# syntax=docker/dockerfile:1
# ----- Build stage -----
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B package -DskipTests

# ----- Runtime stage -----
FROM eclipse-temurin:17-jre
EXPOSE 8084
COPY --from=build /app/target/*.jar /app/app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]