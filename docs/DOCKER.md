# Polybot Docker Services

This directory contains Docker Compose configurations for running Polybot services.

## Docker Compose Files

- **docker-compose.yml** - Main file with all application services + infrastructure
- **docker-compose.monitoring.yaml** - Optional monitoring stack (Prometheus, Grafana)
- **docker-compose.analytics.yaml** - Deprecated (infrastructure only, use main file instead)

## Quick Start

1. **Copy the environment file:**
   ```bash
   cp .env.example .env
   ```

2. **Configure environment variables** in `.env` (especially Polymarket credentials if using executor-service)

3. **Start all application services:**
   ```bash
   docker-compose up -d
   ```

4. **Start monitoring (optional):**
   ```bash
   docker-compose -f docker-compose.monitoring.yaml up -d
   ```

5. **View logs:**
   ```bash
   docker-compose logs -f
   ```

6. **Stop all services:**
   ```bash
   docker-compose down
   docker-compose -f docker-compose.monitoring.yaml down
   ```

## Services

The Docker Compose setup includes the following services:

### Infrastructure Services
- **Redpanda (Kafka)**: Port 9092 - Message broker
- **ClickHouse**: Ports 8123 (HTTP), 9000 (Native) - Analytics database

### Application Services
- **executor-service**: Port 8080 - Executes trades on Polymarket
- **strategy-service**: Port 8081 - Strategy management
- **analytics-service**: Port 8082 - Analytics and metrics
- **ingestor-service**: Port 8083 - Data ingestion
- **infrastructure-orchestrator-service**: Port 8084 - Infrastructure orchestration (optional)

## Trading Modes

### PAPER Mode (Default - SAFE)
All services run in **PAPER mode** by default, which means:
- ✅ No real money at risk
- ✅ Orders are simulated, not sent to Polymarket
- ✅ Fills are simulated based on market conditions
- ✅ Perfect for testing and development

### LIVE Mode (⚠️ REAL MONEY)
When running in LIVE mode:
- ⚠️  **REAL trades are executed on Polymarket**
- ⚠️  **REAL money is at risk**
- ⚠️  Requires valid Polymarket credentials
- ⚠️  Only use after thorough testing in PAPER mode

### Checking Current Mode

```powershell
# Check logs for mode
docker-compose logs executor-service | Select-String "mode"

# Check via metrics endpoint
curl http://localhost:8080/actuator/prometheus | Select-String "environment="
```

### Switching Modes

Edit your `.env` file:
```bash
# For PAPER mode (safe - default):
HFT_MODE=PAPER

# For LIVE mode (⚠️ DANGER - real money!):
HFT_MODE=LIVE
```

Then restart services:
```powershell
docker-compose down
docker-compose up -d
```

**WARNING**: Before switching to LIVE mode, ensure:
1. ✅ You have tested thoroughly in PAPER mode
2. ✅ You have set valid Polymarket credentials in `.env`
3. ✅ You understand you will be executing REAL trades with REAL money

## Service Health Checks

All services expose health endpoints at:
```
http://localhost:<PORT>/actuator/health
```

## Monitoring (Optional)

To start monitoring services (Prometheus, Grafana, AlertManager):
```bash
docker-compose -f docker-compose.monitoring.yaml up -d
```

The monitoring stack connects to the application network and can scrape metrics from all services.

Access:
- Grafana: http://localhost:3000 (admin/changeme)
- Prometheus: http://localhost:9090
- AlertManager: http://localhost:9093

All application services expose Prometheus metrics at `/actuator/prometheus`.

## Development

### Building Individual Services

To rebuild a specific service:
```bash
docker-compose build <service-name>
docker-compose up -d <service-name>
```

### Viewing Service Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f executor-service
```

### Scaling Services

```bash
docker-compose up -d --scale strategy-service=2
```

## Troubleshooting

### Service won't start
1. Check logs: `docker-compose logs <service-name>`
2. Verify environment variables in `.env`
3. Ensure required ports are not in use

### Clean restart
```bash
docker-compose down -v  # Remove volumes
docker-compose build --no-cache
docker-compose up -d
```

### Connect to a running container
```bash
docker-compose exec <service-name> sh
```

## Network

All services are connected via the `polybot-network` bridge network, allowing them to communicate using service names as hostnames.

## Volumes

- `polybot_chdata`: Persistent storage for ClickHouse data

To remove volumes:
```bash
docker-compose down -v
```
