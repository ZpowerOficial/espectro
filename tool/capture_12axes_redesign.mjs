import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  // 1. Desktop Initial Quiz View (1280x880)
  const page = await browser.newPage({ viewport: { width: 1280, height: 880 } });

  console.log('1. Loading Quiz directly on desktop...');
  await page.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await page.waitForTimeout(4000);

  // Enable semantics
  const sem = page.locator('flt-semantics-placeholder');
  if (await sem.count() > 0) {
    await sem.focus();
    await sem.press('Enter');
    await page.waitForTimeout(1000);
  }

  console.log('2. Capturing unselected 12axes redesign desktop...');
  await page.screenshot({ path: `${artifactDir}/quiz_12axes_desktop_initial.png` });

  console.log('3. Selecting "Concordo totalmente"...');
  const concordo = page.locator('flt-semantics[aria-label*="Concordo totalmente"]').first();
  if (await concordo.count() > 0) {
    await concordo.click();
  } else {
    await page.mouse.click(640, 480);
  }
  await page.waitForTimeout(1000);

  console.log('4. Capturing selected 12axes redesign desktop...');
  await page.screenshot({ path: `${artifactDir}/quiz_12axes_desktop_selected.png` });
  await page.close();

  // 2. Mobile Quiz View (390x844)
  const mobilePage = await browser.newPage({ viewport: { width: 390, height: 844 } });
  console.log('5. Loading Quiz on mobile...');
  await mobilePage.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=standard');
  await mobilePage.waitForTimeout(4000);

  const semMobile = mobilePage.locator('flt-semantics-placeholder');
  if (await semMobile.count() > 0) {
    await semMobile.focus();
    await semMobile.press('Enter');
    await mobilePage.waitForTimeout(1000);
  }

  console.log('6. Capturing mobile 12axes redesign view...');
  await mobilePage.screenshot({ path: `${artifactDir}/quiz_12axes_mobile_view.png` });
  await mobilePage.close();

} catch (err) {
  console.error('Error during capture:', err);
} finally {
  await browser.close();
}
