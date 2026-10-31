# Fix: Keep search closed after the sort menu is dismissed

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/unfocus-before-modal
- **Needs new dependency**: none

## Why

The sort popup can open while menu search is focused and has no explicit unfocus hook. Apply the article's FocusManager call before opening that popup; GPS/payment navigation already unfocuses correctly.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

One current popup opener shares a screen with editable search: PopupMenuButton<MenuSort>. There are no showModalBottomSheet/showDialog date/picker paths in the baseline. Checkout chooseLocation/placeOrder already use FocusManager before their route opens. Any newly added changelog dialog must also unfocus in its own plan.

### lib/main.dart:3028

```dart
                  PopupMenuButton<MenuSort>(
                    tooltip: 'Sort menu',
                    initialValue: controller.sort,
                    onSelected: onSort,
                    itemBuilder: (_) => [
                      for (final sort in MenuSort.values)
                        CheckedPopupMenuItem(
                          value: sort,
                          checked: controller.sort == sort,
                          child: Text(sort.label),
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
                prefixIcon: const Icon(Icons.search, size: 22),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
```

### lib/main.dart:5023

```dart
  Future<void> chooseLocation({bool useGps = false}) async {
    if (busy) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final selected = await Navigator.of(context)
        .push<DeliveryLocationSelection>(
          MaterialPageRoute(
            builder: (_) => DeliveryMapPicker(
              initialPoint: deliveryPin,
              locateOnOpen: useGps,
```

### lib/main.dart:5060

```dart
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => busy = true);
    try {
      if (payment == PaymentMethod.digital) {
        final paid = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
```

## The fix

Add onOpened to the existing sort popup, preserving its selected callback:

```dart
PopupMenuButton<MenuSort>(
  tooltip: 'Sort menu',
  initialValue: controller.sort,
  onOpened: () => FocusManager.instance.primaryFocus?.unfocus(),
  onSelected: onSort,
```

Unfocus before opening, not after selecting/dismissing. Do not replace the FocusManager expression with FocusScope.of(context).unfocus and do not remove the existing checkout guards.

## Steps

1. Add the onOpened callback to PopupMenuButton<MenuSort> in lib/main.dart.
2. Add test/sort_popup_focus_test.dart: focus search, type, open sort, dismiss without selecting, then select a sort option in a second run.
3. Verify the keyboard does not reappear and query/category/sort behavior remains correct.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n -A 5 'PopupMenuButton<MenuSort>' lib/main.dart` shows onOpened with FocusManager before the popup's callbacks.
- `rtk flutter test test/sort_popup_focus_test.dart` passes.
- On a phone, canceling sort does not reopen search or erase its text.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not introduce a new sheet/dialog, alter sorting or reset the search field.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe the keyboard staying dismissed after sort and point to opening/canceling Sort while search was active. Report the checks actually executed and any remaining device or hosting verification.
