# Fix: Return to the top by tapping the active destination

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/bottom-nav-reselect
- **Needs new dependency**: none

## Why

The bottom/header navigation always assigns the selected tab, even when it is already active. Use the article's reselect branch with existing scroll controllers, and focus menu search on a second tap at the top.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where



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
  ShopController get shop => widget.controller;

  @override
```

### lib/main.dart:2535

```dart
  }

  @override
  void dispose() {
    search.dispose();
    if (reducedCategoryMotion != null) {
      shop.removeListener(syncCategoryTabs);
      categoryTabs.removeListener(onCategoryPageChanged);
      categoryTabs.dispose();
    }
    featuredPages.dispose();
    orderScroll.dispose();
    cafeScroll.dispose();
    for (final scroll in categoryScrolls) {
      scroll.dispose();
    }
    super.dispose();
  }
```

### lib/main.dart:2562

```dart
  void selectTab(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => tab = value);
  }

```

### lib/main.dart:2670

```dart
                            onPressed: () => selectTab(entry.key),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                              backgroundColor: tab == entry.key
                                  ? AppColors.white.withValues(alpha: .12)
```

### lib/main.dart:2710

```dart
                        NavigationBar(
                          selectedIndex: tab,
                          onDestinationSelected: selectTab,
                          height: 72,
                          destinations: const [
                            NavigationDestination(
                              icon: Icon(Icons.grid_view_outlined),
```

### lib/main.dart:2740

```dart
                        ),
                    ],
                  ),
            body: tab == 0
                ? Column(
                    children: [
                      Material(
                        color: AppColors.canvas,
                        child: MenuFilters(
                          controller: shop,
                          search: search,
                          onQuery: queryChanged,
                          onCategory: selectCategory,
                          tabs: categoryTabs,
                          horizontalPadding: padding,
```

### lib/main.dart:3414

```dart
class MenuFilters extends StatelessWidget {
  const MenuFilters({
    super.key,
    required this.controller,
    required this.search,
    required this.onQuery,
    required this.onCategory,
    required this.tabs,
    required this.horizontalPadding,
    required this.searchHeight,
  });

  final ShopController controller;
  final TextEditingController search;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final TabController tabs;
  final double horizontalPadding;
  final double searchHeight;

  @override
  Widget build(BuildContext context) => ContentWidth(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: searchHeight,
            child: TextField(
              key: const Key('menu-search'),
              controller: search,
              onChanged: onQuery,
```

## The fix

Keep controllers owned by _MenuScreenState. Add final menuSearchFocus = FocusNode(); dispose it with search. Give MenuFilters an optional FocusNode? searchFocus, pass menuSearchFocus from the menu, and set focusNode: searchFocus on its TextField.

Replace selectTab with the article's behavior adapted to the active category:

```dart
void selectTab(int value) {
  if (value == tab) {
    final scroller = switch (tab) {
      0 => categoryScrolls[categoryTabs.index],
      1 => orderScroll,
      _ => cafeScroll,
    };
    if (scroller.hasClients && scroller.offset > 0) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (MediaQuery.disableAnimationsOf(context)) {
        scroller.jumpTo(0);
      } else {
        unawaited(scroller.animateTo(0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic));
      }
    } else if (tab == 0) {
      menuSearchFocus.requestFocus();
    }
    return;
  }
  FocusManager.instance.primaryFocus?.unfocus();
  setState(() => tab = value);
}
```

This handles both the phone NavigationBar and existing desktop header buttons because they share selectTab. A category tab tap is a different interaction: retain its active selection and do not reset category/search/sort. Returning from Cafe info to the menu is still a destination change, not a reselect.

## Steps

1. Add/dispose menuSearchFocus in lib/main.dart and thread the optional focus node into MenuFilters.
2. Replace selectTab with the exact branch above, reusing existing controllers and honoring reduced motion.
3. Add test/navigation_reselect_test.dart for menu/category, nonempty history and Cafe info: reselect from a deep offset, then menu reselect at offset zero focuses search.
4. Check a normal tab change still retains each destination's previous browsing position.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'value == tab|menuSearchFocus|Duration\(milliseconds: 300\)' lib/main.dart` finds the branch/focus wiring.
- `rtk flutter test test/navigation_reselect_test.dart` passes; active category, query and sort survive reselect.
- An empty history/no-attached-controller state does not throw.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not replace the navigation bar, reset filters, recreate ScrollControllers in build, or change category-tab reselect semantics.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe tap-again-to-top and point to scrolling the menu then tapping Our menu twice. Report the checks actually executed and any remaining device or hosting verification.
