# Fix: Give each browser page a useful tab title

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/browser-tab-title
- **Needs new dependency**: none

## Why

All routes and menu destinations currently keep the static Smooch Cafe browser title. Apply the article's single title wrapper, adapted to this app's Navigator and tab state instead of introducing a router package.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Live navigation paths: Start → Menu; Menu/Details → Bag; Featured/Grid → Details; Bag → Checkout; Checkout → Map or Wallet; Checkout → Confirmation; History → saved receipt. Menu also changes Our menu/Order history/Cafe info without pushing a route. Standalone OrderHistoryScreen exists but is not pushed by the current production flow; if used, name that route /history.

### lib/main.dart:1684

```dart
class _MiniShopAppState extends State<MiniShopApp> {
  late final ShopController controller;

  @override
  void initState() {
    super.initState();
    controller = ShopController(
      repository: const MenuRepository(),
      orderStore: widget.orderStore,
    );
    unawaited(controller.restoreOrders().catchError((Object _) {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smooch Cafe',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: StartScreen(controller: controller),
  );
}

// ============================================================
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
```

### lib/main.dart:2557

```dart
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CartScreen(controller: shop)),
    );
  }

  void selectTab(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => tab = value);
```

### lib/main.dart:2562

```dart
  void selectTab(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => tab = value);
  }

```

### lib/main.dart:3220

```dart
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailsScreen(
                                product: product,
                                controller: controller,
                              ),
                            ),
                          ),
                          child: LayoutBuilder(
                            builder: (context, cardConstraints) {
                              final compact = cardConstraints.maxWidth < 310;
```

### lib/main.dart:3700

```dart
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailsScreen(
                product: product,
                controller: controller,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
```

### lib/main.dart:3897

```dart
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CartScreen(controller: widget.controller),
            ),
          ),
        ),
        const SizedBox(width: 12),
```

### lib/main.dart:4076

```dart
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(controller: controller),
      ),
    );
  }

```

### lib/main.dart:4418

```dart
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => OrderConfirmationScreen(
                              order: order,
                              fromHistory: true,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
```

### lib/main.dart:5026

```dart
    final selected = await Navigator.of(context)
        .push<DeliveryLocationSelection>(
          MaterialPageRoute(
            builder: (_) => DeliveryMapPicker(
              initialPoint: deliveryPin,
              locateOnOpen: useGps,
              locationService: widget.locationService,
            ),
          ),
        );
    if (!mounted || selected == null) return;
    final previousSuggestion = suggestedAddress;
    setState(() {
      deliveryPin = selected.point;
```

### lib/main.dart:5066

```dart
        final paid = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => DemoPaymentScreen(
              amount: widget.controller.total,
              checkoutMobile: mobile.text,
            ),
          ),
        );
        if (!mounted || paid != true) return;
      }
```

### lib/main.dart:5096

```dart
      Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(
          settings: const RouteSettings(
            name: OrderConfirmationScreen.routeName,
          ),
          builder: (_) => OrderConfirmationScreen(order: order),
        ),
        (route) => route.settings.name == MenuScreen.routeName || route.isFirst,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
```

### web/index.html:29

```html

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>Smooch Cafe</title>
```

## The fix

Use the article's central Title wrapper listening to navigation state. Keep Navigator 1.0 and required MaterialPageRoute. Add these helpers in lib/main.dart:

