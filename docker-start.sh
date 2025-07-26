docker run --network petclinic-network --name config-server -p 8888:8888 config-server
docker run --network petclinic-network --name discovery-server -p 8761:8761 discovery-server
docker run --network petclinic-network --name admin-server -p 9099:9099 admin-server
docker run --network petclinic-network --name api-gateway -p 8081:8081 api-gateway
docker run --network petclinic-network --name customer-service -p 8082:8082 customer-service
docker run --network petclinic-network --name vets-service -p 8083:8083 vets-service
docker run --network petclinic-network --name visits-service -p 8084:8084 visits-service


tungnc2012/spring-petclinic-config-server:1.0.0
tungnc2012/spring-petclinic-discovery-server:1.0.0
tungnc2012/spring-petclinic-admin-server:1.0.0
tungnc2012/spring-petclinic-api-gateway:1.0.0
tungnc2012/spring-petclinic-customers-service:1.0.0
tungnc2012/spring-petclinic-vets-service:1.0.0
tungnc2012/spring-petclinic-visits-service:1.0.0
tungnc2012/spring-petclinic-genai-service:1.0.0