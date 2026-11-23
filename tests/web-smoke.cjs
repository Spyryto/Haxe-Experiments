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
    const iframe = page.frameLocator('iframe');
    try {
      await iframe.getByText('HaxeUI · esperimento 001').waitFor({state:'visible',timeout:12000});
    } catch (e) {
      const f = page.frames().find(x => x.url().includes('/app.html'));
      console.error('Iframe:', f?.url());
      console.error('Iframe HTML (first 5000 chars):', (await f?.locator('body').innerHTML())?.slice(0,5000));
      await page.screenshot({path:'browser-error.png',fullPage:true});
      throw e;
    }
    await iframe.getByText('Simula progresso +20%').click();
    await iframe.getByText('PHP 8.4 · 20% (solo simulazione)').waitFor({state:'visible'});
    if (errors.length) throw Error(errors.join('\n'));
    console.log('BROWSER SMOKE TEST SUCCESS: UI visible, interactive, no JS exceptions.');
  } finally { await browser.close(); }
})().catch(e => {console.error(e); process.exit(1);});
