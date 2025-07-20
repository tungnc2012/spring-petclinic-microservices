### Plan
1. List all services from 

docker-compose.yaml


2. Organize by function (observability, application, infrastructure)
3. Detail key configurations

### Services Overview

#### Observability Stack
1. **otel-collector**
   - Image: `otel/opentelemetry-collector:0.120.0`
   - Port: 4318
   - Purpose: Telemetry collection

2. **grafana**
   - Image: `grafana/grafana:11.5.2`
   - Anonymous auth enabled
   - Purpose: Visualization

3. **tempo**
   - Image: `grafana/tempo`
   - Port: 3200
   - Purpose: Distributed tracing

4. **loki**
   - Image: `grafana/loki`
   - Port: 3100
   - Purpose: Log aggregation

5. **mimir**
   - Image: `grafana/mimir`
   - Multiple replicas
   - Purpose: Metrics storage