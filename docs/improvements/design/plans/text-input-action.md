# Fix: Keep checkout keyboard actions predictable

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/text-input-action
- **Needs new dependency**: none

## Why

Full-scan refinement: contact fields already use Next, and checkout ends with multiline address/notes rather than a final single-line submit field. The article exempts multiline fields; restore newline behavior on the address instead of making the phone key submit an incomplete order.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

All editable fields: menu search already has Search/onSubmitted; contact name and mobile have Next; address has maxLines: 2 but incorrectly forces Next; notes has maxLines: 2 and correctly retains multiline defaults. There is no separate single-field page or final single-line field that should acquire submit-on-Done.

### lib/main.dart:5153

```dart
                    TextFormField(
                      key: const Key('customer-name'),
                      controller: name,
                      enabled: !busy,
                      autofillHints: const [AutofillHints.name],
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full name *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: CheckoutValidation.name,
                    ),
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
                    const SizedBox(height: 12),
```

### lib/main.dart:5186

```dart
                    TextFormField(
                      key: const Key('delivery-address'),
                      controller: address,
                      enabled: !busy,
                      autofillHints: const [AutofillHints.fullStreetAddress],
                      maxLines: 2,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Delivery address *',
                        hintText: 'House number, street, barangay, city',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        final addressError = CheckoutValidation.address(value);
```

### lib/main.dart:5292

```dart
                    TextFormField(
                      key: const Key('customer-notes'),
                      controller: notes,
                      enabled: !busy,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        labelText: 'Delivery notes (optional)',
                        alignLabelWithHint: true,
                        hintText: 'Anything the cafe should know?',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Eyebrow('3 · Payment method'),
```

### lib/main.dart:3445

```dart
            child: TextField(
              key: const Key('menu-search'),
              controller: search,
              onChanged: onQuery,
              style: const TextStyle(fontSize: 14),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: 'Search drinks, food or pastries',
```

## The fix

Follow both parts of the article: keep Next on the two contact fields, and allow newline on multiline fields. For the address use:

```dart
maxLines: 2,
keyboardType: TextInputType.multiline,
textCapitalization: TextCapitalization.words,
textInputAction: TextInputAction.newline,
```

Do not add onFieldSubmitted: placeOrder to phone/address/notes. Phone Next should still move into the address; Return in address/notes inserts a line break. Keep the existing Place order/Continue to GCash action as the authoritative submit path, with busy guards and validation. No onEditingComplete override is needed. Existing search behavior stays unchanged.

The initial broad finding does not justify adding a new field or a Done-to-submit handler where the article explicitly exempts multiline input. This plan records that narrower verified fix.

## Steps

1. Change only the address field's forced Next action to multiline/newline in lib/main.dart.
2. Keep name/mobile Next, notes multiline default and search Search/onSubmitted.
3. Add test/checkout_keyboard_actions_test.dart for name → phone → address traversal, address/notes newline insertion and no accidental order submission.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'TextInputType.multiline|TextInputAction.newline' lib/main.dart` finds the address configuration.
- `rtk flutter test test/checkout_keyboard_actions_test.dart` passes.
- A newline does not place an order, and contact Next still advances without tapping the next field manually.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not submit on the phone key, convert delivery notes to a single-line field, add an OTP page, or bypass placeOrder validation.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe working Next keys and multiline addresses, pointing to filling checkout from the keyboard. Report the checks actually executed and any remaining device or hosting verification.
