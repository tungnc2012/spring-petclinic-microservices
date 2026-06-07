#!/bin/bash

# Helper script to stop all Spring Petclinic microservices

echo "======================================================"
echo "Stopping Spring Petclinic Microservices"
echo "======================================================"
echo ""

# Function to stop a service
stop_service() {
    SERVICE_NAME=$1
    PID_FILE="logs/${SERVICE_NAME}.pid"
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null; then
            echo "Stopping $SERVICE_NAME (PID: $PID)..."
            kill $PID
            rm "$PID_FILE"
        else
            echo "$SERVICE_NAME is not running"
            rm "$PID_FILE"
        fi
    else
        echo "$SERVICE_NAME PID file not found"
    fi
}

# Stop services in reverse order
stop_service "api-gateway"
stop_service "visits-service"
stop_service "vets-service"
stop_service "customers-service"
stop_service "discovery-server"
stop_service "config-server"

echo ""
echo "All services stopped!"
echo ""
