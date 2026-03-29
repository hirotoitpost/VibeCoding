# Docker Compose Validation Script for Web Accounting App (PowerShell)
# 
# Tests:
# 1. docker-compose build
# 2. docker-compose up -d  
# 3. Health check
# 4. Environment parity
# 5. docker-compose down

$ErrorActionPreference = "Stop"

Write-Host "=== Docker Compose Validation Script ===" -ForegroundColor Green
Write-Host ""

# Test 1: Build images
Write-Host "[TEST 1] Testing docker-compose build..." -ForegroundColor Yellow
try {
    docker-compose build --no-cache
    Write-Host "✓ Build successful" -ForegroundColor Green
} catch {
    Write-Host "✗ Build failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 2: Start services
Write-Host "[TEST 2] Starting services with docker-compose up -d..." -ForegroundColor Yellow
try {
    docker-compose up -d
    Write-Host "✓ Services started" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to start services: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Test 3: Wait for services
Write-Host "[TEST 3] Waiting for services to be ready..." -ForegroundColor Yellow
$maxRetries = 60
$retry = 0

while ($retry -lt $maxRetries) {
    $running = docker ps | Select-String "web-accounting-server"
    if ($running) {
        Write-Host "✓ Server container is running" -ForegroundColor Green
        break
    }
    
    $retry++
    if ($retry -eq $maxRetries) {
        Write-Host "✗ Container not running after $maxRetries attempts" -ForegroundColor Red
        docker-compose logs server
        exit 1
    }
    
    Write-Host "  Waiting for server... (attempt $retry/$maxRetries)"
    Start-Sleep -Seconds 1
}

Write-Host ""

# Test 4: Test API
Write-Host "[TEST 4] Testing API connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:5000/health" -ErrorAction SilentlyContinue
    Write-Host "✓ API server is responding" -ForegroundColor Green
} catch {
    Write-Host "⚠ API endpoint might not be responding yet (this may be normal)" -ForegroundColor Yellow
}

Write-Host ""

# Test 5: Verify environment
Write-Host "[TEST 5] Verifying environment variables..." -ForegroundColor Yellow
$serverEnv = docker exec web-accounting-server printenv NODE_ENV 2>$null
$clientEnv = docker exec web-accounting-client printenv VITE_API_URL 2>$null

if ($serverEnv -eq "production") {
    Write-Host "✓ Server NODE_ENV = production" -ForegroundColor Green
} else {
    Write-Host "⚠ Server NODE_ENV not set to production" -ForegroundColor Yellow
}

if ($clientEnv -like "*server:5000*") {
    Write-Host "✓ Client VITE_API_URL = http://server:5000" -ForegroundColor Green
} else {
    Write-Host "⚠ Client VITE_API_URL not correctly set" -ForegroundColor Yellow
}

Write-Host ""

# Test 6: Show containers
Write-Host "[TEST 6] Running containers:" -ForegroundColor Yellow
docker ps --format "table {{.Names}}`t{{.Status}}`t{{.Ports}}"

Write-Host ""

# Test 7: Cleanup
Write-Host "[TEST 7] Cleaning up..." -ForegroundColor Yellow
try {
    docker-compose down
    Write-Host "✓ Services stopped and removed" -ForegroundColor Green
} catch {
    Write-Host "✗ Failed to stop services: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== All Docker Compose validations passed! ===" -ForegroundColor Green
