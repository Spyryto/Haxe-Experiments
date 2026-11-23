// Real browser test for HaxeUI on a high-density mobile viewport.
const { chromium } = require('playwright-core');
const fs = require('fs');

(async function () {
  const paths = ['/usr/bin/google-chrome','/usr/bin/chromium','/usr/bin/chromium-browser','/opt/google/chrome/chrome'];
  const exe = paths.find(p => fs.existsSync(p));
  if (!exe) throw Error('Chrome/Chromium not found');
  const browser = await chromium.launch({ executablePath: exe, headless: true, args: ['--no-sandbox'] });
  try {
    for (const width of [375, 320]) {
      const page = await browser.newPage({
        viewport: { width, height: 812 }, deviceScaleFactor: 3,
        isMobile: true, hasTouch: true
      });
      try {
        const errors = [];
        page.on('pageerror', e => errors.push(e.stack || String(e)));
        page.on('console', m => { if (m.type() === 'error') console.error('Console:',m.text()); });
        await page.goto('http://127.0.0.1:8765/experiments/001-haxeui/', {waitUntil:'networkidle'});
        await page.getByText('HaxeUI · esperimento 001').waitFor({state:'visible',timeout:12000});
        const metrics = await page.evaluate(() => {
          const host = document.querySelector('.haxeui-mount');
          const card = document.querySelector('.demo-card');
          const root = host.firstElementChild;
          const hostRect = host.getBoundingClientRect();
          const cardRect = card.getBoundingClientRect();
          const rootRect = root.getBoundingClientRect();
          return {
            dpr: window.devicePixelRatio, innerWidth:window.innerWidth,
            docScrollWidth:document.documentElement.scrollWidth,
            hostWidth:hostRect.width, hostScrollWidth:host.scrollWidth,
            cardRight:cardRect.right, rootRight:rootRect.right,
            rootBottom:rootRect.bottom, cardBottom:cardRect.bottom,
            rootWidth:rootRect.width,
          };
        });
        console.log('Layout metrics:', JSON.stringify({width,...metrics}));
        const tolerance = 3;
        if (metrics.docScrollWidth > metrics.innerWidth + tolerance) throw Error('Horizontal page overflow: '+JSON.stringify(metrics));
        if (metrics.rootRight > metrics.cardRight + tolerance) throw Error('HaxeUI clipped horizontally: '+JSON.stringify(metrics));
        if (metrics.rootBottom > metrics.cardBottom + tolerance) throw Error('HaxeUI clipped vertically: '+JSON.stringify(metrics));

        const label = page.getByText('Simula progresso +20%');
        const button = label.locator('xpath=../..');
        await button.click({timeout:10000});
        await page.getByText('PHP 8.4 · 20% (solo simulazione)').first().waitFor({state:'visible'});
        await page.getByText('Azzera').locator('xpath=../..').click({timeout:10000});
        await page.getByText('Pronto: nessun download reale.').first().waitFor({state:'visible'});
        await page.screenshot({path:`mobile-${width}.png`,fullPage:true});
        if (errors.length) throw Error(errors.join('\n'));
        console.log('PASS mobile', width, 'at 3x DPR: rendered, fits viewport, buttons work');
      } catch (e) {
        await page.screenshot({path:`browser-error-${width}.png`,fullPage:true});
        throw e;
      } finally { await page.close(); }
    }
  } finally { await browser.close(); }
})().catch(e => {console.error(e); process.exit(1);});
