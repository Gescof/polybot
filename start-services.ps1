# Start all Polybot services using Docker Compose
# PowerShell script for Windows

$ErrorActionPreference = "Stop"

Write-Host "🚀 Starting Polybot Services..." -ForegroundColor Cyan
Write-Host ""

# Check if .env exists
if (-not (Test-Path .env)) {
    Write-Host "⚠️  .env file not found. Copying from .env.example..." -ForegroundColor Yellow
    Copy-Item .env.example .env
    Write-Host "✅ Created .env file. Please edit it with your configuration." -ForegroundColor Green
    Write-Host ""
}

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "❌ Docker is not running. Please start Docker and try again." -ForegroundColor Red
    exit 1
}

# Stop any existing containers
Write-Host "🛑 Stopping any existing containers..." -ForegroundColor Yellow
docker-compose down

# Build and start all services
Write-Host ""
Write-Host "🔨 Building and starting all services..." -ForegroundColor Cyan
docker-compose up -d --build

# Wait for services to be healthy
Write-Host ""
Write-Host "⏳ Waiting for services to become healthy..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Check service health
Write-Host ""
Write-Host "📊 Service Status:" -ForegroundColor Cyan
Write-Host "===================="

$services = @{
    "executor-service" = 8080
    "strategy-service" = 8081
    "analytics-service" = 8082
    "ingestor-service" = 8083
    "infrastructure-orchestrator-service" = 8084
}

foreach ($service in $services.GetEnumerator()) {
    $name = $service.Key
    $port = $service.Value
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:$port/actuator/health" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $name (port $port)" -ForegroundColor Green
        }
    } catch {
        Write-Host "⏳ $name (port $port) - still starting..." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🎉 Polybot services are starting up!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Useful commands:" -ForegroundColor Cyan
Write-Host "  - View logs:      docker-compose logs -f"
Write-Host "  - Stop services:  docker-compose down"
Write-Host "  - Restart:        docker-compose restart <service-name>"
Write-Host ""
Write-Host "🌐 Service URLs:" -ForegroundColor Cyan
Write-Host "  - Executor:        http://localhost:8080/actuator/health"
Write-Host "  - Strategy:        http://localhost:8081/actuator/health"
Write-Host "  - Analytics:       http://localhost:8082/actuator/health"
Write-Host "  - Ingestor:        http://localhost:8083/actuator/health"
Write-Host "  - Infrastructure:  http://localhost:8084/actuator/health"
Write-Host "  - Redpanda:        localhost:9092"
Write-Host "  - ClickHouse:      http://localhost:8123"
Write-Host ""
