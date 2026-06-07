#!/bin/bash

# Helper script to start Spring Petclinic microservices locally
# Each service should be started in a separate terminal

echo "======================================================"
echo "Spring Petclinic Microservices - Startup Guide"
echo "======================================================"
echo ""
echo "Services must be started in the following order:"
echo ""
echo "1. Config Server (REQUIRED - must start first)"
echo "   cd spring-petclinic-config-server && ../mvnw spring-boot:run"
echo ""
echo "2. Discovery Server (REQUIRED - must start second)"
echo "   cd spring-petclinic-discovery-server && ../mvnw spring-boot:run"
echo ""
echo "3. Customers Service"
echo "   cd spring-petclinic-customers-service && ../mvnw spring-boot:run"
echo ""
echo "4. Vets Service"
echo "   cd spring-petclinic-vets-service && ../mvnw spring-boot:run"
echo ""
echo "5. Visits Service"
echo "   cd spring-petclinic-visits-service && ../mvnw spring-boot:run"
echo ""
echo "6. API Gateway"
echo "   cd spring-petclinic-api-gateway && ../mvnw spring-boot:run"
echo ""
echo "7. GenAI Service (Optional - requires OpenAI API key)"
echo "   cd spring-petclinic-genai-service && ../mvnw spring-boot:run"
echo ""
echo "======================================================"
echo "Once all services are running, access:"
echo "- Application: http://localhost:8080"
echo "- Eureka Dashboard: http://localhost:8761"
echo "- Config Server: http://localhost:8888"
echo "======================================================"
echo ""
echo "Starting services automatically..."
echo ""

# Function to start a service in the background
start_service() {
    SERVICE_NAME=$1
    SERVICE_DIR=$2
    
    echo "Starting $SERVICE_NAME..."
    cd "$SERVICE_DIR"
    ../mvnw spring-boot:run > "../logs/${SERVICE_NAME}.log" 2>&1 &
    echo "$!" > "../logs/${SERVICE_NAME}.pid"
    cd ..
    echo "$SERVICE_NAME started (PID: $(cat logs/${SERVICE_NAME}.pid))"
    echo ""
}

# Create logs directory
mkdir -p logs

# Start services in order with delays
echo "Step 1: Starting Config Server..."
start_service "config-server" "spring-petclinic-config-server"
echo "Waiting 30 seconds for Config Server to initialize..."
sleep 30

echo "Step 2: Starting Discovery Server..."
start_service "discovery-server" "spring-petclinic-discovery-server"
echo "Waiting 30 seconds for Discovery Server to initialize..."
sleep 30

echo "Step 3: Starting microservices..."
start_service "customers-service" "spring-petclinic-customers-service"
sleep 5

start_service "vets-service" "spring-petclinic-vets-service"
sleep 5

start_service "visits-service" "spring-petclinic-visits-service"
sleep 5

echo "Step 4: Starting API Gateway..."
start_service "api-gateway" "spring-petclinic-api-gateway"

echo ""
echo "======================================================"
echo "All services started!"
echo "======================================================"
echo ""
echo "Logs are available in the 'logs' directory"
echo "To stop all services, run: ./stop-services.sh"
echo ""
echo "Monitor service registration at: http://localhost:8761"
echo "Access the application at: http://localhost:8080"
echo ""
