# Fix: Keep missing map addresses out of customer text

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/never-show-null
- **Needs new dependency**: none

## Why

OpenStreetMap/geocoder responses are trimmed and type-checked but a serialized 'null' can still become an address suggestion. Use the article's shared usable-string guard at the response boundary and optional display checks.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

All API string paths: native geocoder parts, OpenStreetMap address parts, display_name fallback, and their suggestion consumer in checkout. Product data and customer-entered text are local data and must not be globally rewritten.

### lib/main.dart:4570

```dart
          .timeout(const Duration(seconds: 6));
      if (matches.isEmpty) return null;
      final place = matches.first;
      final parts = [
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
      ];
      final unique = <String>{};
      final address = parts
          .whereType<String>()
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty && unique.add(part.toLowerCase()))
          .join(', ');
      return address.isEmpty ? null : address;
    } catch (_) {
```

### lib/main.dart:4613

```dart
            headers: {
              'Accept': 'application/json',
              if (!kIsWeb) 'User-Agent': 'SmoochCafeFlutter/1.0',
            },
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'];
      if (address is Map<String, dynamic>) {
        final parts = [
          address['house_number'],
          address['road'] ?? address['pedestrian'] ?? address['footway'],
          address['neighbourhood'] ?? address['suburb'],
          address['city'] ?? address['town'] ?? address['village'],
          address['state'],
          address['postcode'],
        ];
        final unique = <String>{};
        final formatted = parts
            .whereType<String>()
            .map((part) => part.trim())
            .where((part) => part.isNotEmpty && unique.add(part.toLowerCase()))
            .join(', ');
        if (formatted.isNotEmpty) return formatted;
      }
      final displayName = data['display_name'];
      return displayName is String && displayName.trim().isNotEmpty
          ? displayName.trim()
          : null;
    } catch (_) {
      return null;
```

### lib/main.dart:5035

```dart
        );
    if (!mounted || selected == null) return;
    final previousSuggestion = suggestedAddress;
    setState(() {
      deliveryPin = selected.point;
      suggestedAddress = selected.suggestedAddress;
    });
    if ((address.text.trim().isEmpty || address.text == previousSuggestion) &&
        selected.suggestedAddress?.isNotEmpty == true) {
      address.text = selected.suggestedAddress!;
    }
```

### lib/main.dart:5220

```dart
                    if (suggestedAddress?.isNotEmpty == true) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Map address suggestion: $suggestedAddress',
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      if (address.text.trim() != suggestedAddress)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            key: const Key('use-suggested-address'),
                            onPressed: busy
                                ? null
                                : () => setState(() {
                                    address.text = suggestedAddress!;
                                  }),
                            icon: const Icon(Icons.edit_location_alt_outlined),
                            label: const Text('Use suggested address'),
                          ),
```

## The fix

Add the article's nullable-string helper, strengthened for whitespace and case:

```dart
extension UsableDisplayString on String? {
  String? get usableText {
    final value = this?.trim();
    return value == null || value.isEmpty || value.toLowerCase() == 'null'
        ? null : value;
  }
  bool get isUsable => usableText != null;
  String orPlaceholder([String placeholder = '-']) => usableText ?? placeholder;
}
```

In BOTH address-part pipelines, replace map(trim)/isNotEmpty with map((part) => part.usableText).whereType<String>(), followed by the existing case-insensitive deduplication and join. For display_name return displayName is String ? displayName.usableText : null. For suggestedAddress use .isUsable to show the suggestion and to offer Use suggested address; use .usableText! only after the guard when updating address.text. Do not show '-' in the editable address field: a missing optional suggestion stays absent. Existing manual address text remains untouched.

## Steps

1. Add UsableDisplayString beside shared formatting helpers in lib/main.dart.
2. Normalize both geocoder pipelines and the display_name fallback with the helper.
3. Use the same guard when storing/showing/accepting suggestedAddress; retain the existing manual-edit protection.
4. Add test/address_display_guard_test.dart for null, empty, whitespace, 'null', ' NULL ', valid accented addresses and mixed valid/invalid parts.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'UsableDisplayString|usableText|isUsable' lib/main.dart` finds the helper and address boundaries.
- `rtk flutter test test/address_display_guard_test.dart` passes.
- A failed/empty lookup leaves manual address entry and the chosen pin available; it never pre-fills '-' or 'null'.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not change receipt JSON, user-entered names/notes, coordinates, map provider, rate limits, or delivery-area validation.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe that missing map data is quietly omitted and point to choosing a pin with an unavailable address suggestion. Report the checks actually executed and any remaining device or hosting verification.
