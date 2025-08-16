# Multi-stage build with better error handling
FROM maven:3.8.4-openjdk-11-slim AS build

# Set working directory
WORKDIR /app

# Copy pom.xml first for better caching
COPY pom.xml .

# Debug: Show pom.xml content
RUN cat pom.xml

# Download dependencies (this layer will be cached if pom.xml doesn't change)
RUN mvn dependency:go-offline -B

# Copy source code
COPY src ./src

# Debug: Show project structure
RUN find /app -name "*.java" -type f | head -10

# Build the application with verbose output
RUN mvn clean package -DskipTests -X

# Debug: Show what was built
RUN ls -la /app/target/

# Stage 2: Runtime
FROM tomcat:9.0-jdk11-openjdk-slim

# Remove default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file from build stage
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

# Set environment variables
ENV CATALINA_HOME /usr/local/tomcat
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Xmx512m -Xms256m"

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]