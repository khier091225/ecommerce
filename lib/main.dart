import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MiniShopApp(orderStore: PreferencesOrderStore()));
}

// ============================================================
// FINAL PROJECT STARTER CODE
// Customize this application based on your chosen e-commerce.
//
// The required StartScreen is implemented below. Its ORDER NOW
// button opens MenuScreen using Navigator.push() and
// MaterialPageRoute. All application code remains in this file.
// ============================================================

// ============================================================
// APPLICATION COLORS
// Customize these colors to match your selected e-commerce.
// ======================================
abstract final class AppColors {
  static const dark = Color(0xFF0A4952);
  static const teal = Color(0xFF0E6F7A);
  static const coral = Color(0xFFF04C45);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFFC0D8DA);
  static const line = Color(0xFF39747C);
  static const canvas = Color(0xFFF6F3ED);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF163B3D);
  static const secondaryText = Color(0xFF56696B);
  static const border = Color(0xFFDCE3DF);
  static const action = Color(0xFFC23F38);
  static const softTeal = Color(0xFFE8F0EC);
  static const softCoral = Color(0xFFFBE9E5);
}

abstract final class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    visualDensity: VisualDensity.standard,
    fontFamily: 'Montserrat',
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
          platform: const _CafePageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: AppColors.canvas,
    colorScheme: const ColorScheme.light(
      primary: AppColors.action,
      onPrimary: AppColors.white,
      secondary: AppColors.teal,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      onSurfaceVariant: AppColors.secondaryText,
      outline: AppColors.secondaryText,
      outlineVariant: AppColors.border,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.dark,
      foregroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.action,
        foregroundColor: AppColors.white,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        minimumSize: const Size(48, 52),
        side: const BorderSide(color: AppColors.secondaryText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 14),
      prefixIconColor: AppColors.secondaryText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.secondaryText),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.dark,
      contentTextStyle: TextStyle(
        color: AppColors.white,
        fontFamily: 'Montserrat',
      ),
      actionTextColor: AppColors.white,
      behavior: SnackBarBehavior.floating,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.softTeal,
      labelTextStyle: const WidgetStatePropertyAll(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
  );
}

TextStyle displayStyle(double size, {Color color = AppColors.ink}) => TextStyle(
  fontFamily: 'Playfair',
  fontSize: size,
  height: 1.12,
  fontWeight: FontWeight.w600,
  color: color,
  letterSpacing: -.8,
);

// Customize MaterialPageRoute transitions while keeping the required
// Navigator.push() / MaterialPageRoute navigation flow.
class _CafePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CafePageTransitionsBuilder();

  @override
  Duration get transitionDuration => StartScreen.transitionDuration;

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 450);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    if (route.settings.name == MenuScreen.routeName) {
      return _MenuTransition(animation: animation, child: child);
    }
    return const FadeUpwardsPageTransitionsBuilder().buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}

// ============================================================
// PRODUCT, CART, AND ORDER MODELS
// ============================================================
@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.image,
    this.featured = false,
  });

  final String id;
  final String name;
  final int price;
  final String category;
  final String subcategory;
  final String description;
  final String image;
  final bool featured;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'category': category,
    'subcategory': subcategory,
    'description': description,
    'image': image,
    'featured': featured,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: json['price'] as int,
    category: json['category'] as String,
    subcategory: json['subcategory'] as String,
    description: json['description'] as String,
    image: json['image'] as String,
    featured: json['featured'] as bool? ?? false,
  );
}

@immutable
class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;
  int get total => product.price * quantity;

  Map<String, Object?> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    product: Product.fromJson(json['product'] as Map<String, dynamic>),
    quantity: json['quantity'] as int,
  );
}

String pesos(num amount) => '\u20b1${amount.toStringAsFixed(2)}';

String orderDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

@immutable
class OrderReceipt {
  OrderReceipt({
    required this.reference,
    required List<CartItem> items,
    required this.customerName,
    required this.mobileNumber,
    required this.notes,
    required this.paymentMethod,
    required this.createdAt,
  }) : items = List.unmodifiable(items);

  final String reference;
  final List<CartItem> items;
  final String customerName;
  final String mobileNumber;
  final String notes;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  String get paymentStatus => paymentMethod == PaymentMethod.cash
      ? 'Payment due at pickup'
      : 'Payment step complete';
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  int get total => items.fold(0, (sum, item) => sum + item.total);

  Map<String, Object?> toJson() => {
    'reference': reference,
    'items': items.map((item) => item.toJson()).toList(),
    'customerName': customerName,
    'mobileNumber': mobileNumber,
    'notes': notes,
    'paymentMethod': paymentMethod.name,
    'createdAt': createdAt.toIso8601String(),
  };

