# Smooch Cafe application audit and implemented improvements

Reviewed and implemented on 29 October 2026 (Asia/Manila). This is the current implementation audit; earlier reviews in this folder describe earlier versions.

**Wording follow-up:** at the user's request, customer-facing “demo” and “simulation” wording was subsequently removed from history, tracking, receipts, payment processing, and accessibility labels. Statuses now show the stage alone, digital receipts say “Payment step complete,” and confirmation says “Follow your order progress below.” The payment-preview notice remains. References to earlier labels and the audit screenshots below record the original audit version; the local payment/order behavior is unchanged.

## Scope and result

Reviewed the Start Screen, menu/search/categories/sorting, featured carousel, product cards, product details, bag, checkout, delivery location picker, payment preview, confirmation, saved receipts, tracking, Cafe info, shared controls, persistence, and navigation. Changes were implemented in the existing application, with all application Dart retained in `lib/main.dart`.

The required application features in [Finals.docx](../Finals.docx) are present and verified. The final submission document and demonstration recording remain deferred, as requested previously. This audit and its screenshots are supporting material, not a claim that those submission deliverables are complete.

## Findings and changes

| Area | Finding | Implemented result |
| --- | --- | --- |
| Start Screen | The 4.6-second introduction and small copy weakened the entry experience; the static layout rebuilt with the animation. | A 2.4-second intro, immediately visible copy and ORDER NOW, clearer tagline/labels, responsive two-column desktop composition, and animation confined to the coffee scene. The shaded cup, orbiting beans, steam, idle loop, lifecycle pauses, and reduced-motion behavior remain. |
| Menu | Tapping the active category unexpectedly reset it to All. Wide navigation could overflow with enlarged text. | Active-category taps now retain selection; All and Reset provide explicit reset actions. Large-text layouts use the compact navigation arrangement. Existing synchronized tabs/swipes, active indicator, search, sorting, compact grid, untinted photos, and slow bag-flight feedback remain. |
| Product details | Quantity and Add required scrolling past the description. Some labels favored decoration over clarity. Navigating away during the bag animation could leave the action disabled. | Persistent responsive quantity/Add footer, clearer Product details/About this item labels, more readable description, and recovery when another route interrupts the animation. Successful additions still return to the menu. |
| Bag | Removing an item was immediate and irreversible within the interface. Wide content reduced scanning comfort. | Undo restores the removed quantity, including removal through the last minus tap. Clearer Review your items heading and a constrained 760px reading width for contents and total. |
| Checkout | Contact/address/payment lacked strong grouping; invalid fields could be offscreen; corrections left stale error messages. | Numbered sections, autofill hints, first-invalid-field scrolling, live validation after the first submission attempt, and a persistent item count/total beside the action. Shared UI/controller validation checks name, PH mobile, address, and valid coordinates. |
| Checkout safety | Inputs could change during saving; a rejected submission could fail silently. | Busy-state guards, disabled fields, back protection during submission, clear failure feedback, and preserved bag contents on storage failure. Mobile formatting is normalized consistently. |
| Delivery address | Pins could not be cleared; location suggestions could conflict with manual edits. | Remove pin, preserved manually edited addresses, and replacement of a previous automatic suggestion only when it remains unedited. Written address remains required and GPS remains optional. |
| Map and GPS | A late GPS response could overwrite a newer manually placed pin. Failed address lookup could block pin confirmation. Controls needed more room with large text. | Request generation guards, disposal protection, distinct location error messages, bounded address lookup with pin-only fallback, and a scrollable control panel. OpenStreetMap is retained; no Google Maps setup or key was introduced. |
| Payment | Some success/status labels could be mistaken for real payment. | Explicit PAYMENT PREVIEW / SIMULATING PAYMENT / PREVIEW COMPLETE labels, Simulate payment action, and Payment simulated on receipts. Existing failure/retry/cancel paths remain; no money is transferred and no PIN/OTP is collected. |
| History | One malformed receipt could discard all history; a failed initial read could stay cached and prevent later orders. | Valid records survive individual corrupt records; references are deduplicated and sequence numbers checked. Loading/error feedback, read retry, chronological ordering, and safe asynchronous completion after disposal. |
| Confirmation and tracking | Reopening a receipt looked like a newly placed order; “estimated” tracking could imply real delivery. | History opens Order details with the saved date. Tracking explicitly identifies the ten-second stage changes as a simulation with no live rider tracking. |
| Cafe info | Our cafe was vague, and contact details offered no direct action. | Cafe info label, descriptive image semantics, phone/email actions through the device handler, and feedback if a handler cannot open. Existing business details from the supplied website remain unchanged. |
| Code | Repeated search tokenization, duplicate validation, and unnecessary notifications. | Cached search words, no-op category/sort/query guards, shared checkout validation, reusable constrained content, and lifecycle-safe history loading. No application source files were split out of `main.dart`. |

## Design decisions

The existing palette already supports the cafe identity, so it was retained: dark teal `#0A4952`, teal `#0E6F7A`, warm ivory `#F6F3ED`, white cards, ink `#163B3D`, and deeper coral `#C23F38` for primary shopping actions. The brighter original coral remains a brand accent. The earlier design audit records 5.17:1 white-label contrast for the deeper coral action color.

Montserrat remains the practical interface font and Playfair Display the expressive heading font. Both stay bundled locally. Changes emphasize readable copy, clear hierarchy, accessible controls, consistent spacing, and visible actions rather than a new visual identity. The blue payment preview remains a distinct, explicitly simulated wallet flow.

