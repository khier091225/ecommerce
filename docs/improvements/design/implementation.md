# Design implementation status

This records the earlier 25-plan implementation. A subsequently authorized visual redesign replaced Cafe info with Discover and added shared motion components; see [the latest UI and animation report](../../ui-motion-polish-2026-11-01.md) for the current screens and checks.

Completed on 1 November 2026 (Asia/Manila) after approval to implement all 25 selected findings from the flutter-improve-design review. The approved work is integrated into the existing app. There is no public hosting URL yet, so the social-preview asset/tool are ready while production metadata and crawler verification await hosting.

## Plan coverage

| # | Plan | Result |
| --- | --- | --- |
| 1 | In-app changelog | Implemented. Local semantic-version notes appear once after an upgrade. First installation skips them, and late lookup cannot interrupt menu navigation. Package version remains 1.0.0+1. |
| 2 | Safe-area replacement | Implemented. Scroll ends use system-bottom padding with appropriate minimums; pages with protected fixed footers keep their existing safe areas. |
| 3 | Shader mask | Implemented. Small alpha-only edge fades follow available horizontal content on categories and featured picks. No product tint is added. |
| 4 | Selection color | Implemented. Teal cursor, selection, and selection handles match the cafe theme. |
| 5 | Precache images | Implemented. Essential images load first, then deduplicated cafe/catalog assets warm serially without increasing cache limits or blocking ORDER NOW. |
| 6 | Never show null | Implemented. Native/Nominatim address parts and checkout suggestions discard null, blank, and serialized null text. |
| 7 | Human-readable numbers | Implemented. Cached locale-aware peso/count formatting preserves PHP amounts and arithmetic. |
| 8 | Web loading progress | Implemented. Branded HTML/CSS boot screen advances through actual initialization milestones, handles load errors, and disappears on Flutter's first frame. |
| 9 | Haptic feedback | Implemented. Capability-checked feedback on important actions/results on Android/iOS; unsupported environments and plugin failures safely skip it. Physical feel needs device validation. |
| 10 | Tabular figures | Implemented. Quantity counters and monetary labels use tabular digits while inheriting existing typography. |
| 11 | Web social preview | Prepared; awaiting hosting. A 1200 × 630 PNG and tested metadata configuration tool are included. No hostname was invented and nothing was deployed. |
| 12 | Dismiss keyboard on scroll | Implemented. Dragging checkout dismisses the keyboard. |
| 13 | Main destination reselect | Implemented. Reselecting returns the active page to the top; a second Our menu tap at the top focuses search. Reduced motion jumps immediately. |
| 14 | Show app version | Implemented. Cafe info ends with the installed version/build; metadata failure quietly omits the label. Original Cafe info layout is retained. |
| 15 | Web page transitions | Implemented. Browser/desktop routes open immediately; native phone transitions retain the cafe motion. |
| 16 | Scrollbars | Implemented. Shared behavior supplies one scrollbar per scrollable without stacking desktop defaults. |
| 17 | Date formatting | Implemented. History uses locale-aware short month dates; saved receipts use fuller dates and locale hour cycles. Stored timestamps and tracking remain unchanged. |
| 18 | iPhone tap-to-top | Implemented. The active menu category/history/Cafe controller is exposed through PrimaryScrollController. Controller wiring is tested; the physical status-bar gesture needs an iPhone. |
| 19 | Text scale | Implemented. Existing text preferences are preserved up to 2×; only larger scales are capped. Existing responsive/large-text rules remain. |
| 20 | Horizontal list padding | Implemented. Search retains its inset while category navigation and the featured viewport can reach the content edges. |
| 21 | Browser tab title | Implemented. Titles follow routes, product names, main destinations, Back, and fresh menu entry. Popup menus keep the underlying page title. |
| 22 | Unfocus before modal | Implemented. Opening Sort dismisses search focus without restoring it on dismissal. |
| 23 | Friendly error view | Implemented. Branded full/compact fallbacks handle bounded and unbounded slots. Release views hide technical details; a guarded long-press copy supports diagnostics. |
| 24 | Phone formatting | Implemented. Both 09 and +63 forms group digits while typing/pasting, preserve composing text/caret behavior, normalize for existing validation/storage, and read clearly on receipts. |
| 25 | Text input action | Implemented. Contact fields keep Next; the multiline address inserts newlines. Phone input does not submit an order. |

