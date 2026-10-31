# Fix: Show the cafe while the browser loads the app

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/flutter-web-loading-progress
- **Needs new dependency**: none

## Why

The web entry body contains only the Flutter bootstrap script, so the first load is blank. Follow the article's lightweight HTML and real boot-stage progress before the Flutter StartScreen appears.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

One entry page, no custom web/flutter_bootstrap.js or web/style.css in this revision. These web files are not application Dart and do not affect the single-main.dart requirement.

### web/index.html:34

```html
  <link rel="manifest" href="manifest.json">
</head>
<body>
  <!--
    You can customize the "flutter_bootstrap.js" script.
    This is useful to provide a custom configuration to the Flutter loader
    or to give the user feedback during the initialization process.

    For more details:
    * https://docs.flutter.dev/platform-integration/web/initialization
  -->
  <script src="flutter_bootstrap.js" async></script>
</body>
```

### web/index.html:24

```html
  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Smooch Cafe">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>Smooch Cafe</title>
```

## The fix

Add lightweight markup before the existing bootstrap script, link style.css in the head, and use the article's loader milestones. New web/style.css must apply positioning to #smooch-boot only, never body flex layout that could constrain Flutter:

```html
<div id="smooch-boot" role="status" aria-live="polite">
  <strong>Smooch Cafe</strong>
  <p>Getting your favorites ready…</p>
  <div class="boot-track"><div class="boot-bar"></div></div>
</div>
<script src="flutter_bootstrap.js" async></script>
```
```css
html, body { margin: 0; min-height: 100%; background: #0A4952; }
#smooch-boot { position: fixed; inset: 0; display: flex; flex-direction: column;
  align-items: center; justify-content: center; padding: 24px; box-sizing: border-box;
  background: #0A4952; color: #fff; font: 16px system-ui, sans-serif; }
#smooch-boot strong { font-size: 26px; }
#smooch-boot p { color: #C0D8DA; }
.boot-track { width: 180px; height: 6px; overflow: hidden; border-radius: 9px; background: #39747C; }
.boot-bar { width: 0; height: 100%; background: #F04C45; transition: width 180ms ease; }
@media (prefers-reduced-motion: reduce) { .boot-bar { transition: none; } }
```
```js
{{flutter_js}}
{{flutter_build_config}}
const boot = document.getElementById('smooch-boot');
const bar = boot?.querySelector('.boot-bar');
const progress = value => { if (bar) bar.style.width = value + '%'; };
progress(20);
_flutter.loader.load({
  onEntrypointLoaded: async engineInitializer => {
    try {
      progress(50);
      const runner = await engineInitializer.initializeEngine();
      progress(80);
      await runner.runApp();
      progress(100);
      boot?.remove();
    } catch (error) {
      if (boot) boot.textContent = 'Could not open Smooch Cafe. Please refresh to try again.';
      console.error(error);
    }
  },
});
```

The percentages represent milestones, not downloaded-byte percentages. Keep the Flutter placeholders literal in web/flutter_bootstrap.js; Flutter expands them at build time. Do not load a large image, font or remote resource for this temporary view.

## Steps

1. Add the markup/link to web/index.html without duplicating the bootstrap script or changing the base-href token.
2. Create web/style.css and web/flutter_bootstrap.js with the exact scoped CSS and milestone loader.
3. Check the built app under localhost and a non-root base path; the boot view must be removed after runApp, and StartScreen still appears first.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'smooch-boot|style.css' web/index.html` finds the loader/link.
- `rtk rg -n 'onEntrypointLoaded|initializeEngine|runApp|boot\?\.remove' web/flutter_bootstrap.js` finds each milestone and removal.
- `rtk flutter build web` succeeds. In a throttled fresh browser load, the branded HTML appears before Flutter; after loading it cannot cover or intercept ORDER NOW.
- Test reduced motion and engine initialization failure. No byte-download claim is shown.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not edit generated build/web, change Dart startup/navigation, or add remote boot assets.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe the branded loading feedback and tell the developer to open a fresh web session on a throttled connection. Report the checks actually executed and any remaining device or hosting verification.
