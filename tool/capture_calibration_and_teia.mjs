import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  // 1. Mobile Teia View (390x844) - Single Teia with Tab Switcher
  const mobilePage = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
    hasTouch: true
  });

  console.log('1. Loading Mobile Teia...');
  await mobilePage.goto('http://127.0.0.1:8080/#/atlas?v=1&view=map');
  await mobilePage.waitForTimeout(4500);

  // Enable semantics
  const semMobile = mobilePage.locator('flt-semantics-placeholder');
  if (await semMobile.count() > 0) {
    await semMobile.focus();
    await semMobile.press('Enter');
    await mobilePage.waitForTimeout(1000);
  }

  console.log('2. Capturing Mobile Teia Single View with Tab Switcher...');
  await mobilePage.screenshot({ path: `${artifactDir}/teia_mobile_redesign_single.png` });

  // Tap on "+ Teia" button in mobile tab strip to add a second teia
  console.log('3. Adding second teia in mobile strip...');
  const addStripBtn = mobilePage.locator('[key="add-teia-strip-btn"]');
  if (await addStripBtn.count() > 0) {
    await addStripBtn.click();
    await mobilePage.waitForTimeout(1500);
  } else {
    // Tap where + Teia is (right side of tab strip, around y=85, x=340)
    await mobilePage.mouse.click(330, 85);
    await mobilePage.waitForTimeout(1500);
  }

  console.log('4. Capturing Mobile Multi-Teia with Tabs (Teia 1, Teia 2)...');
  await mobilePage.screenshot({ path: `${artifactDir}/teia_mobile_redesign_tabs.png` });

  // Tap center point on canvas to open inspector
  console.log('5. Tapping center to open inspector...');
  await mobilePage.mouse.click(195, 450);
  await mobilePage.waitForTimeout(2000);
  await mobilePage.screenshot({ path: `${artifactDir}/teia_mobile_inspector_open.png` });

  await mobilePage.close();

  // 2. Profile Screen with Realism Calibration (390x844)
  const profilePage = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 2,
    isMobile: true,
  });

  console.log('6. Loading Profile with Calibrated Percentages...');
  await profilePage.goto('http://127.0.0.1:8080/#/atlas?subject=current:socialismo_democratico&tab=dimensoes');
  await profilePage.waitForTimeout(4000);

  console.log('7. Capturing Profile Calibrated Percentages (Mobile)...');
  await profilePage.screenshot({ path: `${artifactDir}/profile_calibrated_percentages_mobile.png` });
  await profilePage.close();

  // 3. Desktop Multi-Teia View (1440x900)
  const desktopPage = await browser.newPage({
    viewport: { width: 1440, height: 900 },
    deviceScaleFactor: 1
  });

  console.log('8. Loading Desktop Teia Multi-Pane Grid...');
  await desktopPage.goto('http://127.0.0.1:8080/#/atlas?v=1&view=map');
  await desktopPage.waitForTimeout(4000);

  console.log('9. Capturing Desktop Multi-Pane Teia Grid...');
  await desktopPage.screenshot({ path: `${artifactDir}/teia_desktop_grid.png` });
  await desktopPage.close();

  console.log('ALL VISUAL VERIFICATION CAPTURES COMPLETE!');
} finally {
  await browser.close();
}
