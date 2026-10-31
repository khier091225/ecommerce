# Fix: Give important taps and order results subtle tactile feedback

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/haptic-feedback
- **Needs new dependency**: haptic_feedback for capability checks and selection/success/warning/error types, following the article.

## Why

The app animates additions but has no tactile feedback on native devices. Use the article's capability-checked helper for deliberate taps and results, never for rebuilds or timer-driven delivery stages.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Native event paths cover startup entry; bag/detail navigation; bottom/header destination taps and category taps/swipes; sort/reset; Add and quantity controls; remove/Undo; history opening/retry errors; map location/pin confirmation failures; checkout validation/save result; payment-method choice; wallet result. Shared callbacks must emit once, not once per widget that calls them.

### lib/main.dart:1793

```dart
Future<void> openCafeLink(BuildContext context, Uri uri) async {
  try {
    if (await launchUrl(uri)) return;
  } catch (_) {
    // Some devices have no application that can handle this link.
  }
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not open the link. You can copy the details instead.',
        ),
      ),
    );
```

### lib/main.dart:2080

```dart
      children: [
        IconButton(
          tooltip: 'Decrease quantity',
          onPressed: onDecrease,
          icon: const Icon(Icons.remove, size: 18),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 28),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          tooltip: 'Increase quantity',
          onPressed: onIncrease,
          icon: const Icon(Icons.add, size: 18),
        ),
      ],
```

### lib/main.dart:2222

```dart
  Future<void> _openMenu() async {
    if (!mounted || _leaving) return;
    setState(() => _leaving = true);
    _syncMotion();
    try {
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: MenuScreen.routeName),
          builder: (_) => MenuScreen(controller: widget.controller),
        ),
```

### lib/main.dart:2554

```dart
  void openCart() {
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => CartScreen(controller: shop)),
    );
  }

  void selectTab(int value) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => tab = value);
  }

  void resetPosition() {
```

### lib/main.dart:2581

```dart

  void onCategoryPageChanged() {
    if (categoryTabs.indexIsChanging) return;
    // Let TabBar.onTap finish first when a zero-duration accessibility change
    // notifies listeners synchronously; swipes still commit on settle.
    scheduleMicrotask(() {
      if (!mounted) return;
      final category = ShopController.categories[categoryTabs.index];
      if (shop.category != category) shop.selectCategory(category);
    });
  }

  void selectCategory(String category) {
    if (!ShopController.categories.contains(category)) return;
    final target = category;
    FocusManager.instance.primaryFocus?.unfocus();
    final index = ShopController.categories.indexOf(target);
    if (MediaQuery.disableAnimationsOf(context)) {
      categoryTabs.index = index;
    } else {
      categoryTabs.animateTo(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
    if (shop.category != target) shop.selectCategory(target);
  }
```

### lib/main.dart:2615

```dart
  void resetFilters() {
    FocusManager.instance.primaryFocus?.unfocus();
    search.clear();
    shop.resetFilters();
    if (MediaQuery.disableAnimationsOf(context)) {
      categoryTabs.index = 0;
    } else {
      categoryTabs.animateTo(0);
    }
    resetPosition();
  }

```

### lib/main.dart:3028

```dart
                  PopupMenuButton<MenuSort>(
                    tooltip: 'Sort menu',
                    initialValue: controller.sort,
                    onSelected: onSort,
                    itemBuilder: (_) => [
                      for (final sort in MenuSort.values)
                        CheckedPopupMenuItem(
                          value: sort,
                          checked: controller.sort == sort,
```

### lib/main.dart:3503

```dart
              labelPadding: const EdgeInsets.symmetric(horizontal: 17),
              onTap: (index) => onCategory(ShopController.categories[index]),
              tabs: [
                for (final category in ShopController.categories)
                  Tab(key: Key('category-$category'), text: category),
              ],
            ),
```

### lib/main.dart:3554

```dart
  void addProduct() {
    final previousCount = widget.controller.cartCount;
    widget.controller.addToCart(widget.product);
    if (widget.controller.cartCount == previousCount) return;
    final targetKey = context
        .findAncestorStateOfType<_MenuScreenState>()
        ?.cartFlightTarget;
    if (targetKey != null) {
      unawaited(_flyProductToCart(context, widget.product, targetKey));
    }
    resetTimer?.cancel();
    pressTimer?.cancel();
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
```

### lib/main.dart:3865

