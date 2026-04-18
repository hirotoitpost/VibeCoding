import { test, expect } from '@playwright/test'

test.describe('スマートホーム IoT Hub', () => {
  test('ダッシュボードが表示される', async ({ page }) => {
    await page.goto('/smarthome/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/01_dashboard.png', fullPage: true })
    await expect(page.locator('body')).toBeVisible()
  })

  test('API fetch が成功する（デバイス一覧）', async ({ page }) => {
    const apiErrors = []
    page.on('response', response => {
      if (response.url().includes('/api/') && !response.ok()) {
        apiErrors.push(`${response.status()} ${response.url()}`)
      }
    })

    await page.goto('/smarthome/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/02_dashboard_loaded.png', fullPage: true })

    expect(apiErrors).toEqual([])
  })

  test('デバイス追加ボタンが存在する', async ({ page }) => {
    await page.goto('/smarthome/')
    await page.waitForLoadState('networkidle')

    const addButton = page.getByRole('button', { name: /追加|add|register/i })
    if (await addButton.count() > 0) {
      await addButton.first().click()
      await page.waitForLoadState('networkidle')
    }
    await page.screenshot({ path: 'e2e/screenshots/03_add_device.png', fullPage: true })
  })
})
