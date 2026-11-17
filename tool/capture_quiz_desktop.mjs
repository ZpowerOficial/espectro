import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });

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

  console.log('2. Inside quiz, answering 5 questions...');
  for (let i = 0; i < 5; i++) {
    // Click option 1
    await page.mouse.click(400, 360);
    await page.waitForTimeout(400);
    // Click Próxima
    await page.mouse.click(700, 950);
    await page.waitForTimeout(400);
  }

  await page.waitForTimeout(1000);
  console.log('3. Clicking Prévia header chip at (630, 40)...');
  await page.mouse.click(630, 40);
  await page.waitForTimeout(3500);

  console.log('4. Capturing Desktop Preliminary Results Banner...');
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_preliminar_banner.png` });

  // Switch to Eixos tab
  console.log('5. Clicking Eixos (12) tab...');
  // The tabs in result screen are around (400, 105)
  const eixosTab = page.locator('flt-semantics[aria-label*="Eixos"]').first();
  if (await eixosTab.count() > 0) {
    await eixosTab.click();
  } else {
    await page.mouse.click(420, 105);
  }
  await page.waitForTimeout(2000);
  console.log('6. Capturing Desktop Dual-Track 12 Axes...');
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_eixos_dual_track.png` });

  // Switch to Tríades tab
  console.log('7. Clicking Tríades (6) tab...');
  const triadesTab = page.locator('flt-semantics[aria-label*="Tríades"]').first();
  if (await triadesTab.count() > 0) {
    await triadesTab.click();
  } else {
    await page.mouse.click(520, 105);
  }
  await page.waitForTimeout(2000);
  console.log('8. Capturing Desktop Triads...');
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_triades_modernas.png` });

  // Click Continuar teste
  console.log('9. Clicking Continuar o teste...');
  const contBtn = page.locator('flt-semantics[aria-label*="Continuar"]').first();
  if (await contBtn.count() > 0) {
    await contBtn.click();
  } else {
    // Back arrow at top left ~ (50, 30)
    await page.mouse.click(50, 30);
  }
  await page.waitForTimeout(2500);
  console.log('10. Capturing Quiz Screen resumed after refinement...');
  await page.screenshot({ path: `${artifactDir}/quiz_desktop_retomado_para_refinamento.png` });

  await page.close();
  console.log('Done capturing targeted desktop screenshots!');
} finally {
  await browser.close();
}
