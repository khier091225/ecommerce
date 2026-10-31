# Fix: Let sideways browsing reach the content edges

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/horizontal-list-padding
- **Needs new dependency**: none

## Why

The featured viewport is inset by outer padding and the pinned category viewport shares the search field's side padding. Apply the article's edge-to-edge viewport/child-owned spacing pattern while retaining desktop reading-width limits.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Two horizontal viewports: featured PageView and category TabBar. The main category CustomScrollView already applies padding per vertical section rather than to the full page, so do not remove its text/grid spacing. TabBarView is page navigation and is excluded.

### lib/main.dart:3190

```dart
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Eyebrow('Smooch picks · Swipe to explore'),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 186 * scale.clamp(1, 1.8),
                child: PageView.builder(
                  key: const Key('featured-carousel'),
                  controller: pages,
```

### lib/main.dart:3205

```dart
                child: PageView.builder(
                  key: const Key('featured-carousel'),
                  controller: pages,
                  itemCount: featured.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (context, index) {
                    final product = featured[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Material(
                        color: AppColors.dark,
                        borderRadius: BorderRadius.circular(22),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          key: Key('featured-${product.id}'),
                          onTap: () => Navigator.of(context).push(
```

### lib/main.dart:3434

```dart
  @override
  Widget build(BuildContext context) => ContentWidth(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: searchHeight,
            child: TextField(
              key: const Key('menu-search'),
              controller: search,
```

### lib/main.dart:3470

```dart
            ),
          ),
          const SizedBox(height: 8),
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
                PointerDeviceKind.stylus,
              },
            ),
            child: TabBar(
              key: const Key('category-filters'),
              controller: tabs,
              isScrollable: true,
```

### lib/main.dart:3497

```dart
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 17),
              onTap: (index) => onCategory(ShopController.categories[index]),
              tabs: [
                for (final category in ShopController.categories)
                  Tab(key: Key('category-$category'), text: category),
              ],
            ),
          ),
        ],
      ),
```

## The fix

Featured carousel: change its outer Padding from EdgeInsets.fromLTRB(10, 4, 10, 18) to EdgeInsets.only(top: 4, bottom: 18). Keep the 760px desktop ConstrainedBox, PageController(viewportFraction: .9), default padEnds and the existing per-item right spacing of 10. The PageView viewport now reaches the bounded content edges; spacing travels with the pages.

MenuFilters: retain its maxWidth of 1160, but remove the ContentWidth horizontal padding around the whole search-plus-tabs column. Wrap only the search SizedBox with Padding(horizontal: horizontalPadding). Give TabBar its own padding: EdgeInsets.symmetric(horizontal: horizontalPadding). The TabBar's viewport reaches the content edge while labels retain the same resting inset. Keep vertical 10px padding, the 8px search gap, automatic tab visibility, labels and controller unchanged.

When edge fades are also present, place their ShaderMask around the expanded viewport, not around the padded search or each page item. No new scrolling model or category controls are introduced.

## Steps

1. Change only the featured carousel's outer horizontal padding in lib/main.dart; preserve card item spacing and viewport fraction.
2. Move category rail padding from the outer ContentWidth to the TabBar's padding property; keep search individually padded.
3. Add test/horizontal_viewport_edges_test.dart comparing viewport and bounded-content rectangles at 390/768/1440px, and checking category/carousel taps and swipes.
4. Check the first/last page resting spacing and desktop max-width composition.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'padding: const EdgeInsets.only\(top: 4, bottom: 18\)' lib/main.dart` finds the carousel's vertical-only outer padding.
- `rtk flutter test test/horizontal_viewport_edges_test.dart` passes.
- On phone, cards/tabs move to the viewport edges rather than vanishing at a shared outer padding line; search remains aligned.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not remove grid/text spacing, desktop width limits, selected-category auto-scrolling or the existing 0.9 viewport fraction.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe cleaner edge-to-edge sideways motion and point to swiping featured picks and the category rail. Report the checks actually executed and any remaining device or hosting verification.
