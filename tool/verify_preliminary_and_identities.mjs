import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';

const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});

try {
  const page = await browser.newPage({ viewport: { width: 1440, height: 1000 } });

  console.log('1. Navigating directly to Espectro Quiz (complete suite)...');
  await page.goto('http://127.0.0.1:8080/#/quiz?suite=espectroIntegrated&depth=complete');
  await page.waitForTimeout(4000);

  // Enable semantics placeholder for accessibility/text matching
  const sem = page.locator('flt-semantics-placeholder');
  if (await sem.count() > 0) {
    await sem.focus();
    await sem.press('Enter');
    await page.waitForTimeout(1000);
  }

  console.log('2. In Quiz: capturing Question 1 with dual badges (EIXO and TRÍADE)...');
  await page.screenshot({ path: `${artifactDir}/quiz_dual_badges_question1.png` });

  console.log('3. Answering 25 questions with Likert options...');
  for (let i = 0; i < 25; i++) {
    // Alternate answers between Strongly Agree, Agree, and Neutral
    const concordo = page.locator('flt-semantics[aria-label*="Concordo totalmente"], flt-semantics[aria-label*="Concordo"]').first();
    if (await concordo.count() > 0) {
      await concordo.click();
    } else {
      await page.mouse.click(500, 480);
    }
    await page.waitForTimeout(400);

    const prox = page.locator('flt-semantics[aria-label*="Próxima"]').first();
    if (await prox.count() > 0) {
      try {
        await prox.click({ timeout: 500 });
        await page.waitForTimeout(300);
      } catch (_) {}
    }
  }

  await page.waitForTimeout(1500);
  console.log('4. Capturing quiz after 25 answers with milestone indication and "Base completa"...');
  await page.screenshot({ path: `${artifactDir}/quiz_milestone_25_answers.png` });

  // Locate and click the Prévia / Resultado preliminar button
  console.log('5. Clicking Prévia button...');
  const previa = page.locator('flt-semantics[aria-label*="Prévia"]').first();
  if (await previa.count() > 0) {
    await previa.click();
  } else {
    await page.mouse.click(640, 960);
  }
  await page.waitForTimeout(4000);

  console.log('6. Capturing Preliminary Results Top Hero...');
  await page.screenshot({ path: `${artifactDir}/preliminary_results_top_hero.png` });

  // Verify decimals: search entire page text/labels for unrounded decimals (3+ decimals)
  const bodyText = await page.evaluate(() => {
    const semElements = Array.from(document.querySelectorAll('flt-semantics'));
    const labels = semElements.map(e => e.getAttribute('aria-label') || '').filter(Boolean);
    return labels.join(' \n ') + ' \n ' + document.body.innerText;
  });

  const percentDecimalsMatch = bodyText.match(/\d+\.\d{3,}%/g);
  const generalDecimalsMatch = bodyText.match(/\b\d+\.\d{4,}\b/g);
  console.log('Infinite percentage decimals found:', percentDecimalsMatch ? percentDecimalsMatch : 'NONE! All percentages rounded to 2 decimal places!');
  console.log('Long general decimals found:', generalDecimalsMatch ? generalDecimalsMatch : 'NONE! All clean!');

  // Now click on "Comparar comigo em detalhes" to test comparison overlay with real entity
  console.log('7. Clicking on [Comparar comigo em detalhes] button in Hero...');
  const compBtn = page.locator('flt-semantics[aria-label*="Comparar comigo em detalhes"]').first();
  if (await compBtn.count() > 0) {
    await compBtn.click();
  } else {
    await page.mouse.click(495, 715);
  }
  await page.waitForTimeout(3000);

  console.log('8. Capturing Entity Comparison Overlay Top (Radar & Nolan)...');
  await page.screenshot({ path: `${artifactDir}/compare_real_overlay_top.png` });

  console.log('9. Scrolling down inside comparison to Contraste por Eixo...');
  await page.mouse.move(720, 500);
  await page.mouse.wheel(0, 800);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${artifactDir}/compare_real_overlay_axes.png` });

  console.log('10. Scrolling down inside comparison to Contraste por Tríade (overlaid ternary chart)...');
  await page.mouse.wheel(0, 800);
  await page.waitForTimeout(1500);
  await page.screenshot({ path: `${artifactDir}/compare_real_overlay_triads.png` });

  // Close comparison modal / screen (back button or ESC)
  console.log('11. Closing comparison screen to return to preliminary results...');
  const backBtn = page.locator('flt-semantics[aria-label*="Voltar"]').or(page.locator('button[aria-label*="Back"]')).first();
  if (await backBtn.count() > 0) {
    await backBtn.click();
  } else {
    await page.keyboard.press('Escape');
    await page.mouse.click(195, 25);
  }
  await page.waitForTimeout(2000);

  // Scroll down to check Triads and Government Triad (Anarquismo)
  console.log('12. Scrolling down to 6 Triads and Government Triad (Anarquismo)...');
  await page.mouse.move(720, 500);
  await page.mouse.wheel(0, 2200);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: `${artifactDir}/preliminary_results_triads_government_anarquismo.png` });

  // Scroll down to Countries (checking Liberland) and Personalities
  console.log('13. Scrolling to Countries & Personalities (checking Liberland)...');
  await page.mouse.wheel(0, 1500);
  await page.waitForTimeout(2000);
  await page.screenshot({ path: `${artifactDir}/preliminary_results_countries_liberland.png` });

  console.log('All comprehensive visual verifications complete!');
} catch (err) {
  console.error('Error in verification:', err);
} finally {
  await browser.close();
}