  factory OrderReceipt.fromJson(Map<String, dynamic> json) => OrderReceipt(
    reference: json['reference'] as String,
    items: (json['items'] as List)
        .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
        .toList(),
    customerName: json['customerName'] as String? ?? '',
    mobileNumber: json['mobileNumber'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    paymentMethod: PaymentMethod.values.byName(
      json['paymentMethod'] as String? ?? 'cash',
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

enum PaymentMethod { cash, digital }

abstract class OrderStore {
  Future<String?> read();
  Future<void> write(String value);
}

class PreferencesOrderStore implements OrderStore {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();
  static const _key = 'smooch_cafe_orders_v1';

  @override
  Future<String?> read() => _preferences.getString(_key);

  @override
  Future<void> write(String value) => _preferences.setString(_key, value);
}

class MemoryOrderStore implements OrderStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async => this.value = value;
}

// ============================================================
// PRODUCT DATA
// ============================================================
// BEGIN CAFE CATALOG
// Generated from SmoochCafe/pages/products.html by tools/import_menu.mjs.
const cafeProducts = <Product>[
  Product(
    id: "coffee-tiramisu-latte",
    name: "Tiramisu Latte",
    price: 145,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Espresso-based latte with tiramisu-inspired cream. A little coffee, a little dessert, and a whole lot of comfort.",
    image: "assets/images/Tiramisu Latte 5.png",
    featured: true,
  ),
  Product(
    id: "quarter-pounder-classic-burger",
    name: "Classic Burger",
    price: 110,
    category: "Food",
    subcategory: "Quarter Pounder",
    description: "A juicy quarter-pound patty with cheese and fresh veggies. Your comfort-food favorite, made to pair with a Smooch drink.",
    image: "assets/images/Classic Burger.png",
    featured: true,
  ),
  Product(
    id: "brownies-chocolate-bliss",
    name: "Chocolate Bliss",
    price: 145,
    category: "Pastries",
    subcategory: "Brownies",
    description: "A fudgy chocolate brownie with a rich, moist center. The perfect little companion to your favorite coffee.",
    image: "assets/images/Chocolate Bliss 2.png",
    featured: true,
  ),
  Product(
    id: "coffee-spanish-latte",
    name: "Spanish Latte",
    price: 80,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Espresso and milk with a sweet, creamy finish. A comforting coffee for slow afternoons.",
    image: "assets/images/Spanish Latte 5.png",
    featured: true,
  ),
  Product(
    id: "non-coffee-strawberry-matcha",
    name: "Strawberry Matcha",
    price: 115,
    category: "Non-Coffee",
    subcategory: "Non-Coffee",
    description: "Earthy matcha meets sweet strawberry and milk for a colorful sip of happiness.",
    image: "assets/images/Strawberry Matcha 1.png",
    featured: true,
  ),
  Product(
    id: "cakes-basque-cheesecake",
    name: "Basque Cheesecake",
    price: 190,
    category: "Pastries",
    subcategory: "Cakes",
    description: "A sweet little moment from our cakes selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Basque Cheesecake 1.png",
    featured: true,
  ),
  Product(
    id: "quarter-pounder-hawaiian-burger",
    name: "Hawaiian Burger",
    price: 125,
    category: "Food",
    subcategory: "Quarter Pounder",
    description: "A comforting pick from our quarter pounder menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Hawaiian Burger.png",
    featured: false,
  ),
  Product(
    id: "quarter-pounder-sunrise-burger",
    name: "Sunrise Burger",
    price: 150,
    category: "Food",
    subcategory: "Quarter Pounder",
    description: "A comforting pick from our quarter pounder menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Sunrise Burger.png",
    featured: false,
  ),
  Product(
    id: "quarter-pounder-bacon-cheese-burger",
    name: "Bacon Cheese Burger",
    price: 155,
    category: "Food",
    subcategory: "Quarter Pounder",
    description: "A comforting pick from our quarter pounder menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Bacon Cheese Burger.png",
    featured: false,
  ),
  Product(
    id: "quarter-pounder-double-classic-burger",
    name: "Double Classic Burger",
    price: 180,
    category: "Food",
    subcategory: "Quarter Pounder",
    description: "A comforting pick from our quarter pounder menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Double Classic Burger.png",
    featured: false,
  ),
  Product(
    id: "sandwiches-classic-chicken",
    name: "Classic Chicken",
    price: 110,
    category: "Food",
    subcategory: "Sandwiches",
    description: "A comforting pick from our sandwiches menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Classic Chicken Sandwich.png",
    featured: false,
  ),
  Product(
    id: "sandwiches-club-house",
    name: "Club House",
    price: 185,
    category: "Food",
    subcategory: "Sandwiches",
    description: "A comforting pick from our sandwiches menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Club House Sandwich.png",
    featured: false,
  ),
  Product(
    id: "sandwiches-grilled-cheese",
    name: "Grilled Cheese",
    price: 110,
    category: "Food",
    subcategory: "Sandwiches",
    description: "A comforting pick from our sandwiches menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Grilled Cheese Sandwich.png",
    featured: false,
  ),
  Product(
    id: "sandwiches-grilled-ham-cheese",
    name: "Grilled Ham & Cheese",
    price: 100,
    category: "Food",
    subcategory: "Sandwiches",
    description: "A comforting pick from our sandwiches menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Grilled Ham & Cheese Sandwich.png",
    featured: false,
  ),
  Product(
    id: "sandwiches-tuna-sandwich",
    name: "Tuna Sandwich",
    price: 125,
    category: "Food",
    subcategory: "Sandwiches",
    description: "A comforting pick from our sandwiches menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Tuna Sandwich.png",
    featured: false,
  ),
  Product(
    id: "sandwiches-chicken-sandwich",
    name: "Chicken Sandwich",
    price: 130,
    category: "Food",
    subcategory: "Sandwiches",
    description: "A comforting pick from our sandwiches menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Chicken Sandwich.png",
    featured: false,
  ),
  Product(
    id: "quesadilla-cheese-quesadilla",
    name: "Cheese Quesadilla",
    price: 115,
    category: "Food",
    subcategory: "Quesadilla",
    description: "A comforting pick from our quesadilla menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Cheese Quesadilla.png",
    featured: false,
  ),
  Product(
    id: "quesadilla-bacon-quesadilla",
    name: "Bacon Quesadilla",
    price: 145,
    category: "Food",
    subcategory: "Quesadilla",
    description: "A comforting pick from our quesadilla menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Bacon Quesadilla.png",
    featured: false,
  ),
  Product(
    id: "quesadilla-chicken-quesadilla",
    name: "Chicken Quesadilla",
    price: 150,
    category: "Food",
    subcategory: "Quesadilla",
    description: "A comforting pick from our quesadilla menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Chicken Quesadilla.png",
    featured: false,
  ),
  Product(
    id: "quesadilla-tapa-quesadilla",
    name: "Tapa Quesadilla",
    price: 160,
    category: "Food",
    subcategory: "Quesadilla",
    description: "A comforting pick from our quesadilla menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Tapa Quesadilla.png",
    featured: false,
  ),
  Product(
    id: "french-fries-plain-fries",
    name: "Plain Fries",
    price: 30,
    category: "Food",
    subcategory: "French Fries",
    description: "A comforting pick from our french fries menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Plain Fries.png",
    featured: false,
  ),
  Product(
    id: "french-fries-bbq-fries",
    name: "BBQ Fries",
    price: 30,
    category: "Food",
    subcategory: "French Fries",
    description: "A comforting pick from our french fries menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/BBQ Fries.png",
    featured: false,
  ),
  Product(
    id: "french-fries-cheese-fries",
    name: "Cheese Fries",
    price: 30,
    category: "Food",
    subcategory: "French Fries",
    description: "A comforting pick from our french fries menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Cheese Fries.png",
    featured: false,
  ),
  Product(
    id: "french-fries-sour-cream-fries",
    name: "Sour Cream Fries",
    price: 30,
    category: "Food",
    subcategory: "French Fries",
    description: "A comforting pick from our french fries menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Sour Cream Fries.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-longganisa",
    name: "Longganisa",
    price: 110,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Longanisa Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-bacon",
    name: "Bacon",
    price: 115,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Bacon Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-sisig",
    name: "Sisig",
    price: 130,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Sisig Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-chicken-steak",
    name: "Chicken Steak",
    price: 130,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Chicken Steak Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-burger-steak",
    name: "Burger Steak",
    price: 130,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Burger Steak Rice Bowl .png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-beef-tapa",
    name: "Beef Tapa",
    price: 140,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Beef Tapa Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-savory-tapa",
    name: "Savory Tapa",
    price: 145,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Savory Tapa Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-chicken-bbq",
    name: "Chicken BBQ",
    price: 125,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Chicken BBQ Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "rice-bowls-chicken-teriyaki",
    name: "Chicken Teriyaki",
    price: 125,
    category: "Food",
    subcategory: "Rice Bowls",
    description: "A comforting pick from our rice bowls menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Chicken Teriyaki Rice Bowl.png",
    featured: false,
  ),
  Product(
    id: "pasta-lasagna",
    name: "Lasagna",
    price: 130,
    category: "Food",
    subcategory: "Pasta",
    description: "A comforting pick from our pasta menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Lasagana 1.png",
    featured: false,
  ),
  Product(
    id: "pasta-carbonara",
    name: "Carbonara",
    price: 115,
    category: "Food",
    subcategory: "Pasta",
    description: "A comforting pick from our pasta menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Carbonara 1.png",
    featured: false,
  ),
  Product(
    id: "pasta-spaghetti-bolognese",
    name: "Spaghetti Bolognese",
    price: 115,
    category: "Food",
    subcategory: "Pasta",
    description: "A comforting pick from our pasta menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Spaghetti Bolognese 1.png",
    featured: false,
  ),
  Product(
    id: "nachos-beef-nachos",
    name: "Beef Nachos",
    price: 130,
    category: "Food",
    subcategory: "Nachos",
    description: "A comforting pick from our nachos menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Beef Nachos 1.png",
    featured: false,
  ),
  Product(
    id: "nachos-nacho-fries",
    name: "Nacho Fries",
    price: 155,
    category: "Food",
    subcategory: "Nachos",
    description: "A comforting pick from our nachos menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Nacho Fries 1.png",
    featured: false,
  ),
  Product(
    id: "nachos-cheesy-bacon-fries",
    name: "Cheesy Bacon Fries",
    price: 155,
    category: "Food",
    subcategory: "Nachos",
    description: "A comforting pick from our nachos menu. Pair it with your favorite handcrafted drink.",
    image: "assets/images/Cheesy Bacon Fries 1.png",
    featured: false,
  ),
  Product(
    id: "brownies-caramel-treat",
    name: "Caramel Treat",
    price: 54,
    category: "Pastries",
    subcategory: "Brownies",
    description: "A sweet little moment from our brownies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Caramel Treat 2.png",
    featured: false,
  ),
  Product(
    id: "brownies-brookies",
    name: "Brookies",
    price: 56,
    category: "Pastries",
    subcategory: "Brownies",
    description: "A sweet little moment from our brownies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Brookies 1.png",
    featured: false,
  ),
  Product(
    id: "brownies-revel-bar",
    name: "Revel Bar",
    price: 60,
    category: "Pastries",
    subcategory: "Brownies",
    description: "A sweet little moment from our brownies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Revel Bar 1.png",
    featured: false,
  ),
  Product(
    id: "brownies-velvet-swirl-bar",
    name: "Velvet Swirl Bar",
    price: 88,
    category: "Pastries",
    subcategory: "Brownies",
    description: "A sweet little moment from our brownies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Velvet Swirl Bar 1.png",
    featured: false,
  ),
  Product(
    id: "brownies-biscoff-blondies",
    name: "Biscoff Blondies",
    price: 50,
    category: "Pastries",
    subcategory: "Brownies",
    description: "A sweet little moment from our brownies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Biscoff Blandies 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-og-cookies",
    name: "OG Cookies",
    price: 40,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/OG Chookies 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-choco-walnut-cookies",
    name: "Choco Walnut Cookies",
    price: 45,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Choco Walnut Cookies 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-chocotrio-cookies",
    name: "Chocotrio Cookies",
    price: 48,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Chocotrio Cookies 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-lotus-cookies",
    name: "Lotus Cookies",
    price: 60,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Lotus Cookies 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-velvet-cookies",
    name: "Velvet Cookies",
    price: 60,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Velve Cookies 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-hershey-s-crinkles",
    name: "Hershey's Crinkles",
    price: 45,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Hershey's Crinkles 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-mini-cookies-4pcs",
    name: "Mini Cookies 4pcs",
    price: 35,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/4 pcs 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-mini-cookies-9pcs",
    name: "Mini Cookies 9pcs",
    price: 75,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/9 PCS 1.png",
    featured: false,
  ),
  Product(
    id: "cookies-mini-cookies-16pcs",
    name: "Mini Cookies 16pcs",
    price: 130,
    category: "Pastries",
    subcategory: "Cookies",
    description: "A sweet little moment from our cookies selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/16 pcs 1.png",
    featured: false,
  ),
  Product(
    id: "muffins-choco-chip-muffin",
    name: "Choco Chip Muffin",
    price: 75,
    category: "Pastries",
    subcategory: "Muffins",
    description: "A sweet little moment from our muffins selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Choco Chip Muffin 1.png",
    featured: false,
  ),
  Product(
    id: "muffins-dark-choco-muffin",
    name: "Dark Choco Muffin",
    price: 75,
    category: "Pastries",
    subcategory: "Muffins",
    description: "A sweet little moment from our muffins selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Dark Choco Muffin 1.png",
    featured: false,
  ),
  Product(
    id: "cakes-moist-chocolate-cake",
    name: "Moist Chocolate Cake",
    price: 100,
    category: "Pastries",
    subcategory: "Cakes",
    description: "A sweet little moment from our cakes selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Moist Chocolate Cake 1.png",
    featured: false,
  ),
  Product(
    id: "cakes-no-bake-cheesecake",
    name: "No Bake Cheesecake",
    price: 170,
    category: "Pastries",
    subcategory: "Cakes",
    description: "A sweet little moment from our cakes selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/No Bake Cheesecake 2.png",
    featured: false,
  ),
  Product(
    id: "cakes-tiramisu",
    name: "Tiramisu",
    price: 180,
    category: "Pastries",
    subcategory: "Cakes",
    description: "A sweet little moment from our cakes selection. Enjoy it with a hot or iced coffee.",
    image: "assets/images/Tiramisu 1.png",
    featured: false,
  ),
  Product(
    id: "coffee-americano",
    name: "Americano",
    price: 60,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Americano 3.png",
    featured: false,
  ),
  Product(
    id: "coffee-latte",
    name: "Latte",
    price: 70,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-french-vanilla-latte",
    name: "French Vanilla Latte",
    price: 75,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/French Vanilla Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-mocha-latte",
    name: "Mocha Latte",
    price: 100,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Mocha Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-white-mocha-latte",
    name: "White Mocha Latte",
    price: 90,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/White Mocha Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-caramel-macchiato",
    name: "Caramel Macchiato",
    price: 95,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Caramel Macchiato 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-choco-hazelnut-latte",
    name: "Choco Hazelnut Latte",
    price: 95,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Choco Hazelnut Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-creamy-americano",
    name: "Creamy Americano",
    price: 95,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Creamy Americano 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-vanilla-ice-cream-latte",
    name: "Vanilla Ice Cream Latte",
    price: 100,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Vanilla Ice Cream Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-dirty-matcha-latte",
    name: "Dirty Matcha Latte",
    price: 115,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Dirty Matcha Latte 5.png",
    featured: false,
  ),
  Product(
    id: "coffee-dirty-ube-latte",
    name: "Dirty Ube Latte",
    price: 85,
    category: "Coffee",
    subcategory: "Coffee",
    description: "Your next coffee moment, from our espresso-based coffee selection. Made for your everyday cravings.",
    image: "assets/images/Dirty Ube Latte 5.png",
    featured: false,
  ),
  Product(
    id: "non-coffee-chocolate",
    name: "Chocolate",
    price: 195,
    category: "Non-Coffee",
    subcategory: "Non-Coffee",
    description: "Skip the espresso and find a little happiness in our non-coffee drink selection.",
    image: "assets/images/Chocolate 1.png",
    featured: false,
  ),
  Product(
    id: "non-coffee-strawberry-latte",
    name: "Strawberry Latte",
    price: 85,
    category: "Non-Coffee",
    subcategory: "Non-Coffee",
    description: "Skip the espresso and find a little happiness in our non-coffee drink selection.",
    image: "assets/images/Strawberry Latte 1.png",
    featured: false,
  ),
  Product(
    id: "non-coffee-matcha-latte",
    name: "Matcha Latte",
    price: 105,
    category: "Non-Coffee",
    subcategory: "Non-Coffee",
    description: "Skip the espresso and find a little happiness in our non-coffee drink selection.",
    image: "assets/images/Matcha Latte 1.png",
    featured: false,
  ),
  Product(
    id: "non-coffee-ube-latte",
    name: "Ube Latte",
    price: 75,
    category: "Non-Coffee",
    subcategory: "Non-Coffee",
    description: "Skip the espresso and find a little happiness in our non-coffee drink selection.",
    image: "assets/images/Ube Latte 1.png",
    featured: false,
  ),
  Product(
    id: "non-coffee-ube-matcha",
    name: "Ube Matcha",
    price: 105,
    category: "Non-Coffee",
    subcategory: "Non-Coffee",
    description: "Skip the espresso and find a little happiness in our non-coffee drink selection.",
    image: "assets/images/Ube Matcha.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-mocha",
    name: "Mocha",
    price: 125,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Mocha 6.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-white-mocha",
    name: "White Mocha",
    price: 115,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/White Mocha 6.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-caramel-macchiato",
    name: "Caramel Macchiato",
    price: 120,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Caramel Macchiato 7.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-choco-hazelnut",
    name: "Choco Hazelnut",
    price: 135,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Choco Hazelnut 7.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-chocolate",
    name: "Chocolate",
    price: 125,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Chocolate 5.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-strawberry",
    name: "Strawberry",
    price: 110,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Strawberry 6.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-matcha",
    name: "Matcha",
    price: 115,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Matcha 4.png",
    featured: false,
  ),
  Product(
    id: "ice-blended-ube",
    name: "Ube",
    price: 100,
    category: "Ice Blended",
    subcategory: "Ice Blended",
    description: "A cool, blended treat for a sweet afternoon break. Discover your favorite flavor.",
    image: "assets/images/Ube 2.png",
    featured: false,
  ),
  Product(
    id: "lava-series-chocolate-lava",
    name: "Chocolate Lava",
    price: 110,
    category: "More Drinks",
    subcategory: "Lava Series",
    description: "A refreshing little break from our lava series selection. A delicious way to complete your order.",
    image: "assets/images/Chocolate Lava 5.png",
    featured: false,
  ),
  Product(
    id: "lava-series-strawberry-lava",
    name: "Strawberry Lava",
    price: 135,
    category: "More Drinks",
    subcategory: "Lava Series",
    description: "A refreshing little break from our lava series selection. A delicious way to complete your order.",
    image: "assets/images/Strawberry Lava 5.png",
    featured: false,
  ),
  Product(
    id: "lava-series-ube-lava",
    name: "Ube Lava",
    price: 125,
    category: "More Drinks",
    subcategory: "Lava Series",
    description: "A refreshing little break from our lava series selection. A delicious way to complete your order.",
    image: "assets/images/Ube Lava 5.png",
    featured: false,
  ),
  Product(
    id: "lava-series-matcha-lava",
    name: "Matcha Lava",
    price: 155,
    category: "More Drinks",
    subcategory: "Lava Series",
    description: "A refreshing little break from our lava series selection. A delicious way to complete your order.",
    image: "assets/images/Matcha Lava 5.png",
    featured: false,
  ),
  Product(
    id: "chilled-drinks-bottled-water",
    name: "Bottled Water",
    price: 12,
    category: "More Drinks",
    subcategory: "Chilled Drinks",
    description: "A refreshing little break from our chilled drinks selection. A delicious way to complete your order.",
    image: "assets/images/Bottled Water 1.png",
    featured: false,
  ),
  Product(
    id: "chilled-drinks-calamansi-juice",
    name: "Calamansi Juice",
    price: 38,
    category: "More Drinks",
    subcategory: "Chilled Drinks",
    description: "A refreshing little break from our chilled drinks selection. A delicious way to complete your order.",
    image: "assets/images/Calamansi juice 1.png",
    featured: false,
  ),
  Product(
    id: "chilled-drinks-healthtea",
    name: "Healthtea",
    price: 15,
    category: "More Drinks",
    subcategory: "Chilled Drinks",
    description: "A refreshing little break from our chilled drinks selection. A delicious way to complete your order.",
    image: "assets/images/Healthtea 1.png",
    featured: false,
  ),
  Product(
    id: "chilled-drinks-healthtea-float",
    name: "Healthtea Float",
    price: 55,
    category: "More Drinks",
    subcategory: "Chilled Drinks",
    description: "A refreshing little break from our chilled drinks selection. A delicious way to complete your order.",
    image: "assets/images/Healthea Float 2.png",
    featured: false,
  ),
  Product(
    id: "dessert-affogato",
    name: "Affogato",
    price: 65,
    category: "More Drinks",
    subcategory: "Dessert",
    description: "A refreshing little break from our dessert selection. A delicious way to complete your order.",
    image: "assets/images/Affogato 4.png",
    featured: false,
  ),
  Product(
    id: "dessert-matcha-affogato",
    name: "Matcha Affogato",
    price: 85,
    category: "More Drinks",
    subcategory: "Dessert",
    description: "A refreshing little break from our dessert selection. A delicious way to complete your order.",
    image: "assets/images/Matcha Affogato 2.png",
    featured: false,
  ),
];
// END CAFE CATALOG

// ============================================================
// LOCAL MENU DATA
// ============================================================
class MenuRepository {
  const MenuRepository();

  List<Product> get products => cafeProducts;
}

// ============================================================
// SEARCH, CATEGORY FILTERS, AND CART STATE
// ============================================================
enum MenuSort {
  recommended('Cafe picks'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  name('Name: A–Z');

  const MenuSort(this.label);
  final String label;
}

class ShopController extends ChangeNotifier {
  ShopController({required this.repository, OrderStore? orderStore})
    : orderStore = orderStore ?? MemoryOrderStore();

  final MenuRepository repository;
  final OrderStore orderStore;
  final Map<String, CartItem> _cart = {};
  final List<OrderReceipt> _orders = [];
  bool _placingOrder = false;
  Future<void>? _restoreTask;
  int _nextOrderNumber = 1;
  String _query = '';
  String _category = 'All';
  MenuSort _sort = MenuSort.recommended;

  static const categories = [
    'All',
    'Coffee',
    'Non-Coffee',
    'Food',
    'Pastries',
    'Ice Blended',
    'More Drinks',
  ];

  String get query => _query;
  String get category => _category;
  MenuSort get sort => _sort;
  bool get placingOrder => _placingOrder;
  List<OrderReceipt> get orders => List.unmodifiable(_orders);
  bool get hasActiveFilters =>
      _query.trim().isNotEmpty ||
      _category != 'All' ||
      _sort != MenuSort.recommended;
  List<Product> get products => repository.products;
  List<Product> get filteredProducts => productsForCategory(_category);

  // Read-only projection for adjacent swipe pages; filtering rules stay shared.
  List<Product> productsForCategory(String category) {
    final matches = products.where((product) {
      final matchesCategory = category == 'All' || product.category == category;
      return matchesCategory && _matchesQuery(product);
    }).toList();
    switch (_sort) {
      case MenuSort.recommended:
        break;
      case MenuSort.priceLow:
        matches.sort((a, b) => a.price.compareTo(b.price));
      case MenuSort.priceHigh:
        matches.sort((a, b) => b.price.compareTo(a.price));
      case MenuSort.name:
        matches.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }
    return matches;
  }

  bool _matchesQuery(Product product) {
    final text = '${product.name} ${product.category} ${product.subcategory}'
        .toLowerCase();
    final words = _query.trim().toLowerCase().split(RegExp(r'\s+'));
    return words.every(text.contains);
  }

  int quantityOf(Product product) => _cart[product.id]?.quantity ?? 0;

  void sortBy(MenuSort value) {
    _sort = value;
    notifyListeners();
  }

  List<CartItem> get cartItems => List.unmodifiable(_cart.values);
  int get cartCount => _cart.values.fold(0, (sum, item) => sum + item.quantity);
  int get total => _cart.values.fold(0, (sum, item) => sum + item.total);

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  void selectCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void resetFilters() {
    _query = '';
    _category = 'All';
    _sort = MenuSort.recommended;
    notifyListeners();
  }

  void addToCart(Product product, {int quantity = 1}) {
    if (quantity < 1 || _placingOrder) return;
    final previous = _cart[product.id]?.quantity ?? 0;
    _cart[product.id] = CartItem(
      product: product,
      quantity: previous + quantity,
    );
    notifyListeners();
  }

  void decrease(Product product) {
    if (_placingOrder) return;
    final current = _cart[product.id];
    if (current == null) return;
    if (current.quantity == 1) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = CartItem(
        product: product,
        quantity: current.quantity - 1,
      );
    }
    notifyListeners();
  }

  void remove(Product product) {
    if (_placingOrder) return;
    _cart.remove(product.id);
    notifyListeners();
  }

  Future<void> restoreOrders() => _restoreTask ??= _loadOrders();

  Future<void> _loadOrders() async {
    final saved = await orderStore.read();
    if (saved == null) return;
    try {
      final data = jsonDecode(saved) as Map<String, dynamic>;
      final restored = (data['orders'] as List)
          .map((entry) => OrderReceipt.fromJson(entry as Map<String, dynamic>))
          .toList();
      _orders
        ..clear()
        ..addAll(restored);
      _nextOrderNumber = math.max(1, data['nextOrderNumber'] as int);
      notifyListeners();
    } on FormatException {
      // A damaged local record must not stop the menu from opening.
    } on TypeError {
      // Ignore a record from an incompatible older schema.
    }
  }

  String _encodeOrders({OrderReceipt? newOrder}) => jsonEncode({
    'nextOrderNumber': _nextOrderNumber + (newOrder == null ? 0 : 1),
    'orders': [
      if (newOrder != null) newOrder.toJson(),
      ..._orders.map((order) => order.toJson()),
    ],
  });

  Future<OrderReceipt?> submitOrder({
    required String customerName,
    required String mobileNumber,
    required String notes,
    required PaymentMethod paymentMethod,
  }) async {
    if (_cart.isEmpty || _placingOrder) return null;
    _placingOrder = true;
    notifyListeners();
    try {
      await restoreOrders();
      final order = OrderReceipt(
        reference: 'SMC-${_nextOrderNumber.toString().padLeft(4, '0')}',
        items: cartItems,
        customerName: customerName.trim(),
        mobileNumber: mobileNumber.trim(),
        notes: notes.trim(),
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );
      await orderStore.write(_encodeOrders(newOrder: order));
      _nextOrderNumber++;
      _orders.insert(0, order);
      _cart.clear();
      notifyListeners();
      return order;
    } finally {
      _placingOrder = false;
      notifyListeners();
    }
  }
}

// ============================================================
// MAIN APPLICATION
// ============================================================

class MiniShopApp extends StatefulWidget {
  const MiniShopApp({super.key, this.orderStore});
  final OrderStore? orderStore;

  @override
  State<MiniShopApp> createState() => _MiniShopAppState();
}

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
// SHARED WIDGETS
// ============================================================
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 125});
  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: width,
    height: width * .56,
    semanticLabel: 'Smooch Cafe',
    fit: BoxFit.contain,
  );
}

