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
        expect(ShopController.categories, contains(product.group));
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
        shop.filteredProducts.every((product) => product.group == 'Coffee'),
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

  test('Search matches words in any order with repeated whitespace', () {
    shop.search('  LATTE   tiramisu  ');
    expect(shop.filteredProducts.map((p) => p.name), ['Tiramisu Latte']);
    shop.selectCategory('Food');
    expect(shop.filteredProducts, isEmpty);
    shop.search('   ');
    expect(shop.filteredProducts.every((p) => p.group == 'Food'), isTrue);
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
