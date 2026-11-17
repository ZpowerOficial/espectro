import { chromium } from '/home/zpower/.npm/_npx/e41f203b7505f1fb/node_modules/playwright/index.mjs';
import fs from 'node:fs/promises';
const requested=process.argv.slice(2);
const ids=requested.length?requested:['murray_rothbard','karl_marx','ludwig_von_mises'];
const out=process.env.ESPECTRO_QA_OUT || (requested.length?'docs/qa/brazilian-profiles-2026-11-05':'docs/qa/editorial-reconstruction-2026-11-05');
const personalities=JSON.parse(await fs.readFile('assets/data/personalities.json','utf8')).entries;
const widths=process.env.ESPECTRO_QA_WIDTHS?process.env.ESPECTRO_QA_WIDTHS.split(',').map(Number):[390,1440];
if(widths.some(w=>![390,1440].includes(w)))throw Error('Unsupported QA width');
await fs.mkdir(out,{recursive:true});
const browser=await chromium.launch({executablePath:'/home/zpower/.cache/ms-playwright/chromium-1243/chrome-linux64/chrome',headless:true});
const report=[];
try {
  for(const width of widths) {
    for(const id of ids) {
      const expected=Object.values(personalities.find(p=>p.id===id).editorialBasis.dimensionEvidence).filter(e=>e.status==='editorial_reconstruction').length;
      const page=await browser.newPage({viewport:{width,height:1000},reducedMotion:'reduce'});
      const errors=[];page.on('pageerror',e=>errors.push(e.message));
      await page.goto(`http://127.0.0.1:4173/#/atlas?v=1&subject=personality%3A${id}`);
      await page.waitForTimeout(4500);
      await page.locator('flt-semantics-placeholder').press('Enter',{timeout:20000});
      let semanticsRetries=0;
      for(let i=0;i<4;i++) {
        if(await page.getByRole('tab',{name:'Dimensões',exact:true}).count())break;
        await page.waitForTimeout(1000);
        const placeholder=page.locator('flt-semantics-placeholder');
        if(await placeholder.count()){await placeholder.press('Enter');semanticsRetries++;}
      }
      await page.getByRole('tab',{name:'Dimensões',exact:true}).click();
      await page.waitForTimeout(300);
      const before=await page.locator('body').ariaSnapshot();
      if(!before.includes(`${expected}/18 com reconstrução editorial documentada`))throw Error(`Missing coverage ${id}`);
      await page.mouse.move(width/2,500);
      for(let i=0;i<24;i++) {
        if(await page.getByRole('button',{name:/Respostas reconstruídas e fontes/}).count())break;
        await page.mouse.wheel(0,250);await page.waitForTimeout(150);
      }
      await page.getByRole('button',{name:/Respostas reconstruídas e fontes/}).first().click();
      await page.waitForTimeout(250);
      await page.mouse.move(width/2,500);await page.mouse.wheel(0,350);
      await page.waitForTimeout(250);
      const tree=await page.locator('body').ariaSnapshot();
      for(const text of ['Simulação editorial:','Resposta atribuída:']) {
        if(!tree.includes(text))throw Error(`Missing ${text}: ${id}`);
      }
      await fs.writeFile(`${out}/${id}-${width}.txt`,tree);
      await page.screenshot({path:`${out}/${id}-${width}.png`});
      for(let i=0;i<15;i++) {
        if(await page.getByRole('button',{name:'Abrir documento',exact:true}).count())break;
        await page.mouse.wheel(0,300);await page.waitForTimeout(150);
      }
      const sources=await page.locator('body').ariaSnapshot();
      await fs.writeFile(`${out}/${id}-${width}-sources.txt`,sources);
      await page.screenshot({path:`${out}/${id}-${width}-sources.png`});
      if(!sources.includes('Abrir documento'))throw Error(`Source button unreachable: ${id}`);
      report.push({id,width,reconstructedDimensions:expected,reconstructedAnswersVisible:true,sourceLink:true,semanticsRetries,errors});
      if(errors.length)throw Error(errors.join('\n'));
      await page.close();
    }
  }
} finally {
  await fs.writeFile(`${out}/browser.json`,JSON.stringify(report,null,2));
  await browser.close();
}
console.log(JSON.stringify(report));
