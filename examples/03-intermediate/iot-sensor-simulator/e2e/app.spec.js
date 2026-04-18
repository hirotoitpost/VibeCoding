import { test, expect } from '@playwright/test'

test.describe('IoT センサーシミュレーター', () => {
  test('ダッシュボードが表示される', async ({ page }) => {
    await page.goto('/iot/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/01_dashboard.png', fullPage: true })
    await expect(page.locator('h1')).toContainText('IoT センサーシミュレーター')
  })

  test('API fetch が成功する（センサー一覧）', async ({ page }) => {
    const apiErrors = []
    page.on('response', response => {
      if (response.url().includes('/api/') && !response.ok()) {
        apiErrors.push(`${response.status()} ${response.url()}`)
      }
    })

    await page.goto('/iot/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/02_dashboard_loaded.png', fullPage: true })

    expect(apiErrors).toEqual([])
  })

  test('/api/health が 200 を返す', async ({ page }) => {
    const response = await page.request.get('/api/health')
    expect(response.status()).toBe(200)
    const body = await response.json()
    expect(body.status).toBe('ok')
    await page.screenshot({ path: 'e2e/screenshots/03_health.png', fullPage: true })
  })
})
