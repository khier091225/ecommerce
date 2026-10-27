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

- Animated splash with a shaded 3D coffee cup, orbiting beans, steam, and the Smooch logo. It automatically opens the menu after 4.6 seconds; “Skip intro” opens it immediately.
- The splash replaces its navigation route, so Back never returns to the intro. Reduced-motion settings show a still composition with a short transition into the menu.
- A coordinated 1.1-second transition fades the splash into teal before gently revealing the menu. Initial menu images are preloaded during the intro, and menu controls become active when the transition finishes.
- All 92 products from `SmoochCafe/pages/products.html`, using its names, prices, categories, and local product images.
- Pinned search, one category strip with scroll arrows when needed, and price/name sorting.
- Search matches words in any order and ignores extra whitespace. Clearing search preserves the chosen category and sort order.
- Product details, a favorites list, and browsing positions retained when switching tabs.
- Clear product-card add buttons, in-bag quantities, and a persistent bag summary with Philippine peso totals.
- Shared cart with quantities, item removal, and a live badge.
- Preview checkout with an order summary. It does not submit orders or process payments.
- Cafe location, hours, phone number, and email copied from the supplied website.
- Responsive phone, tablet, and desktop layouts, plus widget previews at the end of `lib/main.dart`.

Cart and favorites are kept in memory during the app session. Restarting the app resets them. The app has no backend or account system.

## Design

The app retains the website's dark teal `#0A4952`, teal `#0E6F7A`, and original coral `#F04C45` branding. Shopping screens use warm ivory `#F6F3ED`, white cards, and ink `#163B3D` for easier scanning. Primary buttons use deeper coral `#C23F38` for 5.17:1 contrast with white labels. The 3D splash retains its dark teal atmosphere.

Montserrat and Playfair Display are bundled locally, with their open font licenses in `assets/fonts/`. The supplied logo and photos are bundled as Flutter assets. See [the menu UI/UX audit](docs/menu-ui-ux-audit.md) for findings, color measurements, and before/after captures.

## Code

```text
lib/
  main.dart                  Complete application, following the starter layout
```

All application Dart code is in `lib/main.dart`, just like the supplied base code. `main()` runs `MiniShopApp`. Section comments separate colors/theme, product models and data, shopping state, the main application, shared widgets, splash/transition, menu/filter controls, product cards, product details, cart, cafe information, the 3D painter, and widget previews. There are no local Dart imports or `part` files.

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

The tests cover catalog assets and IDs, search/category combinations and recovery, sorting, same-name product variants, cart totals and removal, favorites, persistent bag actions, pinned filters, tab scroll restoration, larger text, key color contrast pairs, splash completion and skipping, reduced motion, animation disposal, product quantity selection, preview checkout, and layouts at 320, 390, 768, and 1440 pixels.
