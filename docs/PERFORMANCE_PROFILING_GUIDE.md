# CrystalCog Performance Profiling and Optimization Guide

This guide covers the comprehensive performance profiling and optimization tools added to CrystalCog as part of the development roadmap.

## Overview

The performance profiling system provides:
- **CPU and Memory Profiling**: Detailed timing and memory allocation tracking
- **Regression Detection**: Automatic detection of performance regressions over time
- **Optimization Recommendations**: AI-powered suggestions for improving performance
- **Real-time Monitoring**: Live performance dashboard with alerting
- **Comprehensive Reporting**: Detailed analysis and visualization tools

## Quick Start

### 1. Basic Profiling

```crystal
require "cogutil/performance_profiler"

# Start a profiling session
CogUtil::PerformanceProfiler.start_session

# Profile a function
result = CogUtil::PerformanceProfiler.profile("my_function") do
  # Your code here
  expensive_computation()
end

# End session and get results
session = CogUtil::PerformanceProfiler.end_session
puts CogUtil::PerformanceProfiler.generate_report
```

### 2. Memory Profiling

```crystal
result = CogUtil::PerformanceProfiler.profile_memory_allocation("memory_test") do
  large_array = Array(Int32).new(10000) { |i| i }
  large_array.sum
end

puts "Result: #{result[:result]}"
puts "Memory allocated: #{result[:allocation][:heap_allocated]} bytes"
```

### 3. Statistical Analysis

```crystal
stats = CogUtil::PerformanceProfiler.profile_iterations("function_test", 100) do
  my_function()
end

puts "Average time: #{stats[:average]}s"
puts "Standard deviation: #{stats[:std_deviation]}s"
```

## Command Line Interface

The profiling tools include a comprehensive CLI:

```bash
# Profile an application
./tools/profiler profile --duration 60 --output results.json

# Analyze performance data
./tools/profiler analyze --input results.json --baseline baseline.json

# Start real-time monitoring
./tools/profiler monitor --port 8080

# Generate optimization recommendations
./tools/profiler optimize --input results.json --priority 70

# Compare performance between versions
./tools/profiler compare --baseline v1.json --current v2.json

# Run built-in benchmarks
./tools/profiler benchmark --suite atomspace --iterations 1000
```

## Performance Monitoring

### Setting Up Real-time Monitoring

```crystal
# Initialize monitor
monitor = CogUtil::PerformanceMonitor.new

# Start monitoring with 1-second intervals
monitor.start_monitoring(1.second)

# Start web dashboard
monitor.start_dashboard(8080)

# Record custom metrics
monitor.record_metric("response_time", 0.045)
monitor.record_metric("memory_usage", 150_000_000.0)
```

### Alert Configuration

```crystal
# Create custom alert rules
alert_rule = CogUtil::PerformanceMonitor::AlertRule.new(
  name: "high_response_time",
  metric_pattern: "response_time",
  threshold: 0.1,  # 100ms
  comparison: "gt",
  duration: 30.seconds,
  severity: "warning"
)

monitor.add_alert_rule(alert_rule)
```

### Dashboard Features

The web dashboard (accessible at `http://localhost:8080`) provides:
- Real-time metric visualization
- Active alert display
- Performance trend analysis
- System health overview
- Interactive metric exploration

## Regression Detection

### Automatic Regression Analysis

```crystal
# Initialize regression detector
regression = CogUtil::PerformanceRegression.new("performance_history.json")

# Record current performance
regression.record_metrics(session, "v2.1.0")

# Analyze for regressions
regressions = regression.analyze_regressions(session)

# Generate report
puts regression.generate_regression_report(regressions)
```

### Trend Analysis

```crystal
# Get trend analysis for specific functions
trends = regression.get_trend_analysis("critical_function", 30)

if trends
  puts "Time trend: #{trends["time_trend"]}"
  puts "Memory trend: #{trends["memory_trend"]}"
  puts "Variance: #{trends["time_variance"]}"
end
```

## Optimization Engine

### Generating Recommendations

```crystal
# Initialize optimization engine
engine = CogUtil::OptimizationEngine.new

# Analyze performance and get recommendations
recommendations = engine.analyze_and_recommend(session)

# Filter by priority
high_priority = recommendations.select { |r| r.priority >= 80 }

# Generate detailed report
puts engine.generate_optimization_report(recommendations)
```

### Optimization Roadmap

```crystal
# Get prioritized optimization roadmap
roadmap = engine.get_optimization_roadmap(recommendations)

roadmap.each do |phase, recs|
  puts "#{phase}:"
  recs.each do |rec|
    puts "  • #{rec.function_name}: #{rec.optimization_strategy}"
    puts "    Expected improvement: #{(rec.expected_improvement * 100).round(1)}%"
  end
end
```

### Recommendation Categories

The optimization engine provides recommendations in several categories:

1. **Performance**: Algorithm improvements, hot path optimization
2. **Memory**: Memory pooling, allocation reduction
3. **Caching**: Result caching, memoization opportunities
4. **Reliability**: Error handling improvements
5. **Architecture**: Structural improvements, concurrency

## Integration with Existing Code

### Automatic Profiling with Decorators

