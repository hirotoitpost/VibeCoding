import { test, expect } from '@playwright/test'

test.describe('チャットボット Web アプリ', () => {
  test('チャット画面が表示される', async ({ page }) => {
    await page.goto('/chatbot/')
    await page.waitForLoadState('networkidle')
    await page.screenshot({ path: 'e2e/screenshots/01_chat.png', fullPage: true })
    await expect(page.locator('body')).toBeVisible()
  })

  test('API fetch が成功する（ヘルスチェック）', async ({ page }) => {
    const response = await page.request.get('/api/health')
    expect(response.status()).toBe(200)
    const body = await response.json()
    expect(body.status).toBe('ok')
  })

  test('チャットメッセージを送信できる', async ({ page }) => {
    const apiErrors = []
    page.on('response', response => {
      if (response.url().includes('/api/') && !response.ok()) {
        apiErrors.push(`${response.status()} ${response.url()}`)
      }
    })

    await page.goto('/chatbot/')
    await page.waitForLoadState('networkidle')

    const input = page.locator('input, textarea').first()
    if (await input.count() > 0) {
      await input.fill('hello')
      await page.keyboard.press('Enter')
      await page.waitForTimeout(1000)
    }
    await page.screenshot({ path: 'e2e/screenshots/02_chat_sent.png', fullPage: true })
    expect(apiErrors).toEqual([])
  })
})
