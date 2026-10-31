# Fix: Show readable order dates in the customer's locale

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-date-times
- **Needs new dependency**: intl for DateFormat and locale data; reuse a direct intl dependency if already added.

## Why

History and receipts use a manually assembled year-month-day timestamp. Apply the article's shared DateFormat helper and locale initialization while keeping stored timestamps and delivery progression unchanged.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Only two user-facing order-date call sites: the history card and reopened receipt subtitle. The createdAt JSON value and stageAt arithmetic are storage/business data, not display strings. Cafe opening hours are a published schedule string, not a DateTime value.

### lib/main.dart:18

```dart
void main() {
  runApp(MiniShopApp(orderStore: PreferencesOrderStore()));
}
```

### lib/main.dart:295

```dart
String orderDate(DateTime value) {
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
```

### lib/main.dart:4466

```dart
                              const SizedBox(height: 10),
                              Text(
                                orderDate(order.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
```

### lib/main.dart:6304

```dart
                Text(
                  fromHistory
                      ? orderDate(order.createdAt)
                      : 'Follow your order progress below.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.secondaryText,
```

### lib/main.dart:400

```dart
    'reference': reference,
    'items': items.map((item) => item.toJson()).toList(),
    'customerName': customerName,
    'mobileNumber': mobileNumber,
    'notes': notes,
    'paymentMethod': paymentMethod.name,
    'createdAt': createdAt.toIso8601String(),
    'fulfillment': fulfillment.name,
    'deliveryAddress': deliveryAddress,
    'deliveryLatitude': deliveryLatitude,
```

### pubspec.yaml:35 — dependency insertion area; let pub add update the lockfile

```yaml
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.6
  flutter_map: ^8.3.2
  geolocator: ^14.1.2
  geocoding: ^5.0.1
  http: ^1.6.0
  latlong2: ^0.10.1
  url_launcher: ^6.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
```

## The fix

Add imports for package:intl/intl.dart and package:intl/date_symbol_data_local.dart. Initialize locale data before runApp:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(MiniShopApp(orderStore: PreferencesOrderStore()));
}
```

If other startup hooks already exist, preserve them in their existing order before runApp. Replace orderDate with:

```dart
String orderDate(DateTime value, {bool detailed = false, String? locale}) {
  final requested = locale ?? Intl.canonicalizedLocale(
    WidgetsBinding.instance.platformDispatcher.locale.toString());
  DateFormat make(String code) => (detailed
      ? DateFormat.yMMMMd(code) : DateFormat.yMMMd(code)).add_jm();
  DateFormat formatter;
  try { formatter = make(requested); }
  catch (_) { formatter = make('en_US'); }
  return formatter.format(value.toLocal());
}
```

The article's short/full month distinction is implemented with locale-aware skeletons so date order and hour cycle follow the locale. History keeps orderDate(order.createdAt); the receipt uses orderDate(order.createdAt, detailed: true). Do not initialize dates on every build and never parse displayed strings for tracking.

## Steps

1. Run `rtk flutter pub add intl` only if no direct dependency exists.
2. Initialize date locale data in main, preserving other startup hooks, and replace the display helper in lib/main.dart.
3. Use detailed: true only on the reopened receipt; leave ISO serialization and ten-second stage arithmetic unchanged.
4. Add test/order_date_locale_test.dart; initialize date data in its setup and test en_PH/de_DE, local conversion, short/full month forms and receipt/history integration.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'DateFormat|initializeDateFormatting|detailed: true' lib/main.dart` finds the helper/startup and detail call.
- `rtk flutter test test/order_date_locale_test.dart` passes. Stored createdAt remains an ISO string and tracking still changes every ten seconds.
- Open old history and its receipt; dates are readable and match the same local instant.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not migrate stored dates, alter time zones/UTC calculations, change store hours or add a full localization system.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe readable localized dates and point to an order in history and its reopened receipt. Report the checks actually executed and any remaining device or hosting verification.
