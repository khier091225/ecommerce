import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce/main.dart';

void main() {
  late ShopController shop;
  setUp(() => shop = ShopController(repository: const MenuRepository()));
  tearDown(() => shop.dispose());

  test(
    'Catalog uses unique product IDs, positive prices, and existing photos',
    () {
      expect(shop.products, hasLength(92));
      expect(shop.products.map((product) => product.id).toSet(), hasLength(92));
      for (final product in shop.products) {
        expect(product.price, greaterThan(0), reason: product.name);
        expect(File(product.image).existsSync(), isTrue, reason: product.image);
        expect(ShopController.categories, contains(product.category));
        expect(product.subcategory, isNotEmpty);
      }
    },
  );

  test(
    'Search ignores case and surrounding spaces and combines with category',
    () {
      shop.search('  LATTE  ');
      expect(shop.filteredProducts, isNotEmpty);
      shop.selectCategory('Coffee');
      expect(
        shop.filteredProducts.every((product) => product.category == 'Coffee'),
        isTrue,
      );
      shop.selectCategory('Food');
      expect(shop.filteredProducts, isEmpty);
      shop.search('burger');
      expect(shop.filteredProducts, hasLength(6));
    },
  );

  test(
    'Cart merges identical products and keeps same-name variants distinct',
    () {
      final variants = shop.products
          .where((p) => p.name == 'Caramel Macchiato')
          .toList();
      expect(variants, hasLength(2));
      shop.addToCart(variants[0], quantity: 2);
      shop.addToCart(variants[0]);
      shop.addToCart(variants[1]);
      expect(shop.cartItems, hasLength(2));
      expect(shop.cartCount, 4);
      expect(shop.total, variants[0].price * 3 + variants[1].price);
      shop.decrease(variants[1]);
      expect(shop.cartItems, hasLength(1));
      shop.remove(variants[0]);
      expect(shop.cartCount, 0);
      expect(shop.total, 0);
      shop.addToCart(variants[0], quantity: 0);
      expect(shop.cartItems, isEmpty);
    },
  );

  test('Favorites toggle without adding items to the cart', () {
    final product = shop.products.first;
    shop.toggleFavorite(product);
    expect(shop.favorites, [product]);
    expect(shop.cartCount, 0);
    shop.toggleFavorite(product);
    expect(shop.favorites, isEmpty);
  });

  test(
    'Placing demo orders snapshots items and totals with sequential references',
    () {
      expect(shop.placeDemoOrder(), isNull);
      final first = shop.products.first;
      final second = shop.products[1];
      shop.addToCart(first, quantity: 2);
      shop.addToCart(second);
      shop.toggleFavorite(first);
      final order = shop.placeDemoOrder()!;
      expect(order.reference, 'SMC-0001');
      expect(order.itemCount, 3);
      expect(order.total, first.price * 2 + second.price);
      expect(shop.cartCount, 0);
      expect(shop.total, 0);
      expect(shop.favorites, [first]);
      expect(shop.placeDemoOrder(), isNull);
      shop.addToCart(first, quantity: 4);
      expect(order.items.first.quantity, 2);
      expect(order.total, first.price * 2 + second.price);
      expect(() => order.items.clear(), throwsUnsupportedError);
      final next = shop.placeDemoOrder()!;
      expect(next.reference, 'SMC-0002');
      expect(next.itemCount, 4);
      expect(next.total, first.price * 4);
    },
  );

  test('Every category filters the expected products and preserves subcategory search', () {
    const expectedCounts = {
      'Coffee': 13,
      'Non-Coffee': 6,
      'Food': 34,
      'Pastries': 21,
      'Ice Blended': 8,
      'More Drinks': 10,
    };
    for (final entry in expectedCounts.entries) {
      shop.selectCategory(entry.key);
      expect(shop.filteredProducts, hasLength(entry.value));
      expect(
        shop.filteredProducts.every((p) => p.category == entry.key),
        isTrue,
      );
    }
    shop.selectCategory('Pastries');
    shop.search('brownies');
    expect(shop.filteredProducts, isNotEmpty);
    expect(
      shop.filteredProducts.every((p) => p.subcategory == 'Brownies'),
      isTrue,
    );
    shop.selectCategory('Food');
    shop.search('quarter pounder');
    expect(shop.filteredProducts, hasLength(5));
    expect(
      shop.filteredProducts.every((p) => p.subcategory == 'Quarter Pounder'),
      isTrue,
    );
  });

  test('Search matches words in any order with repeated whitespace', () {
    shop.search('  LATTE   tiramisu  ');
    expect(shop.filteredProducts.map((p) => p.name), ['Tiramisu Latte']);
    shop.selectCategory('Food');
    expect(shop.filteredProducts, isEmpty);
    shop.search('   ');
    expect(shop.filteredProducts.every((p) => p.category == 'Food'), isTrue);
    expect(shop.filteredProducts, hasLength(34));
  });

  test(
    'Sorting applies to filtered results without changing catalog order',
    () {
      final originalIds = shop.products.map((p) => p.id).toList();
      shop.selectCategory('Coffee');
      shop.search('latte');
      shop.sortBy(MenuSort.priceLow);
      final ascending = shop.filteredProducts.map((p) => p.price).toList();
      expect(ascending, orderedEquals([...ascending]..sort()));
      shop.sortBy(MenuSort.priceHigh);
      expect(
        shop.filteredProducts.map((p) => p.price),
        orderedEquals(ascending.reversed),
      );
      shop.sortBy(MenuSort.name);
      final names = shop.filteredProducts
          .map((p) => p.name.toLowerCase())
          .toList();
      expect(names, orderedEquals([...names]..sort()));
      expect(shop.products.map((p) => p.id), orderedEquals(originalIds));
      shop.sortBy(MenuSort.recommended);
      expect(shop.filteredProducts.first.name, 'Tiramisu Latte');
    },
  );
}
