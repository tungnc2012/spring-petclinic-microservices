# Implementation Plan

- [x] 1. Create Helm chart scaffold and helpers





  - [x] 1.1 Create `helm/petclinic/Chart.yaml` with chart metadata (name, version, appVersion, description)


    - _Requirements: 2.1_
  - [x] 1.2 Create `helm/petclinic/values.yaml` with all default values for every service (image, port, replicas, resources, ingress, mysql, genai secrets)


    - _Requirements: 2.3, 5.1, 5.2, 5.3, 6.1_


  - [x] 1.3 Create `helm/petclinic/templates/_helpers.tpl` with reusable template functions (fullname, labels, image reference, init containers)





    - _Requirements: 2.1, 3.3_

- [x] 2. Implement Config Server and Discovery Server templates





  - [x] 2.1 Create `helm/petclinic/templates/config-server/deployment.yaml` with readiness/liveness probes, resource limits, and configurable git URI env var


    - _Requirements: 3.1, 6.1, 5.1_

  - [x] 2.2 Create `helm/petclinic/templates/config-server/service.yaml` with ClusterIP on port 8888

    - _Requirements: 2.4_

  - [x] 2.3 Create `helm/petclinic/templates/discovery-server/deployment.yaml` with init container waiting for config-server, probes, and resources

    - _Requirements: 3.2, 3.3, 3.4_

  - [x] 2.4 Create `helm/petclinic/templates/discovery-server/service.yaml` with ClusterIP on port 8761

    - _Requirements: 2.4_



- [x] 3. Implement downstream service templates (Customers, Vets, Visits)



  - [x] 3.1 Create `helm/petclinic/templates/customers-service/deployment.yaml` with init containers for config-server and discovery-server, probes, mysql profile support


    - _Requirements: 3.3, 3.4, 5.3_

  - [x] 3.2 Create `helm/petclinic/templates/customers-service/service.yaml` with ClusterIP on port 8081

    - _Requirements: 2.4_

  - [x] 3.3 Create `helm/petclinic/templates/vets-service/deployment.yaml` with init containers, probes, mysql profile support

    - _Requirements: 3.3, 3.4, 5.3_

  - [x] 3.4 Create `helm/petclinic/templates/vets-service/service.yaml` with ClusterIP on port 8083

    - _Requirements: 2.4_

  - [x] 3.5 Create `helm/petclinic/templates/visits-service/deployment.yaml` with init containers, probes, mysql profile support

    - _Requirements: 3.3, 3.4, 5.3_
  - [x] 3.6 Create `helm/petclinic/templates/visits-service/service.yaml` with ClusterIP on port 8082


    - _Requirements: 2.4_

- [x] 4. Implement API Gateway, GenAI Service, and Admin Server templates





  - [x] 4.1 Create `helm/petclinic/templates/api-gateway/deployment.yaml` with init containers, probes, resources


    - _Requirements: 3.3, 3.4, 6.1_

  - [x] 4.2 Create `helm/petclinic/templates/api-gateway/service.yaml` with configurable service type (ClusterIP/LoadBalancer/NodePort)

    - _Requirements: 2.4, 4.1, 4.3_

  - [x] 4.3 Create `helm/petclinic/templates/api-gateway/ingress.yaml` with conditional creation based on `ingress.enabled`

    - _Requirements: 4.1, 4.2_

  - [x] 4.4 Create `helm/petclinic/templates/genai-service/deployment.yaml` with init containers, probes, secret env var references

    - _Requirements: 3.3, 3.4, 5.2_

  - [x] 4.5 Create `helm/petclinic/templates/genai-service/service.yaml` with ClusterIP on port 8084

    - _Requirements: 2.4_

  - [x] 4.6 Create `helm/petclinic/templates/genai-service/secret.yaml` for OpenAI/Azure API keys

    - _Requirements: 5.2_

  - [x] 4.7 Create `helm/petclinic/templates/admin-server/deployment.yaml` with init containers, probes, resources

    - _Requirements: 3.3, 3.4, 6.1_

  - [x] 4.8 Create `helm/petclinic/templates/admin-server/service.yaml` with ClusterIP on port 9090

    - _Requirements: 2.4_

- [ ] 5. Checkpoint - Make sure all tests are passing
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 5.1 Write property test: Helm template renders without errors
  - **Property 1: Helm template renders without errors for valid values**
  - **Validates: Requirements 2.2**
  - Create `helm/petclinic/tests/template_validity_test.yaml` using helm-unittest

- [ ]* 5.2 Write property test: Values override propagation
  - **Property 2: Values override propagation**
  - **Validates: Requirements 2.3, 6.2**
  - Create `helm/petclinic/tests/values_override_test.yaml` testing that custom values for image, tag, replicas, resources appear in rendered output

- [ ]* 5.3 Write property test: Correct target ports on all Services
  - **Property 3: Correct target ports on all Services**
  - **Validates: Requirements 2.4**
  - Create `helm/petclinic/tests/service_ports_test.yaml` asserting each service has the documented targetPort

- [ ]* 5.4 Write property test: Downstream services have init containers
  - **Property 4: Downstream services have init containers for dependencies**
  - **Validates: Requirements 3.3**
  - Create `helm/petclinic/tests/init_containers_test.yaml` verifying all 6 downstream services have init containers for config-server and discovery-server

- [ ]* 5.5 Write property test: All deployments have liveness and readiness probes
  - **Property 5: All deployments have liveness and readiness probes**
  - **Validates: Requirements 3.4, 3.1**
  - Create `helm/petclinic/tests/probes_test.yaml` checking livenessProbe and readinessProbe on all deployments

- [ ]* 5.6 Write property test: Default resource limits
  - **Property 6: Default resource limits**
  - **Validates: Requirements 6.1**
  - Create `helm/petclinic/tests/default_resources_test.yaml` asserting 512Mi memory limit on all services with default values

- [ ]* 5.7 Write property test: Ingress host propagation
  - **Property 7: Ingress host propagation**
  - **Validates: Requirements 4.2**
  - Create `helm/petclinic/tests/ingress_test.yaml` testing that provided host appears in rendered Ingress rules

- [ ] 6. Final Checkpoint - Make sure all tests are passing
  - Ensure all tests pass, ask the user if questions arise.
