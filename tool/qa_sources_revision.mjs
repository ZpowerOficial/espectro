import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
import fs from 'node:fs/promises';
const out='docs/qa/sources-expansion-2026-11-05';
await fs.mkdir(out,{recursive:true});
const browser=await chromium.launch({executablePath:'/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',headless:true});
const report=[];
try {
  for(const width of [390,1440]) {
    const page=await browser.newPage({viewport:{width,height:1000},reducedMotion:'reduce'});
    page.setDefaultTimeout(5000);
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto('http://127.0.0.1:4173/#/atlas?v=1&subject=current%3Anazismo');
    await page.waitForTimeout(4500);
    await page.locator('flt-semantics-placeholder').press('Enter',{timeout:10000});
    await page.getByRole('tab',{name:'Dimensões',exact:true}).click();
    await page.waitForTimeout(200);
    const initial=await page.locator('body').ariaSnapshot();
    if(!initial.includes('14/18 dimensões'))throw Error('Expanded primary coverage missing');
    for(const [name,pattern,date,document] of [
      ['diplomacy',/Fonte primária e interpretação Registro da reunião/, '10/11/1937','document-1540'],
      ['moral',/Fonte primária e interpretação Discurso à Liga/, '08/09/1934','document-1557'],
    ]) {
      await page.mouse.move(width/2,500);
      await page.mouse.wheel(0,-20000);
      await page.waitForTimeout(250);
      const target=page.getByRole('button',{name:pattern}).first();
      let found=false;
      for(let i=0;i<65;i++) {
        const box=await target.count()?await target.boundingBox().catch(()=>null):null;
        if(box&&box.y>100&&box.y+box.height<900){found=true;break;}
        await page.mouse.wheel(0,box?box.y-220:200);
        await page.waitForTimeout(100);
      }
      if(!found){
        await fs.writeFile(`${out}/failure-${name}-${width}.txt`,await page.locator('body').ariaSnapshot());
        await page.screenshot({path:`${out}/failure-${name}-${width}.png`});
        throw Error(name+' source not reachable');
      }
      await target.click();
      await page.waitForTimeout(250);
      await page.mouse.wheel(0,220);
      await page.waitForTimeout(200);
      const tree=await page.locator('body').ariaSnapshot();
      await fs.writeFile(`${out}/${name}-${width}.txt`,tree);
      await page.screenshot({path:`${out}/${name}-${width}.png`});
      if(!tree.includes(date)||!tree.includes(document))throw Error(name+' source metadata missing');
    }
    if(errors.length)throw Error(errors.join('\n'));
    report.push({width,coverage:'14/18',diplomacySource:true,moralSource:true,errors});
    await page.close();
  }
}finally{
  await fs.writeFile(`${out}/browser.json`,JSON.stringify(report,null,2));
  await browser.close();
}
console.log(JSON.stringify(report));
