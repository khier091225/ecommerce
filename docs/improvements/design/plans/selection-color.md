# Fix: Make selected text and cursors match the cafe theme

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/selection-color
- **Needs new dependency**: none

## Why

Search, checkout and selectable receipt/contact text inherit default selection styling. Apply the article's shared theme setting using the cafe's teal.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where



### lib/main.dart:52

```dart
abstract final class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    visualDensity: VisualDensity.standard,
    fontFamily: 'Montserrat',
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        for (final platform in TargetPlatform.values)
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
```

### lib/main.dart:6317

```dart
                const SizedBox(height: 20),
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
```

### lib/main.dart:6643

```dart
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
```

## The fix

Add one textSelectionTheme entry to AppTheme.theme, adjacent to inputDecorationTheme:

```dart
textSelectionTheme: TextSelectionThemeData(
  cursorColor: AppColors.teal,
  selectionHandleColor: AppColors.teal,
  selectionColor: AppColors.teal.withValues(alpha: .22),
),
```

Use the article's theme-level approach, with no per-field overrides. Keep the wallet's blue surfaces; shared field selection still uses the cafe theme.

## Steps

1. Insert the specified TextSelectionThemeData in AppTheme.theme in lib/main.dart.
2. Check search, checkout, receipt reference and Cafe info details for overrides; none exist in this revision.
3. Verify visually; do not add tests that only repeat literal color constants.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'textSelectionTheme:' lib/main.dart` shows one entry.
- Select text in search, delivery address, receipt reference and Cafe info. Handles/cursor are teal and selected text remains legible.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe consistent teal selection and point to selecting a receipt reference. Report the checks actually executed and any remaining device or hosting verification.
