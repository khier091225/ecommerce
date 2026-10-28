import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce/main.dart';

void main() {
  testWidgets(
    'Failed and cancelled digital payment preserve the bag; success saves an order',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final shop = ShopController(repository: const MenuRepository());
      addTearDown(shop.dispose);
      shop.addToCart(shop.products.first, quantity: 2);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: MenuScreen(controller: shop),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('View cart'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open-checkout')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('customer-name')),
        'Juan Dela Cruz',
      );
      await tester.enterText(
        find.byKey(const Key('customer-mobile')),
        '09171234567',
      );
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('payment-digital'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('payment-digital')));
      await Scrollable.ensureVisible(
        tester.element(find.byKey(const Key('place-order'))),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('place-order')));
      await tester.pumpAndSettle();
      expect(find.byType(DemoPaymentScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('simulate-payment-failure')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('payment-failure')), findsOneWidget);
      expect(shop.cartCount, 2);
      expect(shop.orders, isEmpty);
      await tester.tap(find.byKey(const Key('cancel-payment')));
      await tester.pumpAndSettle();
      expect(find.byType(CheckoutScreen), findsOneWidget);
      expect(shop.cartCount, 2);
      await tester.tap(find.byKey(const Key('place-order')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('simulate-payment-success')));
      await tester.pumpAndSettle();
      expect(find.byType(OrderConfirmationScreen), findsOneWidget);
      expect(
        find.text('Digital demo · Demo payment completed'),
        findsOneWidget,
      );
      expect(shop.cartCount, 0);
      expect(shop.orders, hasLength(1));
      await tester.tap(find.byKey(const Key('continue-shopping')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Order history'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('history-SMC-0001')), findsOneWidget);
      await tester.tap(find.byKey(const Key('history-SMC-0001')));
      await tester.pumpAndSettle();
      expect(find.text('Pickup for Juan Dela Cruz'), findsOneWidget);
      await tester.tap(find.byKey(const Key('continue-shopping')));
      await tester.pumpAndSettle();
      expect(find.byType(OrderHistoryScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Featured carousel swipes and category results animate', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final shop = ShopController(repository: const MenuRepository());
    addTearDown(shop.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: MenuScreen(controller: shop),
      ),
    );
    await tester.pumpAndSettle();
    final carousel = find.byKey(const Key('featured-carousel'));
    expect(carousel, findsOneWidget);
    await Scrollable.ensureVisible(tester.element(carousel));
    await tester.drag(carousel, const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(carousel).controller!.page, closeTo(1, .01));
    await tester.tap(find.byKey(const Key('category-Food')));
    await tester.pump();
    expect(carousel, findsNothing);
    final firstFood = shop.filteredProducts.first;
    final motion = find.byKey(Key('filter-motion-${firstFood.id}'));
    expect(motion, findsOneWidget);
    expect(tester.widget<FadeTransition>(motion).opacity.value, lessThan(1));
    await tester.pumpAndSettle();
    expect(tester.widget<FadeTransition>(motion).opacity.value, 1);
    expect(tester.takeException(), isNull);
  });
}
