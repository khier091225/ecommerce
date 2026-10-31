# Fix: Keep the end of scrolling content clear of system controls

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/safe-area-replacement
- **Needs new dependency**: none

## Why

Some scrolling screens use fixed end spacing instead of the device's bottom inset. Apply the article's dynamic spacing only where content reaches the system bar, avoiding double padding above existing footers.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

All vertical surfaces: StartScreen; category pages; Cafe info; product details; empty/filled bag; history error, empty and list states; map-picker controls; checkout; wallet; receipt. Fixed product, bag, map, checkout, wallet and receipt footers already reserve safe bottom space. Wide menu/history/Cafe info with an empty bag have no bottom footer and need the dynamic inset.

### lib/main.dart:2344 — StartScreen SafeArea

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
                    340.0,
                  );
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
```

### lib/main.dart:2698 — conditional menu footer

```dart
            bottomNavigationBar: (wide && shop.cartCount == 0)
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (shop.cartCount > 0)
                        _BagSummary(
                          controller: shop,
                          onPressed: openCart,
                          bottomSafeArea: wide,
                        ),
                      if (!wide)
                        NavigationBar(
                          selectedIndex: tab,
                          onDestinationSelected: selectTab,
                          height: 72,
                          destinations: const [
                            NavigationDestination(
                              icon: Icon(Icons.grid_view_outlined),
                              selectedIcon: Icon(
                                Icons.grid_view_rounded,
                                color: AppColors.dark,
                              ),
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

### lib/main.dart:3090

```dart
            ),
          )
        else
          _ProductGridSliver(
            products: products,
            controller: controller,
            width: width,
            horizontalPadding: horizontalPadding,
          ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Text(
                'A little Smooch goes a long way.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
```

### lib/main.dart:3906

```dart
    body: SingleChildScrollView(
      child: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
```

### lib/main.dart:4092

```dart
              child: SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'A little empty, for now.',
                  message:
                      'Your next favorite sip or bite is waiting on the menu.',
                  action: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Explore the menu'),
```

### lib/main.dart:4105

```dart
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ContentWidth(
                    maxWidth: 760,
```

### lib/main.dart:4337

```dart
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Your orders', style: TextStyle(fontSize: 16)),
    ),
    body: _OrderHistoryContent(
      controller: controller,
      onBrowseMenu: () => Navigator.pop(context),
    ),
  );
```

### lib/main.dart:4369

```dart
            child: SingleChildScrollView(
              child: EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Orders are unavailable.',
                message: controller.historyError!,
                action: OutlinedButton(
```

### lib/main.dart:4388

```dart
            child: SingleChildScrollView(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet.',
                message: 'Your saved orders will appear here.',
                action: FilledButton(
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

### lib/main.dart:4897

```dart
    bottomNavigationBar: ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 640,
              maxHeight: MediaQuery.sizeOf(context).height * .45,
            ),
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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Form(
                key: form,
                autovalidateMode: attemptedSubmit
```

### lib/main.dart:5801

```dart
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_WalletDemoColors.deepBlue, _WalletDemoColors.blue],
```

### lib/main.dart:6270

```dart
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
```

## The fix

Add the article's helper in lib/main.dart:

```dart
class BottomPadding extends StatelessWidget {
  const BottomPadding({super.key, this.minimum = 16});
  final double minimum;
  static double of(BuildContext context, {double minimum = 16}) =>
      math.max(MediaQuery.viewPaddingOf(context).bottom, minimum);
  @override
  Widget build(BuildContext context) =>
      SizedBox(height: of(context, minimum: minimum));
}
```

For StartScreen keep top/left/right protection with SafeArea(bottom: false), and move only bottom protection into the scrolling child's end using BottomPadding.of(context, minimum: 20). Preserve bounded-height centering and existing 20px top spacing; never put Expanded in the unbounded scrolling axis.

For menu content calculate: final endInset = wide && shop.cartCount == 0 ? BottomPadding.of(context, minimum: 0) : 0.0; in the Scaffold builder. Pass this double to category pages and history content. Replace the final category/Cafe footer's bottom value with math.max(32.0, endInset), and history list bottom padding with math.max(24.0, endInset), retaining their other padding values. Standalone history computes BottomPadding.of(context, minimum: 24). Embedded history above NavigationBar/bag footer uses only its existing spacing. Apply the applicable inset to history error/empty scrolling states too.

Product details, filled cart, checkout, wallet and receipt retain their fixed bottom SafeArea and existing end spacing: their body is above that footer. An empty cart has no footer; add BottomPadding.of(context, minimum: 24) at its scrollable end. Keep the map footer's outer SafeArea protecting its actions.

For the StartScreen insertion use a local final bottomSpace = BottomPadding.of(context, minimum: 20). Give its SingleChildScrollView padding: EdgeInsets.only(bottom: bottomSpace), change the ConstrainedBox minimum height to math.max(0.0, constraints.maxHeight - bottomSpace), and change ContentWidth's vertical 20px padding to EdgeInsets.fromLTRB(24, 20, 24, 0). This keeps one bottom allowance rather than stacking two. Add an optional double endInset = 0 parameter to _MenuCategoryPage. In _OrderHistoryContent use an optional double? endInset: null means a standalone unprotected history screen; an explicit zero means the parent footer already protects the viewport. The effective history bottom padding is endInset == null ? BottomPadding.of(context, minimum: 24) : math.max(24.0, endInset!). Both empty/error scroll states receive that same bottom padding.

## Steps

1. Add BottomPadding in the shared-widgets section of lib/main.dart.
2. Separate StartScreen's scrollable bottom spacing from top SafeArea.
3. Route the calculated bottom inset into category/history content and apply it once to wide menu and Cafe info. Handle standalone history and empty bag.
4. Leave protected fixed footers unchanged and document why they are excluded.
5. Add test/scroll_insets_test.dart with bottom insets 0, 24 and 48, empty/nonempty bag, narrow/wide menu and standalone history.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'class BottomPadding|viewPaddingOf|endInset' lib/main.dart` finds the helper and inset routing.
- `rtk flutter test test/scroll_insets_test.dart` passes: final content is reachable with 48px inset, without a second inset above protected footers.
- On Android gesture and three-button navigation, reach the last product and Cafe info menu button without overlap.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not remove SafeArea from fixed actions or top status-bar protection.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe the comfortable end spacing and point to the last product on a device with system navigation controls. Report the checks actually executed and any remaining device or hosting verification.