```dart
  Future<void> addToCart(BuildContext buttonContext) async {
    if (adding) return;
    final addedQuantity = quantity;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => adding = true);
    widget.controller.addToCart(widget.product, quantity: addedQuantity);
    await _flyProductToCart(buttonContext, widget.product, cartFlightTarget);
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) {
      setState(() => adding = false);
      return;
    }
```

### lib/main.dart:4214

```dart
  void removeWithUndo(BuildContext context) {
    if (controller.placingOrder) return;
    controller.remove(item.product);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('${item.product.name} removed from your bag.'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () =>
              controller.addToCart(item.product, quantity: item.quantity),
        ),
      ),
    );
  }

  @override
```

### lib/main.dart:4374

```dart
                action: OutlinedButton(
                  key: const Key('retry-order-history'),
                  onPressed: () => unawaited(
                    controller
                        .restoreOrders(retry: true)
                        .catchError((Object _) {}),
                  ),
                  child: const Text('Try again'),
                ),
```

### lib/main.dart:4417

```dart
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => OrderConfirmationScreen(
                              order: order,
                              fromHistory: true,
                            ),
                          ),
                        ),
```

### lib/main.dart:4780

```dart
      locating = true;
      error = null;
    });
    try {
      final location = await widget.locationService.currentLocation();
      if (!mounted || request != locationRequest) return;
      setState(() {
        pin = location;
        error = CheckoutValidation.isWithinDeliveryArea(location) ? null : 'This location is outside our 10 km delivery area around Carmona.';
      });
      if (mapReady) mapController.move(location, 17);
    } catch (failure) {
      if (mounted && request == locationRequest) {
        setState(
          () => error = failure is StateError
              ? '${failure.message} You can also tap the map.'
              : failure is TimeoutException
              ? 'GPS took too long. Try again or tap the map.'
              : 'Could not use GPS. Allow location access or tap the map.',
        );
      }
    } finally {
      if (mounted && request == locationRequest) {
        setState(() => locating = false);
      }
    }
  }

  Future<void> confirm() async {
    if (pin == null ||
        resolving ||
        locating ||
        !CheckoutValidation.isWithinDeliveryArea(pin)) {
      setState(
        () => error = 'Choose a location within 10 km of Carmona to continue.',
      );
```

### lib/main.dart:4810

```dart
        resolving ||
        locating ||
        !CheckoutValidation.isWithinDeliveryArea(pin)) {
      setState(
        () => error = 'Choose a location within 10 km of Carmona to continue.',
      );
      return;
    }
    setState(() => resolving = true);
    final selected = pin!;
    String? suggestedAddress;
    try {
      suggestedAddress = await widget.locationService
          .addressFor(selected)
          .timeout(const Duration(seconds: 6));
    } catch (_) {
      // Keep the chosen destination even if the address lookup is unavailable.
    }
```

### lib/main.dart:4848

```dart
              pin: pin,
              controller: mapController,
              zoom: pin == null ? 13.5 : 16,
              onReady: () {
                mapReady = true;
                if (pin != null) mapController.move(pin!, 17);
              },
              onTap: resolving
                  ? null
                  : (point) => setState(() {
                      locationRequest++;
                      locating = false;
                      pin = point;
                      error = CheckoutValidation.isWithinDeliveryArea(point)
                          ? null
                          : 'This location is outside our 10 km delivery area around Carmona.';
                    }),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Center(
                child: DecoratedBox(
```

### lib/main.dart:5050

```dart
    setState(() => attemptedSubmit = true);
    final invalid = form.currentState!.validateGranularly();
    if (invalid.isNotEmpty) {
      await Scrollable.ensureVisible(
        invalid.first.context,
        alignment: .15,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 250),
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => busy = true);
    try {
      if (payment == PaymentMethod.digital) {
        final paid = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
```

### lib/main.dart:5084

```dart
      );
      if (!mounted) return;
      if (order == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Check your bag and delivery details before placing an order.',
            ),
          ),
        );
        return;
      }
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
          const SnackBar(
            content: Text('Could not save the order. Your bag is still here.'),
          ),
        );
      }
    } finally {
```

### lib/main.dart:5250

```dart
                          key: const Key('use-gps-address'),
                          onPressed: () => chooseLocation(useGps: true),
                          icon: const Icon(
                            Icons.my_location_outlined,
                            size: 18,
                          ),
                          label: const Text('Use GPS'),
                        ),
                        OutlinedButton.icon(
                          key: const Key('choose-map-address'),
                          onPressed: chooseLocation,
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: Text(
                            deliveryPin == null ? 'Choose on map' : 'Move pin',
```

### lib/main.dart:5280

