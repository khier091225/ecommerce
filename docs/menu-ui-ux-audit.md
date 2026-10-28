# Menu UI/UX audit

## Theme judgment

Keep the teal/coral identity. It is distinctive and connects the app to the supplied SmoochCafe site. My design recommendation is to change how the colors are distributed: retain dark teal for navigation and the splash, introduce warm ivory behind the catalog, and use white product cards. This gives the food photography more room and makes repeated product information easier to scan.

Use deeper coral for primary shopping actions. The original coral remains appropriate for the logo and decorative brand accents, but white small text on it has insufficient contrast for the WCAG normal-text threshold.

| Role | Color | Application |
| --- | --- | --- |
| Brand anchor | `#0A4952` | Header, selected category, bag summary |
| Supporting teal | `#0E6F7A` | Focus outlines and supporting icons |
| Warm ivory | `#F6F3ED` | Shopping-screen background |
| White | `#FFFFFF` | Product cards and input surfaces |
| Primary action coral | `#C23F38` | Add-to-bag and checkout buttons |
| Original brand coral | `#F04C45` | Logo and decorative brand accents |
| Primary text | `#163B3D` | Product names, headings, body text |
| Secondary text | `#56696B` | Categories, descriptions, search hints |

## Findings and implemented changes

| Priority | Finding | Change |
| --- | --- | --- |
| High | The large introductory banner delayed product names and prices beyond the first phone screen. | Compact introduction; the first two products, prices, and add buttons now fit in the initial 390 × 844 browser view. |
| High | White button text on the original coral measured 3.61:1 contrast. | Deeper action coral increases this pair to 5.17:1. |
| High | Search and categories disappeared during long browsing sessions. | A pinned filter header keeps both reachable while scrolling. |
| Medium | Small labels and icon-only purchase controls made scanning and ordering harder. | Larger names and prices, clear full-width “Add to bag” buttons, and consistent touch spacing. |
| Medium | Later categories were easy to miss in the horizontal strip. | Previous/next arrows appear when the strip overflows, and selecting a category brings it into view. |
| Medium | The filter-icon sheet repeated the same seven choices as the category strip. | Removed the duplicate sheet and retained one category control. |
| Medium | Customers could not order results by price or name. | Added ascending/descending price and alphabetical sorting, with a visible current-sort label. |
| Medium | A cart badge provided limited feedback after adding products. | Persistent bag summary shows quantity and total; each selected product also displays its in-bag quantity. |
| Medium | Switching tabs interrupted browsing position. | Menu, Order History, and cafe tabs retain separate scroll positions. |
| Medium | A category-specific search with no results offered weak recovery. | “Search all categories” retains the entered query; “Clear search” is available when searching the full menu. |
| Medium | Search required the exact word order and spacing. | Matching accepts words in any order and extra whitespace, while retaining the category constraint. Clearing search preserves category and sorting. |
| Medium | Larger text could crowd the catalog. | The grid reduces its column count and filter/card sizing responds to text scale. |
| Consistency | A lighter menu would clash with dark product and cart surfaces. | Applied the shopping palette to product details, the cart, and review dialog, retaining the dark branded app bar and splash. |

## Contrast checks

Ratios are calculated from sRGB relative luminance for opaque foreground/background pairs. The [WCAG contrast guidance](https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum) uses 4.5:1 for normal text and 3:1 for qualifying large text.

| Pair | Ratio |
| --- | ---: |
| White / original coral `#F04C45` | 3.61:1 |
| White / action coral `#C23F38` | 5.17:1 |
| Ink `#163B3D` / ivory `#F6F3ED` | 10.98:1 |
| Secondary text `#56696B` / white | 5.79:1 |
| White / dark teal `#0A4952` | 10.06:1 |

Primary menu controls use 48-logical-pixel minimum dimensions or Material's padded touch targets. Refer to the [WCAG target-size guidance](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum) for the separate CSS-pixel accessibility criterion. These focused checks do not establish full WCAG conformance.

## Evidence and validation

- [Before: phone](../artifacts/menu-audit-before-phone.png)
- [Before: scrolled menu](../artifacts/menu-audit-before-scrolled.png)
- [After: phone](../artifacts/menu-audit-after-phone.png)
- [After: pinned filters and bag summary](../artifacts/menu-audit-after-bag.png)
- [After: simplified category filters](../artifacts/menu-filters-phone.png)
- [After: desktop](../artifacts/menu-audit-after-desktop.png)
- [After: cart](../artifacts/menu-audit-after-cart.png)

All 22 automated tests pass, and `flutter analyze` reports no issues. Checks cover search recovery and word matching, category selection and arrow navigation, preserving category/sort when clearing search, price/name sorting, pinned-filter reachability, tab scroll restoration, repeated additions and totals, larger text at 1.6×, key contrast pairs, and the existing splash/shopping flows. Responsive widget checks include widths of 320, 390, 768, and 1440 logical pixels. Browser review covers phone and desktop layouts, sorting, category selection, empty-search recovery, bag totals, and the review dialog.

This is a design and implementation audit, not research with cafe customers. Ordering remains a demo checkout, and cart/favorites state lasts for the current app session. Native-device usability and performance have not been measured in this pass.
