import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  // 1. Desktop Flow
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
    const concordo = page.locator('flt-semantics[aria-label*="Concordo totalmente"], flt-semantics[aria-label*="Concordo"]').first();
    if (await concordo.count() > 0) {
      await concordo.click();
    } else {
      await page.mouse.click(720, 520);
    }
    await page.waitForTimeout(600);

    const prox = page.locator('flt-semantics[aria-label*="Próxima"]').first();
    if (await prox.count() > 0) {
      await prox.click();
      await page.waitForTimeout(500);
    }
  }

  await page.waitForTimeout(1200);
  console.log('3. Capturing Quiz Screen with preview chip active...');
  await page.screenshot({ path: `${artifactDir}/quiz_desktop_com_previa.png` });

  console.log('4. Clicking Prévia chip...');
  const previa = page.locator('flt-semantics[aria-label*="Prévia"]').first();
  if (await previa.count() > 0) {
    await previa.click();
  } else {
    // Header chip click
    await page.mouse.click(775, 75);
  }
  await page.waitForTimeout(3500);

  console.log('5. Capturing Preliminary Results Screen on Desktop...');
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_preliminar_banner.png` });

  console.log('6. Scrolling down to 12 axes dual-track bars...');
  await page.mouse.wheel(0, 600);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${artifactDir}/resultado_desktop_eixos_dual_track.png` });

  console.log('7. Clicking Continuar o teste e refinar...');
  const resumeBtn = page.locator('flt-semantics[aria-label*="Continuar o teste"]').first();
  if (await resumeBtn.count() > 0) {
    await resumeBtn.click();
  } else {
    const backBtn = page.locator('flt-semantics[aria-label*="Voltar ao teste"]').first();
    if (await backBtn.count() > 0) {
      await backBtn.click();
    }
  }
  await page.waitForTimeout(2500);
  await page.screenshot({ path: `${artifactDir}/quiz_desktop_retomado_para_refinamento.png` });

  // 2. Mobile Flow
  console.log('8. Loading Quiz on Mobile (390x844)...');
  const mobilePage = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobilePage.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await mobilePage.waitForTimeout(4000);

  const semMob = mobilePage.locator('flt-semantics-placeholder');
  if (await semMob.count() > 0) {
    await semMob.focus();
    await semMob.press('Enter');
    await mobilePage.waitForTimeout(1000);
  }

  console.log('9. Answering 5 questions on mobile...');
  for (let i = 0; i < 5; i++) {
    await mobilePage.mouse.click(195, 460);
    await mobilePage.waitForTimeout(400);
    await mobilePage.mouse.click(320, 810);
    await mobilePage.waitForTimeout(500);
  }

  await mobilePage.waitForTimeout(1000);
  await mobilePage.screenshot({ path: `${artifactDir}/quiz_mobile_com_previa.png` });

  console.log('10. Clicking Prévia on mobile...');
  // Click header chip at ~ (230, 42) or bottom button at ~ (195, 810)
  await mobilePage.mouse.click(230, 42);
  await mobilePage.waitForTimeout(3500);
  await mobilePage.screenshot({ path: `${artifactDir}/resultado_preliminar_mobile.png` });

  await mobilePage.close();
  await page.close();
  console.log('All screenshots captured successfully!');
} finally {
  await browser.close();
}