```dart
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          key: const Key('remove-delivery-pin'),
                          onPressed: busy
                              ? null
                              : () => setState(() => deliveryPin = null),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Remove pin'),
                        ),
                      ),
```

### lib/main.dart:5310

```dart
                      subtitle: 'Pay when your order arrives',
                      icon: Icons.payments_outlined,
                      selected: payment == PaymentMethod.cash,
                      onTap: () {
                        if (!busy) setState(() => payment = PaymentMethod.cash);
                      },
                    ),
                    const SizedBox(height: 10),
                    _PaymentChoice(
                      key: const Key('payment-digital'),
                      title: 'GCash',
                      subtitle: 'Preview a wallet payment; no money is taken',
                      icon: Icons.account_balance_wallet_outlined,
                      selected: payment == PaymentMethod.digital,
                      onTap: () {
                        if (!busy) {
                          setState(() => payment = PaymentMethod.digital);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
```

### lib/main.dart:5517

```dart
  }

  Future<void> pay() async {
    if (stage != _DemoPaymentStage.review) return;
    setState(() => stage = _DemoPaymentStage.processing);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() => stage = _DemoPaymentStage.success);
  }

```

### lib/main.dart:5948

```dart
                    if (stage == _DemoPaymentStage.review)
                      TextButton(
                        key: const Key('simulate-payment-failure'),
                        onPressed: () =>
                            setState(() => stage = _DemoPaymentStage.failed),
                        style: TextButton.styleFrom(
                          foregroundColor: _WalletDemoColors.blue,
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text('Preview failed payment'),
                      ),
                    if (stage == _DemoPaymentStage.failed)
                      TextButton(
                        key: const Key('cancel-payment'),
```

### pubspec.yaml:35 — dependency insertion area; let pub add update the lockfile

```yaml
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.6
  flutter_map: ^8.3.2
  geolocator: ^14.1.2
  geocoding: ^5.0.1
  http: ^1.6.0
  latlong2: ^0.10.1
  url_launcher: ^6.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
```

## The fix

Add the article's helper in lib/main.dart. Gate it to native Android/iOS, cache capability and contain plugin failures:

```dart
import 'package:haptic_feedback/haptic_feedback.dart';

abstract final class CafeHaptics {
  static Future<bool>? _capability;
  static Future<void> play(HapticsType type) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS)) return;
    try {
      if (await (_capability ??= Haptics.canVibrate())) {
        await Haptics.vibrate(type);
      }
    } catch (_) { /* Haptics must never block an order action. */ }
  }
  static void light() => unawaited(play(HapticsType.light));
  static void selection() => unawaited(play(HapticsType.selection));
  static void success() => unawaited(play(HapticsType.success));
  static void warning() => unawaited(play(HapticsType.warning));
  static void error() => unawaited(play(HapticsType.error));
}
```

Use light for ORDER NOW, navigation opening details/bag/history, a genuine tab/category tap, successful Add, remove and Undo. Use selection for quantity buttons, sort selection, payment selection and settled category swipes. Same-value selections do not vibrate; category tap handling must suppress the subsequent settled-listener duplicate. Use success after local receipt storage succeeds (before confirmation) and wallet preview succeeds. Use warning for invalid checkout or pin/service-area validation. Use error for explicit user-initiated GPS failures, failed storage/submit, wallet failed-payment action and link-opening failure. Do not vibrate for initial background history loading, preloading, automatic stage changes, merely viewing an existing error or a canceled payment. Wrap callbacks so existing actions/guards still run; do not await haptics in navigation or payment logic.

## Steps

1. Run `rtk flutter pub add haptic_feedback` if absent and add CafeHaptics in lib/main.dart.
2. Wire each event path listed in Where to the stated feedback type, with exactly one owner per shared event.
3. Keep native capability failures contained and web/desktop as no-ops.
4. Add test/haptic_actions_test.dart using the plugin's platform channel mock to verify one signal per action, duplicate suppression and unsupported/failing-platform safety. Physically test intensity on Android/iOS.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'class CafeHaptics|CafeHaptics\.' lib/main.dart` finds the helper and action paths.
- `rtk flutter test test/haptic_actions_test.dart` passes; a capability/vibration failure does not block Add, navigation or saving.
- On hardware, tabs and quantities feel subtle, successful checkout feels distinct, and delivery timers never vibrate.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not put haptics in build methods, controller notifications, animated painters or automatic tracking timers. Do not add heavy-impact feedback.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe subtle native tactile feedback and point to changing category and completing checkout on a phone. Report the checks actually executed and any remaining device or hosting verification.
