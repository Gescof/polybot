# Multi-stage build for ingestor-service
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Copy parent POM
COPY pom.xml .

# Copy all module POMs (Maven reactor needs to see all modules)
COPY polybot-core/pom.xml ./polybot-core/
COPY executor-service/pom.xml ./executor-service/
COPY strategy-service/pom.xml ./strategy-service/
COPY analytics-service/pom.xml ./analytics-service/
COPY ingestor-service/pom.xml ./ingestor-service/
COPY infrastructure-orchestrator-service/pom.xml ./infrastructure-orchestrator-service/

# Copy source code for modules we need to build
COPY polybot-core/src ./polybot-core/src
COPY ingestor-service/src ./ingestor-service/src

# Build the application (skip tests for faster builds)
RUN mvn clean package -pl ingestor-service -am -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# Copy the built artifact
COPY --from=build /app/ingestor-service/target/*.jar app.jar

# Expose the service port
EXPOSE 8083

# Set JVM options for containerized environment
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