class ContentWidth extends StatelessWidget {
  const ContentWidth({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Center(
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1160),
      child: SizedBox(
        width: double.infinity,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color = AppColors.secondaryText});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.4,
      color: color,
    ),
  );
}

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
  });
  final Product product;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => Image.asset(
    product.image,
    fit: fit,
    semanticLabel: product.name,
    errorBuilder: (context, error, trace) => const ColoredBox(
      color: AppColors.softTeal,
      child: Center(
        child: Icon(Icons.coffee_outlined, size: 48, color: AppColors.teal),
      ),
    ),
  );
}

class CartButton extends StatelessWidget {
  const CartButton({
    super.key,
    required this.controller,
    required this.onPressed,
  });
  final ShopController controller;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => IconButton(
      tooltip: 'View cart',
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: controller.cartCount > 0,
        backgroundColor: AppColors.action,
        label: Text('${controller.cartCount}'),
        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.white),
      ),
    ),
  );
}

class QuantityPicker extends StatelessWidget {
  const QuantityPicker({
    super.key,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });
  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(28),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Decrease quantity',
          onPressed: onDecrease,
          icon: const Icon(Icons.remove, size: 18),
        ),
        SizedBox(
          width: 28,
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
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 48, color: AppColors.teal),
        const SizedBox(height: 20),
        Text(title, style: displayStyle(28), textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(color: AppColors.secondaryText, height: 1.7),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    ),
  );
}

