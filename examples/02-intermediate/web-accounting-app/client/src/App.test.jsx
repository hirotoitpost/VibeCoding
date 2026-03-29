import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { render } from '@testing-library/react'
import App from './App'

// Mock axios for API calls
vi.mock('axios', () => ({
  default: {
    get: vi.fn(() => Promise.resolve({ data: [] })),
    post: vi.fn(() => Promise.resolve({ data: { id: 1 } })),
    put: vi.fn(() => Promise.resolve({ data: { id: 1 } })),
    delete: vi.fn(() => Promise.resolve()),
  }
}))

describe('App Component', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  afterEach(() => {
    vi.clearAllMocks()
  })

  it('renders app container', () => {
    render(<App />)
    const appContainer = document.querySelector('.app')
    expect(appContainer).toBeTruthy()
  })

  it('displays navbar', () => {
    render(<App />)
    const navbar = document.querySelector('.navbar')
    expect(navbar).toBeTruthy()
  })

  it('renders main container', () => {
    render(<App />)
    const mainContainer = document.querySelector('.container')
    expect(mainContainer).toBeTruthy()
  })

  it('displays dashboard component on initial load', () => {
    render(<App />)
    // Dashboard should be rendered initially
    const dashboard = document.querySelector('main')
    expect(dashboard).toBeTruthy()
  })

  it('renders navigation structure', () => {
    render(<App />)
    const nav = document.querySelector('nav')
    expect(nav).toBeTruthy()
  })
})

