# Smooch Cafe

A Flutter cafe shopping app adapted from the supplied **SmoochCafe** website and MiniShop starter code.

## Run

Use the installed Flutter SDK (Dart 3.13.1 or compatible):

```sh
flutter pub get
flutter run
```

For a browser preview, run `flutter run -d chrome`. For Android, connect a device or start an emulator, then select it with `flutter run`.

An installable debug APK is available after `flutter build apk --debug` at `build/app/outputs/flutter-apk/app-debug.apk`. Release web output is generated in `build/web/`.

## Included

- A 3D Start Screen with a shaded coffee cup, orbiting beans, steam, the Smooch logo, and a primary SHOP NOW button. After the 4.6-second intro, gentle cup motion, beans, and steam loop while waiting for the user to enter. Motion pauses in the menu or background and resumes on return; reduced-motion settings keep the scene still.
- SHOP NOW opens the menu using `Navigator.push()` and `MaterialPageRoute`. Back returns to the Start Screen; cart and favorites remain available when entering again. Rapid taps open one menu. Reduced-motion settings show a still composition.
- A coordinated 600 ms transition fades through teal before gently revealing the menu, configured through the Material page transition theme. Initial menu images are preloaded during the intro, and menu controls become active when the transition finishes.
- All 92 products from `SmoochCafe/pages/products.html`, using its names, prices, categories, and local product images.
- Pinned search and wrapping category chips keep every choice visible without category navigation arrows. Tap a selected category to return to All, or use Reset to clear search, category, and sorting together.
- A swipeable featured-product carousel gives the menu an image-led entry point. Product cards slide and fade in when categories or sorting change; search results use a shorter transition. Reduced-motion settings skip these effects.
- Search matches words in any order and ignores extra whitespace. Clearing search preserves the chosen category and sort order.
- Every `Product.category` matches a filter choice. Descriptive product labels, such as Quarter Pounder or Brownies, are kept in `Product.subcategory` and remain searchable.
- Product details, a favorites list, and browsing positions retained when switching tabs.
- Compact product cards with shorter photos, price/Add controls side by side, and up to five columns on wide screens. Cards adapt for larger text and retain in-bag quantities and a persistent bag summary with Philippine peso totals.
- Shared cart with quantities, item removal, and a live badge.
- The bag leads to checkout with required name and Philippine mobile number, optional pickup notes, and a choice of cash at pickup or demo digital payment. Digital payment can simulate success, failure, or cancellation. The bag stays intact until an order is saved successfully.
- Confirmation shows the saved receipt, customer details, payment method/status, products, quantities, and total. Order history reopens receipts after restarting the app, with references continuing in sequence. No order is sent to the cafe and no real payment is taken.
- Cafe location, hours, phone number, and email copied from the supplied website.
- Responsive phone, tablet, and desktop layouts, plus widget previews at the end of `lib/main.dart`.

Cart and favorites are kept in memory during the app session. Completed demo receipts and the next reference number are stored locally on the device with `shared_preferences`. The app has no backend or account system, so history does not sync across devices.

## Design

The app retains the website's dark teal `#0A4952`, teal `#0E6F7A`, and original coral `#F04C45` branding. Shopping screens use warm ivory `#F6F3ED`, white cards, and ink `#163B3D` for easier scanning. Primary buttons use deeper coral `#C23F38` for 5.17:1 contrast with white labels. The 3D splash retains its dark teal atmosphere.

Montserrat and Playfair Display are bundled locally, with their open font licenses in `assets/fonts/`. The supplied logo and photos are bundled as Flutter assets. See [the menu UI/UX audit](docs/menu-ui-ux-audit.md) for findings, color measurements, and before/after captures.

## Code

```text
lib/
  main.dart                  Complete application, following the starter layout
```

All application Dart code is in `lib/main.dart`, just like the supplied base code. `main()` runs `MiniShopApp`. Section comments separate colors/theme, product models and data, shopping state, the main application, shared widgets, Start Screen/transition, menu/filter controls, product cards, product details, cart, checkout, demo payment, order history/confirmation, cafe information, the 3D painter, and widget previews. There are no local Dart imports or `part` files.

Product photos, the logo, and cafe images are in `assets/images/`; fonts are in `assets/fonts/`. Both are declared in `pubspec.yaml`. Tests live under `test/` and import `main.dart`.

The original Flutter starter is preserved in `docs/flutter_starter.dart.txt`. The app runs from the catalog in `main.dart` and the bundled assets; the original website folder is optional.

Edit products directly in the `PRODUCT DATA` section of `main.dart`. If the original website is available at `SmoochCafe/pages/products.html`, you can also regenerate the catalog with Node.js:

```sh
node tools/import_menu.mjs
dart format lib/main.dart
```

The importer updates only the `BEGIN CAFE CATALOG` / `END CAFE CATALOG` section inside `main.dart`. It checks image paths, including filename capitalization, and creates separate IDs for similarly named products in different categories. Descriptions are adapted for the app; names, prices, and categories come from the supplied menu.

## Verify

```sh
flutter analyze
flutter test
flutter build web
```

The tests cover catalog assets and IDs, filtering, sorting, carousel swiping, result animation, cart/favorites, checkout validation, demo payment outcomes, failed storage safety, receipt restoration and references after restart, confirmation/history navigation, reduced motion, and narrow-screen layouts with the bundled fonts.
