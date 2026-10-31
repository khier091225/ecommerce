# Fix: Make browser and desktop page changes immediate

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/web-page-transitions
- **Needs new dependency**: none

## Why

Every platform currently gets the same animated route builder. Apply the article's platform split: preserve native phone motion and disable page transitions on web/desktop.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where



### lib/main.dart:57

```dart
    fontFamily: 'Montserrat',
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const _CafePageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: AppColors.canvas,
```

### lib/main.dart:156

```dart
class _CafePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CafePageTransitionsBuilder();

  @override
  Duration get transitionDuration => StartScreen.transitionDuration;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 450);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    if (route.settings.name == MenuScreen.routeName) {
      return _MenuTransition(animation: animation, child: child);
    }
    return const FadeUpwardsPageTransitionsBuilder().buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

```

### lib/main.dart:2227

```dart
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: MenuScreen.routeName),
          builder: (_) => MenuScreen(controller: widget.controller),
        ),
      );
    } finally {
      if (mounted) {
```

### lib/main.dart:2427

```dart
class _MenuTransition extends StatelessWidget {
  const _MenuTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: RepaintBoundary(child: child),
    builder: (context, menu) {
      // Finish covering the splash before the menu appears, avoiding ghosted
      // cup/text over the product grid during the MaterialPageRoute transition.
      final cover = const Interval(
        0,
        .4,
        curve: Curves.easeInOutCubic,
      ).transform(animation.value);
      final reveal = const Interval(
        .4,
        1,
```

## The fix

Add the article's no-transition builder:

```dart
class _NoPageTransitionsBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionsBuilder();
  @override
  Duration get transitionDuration => Duration.zero;
  @override
  Duration get reverseTransitionDuration => Duration.zero;
  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext context,
      Animation<double> animation, Animation<double> secondaryAnimation,
      Widget child) => child;
}
```

Replace only AppTheme.theme's builders map entries with:

```dart
for (final platform in TargetPlatform.values)
  platform: kIsWeb ||
          const [TargetPlatform.macOS, TargetPlatform.windows,
            TargetPlatform.linux, TargetPlatform.fuchsia].contains(platform)
      ? const _NoPageTransitionsBuilder()
      : const _CafePageTransitionsBuilder(),
```

Native Android/iOS retain the existing cafe transition, including StartScreen to menu and reduced-motion behavior. Mobile browsers also use no page transition because kIsWeb wins. This changes route motion only: category swipes, featured carousel, bag flight and cup animation remain as they are. Verify that _MenuTransition's temporary interaction suppression is bypassed safely on web and route animation completion still enables controls on native phones. Do not replace Navigator.push or MaterialPageRoute.

## Steps

1. Add _NoPageTransitionsBuilder in lib/main.dart next to the existing builder.
2. Apply the platform map above without changing native _CafePageTransitionsBuilder code.
3. Add test/platform_route_motion_test.dart for native Android/iOS and desktop targets; test web via browser build because kIsWeb is a compile-time constant.
4. Check instant browser entry and Back, and the native 600ms entry transition with usable menu controls after completion.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n '_NoPageTransitionsBuilder|kIsWeb \|\|' lib/main.dart` finds the platform split.
- `rtk flutter test test/platform_route_motion_test.dart` passes.
- `rtk flutter build web` succeeds; navigating menu/details/bag/checkout has no mobile route movement in the browser.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not alter category/featured/flight animations, replace routes, or remove smooth native StartScreen-to-menu motion.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe immediate browser/desktop navigation and preserved phone transitions; point to opening product details on each. Report the checks actually executed and any remaining device or hosting verification.
