import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox']
});

try {
  console.log('1. Loading Quiz directly on desktop (1440x900)...');
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await page.waitForTimeout(3000);

  for (let i = 0; i < 6; i++) {
    await page.mouse.click(500, 360);
    await page.waitForTimeout(250);
    await page.mouse.click(1000, 860);
    await page.waitForTimeout(350);
  }

  console.log('Opening desktop preliminary result...');
  await page.mouse.click(640, 860);
  await page.waitForTimeout(2500);

  console.log('Clicking TOC: 03 Países at (1250, 285)...');
  await page.mouse.click(1250, 285);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/sticky_toc_03_paises.png` });

  console.log('Clicking TOC: 07 Bússola & Tríades at (1250, 425)...');
  await page.mouse.click(1250, 425);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/sticky_toc_07_bussola_triades.png` });

  console.log('Clicking TOC: 08 Outras ideologias at (1250, 460)...');
  await page.mouse.click(1250, 460);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/sticky_toc_08_outras_ideologias.png` });

  await page.close();
  console.log('Sticky TOC jumps captured successfully!');
} finally {
  await browser.close();
}
