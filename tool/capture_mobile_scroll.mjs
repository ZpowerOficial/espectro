import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox']
});

try {
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 }, hasTouch: true });
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

  console.log('Capturing mobile hero...');
  await mobile.screenshot({ path: `${artifactDir}/mobile_scroll_01_hero.png` });

  // Drag scroll down
  console.log('Dragging down to 12 axes...');
  await mobile.mouse.move(200, 650);
  await mobile.mouse.down();
  await mobile.mouse.move(200, 150, { steps: 15 });
  await mobile.mouse.up();
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_scroll_02_eixos.png` });

  console.log('Dragging down to Distinção & Países...');
  await mobile.mouse.move(200, 650);
  await mobile.mouse.down();
  await mobile.mouse.move(200, 150, { steps: 15 });
  await mobile.mouse.up();
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_scroll_03_paises.png` });

  console.log('Dragging down to Personalidades & Livros...');
  await mobile.mouse.move(200, 650);
  await mobile.mouse.down();
  await mobile.mouse.move(200, 150, { steps: 15 });
  await mobile.mouse.up();
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_scroll_04_personalidades_livros.png` });

  console.log('Dragging down to Partidos & Tríades...');
  await mobile.mouse.move(200, 650);
  await mobile.mouse.down();
  await mobile.mouse.move(200, 150, { steps: 15 });
  await mobile.mouse.up();
  await mobile.waitForTimeout(1000);
  await mobile.screenshot({ path: `${artifactDir}/mobile_scroll_05_partidos_triades.png` });

  await mobile.close();
  console.log('Mobile scrolling captured successfully!');
} finally {
  await browser.close();
}
