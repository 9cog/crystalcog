#!/bin/bash
# CrystalCog Production Deployment Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.production.yml"
ENV_FILE="$PROJECT_ROOT/.env.production"
BACKUP_DIR="/backup/crystalcog/$(date +%Y%m%d_%H%M%S)"

# Default values
ENVIRONMENT="production"
ACTION="deploy"
BACKUP_BEFORE_DEPLOY="true"
HEALTH_CHECK_TIMEOUT=300
ROLLBACK_ON_FAILURE="true"

print_status() {
    echo -e "${BLUE}[Deploy]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[Deploy]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[Deploy]${NC} $1"
}

print_error() {
    echo -e "${RED}[Deploy]${NC} $1"
}

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Deployment environment (default: production)"
    echo "  -a, --action ACTION      Action to perform: deploy|rollback|stop|status|logs (default: deploy)"
    echo "  --no-backup             Skip backup before deployment"
    echo "  --no-rollback           Don't rollback on failure"
    echo "  --timeout SECONDS       Health check timeout (default: 300)"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                      # Deploy to production with backup"
    echo "  $0 --action status      # Check deployment status"
    echo "  $0 --action rollback    # Rollback to previous version"
    echo "  $0 --no-backup          # Deploy without backup"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--environment)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -a|--action)
            ACTION="$2"
            shift 2
            ;;
        --no-backup)
            BACKUP_BEFORE_DEPLOY="false"
            shift
            ;;
        --no-rollback)
            ROLLBACK_ON_FAILURE="false"
            shift
            ;;
        --timeout)
            HEALTH_CHECK_TIMEOUT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    
    if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
        print_error "Docker Compose file not found: $DOCKER_COMPOSE_FILE"
        exit 1
    fi
    
    if [ ! -f "$ENV_FILE" ]; then
        print_warning "Environment file not found: $ENV_FILE"
        print_warning "Creating default environment file..."
        create_default_env_file
    fi
    
    print_success "Prerequisites check passed"
}

# Create default environment file
create_default_env_file() {
    cat > "$ENV_FILE" << EOF
# CrystalCog Production Environment Configuration

# Database Configuration
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Monitoring Configuration  
GRAFANA_ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)

# Email Configuration (configure for your SMTP server)
SMTP_HOST=smtp.example.com
SMTP_USER=noreply@example.com
SMTP_PASSWORD=your_smtp_password

# SSL Configuration
SSL_CERT_PATH=/etc/ssl/certs/crystalcog.crt
SSL_KEY_PATH=/etc/ssl/certs/crystalcog.key

# Backup Configuration
BACKUP_ENABLED=true
BACKUP_SCHEDULE="0 2 * * *"  # Daily at 2 AM
BACKUP_RETENTION_DAYS=30
EOF
    
    print_warning "Please edit $ENV_FILE with your actual configuration values"
}

# Backup current deployment
backup_deployment() {
    if [ "$BACKUP_BEFORE_DEPLOY" = "false" ]; then
        print_status "Skipping backup as requested"
        return 0
    fi
    
    print_status "Creating backup before deployment..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup database
    if docker-compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q postgres; then
        print_status "Backing up PostgreSQL database..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T postgres \
            pg_dump -U crystalcog_user crystalcog_prod > "$BACKUP_DIR/database.sql"
    fi
    
    # Backup volumes
    print_status "Backing up data volumes..."
    docker run --rm -v crystalcog_app-data:/data -v "$BACKUP_DIR":/backup alpine \
        tar czf /backup/app-data.tar.gz -C /data .
    
    docker run --rm -v crystalcog_redis-data:/data -v "$BACKUP_DIR":/backup alpine \
        tar czf /backup/redis-data.tar.gz -C /data .
    
    # Backup configuration
    cp -r "$PROJECT_ROOT/config" "$BACKUP_DIR/"
    
    print_success "Backup completed: $BACKUP_DIR"
}

# Build and deploy
deploy() {
    print_status "Starting deployment..."
    
    cd "$PROJECT_ROOT"
    
    # Pull latest images
    print_status "Pulling latest images..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" --env-file "$ENV_FILE" pull
    
    # Build application
    print_status "Building application..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" --env-file "$ENV_FILE" build --no-cache crystalcog-app
    
    # Deploy services
    print_status "Deploying services..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" --env-file "$ENV_FILE" up -d
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    wait_for_services
    
    # Run health check
    print_status "Running health check..."
    if run_health_check; then
        print_success "Deployment completed successfully!"
        cleanup_old_images
    else
        print_error "Health check failed!"
        if [ "$ROLLBACK_ON_FAILURE" = "true" ]; then
            print_warning "Rolling back deployment..."
            rollback
        fi
        exit 1
    fi
}

