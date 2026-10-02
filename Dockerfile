# Stage 1: Build the Spring Boot application
FROM maven:3.9-eclipse-temurin-21 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Create the runtime image
FROM eclipse-temurin:21-jre

WORKDIR /app

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        openssl \
        libssl3t64 \
        openssl-provider-legacy \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN groupadd --system spring \
    && useradd --system --gid spring spring

# Copy the application from the builder stage
COPY --from=builder /app/target/inventory-service-0.0.1-SNAPSHOT.jar app.jar

RUN chown spring:spring app.jar

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
