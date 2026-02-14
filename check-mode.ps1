# Check Trading Mode of Polybot Services
# PowerShell script to verify if services are running in PAPER or LIVE mode

$ErrorActionPreference = "SilentlyContinue"

Write-Host ""
Write-Host "🔍 Polybot Trading Mode Check" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan
Write-Host ""

# Check .env file
if (Test-Path .env) {
    $envMode = Select-String -Path .env -Pattern "^HFT_MODE=" | ForEach-Object { $_.Line.Split('=')[1] }
    if ($envMode) {
        $color = if ($envMode -eq "PAPER") { "Green" } else { "Red" }
        Write-Host "📄 .env file:        HFT_MODE=$envMode" -ForegroundColor $color
    } else {
        Write-Host "📄 .env file:        HFT_MODE not set (defaults to PAPER)" -ForegroundColor Yellow
    }
} else {
    Write-Host "📄 .env file:        Not found (using defaults)" -ForegroundColor Yellow
}

Write-Host ""

# Check running services
$services = @{
    "executor-service" = 8080
    "strategy-service" = 8081
    "analytics-service" = 8082
    "ingestor-service" = 8083
}

Write-Host "🔧 Running Services:" -ForegroundColor Cyan
Write-Host ""

foreach ($service in $services.GetEnumerator()) {
    $name = $service.Key
    $port = $service.Value
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:$port/actuator/env/hft.mode" -TimeoutSec 2 -ErrorAction Stop
        $mode = $response.property.value
        
        if ($mode -eq "PAPER") {
            Write-Host "  ✅ $name : $mode (Safe mode)" -ForegroundColor Green
        } elseif ($mode -eq "LIVE") {
            Write-Host "  ⚠️  $name : $mode (⚠️  REAL MONEY!)" -ForegroundColor Red
        } else {
            Write-Host "  ⚠️  $name : $mode (Unknown)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  ❌ $name : Not running or not accessible" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "  - To change mode: Edit HFT_MODE in .env file"
Write-Host "  - PAPER mode = Safe simulation (no real trades)"
Write-Host "  - LIVE mode = REAL trades with REAL money ⚠️"
Write-Host "  - After changing .env: docker-compose down && docker-compose up -d"
Write-Host ""