# Wait for services to be ready
wait_for_services() {
    local timeout=$HEALTH_CHECK_TIMEOUT
    local elapsed=0
    local interval=10
    
    while [ $elapsed -lt $timeout ]; do
        if docker-compose -f "$DOCKER_COMPOSE_FILE" ps | grep -q "Up"; then
            print_status "Services are starting... ($elapsed/${timeout}s)"
            sleep $interval
            elapsed=$((elapsed + interval))
        else
            print_error "Services failed to start"
            return 1
        fi
        
        # Check if main application is responding
        if docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T crystalcog-app curl -s -f http://localhost:5000/health >/dev/null 2>&1; then
            print_success "Services are ready!"
            return 0
        fi
    done
    
    print_error "Services did not become ready within timeout"
    return 1
}

# Run comprehensive health check
run_health_check() {
    print_status "Running comprehensive health check..."
    
    if docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T crystalcog-app /usr/local/bin/healthcheck.sh; then
        return 0
    else
        return 1
    fi
}

# Rollback deployment
rollback() {
    print_status "Rolling back deployment..."
    
    # Stop current services
    docker-compose -f "$DOCKER_COMPOSE_FILE" down
    
    # Find most recent backup
    local latest_backup=$(ls -t /backup/crystalcog/ | head -n 1)
    if [ -z "$latest_backup" ]; then
        print_error "No backup found for rollback"
        exit 1
    fi
    
    local backup_path="/backup/crystalcog/$latest_backup"
    print_status "Rolling back to backup: $backup_path"
    
    # Restore database
    if [ -f "$backup_path/database.sql" ]; then
        print_status "Restoring database..."
        docker-compose -f "$DOCKER_COMPOSE_FILE" up -d postgres
        sleep 30
        cat "$backup_path/database.sql" | docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T postgres \
            psql -U crystalcog_user -d crystalcog_prod
    fi
    
    # Restore data volumes
    print_status "Restoring data volumes..."
    if [ -f "$backup_path/app-data.tar.gz" ]; then
        docker run --rm -v crystalcog_app-data:/data -v "$backup_path":/backup alpine \
            sh -c "rm -rf /data/* && tar xzf /backup/app-data.tar.gz -C /data"
    fi
    
    if [ -f "$backup_path/redis-data.tar.gz" ]; then
        docker run --rm -v crystalcog_redis-data:/data -v "$backup_path":/backup alpine \
            sh -c "rm -rf /data/* && tar xzf /backup/redis-data.tar.gz -C /data"
    fi
    
    # Start services
    docker-compose -f "$DOCKER_COMPOSE_FILE" up -d
    
    print_success "Rollback completed"
}

# Show deployment status
show_status() {
    print_status "Deployment Status:"
    docker-compose -f "$DOCKER_COMPOSE_FILE" ps
    echo ""
    
    print_status "Service Health:"
    if docker-compose -f "$DOCKER_COMPOSE_FILE" exec -T crystalcog-app /usr/local/bin/healthcheck.sh; then
        print_success "All services are healthy"
    else
        print_warning "Some services may have issues"
    fi
}

# Show logs
show_logs() {
    docker-compose -f "$DOCKER_COMPOSE_FILE" logs -f --tail=100
}

# Stop deployment
stop_deployment() {
    print_status "Stopping deployment..."
    docker-compose -f "$DOCKER_COMPOSE_FILE" down
    print_success "Deployment stopped"
}

# Cleanup old Docker images
cleanup_old_images() {
    print_status "Cleaning up old Docker images..."
    docker image prune -f
    docker system prune -f --volumes
    print_success "Cleanup completed"
}

# Main execution
main() {
    print_status "CrystalCog Production Deployment Tool"
    print_status "Environment: $ENVIRONMENT"
    print_status "Action: $ACTION"
    
    check_prerequisites
    
    case $ACTION in
        deploy)
            backup_deployment
            deploy
            ;;
        rollback)
            rollback
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        stop)
            stop_deployment
            ;;
        *)
            print_error "Unknown action: $ACTION"
            usage
            exit 1
            ;;
    esac
}

# Run main function
main "$@"