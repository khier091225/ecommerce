# Fix: Hint that categories and featured picks can scroll sideways

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/shader-mask
- **Needs new dependency**: none

## Why

The category rail and featured carousel can contain more content beyond the visible edge. Apply the article's horizontal alpha fade without obscuring labels or changing taps and swipes.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Two horizontal browsing surfaces: category TabBar and featured PageView. TabBarView is page navigation, not a list to fade. No other custom horizontal lists exist.

### lib/main.dart:3170

```dart
class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({
    required this.controller,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
  });
  final ShopController controller;
  final PageController pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final featured = controller.products
        .where((item) => item.featured)
        .take(5)
        .toList();
```

### lib/main.dart:3203

```dart
              SizedBox(
                height: 186 * scale.clamp(1, 1.8),
                child: PageView.builder(
                  key: const Key('featured-carousel'),
                  controller: pages,
                  itemCount: featured.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    final product = featured[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
```

### lib/main.dart:3471

```dart
          ),
          const SizedBox(height: 8),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: TabBar(
              key: const Key('category-filters'),
              controller: tabs,
              isScrollable: true,
```

### lib/main.dart:3501

```dart
                fontWeight: FontWeight.w600,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 17),
              onTap: (index) => onCategory(ShopController.categories[index]),
              tabs: [
                for (final category in ShopController.categories)
                  Tab(key: Key('category-$category'), text: category),
              ],
            ),
          ),
        ],
      ),
```

## The fix

Use ShaderMask with BlendMode.dstIn, adapted from the article:

```dart
class HorizontalEdgeFade extends StatelessWidget {
  const HorizontalEdgeFade({super.key, required this.child,
    this.fadeStart = false, this.fadeEnd = true});
  final Widget child;
  final bool fadeStart;
  final bool fadeEnd;
  @override
  Widget build(BuildContext context) => ShaderMask(
    blendMode: BlendMode.dstIn,
    shaderCallback: (bounds) {
      final edge = bounds.width <= 0 ? 0.0 : math.min(12.0 / bounds.width, .1);
      return LinearGradient(
        begin: Alignment.centerLeft, end: Alignment.centerRight,
        colors: [fadeStart ? Colors.transparent : Colors.white, Colors.white,
          Colors.white, fadeEnd ? Colors.transparent : Colors.white],
        stops: [0, edge, 1 - edge, 1],
      ).createShader(bounds);
    },
    child: child,
  );
}
```

Wrap only each horizontal viewport, not headings, dots or search. Use ScrollMetricsNotification plus horizontal ScrollNotification to set fadeStart = extentBefore > 0 and fadeEnd = extentAfter > 0 after layout/on scroll; return false. Schedule state updates after the frame for metrics emitted during layout. Keep state in the wrapper; rebuild only when these booleans change. Ignore vertical notifications. If no horizontal extent, both fades are off. Preserve Material TabBar's controller and automatic visibility. Use at most the outer 12px, and no animation of the mask.

Use this notification wrapper to supply the two fade booleans without taking ownership of TabBar/PageView controllers. Wrap both viewport children with HorizontalScrollFade; this wrapper owns HorizontalEdgeFade internally:

```dart
class HorizontalScrollFade extends StatefulWidget {
  const HorizontalScrollFade({super.key, required this.child});
  final Widget child;
  @override
  State<HorizontalScrollFade> createState() => _HorizontalScrollFadeState();
}
class _HorizontalScrollFadeState extends State<HorizontalScrollFade> {
  bool start = false, end = false;
  bool wantedStart = false, wantedEnd = false;
  bool scheduled = false;
  void readMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.horizontal) return;
    wantedStart = metrics.extentBefore > .5;
    wantedEnd = metrics.extentAfter > .5;
    if (scheduled || (start == wantedStart && end == wantedEnd)) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!mounted || (start == wantedStart && end == wantedEnd)) return;
      setState(() { start = wantedStart; end = wantedEnd; });
    });
    WidgetsBinding.instance.scheduleFrame();
  }
  @override
  Widget build(BuildContext context) => NotificationListener<ScrollMetricsNotification>(
    onNotification: (notification) { readMetrics(notification.metrics); return false; },
    child: NotificationListener<ScrollNotification>(
      onNotification: (notification) { readMetrics(notification.metrics); return false; },
      child: HorizontalEdgeFade(fadeStart: start, fadeEnd: end, child: widget.child),
    ),
  );
}
```


## Steps

1. Add HorizontalEdgeFade and the horizontal-metrics wrapper in lib/main.dart.
2. Wrap the category rail and featured viewport, preserving keys/controllers.
3. Disable fades at exhausted edges and when all items fit.
4. Add test/horizontal_fade_test.dart for first/middle/last positions, all-tabs-fit width, category synchronization and Add hit testing.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'HorizontalEdgeFade|BlendMode.dstIn' lib/main.dart` finds the wrapper and masks.
- `rtk flutter test test/horizontal_fade_test.dart` passes; masks do not consume taps.
- At phone width, category labels remain readable and selected tabs still scroll fully into view.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not mask TabBarView, the grid, search or bag summary.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe the subtle edge hints and point to the category rail and featured picks. Report the checks actually executed and any remaining device or hosting verification.
