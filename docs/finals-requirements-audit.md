# Finals.docx requirements audit

Reviewed on 28 October 2026 (Asia/Manila).

**Implementation update after this review:** plan steps 1–4 are complete. `StartScreen` waits for SHOP NOW and opens `MenuScreen` through `Navigator.push()` with `MaterialPageRoute`, retaining the 3D design and smooth transition. All 92 products now use a `category` from the filter list, with descriptive labels in `subcategory`. All 25 tests pass, analysis is clean, and web/Android builds succeed. Back/re-entry, retained cart/favorites, reduced motion, and category behavior were verified. The required submission documentation and video (steps 5–6) are deferred at the user's request.

**Initial audit verdict, before those changes:** the shopping application met most functional requirements, but was not ready for final submission. The findings and comparison below record that original review; the opening-screen and category issues have since been resolved as described above.

Source: [Finals.docx](../Finals.docx). Its paragraph and table text is available in [the extracted requirements](../artifacts/finals-requirements.txt). The document contains no embedded media. This audit reviews the current source, project files, screenshots, static analysis, and automated tests; it does not change the application.

## Requirement-by-requirement comparison

| Finals.docx section | Requirement | Status | Current evidence |
| --- | --- | --- | --- |
| Overview / 5 | Flutter application customized from the starter | Met | `MiniShopApp`, product models/cards, details, and cart are implemented in `lib/main.dart`. The original starter is preserved in `docs/flutter_starter.dart.txt`. |
| 2 | Clear e-commerce concept with matching products and design | Met | Smooch Cafe uses a food/drinks catalog, cafe branding, local product photos, and a consistent teal/coral/ivory theme. |
| 3 | Opening screen → product screen → details/cart | Partly met | All these destinations exist, but opening the menu uses automatic route replacement rather than the prescribed button-driven push. |
| 4 | Store identity, categories, products, color, and tagline planned | Content present; process unverified | These are identifiable in the current app. The timing of planning and group agreement cannot be established from source files. |
| 5 | Set up in Visual Studio Code and run/check the original starter before editing | Not verifiable retrospectively | A working Flutter project and original starter are present. The editor used and original execution history cannot be proved from the project alone. |
| 6 | Custom store name, home heading, and description | Met | App title is Smooch Cafe; the menu has custom cafe headings and description. |
| 7 | Readable customized theme using AppColors | Met | `AppColors` and `AppTheme` define custom brand, surface, text, and action colors. The worksheet's specific sample color/property names are examples. |
| 8 | Custom categories; Product.category exactly matches a filter category | Partly met | Filtering works through `Product.group`. However, 65 of 92 products have `Product.category` values outside the seven-entry filter list. This does not meet the worksheet's explicit field rule. |
| 9 | Custom products with name, price, category, description, and image | Met | 92 product records appear near the top of `main.dart`, with the required fields plus IDs, groups, and featured flags. The worksheet's `demoProducts` identifier is an example location, not an additional feature. |
| 10 | Images in assets/images with matching paths | Met | Product images, logo, and cafe images use `assets/images/`. Catalog asset checks pass. |
| 10 | Simple image filenames | Recommended cleanup | Existing filenames contain spaces and mixed capitalization. They currently resolve correctly; using simpler names would follow the naming guidance more closely. |
| 11 | Register images in pubspec.yaml and run pub get | Met | `flutter.assets` includes `assets/images/`; package resolution succeeded after the folder move. |
| 12 | Search filters products by name | Met | Case-insensitive word matching supports product names, extra whitespace, and combined category filtering. |
| 12 | Category selection filters matching products | Functionally met | Matching works through `group`; see the separate strict field-rule gap in section 8. |
| 12 | Responsive grid displays products | Met | Product grid is generated from the catalog; widget tests cover 320, 390, 768, and 1440 logical-pixel widths. |
| 12 | Selecting a product opens its correct details | Met | Product cards pass the selected product into `ProductDetailsScreen` through a `MaterialPageRoute`. |
| 12 | Add to Cart returns to the product screen and increases count | Met | The details button adds the chosen quantity and pops back to the menu; cart count and totals update. |
| 12 | Cart displays selected items/prices and total | Met | `CartScreen` displays items, quantities, unit/line prices, and the computed peso total. |
| 13 | Opening screen appears before the catalog | Met | `MaterialApp.home` is `SplashScreen`. |
| 13 | Opening screen has store name, logo/image, and tagline | Met | The branded logo and 3D cup appear with custom opening text and tagline. |
| 13 | One main GET STARTED / SHOP NOW / ENTER STORE button | Not met | The splash has a small secondary “Skip intro” control and automatic advancement, but no primary enter-store button. |
| 14 | Start button uses Navigator.push() and MaterialPageRoute | Not met | `_openMenu()` uses `Navigator.of(context).pushReplacement()` with `PageRouteBuilder`. These are different from the explicitly required APIs. |
| 14 | Product Details and Cart navigation continue to work | Met | Both use push navigation and `MaterialPageRoute`; shopping-flow tests pass. |
| 15 | Visual customization beyond the starter | Met | Custom branding, fonts, cards, layout, 3D opening animation, transitions, navigation, filters, favorites, and bag summary are present. |
| 16 | Two group members understand and can explain the app | Requires group confirmation | Source files and test results cannot establish group membership or each member's understanding. |
| 17 / 19 | Simple documentation with all five required sections | Incomplete in workspace | README and a UI/UX audit exist, but there is no completed submission document containing Introduction, Application Description, Target Audience, the group's reason for choosing the concept, and captioned screenshots. |
| 17 | Captioned screenshots of every major and additional screen | Partly prepared | Raw captures exist for the splash, menu, and cart. A complete captioned screenshot section is missing; no dedicated product-details capture was found. Additional tabs such as Favorites and Our Cafe should also be represented. |
| 18 / 19 | Screen recording of the required demonstration flow | Not found in workspace | No `.mp4`, `.webm`, `.mov`, `.avi`, or `.mkv` submission recording was found among the project's visible files. A recording stored elsewhere would need separate review. |
| 19 | Submit documentation and video | Incomplete in workspace | These are the two specified final outputs. Current app source, an APK, or an audit report alone do not replace them. |

