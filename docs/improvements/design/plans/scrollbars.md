# Fix: Show a single scroll-position indicator on long pages

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/scrollbars
- **Needs new dependency**: none

## Why

Desktop gets default Flutter scrollbars, while native phone scrolling has none. Use the article's app-wide scroll behavior to provide one scrollbar per supported vertical viewport without stacking manual and automatic bars.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Vertical viewports: intro; category pages; Cafe info; details; bag empty/list; history error/empty/list; bounded map controls; checkout; wallet; receipt. Category TabBar, PageView/TabBarView and single-line EditableText must remain without added scrollbar thumbs. The existing ScrollConfiguration.copyWith changes dragDevices only and should delegate to the root behavior.

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

### lib/main.dart:2357

```dart
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: ContentWidth(
                  padding: const EdgeInsets.symmetric(
```

### lib/main.dart:2765

```dart
                              PointerDeviceKind.stylus,
                            },
                          ),
                          child: TabBarView(
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
```

### lib/main.dart:2854

```dart
                : CustomScrollView(
                    key: const PageStorageKey('menu-tab-cafe'),
                    controller: cafeScroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: ContentWidth(
```

### lib/main.dart:2933

```dart
    return CustomScrollView(
      key: PageStorageKey('products-$category'),
      controller: scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (showFeatured) ...[
```

### lib/main.dart:3906

```dart
    body: SingleChildScrollView(
      child: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
```

### lib/main.dart:4092

```dart
              child: SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'A little empty, for now.',
                  message:
```

### lib/main.dart:4105

```dart
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ContentWidth(
```

### lib/main.dart:4369

```dart
            child: SingleChildScrollView(
              child: EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Orders are unavailable.',
                message: controller.historyError!,
```

### lib/main.dart:4388

```dart
            child: SingleChildScrollView(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet.',
                message: 'Your saved orders will appear here.',
```

### lib/main.dart:4400

```dart
        : ListView.builder(
            key: const PageStorageKey('order-history-list'),
            controller: scroll,
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
```

### lib/main.dart:4908

```dart
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
```

### lib/main.dart:5125

```dart
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
```

### lib/main.dart:5801

```dart
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
```

### lib/main.dart:6270

```dart
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
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

Use the article's automatic approach rather than wrapping every page manually. Add this behavior in lib/main.dart:

```dart
class AlwaysScrollbarBehavior extends MaterialScrollBehavior {
  const AlwaysScrollbarBehavior();
  @override
  Widget buildScrollbar(BuildContext context, Widget child,
      ScrollableDetails details) => Scrollbar(
    controller: details.controller,
    child: child,
  );
}
```

Set scrollBehavior: const AlwaysScrollbarBehavior() on the production MaterialApp and both splash/menu preview MaterialApp instances. Keep default auto-hiding thumb behavior; do not force thumbVisibility true on mobile. Existing explicit vertical controllers flow through details.controller; do not replace them or attach a second controller. This override replaces the default desktop scrollbar builder, so do not additionally wrap pages in Scrollbar. Verify the local copyWith drag-device wrappers still delegate buildScrollbar. Flutter's page/field-specific overrides intentionally suppress unsuitable scrollbars; do not fight them.

## Steps

1. Add AlwaysScrollbarBehavior in lib/main.dart and set it on the three app/preview MaterialApp configurations.
2. Preserve existing drag devices and all explicit controllers; do not add per-page Scrollbar wrappers.
3. Add test/scrollbar_behavior_test.dart exercising phone/desktop category, Cafe info, history and the map's bounded controls.
4. Check that only vertical scrollers get a thumb and that nested/page scroll gestures remain correct.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'AlwaysScrollbarBehavior|buildScrollbar' lib/main.dart` finds the class and app/preview wiring.
- `rtk flutter test test/scrollbar_behavior_test.dart` passes without multiple-position controller errors.
- On desktop there is one thumb, not two; on a phone it appears while scrolling and does not cover essential actions.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not make every thumb permanently visible, wrap page-view swipes in a new scrollbar, or replace controllers.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe a consistent scroll-position hint and point to a long menu category on phone and desktop. Report the checks actually executed and any remaining device or hosting verification.
