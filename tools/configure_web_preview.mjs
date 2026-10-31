import {readFileSync, writeFileSync, existsSync} from 'node:fs';
import {fileURLToPath, pathToFileURL} from 'node:url';

const description = 'Handcrafted sips, comforting bites, and a little happiness in every order.';
const escape = value => value.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

export function configureSocialPreview(html, publicSiteUrl) {
  const site = new URL(publicSiteUrl);
  if (site.protocol !== 'https:' || site.username || site.password ||
      site.hostname === 'localhost' || !site.hostname.includes('.') ||
      /^127\.|^0\./.test(site.hostname)) {
    throw new Error('Use the public HTTPS hosting URL, not a local preview URL.');
  }
  site.search = ''; site.hash = '';
  if (!site.pathname.endsWith('/')) site.pathname += '/';
  const image = new URL('og-image.png', site).href;
  const tags = `<!-- SMOOCH_SOCIAL_PREVIEW -->
  <meta property="og:title" content="Smooch Cafe">
  <meta property="og:description" content="${description}">
  <meta property="og:type" content="website">
  <meta property="og:url" content="${escape(site.href)}">
  <meta property="og:image" content="${escape(image)}">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta property="og:image:alt" content="Smooch Cafe — handcrafted sips and comforting bites">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="Smooch Cafe">
  <meta name="twitter:description" content="${description}">
  <meta name="twitter:image" content="${escape(image)}">
  <!-- /SMOOCH_SOCIAL_PREVIEW -->`;
  if (!html.includes('</head>')) throw new Error('Missing HTML head.');
  const existing = /<!-- SMOOCH_SOCIAL_PREVIEW -->[\s\S]*?<!-- \/SMOOCH_SOCIAL_PREVIEW -->/;
  return existing.test(html) ? html.replace(existing, tags) : html.replace('</head>', `  ${tags}\n</head>`);
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  try {
    if (!process.argv[2]) throw new Error('Usage: node tools/configure_web_preview.mjs https://your-public-host/app/');
    const index = fileURLToPath(new URL('../web/index.html', import.meta.url));
    if (!existsSync(new URL('../web/og-image.png', import.meta.url))) throw new Error('Missing web/og-image.png.');
    writeFileSync(index, configureSocialPreview(readFileSync(index, 'utf8'), process.argv[2]));
    console.log('Social preview metadata configured. Rebuild web and verify the public image URL after deployment.');
  } catch (error) { console.error(error.message); process.exitCode = 1; }
}
