// Private-session QA: only a loopback URL receives the result fragment.
import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
import fs from 'node:fs/promises';
const out='build/artifacts/dossier-audit/browser';
await fs.mkdir(out,{recursive:true});
const record=JSON.parse(await fs.readFile('build/artifacts/dossier-audit/record_reprocessado.json','utf8'));
const token=Buffer.from(JSON.stringify({v:1,record})).toString('base64url');
const browser=await chromium.launch({executablePath:'/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',headless:true});
const report=[];
try{
  for(const width of [390,1440]){
    const page=await browser.newPage({viewport:{width,height:1000},reducedMotion:'reduce'});
    const errors=[];page.on('pageerror',e=>errors.push(e.message));
    await page.goto('http://127.0.0.1:4173/#/shared?v=1&data='+token);
    await page.waitForTimeout(4500);
    await page.locator('flt-semantics-placeholder').press('Enter',{timeout:10000});
    await page.waitForTimeout(300);
    const tree=await page.locator('body').ariaSnapshot();
    await fs.writeFile(`${out}/result-${width}.txt`,tree);
    await page.screenshot({path:`${out}/result-${width}.png`});
    if(!tree.includes('60/60 itens desta sessão') || !tree.includes('Libertarianismo Consequencialista') || !tree.includes('Voluntarismo'))throw Error('Replayed result or session count not rendered');
    await page.getByRole('tab',{name:/Eixos/}).click();
    await page.waitForTimeout(250);
    await page.getByRole('button',{name:/^Estrutura:/}).click();
    await page.waitForTimeout(250);
    const axisTree=await page.locator('body').ariaSnapshot();
    await fs.writeFile(`${out}/axes-${width}.txt`,axisTree);
    await page.screenshot({path:`${out}/axes-${width}.png`});
    if(!axisTree.toLocaleLowerCase('pt-BR').includes('confiança baixa'))throw Error('Short-form confidence not visible');
    if(errors.length)throw Error(errors.join('\n'));
    report.push({width,rendered:true,sessionCountExplicit:true,lowSampleConfidence:true,pageErrors:errors,privateInput:'local replay, no result URL logged'});
    await page.close();
  }
}finally{await fs.writeFile(`${out}/validation.json`,JSON.stringify(report,null,2));await browser.close();}
console.log(JSON.stringify(report));
