import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render } from '@testing-library/react'
import TransactionForm from './TransactionForm'

describe('TransactionForm Component', () => {
  const mockApiUrl = 'http://localhost:5000'
  const onSave = vi.fn()
  const onCancel = vi.fn()

  beforeEach(() => {
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  it('renders form component', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const form = document.querySelector('form')
    expect(form).toBeTruthy()
  })

  it('form contains input elements', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const inputs = document.querySelectorAll('input')
    expect(inputs.length).toBeGreaterThan(0)
  })

  it('form contains select elements', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const selects = document.querySelectorAll('select')
    expect(selects.length).toBeGreaterThan(0)
  })

  it('form contains buttons', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const buttons = document.querySelectorAll('button')
    expect(buttons.length).toBeGreaterThan(0)
  })

  it('renders with amount input field', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const amountInputs = document.querySelectorAll('input[type="number"]')
    expect(amountInputs.length).toBeGreaterThan(0)
  })

  it('renders with date input field', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const dateInputs = document.querySelectorAll('input[type="date"]')
    expect(dateInputs.length).toBeGreaterThan(0)
  })

  it('renders form for new transaction', () => {
    render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={null}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    const form = document.querySelector('form')
    expect(form).toBeTruthy()
  })

  it('renders form for existing transaction', () => {
    const { container } = render(
      <TransactionForm
        apiUrl={mockApiUrl}
        txId={5}
        onSave={onSave}
        onCancel={onCancel}
      />
    )

    // Just verify component renders without errors
    expect(container).toBeTruthy()
  })
})
