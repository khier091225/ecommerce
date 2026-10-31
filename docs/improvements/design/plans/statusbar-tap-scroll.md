# Fix: Restore the native iPhone tap-to-top gesture

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/statusbar-tap-scroll
- **Needs new dependency**: none

## Why

Menu, history and Cafe info use custom vertical scroll controllers that are not provided above their Scaffold. Apply the article's PrimaryScrollController pattern with the active destination/category controller.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

One owning Scaffold and three controller groups: categoryScrolls (one per category), orderScroll and cafeScroll. Featured PageController is horizontal and excluded. Other screens use no custom vertical controller and keep Flutter's built-in route-level behavior.

### lib/main.dart:2490

```dart
class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int tab = 0;
  final cartFlightTarget = GlobalKey();
  final search = TextEditingController();
  final orderScroll = ScrollController();
  final cafeScroll = ScrollController();
  final categoryScrolls = List.generate(
    ShopController.categories.length,
    (_) => ScrollController(),
  );
  final featuredPages = PageController(viewportFraction: .9);
  late TabController categoryTabs;
  bool? reducedCategoryMotion;
  int featuredIndex = 0;
```

### lib/main.dart:2636

```dart
      return ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
```

### lib/main.dart:2769

```dart
                            key: const Key('menu-category-pages'),
                            controller: categoryTabs,
                            physics: const PageScrollPhysics(),
                            children: [
                              for (
                                var index = 0;
                                index < ShopController.categories.length;
                                index++
                              )
                                _MenuCategoryPage(
                                  key: PageStorageKey(
                                    'menu-category-${ShopController.categories[index]}',
                                  ),
                                  category: ShopController.categories[index],
                                  products: shop.productsForCategory(
                                    ShopController.categories[index],
                                  ),
                                  controller: shop,
                                  scroll: categoryScrolls[index],
                                  width: constraints.maxWidth,
                                  horizontalPadding: padding,
                                  wide: wide,
```

### lib/main.dart:2844

```dart
                      ),
                      Expanded(
                        child: _OrderHistoryContent(
                          controller: shop,
                          onBrowseMenu: () => selectTab(0),
                          scroll: orderScroll,
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    key: const PageStorageKey('menu-tab-cafe'),
                    controller: cafeScroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
```

### lib/main.dart:2933

```dart
    return CustomScrollView(
      key: PageStorageKey('products-$category'),
      controller: scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
```

### lib/main.dart:4400

```dart
        : ListView.builder(
            key: const PageStorageKey('order-history-list'),
            controller: scroll,
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: controller.orders.length,
```

## The fix

Add this getter in _MenuScreenState:

```dart
ScrollController get activePrimaryScroll => switch (tab) {
  0 => categoryScrolls[categoryTabs.index],
  1 => orderScroll,
  _ => cafeScroll,
};
```

Inside the existing ListenableBuilder, wrap the returned menu Scaffold:

```dart
return PrimaryScrollController(
  controller: activePrimaryScroll,
  child: Scaffold(
    // retain the existing Scaffold and explicit scroll controllers
  ),
);
```

The comment above is an insertion diagram, not a replacement of Scaffold contents. Retain the complete current Scaffold verbatim inside the wrapper. The provided controller must be the SAME object attached to the currently visible vertical scrollable. Rebuild the wrapper on destination and category changes, as the existing state listeners already do. Never provide featuredPages as the primary controller. Do not force primary:true onto a scrollable that also has an explicit controller. For empty/error history, ensure the visible fallback either uses orderScroll or inherits the active primary controller exactly once; no hidden list may share that attachment.

## Steps

1. Add the getter and PrimaryScrollController wrapper in lib/main.dart.
2. Preserve existing controller construction/disposal and explicit scroll assignments.
3. Add test/ios_primary_scroll_test.dart with iOS target to verify that the PrimaryScrollController above Scaffold equals the visible category/history/Cafe controller and is never attached twice.
4. On physical iPhone, scroll each destination then tap the status bar; also test after swiping categories and returning from a receipt.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'activePrimaryScroll|PrimaryScrollController\(' lib/main.dart` finds the getter/wrapper.
- `rtk flutter test test/ios_primary_scroll_test.dart` passes without multiple-position errors.
- The iPhone status-bar tap scrolls only the visible destination to zero; hidden categories retain their own positions.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not replace ScrollControllers, wrap the horizontal PageController, or change existing destination retention.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe restored iPhone tap-to-top and point to tapping the clock while browsing a scrolled category. Report the checks actually executed and any remaining device or hosting verification.
