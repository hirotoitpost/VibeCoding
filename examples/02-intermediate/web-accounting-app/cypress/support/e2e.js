// Cypress support file for Web Accounting App E2E Tests

// Disable uncaught exception handling for specific cases
Cypress.on('uncaught:exception', (err, runnable) => {
  // Ignore fetch errors during test (API might not be available)
  if (err.message.includes('fetch')) {
    return false
  }
  return true
})

// Custom commands
Cypress.Commands.add('loginAsDefaultUser', () => {
  // TODO: Add login logic if authentication is later implemented
})

Cypress.Commands.add('createTransaction', (transactionData) => {
  cy.request('POST', 'http://localhost:5000/api/transactions', {
    date: transactionData.date,
    category: transactionData.category,
    amount: transactionData.amount,
    description: transactionData.description
  })
})

Cypress.Commands.add('deleteAllTransactions', () => {
  cy.request('GET', 'http://localhost:5000/api/transactions').then((response) => {
    if (response.body.data) {
      response.body.data.forEach((tx) => {
        cy.request('DELETE', `http://localhost:5000/api/transactions/${tx.id}`)
      })
    }
  })
})
