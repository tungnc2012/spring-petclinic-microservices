# Spring Petclinic Microservices - Status Checking Guide

## Quick Status Check

Run the automated status checker:
```bash
cd ~/Code/Learn/SRE/spring-petclinic-microservices
./check-services.sh
```

This will show you:
- ✓ Which services are running
- ✗ Which services are down
- Port numbers for each service
- Health status
- Eureka registration status
- Quick access URLs

---

## Manual Status Check Methods

### 1. Check Ports (Quick)

Check if services are listening on their ports:

```bash
# Check all services at once
lsof -i :8888 -i :8761 -i :8080 -i :8081 -i :8082 -i :8083

# Or check individual services
lsof -i :8888  # Config Server
lsof -i :8761  # Discovery Server (Eureka)
lsof -i :8080  # API Gateway
lsof -i :8081  # Customers Service
lsof -i :8082  # Visits Service
lsof -i :8083  # Vets Service
```

### 2. Check Health Endpoints

Each Spring Boot service has actuator health endpoints:

```bash
# Config Server
curl http://localhost:8888/actuator/health

# Discovery Server
curl http://localhost:8761/actuator/health

# Customers Service
curl http://localhost:8081/actuator/health

# Vets Service
curl http://localhost:8083/actuator/health

# Visits Service
curl http://localhost:8082/actuator/health

# API Gateway
curl http://localhost:8080/actuator/health
```

**Expected Response:**
```json
{
  "status": "UP"
}
```

### 3. Check Service Registration in Eureka

Visit the Eureka Dashboard in your browser:
```
http://localhost:8761
```

**What to look for:**
- **Instances currently registered with Eureka** section should show:
  - CUSTOMERS-SERVICE
  - VETS-SERVICE
  - VISITS-SERVICE
  - API-GATEWAY
  - (GENAI-SERVICE if started)

**OR** use the REST API:
```bash
# Get all registered services
curl http://localhost:8761/eureka/apps -H "Accept: application/json" | jq

# Check specific service
curl http://localhost:8761/eureka/apps/CUSTOMERS-SERVICE -H "Accept: application/json" | jq
```

### 4. Check Process Status

If you started services manually in separate terminals:

```bash
# Find all Java processes
ps aux | grep spring-petclinic

# Or more specific
ps aux | grep "config-server\|discovery-server\|customers-service\|vets-service\|visits-service\|api-gateway"
```

If you used the `start-services.sh` script:

```bash
# Check PID files
cat logs/config-server.pid
cat logs/discovery-server.pid
cat logs/customers-service.pid
cat logs/vets-service.pid
cat logs/visits-service.pid
cat logs/api-gateway.pid

# Check if those processes are running
ps -p $(cat logs/config-server.pid)
```

### 5. Check Service Logs

#### If started with `start-services.sh`:
```bash
# View logs
tail -f logs/config-server.log
tail -f logs/discovery-server.log
tail -f logs/customers-service.log
tail -f logs/vets-service.log
tail -f logs/visits-service.log
tail -f logs/api-gateway.log

# View all logs at once (multilog)
tail -f logs/*.log
```

#### If started manually in terminals:
- Check the terminal window where you started each service
- Look for log messages indicating startup status

### 6. Test API Endpoints

Once services are registered in Eureka, test the actual API:

```bash
# Get all owners (via API Gateway)
curl http://localhost:8080/api/customer/owners | jq

# Get all vets (via API Gateway)
curl http://localhost:8080/api/vet/vets | jq

# Direct service access (without gateway)
curl http://localhost:8081/owners | jq
curl http://localhost:8083/vets | jq
```

---

## Service Port Reference

| Service | Port | Health Endpoint | Dashboard/UI |
|---------|------|-----------------|--------------|
| Config Server | 8888 | `/actuator/health` | - |
| Discovery Server (Eureka) | 8761 | `/actuator/health` | http://localhost:8761 |
| Customers Service | 8081 | `/actuator/health` | - |
| Visits Service | 8082 | `/actuator/health` | - |
| Vets Service | 8083 | `/actuator/health` | - |
| GenAI Service | 8084 | `/actuator/health` | - |
| API Gateway | 8080 | `/actuator/health` | http://localhost:8080 |
| Admin Server | 9090 | `/actuator/health` | http://localhost:9090 |
| Zipkin (Tracing) | 9411 | `/actuator/health` | http://localhost:9411/zipkin |
| Prometheus | 9091 | `/-/healthy` | http://localhost:9091 |
| Grafana | 3030 | `/api/health` | http://localhost:3030 |

---

## Troubleshooting Service Status

### Service Won't Start

1. **Check if port is already in use:**
   ```bash
   lsof -i :8888  # Replace with your service port
   ```
   If something is using the port, kill it:
   ```bash
   kill -9 <PID>
   ```

2. **Check Config Server is running:**
   ```bash
   curl http://localhost:8888/actuator/health
   ```
   Other services depend on Config Server!

3. **Check Discovery Server is running:**
   ```bash
   curl http://localhost:8761/actuator/health
   ```
   Services need to register with Eureka.

4. **Check service logs for errors:**
   ```bash
   tail -f logs/<service-name>.log
   ```
   or check the terminal where you started it.

### Service Started But Not Registered in Eureka

1. Wait 30-60 seconds (registration takes time)
2. Check if Discovery Server is running on port 8761
3. Check service logs for connection errors
4. Verify the service's `application.yml` has correct Eureka configuration

### Health Endpoint Returns 503

The service is running but not fully initialized:
- Database connection issues
- Dependency services not available
- Still starting up

Wait a few moments and check again.

---

## Monitoring Dashboard URLs

Once all services are running, access these dashboards:

- **Application**: http://localhost:8080
- **Eureka Dashboard**: http://localhost:8761
- **Spring Boot Admin**: http://localhost:9090
- **Zipkin Tracing**: http://localhost:9411/zipkin
- **Prometheus**: http://localhost:9091
- **Grafana**: http://localhost:3030 (default credentials: admin/admin)

---

## Quick Status Check One-Liners

```bash
# Check all service ports
lsof -i :8888 -i :8761 -i :8080 -i :8081 -i :8082 -i :8083 | grep LISTEN

# Check all health endpoints
for port in 8888 8761 8080 8081 8082 8083; do echo "Port $port:"; curl -s http://localhost:$port/actuator/health | jq .status; done

# Count registered services in Eureka
curl -s http://localhost:8761/eureka/apps -H "Accept: application/json" | jq '.applications.application | length'

# Watch service status (refresh every 2 seconds)
watch -n 2 ./check-services.sh
```

---

## Using the Helper Scripts

### Start all services:
```bash
./start-services.sh
```

### Check status:
```bash
./check-services.sh
```

### Stop all services:
```bash
./stop-services.sh
```

### Watch status continuously:
```bash
watch -n 5 ./check-services.sh
```
