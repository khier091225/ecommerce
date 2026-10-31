# Fix: Bound extreme text sizes while keeping enlarged text usable

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/text-scale-factor
- **Needs new dependency**: none

## Why

The app adapts to large text but has no app-wide upper bound. Apply the article's TextScaler.clamp mechanism with a 2.0 cap, preserving the range already exercised by this project instead of shrinking everyone to the article's illustrative 1.1 value.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Production root and two widget-preview roots. Existing responsive text-scaling reads in intro/menu/grid/carousel/card are correct and remain in place. Do not replace local MediaQuery data or disable accessibility/reduced-motion flags.

### lib/main.dart:1704

```dart
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smooch Cafe',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: StartScreen(controller: controller),
  );
}
```

### lib/main.dart:2344

```dart
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide =
                constraints.maxWidth >= 850 &&
                MediaQuery.textScalerOf(context).scale(14) < 23;
            final compact = constraints.maxHeight < 740;
            final sceneHeight = wide
                ? 460.0
                : (constraints.maxHeight * (compact ? .34 : .39)).clamp(
                    160.0,
```

### lib/main.dart:2629

```dart
    builder: (context, constraints) {
      final wide =
          constraints.maxWidth >= 900 &&
          MediaQuery.textScalerOf(context).scale(14) <= 18;
      final padding = wide ? 24.0 : 16.0;
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final searchHeight = math.max(56.0, 14 * scale + 32);
      return ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          return Scaffold(
```

### lib/main.dart:3130

```dart
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: math.max(0, (width - 1160) / 2) + horizontalPadding,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, gridConstraints) {
          final gridWidth = gridConstraints.crossAxisExtent;
          final columns = scale > 1.3
              ? math.max(1, (gridWidth / (240 * scale)).floor()).clamp(1, 4)
              : gridWidth >= 1040
              ? 5
              : gridWidth >= 900
```

### lib/main.dart:3189

```dart
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Eyebrow('Smooch picks · Swipe to explore'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 186 * scale.clamp(1, 1.8),
                child: PageView.builder(
```

### lib/main.dart:3782

```dart
                  const SizedBox(height: 4),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(15) * 2.7,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
```

### lib/main.dart:7118

```dart
Widget splashPreview() => MaterialApp(
  theme: AppTheme.theme,
  home: StartScreen(
    controller: ShopController(repository: const MenuRepository()),
  ),
);

@Preview(name: 'Menu / phone', size: Size(390, 844))
@Preview(name: 'Menu / desktop', size: Size(1440, 1000))
Widget menuPreview() => MaterialApp(
  theme: AppTheme.theme,
  home: MenuScreen(
    controller: ShopController(repository: const MenuRepository()),
  ),
);

```

## The fix

Use the article's app-level clamp with this project's explicit maximum 2.0:

```dart
Widget cafeTextScaleBuilder(BuildContext context, Widget? child) {
  final media = MediaQuery.of(context);
  return MediaQuery(
    data: media.copyWith(
      textScaler: media.textScaler.clamp(
        minScaleFactor: 0.0,
        maxScaleFactor: 2.0,
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}
```

Set builder: cafeTextScaleBuilder on the production MaterialApp and both preview MaterialApp instances. If a builder has since been introduced, nest the same MediaQuery around its existing child instead of replacing its other responsibilities. Values at/below 2.0 preserve the user's scaler; values above 2.0 are capped. This is an explicit accessibility tradeoff, not proof that a layout is accessible. Keep all current adaptive layout rules and verify every ordering screen at the cap. Do not silently lower the cap or force text to 1.0 if a screen fails.

## Steps

1. Add the helper in lib/main.dart and wire the three app/preview builders.
2. Keep existing local textScaler reads unchanged and preserve the full MediaQuery data via copyWith.
3. Add test/app_text_scale_test.dart for incoming scale 1.0, 1.6, 2.0 and 3.0, with expected effective maxima 1.0, 1.6, 2.0 and 2.0.
4. Run actual-font layout checks at 320px and 2× through StartScreen, menu, details, bag, checkout, wallet, receipt, history and Cafe info. Any failure must be reported rather than fixed by dropping below 2×.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'cafeTextScaleBuilder|maxScaleFactor: 2.0' lib/main.dart` finds the helper and wiring.
- `rtk flutter test test/app_text_scale_test.dart` passes.
- All required actions remain reachable at 320px/2×; below-cap preferences, view insets and reduced-motion settings are unchanged.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not clamp to 1.0/1.1, reduce current large-text support, scale images globally or replace responsive layouts with fixed sizes.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.
- A required screen cannot remain usable at the 2.0 cap without a separate layout change. Report that screen instead of lowering the cap.

## When you're done

Tell the developer in two or three sentences: describe the 2× upper bound and preserved enlarged text, pointing to device text settings and a narrow checkout screen. Report the checks actually executed and any remaining device or hosting verification.
