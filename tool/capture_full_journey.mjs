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

  // Answer 6 questions with distinct answers
  const optionsY = [360, 420, 560, 620, 360, 420];
  for (let i = 0; i < 6; i++) {
    await page.mouse.click(500, optionsY[i]);
    await page.waitForTimeout(250);
    await page.mouse.click(1000, 860);
    await page.waitForTimeout(350);
  }

  // Click bottom preliminary result button
  console.log('1. Opening preliminary result...');
  await page.mouse.click(640, 860);
  await page.waitForTimeout(2500);

  console.log('Capturing Desktop Hero & 12 Axes...');
  await page.screenshot({ path: `${artifactDir}/journey_01_hero_eixos.png` });

  console.log('Scrolling to Distinção & Países...');
  await page.mouse.wheel(0, 750);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/journey_02_distincao_paises.png` });

  console.log('Scrolling to Personalidades & Livros...');
  await page.mouse.wheel(0, 800);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/journey_03_personalidades_livros.png` });

  console.log('Scrolling to Partidos & Bússola / Tríades...');
  await page.mouse.wheel(0, 800);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/journey_04_partidos_bussola.png` });

  console.log('Scrolling to Outras Ideologias & Ações...');
  await page.mouse.wheel(0, 800);
  await page.waitForTimeout(800);
  await page.screenshot({ path: `${artifactDir}/journey_05_ideologias_acoes.png` });

  // Mobile flow
  console.log('Loading Mobile Viewport (390x844)...');
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobile.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await mobile.waitForTimeout(3000);

  for (let i = 0; i < 5; i++) {
    await mobile.mouse.click(200, 360);
    await mobile.waitForTimeout(250);
    // Click Próxima on mobile: bottom right (300, 810)
    await mobile.mouse.click(300, 810);
    await mobile.waitForTimeout(350);
  }

  // Click Prévia on mobile: bottom bar (140, 810)
  console.log('Opening mobile preliminary result...');
  await mobile.mouse.click(140, 810);
  await mobile.waitForTimeout(2500);

  console.log('Capturing Mobile Hero & Quick Nav...');
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_01_hero.png` });

  console.log('Scrolling Mobile to 12 Axes & Países...');
  await mobile.mouse.wheel(0, 600);
  await mobile.waitForTimeout(800);
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_02_eixos.png` });

  await mobile.mouse.wheel(0, 750);
  await mobile.waitForTimeout(800);
  await mobile.screenshot({ path: `${artifactDir}/journey_mobile_03_paises_personalidades.png` });

  await page.close();
  await mobile.close();
  console.log('Done capturing journey screenshots!');
} finally {
  await browser.close();
}
