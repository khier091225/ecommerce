import 'package:ecommerce/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  OrderReceipt receipt(
    DateTime createdAt, {
    FulfillmentMethod fulfillment = FulfillmentMethod.delivery,
  }) => OrderReceipt(
    reference: 'SMC-0001',
    items: const [],
    customerName: 'Juan Dela Cruz',
    mobileNumber: '09171234567',
    notes: '',
    paymentMethod: PaymentMethod.cash,
    createdAt: createdAt,
    fulfillment: fulfillment,
    deliveryAddress: fulfillment == FulfillmentMethod.delivery
        ? '12 Rizal Street, Carmona, Cavite'
        : '',
  );

  test('Saved order time determines the stage at each ten-second boundary', () {
    final placedAt = DateTime.utc(2026, 1, 1, 12);
    final order = receipt(placedAt);
    expect(order.stageAt(placedAt), OrderStage.confirmed);
    expect(
      order.stageAt(placedAt.add(const Duration(seconds: 9))),
      OrderStage.confirmed,
    );
    expect(
      order.stageAt(placedAt.add(const Duration(seconds: 10))),
      OrderStage.preparing,
    );
    expect(
      order.stageAt(placedAt.add(const Duration(seconds: 19))),
      OrderStage.preparing,
    );
    expect(
      order.stageAt(placedAt.add(const Duration(seconds: 20))),
      OrderStage.riderAssigned,
    );
    expect(
      order.stageAt(placedAt.add(const Duration(seconds: 30))),
      OrderStage.onTheWay,
    );
    expect(
      order.stageAt(placedAt.add(const Duration(seconds: 40))),
      OrderStage.delivered,
    );
    final restored = OrderReceipt.fromJson(order.toJson());
    expect(restored.fulfillment, FulfillmentMethod.delivery);
    expect(restored.deliveryAddress, '12 Rizal Street, Carmona, Cavite');
    expect(
      restored.stageAt(placedAt.add(const Duration(minutes: 2))),
      OrderStage.delivered,
    );
  });

  test('Older pickup receipts keep a matching three-stage timeline', () {
    final placedAt = DateTime.utc(2026, 1, 1, 12);
    final legacy =
        receipt(placedAt, fulfillment: FulfillmentMethod.pickup).toJson()
          ..remove('fulfillment')
          ..remove('deliveryAddress');
    final restored = OrderReceipt.fromJson(legacy);
    expect(restored.fulfillment, FulfillmentMethod.pickup);
    expect(restored.stages, [
      OrderStage.confirmed,
      OrderStage.preparing,
      OrderStage.readyForPickup,
    ]);
    expect(
      restored.stageAt(placedAt.add(const Duration(seconds: 20))),
      OrderStage.readyForPickup,
    );
  });

  test('A delivery order cannot be saved without a delivery address', () async {
    final shop = ShopController(repository: const MenuRepository());
    addTearDown(shop.dispose);
    shop.addToCart(shop.products.first);
    final missingAddress = await shop.submitOrder(
      customerName: 'Ana Cruz',
      mobileNumber: '09171234567',
      notes: '',
      paymentMethod: PaymentMethod.cash,
      fulfillment: FulfillmentMethod.delivery,
    );
    expect(missingAddress, isNull);
    expect(shop.cartCount, 1);
    expect(shop.orders, isEmpty);
    final saved = await shop.submitOrder(
      customerName: 'Ana Cruz',
      mobileNumber: '09171234567',
      notes: '',
      paymentMethod: PaymentMethod.cash,
      fulfillment: FulfillmentMethod.delivery,
      deliveryAddress: '  12 Rizal Street, Carmona  ',
    );
    expect(saved?.deliveryAddress, '12 Rizal Street, Carmona');
    expect(saved?.reference, 'SMC-0001');
  });

  testWidgets('Receipt timeline advances every ten seconds', (tester) async {
    final order = receipt(DateTime.now());
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: OrderConfirmationScreen(order: order),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('order-stage-confirmed')), findsOneWidget);
    expect(
      find.text('Estimated progress · updates every 10 seconds'),
      findsOneWidget,
    );

    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('order-stage-preparing')), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('order-stage-riderAssigned')), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('order-stage-onTheWay')), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const Key('order-stage-delivered')), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    expect(find.byKey(const Key('order-stage-delivered')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Order History updates its status while open', (tester) async {
    final shop = ShopController(repository: const MenuRepository());
    addTearDown(shop.dispose);
    shop.addToCart(shop.products.first);
    await shop.submitOrder(
      customerName: 'Juan Dela Cruz',
      mobileNumber: '09171234567',
      notes: '',
      paymentMethod: PaymentMethod.cash,
      fulfillment: FulfillmentMethod.delivery,
      deliveryAddress: '12 Rizal Street, Carmona, Cavite',
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: OrderHistoryScreen(controller: shop),
      ),
    );
    await tester.pumpAndSettle();
    final status = find.byKey(const Key('order-stage-SMC-0001'));
    expect(tester.widget<Text>(status).data, 'Confirmed');
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 350));
    expect(tester.widget<Text>(status).data, 'Preparing');
    expect(tester.takeException(), isNull);
  });

  testWidgets('Checkout requires an address for delivery but not pickup', (
    tester,
  ) async {
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
    await tester.enterText(find.byKey(const Key('customer-name')), 'Ana Cruz');
    await tester.enterText(
      find.byKey(const Key('customer-mobile')),
      '09171234567',
    );
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(find.text('Enter your delivery address'), findsOneWidget);
    expect(shop.orders, isEmpty);

    final pickup = find.byKey(const Key('fulfillment-pickup'));
    await tester.ensureVisible(pickup);
    await tester.pumpAndSettle();
    await tester.tap(pickup);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delivery-address')), findsNothing);
    await tester.tap(find.byKey(const Key('place-order')));
    await tester.pumpAndSettle();
    expect(shop.orders.single.fulfillment, FulfillmentMethod.pickup);
    expect(find.text('Ready for pickup'), findsOneWidget);
    expect(find.text('Rider assigned'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