## Changes needed before submission

### 1. Make the 3D opening screen satisfy the Start Screen requirement

The existing 3D design can serve as the required opening screen. Add a clearly visible primary **SHOP NOW** or **GET STARTED** button, and make that button open `MenuScreen` using `Navigator.push()` with `MaterialPageRoute`, as specified in sections 3, 13, and 14. The current menu serves the Home / Product Screen role; renaming it to `HomeScreen` is not itself necessary.

Current implementation evidence in [main.dart](../lib/main.dart):

- Initial splash: line 1267.
- Automatic advancement and reduced-motion timer: `SplashScreen` implementation starting at line 1455.
- Route replacement and custom route: lines 1532–1533.
- Secondary “Skip intro” control: line 1622.

Existing splash tests intentionally check automatic advancement and replacement of the intro route. Those tests pass for the current behavior, but they will need to be revised when the required push/button behavior is implemented. Passing tests do not establish compliance with a different navigation requirement.

### 2. Align Product.category with the filter list

The current categories are `All`, `Coffee`, `Non-Coffee`, `Food`, `Pastries`, `Ice Blended`, and `More Drinks`. Filtering at line 1157 compares the selected category with `product.group`.

For example, Classic Burger has `category: "Quarter Pounder"` and `group: "Food"`. It filters correctly under Food, but “Quarter Pounder” is absent from the categories list. There are **65 products** with this mismatch, across 14 product labels.

To follow section 8 literally while keeping the current category layout, use the broad filter value as `Product.category` and store descriptive labels such as Quarter Pounder or Brownies in a separate subcategory field. Then filter using `Product.category` and update tests/import tooling consistently.

### 3. Prepare the actual documentation

Include the five mandatory sections from section 17:

1. Introduction: identify the Flutter e-commerce project.
2. Application Description: describe the opening screen, catalog, search, categories, details, cart, and total.
3. Target Audience: identify the intended customers.
4. Why We Chose This E-Commerce Concept: use the group's actual reason, rather than an assumed reason.
5. Application Screenshots: add current screenshots with short captions for the opening screen, menu, product details, cart, and additional screens/tabs.

The title-page layout in the worksheet is suggested. Group names and explanations must be supplied or confirmed by the members. The existing README and UI/UX audit are useful supporting material, but do not yet provide the complete required submission.

### 4. Record the demonstration after the app changes

Show a fresh launch → opening screen → main enter-store button → catalog → category selection → product search → product details → add to cart → cart and total. Check images, layout, and navigation before recording, as section 18 requests. No recording or external submission was created during this audit.

## Validation performed

- `flutter analyze`: no issues.
- `flutter test`: all 22 tests passed.
- Catalog check: 92 products; every current `group` is present in the filter list, while 65 `category` values are not.
- Image checks: product image files exist; `pubspec.yaml` registers `assets/images/`.
- Inspected the opening-screen navigation, details navigation, cart navigation, add-to-cart action, and total display in the current source.
- Reviewed visible documentation, screenshot files, and common video-file types in the workspace.

No grading percentage is assigned: Finals.docx provides requirements but no numerical grading rubric. Group understanding, files stored outside this workspace, and behavior on a physical mobile device were not independently verified in this pass.
