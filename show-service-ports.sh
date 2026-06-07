#!/bin/bash

# Script to clearly show all service ports from Eureka

echo "======================================================"
echo "Spring Petclinic - Service Port Information"
echo "======================================================"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if ! curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" > /dev/null 2>&1; then
    echo "❌ Cannot connect to Eureka at http://localhost:8761"
    echo "Make sure Discovery Server is running!"
    exit 1
fi

echo -e "${BLUE}Infrastructure Services (Fixed Ports):${NC}"
echo "─────────────────────────────────────────────"
printf "%-30s %-15s %s\n" "Service" "Port" "URL"
printf "%-30s %-15s %s\n" "Config Server" "8888" "http://localhost:8888"
printf "%-30s %-15s %s\n" "Discovery Server (Eureka)" "8761" "http://localhost:8761"
printf "%-30s %-15s %s\n" "API Gateway" "8080" "http://localhost:8080"

echo ""
echo -e "${BLUE}Microservices (Random Ports):${NC}"
echo "─────────────────────────────────────────────"
printf "%-30s %-15s %s\n" "Service" "Port" "Health URL"

# Get Customers Service info
CUSTOMERS_DATA=$(curl -s http://localhost:8761/eureka/apps/CUSTOMERS-SERVICE -H "Accept: application/json" | jq -r '.application.instance[0] | {port: .port."$", host: .hostName}' 2>/dev/null)
if [ ! -z "$CUSTOMERS_DATA" ] && [ "$CUSTOMERS_DATA" != "null" ]; then
    PORT=$(echo "$CUSTOMERS_DATA" | jq -r '.port')
    HOST=$(echo "$CUSTOMERS_DATA" | jq -r '.host')
    printf "%-30s ${GREEN}%-15s${NC} http://%s:%s/actuator/health\n" "Customers Service" "$PORT" "$HOST" "$PORT"
fi

# Get Vets Service info
VETS_DATA=$(curl -s http://localhost:8761/eureka/apps/VETS-SERVICE -H "Accept: application/json" | jq -r '.application.instance[0] | {port: .port."$", host: .hostName}' 2>/dev/null)
if [ ! -z "$VETS_DATA" ] && [ "$VETS_DATA" != "null" ]; then
    PORT=$(echo "$VETS_DATA" | jq -r '.port')
    HOST=$(echo "$VETS_DATA" | jq -r '.host')
    printf "%-30s ${GREEN}%-15s${NC} http://%s:%s/actuator/health\n" "Vets Service" "$PORT" "$HOST" "$PORT"
fi

# Get Visits Service info
VISITS_DATA=$(curl -s http://localhost:8761/eureka/apps/VISITS-SERVICE -H "Accept: application/json" | jq -r '.application.instance[0] | {port: .port."$", host: .hostName}' 2>/dev/null)
if [ ! -z "$VISITS_DATA" ] && [ "$VISITS_DATA" != "null" ]; then
    PORT=$(echo "$VISITS_DATA" | jq -r '.port')
    HOST=$(echo "$VISITS_DATA" | jq -r '.host')
    printf "%-30s ${GREEN}%-15s${NC} http://%s:%s/actuator/health\n" "Visits Service" "$PORT" "$HOST" "$PORT"
fi

# Get GenAI Service info (optional)
GENAI_DATA=$(curl -s http://localhost:8761/eureka/apps/GENAI-SERVICE -H "Accept: application/json" | jq -r '.application.instance[0] | {port: .port."$", host: .hostName}' 2>/dev/null)
if [ ! -z "$GENAI_DATA" ] && [ "$GENAI_DATA" != "null" ]; then
    PORT=$(echo "$GENAI_DATA" | jq -r '.port')
    HOST=$(echo "$GENAI_DATA" | jq -r '.host')
    printf "%-30s ${GREEN}%-15s${NC} http://%s:%s/actuator/health\n" "GenAI Service (optional)" "$PORT" "$HOST" "$PORT"
fi

echo ""
echo "======================================================"
echo -e "${YELLOW}Note:${NC} Microservices use random ports by design."
echo "The API Gateway discovers them via Eureka and routes"
echo "requests automatically. Always access via:"
echo -e "  ${GREEN}http://localhost:8080${NC}"
echo "======================================================"
echo ""
