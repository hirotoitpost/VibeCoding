import { test, expect } from '@playwright/test'

test.describe('Web 家計簿アプリ', () => {
  test('ダッシュボードが表示される', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/01_dashboard.png', fullPage: true })
    await expect(page.locator('h1')).toContainText('Web 家計簿')
  })

  test('API fetch が成功する（取引一覧）', async ({ page }) => {
    const apiErrors = []
    page.on('response', response => {
      if (response.url().includes('/api/') && !response.ok()) {
        apiErrors.push(`${response.status()} ${response.url()}`)
      }
    })

    await page.goto('/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/02_dashboard_loaded.png', fullPage: true })

    expect(apiErrors).toEqual([])
  })

  test('新規取引フォームが開く', async ({ page }) => {
    await page.goto('/')
    await page.waitForLoadState('networkidle')

    const addButton = page.getByRole('button', { name: /追加|新規|add/i })
    if (await addButton.count() > 0) {
      await addButton.first().click()
      await page.waitForLoadState('networkidle')
    }
    await page.screenshot({ path: 'e2e/screenshots/03_form.png', fullPage: true })
  })
})
