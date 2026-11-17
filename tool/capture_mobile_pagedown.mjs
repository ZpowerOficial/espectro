import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox']
});

try {
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobile.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await mobile.waitForTimeout(3000);

  for (let i = 0; i < 5; i++) {
    await mobile.mouse.click(200, 500);
    await mobile.waitForTimeout(250);
    await mobile.mouse.click(280, 795);
    await mobile.waitForTimeout(350);
  }

  // Click Prévia
  await mobile.mouse.click(230, 40);
  await mobile.waitForTimeout(2500);

  // Focus body
  await mobile.mouse.click(200, 300);
  await mobile.waitForTimeout(300);

  console.log('Pressing PageDown on mobile...');
  await mobile.keyboard.press('PageDown');
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_pagedown_01.png` });

  await mobile.keyboard.press('PageDown');
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_pagedown_02.png` });

  await mobile.keyboard.press('PageDown');
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_pagedown_03.png` });

  await mobile.close();
  console.log('Mobile PageDown captured!');
} finally {
  await browser.close();
}
