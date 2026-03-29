# Phase 3.2.A.3 Testing & Docker Validation Guide

## Overview

This document describes the testing and validation procedures for Phase 3.2.A Web Accounting App.

### Test Phases

| Phase | Type | Status | Command |
|-------|------|--------|---------|
| **3.2.A.1** | Frontend | ✅ Complete | `npm test` (client/) |
| **3.2.A.2** | Backend | ✅ Complete | `npm test` (server/) |
| **3.2.A.3.1** | Frontend Component | ✅ Ready | `npm test -- --run` (client/) |
| **3.2.A.3.2** | E2E Integration | 🚀 Ready | `npx cypress run` (root) |
| **3.2.A.3.3** | Docker Validation | 🚀 Ready | `./validate-docker-compose.ps1` (Windows) or `.sh` (Unix) |

---

## Testing Strategy

### Frontend Component Testing (React Testing Library + Vitest)

**Location**: `client/src/*.test.jsx`

**Components Tested**:
- `App.jsx` - Main application routing
- `Dashboard.jsx` - Transaction list, filtering, summary
- `TransactionForm.jsx` - Form validation, CRUD operations

**Test Suite**:
- 18 total tests
- 3 test files (App.test.jsx, Dashboard.test.jsx, TransactionForm.test.jsx)
- Coverage: User interactions, validation, API calls

**Run**:
```bash
cd client
npm install  # First time
npm test -- --run   # Run all tests once
npm test              # Run tests in watch mode
```

**Configuration**:
- Framework: Vitest
- Environment: jsdom
- Setup file: `src/setupTests.js`
- Config: `vite.config.js`

---

### Backend API Testing (Jest)

**Location**: `server/test/transactions.test.js`

**Endpoints Tested**:
- POST /api/transactions - Create
- GET /api/transactions - List with filtering
- GET /api/transactions/:id - Retrieve  
- PUT /api/transactions/:id - Update
- DELETE /api/transactions/:id - Delete
- GET /api/transactions/summary/monthly - Monthly summary

**Test Statistics**:
- 20 total tests
- 100% pass rate
- 76.96% code coverage
- Supertest for HTTP testing

**Run**:
```bash
cd server
npm installer  # First time
npm test       # Run with coverage report
```

---

### E2E Integration Testing (Cypress)

**Location**: `cypress/e2e/accounting-app.cy.js`

**Test Scenarios**:
1. Dashboard initial load
2. Navigation bar display
3. Add transaction form navigation
4. Create new transaction
5. Display created transactions
6. Filter by category
7. Validation error handling
8. Form cancellation
9. Summary cards display
10. Error handling
11. Loading state
12. Complete transaction lifecycle

**Prerequisites**:
- Both server and client running
- Server: `npm run dev` in `server/`
- Client: `npm run dev` in `client/`
- Both on default ports (5000 & 5173)

**Run**:
```bash
# Terminal 1: Start backend
cd server
npm run dev   # Runs on http://localhost:5000

# Terminal 2: Start frontend dev server
cd client
npm run dev   # Runs on http://localhost:5173

# Terminal 3: Run Cypress tests
npx cypress run                          # Headless mode
npx cypress run --headed                 # Headed mode (watch)
npx cypress open                         # Interactive mode
npx cypress run --spec "cypress/e2e/**" # Run all E2E tests
```

**Expected Results**:
- All 14 scenarios should pass
- No console errors
- Success messages display correctly after transaction creation

---

### Docker Compose Validation

**Location**: `validate-docker-compose.ps1` (Windows) or `validate-docker-compose.sh` (Unix)

**Tests Performed**:

1. **Build Test**
   - Verifies both images build without errors
   - Server image: node:18-alpine with Express
   - Client image: node:18-alpine with React/Vite

2. **Service Startup**
   - `docker-compose up -d` succeeds
   - Both containers start

3. **Health Check**
   - Server health endpoint responds
   - Containers maintain healthy status

4. **Environment Parity**
   - Server NODE_ENV = production
   - Client VITE_API_URL = http://server:5000
   - Port mappings correct (5000 & 5173)

5. **Networking**
   - Services on shared `accounting-network` bridge
   - Service-to-service communication works
   - Port exposure correct

6. **Volumes**
   - `server_node_modules` mounted correctly
   - `client_node_modules` mounted correctly
   - No permission errors

7. **Dependencies**
   - Client waits for server health
   - Services start in correct order

**Run**:
```powershell
# Windows PowerShell
.\validate-docker-compose.ps1

# or Mac/Linux Bash
bash validate-docker-compose.sh
```

