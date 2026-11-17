import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  // 1. Desktop Overview (1440x900)
  console.log('1. Capturing desktop overview...');
  const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await page.goto('http://127.0.0.1:8080/#/atlas?v=1&view=map');
  await page.waitForTimeout(4000);

  // Enable semantics
  const sem = page.locator('flt-semantics-placeholder');
  if (await sem.count() > 0) {
    await sem.focus();
    await sem.press('Enter');
    await page.waitForTimeout(1000);
  }

  await page.screenshot({ path: `${artifactDir}/teia_v2_desktop_overview.png` });

  // 2. Click on a subject in search or click on canvas
  console.log('2. Selecting Anarcocapitalismo via search modal...');
  const searchBtn = page.locator('flt-semantics[aria-label="Buscar e filtrar"]');
  await searchBtn.click();
  await page.waitForTimeout(800);
  const ancapItem = page.locator('flt-semantics').filter({ hasText: 'Anarcocapitalismo' }).first();
  if (await ancapItem.count() > 0) {
    await ancapItem.click();
    await page.waitForTimeout(1200);
  }
  await page.screenshot({ path: `${artifactDir}/teia_v2_desktop_selected.png` });

  // Close inspector
  const closeDetails = page.locator('flt-semantics[aria-label="Fechar detalhes"]');
  if (await closeDetails.count() > 0) {
    await closeDetails.click();
    await page.waitForTimeout(600);
  }

  // 3. Multi-Teia: click "+ Teia (1/4)"
  console.log('3. Clicking + Teia button to add 2nd teia...');
  const addBtn = page.locator('flt-semantics[aria-label*="+ Teia"]');
  await addBtn.click();
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${artifactDir}/teia_v2_desktop_multi_teia_2.png` });

  // Add 3rd and 4th teias
  console.log('Adding 3rd teia...');
  await addBtn.click();
  await page.waitForTimeout(1200);

  console.log('Adding 4th teia...');
  await addBtn.click();
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${artifactDir}/teia_v2_desktop_multi_teia_4.png` });

  // 4. Zoom test
  console.log('4. Capturing zoom test...');
  const zoomPage = await browser.newPage({ viewport: { width: 1440, height: 900 } });
  await zoomPage.goto('http://127.0.0.1:8080/#/atlas?v=1&view=map');
  await zoomPage.waitForTimeout(3500);
  await zoomPage.mouse.move(720, 450);
  for (let i = 0; i < 4; i++) {
    await zoomPage.mouse.wheel(0, -350);
    await zoomPage.waitForTimeout(200);
  }
  await zoomPage.waitForTimeout(1000);
  await zoomPage.screenshot({ path: `${artifactDir}/teia_v2_desktop_zoom.png` });
  await zoomPage.close();

  // 5. Mobile (390x844)
  console.log('5. Capturing mobile overview...');
  const mobilePage = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobilePage.goto('http://127.0.0.1:8080/#/atlas?v=1&view=map');
  await mobilePage.waitForTimeout(4000);
  await mobilePage.screenshot({ path: `${artifactDir}/teia_v2_mobile_overview.png` });
  await mobilePage.close();

  await page.close();
  console.log('All screenshots captured successfully!');
} finally {
  await browser.close();
}
