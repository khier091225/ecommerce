# Fix: Get the keyboard out of the way while scrolling checkout

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/dismiss-keyboard-on-scroll
- **Needs new dependency**: none

## Why

Checkout is the only scrollable containing editable fields without drag-to-dismiss behavior. Apply the article's one-property fix, keeping deliberate multiline editing and manual submit intact.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Editable fields exist in the pinned menu search and checkout. Menu result scrolling already has onDrag; Cafe scrolling also has it. The checkout SingleChildScrollView lacks it. Other scrollables contain selectable text or no input fields, not an active editing form.

### lib/main.dart:5121

```dart
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
              child: Form(
                key: form,
                autovalidateMode: attemptedSubmit
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

### lib/main.dart:2933

```dart
    return CustomScrollView(
      key: PageStorageKey('products-$category'),
      controller: scroll,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (showFeatured) ...[
```

### lib/main.dart:2854

```dart
                : CustomScrollView(
                    key: const PageStorageKey('menu-tab-cafe'),
                    controller: cafeScroll,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverToBoxAdapter(
```

## The fix

Add the article's property to the checkout body's existing scrollable:

```dart
body: SingleChildScrollView(
  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
  child: Center(
```

Do not wrap the form in a gesture detector that swallows taps, reset field values, add autofocus or change validation. Leave existing onDrag menu behavior alone.

## Steps

1. Add keyboardDismissBehavior to the CheckoutScreen body in lib/main.dart.
2. Add test/checkout_keyboard_scroll_test.dart: focus/enter a field, verify the test keyboard is visible, drag the checkout body, verify it is dismissed while text remains.
3. Check notes still accept multiline input when not scrolling.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n -A 2 'body: SingleChildScrollView' lib/main.dart` shows onDrag on the checkout occurrence.
- `rtk flutter test test/checkout_keyboard_scroll_test.dart` passes.
- On phone, scroll from name/address toward payment; the keyboard closes and required-field scrolling still works.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not alter search submission, validation, autofill, field controllers or payment behavior.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe that scrolling checkout clears the keyboard and point to entering an address then scrolling toward payment. Report the checks actually executed and any remaining device or hosting verification.