**Expected Output**:
```
=== Docker Compose Validation Script ===

[TEST 1] Testing docker-compose build...
✓ Build successful

[TEST 2] Starting services with docker-compose up -d...
✓ Services started

[TEST 3] Waiting for services to be healthy...
✓ Server is healthy

[TEST 4] Testing API connectivity...
✓ API server is responding

[TEST 5] Verifying environment variables...
✓ Server NODE_ENV = production
✓ Client VITE_API_URL = http://server:5000

[TEST 6] Inspecting running containers...
Running containers:
...

[TEST 7] Cleaning up...
✓ Services stopped and removed

=== All Docker Compose validations passed! ===
```

---

## Complete Test Execution Workflow

### Sequential Execution (Recommended for first-time validation)

```bash
# Step 1: Backend unit tests
cd server
npm test

# Step 2: Frontend component tests  
cd ../client
npm test -- --run

# Step 3: Start dev servers for E2E testing
# Terminal 1
cd server && npm run dev

# Terminal 2 (same time as Terminal 1)
cd client && npm run dev

# Terminal 3: E2E tests (after both servers running)
npx cypress run

# Step 4: Docker validation
cd ..
./validate-docker-compose.ps1  # Windows
# or
bash validate-docker-compose.sh # Mac/Linux
```

### Parallel Execution (Faster, for CI/CD)

```bash
# Run all tests in parallel (requires proper setup)
npm run test:all  # (if added to root package.json)
```

---

## Troubleshooting

### Frontend Tests Failing

**Issue**: "Unable to find an element with the text"
```bash
# Solution: Ensure Vitest globals are enabled
# Already configured in vite.config.js
```

**Issue**: "act(...)" warnings
```bash
# Solution: Tests use waitFor() for async operations
# Ensure all state changes are wrapped
```

### Cypress Tests Timing Out

**Issue**: "Timed out waiting for server response"
```bash
# Solution: Verify servers are running
curl http://localhost:5000/health
curl http://localhost:5173
```

**Issue**: "Network error during test"
```bash
# Solution: Add retries in test or increase wait timeout
cy.wait(2000)  // Increase from 1000
```

### Docker Validation Failing

**Issue**: "docker-compose: command not found"
```bash
# Solution: Install Docker Desktop or use docker compose (new syntax)
docker compose build   # instead of docker-compose build
```

**Issue**: "Port 5000 already in use"
```bash
# Solution: Kill existing process or use different port
docker-compose down  # Clean up any lingering containers
lsof -i :5000       # Find process using port
```

### Environment Variables Not Applied

**Issue**: "Client can't reach server API"
```bash
# Verify in docker-compose.yml:
# client environment should have VITE_API_URL=http://server:5000
# (internal network reference, not localhost)
```

---

## Coverage Reports

### Backend Coverage
```
File          | % Stmts | % Branch | % Funcs | % Lines |
------------- | ------- | -------- | ------- | ------- |
db.js         | 78.95   | 100      | 100     | 78.95   |
routes/tx.js  | 76.47   | 73.33    | 88.89   | 76.47   |
------------- | ------- | -------- | ------- | ------- |
TOTAL         | 76.96   | 87.50    | 85.71   | 76.96   |
```

### Frontend Coverage
- App.jsx: Component routing tests
- Dashboard.jsx: Data fetching, filtering
- TransactionForm.jsx: Validation, CRUD

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Phase 3.2.A.3

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - run: cd server && npm install && npm test

  frontend:
    runs-on: ubuntu-latest
    steps:
      - run: cd client && npm install && npm test -- --run

  e2e:
    runs-on: ubuntu-latest
    steps:
      - run: cd server && npm run dev &
      - run: cd client && npm run dev &
      - run: npx cypress run

  docker:
    runs-on: ubuntu-latest
    steps:
      - run: bash validate-docker-compose.sh
```

---

## Validation Checklist

- [ ] Frontend Component Tests: All passing
- [ ] Backend API Tests: 20/20 passing
- [ ] E2E Tests: All 14 scenarios passing
- [ ] Docker Build: Successful for both images
- [ ] Docker Startup: Successful for both containers
- [ ] Health Check: Both services healthy
- [ ] Environment Variables: Correctly set
- [ ] Port Mapping: 5000 (server) & 5173 (client)
- [ ] Network Connectivity: Verified

---

## Next Steps (Phase 3.2.A.4)

After all tests pass:
- [ ] Performance optimization (if needed)
- [ ] Production deployment (Docker to cloud)
- [ ] Monitoring setup
- [ ] User documentation

---

**Document Version**: 1.0  
**Updated**: 2026-03-29  
**Phase**: 3.2.A.3 (Testing & Validation)
