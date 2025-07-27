# Spring PetClinic Microservices - User Flow Diagram

## Application Overview
The Spring PetClinic is a microservices-based pet clinic management system with the following architecture:
- **API Gateway** (Port 8081) - Single entry point for all user interactions
- **Customers Service** (Port 8082) - Manages owners and pets
- **Vets Service** (Port 8083) - Manages veterinarians and specialties
- **Visits Service** (Port 8084) - Manages pet visits
- **Admin Server** (Port 9099) - Application monitoring
- **Config Server** (Port 8888) - Configuration management
- **Discovery Server** (Port 8761) - Service discovery
- **GenAI Service** (Port 8085) - AI-powered chat support (optional)

## User Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           USER INTERFACE (API Gateway)                          │
│                              http://<node-ip>:30081                            │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              MAIN NAVIGATION                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐           │
│  │    Home     │  │ Find Owners │  │Register Owner│  │Veterinarians│           │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘           │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              USER JOURNEYS                                      │
└─────────────────────────────────────────────────────────────────────────────────┘

## 1. OWNER MANAGEMENT FLOW

### 1.1 Find Owners
```
User → API Gateway (/owners) → Customers Service (/api/customer/owners)
     ↓
Display: Owner list with search filter
     ↓
User clicks on owner name → API Gateway (/owners/details/{ownerId}) → Customers Service + Visits Service
     ↓
Display: Owner details with pets and visits
```

### 1.2 Register New Owner
```
User → API Gateway (/owners/new) → Display: Owner registration form
     ↓
User fills form → API Gateway (/api/customer/owners) → Customers Service (POST)
     ↓
Redirect to: Owner list
```

### 1.3 Edit Owner
```
User → Owner details → "Edit Owner" button → API Gateway (/owners/{ownerId}/edit)
     ↓
Display: Pre-filled owner form
     ↓
User updates → API Gateway (/api/customer/owners/{ownerId}) → Customers Service (PUT)
     ↓
Redirect to: Owner details
```

## 2. PET MANAGEMENT FLOW

### 2.1 Add New Pet
```
User → Owner details → "Add New Pet" button → API Gateway (/owners/{ownerId}/new-pet)
     ↓
Display: Pet registration form (with pet types from Customers Service)
     ↓
User fills form → API Gateway (/api/customer/owners/{ownerId}/pets) → Customers Service (POST)
     ↓
Redirect to: Owner details
```

### 2.2 Edit Pet
```
User → Owner details → Pet name link → API Gateway (/owners/{ownerId}/pets/{petId})
     ↓
Display: Pre-filled pet form
     ↓
User updates → API Gateway (/api/customer/owners/{ownerId}/pets/{petId}) → Customers Service (PUT)
     ↓
Redirect to: Owner details
```

## 3. VISIT MANAGEMENT FLOW

### 3.1 Add New Visit
```
User → Owner details → "Add Visit" button → API Gateway (/owners/{ownerId}/pets/{petId}/visits)
     ↓
Display: Visit form
     ↓
User fills form → API Gateway (/api/visit/owners/{ownerId}/pets/{petId}/visits) → Visits Service (POST)
     ↓
Redirect to: Owner details
```

### 3.2 View Visits
```
User → Owner details → View existing visits (loaded via API Gateway)
     ↓
API Gateway (/api/gateway/owners/{ownerId}) → Customers Service + Visits Service
     ↓
Display: Combined owner and visit data
```

## 4. VETERINARIAN MANAGEMENT FLOW

### 4.1 View Veterinarians
```
User → API Gateway (/vets) → Vets Service (/api/vet/vets)
     ↓
Display: Veterinarian list with specialties
```

## 5. AI CHAT SUPPORT FLOW (Optional)

### 5.1 Chat with AI
```
User → Chat widget (bottom-right corner) → API Gateway (/api/genai/chatclient)
     ↓
GenAI Service (if enabled) → AI processing
     ↓
Display: AI response in chat widget
```

## 6. MICROSERVICES INTERACTION FLOW

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              MICROSERVICES ARCHITECTURE                         │
└─────────────────────────────────────────────────────────────────────────────────┘

API Gateway (8081)
    │
    ├── Customers Service (8082)
    │   ├── /api/customer/owners (GET, POST, PUT)
    │   ├── /api/customer/owners/{id} (GET)
    │   ├── /api/customer/owners/{id}/pets (GET, POST, PUT)
    │   └── /api/customer/petTypes (GET)
    │
    ├── Vets Service (8083)
    │   └── /api/vet/vets (GET)
    │
    ├── Visits Service (8084)
    │   ├── /api/visit/owners/{ownerId}/pets/{petId}/visits (GET, POST)
    │   └── /api/visit/pets/visits?petId={petIds} (GET)
    │
    ├── GenAI Service (8085) - Optional
    │   └── /api/genai/chatclient (POST)
    │
    └── Admin Server (9099) - Monitoring
        └── Application health and metrics

Supporting Services:
├── Config Server (8888) - Configuration management
├── Discovery Server (8761) - Service discovery
└── Circuit Breaker - Resilience4j for fault tolerance
```

## 7. DATA FLOW EXAMPLES

### 7.1 Owner Details with Pets and Visits
```
1. User requests: /owners/details/1
2. API Gateway calls:
   - Customers Service: GET /owners/1
   - Visits Service: GET /pets/visits?petId=1,2,3
3. API Gateway aggregates data
4. Returns: Owner details with pets and their visits
```

### 7.2 Add Visit to Pet
```
1. User submits visit form
2. API Gateway: POST /api/visit/owners/1/pets/2/visits
3. Visits Service: Creates visit record
4. Redirect to owner details page
```

## 8. ERROR HANDLING

- **Circuit Breaker**: Resilience4j handles service failures
- **Fallback**: Graceful degradation when services are unavailable
- **Health Checks**: Actuator endpoints for monitoring
- **Chat Fallback**: "Chat is currently unavailable" when GenAI service is down

## 9. SECURITY & MONITORING

- **Admin Server**: Application monitoring and health checks
- **Service Discovery**: Eureka-based service registration
- **Configuration**: Centralized config management
- **Tracing**: Distributed tracing support (can be enhanced with Jaeger)

## 10. DEPLOYMENT ACCESS

- **External Access**: http://<cluster-node-ip>:30081
- **Internal Services**: ClusterIP (except API Gateway which is NodePort)
- **Admin Interface**: Available via Admin Server (internal access)
- **Service Discovery**: Eureka dashboard (internal access)

This architecture provides a scalable, resilient microservices-based pet clinic management system with clear separation of concerns and comprehensive user interaction flows. 