```crystal
class MyClass
  include CogUtil::ProfiledMethod
  
  # Automatically profile this method
  profile_method expensive_operation
  
  def expensive_operation(data)
    # Original method implementation
    process_data(data)
  end
end
```

### Conditional Profiling

```crystal
def my_function(data)
  if CogUtil.config_get("ENABLE_PROFILING", "false") == "true"
    CogUtil::PerformanceProfiler.profile("my_function") do
      process_data(data)
    end
  else
    process_data(data)
  end
end
```

## Advanced Features

### Custom Metrics Collection

```crystal
# Record business-specific metrics
monitor.record_metric("user_actions_per_second", 42.5, {
  "action_type" => "search",
  "user_segment" => "premium"
})

# Create metric aggregations
monitor.record_metric("database_query_time", query_time, {
  "query_type" => "SELECT",
  "table" => "users"
})
```

### Performance Comparison Tools

```crystal
# Compare against baseline
baseline_session = load_baseline_data("v1.0.0")
current_session = current_profiling_session

regression = CogUtil::PerformanceRegression.new
regressions = regression.analyze_regressions(current_session)

# Detailed comparison
regressions.each do |reg|
  if reg.critical?
    puts "CRITICAL: #{reg.function_name} performance degraded by #{reg.change_percentage}%"
  end
end
```

### Export and Integration

```crystal
# Export to JSON for external analysis
json_data = CogUtil::PerformanceProfiler.export_metrics
File.write("performance_data.json", json_data)

# Export monitoring data to CSV
csv_data = monitor.export_monitoring_data("csv")
File.write("monitoring_data.csv", csv_data)

# Integration with external tools
performance_data = JSON.parse(json_data)
send_to_analytics_service(performance_data)
```

## Best Practices

### 1. Production Use Guidelines

- Use sampling for high-frequency operations
- Set appropriate buffer sizes for monitoring
- Configure reasonable alert thresholds
- Regular cleanup of historical data

```crystal
# Production-safe profiling
if rand < 0.01  # Sample 1% of operations
  CogUtil::PerformanceProfiler.profile("production_operation") do
    critical_business_logic()
  end
else
  critical_business_logic()
end
```

### 2. Optimization Workflow

1. **Profile** your application under realistic load
2. **Identify** bottlenecks using the optimization engine
3. **Prioritize** optimizations by impact and difficulty
4. **Implement** changes incrementally
5. **Validate** improvements with regression testing
6. **Monitor** ongoing performance

### 3. Alert Configuration

- Set progressive alert thresholds (warning → critical)
- Use appropriate time windows for alerts
- Configure different alerts for different environments
- Implement alert fatigue prevention

```crystal
# Progressive alerting
warning_rule = AlertRule.new(
  name: "response_time_warning",
  threshold: 0.1,  # 100ms
  severity: "warning"
)

critical_rule = AlertRule.new(
  name: "response_time_critical", 
  threshold: 0.5,  # 500ms
  severity: "critical"
)
```

## Performance Impact

The profiling tools are designed for minimal overhead:
- **Profiling overhead**: < 5% for typical applications
- **Monitoring overhead**: < 2% for reasonable metric frequency
- **Memory overhead**: Configurable buffer sizes
- **Storage overhead**: Automatic cleanup and compression

## Troubleshooting

### Common Issues

1. **High profiling overhead**: Reduce profiling frequency or use sampling
2. **Memory usage**: Adjust buffer sizes in monitoring configuration
3. **Alert spam**: Tune alert thresholds and duration windows
4. **Missing data**: Check session management and ensure proper cleanup

### Debugging

```crystal
# Enable verbose logging
CogUtil::Logger.set_level(CogUtil::Logger::DEBUG)

# Check profiler session state
if session = CogUtil::PerformanceProfiler.current_session
  puts "Active session with #{session.all_metrics.size} functions"
else
  puts "No active profiling session"
end

# Validate monitoring state
puts "Monitoring active: #{monitor.monitoring_active?}"
puts "Sample count: #{monitor.sample_count}"
```

## Examples and Demos

See the comprehensive demo in `benchmarks/comprehensive_performance_demo.cr` for:
- Complete profiling workflow
- Real-world optimization scenarios
- Stress testing examples
- Performance comparison techniques

## API Reference

### Core Classes

- `CogUtil::PerformanceProfiler`: Main profiling interface
- `CogUtil::PerformanceRegression`: Regression detection and analysis
- `CogUtil::OptimizationEngine`: Optimization recommendation system
- `CogUtil::PerformanceMonitor`: Real-time monitoring and alerting
- `CogUtil::ProfilingCLI`: Command-line interface

### Configuration Options

Environment variables for configuration:
- `CRYSTALCOG_PROFILING_ENABLED`: Enable/disable profiling
- `CRYSTALCOG_MONITORING_INTERVAL`: Default monitoring interval
- `CRYSTALCOG_ALERT_BUFFER_SIZE`: Alert buffer size
- `CRYSTALCOG_PERFORMANCE_STORAGE`: Performance data storage path

## Contributing

When adding new profiling features:
1. Follow the existing API patterns
2. Add comprehensive tests
3. Update documentation
4. Consider performance impact
5. Validate with real workloads

## License

This performance profiling system is part of CrystalCog and follows the same licensing terms as the main project.