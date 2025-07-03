#!/bin/bash

# Rollback Script for Flask E-commerce Application
# This script rolls back to the previous version in case of deployment failure

set -e

# Configuration
APP_NAME="flask-ecommerce"
CONTAINER_NAME="${APP_NAME}-app"
BACKUP_CONTAINER="${APP_NAME}-backup"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
    exit 1
}

log "Starting rollback process..."

# Check if backup container exists
if ! docker ps -a --format 'table {{.Names}}' | grep -q "$BACKUP_CONTAINER"; then
    error "No backup container found. Cannot perform rollback."
fi

# Stop current container
log "Stopping current container..."
if docker ps --format 'table {{.Names}}' | grep -q "$CONTAINER_NAME"; then
    docker stop "$CONTAINER_NAME" || warn "Failed to stop current container"
    docker rm "$CONTAINER_NAME" || warn "Failed to remove current container"
else
    warn "Current container not found"
fi

# Start backup container
log "Starting backup container..."
docker start "$BACKUP_CONTAINER" || error "Failed to start backup container"

# Rename backup container to current
log "Renaming backup container..."
docker rename "$BACKUP_CONTAINER" "$CONTAINER_NAME" || error "Failed to rename container"

# Wait for application to start
log "Waiting for application to start..."
sleep 10

# Health check
log "Performing health check..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if curl -f http://localhost/health > /dev/null 2>&1; then
        log "Health check passed! Rollback successful."
        break
    fi
    
    attempt=$((attempt + 1))
    if [ $attempt -eq $max_attempts ]; then
        error "Health check failed after rollback"
    fi
    
    sleep 2
done

log "Rollback completed successfully!"
log "Application is running at: http://$(curl -s http://checkip.amazonaws.com)"

# Display final status
log "Current application status:"
docker ps --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
