import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce/main.dart';

void main() {
  testWidgets(
    'Splash skip, search, details, quantity changes, and empty cart',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MiniShopApp());
      await tester.pump(const Duration(milliseconds: 1800));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byKey(const Key('coffee-scene')), findsOneWidget);
      await tester.tap(find.byKey(const Key('skip-splash')));
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsNothing);
      expect(
        Navigator.of(tester.element(find.byType(MenuScreen))).canPop(),
        isFalse,
      );

      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'tiramisu latte');
      await tester.pumpAndSettle();
      final product = find.byKey(const Key('product-coffee-tiramisu-latte'));
      await tester.ensureVisible(product);
      await tester.tap(product);
      await tester.pumpAndSettle();
      expect(find.text('Tiramisu Latte'), findsOneWidget);
      await tester.ensureVisible(find.byTooltip('Increase quantity'));
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();
      expect(find.text('Add to bag • ₱290.00'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('details-add-to-cart')));
      await tester.tap(find.byKey(const Key('details-add-to-cart')));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('View cart'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cart-total')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('cart-total'))).data,
        '₱290.00',
      );
      await tester.tap(find.byTooltip('Increase quantity'));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('cart-total'))).data,
        '₱435.00',
      );
      await tester.tap(find.byTooltip('Decrease quantity'));
      await tester.pump();
      expect(
        tester.widget<Text>(find.byKey(const Key('cart-total'))).data,
        '₱290.00',
      );
      await tester.tap(find.text('Review order'));
      await tester.pumpAndSettle();
      expect(find.text('DEMO CHECKOUT'), findsOneWidget);
      await tester.tap(find.text('Back to my bag'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove Tiramisu Latte'));
      await tester.pumpAndSettle();
      expect(find.text('A little empty, for now.'), findsOneWidget);
      expect(find.byKey(const Key('cart-total')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Favorites and cafe tabs work on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = ShopController(repository: const MenuRepository());
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: MenuScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Save Tiramisu Latte'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byTooltip('Save Tiramisu Latte'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save Tiramisu Latte'));
    await tester.pump();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Tiramisu Latte'), findsOneWidget);
    await tester.tap(find.byTooltip('Unsave Tiramisu Latte'));
    await tester.pumpAndSettle();
    expect(find.text('Make room for favorites.'), findsOneWidget);
    await tester.tap(find.text('Our cafe'));
    await tester.pumpAndSettle();
    expect(
      find.text('Come for the coffee.\nStay for the comfort.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final size in [
    const Size(320, 700),
    const Size(768, 1024),
    const Size(1440, 900),
  ]) {
    testWidgets('Animated splash and menu fit ${size.width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MiniShopApp());
      await tester.pump(const Duration(milliseconds: 1800));
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const Key('skip-splash')));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -550));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Splash automatically replaces itself with the menu once', (
    tester,
  ) async {
    await tester.pumpWidget(const MiniShopApp());
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2300));
    expect(find.byType(MenuScreen), findsNothing);
    await tester.pump(const Duration(milliseconds: 2400));
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(MenuScreen))).canPop(),
      isFalse,
    );
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(MenuScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Reduced motion shows a still splash and promptly opens the menu',
    (tester) async {
      final controller = ShopController(repository: const MenuRepository());
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: SplashScreen(controller: controller),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.byType(MenuScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Disposing an active splash cancels its animations', (
    tester,
  ) async {
    await tester.pumpWidget(const MiniShopApp());
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 6));
    expect(tester.takeException(), isNull);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('Splash fades away before the menu appears and accepts taps', (
    tester,
  ) async {
    await tester.pumpWidget(const MiniShopApp());
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.tap(find.byKey(const Key('skip-splash')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(MenuScreen), findsOneWidget);
    final cover = tester.widget<Opacity>(
      find.byKey(const Key('splash-fade-cover')),
    );
    final menu = tester.widget<Opacity>(find.byKey(const Key('menu-reveal')));
    expect(cover.opacity, allOf(greaterThan(0), lessThan(1)));
    expect(menu.opacity, 0);
    expect(find.byTooltip('View cart').hitTestable(), findsNothing);

    await tester.pump(const Duration(milliseconds: 550));
    expect(
      tester
          .widget<Opacity>(find.byKey(const Key('splash-fade-cover')))
          .opacity,
      1,
    );
    expect(
      tester.widget<Opacity>(find.byKey(const Key('menu-reveal'))).opacity,
      allOf(greaterThan(0), lessThan(1)),
    );
    expect(find.byTooltip('View cart').hitTestable(), findsNothing);

    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byTooltip('View cart').hitTestable(), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(MenuScreen))).canPop(),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });
}
