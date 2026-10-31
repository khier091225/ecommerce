# Fix: Make peso totals and quantities easy to read

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-numbers-for-humans
- **Needs new dependency**: intl for NumberFormat, as used by the article.

## Why

The shared peso helper prints ungrouped digits and counts are interpolated directly. Use the article's NumberFormat approach for amounts and quantities, keeping the currency PHP and arithmetic unchanged.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Shared pesos changes all price/amount calls in featured picks, bag summary, product card/details, Add button, bag rows/total, history, checkout, wallet rows/hero/button, receipt rows/total. Raw count text occurs in CartButton, QuantityPicker, result count, bag summary, in-bag label, cart heading, history summary, checkout summary, receipt summary/line quantity and details Add feedback. Do not format IDs, references, GPS coordinates, phone numbers, dates or sort labels as quantities.

### lib/main.dart:254

```dart
String pesos(num amount) => '\u20b1${amount.toStringAsFixed(2)}';

String normalizedMobile(String value) => value.replaceAll(RegExp(r'[\s-]'), '');
```

### lib/main.dart:1903

```dart
            isLabelVisible: widget.controller.cartCount > 0,
            backgroundColor: AppColors.action,
            label: Text('${widget.controller.cartCount}'),
            child: const Icon(
```

### lib/main.dart:2086

```dart
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 28),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
```

### lib/main.dart:2998

```dart
                        const SizedBox(height: 4),
                        Text(
                          '${products.length} ${products.length == 1 ? 'item' : 'items'}${controller.query.trim().isNotEmpty ? ' for “${controller.query.trim()}”' : ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
```

### lib/main.dart:3274

```dart
                                              Text(
                                                pesos(product.price),
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
```

### lib/main.dart:3380

```dart
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
```

### lib/main.dart:3754

```dart
                        ),
                        child: Text(
                          '$quantity in bag',
                          style: const TextStyle(
                            color: AppColors.white,
```

### lib/main.dart:3802

```dart
                      final price = Text(
                        pesos(product.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      );
```

### lib/main.dart:3936

```dart
                        const SizedBox(height: 18),
                        Text(
                          pesos(widget.product.price),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
```

### lib/main.dart:4030

```dart
                  label: Text(
                    adding
                        ? 'Added to bag'
                        : 'Add to bag • ${pesos(widget.product.price * quantity)}',
                  ),
                ),
```

### lib/main.dart:4118

```dart
                          const SizedBox(height: 10),
                          Text(
                            '$itemCount ${itemCount == 1 ? 'item' : 'items'} to brighten your day.',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 12,
```

### lib/main.dart:4165

```dart
                            const Text('Total', style: TextStyle(fontSize: 16)),
                            Text(
                              pesos(orderTotal),
                              key: const Key('cart-total'),
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
```

### lib/main.dart:4278

```dart
                      Text(
                        '${pesos(item.product.price)} each',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
```

### lib/main.dart:4312

```dart
                ),
                Text(
                  pesos(item.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
```

### lib/main.dart:4483

```dart
                              const SizedBox(height: 8),
                              Text(
                                '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} · ${order.fulfillment == FulfillmentMethod.delivery ? 'Delivery' : 'Pickup'} · ${order.paymentStatus}',
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
```

### lib/main.dart:5364

```dart
                      children: [
                        Text(
                          '${widget.controller.cartCount} ${widget.controller.cartCount == 1 ? 'item' : 'items'} · Delivery',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          pesos(widget.controller.total),
                          key: const Key('checkout-total'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
```

### lib/main.dart:5660

```dart
            paymentRow('Merchant', 'Smooch Cafe'),
            paymentRow('Amount', pesos(widget.amount)),
            paymentRow('Service fee', pesos(0)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1),
            ),
            paymentRow('Total', pesos(widget.amount), total: true),
          ],
```

### lib/main.dart:5756

```dart
              const Divider(),
              paymentRow('Merchant', 'Smooch Cafe'),
              paymentRow('Amount', pesos(widget.amount), total: true),
            ],
```

### lib/main.dart:5839

```dart
                          alignment: Alignment.centerLeft,
                          child: Text(
                            pesos(widget.amount),
                            key: const Key('payment-amount'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
```

### lib/main.dart:5940

```dart
                      child: Text(switch (stage) {
                        _DemoPaymentStage.review =>
                          'Continue · ${pesos(widget.amount)}',
                        _DemoPaymentStage.processing => 'Processing…',
                        _DemoPaymentStage.success => 'Continue to order',
```

### lib/main.dart:6339

```dart
                      const SizedBox(height: 12),
                      Text(
                        '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'} · ${order.fulfillment == FulfillmentMethod.delivery ? 'Delivery' : 'Pickup'} order',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
```

### lib/main.dart:6434

```dart
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
```

### lib/main.dart:6468

```dart
                          ),
                          Text(
                            pesos(order.total),
                            key: const Key('confirmation-total'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
```

### lib/main.dart:3880

```dart
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '$addedQuantity × ${widget.product.name} added to your bag.',
        ),
      ),
    );
  }
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

Run the declared package addition, then add one import and these helpers in lib/main.dart:

```dart
import 'package:intl/intl.dart';

String displayLocale() => Intl.canonicalizedLocale(
  WidgetsBinding.instance.platformDispatcher.locale.toString(),
);
String pesos(num amount, {String? locale}) {
  NumberFormat formatter;
  try {
    formatter = NumberFormat.currency(locale: locale ?? displayLocale(),
      name: 'PHP', symbol: '\u20b1', decimalDigits: 2);
  } catch (_) {
    formatter = NumberFormat.currency(locale: 'en_PH',
      name: 'PHP', symbol: '\u20b1', decimalDigits: 2);
  }
  return formatter.format(amount);
}
String countText(num count, {String? locale}) {
  NumberFormat formatter;
  try { formatter = NumberFormat.decimalPattern(locale ?? displayLocale()); }
  catch (_) { formatter = NumberFormat.decimalPattern('en_PH'); }
  return formatter.format(count);
}
```

Keep every existing pesos caller. Replace each raw displayed quantity/count identified in Where with countText(value); use raw numeric values for singular/plural checks and calculations. Change addedQuantity in the details snackbar too. The service fee zero is money and continues through pesos. Do not compact basket counts or prices; always show the full quantity and two currency decimals. Locale affects separators, not exchange rates.

## Steps

1. Run `rtk flutter pub add intl` if no direct intl dependency exists.
2. Replace only the pesos helper and add displayLocale/countText in lib/main.dart.
3. Update every displayed count enumerated in Where; preserve raw IDs, coordinate formatting, storage and calculations.
4. Add test/number_display_test.dart with explicit en_PH and de_DE locales, zero, negative values, 1234567.5, large quantities and a multi-item cart/receipt flow.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'NumberFormat.currency|NumberFormat.decimalPattern|countText' lib/main.dart` finds the shared formatters and count uses.
- `rtk flutter test test/number_display_test.dart` passes; en_PH renders ₱1,234,567.50 and groups large counts.
- Verify totals still equal the original integer arithmetic and PHP stays the currency in every locale.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not translate product names, convert currencies, change number values/rounding in business logic, or format technical coordinates.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe grouped totals and counts and point to a large order in the bag and its receipt. Report the checks actually executed and any remaining device or hosting verification.