The existing compact cards, featured carousel, horizontal category navigation, quantity feedback, empty states, and 1100ms bag-flight animation were retained where they already worked well. Reduced-motion settings continue to suppress decorative movement. Animation isolation reduces avoidable rebuilds; a measured 60 FPS claim would still require profiling on target hardware.

## Finals.docx acceptance checks

| Required behavior | Evidence / status |
| --- | --- |
| Customized Smooch Cafe concept, theme, and catalog | Met: cafe branding and all 92 existing products retained. |
| Start Screen displayed first | Met: `MaterialApp.home` is `StartScreen`. |
| Store name, logo/image, and short tagline | Met: visible on the responsive Start Screen. |
| Mandatory ORDER NOW | Met: exact label retained and covered by navigation tests. |
| `Navigator.push()` with `MaterialPageRoute` | Met: Start-to-menu implementation retained; tests verify the route, Back/re-entry, retained bag, and repeated-tap protection. |
| Home/Product Screen with search and category filters | Met: word matching, category membership, reset, sorting, swipe synchronization, and active selection tested. |
| Responsive product grid and correct product details | Met: phone/tablet/desktop tests and rendered browser checks. |
| Product images | Met: catalog asset/path checks pass; browser captures show bundled product images. |
| Add to Cart returns to menu and updates count | Met: quantity and bag-flight flow tested and exercised in the browser. |
| Cart contents, quantities, and correct total | Met: automated tests plus a two-item Spanish Latte order totaling ₱160.00. |
| Required navigation remains functional | Met: Start/menu/details/cart flow, checkout, saved receipts, and Cafe info covered. |
| Single-file application architecture | Met: `lib/main.dart` is the only Dart file under `lib/`; tests remain under `test/`. |
| Catalog importer compatibility | Met: catalog text between importer markers is unchanged from the pre-audit revision; importer and assets are unchanged. |
| Final documentation and demonstration video | Deferred: still requires the agreed finalization/submission work. Group understanding and actual submission cannot be established from source inspection. |

## Validation executed

- `dart format lib/main.dart` and formatting of the new regression test: successful.
- `flutter analyze`: **No issues found**.
- `flutter test --reporter expanded`: **63 tests passed**.
- `flutter build web --no-pub`: **successful release web build** in `build/web`; the build's Wasm compatibility dry run also succeeded. A Wasm runtime deployment was not tested.
- `git diff --check`: clean.
- Catalog integrity comparison: importer-delimited catalog unchanged; only `main.dart` under `lib/`.

Nine new regression tests cover partial history corruption/reference recovery, retry after a transient initial read failure, disposal during a read, invalid/normalized contact and coordinate input, bag Undo, invalid-field scrolling and correction, GPS/manual-pin races with address lookup failure, a small large-text map layout, and tablet navigation with enlarged fonts. Existing tests were updated for intentional labels and active-category behavior.

Automated layouts include 320px, 390px, 768px, 900px, and 1440px widths; focused map and tablet regressions run at 2× text scaling with the real bundled fonts. Existing tests cover reduced motion, payment success/failure/cancellation, storage-write failure, swipe navigation, and stage timing.

Rendered Chromium checks exercised: Start → ORDER NOW → Coffee category → Spanish Latte search → details → quantity 2 → Add → bag total ₱160 → remove/Undo → invalid checkout → customer/address entry → manual OpenStreetMap pin → wallet preview → simulated success → confirmation → history. Reloading the app restored the same order, payment status, customer/address, pin, and total; its stage caught up to Delivered. The final build also verified a corrected name clears its validation error while typing.

## Visual evidence

These captures support the audit; they are not a complete final academic screenshot document.

| Screen | Capture |
| --- | --- |
| Start before / after | [Before](../artifacts/audit-start-before.png) · [Phone after](../artifacts/audit-start-after.png) · [Desktop after](../artifacts/audit-start-desktop.png) |
| Menu before / after | [Before](../artifacts/audit-menu-before.png) · [Phone after](../artifacts/audit-menu-after.png) · [Tablet after](../artifacts/audit-menu-tablet.png) |
| Product details | [Persistent quantity and Add action](../artifacts/audit-details-after.png) |
| Bag | [Items and total](../artifacts/audit-cart-after.png) |
| Checkout | [Grouped fields and persistent total](../artifacts/audit-checkout-after.png) |
| Map | [OpenStreetMap with a manually chosen pin](../artifacts/audit-map-after.png) |
| Payment | [Explicitly simulated wallet flow](../artifacts/audit-payment-after.png) |
| Confirmation | [Saved order and simulated stages](../artifacts/audit-receipt-after.png) |
| History | [Saved receipts and simulation status](../artifacts/audit-history-after.png) |
| Cafe info | [Business information](../artifacts/audit-cafe-after.png) |

## Remaining practical limits

- Payments, order placement, and delivery stages are local simulations. No order reaches the restaurant; no rider or real-time route exists.
- Receipts are local to this browser/device, and the bag is session-only. Clearing application data removes history; no account, cloud sync, or backend was introduced.
- GPS accuracy, native permission prompts, native geocoding, telephone/email handlers, and performance on physical Android/iOS devices require device validation. The current audit verified a web build and browser rendering, not a new native release build.
- Map tiles require connectivity. Browser GPS requires localhost or HTTPS; native address suggestions depend on the device geocoder. Manual address entry remains available if GPS/geocoding fails. No service-area or delivery-fee calculation was added because no verified rules were supplied.
- Business details are preserved from the supplied website; this audit did not independently verify current operating hours or contact availability.
- Final assignment documentation and the demonstration recording remain pending finalization, as previously agreed.
