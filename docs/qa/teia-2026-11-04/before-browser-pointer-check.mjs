import fs from 'node:fs/promises';
const target = (await (await fetch('http://127.0.0.1:9244/json/list')).json()).find(x=>x.type==='page');
const ws = new WebSocket(target.webSocketDebuggerUrl);
await new Promise((res,rej)=>{ws.addEventListener('open',res);ws.addEventListener('error',rej)});
let seq=0;const pending=new Map();
ws.addEventListener('message',event=>{const msg=JSON.parse(event.data);if(msg.id){const task=pending.get(msg.id);pending.delete(msg.id);if(msg.error)task.reject(msg.error);else task.resolve(msg.result)}});
function cdp(method,params={}){const id=++seq;return new Promise((resolve,reject)=>{pending.set(id,{resolve,reject});ws.send(JSON.stringify({id,method,params}));})}
const pause=ms=>new Promise(resolve=>setTimeout(resolve,ms));
await cdp('Page.enable');
await cdp('Emulation.setDeviceMetricsOverride',{width:390,height:844,deviceScaleFactor:1,mobile:true});
await cdp('Emulation.setEmulatedMedia',{features:[{name:'prefers-reduced-motion',value:'reduce'}]});
await cdp('Page.navigate',{url:'http://127.0.0.1:8904/#/atlas?v=1&view=map&q=platao'});
await pause(1400);
let doc=await cdp('DOM.getDocument',{depth:-1,pierce:true});
function flatten(node){return [node,...(node.children??[]).flatMap(flatten),...(node.shadowRoots??[]).flatMap(flatten)]}
let nodes=flatten(doc.root);
const placeholder=nodes.find(n=>n.nodeName==='FLT-SEMANTICS-PLACEHOLDER');
if(placeholder){await cdp('DOM.focus',{nodeId:placeholder.nodeId});await cdp('Input.dispatchKeyEvent',{type:'keyDown',key:'Enter',code:'Enter',windowsVirtualKeyCode:13});await cdp('Input.dispatchKeyEvent',{type:'keyUp',key:'Enter',code:'Enter',windowsVirtualKeyCode:13});await pause(100);}
function attrs(n){const a={};for(let i=0;i<(n.attributes??[]).length;i+=2)a[n.attributes[i]]=n.attributes[i+1];return a}
async function semNodes(){doc=await cdp('DOM.getDocument',{depth:-1,pierce:true});return flatten(doc.root).filter(n=>attrs(n).role==='button').map(n=>({node:n,attrs:attrs(n)}))}
let buttons=await semNodes();

function named(buttons,name){return buttons.find(b=>b.node.children?.some(n=>n.nodeValue===name))?.node}
const teia=named(buttons,'Teia');
await cdp('DOM.focus',{nodeId:teia.nodeId});
await cdp('Input.dispatchKeyEvent',{type:'keyDown',key:'PageDown',code:'PageDown',windowsVirtualKeyCode:34});
await cdp('Input.dispatchKeyEvent',{type:'keyUp',key:'PageDown',code:'PageDown',windowsVirtualKeyCode:34});
await pause(300);
buttons=await semNodes();
const plato=named(buttons,'Platão');
const box=await cdp('DOM.getBoxModel',{nodeId:plato.nodeId});
const q=box.model.content;
const point={x:(q[0]+q[2]+q[4]+q[6])/4,y:(q[1]+q[3]+q[5]+q[7])/4};
await cdp('Input.dispatchMouseEvent',{type:'mouseMoved',...point});
await cdp('Input.dispatchMouseEvent',{type:'mousePressed',button:'left',clickCount:1,...point});
await cdp('Input.dispatchMouseEvent',{type:'mouseReleased',button:'left',clickCount:1,...point});
await pause(300);
const after=await cdp('Accessibility.getFullAXTree');
const screenshot=await cdp('Page.captureScreenshot',{format:'png'});
await fs.writeFile('docs/qa/teia-2026-11-04/after-selected-mobile.png',Buffer.from(screenshot.data,'base64'));
const names=after.nodes.map(n=>({name:n.name?.value,role:n.role?.value})).filter(n=>n.name);
await fs.writeFile('docs/qa/teia-2026-11-04/browser-pointer-report.json',JSON.stringify({point,quad:q,names},null,2));
console.log(JSON.stringify({point,quad:q,names}));
ws.close();
