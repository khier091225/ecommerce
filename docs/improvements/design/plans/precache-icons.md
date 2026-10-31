# Fix: Prepare cafe images before their first appearance

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/precache-icons
- **Needs new dependency**: none

## Why

The intro warms a few menu images, but not the logo or Cafe info illustration. Complete the article's essential-first/background-rest strategy without delaying ORDER NOW or decoding every photo simultaneously.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Asset entry points: BrandLogo, ProductImage and CafeSection's landing1.png. ProductImage supplies grid, carousel, details and flight images. Material icons are bundled glyphs, not SVG files. Deduplicate the 92 products by image path.

### lib/main.dart:1720

```dart
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: width,
    height: width * .56,
    semanticLabel: 'Smooch Cafe',
    fit: BoxFit.contain,
  );
```

### lib/main.dart:1780

```dart
  Widget build(BuildContext context) => Image.asset(
    product.image,
    fit: fit,
    semanticLabel: product.name,
    errorBuilder: (context, error, trace) => const ColoredBox(
      color: AppColors.softTeal,
      child: Center(
        child: Icon(Icons.coffee_outlined, size: 48, color: AppColors.teal),
      ),
    ),
  );
```

### lib/main.dart:2176

```dart
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _syncMotion();
        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Decode the initial menu images while the intro is playing.
      final assets = <String>{
        'assets/images/Ice Blended Choco Hazelnut transparent.png',
        ...widget.controller.products.take(6).map((product) => product.image),
      };
      for (final asset in assets) {
        unawaited(precacheImage(AssetImage(asset), context));
      }
    });
  }

```

### lib/main.dart:6551

```dart
          child: SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.asset(
              'assets/images/landing1.png',
              fit: BoxFit.contain,
              semanticLabel: 'Smooch Cafe drinks and food',
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
```

## The fix

Replace the existing warmup loop with this article-based two-tier preparation:

```dart
Future<void> _preloadImages() async {
  final foreground = <String>{
    'assets/images/logo.png',
    'assets/images/Ice Blended Choco Hazelnut transparent.png',
    ...widget.controller.products.take(6).map((p) => p.image),
  };
  final background = <String>{
    'assets/images/landing1.png',
    ...widget.controller.products.map((p) => p.image),
  }..removeAll(foreground);
  for (final path in [...foreground, ...background]) {
    if (!mounted) return;
    await precacheImage(AssetImage(path), context,
      onError: (Object _, StackTrace? __) {});
    if (!foreground.contains(path)) {
      await Future<void>.delayed(const Duration(milliseconds: 16));
    }
  }
}
```

Call unawaited(_preloadImages()) once after the first frame. Never await it before enabling ORDER NOW. Keep default image-cache limits; warming does not guarantee all photos stay resident. Use the same AssetImage keys/configuration as display. Do not add resize keys only to preloading. Preserve ProductImage's fallback. There are no SVGs to justify flutter_svg.

## Steps

1. Replace the inline warmup set/loop with _preloadImages in _StartScreenState.
2. Warm essentials first and the deduplicated remainder serially in the background; stop on disposal and tolerate unavailable assets.
3. Profile first entry, Cafe info and category changes; keep cache limits and navigation responsiveness.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n '_preloadImages|precacheImage' lib/main.dart` finds the helper and call.
- A rapid ORDER NOW tap navigates even while image loading is delayed.
- Compare first image appearance and memory use on a constrained device; do not claim permanent caching of every photo.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not add flutter_svg, change image files/cache limits, or block the intro button.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe earlier image readiness and point to first entry into the menu and Cafe info. Report the checks actually executed and any remaining device or hosting verification.
