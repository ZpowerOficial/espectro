import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

  // 1. Nazismo selected in Teia -> Click "Aba AS 6 TRÍADES"
  console.log('1. Opening Teia with Nazismo selected and clicking Aba AS 6 TRÍADES...');
  await page.goto('http://127.0.0.1:8080/#/atlas?v=1&view=map&select=current:nazismo');
  await page.waitForTimeout(4000);

  // Enable semantics
  const sem = page.locator('flt-semantics-placeholder');
  if (await sem.count() > 0) {
    await sem.focus();
    await sem.press('Enter');
    await page.waitForTimeout(1000);
  }

  // Find Aba AS 6 TRÍADES
  const triadesBtn = page.locator('flt-semantics[aria-label*="TRÍADES"]');
  if (await triadesBtn.count() > 0) {
    await triadesBtn.first().click();
    await page.waitForTimeout(1500);
  } else {
    await page.mouse.click(1350, 410);
    await page.waitForTimeout(1500);
  }
  await page.screenshot({ path: `${artifactDir}/teia_v3_desktop_inspector_triades.png` });

  // 2. Nazismo Profile Screen directly on tab=dimensoes
  console.log('2. Opening Nazismo Profile directly on tab=dimensoes...');
  await page.goto('http://127.0.0.1:8080/#/atlas?v=1&subject=current:nazismo&tab=dimensoes');
  await page.waitForTimeout(4000);
  await page.screenshot({ path: `${artifactDir}/perfil_v3_desktop_dimensoes.png` });

  await page.close();
  console.log('Done capturing targeted screenshots!');
} finally {
  await browser.close();
}
