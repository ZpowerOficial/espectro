import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
import fs from 'node:fs/promises';
import crypto from 'node:crypto';
const out = 'docs/qa/revision-2026-11-05';
await fs.mkdir(out, { recursive: true });
const browser = await chromium.launch({executablePath:'/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome', headless:true});
const report=[];
try {
  for (const width of [390,1440]) {
    const page = await browser.newPage({viewport:{width,height:844},reducedMotion:'reduce'});
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto('http://127.0.0.1:4173/#/atlas?v=1&view=map');
    await page.waitForTimeout(5000);
    await page.locator('flt-semantics-placeholder').press('Enter',{timeout:20000});
    await page.getByRole('button',{name:'Buscar e filtrar',exact:true}).waitFor();
    await page.waitForTimeout(500);
    const hash=b=>crypto.createHash('sha256').update(b).digest('hex');
    const before = await page.screenshot({path:`${out}/map-${width}.png`});
    await page.mouse.move(width/2,420);await page.mouse.down();
    await page.mouse.move(width/2+70,480,{steps:12});await page.mouse.up();
    await page.waitForTimeout(250);
    const after=await page.screenshot({path:`${out}/pan-${width}.png`});
    if(hash(before)===hash(after))throw Error('Pan did not change visible canvas');
    await page.mouse.wheel(0,-240);await page.waitForTimeout(250);
    const zoom=await page.screenshot({path:`${out}/zoom-${width}.png`});
    if(hash(zoom)===hash(after))throw Error('Wheel did not change visible canvas');
    await page.getByRole('button',{name:'Buscar e filtrar',exact:true}).click();
    const searchTree=await page.locator('body').ariaSnapshot();
    if(!searchTree.includes('289 verbetes'))throw Error('Not all 289 currents available');
    await fs.writeFile(`${out}/search-${width}.txt`,searchTree);
    await page.mouse.click(width / 2, 15);
    await page.waitForTimeout(350);
    await page.getByRole('button',{name:'Escolher eixos',exact:true}).click();
    await page.getByRole('checkbox',{name:'12 eixos',exact:true}).click();
    await page.screenshot({path:`${out}/axes-${width}.png`});
    await fs.writeFile(`${out}/axes-${width}.txt`,await page.locator('body').ariaSnapshot());
    report.push({width,pan:true,wheel:true,allCurrents:289,pageErrors:errors,before:hash(before),after:hash(after)});
    if(errors.length)throw Error(errors.join('\n'));
    await page.close();
  }
} finally {
  await fs.writeFile(`${out}/browser.json`,JSON.stringify(report,null,2));
  await browser.close();
}
console.log(JSON.stringify(report));
