import 'dart:async';
import 'dart:convert';

import 'package:ecommerce/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart' show FlutterMap, TapPosition;
import 'package:latlong2/latlong.dart';

Future<OrderReceipt?> place(
  ShopController shop, {
  String mobile = '09171234567',
  double? latitude,
  double? longitude,
}) => shop.submitOrder(
  customerName: 'Ana Cruz',
  mobileNumber: mobile,
  notes: '',
  paymentMethod: PaymentMethod.cash,
  deliveryAddress: '12 Rizal Street, Carmona',
  deliveryLatitude: latitude,
  deliveryLongitude: longitude,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Montserrat',
    )..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'))).load();
    await (FontLoader(
      'Playfair',
    )..addFont(rootBundle.load('assets/fonts/PlayfairDisplay.ttf'))).load();
  });

  test(
    'Corrupt receipts do not discard good history or reuse references',
    () async {
      final store = MemoryOrderStore();
      final original = ShopController(
        repository: const MenuRepository(),
        orderStore: store,
      );
      original.addToCart(original.products.first);
      final saved = (await place(original))!;
      original.dispose();
      store.value = jsonEncode({
        'orders': [
          {'reference': 'SMC-0008', 'paymentMethod': 'invalid'},
          saved.toJson(),
        ],
        'nextOrderNumber': 1,
      });
      final shop = ShopController(
        repository: const MenuRepository(),
        orderStore: store,
      );
      addTearDown(shop.dispose);
      await shop.restoreOrders();
      expect(shop.orders.single.reference, 'SMC-0001');
      expect(shop.historyError, isNotNull);
      shop.addToCart(shop.products.first);
      expect((await place(shop))!.reference, 'SMC-0009');
    },
  );

  test(
    'A failed first storage read can recover on the next order attempt',
    () async {
      final store = _TransientStore();
      final shop = ShopController(
        repository: const MenuRepository(),
        orderStore: store,
      );
      addTearDown(shop.dispose);
      await expectLater(shop.restoreOrders(), throwsStateError);
      shop.addToCart(shop.products.first);
      expect((await place(shop))!.reference, 'SMC-0001');
      expect(shop.historyError, isNull);
      expect(shop.cartCount, 0);
    },
  );

  test(
    'Disposing during a storage read does not notify a disposed controller',
    () async {
      final store = _PendingStore();
      final shop = ShopController(
        repository: const MenuRepository(),
        orderStore: store,
      );
      final pending = shop.restoreOrders();
      shop.dispose();
      store.readResult.complete(null);
      await pending;
    },
  );

  test(
    'Checkout validates phone and coordinates and normalizes the saved mobile',
    () async {
      final shop = ShopController(repository: const MenuRepository());
      addTearDown(shop.dispose);
      shop.addToCart(shop.products.first);
      expect(await place(shop, mobile: '123'), isNull);
      expect(await place(shop, latitude: double.nan, longitude: 121), isNull);
      expect(await place(shop, latitude: 95, longitude: 121), isNull);
      expect(shop.cartCount, 1);
      final order = await place(shop, mobile: '0917 123-4567');
      expect(order!.mobileNumber, '09171234567');
    },
  );

  testWidgets(
    'Removing the final bag line can be undone with quantity and total restored',
    (tester) async {
      final shop = ShopController(repository: const MenuRepository());
      addTearDown(shop.dispose);
      shop.addToCart(shop.products.first, quantity: 3);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: CartScreen(controller: shop),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove Tiramisu Latte'));
      await tester.pumpAndSettle();
      expect(shop.cartCount, 0);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(shop.cartCount, 3);
      expect(shop.total, 435);
      expect(find.byKey(const Key('cart-total')), findsOneWidget);
    },
  );

  testWidgets(
    'Submitting from the bottom scrolls to the first invalid contact field',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final shop = ShopController(repository: const MenuRepository());
      addTearDown(shop.dispose);
      shop.addToCart(shop.products.first);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: CheckoutScreen(controller: shop),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('payment-digital')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('place-order')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('customer-name')).hitTestable(),
        findsOneWidget,
      );
      expect(find.text('Enter your name'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('customer-name')),
        'Ana Cruz',
      );
      await tester.pumpAndSettle();
      expect(find.text('Enter your name'), findsNothing);
      expect(shop.orders, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Manual map pin wins over a late GPS response and lookup failure still confirms',
    (tester) async {
      final service = _PendingLocation();
      DeliveryLocationSelection? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push<DeliveryLocationSelection>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DeliveryMapPicker(
                        locationService: service,
                        locateOnOpen: true,
                      ),
                    ),
                  );
                },
                child: const Text('Open map'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open map'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final map = tester.widget<FlutterMap>(
        find.byKey(const Key('delivery-map')),
      );
      map.options.onTap!(
        const TapPosition(Offset.zero, null),
        const LatLng(14.32, 121.06),
      );
      await tester.pump();
      service.gps.complete(const LatLng(14.9, 121.9));
      await tester.pumpAndSettle();
      expect(find.textContaining('14.32000'), findsOneWidget);
      await tester.tap(find.byKey(const Key('confirm-delivery-pin')));
      await tester.pumpAndSettle();
      expect(result!.point.latitude, 14.32);
      expect(result!.suggestedAddress, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Map errors and controls fit a small phone with large real fonts',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: DeliveryMapPicker(
            locationService: _DeniedLocation(),
            locateOnOpen: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Turn on device'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('confirm-delivery-pin')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Tablet navigation accommodates large fonts', (tester) async {
    tester.view.physicalSize = const Size(900, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final shop = ShopController(repository: const MenuRepository());
    addTearDown(shop.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: MenuScreen(controller: shop),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cafe info'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _TransientStore implements OrderStore {
  bool failed = false;
  @override
  Future<String?> read() async {
    if (!failed) {
      failed = true;
      throw StateError('Unavailable');
    }
    return null;
  }

  @override
  Future<void> write(String value) async {}
}

class _PendingStore implements OrderStore {
  final readResult = Completer<String?>();
  @override
  Future<String?> read() => readResult.future;
  @override
  Future<void> write(String value) async {}
}

class _PendingLocation extends DeliveryLocationService {
  final gps = Completer<LatLng>();
  @override
  Future<LatLng> currentLocation() => gps.future;
  @override
  Future<String?> addressFor(LatLng point) async =>
      throw StateError('Address service offline');
}

class _DeniedLocation extends DeliveryLocationService {
  @override
  Future<LatLng> currentLocation() async =>
      throw StateError('Turn on device location services to use GPS.');
}
