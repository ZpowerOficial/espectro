import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  const page = await browser.newPage({ viewport: { width: 1280, height: 880 } });

  await page.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await page.waitForTimeout(4000);

  // Enable semantics
  const sem = page.locator('flt-semantics-placeholder');
  if (await sem.count() > 0) {
    await sem.focus();
    await sem.press('Enter');
    await page.waitForTimeout(1000);
  }

  // Toggle switch to turn off autoAdvance so we stay on question 1 with selection visible
  const sw = page.locator('flt-semantics[role="switch"]').first();
  if (await sw.count() > 0) {
    await sw.click();
    await page.waitForTimeout(400);
  }

  // Select "Concordo totalmente"
  const concordo = page.locator('flt-semantics[aria-label*="Concordo totalmente"]').first();
  if (await concordo.count() > 0) {
    await concordo.click();
  }
  await page.waitForTimeout(800);

  console.log('Capturing selected state with radio button filled...');
  await page.screenshot({ path: `${artifactDir}/quiz_12axes_desktop_selected.png` });

  // Toggle dark mode using the moon icon button
  const moon = page.locator('flt-semantics[aria-label*="Alternar tema"]').first();
  if (await moon.count() > 0) {
    await moon.click();
    await page.waitForTimeout(800);
    console.log('Capturing dark mode 12axes view...');
    await page.screenshot({ path: `${artifactDir}/quiz_12axes_dark_mode.png` });
  }

  await page.close();
} catch (err) {
  console.error('Error during capture:', err);
} finally {
  await browser.close();
}