// ============================================================
// 3D SPLASH SCREEN AND MENU TRANSITION
// ============================================================
class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.controller});

  final ShopController controller;
  static const duration = Duration(milliseconds: 4600);
  static const transitionDuration = Duration(milliseconds: 600);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _animation;
  late final AnimationController _idle;
  bool? _reducedMotion;
  bool _leaving = false;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
      animationBehavior: AnimationBehavior.preserve,
    );
    _animation =
        AnimationController(
          vsync: this,
          duration: StartScreen.duration,
          animationBehavior: AnimationBehavior.preserve,
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) _syncMotion();
        });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Decode the initial menu images while the intro is playing.
      final assets = <String>{
        'assets/images/Ice Blended Choco Hazelnut transparent.png',
        ...widget.controller.products.take(6).map((product) => product.image),
      };
      for (final asset in assets) {
        unawaited(precacheImage(AssetImage(asset), context));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reducedMotion == reduceMotion) return;
    _reducedMotion = reduceMotion;
    _syncMotion();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _syncMotion();
  }

  void _syncMotion() {
    if (_reducedMotion == true) {
      _animation.stop();
      _idle.stop();
      if (_animation.value != 1) _animation.value = 1;
    } else if (_reducedMotion != false || _leaving || !_foreground) {
      _animation.stop();
      _idle.stop();
    } else if (_animation.isCompleted) {
      if (!_idle.isAnimating) _idle.repeat();
    } else if (!_animation.isAnimating) {
      _animation.forward();
    }
  }

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
      );
    } finally {
      if (mounted) {
        setState(() => _leaving = false);
        _syncMotion();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animation.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.dark,
    body: DecoratedBox(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -.15),
          radius: .85,
          colors: [AppColors.teal, AppColors.dark, Color(0xFF062E35)],
          stops: [0, .57, 1],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            final sceneHeight = (constraints.maxHeight * .43).clamp(
              180.0,
              370.0,
            );
            return AnimatedBuilder(
              animation: _animation,
              builder: (context, _) {
                final progress = _animation.value;
                final reveal = Curves.easeOut.transform(
                  ((progress - .12) / .25).clamp(0.0, 1.0),
                );
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.auto_awesome_outlined,
                                  size: 16,
                                  color: AppColors.coral,
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'SMOOCH CAFE',
                                    style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1.6,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              BrandLogo(width: compact ? 142 : 178),
                              SizedBox(
                                width: math.min(constraints.maxWidth, 500),
                                height: sceneHeight,
                                child: RepaintBoundary(
                                  child: Semantics(
                                    label: 'A floating Smooch Cafe cup with orbiting coffee beans and rising steam',
                                    image: true,
                                    child: ExcludeSemantics(
                                      child: AnimatedBuilder(
                                        animation: _idle,
                                        builder: (context, _) => CustomPaint(
                                          key: const Key('coffee-scene'),
                                          painter: CoffeeScenePainter(
                                            progress: progress,
                                            idlePhase: _idle.value,
                                            reducedMotion:
                                                _reducedMotion ?? false,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Opacity(
                                opacity: _reducedMotion == true ? 1 : reveal,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    _reducedMotion == true
                                        ? 0
                                        : 16 * (1 - reveal),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'A little magic.',
                                        textAlign: TextAlign.center,
                                        style: displayStyle(
                                          compact ? 31 : 38,
                                          color: AppColors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'A lot of Smooch.',
                                        textAlign: TextAlign.center,
                                        style: displayStyle(
                                          compact ? 31 : 38,
                                          color: AppColors.coral,
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      const Text(
                                        'Your daily dose of happy starts here.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.7,
                                          color: AppColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: compact ? 26 : 36,
                              bottom: 28,
                            ),
                            child: Column(
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 360,
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: FilledButton.icon(
                                      key: const Key('enter-store'),
                                      onPressed: _leaving ? null : _openMenu,
                                      iconAlignment: IconAlignment.end,
                                      icon: const Icon(Icons.arrow_forward),
                                      label: const Text('ORDER NOW'),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size(48, 56),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 17),
                                const Text(
                                  'COFFEE. COMFORT. CONNECTION.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 8,
                                    letterSpacing: 1.9,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    ),
  );
}

class _MenuTransition extends StatelessWidget {
  const _MenuTransition({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: RepaintBoundary(child: child),
    builder: (context, menu) {
      // Finish covering the splash before the menu appears, avoiding ghosted
      // cup/text over the product grid during the MaterialPageRoute transition.
      final cover = const Interval(
        0,
        .4,
        curve: Curves.easeInOutCubic,
      ).transform(animation.value);
      final reveal = const Interval(
        .4,
        1,
        curve: Curves.easeInOutCubic,
      ).transform(animation.value);
      return Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            key: const Key('splash-fade-cover'),
            opacity: cover,
            child: const ColoredBox(color: AppColors.dark),
          ),
          ExcludeSemantics(
            excluding: animation.value < 1,
            child: IgnorePointer(
              ignoring: animation.value < 1,
              child: Opacity(
                key: const Key('menu-reveal'),
                opacity: reveal,
                child: Transform.translate(
                  offset: Offset(0, 18 * (1 - reveal)),
                  child: menu,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

// ============================================================
// MENU SCREEN
// ============================================================
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.controller});
  static const routeName = '/menu';
  final ShopController controller;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int tab = 0;
  final search = TextEditingController();
  final orderScroll = ScrollController();
  final cafeScroll = ScrollController();
  final categoryScrolls = List.generate(
    ShopController.categories.length,
    (_) => ScrollController(),
  );
  final featuredPages = PageController(viewportFraction: .9);
  late TabController categoryTabs;
  bool? reducedCategoryMotion;
  int featuredIndex = 0;
  ShopController get shop => widget.controller;

  @override
  void initState() {
    super.initState();
    search.text = shop.query;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (reducedCategoryMotion == reduced) return;
    final previousIndex = reducedCategoryMotion == null
        ? ShopController.categories.indexOf(shop.category)
        : categoryTabs.index;
    if (reducedCategoryMotion != null) {
      categoryTabs.removeListener(onCategoryPageChanged);
      categoryTabs.dispose();
    }
    categoryTabs = TabController(
      length: ShopController.categories.length,
      initialIndex: previousIndex,
      animationDuration: reduced
          ? Duration.zero
          : const Duration(milliseconds: 320),
      vsync: this,
    );
    categoryTabs.addListener(onCategoryPageChanged);
    if (reducedCategoryMotion == null) shop.addListener(syncCategoryTabs);
    reducedCategoryMotion = reduced;
  }

  @override
  void dispose() {
    search.dispose();
    if (reducedCategoryMotion != null) {
      shop.removeListener(syncCategoryTabs);
      categoryTabs.removeListener(onCategoryPageChanged);
      categoryTabs.dispose();
    }
    featuredPages.dispose();
    orderScroll.dispose();
    cafeScroll.dispose();
    for (final scroll in categoryScrolls) {
      scroll.dispose();
    }
    super.dispose();
  }

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
    final scroll = categoryScrolls[categoryTabs.index];
    if (scroll.hasClients && scroll.offset > 0) scroll.jumpTo(0);
  }

  void syncCategoryTabs() {
    final index = ShopController.categories.indexOf(shop.category);
    if (!mounted || index < 0 || categoryTabs.index == index) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      categoryTabs.index = index;
    } else {
      categoryTabs.animateTo(index);
    }
  }

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
    final target = category == shop.category && category != 'All'
        ? 'All'
        : category;
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

  void queryChanged(String query) {
    shop.search(query);
    resetPosition();
  }

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

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 900;
      final padding = wide ? 24.0 : 16.0;
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      final searchHeight = math.max(56.0, 14 * scale + 32);
      return ListenableBuilder(
        listenable: shop,
        builder: (context, _) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
              titleSpacing: 0,
              title: ContentWidth(
                padding: EdgeInsets.symmetric(horizontal: padding),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop()) ...[
                      IconButton(
                        tooltip: 'Back to start',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    const BrandLogo(width: 112),
                    const Spacer(),
                    if (wide) ...[
                      for (final entry in [
                        'Our menu',
                        'Order history',
                        'Our cafe',
                      ].asMap().entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: TextButton(
                            onPressed: () => selectTab(entry.key),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                              backgroundColor: tab == entry.key
                                  ? AppColors.white.withValues(alpha: .12)
                                  : null,
                              minimumSize: const Size(80, 48),
                            ),
                            child: Text(
                              entry.value,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 20),
                    ],
                    CartButton(controller: shop, onPressed: openCart),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: (wide && shop.cartCount == 0)
                ? null
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (shop.cartCount > 0)
                        _BagSummary(
                          controller: shop,
                          onPressed: openCart,
                          bottomSafeArea: wide,
                        ),
                      if (!wide)
                        NavigationBar(
                          selectedIndex: tab,
                          onDestinationSelected: selectTab,
                          height: 72,
                          destinations: const [
                            NavigationDestination(
                              icon: Icon(Icons.grid_view_outlined),
                              selectedIcon: Icon(
                                Icons.grid_view_rounded,
                                color: AppColors.dark,
                              ),
                              label: 'Our menu',
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.receipt_long_outlined),
                              selectedIcon: Icon(
                                Icons.receipt_long,
                                color: AppColors.dark,
                              ),
                              label: 'Order history',
                            ),
                            NavigationDestination(
                              icon: Icon(Icons.storefront_outlined),
                              selectedIcon: Icon(
                                Icons.storefront,
                                color: AppColors.dark,
                              ),
                              label: 'Our cafe',
                            ),
                          ],
                        ),
                    ],
                  ),
            body: tab == 0
                ? Column(
                    children: [
                      Material(
                        color: AppColors.canvas,
                        child: MenuFilters(
                          controller: shop,
                          search: search,
                          onQuery: queryChanged,
                          onCategory: selectCategory,
                          tabs: categoryTabs,
                          horizontalPadding: padding,
                          searchHeight: searchHeight,
                        ),
                      ),
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                              PointerDeviceKind.trackpad,
                              PointerDeviceKind.stylus,
                            },
                          ),
                          child: TabBarView(
                            key: const Key('menu-category-pages'),
                            controller: categoryTabs,
                            physics: const PageScrollPhysics(),
                            children: [
                              for (
                                var index = 0;
                                index < ShopController.categories.length;
                                index++
                              )
                                _MenuCategoryPage(
                                  key: PageStorageKey(
                                    'menu-category-${ShopController.categories[index]}',
                                  ),
                                  category: ShopController.categories[index],
                                  products: shop.productsForCategory(
                                    ShopController.categories[index],
                                  ),
                                  controller: shop,
                                  scroll: categoryScrolls[index],
                                  width: constraints.maxWidth,
                                  horizontalPadding: padding,
                                  wide: wide,
                                  featuredPages: featuredPages,
                                  featuredIndex: featuredIndex,
                                  onFeaturedPageChanged: (value) =>
                                      setState(() => featuredIndex = value),
                                  onReset: resetFilters,
                                  onSort: (value) {
                                    shop.sortBy(value);
                                    resetPosition();
                                  },
                                  onSearchAll: () => selectCategory('All'),
                                  onClearSearch: () {
                                    search.clear();
                                    queryChanged('');
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : tab == 1
                ? Column(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 680),
                          child: SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                24,
                                24,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Your orders', style: displayStyle(32)),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Find past orders and view the details.',
                                    style: TextStyle(
                                      color: AppColors.secondaryText,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _OrderHistoryContent(
                          controller: shop,
                          onBrowseMenu: () => selectTab(0),
                          scroll: orderScroll,
                        ),
                      ),
                    ],
                  )
                : CustomScrollView(
                    key: const PageStorageKey('menu-tab-cafe'),
                    controller: cafeScroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
                        child: ContentWidth(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 24, bottom: 14),
                            child: CafeSection(onBrowse: () => selectTab(0)),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 32,
                          ),
                          child: Center(
                            child: Text(
                              'A little Smooch goes a long way.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.secondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      );
    },
  );
}

class _MenuCategoryPage extends StatelessWidget {
  const _MenuCategoryPage({
    super.key,
    required this.category,
    required this.products,
    required this.controller,
    required this.scroll,
    required this.width,
    required this.horizontalPadding,
    required this.wide,
    required this.featuredPages,
    required this.featuredIndex,
    required this.onFeaturedPageChanged,
    required this.onReset,
    required this.onSort,
    required this.onSearchAll,
    required this.onClearSearch,
  });

  final String category;
  final List<Product> products;
  final ShopController controller;
  final ScrollController scroll;
  final double width;
  final double horizontalPadding;
  final bool wide;
  final PageController featuredPages;
  final int featuredIndex;
  final ValueChanged<int> onFeaturedPageChanged;
  final VoidCallback onReset;
  final ValueChanged<MenuSort> onSort;
  final VoidCallback onSearchAll;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final showFeatured = category == 'All' && controller.query.trim().isEmpty;
    return CustomScrollView(
      key: PageStorageKey('products-$category'),
      controller: scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (showFeatured) ...[
          SliverToBoxAdapter(
            child: ContentWidth(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('Smooch Cafe · Carmona'),
                    const SizedBox(height: 8),
                    Text(
                      'Made for your cravings.',
                      style: displayStyle(wide ? 38 : 29),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your favorite sip. Your next little treat.',
                      style: TextStyle(
                        color: AppColors.secondaryText,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _FeaturedCarousel(
              controller: controller,
              pages: featuredPages,
              currentPage: featuredIndex,
              onPageChanged: onFeaturedPageChanged,
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: ContentWidth(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.query.trim().isNotEmpty
                              ? 'Search results'
                              : category == 'All'
                              ? 'Explore the menu'
                              : category,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${products.length} ${products.length == 1 ? 'item' : 'items'}${controller.query.trim().isNotEmpty ? ' for “${controller.query.trim()}”' : ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (controller.hasActiveFilters) ...[
                    TextButton(
                      key: const Key('reset-menu-filters'),
                      onPressed: onReset,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.teal,
                        minimumSize: const Size(48, 48),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  PopupMenuButton<MenuSort>(
                    tooltip: 'Sort menu',
                    initialValue: controller.sort,
                    onSelected: onSort,
                    itemBuilder: (_) => [
                      for (final sort in MenuSort.values)
                        CheckedPopupMenuItem(
                          value: sort,
                          checked: controller.sort == sort,
                          child: Text(sort.label),
                        ),
                    ],
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 48),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.swap_vert, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            wide
                                ? controller.sort.label
                                : switch (controller.sort) {
                                    MenuSort.recommended => 'Sort',
                                    MenuSort.priceLow => 'Price ↑',
                                    MenuSort.priceHigh => 'Price ↓',
                                    MenuSort.name => 'A–Z',
                                  },
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (products.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              icon: Icons.search_off,
              title: 'No matches found.',
              message: category == 'All'
                  ? 'Try another name or clear your search.'
                  : 'Nothing matched in $category. Try searching all categories.',
              action: OutlinedButton(
                onPressed: category == 'All' ? onClearSearch : onSearchAll,
                child: Text(
                  category == 'All' ? 'Clear search' : 'Search all categories',
                ),
              ),
            ),
          )
        else
          _ProductGridSliver(
            products: products,
            controller: controller,
            width: width,
            horizontalPadding: horizontalPadding,
          ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Center(
              child: Text(
                'A little Smooch goes a long way.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductGridSliver extends StatelessWidget {
  const _ProductGridSliver({
    required this.products,
    required this.controller,
    required this.width,
    required this.horizontalPadding,
  });
  final List<Product> products;
  final ShopController controller;
  final double width;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: math.max(0, (width - 1160) / 2) + horizontalPadding,
      ),
      sliver: SliverLayoutBuilder(
        builder: (context, gridConstraints) {
          final gridWidth = gridConstraints.crossAxisExtent;
          final columns = scale > 1.3
              ? math.max(1, (gridWidth / (240 * scale)).floor()).clamp(1, 4)
              : gridWidth >= 1040
              ? 5
              : gridWidth >= 900
              ? 4
              : gridWidth >= 700
              ? 3
              : gridWidth >= 300
              ? 2
              : 1;
          final cardWidth = (gridWidth - 12 * (columns - 1)) / columns;
          return SliverGrid.builder(
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              mainAxisExtent: math.min(cardWidth * .76, 176) + 144 * scale,
            ),
            itemBuilder: (_, index) =>
                ProductCard(product: products[index], controller: controller),
          );
        },
      ),
    );
  }
}

class _FeaturedCarousel extends StatelessWidget {
  const _FeaturedCarousel({
    required this.controller,
    required this.pages,
    required this.currentPage,
    required this.onPageChanged,
  });
  final ShopController controller;
  final PageController pages;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final featured = controller.products
        .where((item) => item.featured)
        .take(5)
        .toList();
    if (featured.isEmpty) return const SizedBox.shrink();
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Eyebrow('Smooch picks · Swipe to explore'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 178 * scale.clamp(1, 1.5),
                child: PageView.builder(
                  key: const Key('featured-carousel'),
                  controller: pages,
                  itemCount: featured.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    final product = featured[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Material(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(22),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          key: Key('featured-${product.id}'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ProductDetailsScreen(
                                product: product,
                                controller: controller,
                              ),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                right: 0,
                                left: null,
                                child: SizedBox(
                                  width: 165,
                                  child: ProductImage(product: product),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.dark,
                                        AppColors.dark,
                                        AppColors.dark.withValues(alpha: .7),
                                        AppColors.dark.withValues(alpha: .06),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CAFE PICK',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 19 * scale.clamp(1, 1.3),
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          pesos(product.price),
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton.filledTonal(
                                          tooltip: 'Add ${product.name} to bag',
                                          onPressed: () =>
                                              controller.addToCart(product),
                                          icon: const Icon(Icons.add, size: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var index = 0; index < featured.length; index++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: index == currentPage ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: index == currentPage
                            ? AppColors.teal
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BagSummary extends StatelessWidget {
  const _BagSummary({
    required this.controller,
    required this.onPressed,
    required this.bottomSafeArea,
  });
  final ShopController controller;
  final VoidCallback onPressed;
  final bool bottomSafeArea;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      top: false,
      bottom: bottomSafeArea,
      child: ContentWidth(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Semantics(
          liveRegion: true,
          child: FilledButton(
            key: const Key('view-bag-summary'),
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.dark,
              minimumSize: const Size(double.infinity, 56),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: .15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${controller.cartCount}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'View bag',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  pesos(controller.total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// SEARCH AND CATEGORY FILTER CONTROLS
// ============================================================
class MenuFilters extends StatelessWidget {
  const MenuFilters({
    super.key,
    required this.controller,
    required this.search,
    required this.onQuery,
    required this.onCategory,
    required this.tabs,
    required this.horizontalPadding,
    required this.searchHeight,
  });

  final ShopController controller;
  final TextEditingController search;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onCategory;
  final TabController tabs;
  final double horizontalPadding;
  final double searchHeight;

  @override
  Widget build(BuildContext context) => ContentWidth(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: searchHeight,
            child: TextField(
              key: const Key('menu-search'),
              controller: search,
              onChanged: onQuery,
              style: const TextStyle(fontSize: 14),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: 'Search drinks, food or pastries',
                prefixIcon: const Icon(Icons.search, size: 22),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixIcon: controller.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          search.clear();
                          onQuery('');
                        },
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: TabBar(
              key: const Key('category-filters'),
              controller: tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.teal,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: AppColors.border,
              labelColor: AppColors.dark,
              unselectedLabelColor: AppColors.secondaryText,
              labelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 17),
              onTap: (index) => onCategory(ShopController.categories[index]),
              tabs: [
                for (final category in ShopController.categories)
                  Tab(key: Key('category-$category'), text: category),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// PRODUCT CARD
// ============================================================
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.controller,
  });
  final Product product;
  final ShopController controller;

  @override
  Widget build(BuildContext context) {
    final quantity = controller.quantityOf(product);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: Key('product-${product.id}'),
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
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(product: product),
                  if (product.featured)
                    Positioned(
                      left: 10,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Cafe pick',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ),
                  if (quantity > 0)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dark,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$quantity in bag',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.subcategory,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(15) * 2.7,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final scale =
                          MediaQuery.textScalerOf(context).scale(13) / 13;
                      final stacked = constraints.maxWidth < 150 * scale;
                      final price = Text(
                        pesos(product.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      );
                      final add = Tooltip(
                        message: 'Add ${product.name} to cart',
                        child: FilledButton.icon(
                          key: Key('add-${product.id}'),
                          onPressed: () => controller.addToCart(product),
                          icon: const Icon(Icons.add, size: 17),
                          label: Text(
                            constraints.maxWidth >= 230 * scale
                                ? 'Add to bag'
                                : 'Add',
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            minimumSize: const Size(68, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                      if (stacked) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            price,
                            const SizedBox(height: 8),
                            SizedBox(width: double.infinity, child: add),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: price),
                          const SizedBox(width: 8),
                          add,
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PRODUCT DETAILS SCREEN
// ============================================================
class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.controller,
  });
  final Product product;
  final ShopController controller;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('A little closer', style: TextStyle(fontSize: 15)),
      actions: [
        CartButton(
          controller: widget.controller,
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => CartScreen(controller: widget.controller),
            ),
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
    body: SingleChildScrollView(
      child: ContentWidth(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;
              return Flex(
                direction: wide ? Axis.horizontal : Axis.vertical,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    flex: wide ? 1 : 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: AspectRatio(
                        aspectRatio: wide ? 1 : 1.1,
                        child: ProductImage(product: widget.product),
                      ),
                    ),
                  ),
                  SizedBox(width: wide ? 44 : 0, height: wide ? 0 : 28),
                  Flexible(
                    flex: wide ? 1 : 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(widget.product.subcategory),
                        const SizedBox(height: 12),
                        Text(widget.product.name, style: displayStyle(38)),
                        const SizedBox(height: 18),
                        Text(
                          pesos(widget.product.price),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 18),
                        const Text(
                          'A little comfort in every order',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.product.description,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            height: 1.9,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'How many happy moments?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        QuantityPicker(
                          quantity: quantity,
                          onDecrease: quantity > 1
                              ? () => setState(() => quantity--)
                              : null,
                          onIncrease: () => setState(() => quantity++),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const Key('details-add-to-cart'),
                            onPressed: () {
                              widget.controller.addToCart(
                                widget.product,
                                quantity: quantity,
                              );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '$quantity × ${widget.product.name} added to your bag.',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.shopping_bag_outlined,
                              size: 18,
                            ),
                            label: Text(
                              'Add to bag • ${pesos(widget.product.price * quantity)}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Icon(
                              Icons.local_cafe_outlined,
                              color: AppColors.action,
                              size: 15,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Made with love at Smooch Cafe.',
                                softWrap: true,
                                style: TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// CART SCREEN
// ============================================================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.controller});
  final ShopController controller;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  ShopController get controller => widget.controller;
  List<CartItem> get items => controller.cartItems;
  int get itemCount => controller.cartCount;
  int get orderTotal => controller.total;

  void _openCheckout() {
    if (items.isEmpty) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CheckoutScreen(controller: controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Scaffold(
      appBar: AppBar(
        title: const Text('Your bag', style: TextStyle(fontSize: 16)),
      ),
      body: items.isEmpty
          ? Center(
              child: SingleChildScrollView(
                child: EmptyState(
                  icon: Icons.shopping_bag_outlined,
                  title: 'A little empty, for now.',
                  message:
                      'Your next favorite sip or bite is waiting on the menu.',
                  action: FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Explore the menu'),
                  ),
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ContentWidth(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 28, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('Good things in the bag'),
                          const SizedBox(height: 10),
                          Text(
                            'A craving, well curated.',
                            style: displayStyle(32),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$itemCount ${itemCount == 1 ? 'item' : 'items'} to brighten your day.',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ContentWidth(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CartRow(item: item, controller: controller),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
      bottomNavigationBar: items.isEmpty
          ? null
          : ColoredBox(
              color: AppColors.surface,
              child: SafeArea(
                child: ContentWidth(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            const Text('Total', style: TextStyle(fontSize: 16)),
                            Text(
                              pesos(orderTotal),
                              key: const Key('cart-total'),
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No order is sent to the cafe.',
                            style: TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const Key('open-checkout'),
                            onPressed: _openCheckout,
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward, size: 18),
                            label: const Text('Continue to checkout'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    ),
  );
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item, required this.controller});
  final CartItem item;
  final ShopController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 450;
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: compact ? 68 : 100,
                    height: compact ? 80 : 100,
                    child: ProductImage(product: item.product),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.subcategory.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${pesos(item.product.price)} each',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Remove ${item.product.name}',
                  onPressed: () => controller.remove(item.product),
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                QuantityPicker(
                  quantity: item.quantity,
                  onDecrease: () => controller.decrease(item.product),
                  onIncrease: () => controller.addToCart(item.product),
                ),
                Text(
                  pesos(item.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}

// ============================================================
// SAVED ORDERS
// ============================================================
class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key, required this.controller});
  final ShopController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Your orders', style: TextStyle(fontSize: 16)),
    ),
    body: _OrderHistoryContent(
      controller: controller,
      onBrowseMenu: () => Navigator.pop(context),
    ),
  );
}

class _OrderHistoryContent extends StatelessWidget {
  const _OrderHistoryContent({
    required this.controller,
    required this.onBrowseMenu,
    this.scroll,
  });

  final ShopController controller;
  final VoidCallback onBrowseMenu;
  final ScrollController? scroll;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => controller.orders.isEmpty
        ? Center(
            child: SingleChildScrollView(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No orders yet.',
                message: 'Your saved orders will appear here.',
                action: FilledButton(
                  onPressed: onBrowseMenu,
                  child: const Text('Browse the menu'),
                ),
              ),
            ),
          )
        : ListView.builder(
            key: const PageStorageKey('order-history-list'),
            controller: scroll,
            padding: const EdgeInsets.symmetric(vertical: 24),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = controller.orders[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 680),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                    child: Material(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        key: Key('history-${order.reference}'),
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
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.receipt_long,
                                    color: AppColors.teal,
                                    size: 26,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      order.reference,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.secondaryText,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                orderDate(order.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} · ${order.paymentStatus}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pesos(order.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
  );
}

// ============================================================
// CHECKOUT AND GCASH-STYLE PAYMENT DEMO
// ============================================================
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.controller});
  final ShopController controller;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController();
  final mobile = TextEditingController();
  final notes = TextEditingController();
  PaymentMethod payment = PaymentMethod.cash;
  bool busy = false;

  @override
  void dispose() {
    name.dispose();
    mobile.dispose();
    notes.dispose();
    super.dispose();
  }

  String? validateMobile(String? value) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(cleaned)) {
      return 'Enter a valid PH mobile number';
    }
    return null;
  }

  Future<void> placeOrder() async {
    if (busy || !form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      if (payment == PaymentMethod.digital) {
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
      final order = await widget.controller.submitOrder(
        customerName: name.text,
        mobileNumber: mobile.text,
        notes: notes.text,
        paymentMethod: payment,
      );
      if (!mounted || order == null) return;
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
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Checkout', style: TextStyle(fontSize: 16)),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow('Pickup details'),
                  const SizedBox(height: 10),
                  Text('Almost yours.', style: displayStyle(32)),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the details the cafe would use to identify your pickup order.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    key: const Key('customer-name'),
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full name *',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) => (value ?? '').trim().length < 2
                        ? 'Enter your name'
                        : null,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('customer-mobile'),
                    controller: mobile,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mobile number *',
                      hintText: '09XX XXX XXXX',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: validateMobile,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('customer-notes'),
                    controller: notes,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: const InputDecoration(
                      labelText: 'Pickup notes (optional)',
                      alignLabelWithHint: true,
                      hintText: 'Anything the cafe should know?',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Eyebrow('Payment method'),
                  const SizedBox(height: 12),
                  _PaymentChoice(
                    key: const Key('payment-cash'),
                    title: 'Cash at pickup',
                    subtitle: 'Pay when you collect your order',
                    icon: Icons.payments_outlined,
                    selected: payment == PaymentMethod.cash,
                    onTap: () => setState(() => payment = PaymentMethod.cash),
                  ),
                  const SizedBox(height: 10),
                  _PaymentChoice(
                    key: const Key('payment-digital'),
                    title: 'GCash',
                    subtitle: 'Preview a wallet payment; no money is taken',
                    icon: Icons.account_balance_wallet_outlined,
                    selected: payment == PaymentMethod.digital,
                    onTap: () =>
                        setState(() => payment = PaymentMethod.digital),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        Text(
                          '${widget.controller.cartCount} ${widget.controller.cartCount == 1 ? 'item' : 'items'} · Pickup',
                        ),
                        Text(
                          pesos(widget.controller.total),
                          key: const Key('checkout-total'),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No order will be sent to the cafe, and no payment will be taken.',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('place-order'),
                  onPressed: busy ? null : placeOrder,
                  icon: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward, size: 18),
                  iconAlignment: IconAlignment.end,
                  label: Text(
                    payment == PaymentMethod.cash
                        ? 'Place order'
                        : 'Continue to GCash',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PaymentChoice extends StatelessWidget {
  const _PaymentChoice({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? AppColors.softTeal : AppColors.surface,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.dark),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.teal : AppColors.secondaryText,
            ),
          ],
        ),
      ),
    ),
  );
}

abstract final class _WalletDemoColors {
  static const blue = Color(0xFF0958D9);
  static const deepBlue = Color(0xFF073DA7);
  static const paleBlue = Color(0xFFF3F7FF);
  static const text = Color(0xFF172B50);
  static const muted = Color(0xFF65738D);
}

enum _DemoPaymentStage { review, processing, success, failed }

class DemoPaymentScreen extends StatefulWidget {
  const DemoPaymentScreen({
    super.key,
    required this.amount,
    required this.checkoutMobile,
  });

  final num amount;
  final String checkoutMobile;

  @override
  State<DemoPaymentScreen> createState() => _DemoPaymentScreenState();
}

class _DemoPaymentScreenState extends State<DemoPaymentScreen> {
  _DemoPaymentStage stage = _DemoPaymentStage.review;

  String get maskedMobile {
    final digits = widget.checkoutMobile.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return 'Checkout mobile';
    return 'Checkout mobile ending ${digits.substring(digits.length - 4)}';
  }

  Future<void> pay() async {
    if (stage != _DemoPaymentStage.review) return;
    setState(() => stage = _DemoPaymentStage.processing);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() => stage = _DemoPaymentStage.success);
  }

  Widget paymentRow(String label, String value, {bool total = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: total
                      ? _WalletDemoColors.text
                      : _WalletDemoColors.muted,
                  fontWeight: total ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: _WalletDemoColors.text,
                  fontWeight: total ? FontWeight.w800 : FontWeight.w600,
                  fontSize: total ? 18 : 14,
                ),
              ),
            ),
          ],
        ),
      );

  Widget walletCard(Widget child) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14073DA7),
          blurRadius: 26,
          offset: Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );

  Widget reviewContent() => Column(
    key: const ValueKey('payment-review'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      walletCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PAY WITH',
              style: TextStyle(
                color: _WalletDemoColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _WalletDemoColors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    'G',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GCash wallet',
                        style: TextStyle(
                          color: _WalletDemoColors.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        maskedMobile,
                        style: const TextStyle(
                          color: _WalletDemoColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: _WalletDemoColors.blue,
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      walletCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'PAYMENT DETAILS',
              style: TextStyle(
                color: _WalletDemoColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 13),
            paymentRow('Merchant', 'Smooch Cafe'),
            paymentRow('Amount', pesos(widget.amount)),
            paymentRow('Service fee', pesos(0)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            paymentRow('Total', pesos(widget.amount), total: true),
          ],
        ),
      ),
      const SizedBox(height: 18),
      const _PaymentDemoNotice(),
    ],
  );

  Widget resultContent() {
    final success = stage == _DemoPaymentStage.success;
    final processing = stage == _DemoPaymentStage.processing;
    final icon = processing
        ? null
        : success
        ? Icons.check_rounded
        : Icons.close_rounded;
    return Column(
      key: ValueKey(stage),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        walletCard(
          Column(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: success
                      ? const Color(0xFFE6F7F0)
                      : processing
                      ? _WalletDemoColors.paleBlue
                      : const Color(0xFFFDEDEB),
                  shape: BoxShape.circle,
                ),
                child: processing
                    ? const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          color: _WalletDemoColors.blue,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        icon,
                        color: success
                            ? const Color(0xFF18835D)
                            : AppColors.action,
                        size: 40,
                      ),
              ),
              const SizedBox(height: 20),
              Semantics(
                liveRegion: true,
                child: Text(
                  processing
                      ? 'Processing payment'
                      : success
                      ? 'Payment successful'
                      : 'Payment failed',
                  key: processing
                      ? const Key('payment-processing')
                      : success
                      ? const Key('payment-success')
                      : const Key('payment-failure'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _WalletDemoColors.text,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                processing
                    ? 'Please wait a moment.'
                    : success
                    ? 'Your Smooch Cafe order is ready to confirm.'
                    : 'Your bag is safe. You can try again or return to checkout.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _WalletDemoColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(),
              paymentRow(success ? 'Paid to' : 'Merchant', 'Smooch Cafe'),
              paymentRow('Amount', pesos(widget.amount), total: true),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _PaymentDemoNotice(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      backgroundColor: _WalletDemoColors.paleBlue,
      appBar: AppBar(
        backgroundColor: _WalletDemoColors.deepBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'GCash',
          style: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
        ),
        actions: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .17),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'PREVIEW',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_WalletDemoColors.deepBlue, _WalletDemoColors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          switch (stage) {
                            _DemoPaymentStage.review => 'YOU ARE ABOUT TO PAY',
                            _DemoPaymentStage.processing =>
                              'PROCESSING PAYMENT',
                            _DemoPaymentStage.success => 'PAYMENT COMPLETE',
                            _DemoPaymentStage.failed => 'PAYMENT UNSUCCESSFUL',
                          },
                          style: const TextStyle(
                            color: Color(0xFFD6E5FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            pesos(widget.amount),
                            key: const Key('payment-amount'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: Colors.white,
                              child: Text(
                                'SC',
                                style: TextStyle(
                                  color: _WalletDemoColors.deepBlue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Smooch Cafe',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: stage == _DemoPaymentStage.review
                        ? reviewContent()
                        : resultContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton(
                      key: Key(
                        stage == _DemoPaymentStage.success
                            ? 'continue-after-payment'
                            : stage == _DemoPaymentStage.failed
                            ? 'retry-payment'
                            : 'pay-with-gcash',
                      ),
                      onPressed: switch (stage) {
                        _DemoPaymentStage.review => pay,
                        _DemoPaymentStage.processing => null,
                        _DemoPaymentStage.success => () => Navigator.pop(
                          context,
                          true,
                        ),
                        _DemoPaymentStage.failed => () => setState(
                          () => stage = _DemoPaymentStage.review,
                        ),
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: _WalletDemoColors.blue,
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: Text(switch (stage) {
                        _DemoPaymentStage.review =>
                          'Pay ${pesos(widget.amount)}',
                        _DemoPaymentStage.processing => 'Processing…',
                        _DemoPaymentStage.success => 'Continue to order',
                        _DemoPaymentStage.failed => 'Try again',
                      }),
                    ),
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
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: _WalletDemoColors.blue,
                          backgroundColor: Colors.transparent,
                        ),
                        child: const Text('Back to checkout'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentDemoNotice extends StatelessWidget {
  const _PaymentDemoNotice();

  @override
  Widget build(BuildContext context) => const Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.info_outline, color: _WalletDemoColors.blue, size: 18),
      SizedBox(width: 9),
      Expanded(
        child: Text(
          'Payment preview only. This is not connected to GCash and no money will be transferred.',
          style: TextStyle(
            color: _WalletDemoColors.muted,
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ),
    ],
  );
}

// ============================================================
// ORDER CONFIRMATION
// ============================================================
class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    super.key,
    required this.order,
    this.fromHistory = false,
  });
  static const routeName = '/order-confirmation';
  final OrderReceipt order;
  final bool fromHistory;

  void _continueShopping(BuildContext context) {
    if (fromHistory) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).popUntil(
      (route) => route.settings.name == MenuScreen.routeName || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Order confirmation', style: TextStyle(fontSize: 16)),
      leading: IconButton(
        tooltip: fromHistory ? 'Back to orders' : 'Back to menu',
        onPressed: () => _continueShopping(context),
        icon: const Icon(Icons.arrow_back),
      ),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.softTeal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.dark,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    'Order confirmed.',
                    style: displayStyle(32),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Thanks for a little Smooch. Your order details are below.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Eyebrow('Order reference'),
                      const SizedBox(height: 8),
                      SelectableText(
                        order.reference,
                        key: const Key('order-reference'),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} · Pickup order',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pickup for ${order.customerName}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      if (order.mobileNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(order.mobileNumber),
                      ],
                      if (order.notes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Note: ${order.notes}'),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        order.paymentMethod == PaymentMethod.cash
                            ? 'Cash at pickup · ${order.paymentStatus}'
                            : 'GCash · ${order.paymentStatus}',
                        key: const Key('confirmation-payment'),
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      for (final item in order.items)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.product.subcategory,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                spacing: 16,
                                runSpacing: 6,
                                children: [
                                  Text(
                                    '${item.quantity} × ${pesos(item.product.price)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  Text(
                                    pesos(item.total),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const Divider(),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            pesos(order.total),
                            key: const Key('confirmation-total'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Saved on this device only. Nothing was sent to the cafe, and no payment was taken.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('continue-shopping'),
                  onPressed: () => _continueShopping(context),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    fromHistory ? 'Back to orders' : 'Continue Shopping',
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

// ============================================================
// CAFE INFORMATION
// ============================================================
class CafeSection extends StatelessWidget {
  const CafeSection({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Eyebrow('Your neighborhood happy place'),
      const SizedBox(height: 14),
      Text(
        'Come for the coffee.\nStay for the comfort.',
        style: displayStyle(34),
      ),
      const SizedBox(height: 24),
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
          color: AppColors.softTeal,
          child: SizedBox(
            height: 240,
            width: double.infinity,
            child: Image.asset(
              'assets/images/landing1.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'A little about Smooch',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      const Text(
        'Black tea and coffee lovers dedicated to quality, sustainability, and the perfect cup. From handcrafted drinks to warm meals and freshly baked pastries, there’s comfort for every craving.',
        style: TextStyle(
          color: AppColors.secondaryText,
          fontSize: 14,
          height: 1.8,
        ),
      ),
      const SizedBox(height: 22),
      const _CafeInfo(
        icon: Icons.location_on_outlined,
        title: 'Find us',
        text: '447 JM Loyola Street, Carmona, Cavite',
      ),
      const _CafeInfo(
        icon: Icons.schedule,
        title: 'Opening hours',
        text: 'Monday–Sunday • 2:00 PM–11:00 PM',
      ),
      const _CafeInfo(
        icon: Icons.phone_outlined,
        title: 'Give us a call',
        text: '(0965) 760 8290',
      ),
      const _CafeInfo(
        icon: Icons.mail_outline,
        title: 'Say hello',
        text: 'smoochcafe25@gmail.com',
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: onBrowse,
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Explore our menu'),
      ),
    ],
  );
}

class _CafeInfo extends StatelessWidget {
  const _CafeInfo({
    required this.icon,
    required this.title,
    required this.text,
  });
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.teal, size: 22),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              SelectableText(
                text,
                style: const TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// ============================================================
// 3D COFFEE SCENE DRAWING
// ============================================================
// A small perspective renderer: the cup is a shaded surface of revolution.
// Faces are sorted by depth; visible lettering follows the curved cup surface.
class CoffeeScenePainter extends CustomPainter {
  CoffeeScenePainter({
    required this.progress,
    required this.reducedMotion,
    this.idlePhase = 0,
  });

  final double progress;
  final bool reducedMotion;
  final double idlePhase;
  static const _cream = Color(0xFFF5E8D6);
  static const _lid = Color(0xFFFFF5E8);
  static const _light = _Vector(-.45, .65, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final time = reducedMotion ? 1.0 : progress;
    final idleAngle = reducedMotion ? 0.0 : idlePhase * math.pi * 2;
    final arrival = reducedMotion
        ? 1.0
        : Curves.easeOutBack.transform((time / .25).clamp(0.0, 1.0));
    final turn = Curves.easeInOutCubic.transform(
      ((time - .05) / .78).clamp(0.0, 1.0),
    );
    final yaw = reducedMotion
        ? -.14
        : -.65 + math.pi * 2 * turn + .51 * turn + math.sin(idleAngle) * .18;
    final tilt = reducedMotion
        ? .27
        : .27 + math.sin(time * math.pi * 2 + idleAngle) * .08;
    final roll = reducedMotion
        ? -.08
        : -.08 + math.sin(time * math.pi * 2 + idleAngle) * .1;
    final float = reducedMotion
        ? 0.0
        : math.sin(time * math.pi * 3 + idleAngle) * .09;
    final unit = math.min(size.width / 4.5, size.height / 4.25);
    final center = Offset(size.width / 2, size.height * .51);

    _Vector rotate(_Vector p) {
      final x = p.x * math.cos(yaw) + p.z * math.sin(yaw);
      final z = -p.x * math.sin(yaw) + p.z * math.cos(yaw);
      final y = p.y * math.cos(tilt) - z * math.sin(tilt);
      final depth = p.y * math.sin(tilt) + z * math.cos(tilt);
      return _Vector(
        x * math.cos(roll) - y * math.sin(roll),
        x * math.sin(roll) + y * math.cos(roll),
        depth,
      );
    }

    Offset project(_Vector p) {
      final perspective = 7 / (7 - p.z);
      return center +
          Offset(p.x, -p.y - float) * (unit * perspective * arrival);
    }

    final glowRect = Rect.fromCenter(
      center: center,
      width: unit * 4.5,
      height: unit * 4.5,
    );
    canvas.drawOval(
      glowRect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4EB5AF).withValues(alpha: .21),
            AppColors.teal.withValues(alpha: 0),
          ],
        ).createShader(glowRect),
    );

    final shadow = Rect.fromCenter(
      center: center + Offset(0, unit * 1.65),
      width: unit * (2.15 - float),
      height: unit * .25,
    );
    canvas.drawOval(
      shadow,
      Paint()
        ..color = const Color(0xFF031D22)
            .withValues(alpha: .34 * arrival.clamp(0, 1))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, unit * .15),
    );

    // Fine orbital paths sit behind the sculpture; their moving beads add depth.
    for (var orbit = 0; orbit < 2; orbit++) {
      final path = Path();
      for (var i = 0; i <= 100; i++) {
        final angle = math.pi * 2 * i / 100;
        final point = project(
          _Vector(
            math.cos(angle) * (1.92 + orbit * .12),
            math.sin(angle) * (.44 + orbit * .15) - .1,
            math.sin(angle) * .6,
          ),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..color = AppColors.muted.withValues(alpha: orbit == 0 ? .19 : .08),
      );
    }

    final surfaces = <_Surface>[];
    final lettering = <_Surface>[];
    final beans = <_Surface>[];
    void addFace(List<_Vector> points, Color color, _Vector normal) {
      final transformed = points.map(rotate).toList(growable: false);
      final light = math.max(
        0.0,
        rotate(normal).normalized.dot(_light.normalized),
      );
      final brightness = .57 + .43 * light;
      final shade = Color.fromARGB(
        255,
        (color.r * 255 * brightness).round().clamp(0, 255),
        (color.g * 255 * brightness).round().clamp(0, 255),
        (color.b * 255 * brightness).round().clamp(0, 255),
      );
      final path = Path()..addPolygon(transformed.map(project).toList(), true);
      surfaces.add(
        _Surface(
          transformed.fold(0.0, (sum, p) => sum + p.z) / transformed.length,
          (canvas) {
            final paint = Paint()
              ..color = shade
              ..isAntiAlias = false;
            canvas.drawPath(path, paint);
            canvas.drawPath(
              path,
              paint
                ..style = PaintingStyle.stroke
                ..strokeWidth = .5,
            );
          },
        ),
      );
    }

    void lathe(List<(double, double)> rings, Color color) {
      const segments = 80;
      for (var ring = 0; ring < rings.length - 1; ring++) {
        final (bottom, lowerRadius) = rings[ring];
        final (top, upperRadius) = rings[ring + 1];
        for (var segment = 0; segment < segments; segment++) {
          final a = segment * math.pi * 2 / segments;
          final b = (segment + 1) * math.pi * 2 / segments;
          final middle = (a + b) / 2;
          addFace(
            [
              _Vector(
                lowerRadius * math.cos(a),
                bottom,
                lowerRadius * math.sin(a),
              ),
              _Vector(
                lowerRadius * math.cos(b),
                bottom,
                lowerRadius * math.sin(b),
              ),
              _Vector(
                upperRadius * math.cos(b),
                top,
                upperRadius * math.sin(b),
              ),
              _Vector(
                upperRadius * math.cos(a),
                top,
                upperRadius * math.sin(a),
              ),
            ],
            color,
            _Vector(
              math.cos(middle),
              (lowerRadius - upperRadius) / math.max(.001, top - bottom),
              math.sin(middle),
            ),
          );
        }
      }
    }

    // Adjacent material bands share edges instead of overlapping cylinders.
    lathe([(-1.33, .66), (-1.29, .70), (-.80, .751), (-.78, .775)], _cream);
    lathe([(-.72, .783), (.43, .901)], AppColors.teal);
    lathe([(-.78, .775), (-.72, .783)], AppColors.coral);
    lathe([(.43, .901), (.47, .907)], AppColors.coral);
    lathe([(.47, .907), (.49, .885), (1.02, .94), (1.09, .95)], _cream);
    lathe([
      (1.04, .96),
      (1.08, 1.035),
      (1.14, 1.04),
      (1.18, 1.0),
      (1.21, .975),
      (1.34, .93),
      (1.39, .87),
    ], _lid);
    addFace(
      List.generate(64, (i) {
        final angle = i * math.pi * 2 / 64;
        return _Vector(.87 * math.cos(angle), 1.39, .87 * math.sin(angle));
      }),
      _lid,
      const _Vector(0, 1, 0),
    );
    // The sip opening sits on the lid's top plane.
    addFace(
      List.generate(20, (i) {
        final angle = i * math.pi * 2 / 20;
        return _Vector(
          .22 * math.cos(angle),
          1.397,
          .57 + .07 * math.sin(angle),
        );
      }),
      const Color(0xFF715A49),
      const _Vector(0, 1, 0),
    );

    void label(
      String text,
      double y,
      double fontSize,
      double spacing,
      Color color,
    ) {
      for (var i = 0; i < text.length; i++) {
        final angle = math.pi / 2 - (i - (text.length - 1) / 2) * spacing;
        final radius = .70 + (y + 1.29) * .104 + .024;
        final position = rotate(
          _Vector(radius * math.cos(angle), y, radius * math.sin(angle)),
        );
        final normal = rotate(_Vector(math.cos(angle), 0, math.sin(angle)));
        if (normal.z <= .12) continue;
        final painter = TextPainter(
          text: TextSpan(
            text: text[i],
            style: TextStyle(
              color: color,
              fontSize: unit * fontSize,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        final projected = project(position);
        final perspective = 7 / (7 - position.z);
        lettering.add(
          _Surface(position.z + .025, (canvas) {
            canvas.save();
            canvas.translate(projected.dx, projected.dy);
            canvas.rotate(-roll);
            canvas.scale(
              perspective * arrival * normal.z,
              perspective * arrival,
            );
            painter.paint(
              canvas,
              Offset(-painter.width / 2, -painter.height / 2),
            );
            canvas.restore();
            painter.dispose();
          }),
        );
      }
    }

    label('SMOOCH', -.03, .265, .205, AppColors.white);
    label('CAFE', -.36, .14, .17, AppColors.white);

    for (var i = 0; i < 5; i++) {
      final angle =
          i * math.pi * 2 / 5 +
          (reducedMotion ? .3 : time * math.pi * 2 * .8 + idleAngle);
      final position = _Vector(
        math.cos(angle) * 1.74,
        math.sin(angle * 1.4 + i) * .8 + .1,
        math.sin(angle) * 1.5,
      );
      final point = project(position);
      final beanSize =
          unit * (.13 + i % 2 * .035) * 7 / (7 - position.z) * arrival;
      beans.add(
        _Surface(position.z, (canvas) {
          canvas.save();
          canvas.translate(point.dx, point.dy);
          canvas.rotate(angle + .55);
          final rect = Rect.fromCenter(
            center: Offset.zero,
            width: beanSize * 1.4,
            height: beanSize * 2.05,
          );
          canvas.drawOval(
            rect.shift(Offset(beanSize * .12, beanSize * .18)),
            Paint()
              ..color = Colors.black.withValues(alpha: .16)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, beanSize * .2),
          );
          canvas.drawOval(
            rect,
            Paint()
              ..shader = const RadialGradient(
                center: Alignment(-.6, -.5),
                radius: 1.4,
                colors: [
                  Color(0xFFC58A58),
                  Color(0xFF7C482E),
                  Color(0xFF3B211B),
                ],
                stops: [0, .5, 1],
              ).createShader(rect),
          );
          final seam = Path()
            ..moveTo(0, -beanSize * .85)
            ..cubicTo(
              -beanSize * .55,
              -beanSize * .25,
              beanSize * .5,
              beanSize * .2,
              0,
              beanSize * .85,
            );
          canvas.drawPath(
            seam,
            Paint()
              ..color = const Color(0xFF301F1A)
              ..style = PaintingStyle.stroke
              ..strokeWidth = beanSize * .13
              ..strokeCap = StrokeCap.round,
          );
          canvas.restore();
        }),
      );
    }

    beans.sort((a, b) => a.depth.compareTo(b.depth));
    for (final bean in beans.where((bean) => bean.depth < 0)) {
      bean.draw(canvas);
    }
    surfaces.sort((a, b) => a.depth.compareTo(b.depth));
    for (final surface in surfaces) {
      surface.draw(canvas);
    }
    for (final letter in lettering) {
      letter.draw(canvas);
    }
    for (final bean in beans.where((bean) => bean.depth >= 0)) {
      bean.draw(canvas);
    }

    // Steam is intentionally soft and sparse, keeping the cup as the focal point.
    for (var i = 0; i < 3; i++) {
      final phase = reducedMotion
          ? .45 + i * .1
          : (time * 1.8 + idlePhase * 2 + i / 3) % 1;
      final alpha = math.sin(phase * math.pi) * .24 * arrival.clamp(0, 1);
      final start = project(_Vector((i - 1) * .25, 1.46 + phase * .5, 0));
      final drift = math.sin(phase * math.pi * 2 + i) * unit * .13;
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + drift,
          start.dy - unit * .18,
          start.dx - drift,
          start.dy - unit * .34,
          start.dx + drift * .5,
          start.dy - unit * .49,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.white.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    for (var i = 0; i < 10; i++) {
      final angle = i * 2.4 + (reducedMotion ? 0 : time * .6 + idleAngle);
      final distance = 1.55 + (i % 3) * .22;
      final point = project(
        _Vector(math.cos(angle) * distance, math.sin(angle) * 1.5, -.5),
      );
      final pulse = reducedMotion
          ? .6
          : .45 + .3 * math.sin(time * 8 + idleAngle + i);
      canvas.drawCircle(
        point,
        i % 3 == 0 ? 2.1 : 1.2,
        Paint()
          ..color = (i.isEven ? AppColors.coral : AppColors.muted).withValues(
            alpha: pulse,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(CoffeeScenePainter oldDelegate) =>
      progress != oldDelegate.progress ||
      idlePhase != oldDelegate.idlePhase ||
      reducedMotion != oldDelegate.reducedMotion;
}

class _Vector {
  const _Vector(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;

  _Vector get normalized {
    final length = math.sqrt(x * x + y * y + z * z);
    return _Vector(x / length, y / length, z / length);
  }

  double dot(_Vector other) => x * other.x + y * other.y + z * other.z;
}

class _Surface {
  const _Surface(this.depth, this.draw);
  final double depth;
  final void Function(Canvas canvas) draw;
}

// ============================================================
// WIDGET PREVIEWS
// ============================================================
@Preview(name: '3D start screen / phone', size: Size(390, 844))
@Preview(name: '3D start screen / desktop', size: Size(1440, 900))
Widget splashPreview() => MaterialApp(
  theme: AppTheme.theme,
  home: StartScreen(
    controller: ShopController(repository: const MenuRepository()),
  ),
);

@Preview(name: 'Menu / phone', size: Size(390, 844))
@Preview(name: 'Menu / desktop', size: Size(1440, 1000))
Widget menuPreview() => MaterialApp(
  theme: AppTheme.theme,
  home: MenuScreen(
    controller: ShopController(repository: const MenuRepository()),
  ),
);
