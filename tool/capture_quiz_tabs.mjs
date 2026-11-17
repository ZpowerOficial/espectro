import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox']
});

try {
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await page.waitForTimeout(3000);

  // Answer 5 questions
  for (let i = 0; i < 5; i++) {
    await page.mouse.click(500, 360);
    await page.waitForTimeout(300);
    await page.mouse.click(1000, 860);
    await page.waitForTimeout(400);
  }

  // Open preliminary result via bottom button at (640, 860)
  console.log('1. Opening preliminary result...');
  await page.mouse.click(640, 860);
  await page.waitForTimeout(3000);
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_preliminar_banner.png` });

  // 2. Click Eixos (12) tab at (300, 88)
  console.log('2. Switching to Eixos (12) tab...');
  await page.mouse.click(300, 88);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_eixos_dual_track.png` });

  // 3. Click Tríades (6) tab at (370, 88)
  console.log('3. Switching to Tríades (6) tab...');
  await page.mouse.click(370, 88);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_triades_modernas.png` });

  // 4. Click "Continuar teste" in top AppBar at (1320, 28)
  console.log('4. Clicking Continuar teste at (1320, 28) to resume quiz...');
  await page.mouse.click(1320, 28);
  await page.waitForTimeout(2500);
  await page.screenshot({ path: `${artifactDir}/quiz_desktop_retomado_para_refinamento.png` });

  await page.close();
  console.log('All tabs and resume flow captured successfully!');
} finally {
  await browser.close();
}
