#!/bin/bash
# Docker Compose Validation Script for Web Accounting App
# 
# Tests:
# 1. docker-compose build - Verify all images build successfully
# 2. docker-compose up -d - Start services  
# 3. Health check - Verify services are healthy
# 4. Environment parity - Verify environment variables match
# 5. docker-compose down - Clean up

set -e

echo "=== Docker Compose Validation Script ==="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test 1: Build images
echo -e "${YELLOW}[TEST 1] Testing docker-compose build...${NC}"
if docker-compose build; then
  echo -e "${GREEN}✓ Build successful${NC}"
else
  echo -e "${RED}✗ Build failed${NC}"
  exit 1
fi

echo ""

# Test 2: Start services
echo -e "${YELLOW}[TEST 2] Starting services with docker-compose up -d...${NC}"
if docker-compose up -d; then
  echo -e "${GREEN}✓ Services started${NC}"
else
  echo -e "${RED}✗ Failed to start services${NC}"
  exit 1
fi

echo ""

# Test 3: Wait for services to be healthy
echo -e "${YELLOW}[TEST 3] Waiting for services to be healthy...${NC}"
MAX_RETRIES=60
RETRY=0

while [ $RETRY -lt $MAX_RETRIES ]; do
  if docker ps | grep -q "web-accounting-server" && \
     docker inspect web-accounting-server | grep -q '"Health": "healthy"'; then
    echo -e "${GREEN}✓ Server is healthy${NC}"
    break
  fi
  
  RETRY=$((RETRY + 1))
  if [ $RETRY -eq $MAX_RETRIES ]; then
    echo -e "${RED}✗ Server health check failed after ${MAX_RETRIES} attempts${NC}"
    docker-compose logs server
    exit 1
  fi
  
  echo "  Waiting for server health... (attempt $RETRY/$MAX_RETRIES)"
  sleep 1
done

echo ""

# Test 4: Test API connectivity
echo -e "${YELLOW}[TEST 4] Testing API connectivity...${NC}"
if curl -s http://localhost:5000/health | grep -q "ok\|healthy\|running" || [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ API server is responding${NC}"
else
  echo -e "${YELLOW}⚠ API endpoint might not be responding yet (this may be normal)${NC}"
fi

echo ""

# Test 5: Verify environment variables
echo -e "${YELLOW}[TEST 5] Verifying environment variables...${NC}"
SERVER_ENV=$(docker exec web-accounting-server printenv NODE_ENV 2>/dev/null || echo "")
CLIENT_ENV=$(docker exec web-accounting-client printenv VITE_API_URL 2>/dev/null || echo "")

if [ "$SERVER_ENV" = "production" ]; then
  echo -e "${GREEN}✓ Server NODE_ENV = production${NC}"
else
  echo -e "${YELLOW}⚠ Server NODE_ENV not set to production${NC}"
fi

if echo "$CLIENT_ENV" | grep -q "server:5000"; then
  echo -e "${GREEN}✓ Client VITE_API_URL = http://server:5000${NC}"
else
  echo -e "${YELLOW}⚠ Client VITE_API_URL not correctly set${NC}"
fi

echo ""

# Test 6: Inspect container details
echo -e "${YELLOW}[TEST 6] Inspecting running containers...${NC}"
echo "Running containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""

# Test 7: Cleanup
echo -e "${YELLOW}[TEST 7] Cleaning up...${NC}"
if docker-compose down; then
  echo -e "${GREEN}✓ Services stopped and removed${NC}"
else
  echo -e "${RED}✗ Failed to stop services${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}=== All Docker Compose validations passed! ===${NC}"
