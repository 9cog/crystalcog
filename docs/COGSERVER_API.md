# CogServer Network API Documentation

This document describes the network API provided by the Crystal CogServer implementation.

## Overview

The CogServer provides multiple network interfaces for interacting with the OpenCog AtomSpace:

- **HTTP REST API**: RESTful endpoints for AtomSpace operations (Port 18080)
- **WebSocket Protocol**: Real-time communication support (Port 18080)
- **Telnet Interface**: Command-line interface simulation (Port 17001)

## Starting the CogServer

```bash
# Start with default settings
crystal run src/cogserver/cogserver_main.cr

# Or with custom ports
crystal run src/cogserver/cogserver_main.cr -- --host 0.0.0.0 --port 17002 --ws-port 18081
```

## HTTP REST API Endpoints

### GET /status
Returns server status and statistics.

**Response:**
```json
{
  "running": true,
  "host": "localhost",
  "port": 17001,
  "ws_port": 18080,
  "active_sessions": 2,
  "atomspace_size": 42,
  "atomspace_nodes": 25,
  "atomspace_links": 17
}
```

### GET /atomspace
Returns AtomSpace information and contents.

**Response:**
```json
{
  "size": 42,
  "nodes": 25,
  "links": 17,
  "atoms": ["ConceptNode:dog", "ConceptNode:animal", "InheritanceLink(dog, animal)"]
}
```

### GET /atoms
Returns all atoms in the AtomSpace with optional type filtering.

**Query Parameters:**
- `type` (optional): Filter by atom type (e.g., `ConceptNode`, `InheritanceLink`)

**Response:**
```json
{
  "count": 3,
  "atoms": [
    {
      "type": "ConceptNode",
      "name": "dog",
      "outgoing": null,
      "truth_value": {
        "strength": 0.9,
        "confidence": 0.8
      },
      "string": "ConceptNode:dog"
    }
  ]
}
```

### POST /atoms
Create a new atom in the AtomSpace.

**Request Body:**
```json
{
  "type": "ConceptNode",
  "name": "cat"
}
```

**Response:**
```json
{
  "success": true,
  "atom": {
    "type": "ConceptNode",
    "string": "ConceptNode:cat"
  }
}
```

### GET /sessions
Returns information about active sessions.

**Response:**
```json
{
  "active_sessions": 2,
  "sessions": [
    {
      "id": "abc123def456",
      "type": "websocket",
      "created_at": "2024-09-04T10:30:00Z",
      "duration": 45.2,
      "closed": false
    }
  ]
}
```

### GET /ping
Health check endpoint.

**Response:**
```json
{
  "status": "ok",
  "timestamp": "2024-09-04T10:30:00Z",
  "server": "CogServer 0.1.0"
}
```

### GET /version
Returns server version information.

**Response:**
```json
{
  "version": "0.1.0",
  "crystal_version": "1.10.1",
  "server_type": "CogServer",
  "api_version": "1.0"
}
```

## WebSocket Protocol

### Connection
Connect to `ws://localhost:18080/` with proper WebSocket headers:

```javascript
const ws = new WebSocket('ws://localhost:18080/');
ws.onopen = function() {
    console.log('Connected to CogServer');
};
```

### Upgrade Headers
Required headers for WebSocket upgrade:
- `Connection: Upgrade`
- `Upgrade: websocket`
- `Sec-WebSocket-Key: [base64-key]`
- `Sec-WebSocket-Version: 13`

## Telnet Interface

### Connection
Connect via HTTP with command query parameters:

```bash
# Basic connection
curl "http://localhost:17001/"

# Execute a command
curl "http://localhost:17001/?cmd=help"
```

### Available Commands

- `help` - Show available commands
- `info` - Display server information
- `atomspace` - Show AtomSpace statistics
- `list` - List atoms in AtomSpace (first 10)
- `stats` - Show session statistics
- `quit/exit` - Close session

### Example Session
```bash
$ curl "http://localhost:17001/?cmd=help"
Welcome to CogServer 0.1.0
Session ID: abc123def456
AtomSpace contains 42 atoms
Type 'help' for available commands
cog> 

Available commands:
help          - Show this help message
info          - Show server information  
atomspace     - Show AtomSpace statistics
list          - List atoms in AtomSpace
stats         - Show session statistics
quit, exit    - Close session
cog>
```

## Error Handling

All endpoints return consistent JSON error responses:

```json
{
  "error": "Error description"
}
```

Common HTTP status codes:
- `200` - Success
- `201` - Created (for POST requests)
- `400` - Bad Request
- `404` - Not Found
- `405` - Method Not Allowed
- `500` - Internal Server Error
- `501` - Not Implemented

## Integration Examples

### Python Client
```python
import requests
import json

# Get server status
response = requests.get('http://localhost:18080/status')
status = response.json()
print(f"Server running: {status['running']}")

# Add an atom
atom_data = {"type": "ConceptNode", "name": "python"}
response = requests.post('http://localhost:18080/atoms', json=atom_data)
result = response.json()
print(f"Created atom: {result['atom']['string']}")
```

### JavaScript WebSocket
```javascript
const ws = new WebSocket('ws://localhost:18080/');

ws.onopen = function() {
    console.log('Connected to CogServer');
    // Connection established successfully
};

ws.onmessage = function(event) {
    const data = JSON.parse(event.data);
    console.log('Received:', data);
};

ws.onerror = function(error) {
    console.error('WebSocket error:', error);
};
```

### Shell Scripts
```bash
#!/bin/bash

# Check if server is running
curl -f http://localhost:18080/ping > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "CogServer is running"
else
    echo "CogServer is not responding"
    exit 1
fi

# Get AtomSpace statistics
curl -s http://localhost:18080/atomspace | jq '.size'
```

## Performance Considerations

- The HTTP API is designed for occasional administrative tasks
- WebSocket connections provide better performance for real-time applications
- Large AtomSpaces may cause slower response times for `/atoms` endpoint
- Session cleanup happens automatically when connections are closed

## Security Notes

The current implementation provides basic functionality without authentication. For production use, consider:

- Adding authentication mechanisms
- Implementing rate limiting
- Using HTTPS/WSS for encrypted connections
- Restricting network access to trusted clients
- Implementing proper session management and timeouts