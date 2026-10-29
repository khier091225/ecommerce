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

- A 3D Start Screen with a shaded coffee cup, orbiting beans, steam, the Smooch logo, and a primary ORDER NOW button. The 2.4-second intro runs alongside immediately readable copy and a usable button; gentle cup motion, beans, and steam then loop while waiting for the user to enter. Wide screens place the copy and coffee scene side by side. Motion pauses in the menu or background and resumes on return; reduced-motion settings keep the scene still. Animation rebuilds are isolated from the static Start Screen layout.
- ORDER NOW opens the menu using `Navigator.push()` and `MaterialPageRoute`. Back returns to the Start Screen; the bag remains available when entering again. Rapid taps open one menu. Reduced-motion settings show a still composition.
- A coordinated 600 ms transition fades through teal before gently revealing the menu, configured through the Material page transition theme. Initial menu images are preloaded during the intro, and menu controls become active when the transition finishes.
- All 92 products from `SmoochCafe/pages/products.html`, using its names, prices, categories, and local product images.
- Search and a horizontally scrollable category tab rail stay visible above the menu. The selected category scrolls into view and has a moving teal underline; there are no category arrows. Tapping the active category keeps it selected. Choose All to browse every category, or use Reset to clear search, category, and sorting together.
- Product grids follow horizontal swipes using `TabBarView`, keeping the active tab and displayed products in sync. The featured-product carousel remains on All and shows untinted product photos beside a dark text panel. Reduced-motion settings make category taps jump directly to the selected page.
- Search matches words in any order and ignores extra whitespace. Clearing search preserves the chosen category and sort order.
- Every `Product.category` matches a filter choice. Descriptive product labels, such as Quarter Pounder or Brownies, are kept in `Product.subcategory` and remain searchable.
- Product details with a persistent quantity/Add to bag footer, an Order History tab with saved receipts, and browsing positions retained when switching tabs.
- Compact product cards with shorter photos, price/Add controls side by side, and up to five columns on wide screens. Cards adapt for larger text and retain in-bag quantities and a persistent bag summary with Philippine peso totals. Adding an item sends its photo along a curved path to the bag icon, briefly shows a teal “Added” confirmation, and pulses the bag icon. Product details returns to the menu after the flight. Reduced-motion settings skip the movement.
- Shared cart with quantities, item removal, Undo, and a live badge. Bag contents and totals use a comfortable reading width on desktop.
- The bag leads to delivery-only checkout with required name, Philippine mobile number, and delivery address, plus optional notes and cash or a GCash-style payment preview. Choose a destination by tapping an OpenStreetMap map or request GPS location with **Use GPS**. The selected pin is saved with the order and shown on its receipt. Check and edit the street and house number before ordering. The wallet screen shows the checkout amount and masked mobile, then previews processing, success, failure, or cancellation. It never asks for a PIN or OTP, is not connected to GCash, and takes no money. The bag stays intact until an order is saved successfully.
- Checkout groups contact, delivery, and payment details, supports autofill, and keeps the order total beside the primary action. Invalid submissions scroll to the first field needing attention; errors update as the customer corrects them. A delivery pin can be moved or removed, and manual address edits are preserved. Failed saving leaves the bag intact.
- Delivery receipts show five stages: Confirmed, Preparing, Rider assigned, On the way, and Delivered, advancing every 10 seconds. Order History shows the current stage and reopens receipts after restarting the app. The stage is calculated from the saved order time, so it catches up when the app reopens. Older pickup receipts remain readable in history; new orders are delivery-only. The receipt also shows customer details, address and destination map when available, payment method/status, products, quantities, and total. References continue in sequence. These stages still run locally: no order is sent to the cafe, no real rider is assigned or tracked, and no real payment is taken. Digital receipts say **Payment step complete**. Customer-facing text uses natural order labels without the words demo, simulated, or simulation; the wallet retains its payment-preview notice.
- Cafe info shows location, hours, phone number, and email copied from the supplied website, with actions to open the device's phone or email application.
- Responsive phone, tablet, and desktop layouts, plus widget previews at the end of `lib/main.dart`.

The bag is kept in memory during the app session. Completed receipts and the next reference number are stored locally on the device with `shared_preferences`. History has loading/error feedback and retry for read failures; corrupt individual records are skipped while valid receipts are retained. References are also checked against restored records. The app has no backend or account system, so history does not sync across devices.

The map needs internet access. GPS permission is requested only after the customer chooses **Use GPS** or **Use my location**; manually placing a pin does not request it. A manual pin takes precedence over a pending GPS response. Android, iOS, and macOS can suggest an address from a selected location through the device geocoding service; a failed or timed-out lookup still allows the pin to be used. Browser builds keep the address field editable because that geocoding plugin does not support web. Browser GPS requires HTTPS or localhost. If location access is unavailable, customers can still enter the delivery address manually. Set `MAP_TILE_URL` with `--dart-define` to use a different compatible tile provider for larger deployments.

## Design

The app retains the website's dark teal `#0A4952`, teal `#0E6F7A`, and original coral `#F04C45` branding. Shopping screens use warm ivory `#F6F3ED`, white cards, and ink `#163B3D` for easier scanning. Primary buttons use deeper coral `#C23F38` for 5.17:1 contrast with white labels. The 3D splash retains its dark teal atmosphere. The simulated wallet screen uses blue to evoke the GCash payment flow and marks itself as a preview.

Montserrat and Playfair Display are bundled locally, with their open font licenses in `assets/fonts/`. The supplied logo and photos are bundled as Flutter assets. See [the complete application audit](docs/application-audit-2026-10-29.md) for current changes, screenshots, validation, and assignment compliance. The [earlier menu UI/UX audit](docs/menu-ui-ux-audit.md) records the original color measurements and menu refinements.

## Code

```text
lib/
  main.dart                  Complete application, following the starter layout
```

All application Dart code is in `lib/main.dart`, just like the supplied base code. `main()` runs `MiniShopApp`. Section comments separate colors/theme, product models and data, shopping state, the main application, shared widgets, Start Screen/transition, menu/filter controls, product cards, product details, cart, checkout, payment preview, order history/confirmation, cafe information, the 3D painter, and widget previews. There are no local Dart imports or `part` files.

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
dart format lib/main.dart
flutter analyze
flutter test
flutter build web
```

The 63 tests cover catalog assets and IDs, filtering, sorting, featured and category swipes, active tab synchronization, automatic category visibility, the bag and Undo, checkout validation and correction, payment outcomes, failed storage safety, partial receipt corruption, retry after a storage read failure, references after restart, Order History navigation, GPS/manual-pin races, address lookup failures, reduced motion, and narrow/large-text layouts with bundled fonts. Native GPS accuracy and native geocoding still require checks on a physical device; browser screenshots and widget tests do not establish device frame rates.
