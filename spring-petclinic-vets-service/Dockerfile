# ----- Runtime stage -----
FROM eclipse-temurin:17-jre
EXPOSE 8083
COPY target/*.jar /app/app.jar
ENV SPRING_PROFILES_ACTIVE=docker
ENTRYPOINT ["java","-jar","/app/app.jar"]