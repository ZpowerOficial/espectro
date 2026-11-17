import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
import fs from 'node:fs/promises';
const out = 'docs/qa/primary-triangles-2026-11-05';
await fs.mkdir(out, {recursive:true});
const browser = await chromium.launch({executablePath:'/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',headless:true});
const report=[];
try {
  for (const width of [390,1440]) {
    const page=await browser.newPage({viewport:{width,height:1000},reducedMotion:'reduce'});
    page.setDefaultTimeout(5000);
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto('http://127.0.0.1:4173/#/atlas?v=1&subject=current%3Afascismo_historico');
    await page.waitForTimeout(4500);
    await page.locator('flt-semantics-placeholder').press('Enter',{timeout:10000});
    await page.getByRole('tab',{name:'Dimensões',exact:true}).click();
    await page.waitForTimeout(300);
    const tree=await page.locator('body').ariaSnapshot();
    if(!tree.includes('8/18 dimensões')) throw Error('Primary dimensional coverage missing');
    await fs.writeFile(`${out}/dimensions-${width}.txt`,tree);
    await page.screenshot({path:`${out}/dimensions-${width}.png`});
    await page.mouse.move(width/2,500);
    const triangle=page.getByRole('button',{name:/Triângulo: A Controle/}).first();
    for(let i=0;i<30;i++) {
      const box=await triangle.count() ? await triangle.boundingBox().catch(()=>null) : null;
      if(box && box.y>=100 && box.y+box.height<950) break;
      await page.mouse.wheel(0,box ? box.y-190 : 550);
      await page.waitForTimeout(120);
    }
    await fs.writeFile(`${out}/scrolled-${width}.txt`,await page.locator('body').ariaSnapshot());
    await page.screenshot({path:`${out}/scrolled-${width}.png`});
    const box=await triangle.boundingBox();
    if(!box || box.y<80 || box.y>750) throw Error('Economy triangle not reachable');
    await page.screenshot({path:`${out}/triangle-${width}.png`});
    await page.mouse.click(box.x+box.width/2,box.y+box.height*.6);
    await page.waitForTimeout(100);
    const after=await page.locator('body').ariaSnapshot();
    if(!after.includes('Área explorada:')) throw Error('Triangle inspection did not respond');
    await fs.writeFile(`${out}/triangle-${width}.txt`,after);
    await page.screenshot({path:`${out}/triangle-probed-${width}.png`});
    await page.getByRole('button',{name:/Fonte primária e interpretação Carta del Lavoro/}).first().click();
    await page.waitForTimeout(350);
    await page.mouse.move(width/2,600);
    await page.mouse.wheel(0,300);
    await page.waitForTimeout(250);
    const sources=await page.locator('body').ariaSnapshot();
    await fs.writeFile(`${out}/source-${width}.txt`,sources);
    await page.screenshot({path:`${out}/source-${width}.png`});
    if(!sources.includes('polyarchy.org') || !sources.includes('21/04/1927')) throw Error('Per-dimension primary metadata missing');
    report.push({width,primaryCoverage:'8/18',triangleVisible:true,interactiveProbe:true,primarySourcePane:true,errors});
    if(errors.length)throw Error(errors.join('\n'));
    await page.close();
  }
} finally {
  await fs.writeFile(`${out}/browser.json`,JSON.stringify(report,null,2));
  await browser.close();
}
console.log(JSON.stringify(report));
