# Requirements Document

## Introduction

This feature provides Kubernetes deployment capabilities for the Spring PetClinic microservices application. The project already has a shared Dockerfile and docker-compose setup. The goal is to create per-service Dockerfiles (where needed) and a comprehensive Helm chart that deploys all microservices to a Kubernetes cluster with proper service discovery, configuration, health checks, and external access.

## Glossary

- **Helm Chart**: A package of pre-configured Kubernetes resource definitions managed by the Helm package manager.
- **PetClinic System**: The Spring PetClinic microservices application comprising Config Server, Discovery Server, API Gateway, Customers Service, Vets Service, Visits Service, GenAI Service, and Admin Server.
- **Config Server**: The Spring Cloud Config Server that provides centralized configuration to all services.
- **Discovery Server**: The Eureka-based service registry that enables service-to-service communication.
- **API Gateway**: The Spring Cloud Gateway that routes external traffic to backend microservices.
- **Service Mesh**: The internal network of Kubernetes Services that enables pod-to-pod communication.
- **Init Container**: A Kubernetes container that runs before the main application container to check preconditions.
- **Values File**: The Helm `values.yaml` file that parameterizes the chart for different environments.

## Requirements

### Requirement 1

**User Story:** As a DevOps engineer, I want each microservice to have a Dockerfile that produces an optimized container image, so that I can build and push images to any container registry.

#### Acceptance Criteria

1. WHEN a developer builds the Docker image for any service THEN the PetClinic System SHALL produce a layered image using Eclipse Temurin 17 as the base with Spring Boot layer extraction.
2. WHEN the Docker build completes THEN the PetClinic System SHALL expose the correct port for each service (Config Server: 8888, Discovery Server: 8761, API Gateway: 8080, Customers: 8081, Vets: 8083, Visits: 8082, GenAI: 8084, Admin: 9090).
3. WHEN a container starts THEN the PetClinic System SHALL activate the `docker` Spring profile by default.

### Requirement 2

**User Story:** As a DevOps engineer, I want a Helm chart that deploys all PetClinic microservices to Kubernetes, so that I can manage the full application lifecycle with a single Helm release.

#### Acceptance Criteria

1. WHEN a user runs `helm install` with the chart THEN the PetClinic System SHALL create Kubernetes Deployment and Service resources for each of the eight microservices.
2. WHEN the chart is rendered THEN the PetClinic System SHALL produce valid Kubernetes manifests that pass `helm template` without errors.
3. WHEN a user provides custom values via `values.yaml` THEN the PetClinic System SHALL override default image repository, tag, replica count, and resource limits for each service.
4. WHEN the chart is installed THEN the PetClinic System SHALL assign a ClusterIP Service to each microservice with the correct target port.

### Requirement 3

**User Story:** As a DevOps engineer, I want services to start in the correct order with health-based dependency management, so that downstream services only start after their dependencies are healthy.

#### Acceptance Criteria

1. WHEN Config Server starts THEN the PetClinic System SHALL expose a readiness probe at the `/actuator/health` endpoint on port 8888.
2. WHEN Discovery Server starts THEN the PetClinic System SHALL wait for Config Server to be healthy using an init container before launching.
3. WHEN any downstream service (Customers, Vets, Visits, GenAI, API Gateway, Admin) starts THEN the PetClinic System SHALL wait for both Config Server and Discovery Server to be healthy using init containers.
4. WHEN a container health check fails THEN Kubernetes SHALL restart the container according to the configured liveness probe.

### Requirement 4

**User Story:** As a user, I want to access the PetClinic web UI through a single external endpoint, so that I can interact with the application from my browser.

#### Acceptance Criteria

1. WHEN the Helm chart is installed THEN the PetClinic System SHALL create an Ingress resource (or NodePort/LoadBalancer Service) that routes external HTTP traffic to the API Gateway on port 8080.
2. WHEN a user configures `ingress.enabled=true` in values THEN the PetClinic System SHALL create an Ingress resource with the specified host and path.
3. WHEN a user sets `api-gateway.service.type=LoadBalancer` THEN the PetClinic System SHALL expose the API Gateway via a cloud load balancer.

### Requirement 5

**User Story:** As a DevOps engineer, I want to configure environment-specific settings through Helm values, so that I can deploy to different clusters without modifying templates.

#### Acceptance Criteria

1. WHEN a user overrides `configServer.git.uri` in values THEN the Config Server SHALL use the specified Git repository for configuration.
2. WHEN a user provides `genai.openaiApiKey` in values THEN the GenAI Service SHALL receive the API key as a Kubernetes Secret mounted as an environment variable.
3. WHEN a user enables the MySQL profile THEN the PetClinic System SHALL configure the data services (Customers, Vets, Visits) with the MySQL JDBC connection string from values.

### Requirement 6

**User Story:** As a DevOps engineer, I want resource limits and requests defined for each service, so that Kubernetes can schedule pods efficiently and prevent resource starvation.

#### Acceptance Criteria

1. WHEN the chart is installed with default values THEN each service pod SHALL have memory requests and limits configured (default 512Mi limit per service).
2. WHEN a user overrides resource values THEN the PetClinic System SHALL apply the custom resource requests and limits to the corresponding pod.

