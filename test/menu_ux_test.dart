import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce/main.dart';

void main() {
  late ShopController shop;
  setUp(() => shop = ShopController(repository: const MenuRepository()));
  tearDown(() => shop.dispose());

  Future<void> openMenu(
    WidgetTester tester, {
    double scale = 1,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: MenuScreen(controller: shop),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Category strip and empty search recovery keep the query', (
    tester,
  ) async {
    await openMenu(tester);
    await tester.drag(
      find.byKey(const Key('category-scroll')),
      const Offset(-300, 0),
    );
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const Key('category-Food'))),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('category-Food')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('menu-search')),
      'tiramisu latte',
    );
    await tester.pumpAndSettle();
    expect(find.text('No matches found.'), findsOneWidget);
    await Scrollable.ensureVisible(
      tester.element(find.text('Search all categories')),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Search all categories'));
    await tester.pumpAndSettle();
    expect(shop.category, 'All');
    expect(find.byKey(const Key('category-All')).hitTestable(), findsOneWidget);
    expect(shop.query, 'tiramisu latte');
    expect(find.text('1 item for “tiramisu latte”'), findsOneWidget);
    expect(find.text('Tiramisu Latte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Search remains reachable after scrolling and tabs preserve position',
    (tester) async {
      await openMenu(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -650));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('menu-search')).hitTestable(),
        findsOneWidget,
      );
      expect(find.byTooltip('Next categories').hitTestable(), findsOneWidget);
      final scroll = tester
          .widget<CustomScrollView>(find.byType(CustomScrollView))
          .controller!;
      final position = scroll.offset;
      expect(position, greaterThan(200));
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Our menu'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CustomScrollView>(find.byType(CustomScrollView))
            .controller!
            .offset,
        closeTo(position, 1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Category arrows reach later groups and selected chip stays visible',
    (tester) async {
      await openMenu(tester);
      for (var i = 0; i < 5; i++) {
        final next = tester.widget<IconButton>(
          find.byKey(const Key('next-categories')),
        );
        if (next.onPressed == null) break;
        await tester.tap(find.byTooltip('Next categories'));
        await tester.pumpAndSettle();
      }
      final last = find.byKey(const Key('category-More Drinks'));
      expect(last.hitTestable(), findsOneWidget);
      await tester.tap(last);
      await tester.pumpAndSettle();
      expect(shop.category, 'More Drinks');
      expect(
        shop.filteredProducts.every((p) => p.group == 'More Drinks'),
        isTrue,
      );
      expect(last.hitTestable(), findsOneWidget);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
      await tester.pumpAndSettle();
      final scroll = tester
          .widget<CustomScrollView>(find.byType(CustomScrollView))
          .controller!;
      final position = scroll.offset;
      shop.selectCategory('All');
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('category-All')).hitTestable(),
        findsOneWidget,
      );
      expect(scroll.offset, closeTo(position, 1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Clear search preserves category and sort; desktop needs no arrows',
    (tester) async {
      shop.selectCategory('Coffee');
      shop.sortBy(MenuSort.priceLow);
      shop.search('latte');
      await openMenu(tester, size: const Size(1440, 1000));
      expect(find.byTooltip('Previous categories'), findsNothing);
      expect(find.byTooltip('Next categories'), findsNothing);
      expect(find.byTooltip('Browse categories'), findsNothing);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      expect(shop.query, isEmpty);
      expect(shop.category, 'Coffee');
      expect(shop.sort, MenuSort.priceLow);
      expect(shop.filteredProducts, hasLength(13));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Add button updates the persistent bag total and opens cart', (
    tester,
  ) async {
    await openMenu(tester);
    final add = find.byKey(const Key('add-coffee-tiramisu-latte'));
    await Scrollable.ensureVisible(tester.element(add), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('view-bag-summary')), findsOneWidget);
    expect(shop.total, 145);
    await Scrollable.ensureVisible(tester.element(add), alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text('₱290.00'), findsOneWidget);
    await tester.tap(find.byKey(const Key('view-bag-summary')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('cart-total'))).data,
      '₱290.00',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Menu and bag summary accommodate larger text', (tester) async {
    shop.addToCart(shop.products.first);
    await openMenu(tester, scale: 1.6);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('menu-search')).hitTestable(), findsOneWidget);
    expect(
      find.byKey(const Key('view-bag-summary')).hitTestable(),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  test('Shopping text and primary actions retain at least 4.5:1 contrast', () {
    for (final pair in [
      (AppColors.white, AppColors.action),
      (AppColors.ink, AppColors.canvas),
      (AppColors.secondaryText, AppColors.surface),
      (AppColors.white, AppColors.dark),
    ]) {
      final a = pair.$1.computeLuminance();
      final b = pair.$2.computeLuminance();
      final contrast = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
      expect(contrast, greaterThanOrEqualTo(4.5));
    }
  });
}