## Preserved scope

- All application Dart remains in `lib/main.dart` with no local Dart imports or part files.
- The catalog source between importer markers is unchanged from baseline `fc76bcd7192c63460df486deb451a5876d17cc09`: all 92 products retain their names, prices, categories, and assets.
- The Start Screen retains the logo/tagline and ORDER NOW using Navigator.push with MaterialPageRoute. The 3D scene, category swipes, slow add-to-bag flight, search/sort, and cart remain.
- Delivery stays delivery-only with OpenStreetMap, the current 10 km Carmona validation, optional GPS/manual pins, and explicit address suggestions. No map provider or delivery rule was changed.
- Receipt storage, references, totals, local payment outcomes, and 10-second tracking progression keep their existing business logic. No backend, payment gateway, or rider tracking service was added.
- Visible copy does not introduce demo/simulated/simulation wording. Internal payment identifiers retain their existing names. The existing payment-preview disclosure remains accurate.
- Cafe info retains its restored design with only the approved version label appended.

Direct dependencies added or promoted: `package_info_plus`, `pub_semver`, `intl`, `haptic_feedback`, and `mask_text_input_formatter`. No broad dependency upgrade was performed. On this Windows host, project-local ignored plugin junctions resolved Flutter's symlink setup without changing Windows Developer Mode.

## Verification performed

- Dart formatting completed and `flutter analyze --no-pub` reports no issues.
- `flutter test --no-pub --reporter expanded`: **82 passed**, including **17 new tests** in `test/design_improvements_test.dart`.
- `node --test test/web_preview_test.mjs`: **2 passed**.
- `flutter build web --no-pub`: successful, including Flutter's Wasm dry run. The app was checked using its default JavaScript web build.
- `flutter build apk --debug --no-pub`: successful. Output: `build/app/outputs/flutter-apk/app-debug.apk`. The Android tools emitted a nonfatal SDK XML-version warning.
- Catalog integrity comparison, single-file application check, and `git diff --check`: passed.
- Browser inspection at 390 × 844, 768 × 1024, and 1440 × 1000 verified page layouts. Reduced-motion category switching kept the active tab and products synchronized.
- Browser flow: ORDER NOW → Coffee/search → Spanish Latte details → quantity 14 → animated Add → bag total **₱1,120.00** → checkout → manual OpenStreetMap pin → returned address suggestion without overwriting the multiline manual address → GCash failure/retry/cancellation/success → saved receipt → history → reopened receipt. Grouped phone, localized dates, totals, and route/tab titles were checked. No JavaScript page errors appeared; the boot overlay was removed.

Screenshots are in `artifacts/design-*.png`, including phone Start/menu/details/checkout/payment/confirmation/history and tablet/desktop menu views. Widget tests also cover narrow screens, larger text, reduced motion, fallback sizes, and delayed asynchronous work.

Not established by these checks: physical haptic quality, native GPS accuracy/geocoding, an actual iPhone status-bar gesture, iOS builds, or 60 FPS on target devices. The Android artifact was built but not installed on hardware in this pass.

## Finish the share preview after hosting

When the public HTTPS app URL is known, run:

```sh
node tools/configure_web_preview.mjs <public-HTTPS-URL>
flutter build web
```

Use the exact hosted base path, including a subdirectory if applicable. The tool creates/replaces static Open Graph/X tags in `web/index.html` with absolute page/image URLs and keeps the Flutter base-href handling. Deploy only when authorized, then verify that the public page and `og-image.png` return successfully without authentication and that social crawlers receive the tags. Public crawler checks cannot be completed before hosting exists.
