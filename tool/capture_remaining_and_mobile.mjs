import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox']
});

try {
  // 1. Desktop remaining sections
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

  // Scroll directly down to Section 07 (Bússola & Tríades)
  console.log('Scrolling to Section 07 (Bússola & Tríades)...');
  await page.mouse.wheel(0, 2600);
  await page.waitForTimeout(1000);
  await page.screenshot({ path: `${artifactDir}/journey_06_bussola_triade.png` });

  // Scroll to Section 08 (Outras Ideologias) & 09 (Ações)
  console.log('Scrolling to Section 08 (Outras Ideologias) & 09 (Ações)...');
  await page.mouse.wheel(0, 950);
  await page.waitForTimeout(1000);
  await page.screenshot({ path: `${artifactDir}/journey_07_ideologias_acoes_bottom.png` });

  // 2. Mobile Flow (390x844)
  console.log('2. Loading Quiz on Mobile (390x844)...');
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobile.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await mobile.waitForTimeout(3000);

  for (let i = 0; i < 5; i++) {
    // Click option 1
    await mobile.mouse.click(200, 500);
    await mobile.waitForTimeout(250);
    // Click Próxima
    await mobile.mouse.click(280, 795);
    await mobile.waitForTimeout(350);
  }

  // Click Prévia on mobile header or bottom bar
  console.log('Clicking Prévia on mobile header (230, 40)...');
  await mobile.mouse.click(230, 40);
  await mobile.waitForTimeout(3000);

  console.log('Capturing Mobile Hero...');
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_hero.png` });

  console.log('Scrolling Mobile to 12 Axes...');
  await mobile.mouse.wheel(0, 600);
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_eixos.png` });

  console.log('Scrolling Mobile to Distinção & Países...');
  await mobile.mouse.wheel(0, 850);
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_paises.png` });

  console.log('Scrolling Mobile to Personalidades & Livros...');
  await mobile.mouse.wheel(0, 950);
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_personalidades_livros.png` });

  console.log('Scrolling Mobile to Partidos & Tríades...');
  await mobile.mouse.wheel(0, 950);
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_partidos_triades.png` });

  await page.close();
  await mobile.close();
  console.log('Done capturing all views!');
} finally {
  await browser.close();
}
