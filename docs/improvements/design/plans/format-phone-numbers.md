# Fix: Group Philippine phone numbers while typing and reading

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/format-phone-numbers
- **Needs new dependency**: mask_text_input_formatter for the article's single-country input/display mask.

## Why

Checkout accepts Philippine numbers but typing and saved receipt display are ungrouped. Apply a Philippine mask consistently while preserving existing valid local and +63 inputs and normalized stored values.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Formatting targets: one editable mobile field and one dynamic receipt phone display. Cafe info already groups its published phone number. Wallet intentionally shows only a masked ending; keep that privacy treatment. Receipt JSON and submitOrder store normalized phone text, not display spaces.

### lib/main.dart:256

```dart
String normalizedMobile(String value) => value.replaceAll(RegExp(r'[\s-]'), '');

abstract final class CheckoutValidation {
  static String? name(String? value) =>
      (value ?? '').trim().length < 2 ? 'Enter your name' : null;
  static String? mobile(String? value) =>
      RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(normalizedMobile(value ?? ''))
      ? null
      : 'Enter a valid PH mobile number';
  static String? address(String? value) =>
      (value ?? '').trim().length < 8 ? 'Enter your delivery address' : null;

```

### lib/main.dart:419

```dart
    mobileNumber: json['mobileNumber'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
    paymentMethod: PaymentMethod.values.byName(
```

### lib/main.dart:1650

```dart
        mobileNumber: normalizedMobile(mobileNumber),
        notes: notes.trim(),
        paymentMethod: paymentMethod,
```

### lib/main.dart:5000

```dart
  final name = TextEditingController();
  final mobile = TextEditingController();
  final address = TextEditingController();
  final notes = TextEditingController();
  String? suggestedAddress;
  LatLng? deliveryPin;
```

### lib/main.dart:5167

```dart
                    TextFormField(
                      key: const Key('customer-mobile'),
                      controller: mobile,
                      enabled: !busy,
                      autofillHints: const [
                        AutofillHints.telephoneNumberNational,
                      ],
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Mobile number *',
                        hintText: '09XX XXX XXXX',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: validateMobile,
                    ),
                    const SizedBox(height: 24),
                    const Eyebrow('2 · Delivery address'),
```

### lib/main.dart:5630

```dart
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
```

### lib/main.dart:6352

```dart
                      if (order.mobileNumber.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(order.mobileNumber),
                      ],
                      if (order.deliveryAddress.isNotEmpty) ...[
```

### lib/main.dart:6582

```dart
      const _CafeInfo(
        icon: Icons.schedule,
        title: 'Opening hours',
        text: 'Monday–Sunday • 2:00 PM–11:00 PM',
      ),
      const _CafeInfo(
        icon: Icons.phone_outlined,
        title: 'Give us a call',
        text: '(0965) 760 8290',
        link: 'tel:+639657608290',
        actionLabel: 'Call cafe',
      ),
      const _CafeInfo(
        icon: Icons.mail_outline,
        title: 'Say hello',
        text: 'smoochcafe25@gmail.com',
        link: 'mailto:smoochcafe25@gmail.com',
        actionLabel: 'Email cafe',
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

Use the article's eager mask and display/unmask separation, with local and international Philippine forms. The package constructor's initialText argument was checked in its upstream source, so a formatter can reconstruct the previous masked state for each edit without sharing mutable state with receipt formatting.

Add the package import and merge TextInputFormatter/TextEditingValue into the flutter/services.dart import. Keep normalizedMobile and validation unchanged:

```dart
MaskTextInputFormatter phPhoneMask({required bool international, String? initialText}) =>
    MaskTextInputFormatter(
      mask: international ? '+## ### ### ####' : '#### ### ####',
      initialText: initialText,
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.eager,
    );

class PhMobileInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.composing.isCollapsed) return newValue;
    final compact = normalizedMobile(newValue.text);
    final international = compact.startsWith('+');
    // Keep the beginning of a typed international prefix, not only a full paste.
    if (international && compact.length <= 3) return newValue;
    return phPhoneMask(international: international, initialText: oldValue.text)
        .formatEditUpdate(oldValue, newValue);
  }
}
String readablePhMobile(String raw) {
  final clean = normalizedMobile(raw);
  if (!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(clean)) return raw;
  return phPhoneMask(international: clean.startsWith('+')).maskText(clean);
}
```

Own one final mobileFormatter = PhMobileInputFormatter() in _CheckoutScreenState, and apply inputFormatters: [mobileFormatter] only to the mobile field. Local values show 0917 123 4567; international values show +63 917 123 4567. Typing '+', then '6', then '3' must retain the prefix until the next digits arrive. Paste/autofill and editing in the middle must keep a valid caret; if the package version's behavior differs, stop rather than falling back to moving the caret to the end on every edit.

Use readablePhMobile(order.mobileNumber) in the receipt. normalizedMobile still removes mask spaces before storage, so 09 and +63 retain their respective accepted canonical forms. A display helper creates a fresh mask and cannot disturb the input formatter. No separate dial-code prefix or country picker is introduced. Cafe info already groups the published number and wallet still shows only its ending. Invalid legacy values are displayed as-is, not reinterpreted.

Upstream constructor verification: https://github.com/siqwin/mask_text_input_formatter/blob/master/lib/mask_text_input_formatter.dart (initialText is a supported constructor parameter; source was read during planning).

## Steps

1. Run `rtk flutter pub add mask_text_input_formatter` if absent.
2. Add the eager-mask helper, PhMobileInputFormatter and independent receipt formatter in lib/main.dart.
3. Own/apply mobileFormatter on the mobile field; use readablePhMobile for the receipt. Keep validators and normalized storage.
4. Add test/ph_phone_format_test.dart covering local and international typing, '+6'/' +63' prefix progression, paste/autofill, insertion/deletion in the middle, partial values, invalid numbers and receipt/wallet display.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'PhMobileInputFormatter|mobileFormatter|readablePhMobile|inputFormatters' lib/main.dart` finds field/display wiring.
- `rtk flutter test test/ph_phone_format_test.dart` passes: 09171234567 displays as 0917 123 4567 and +639171234567 as +63 917 123 4567. Each saves its original accepted canonical form with no mask spaces.
- Typed international prefixes survive; invalid legacy receipts are not silently converted; the wallet continues to reveal only the ending.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not add a country picker, change accepted Philippine number rules, put a static dial-code prefix on the field, or rewrite saved history.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe grouped mobile numbers and point to typing/pasting a Philippine number in checkout and viewing a saved receipt. Report the checks actually executed and any remaining device or hosting verification.
