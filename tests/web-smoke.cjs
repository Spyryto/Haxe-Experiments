// A real browser smoke test, not just a successful Haxe compilation.
const { chromium } = require('playwright-core');
const fs = require('fs');

(async function () {
  const paths = ['/usr/bin/google-chrome', '/usr/bin/chromium', '/usr/bin/chromium-browser', '/opt/google/chrome/chrome'];
  const exe = paths.find((p) => fs.existsSync(p));
  console.log('Chrome executable:', exe || 'not found');
  if (!exe) throw Error('No Chromium/Chrome installed on the GitHub Actions runner');
  const browser = await chromium.launch({ executablePath: exe, headless: true, args: ['--no-sandbox'] });
  try {
    const page = await browser.newPage({ viewport: { width: 375, height: 812 }, deviceScaleFactor: 2, isMobile: true, hasTouch: true });
    const errors = [];
    page.on('pageerror', err => { console.error('JS page error:', err.stack || String(err)); errors.push(String(err)); });
    page.on('console', msg => console.log('Console:', msg.type(), msg.text()));
    page.on('response', response => { if (response.status() >= 400) console.error('HTTP:', response.status(), response.url()); });
    await page.goto('http://127.0.0.1:8765/experiments/001-haxeui/', {waitUntil: 'networkidle'});
    const app = page;
    try {
      await app.getByText('HaxeUI · esperimento 001').waitFor({state:'visible',timeout:12000});
    } catch (e) {
      console.error('Page HTML (first 5000 chars):', (await page.locator('body').innerHTML()).slice(0,5000));
      await page.screenshot({path:'browser-error.png',fullPage:true});
      throw e;
    }
    const el = app.getByText('Simula progresso +20%');
    const bounds = await el.boundingBox();
    console.log('Button coordinates:', bounds);
    if (!bounds || bounds.width <= 0 || bounds.height <= 0) throw Error('Button has no visible bounds');
    console.log('Text wrapper:', await el.evaluate(node => node.parentElement?.outerHTML.slice(0, 2200)));
    // HaxeUI's text child does not necessarily handle pointer events.
    // Interact with the actual button parent, not the label.
    const button = el.locator('xpath=../..');
    console.log('Actual button:', await button.evaluate(node => node.outerHTML.slice(0, 1200)));
    await button.click({ timeout: 10000 });
    await iframe.getByText('PHP 8.4 · 20% (solo simulazione)').waitFor({state:'visible'});
    if (errors.length) throw Error(errors.join('\n'));
    console.log('BROWSER SMOKE TEST SUCCESS: UI visible, interactive, no JS exceptions.');
  } finally { await browser.close(); }
})().catch(e => {console.error(e); process.exit(1);});
