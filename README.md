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
- On Android and iOS, a coordinated 600 ms transition fades through teal before gently revealing the menu. Browser and desktop routes open immediately. Initial menu images are preloaded during the intro; the remaining cafe images are warmed one at a time in the background within Flutter's existing cache limits.
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
- Scroll-aware edge fades hint at sideways browsing, scrolling content clears system controls, and long pages use a single scrollbar. Tapping the active main destination returns to the top; tapping Our menu again at the top focuses search. The active page supplies the iPhone tap-to-top scroll controller.
- Checkout groups Philippine mobile digits as you type, supports a multiline address, and dismisses the keyboard while scrolling or opening Sort. Peso amounts, counts, and receipt dates follow the device locale; changing numeric values use tabular figures. Text selection uses the cafe teal, and enlarged text is supported up to 2×.
- Supported phones provide subtle haptic feedback for important actions and results. Cafe info includes the installed version. A branded error fallback adapts to the failed widget's space and hides technical details in release builds.
- Browser startup shows a lightweight branded loading view until Flutter draws its first frame. Browser tab titles follow pages, products, and main destinations, including Back navigation.

The bag is kept in memory during the app session. Completed receipts and the next reference number are stored locally on the device with `shared_preferences`. History has loading/error feedback and retry for read failures; corrupt individual records are skipped while valid receipts are retained. References are also checked against restored records. The app has no backend or account system, so history does not sync across devices.

The map needs internet access. GPS permission is requested only after the customer chooses **Use GPS** or **Use my location**; manually placing a pin does not request it. A manual pin takes precedence over a pending GPS response. Address suggestions first use OpenStreetMap/Nominatim, with device geocoding as a fallback on Android, iOS, and macOS. Blank or serialized `null` address parts are omitted. Lookup failures still allow a valid pin, and accepting a suggestion is explicit when the customer has typed an address. Delivery pins must be within 10 km of Carmona; checkout also validates the typed delivery area. Browser GPS requires HTTPS or localhost. If location access is unavailable, customers can still enter the delivery address manually. Set `MAP_TILE_URL` with `--dart-define` to use a different compatible tile provider for larger deployments.

Release notes live in the `releaseNotes` map in `main.dart`. On a future version upgrade, relevant notes appear once on the Start Screen; first installation skips the dialog. Add an entry matching the next release's version when preparing that release. This implementation keeps the current `1.0.0+1` version. The `smooch_last_seen_version` preference is separate from saved receipts.

The 1200 × 630 share card is ready at `web/og-image.png`. There is no public URL yet, so crawler metadata is intentionally waiting for hosting. Once a public HTTPS URL is known, run `node tools/configure_web_preview.mjs <public-HTTPS-URL>` and rebuild web. The tool writes static Open Graph/X tags, preserves hosted subpaths, and can be rerun without duplicating tags. After deployment, verify that the page and absolute image URL are publicly accessible. This tool does not publish the app.

## Design

The app retains the website's dark teal `#0A4952`, teal `#0E6F7A`, and original coral `#F04C45` branding. Shopping screens use warm ivory `#F6F3ED`, white cards, and ink `#163B3D` for easier scanning. Primary buttons use deeper coral `#C23F38` for 5.17:1 contrast with white labels. The 3D splash retains its dark teal atmosphere. The wallet screen uses blue to evoke the GCash payment flow and marks itself as a preview.

Montserrat and Playfair Display are bundled locally, with their open font licenses in `assets/fonts/`. The supplied logo and photos are bundled as Flutter assets. See [the design implementation report](docs/improvements/design/implementation.md) for the latest 25-plan status and validation. The [complete application audit](docs/application-audit-2026-10-29.md) and [earlier menu UI/UX audit](docs/menu-ui-ux-audit.md) record earlier changes, assignment compliance, and color measurements.

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
node --test test/web_preview_test.mjs
flutter build web
flutter build apk --debug
```

The 82 Flutter tests cover catalog assets and IDs, filters and swipes, category synchronization, bag/Undo, checkout validation, payment outcomes, storage safety, receipt history, GPS/manual-pin races, address lookup failures, reduced motion, narrow/large-text layouts, localized formatting, phone editing, release notes, navigation reselect and titles, scroll hints/insets, version metadata, and the error fallback. Two Node tests cover share-metadata setup. Browser checks exercised splash → menu → details → bag → map/checkout → payment failure/cancellation/success → receipt/history, plus tablet and desktop layouts. Native haptics, the physical iPhone status-bar gesture, GPS accuracy, and native geocoding still require checks on devices; these checks do not establish device frame rates.