```dart
class CafeRouteTitles extends NavigatorObserver {
  final title = ValueNotifier<String>('Welcome · Smooch Cafe');
  String menuLabel = 'Our menu';
  Route<dynamic>? active;
  String? pending;
  bool scheduled = false;
  bool disposed = false;
  void publish(String label) {
    pending = '$label · Smooch Cafe';
    if (scheduled || disposed) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!disposed && pending != null) title.value = pending!;
    });
  }
  void showRoute(Route<dynamic>? route) {
    active = route;
    final label = switch (route?.settings.name) {
      '/menu' => menuLabel,
      '/details' => route?.settings.arguments is String
          ? route!.settings.arguments as String : 'Product details',
      '/bag' => 'Your bag',
      '/history' => 'Order history',
      '/delivery-map' => 'Delivery location',
      '/checkout' => 'Checkout',
      '/payment' => 'GCash',
      '/order-confirmation' => route?.settings.arguments == 'Order details'
          ? 'Order details' : 'Order confirmation',
      _ => 'Welcome',
    };
    publish(label);
  }
  void selectMenuTab(int index) {
    menuLabel = const ['Our menu', 'Order history', 'Cafe info'][index];
    if (active?.settings.name == '/menu') publish(menuLabel);
  }
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == '/menu') menuLabel = 'Our menu';
    showRoute(route);
  }
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => showRoute(previousRoute);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (active == oldRoute) showRoute(newRoute);
  }
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (active == route) showRoute(previousRoute);
  }
  void dispose() { disposed = true; title.dispose(); }
}
class CafeTitleScope extends InheritedWidget {
  const CafeTitleScope({super.key, required this.titles, required super.child});
  final CafeRouteTitles titles;
  static CafeRouteTitles? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CafeTitleScope>()?.titles;
  @override
  bool updateShouldNotify(CafeTitleScope oldWidget) => oldWidget.titles != titles;
}
```

Own one CafeRouteTitles in _MiniShopAppState and dispose it. Set navigatorObservers: [titles]. In MaterialApp.builder wrap its Navigator child with CafeTitleScope and ValueListenableBuilder<String> whose builder returns Title(title: value, color: AppColors.dark, child: child!). Preserve an existing scale builder by putting its result inside this Title/scope instead of replacing it.

Give each currently unnamed MaterialPageRoute the matching name above. Details arguments contain product.name; saved receipt arguments contain 'Order details'; a fresh receipt uses the existing OrderConfirmationScreen.routeName. Keep all existing route settings and stack-removal predicates functional. In selectTab call CafeTitleScope.of(context)?.selectMenuTab(value) when accepting a destination, including reselect; it must not alter scrolling behavior. On returning to /menu, the observer restores the cached destination label. Keep the static index title as the pre-boot fallback. All Title colors are opaque.

Concrete MaterialApp integration (keep its existing properties and dispose titles from the owning State):

```dart
// field in _MiniShopAppState
final titles = CafeRouteTitles();

// entries in the existing MaterialApp
navigatorObservers: [titles],
builder: (context, child) => CafeTitleScope(
  titles: titles,
  child: ValueListenableBuilder<String>(
    valueListenable: titles.title,
    child: child ?? const SizedBox.shrink(),
    builder: (context, value, navigator) => Title(
      title: value,
      color: AppColors.dark,
      child: navigator!,
    ),
  ),
),
```
If cafeTextScaleBuilder already exists, use child: cafeTextScaleBuilder(context, child) instead of child: child ?? const SizedBox.shrink() in ValueListenableBuilder. Add CafeTitleScope.of(context)?.selectMenuTab(value) at the beginning of selectTab, after rejecting any invalid destination index. A fresh /menu push resets the title to Our menu; popping back to an existing menu restores its last tab. Include this re-entry case in tests.

## Steps

1. Add the observer/scope in lib/main.dart, own it in _MiniShopAppState and dispose it.
2. Wire navigatorObservers and the central listening Title through MaterialApp.builder; preserve any existing builder behavior.
3. Add the specified route names/arguments at every push in Where; leave the existing menu/confirmation constants and Navigator APIs intact.
4. Notify the title observer from the shared menu destination handler.
5. Add test/route_titles_test.dart for push, pop, replacement/removal, tab changes, product title and disposed callbacks. Confirm actual browser title after Back and receipt → history.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'CafeRouteTitles|CafeTitleScope|Title\(' lib/main.dart` finds the observer, shared scope and central Title.
- `rtk flutter test test/route_titles_test.dart` passes.
- `rtk flutter build web` succeeds. The browser shows Welcome, Our menu, Cafe info, product name, Your bag, Checkout, Delivery location, GCash and receipt titles at their corresponding screens, and restores them on Back.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not add go_router, replace Navigator.push/MaterialPageRoute, expose customer names in titles, or change route-stack behavior.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe distinguishable browser tabs and point to opening details, checkout and history while watching the browser title. Report the checks actually executed and any remaining device or hosting verification.
