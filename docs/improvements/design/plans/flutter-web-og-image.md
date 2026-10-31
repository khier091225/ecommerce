# Fix: Give shared app links a cafe preview card

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/flutter-web-og-image
- **Needs new dependency**: none

## Why

The web entry has a title/description but lacks social preview metadata. Add the article's Open Graph and X tags with a real absolute image URL and a 1200×630 card.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Only web/index.html supplies crawler-visible metadata. A repository-wide search of README, docs and web found no confirmed public deployment URL. The manifest's relative start_url is not a deployment origin.

### web/index.html:17

```html
  <base href="$FLUTTER_BASE_HREF">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Smooch Cafe — handcrafted sips, comforting bites, and a little happiness in every order.">
  <meta name="theme-color" content="#0A4952">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Smooch Cafe">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>Smooch Cafe</title>
  <link rel="manifest" href="manifest.json">
```

### web/manifest.json:1

```yaml
{
    "name": "Smooch Cafe",
    "short_name": "Smooch",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#0A4952",
    "theme_color": "#0A4952",
    "description": "Handcrafted sips and comforting bites from Smooch Cafe.",
    "orientation": "any",
    "prefer_related_applications": false,
    "icons": [
        {
```

## The fix

Required input before changing metadata: PUBLIC_SITE_URL, the verified public HTTPS base URL including any deployment subpath. Do not invent a domain, commit example.com, use localhost as production metadata, or substitute window.location in JavaScript (crawlers need static tags).

After the input exists, normalize it with new URL, remove query/hash, and ensure its pathname ends with '/'. Define absolute image URL as new URL('og-image.png', publicSiteUrl).href. Add static tags with these exact brand values; replace the two capitalized URL tokens with those validated values before saving:

```html
<meta property="og:title" content="Smooch Cafe">
<meta property="og:description" content="Handcrafted sips, comforting bites, and a little happiness in every order.">
<meta property="og:type" content="website">
<meta property="og:url" content="PUBLIC_SITE_URL">
<meta property="og:image" content="ABSOLUTE_OG_IMAGE_URL">
<meta property="og:image:width" content="1200">
<meta property="og:image:height" content="630">
<meta property="og:image:alt" content="Smooch Cafe — handcrafted sips and comforting bites">
<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="Smooch Cafe">
<meta name="twitter:description" content="Handcrafted sips, comforting bites, and a little happiness in every order.">
<meta name="twitter:image" content="ABSOLUTE_OG_IMAGE_URL">
```

Create web/og-image.png at exactly 1200×630 from existing brand assets. For a deterministic export, serve the repository locally and use a browser canvas with this recipe:

```js
const canvas = document.createElement('canvas');
canvas.width = 1200; canvas.height = 630;
const ctx = canvas.getContext('2d');
ctx.fillStyle = '#0A4952'; ctx.fillRect(0, 0, 1200, 630);
const logo = new Image(); logo.src = '/assets/images/logo.png'; await logo.decode();
ctx.drawImage(logo, 72, 64, 300, 168);
ctx.fillStyle = '#FFFFFF'; ctx.font = 'bold 64px sans-serif';
ctx.fillText('Smooch Cafe', 72, 340);
ctx.fillStyle = '#C0D8DA'; ctx.font = '30px sans-serif';
ctx.fillText('Handcrafted sips. Comforting bites.', 72, 404);
ctx.fillStyle = '#F04C45'; ctx.fillRect(72, 472, 110, 8);
const pngDataUrl = canvas.toDataURL('image/png');
```

Export those PNG bytes with the available browser/file tools; the data URL is not the og:image value. The source is local, same-origin so the canvas remains exportable. Keep the card plain and within its safe margins. This plan does not publish the site or create a paid service.

Concrete PNG export with browser tooling: create temporary docs/improvements/design/social-card-preview.html containing <!doctype html><html><body></body></html>, serve the repository with rtk proxy npx --yes http-server . -p 8082 -c-1, and open http://localhost:8082/docs/improvements/design/social-card-preview.html at 1200×630. Run the canvas recipe inside the page, await image decode/drawing, set document.body.style.margin = '0' and document.body.replaceChildren(canvas), then save a viewport screenshot to web/og-image.png. Do not screenshot browser chrome or a live app screen. Remove the temporary HTML afterwards. This exports a PNG without another app/build dependency.

## Steps

1. Obtain/verify PUBLIC_SITE_URL before any metadata edits. If it is unavailable, report this plan as waiting for hosting information; do not block other plans.
2. Generate the 1200×630 PNG from the provided recipe and save web/og-image.png.
3. Insert the static tags in web/index.html, substituting the validated HTTPS base/image URLs; preserve current title, description, manifest and base-href handling.
4. Build and inspect the generated index. Once deployed with authorization, verify the image URL returns a public image/png and social crawlers receive the tags without running Flutter.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'og:title|og:image|twitter:image|twitter:card' web/index.html` finds all required tags.
- `rtk rg -n 'PUBLIC_SITE_URL|ABSOLUTE_OG_IMAGE_URL|example.com|localhost' web/index.html` must find no placeholder/temporary-host metadata after implementation.
- `rtk flutter build web` succeeds; the exported image is 1200×630.
- The confirmed public page and absolute image URL are accessible without authentication. Deployment itself requires its own authorization.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not invent a hostname, publish a site, replace the logo, change app navigation, or put crawler tags only in Dart/JavaScript.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.
- PUBLIC_SITE_URL has not been supplied and verified, or the image cannot be exported without fetching unrelated assets.

## When you're done

Tell the developer in two or three sentences: describe the title/image people see when sharing the app link; report whether the public-host check could be completed. Report the checks actually executed and any remaining device or hosting verification.
