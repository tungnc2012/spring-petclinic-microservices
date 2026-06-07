#!/bin/bash

# Helper script to check the status of Spring Petclinic microservices

echo "======================================================"
echo "Spring Petclinic Microservices - Status Check"
echo "======================================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a service is running on a specific port
check_port() {
    SERVICE_NAME=$1
    PORT=$2
    ENDPOINT=$3
    
    printf "%-30s" "$SERVICE_NAME:"
    
    # Check if port is listening
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        # Try to hit the actuator health endpoint
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$PORT$ENDPOINT 2>/dev/null)
        
        if [ "$HTTP_CODE" = "200" ]; then
            echo -e "${GREEN}✓ RUNNING${NC} (Port: $PORT, Health: OK)"
        elif [ "$HTTP_CODE" = "503" ]; then
            echo -e "${YELLOW}⚠ STARTING${NC} (Port: $PORT, Health: Service Unavailable)"
        else
            echo -e "${YELLOW}⚠ UP${NC} (Port: $PORT, Health endpoint status: $HTTP_CODE)"
        fi
    else
        echo -e "${RED}✗ DOWN${NC} (Port: $PORT not listening)"
    fi
}

# Function to check service registration in Eureka
check_eureka_registration() {
    echo ""
    echo "======================================================"
    echo "Service Registration Status (Eureka)"
    echo "======================================================"
    
    if curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" > /dev/null 2>&1; then
        EUREKA_APPS=$(curl -s http://localhost:8761/eureka/apps -H "Accept: application/json")
        
        echo ""
        printf "%-30s" "CUSTOMERS-SERVICE:"
        if echo "$EUREKA_APPS" | grep -q "CUSTOMERS-SERVICE"; then
            echo -e "${GREEN}✓ Registered${NC}"
        else
            echo -e "${RED}✗ Not Registered${NC}"
        fi
        
        printf "%-30s" "VETS-SERVICE:"
        if echo "$EUREKA_APPS" | grep -q "VETS-SERVICE"; then
            echo -e "${GREEN}✓ Registered${NC}"
        else
            echo -e "${RED}✗ Not Registered${NC}"
        fi
        
        printf "%-30s" "VISITS-SERVICE:"
        if echo "$EUREKA_APPS" | grep -q "VISITS-SERVICE"; then
            echo -e "${GREEN}✓ Registered${NC}"
        else
            echo -e "${RED}✗ Not Registered${NC}"
        fi
        
        printf "%-30s" "API-GATEWAY:"
        if echo "$EUREKA_APPS" | grep -q "API-GATEWAY"; then
            echo -e "${GREEN}✓ Registered${NC}"
        else
            echo -e "${RED}✗ Not Registered${NC}"
        fi
        
        printf "%-30s" "GENAI-SERVICE:"
        if echo "$EUREKA_APPS" | grep -q "GENAI-SERVICE"; then
            echo -e "${GREEN}✓ Registered${NC}"
        else
            echo -e "${YELLOW}⚠ Not Registered${NC} (optional service)"
        fi
    else
        echo -e "${RED}Cannot connect to Eureka. Discovery Server might be down.${NC}"
    fi
}

# Check each service
echo "Checking Infrastructure Services:"
echo "------------------------------------------------------"
check_port "Config Server" "8888" "/actuator/health"
check_port "Discovery Server (Eureka)" "8761" "/actuator/health"

echo ""
echo "Checking Microservices (using random ports):"
echo "------------------------------------------------------"

# Check microservices via Eureka (they use random ports)
if curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" > /dev/null 2>&1; then
    # Get Customers Service port from Eureka
    CUSTOMERS_PORT=$(curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" | jq -r '.applications.application[] | select(.name == "CUSTOMERS-SERVICE") | .instance[0].port."$"' 2>/dev/null)
    if [ ! -z "$CUSTOMERS_PORT" ] && [ "$CUSTOMERS_PORT" != "null" ]; then
        check_port "Customers Service" "$CUSTOMERS_PORT" "/actuator/health"
    else
        printf "%-30s" "Customers Service:"
        echo -e "${RED}✗ Not Found in Eureka${NC}"
    fi
    
    # Get Vets Service port from Eureka
    VETS_PORT=$(curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" | jq -r '.applications.application[] | select(.name == "VETS-SERVICE") | .instance[0].port."$"' 2>/dev/null)
    if [ ! -z "$VETS_PORT" ] && [ "$VETS_PORT" != "null" ]; then
        check_port "Vets Service" "$VETS_PORT" "/actuator/health"
    else
        printf "%-30s" "Vets Service:"
        echo -e "${RED}✗ Not Found in Eureka${NC}"
    fi
    
    # Get Visits Service port from Eureka
    VISITS_PORT=$(curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" | jq -r '.applications.application[] | select(.name == "VISITS-SERVICE") | .instance[0].port."$"' 2>/dev/null)
    if [ ! -z "$VISITS_PORT" ] && [ "$VISITS_PORT" != "null" ]; then
        check_port "Visits Service" "$VISITS_PORT" "/actuator/health"
    else
        printf "%-30s" "Visits Service:"
        echo -e "${RED}✗ Not Found in Eureka${NC}"
    fi
else
    printf "%-30s" "Customers Service:"
    echo -e "${YELLOW}⚠ Cannot check - Eureka down${NC}"
    printf "%-30s" "Vets Service:"
    echo -e "${YELLOW}⚠ Cannot check - Eureka down${NC}"
    printf "%-30s" "Visits Service:"
    echo -e "${YELLOW}⚠ Cannot check - Eureka down${NC}"
fi

echo ""
echo "Checking API Gateway:"
echo "------------------------------------------------------"
check_port "API Gateway" "8080" "/actuator/health"

echo ""
echo "Checking Optional Services:"
echo "------------------------------------------------------"
check_port "GenAI Service" "8084" "/actuator/health"
check_port "Admin Server" "9090" "/actuator/health"
check_port "Zipkin (Tracing)" "9411" "/actuator/health"
check_port "Prometheus" "9091" "/-/healthy"
check_port "Grafana" "3030" "/api/health"

# Check Eureka registration
check_eureka_registration

echo ""
echo "======================================================"
echo "Quick Access URLs:"
echo "======================================================"
echo "Application:        http://localhost:8080"
echo "Eureka Dashboard:   http://localhost:8761"
echo "Config Server:      http://localhost:8888"
echo "Admin Server:       http://localhost:9090"
echo "Zipkin:             http://localhost:9411"
echo "Prometheus:         http://localhost:9091"
echo "Grafana:            http://localhost:3030"
echo ""
echo "======================================================"
echo "Process Status (if started with start-services.sh):"
echo "======================================================"

# Check PIDs if services were started with the start script
if [ -d "logs" ]; then
    for pidfile in logs/*.pid; do
        if [ -f "$pidfile" ]; then
            SERVICE=$(basename "$pidfile" .pid)
            PID=$(cat "$pidfile")
            printf "%-30s" "$SERVICE:"
            if ps -p $PID > /dev/null 2>&1; then
                echo -e "${GREEN}✓ Running${NC} (PID: $PID)"
            else
                echo -e "${RED}✗ Not Running${NC} (Stale PID: $PID)"
            fi
        fi
    done
else
    echo "No PID files found. Services may have been started manually."
fi

echo ""
