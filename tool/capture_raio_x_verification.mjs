import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Captura verificada do Raio-X. Cada screenshot só é salva depois de afirmar
// que o elemento-alvo está DENTRO da viewport (bounding box), não apenas
// presente no DOM de semântica.

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const artifactDir = '/home/zpower/.gemini/antigravity-cli/brain/d0d05b5c-0ed3-4807-a5cf-c82f1b77ffa2';
const repoScreenshotsDir = path.resolve(__dirname, '../docs/screenshots');
const base = 'http://127.0.0.1:8080';

fs.mkdirSync(repoScreenshotsDir, { recursive: true });

async function saveBoth(page, filename) {
  for (const dir of [artifactDir, repoScreenshotsDir]) {
    await page.screenshot({ path: path.join(dir, filename) });
  }
  console.log(`Saved ${filename}`);
}

const tokenPath = path.resolve(__dirname, 'valid_shared_token.txt');
if (!fs.existsSync(tokenPath)) {
  console.error(`ERROR: Valid token file not found at ${tokenPath}`);
  process.exit(1);
}
const token = fs.readFileSync(tokenPath, 'utf8').trim();

async function enableSemantics(page) {
  const sem = page.locator('flt-semantics-placeholder');
  if (await sem.count() > 0) {
    await sem.focus();
    await sem.press('Enter');
    await page.waitForTimeout(1000);
  }
}

async function assertNoErrorScreen(page) {
  if (await page.locator('flt-semantics:has-text("Link indisponível")').count() > 0) {
    throw new Error('FATAL: "Link indisponível" rendered — token failed to decode.');
  }
}

/// Rola com a roda do mouse até o primeiro nó cujo texto contém [text] ter o
/// topo entre [minTop] e [maxTopRatio] da altura da viewport.
async function scrollUntilInView(page, text, { minTop = 90, maxTopRatio = 0.35, step = 250, maxSteps = 80 } = {}) {
  const vp = page.viewportSize();
  await page.mouse.move(vp.width * 0.55, vp.height * 0.6);
  for (let i = 0; i < maxSteps; i++) {
    const loc = page.locator(`flt-semantics:has-text("${text}")`).last();
    if (await loc.count() > 0) {
      const box = await loc.boundingBox();
      if (box && box.y >= minTop && box.y <= vp.height * maxTopRatio) return box;
      if (box && box.y < minTop) {
        await page.mouse.wheel(0, -Math.min(step, minTop - box.y + 20));
        await page.waitForTimeout(350);
        continue;
      }
    }
    await page.mouse.wheel(0, step);
    await page.waitForTimeout(350);
  }
  throw new Error(`FATAL: "${text}" never scrolled into the viewport.`);
}

const browser = await chromium.launch({
  executablePath: '/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox'],
});

try {
  // 1. Desktop — visão geral do resultado com o card recolhido.
  const page = await browser.newPage({ viewport: { width: 1440, height: 1100 } });
  console.log('1. Desktop result overview...');
  await page.goto(`${base}/#/shared?v=1&data=${token}`);
  await page.waitForTimeout(4000);
  await enableSemantics(page);
  await assertNoErrorScreen(page);
  await scrollUntilInView(page, 'Raio-X: Você e');
  await page.waitForTimeout(800);
  await saveBoth(page, 'raio_x_result_overview_desktop.png');

  // 2. Desktop — card expandido.
  console.log('2. Expanding Raio-X card...');
  // Flutter Web expõe o tooltip do IconButton como texto do nó role=button.
  const expandBtn = page.locator('flt-semantics[role="button"]:has-text("Expandir todos os detalhes")').first();
  if (await expandBtn.count() === 0) throw new Error('FATAL: expand button not found.');
  await expandBtn.click();
  await page.waitForTimeout(1000);
  await scrollUntilInView(page, 'Onde vocês divergem', { maxTopRatio: 0.3 });
  await page.waitForTimeout(800);
  await saveBoth(page, 'raio_x_card_expanded_desktop.png');

  // 3. Desktop — comparação usuário × entidade (EntityComparisonScreen),
  // aberta pelo botão real "Comparar comigo em detalhes".
  console.log('3. Opening user × entity comparison...');
  await page.goto(`${base}/#/shared?v=1&data=${token}`);
  await page.waitForTimeout(4000);
  await enableSemantics(page);
  await assertNoErrorScreen(page);
  await scrollUntilInView(page, 'Comparar comigo em detalhes', { maxTopRatio: 0.8 });
  await page.locator('flt-semantics:has-text("Comparar comigo em detalhes")').last().click();
  await page.waitForTimeout(2500);
  await scrollUntilInView(page, 'Raio-X: Você e');
  await page.waitForTimeout(800);
  await saveBoth(page, 'raio_x_comparison_desktop.png');

  // 4. Mobile 390×844 — card no resultado.
  console.log('4. Mobile result...');
  const mobile = await browser.newPage({ viewport: { width: 390, height: 844 } });
  await mobile.goto(`${base}/#/shared?v=1&data=${token}`);
  await mobile.waitForTimeout(4000);
  await enableSemantics(mobile);
  await assertNoErrorScreen(mobile);
  await scrollUntilInView(mobile, 'Raio-X: Você e', { minTop: 190 });
  await mobile.waitForTimeout(800);
  await saveBoth(mobile, 'raio_x_result_mobile.png');

  console.log('SUCCESS: all four captures show the Raio-X card in viewport.');
} catch (err) {
  console.error('Error during capture:', err);
  process.exit(1);
} finally {
  await browser.close();
}
