# ---------- Stage 1: Build ----------
FROM maven:3.9.5-eclipse-temurin-17 AS build

WORKDIR /app

COPY pom.xml .
COPY .mvn .mvn
COPY mvnw .

RUN apt-get update && apt-get install -y dos2unix
RUN dos2unix mvnw
RUN chmod +x mvnw

# Copying the source code
COPY src ./src

# Building the application
RUN mvn clean install -DskipTests 


# ---------- Stage 2: Runtime ----------
FROM eclipse-temurin:17-jre-jammy

# Creating a non-root user
RUN useradd -m springuser

WORKDIR /app

# Copying only the built jar from builder stage
COPY --from=build /app/target/*.jar app.jar

# Changing ownership to non-root user
RUN chown -R springuser:springuser /app

# Setting user
USER springuser

# # Adding Health Checker ???
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

#   Port application is listening on
EXPOSE 8080

# Specifying default executable
ENTRYPOINT ["java", "-jar", "app.jar"]