import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  // 1. Desktop View
  const page = await browser.newPage({ viewport: { width: 1280, height: 880 } });
  await page.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await page.waitForTimeout(3500);

  console.log('Capturing desktop initial state...');
  await page.screenshot({ path: `${artifactDir}/quiz_espectro_desktop_initial.png` });

  // Click switch at (573, 773) to turn OFF auto-advance
  console.log('Toggling auto-advance switch OFF...');
  await page.mouse.click(573, 773);
  await page.waitForTimeout(400);

  // Click Option 1 (Concordo totalmente) at (640, 342)
  console.log('Selecting Option 1 (Concordo totalmente)...');
  await page.mouse.click(640, 342);
  await page.waitForTimeout(600);

  console.log('Capturing desktop selected state...');
  await page.screenshot({ path: `${artifactDir}/quiz_espectro_desktop_selected.png` });

  // Click theme button at (924, 30) to switch to dark mode
  console.log('Toggling dark mode...');
  await page.mouse.click(924, 30);
  await page.waitForTimeout(600);

  console.log('Capturing dark mode view...');
  await page.screenshot({ path: `${artifactDir}/quiz_espectro_dark_mode.png` });

  await page.close();

  // 2. Mobile View
  const mobilePage = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobilePage.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await mobilePage.waitForTimeout(3500);

  console.log('Capturing mobile view...');
  await mobilePage.screenshot({ path: `${artifactDir}/quiz_espectro_mobile_view.png` });

  await mobilePage.close();

  // 3. Home Screen background verification
  const homePage = await browser.newPage({ viewport: { width: 1280, height: 880 } });
  await homePage.goto('http://127.0.0.1:8080/#/');
  await homePage.waitForTimeout(3000);
  console.log('Capturing home page with subtle gradient background...');
  await homePage.screenshot({ path: `${artifactDir}/home_screen_gradient_background.png` });
  await homePage.close();

  console.log('All screenshots captured successfully.');
} catch (err) {
  console.error('Error during capture:', err);
} finally {
  await browser.close();
}
