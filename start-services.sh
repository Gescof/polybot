#!/bin/bash
# Start all Polybot services using Docker Compose

set -e

echo "🚀 Starting Polybot Services..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Copying from .env.example..."
    cp .env.example .env
    echo "✅ Created .env file. Please edit it with your configuration."
    echo ""
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker-compose down

# Build and start all services
echo ""
echo "🔨 Building and starting all services..."
docker-compose up -d --build

# Wait for services to be healthy
echo ""
echo "⏳ Waiting for services to become healthy..."
sleep 10

# Check service health
echo ""
echo "📊 Service Status:"
echo "===================="

services=(
    "executor-service:8080"
    "strategy-service:8081"
    "analytics-service:8082"
    "ingestor-service:8083"
    "infrastructure-orchestrator-service:8084"
)

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -sf "http://localhost:${port}/actuator/health" > /dev/null 2>&1; then
        echo "✅ ${name} (port ${port})"
    else
        echo "⏳ ${name} (port ${port}) - still starting..."
    fi
done

echo ""
echo "🎉 Polybot services are starting up!"
echo ""
echo "📝 Useful commands:"
echo "  - View logs:      docker-compose logs -f"
echo "  - Stop services:  docker-compose down"
echo "  - Restart:        docker-compose restart <service-name>"
echo ""
echo "🌐 Service URLs:"
echo "  - Executor:        http://localhost:8080/actuator/health"
echo "  - Strategy:        http://localhost:8081/actuator/health"
echo "  - Analytics:       http://localhost:8082/actuator/health"
echo "  - Ingestor:        http://localhost:8083/actuator/health"
echo "  - Infrastructure:  http://localhost:8084/actuator/health"
echo "  - Redpanda:        localhost:9092"
echo "  - ClickHouse:      http://localhost:8123"
echo ""
