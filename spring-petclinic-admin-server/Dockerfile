# # ----- Build stage -----
# FROM maven:3.9.6-eclipse-temurin-17 AS build
# WORKDIR /app
# COPY pom.xml .
# COPY src ./src
# RUN mvn -B package -DskipTests

# ----- Runtime stage -----
FROM eclipse-temurin:17-jre
EXPOSE 9099
COPY target/*.jar /app/app.jar
ENV SPRING_PROFILES_ACTIVE=docker
ENTRYPOINT ["java","-jar","/app/app.jar"]