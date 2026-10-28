import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final montserrat = FontLoader('Montserrat')
      ..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'));
    final playfair = FontLoader('Playfair')
      ..addFont(rootBundle.load('assets/fonts/PlayfairDisplay.ttf'));
    await montserrat.load();
    await playfair.load();
  });

  testWidgets(
    'Bag and product details fit a narrow phone with enlarged real fonts',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final shop = ShopController(repository: const MenuRepository());
      addTearDown(shop.dispose);
      final expensive = shop.products.reduce(
        (a, b) => a.price > b.price ? a : b,
      );
      shop.addToCart(expensive, quantity: 99);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: CartScreen(controller: shop),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('open-checkout')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: ProductDetailsScreen(
            product: shop.products.first,
            controller: shop,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('details-add-to-cart')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Checkout and saved history fit a narrow phone with enlarged real fonts',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final shop = ShopController(repository: const MenuRepository());
      addTearDown(shop.dispose);
      shop.addToCart(shop.products.first);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: CheckoutScreen(controller: shop),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('payment-digital')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('place-order')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await shop.submitOrder(
        customerName: 'Ana Cruz',
        mobileNumber: '09171234567',
        notes: '',
        paymentMethod: PaymentMethod.cash,
        deliveryAddress: '12 Rizal Street, Carmona, Cavite',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(1.6)),
            child: child!,
          ),
          home: OrderHistoryScreen(controller: shop),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('history-SMC-0001')).hitTestable(),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('GCash payment demo stays usable on a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
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
        home: const DemoPaymentScreen(
          amount: 12345,
          checkoutMobile: '09171234567',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('pay-with-gcash')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const Key('simulate-payment-failure')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('retry-payment')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Featured carousel fits a narrow phone with enlarged fonts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
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
    final carousel = find.byKey(const Key('featured-carousel'));
    expect(carousel, findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(carousel);
    await tester.pumpAndSettle();
    await tester.drag(carousel, const Offset(-220, 0));
    await tester.pumpAndSettle();
    expect(tester.widget<PageView>(carousel).controller!.page, closeTo(1, .01));
    expect(tester.takeException(), isNull);
  });
}
