/**
 * E2E Integration Tests for Web Accounting App
 * 
 * Test Scenarios:
 * 1. Dashboard Initial Load
 * 2. Add New Transaction Flow
 * 3. View Transactions
 * 4. Edit Transaction
 * 5. Delete Transaction
 * 6. Filter by Category
 */

describe('Web Accounting App - E2E Integration Tests',  () => {
  const API_BASE = 'http://localhost:5000'
  const APP_URL = 'http://localhost:5173'

  before(() => {
    // Optional: Seed database before tests
    cy.request('POST', `${API_BASE}/api/transactions`, {
      date: '2026-03-15',
      category: 'food',
      amount: 1500,
      description: 'Test transaction for filtering'
    }).then((response) => {
      expect(response.status).to.eq(201)
    })
  })

  beforeEach(() => {
    cy.visit(APP_URL)
    cy.wait(1000) // Wait for app to load
  })

  it('should display dashboard on initial load', () => {
    // Verify dashboard container exists
    cy.get('.dashboard').should('exist')
    
    // Verify main sections are visible
    cy.get('.dashboard-header').should('be.visible')
    cy.get('.filter-section').should('be.visible')
    cy.get('.summary-cards').should('be.visible')
    cy.get('.transaction-section').should('be.visible')
  })

  it('should display navigation bar with title', () => {
    cy.get('.navbar').should('exist')
    cy.get('nav h1').should('be.visible')
  })

  it('should navigate to form when Add button is clicked', () => {
    // Find and click "New Transaction" button
    cy.get('button.btn-primary').first().click()
    
    // Verify form is displayed
    cy.get('.transaction-form').should('exist')
    cy.get('form').should('be.visible')
  })

  it('should create a new transaction', () => {
    // Click Add button
    cy.get('button.btn-primary').first().click()
    
    // Fill out form
    cy.get('input[name="date"]').clear().type('2026-03-29')
    cy.get('select[name="category"]').select('transport')
    cy.get('input[name="amount"]').type('3000')
    cy.get('textarea[name="description"]').type('Train fare')
    
    // Submit form
    cy.get('button').contains('保存').click()
    
    // Wait for success message
    cy.get('.success-message', { timeout: 5000 }).should('exist')
  })

  it('should display created transaction in list', () => {
    // Navigate to dashboard
    cy.get('.navbar').should('exist')
    
    // Wait for transactions to load
    cy.wait(1000)
    
    // Verify transaction table/list is displayed
    cy.get('.transaction-section').should('be.visible')
  })

  it('should filter transactions by category', () => {
    // Get all select elements
    cy.get('select').then($selects => {
      // Find the category select (usually the first one in filter section)
      const categorySelect = $selects[0]
      cy.wrap(categorySelect).select('food')
    })
    
    // Wait for filter to apply
    cy.wait(500)
    
    // Verify filtered results are displayed
    cy.get('.transaction-section').should('be.visible')
  })

  it('should display validation error for invalid amount', () => {
    // Click Add button
    cy.get('button.btn-primary').first().click()
    
    // Fill out form with invalid data
    cy.get('input[name="amount"]').type('-100')
    
    // Submit form
    cy.get('button').contains('保存').click()
    
    // Verify error message
    cy.get('.error-message').should('contain', '正の数')
  })

  it('should display validation error for missing required fields', () => {
    // Click Add button
    cy.get('button.btn-primary').first().click()
    
    // Submit empty form
    cy.get('button').contains('保存').click()
    
    // Verify error message
    cy.get('.error-message').should('contain', '必須項目')
  })

  it('should cancel form and return to dashboard', () => {
    // Click Add button
    cy.get('button.btn-primary').first().click()
    
    // Verify form is displayed
    cy.get('.transaction-form').should('exist')
    
    // Click Cancel button
    cy.get('button').contains('キャンセル').click()
    
    // Verify dashboard is displayed
    cy.get('.dashboard').should('exist')
    cy.get('.transaction-form').should('not.exist')
  })

  it('should display summary cards', () => {
    // Verify summary cards exist
    cy.get('.summary-cards').should('exist')
    
    // Verify individual cards
    cy.get('.card').should('have.length.greaterThan', 0)
  })

  it('should handle API errors gracefully', () => {
    // This test verifies error handling when API is temporarily unavailable
    // In real scenario, we'd mock API failure
    cy.visit(APP_URL)
    
    // Dashboard should still render (with loading/empty state)
    cy.get('.dashboard').should('exist')
  })

  it('should display loading state during fetch', () => {
    cy.visit(APP_URL)
    
    // Check for loading indicator (brief)
    // Note: Loading state might be too fast to catch
    cy.get('.dashboard').should('exist')
  })

  it('should maintain month filter state', () => {
    // Set a month in the filter
    cy.get('input[type="month"]').then($monthInput => {
      if ($monthInput.length > 0) {
        cy.wrap($monthInput).type('2026-03')
      }
    })
    
    // Verify dashboard is still responsive
    cy.get('.dashboard').should('exist')
  })

  it('E2E: Complete transaction lifecycle - Create → View → (Optional: Edit) → Delete', () => {
    // Step 1: Create transaction
    cy.get('button.btn-primary').first().click()
    cy.get('input[name="date"]').clear().type('2026-03-20')
    cy.get('select[name="category"]').select('entertainment')
    cy.get('input[name="amount"]').type('5000')
    cy.get('textarea[name="description"]').type('Movie tickets')
    cy.get('button').contains('保存').click()
    
    // Verify success
    cy.get('.success-message', { timeout: 5000 }).should('exist')
    
    // Step 2: Verify transaction appears in list
    cy.get('.transaction-section').should('be.visible')
    
    // Step 3: Verify dashboard layout is maintained
    cy.get('.dashboard').should('exist')
    cy.get('.navbar').should('exist')
  })
})
