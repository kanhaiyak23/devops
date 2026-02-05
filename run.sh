#!/bin/bash

# Configuration
ENV=${1:-dev}          # Environment: dev, prod, test (default: dev)
SERVER_PORT=${2:-3000} # Backend port (default: 3000)
CLIENT_PORT=${3:-5173} # Frontend port (default: 5173)

echo "=========================================="
echo "  ShopSmart Development Setup Script"
echo "=========================================="
echo "Environment: $ENV"
echo "Server Port: $SERVER_PORT"
echo "Client Port: $CLIENT_PORT"
echo "=========================================="

# Exit on error
set -e

# Function to log messages
log() {
    echo "[INFO] $(date '+%Y-%m-%d %H:%M:%S') $1"
}

# Function to handle errors
error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') $1" >&2
    exit 1
}

# Function to check if a command exists
check_command() {
    command -v "$1" >/dev/null 2>&1 || error "$2 is not installed. Please install $2 to continue."
}

# 1. Check Prerequisites
log "Checking prerequisites..."
check_command node "Node.js"
check_command npm "npm"
log "Prerequisites met: Node $(node -v), npm $(npm -v)"

# 2. Setup Server (Backend)
log "Setting up Backend (Server)..."
if [ ! -d "server" ]; then
    error "Server directory not found! Make sure you're running this script from the project root."
fi

cd server
if [ ! -d "node_modules" ] || [ package.json -nt node_modules ]; then
    log "Installing/Updating server dependencies..."
    npm install
else
    log "Server dependencies are up to date."
fi
cd ..

# 3. Setup Client (Frontend)
log "Setting up Frontend (Client)..."
if [ ! -d "client" ]; then
    error "Client directory not found! Make sure you're running this script from the project root."
fi

cd client
if [ ! -d "node_modules" ] || [ package.json -nt node_modules ]; then
    log "Installing/Updating client dependencies..."
    npm install
else
    log "Client dependencies are up to date."
fi
cd ..

# 4. Environment-specific actions
case $ENV in
    "dev")
        log "Development environment selected."
        log "Starting both server and client in development mode..."
        
        # Start server in background
        cd server
        log "Starting backend server on port $SERVER_PORT..."
        PORT=$SERVER_PORT npm run dev &
        SERVER_PID=$!
        cd ..
        
        # Start client
        cd client
        log "Starting frontend client on port $CLIENT_PORT..."
        VITE_PORT=$CLIENT_PORT npm run dev &
        CLIENT_PID=$!
        cd ..
        
        log "Server PID: $SERVER_PID, Client PID: $CLIENT_PID"
        log "Press Ctrl+C to stop both servers."
        
        # Handle shutdown
        trap "kill $SERVER_PID $CLIENT_PID 2>/dev/null; exit" SIGINT SIGTERM
        wait
        ;;
    "prod")
        log "Production environment selected."
        log "Building frontend for production..."
        cd client
        npm run build
        cd ..
        
        log "Starting backend server in production mode..."
        cd server
        PORT=$SERVER_PORT npm start
        ;;
    "test")
        log "Test environment selected."
        log "Running server tests..."
        cd server
        npm test
        cd ..
        
        log "Running client tests..."
        cd client
        npm test
        cd ..
        ;;
    "build")
        log "Build-only mode selected."
        log "Building frontend..."
        cd client
        npm run build
        cd ..
        log "Build completed successfully!"
        ;;
    *)
        error "Unknown environment: $ENV. Valid options are: dev, prod, test, build"
        ;;
esac

# 5. Final Verification
log "ShopSmart setup completed successfully!"
exit 0
