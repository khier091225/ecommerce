# Whole-app journey review

## Implementation update — 28 October 2026

The findings below record the initial audit. The current app now follows `Start → Menu → Bag → Checkout → Cash at pickup or GCash-style payment preview → Confirmation`, with required name/mobile validation and optional pickup notes. The simulated wallet screen reviews the exact order amount, shows a masked checkout mobile, and previews processing, success, and failure. Failed or cancelled payment keeps the bag. A successful order is saved locally before the bag clears; confirmation shows customer details, payment status, items, and total. The order-history button in the menu reopens receipts after an app restart, and references continue in sequence. The two large-text overflows found in the bag and product details were fixed and verified with the bundled fonts. The menu also has a swipeable featured-products carousel and a horizontal category tab rail; product grids follow category swipes, and the underline stays synchronized with the selected page.

This remains a simulation: no order is sent to Smooch Cafe, no real payment is processed, and no PIN or OTP is requested. The wallet screen explicitly says it is not connected to GCash. Local history is device-specific and does not sync across devices.

Reviewed on 28 October 2026 (Asia/Manila).

**Result:** the current classroom-demo journey works from launch through the bag, demo order confirmation, and return to shopping. A checkout/payment journey is not implemented. Two additional large-text layout defects were reproduced during this review.

This review did not change application behavior. The existing choice to use demo orders is respected; the missing checkout/payment functions below are gaps only if the desired scope now includes those stages. The app accurately labels its confirmations as demonstrations and does not claim to have taken payment.

## Findings

### 1. There is no checkout or payment stage

**Priority: first decision for completing the requested payment journey.**

The current path is:

`Start → Menu → Product details / Add → Bag → Place Order → Demo confirmation → Menu`

In `lib/main.dart`, `_placeOrder()` at line 2933 calls `placeDemoOrder()` immediately. That method at line 1298 creates a local receipt and clears the bag. No payment method, payment status, processing state, cancellation, or failed-payment outcome is represented.

This is correct for the previously agreed demo confirmation. It does not support completing a paid order. If a payment step is added, retain the bag when that step is cancelled or fails; clear it only when the selected checkout outcome is accepted. For pay-at-pickup, confirmation should clearly say payment is still due rather than claiming the order is paid.

For this project, a payment-method selection and a clearly labelled simulated outcome would be enough to demonstrate the additional flow. Connecting actual payments is a separate integration decision.

### 2. No customer or fulfillment details are collected

**Priority: needed if the demo should resemble an actionable cafe order.**

`OrderReceipt` at line 214 contains only a reference and line items, with computed quantity and total. There is no customer name, contact, pickup/dine-in choice, or pickup instruction. Consequently, the confirmation is a shopping demonstration rather than an order the cafe could identify and fulfill.

A short checkout-details form could collect the minimum information needed for the chosen service. It should add those details without recreating the redundant bag-review page that was removed.

### 3. Completed receipts cannot be reopened, and state does not survive restart

**Priority: useful completion and recovery improvement; current documented prototype limitation.**

The confirmation displays a correct immutable receipt, but `Continue Shopping` removes that route. The controller does not keep an order-history collection and the navigation has no Orders destination. There is therefore no in-app way to reopen that confirmation afterward.

The bag and favorites are also memory-only. Browser reload was tested: a populated bag and saved favorite both reset. The order-number counter starts at 1 in each new controller (`main.dart`, line 1181), so a new session can reuse `SMC-0001`.

If users should retain their finished orders, store completed receipts locally, add an Orders/history entry, and use references that remain unique after restarting. The existing in-session receipt snapshots and sequential numbering already work correctly.

### 4. Bag quantity/subtotal layout overflows on a narrow screen with enlarged text

**Priority: medium; reproduced layout defect.**

Reproduction:

- 320 × 700 logical-pixel viewport.
- Text scale 1.6 (160%).
- The highest-priced catalog product, quantity 99.
- Open the bag.

With the app's actual Montserrat and Playfair fonts loaded, Flutter reports a horizontal RenderFlex overflow of about **21 pixels**. The rigid quantity-picker/subtotal row in `_CartRow` (`main.dart`, line 3146) cannot reliably fit both controls and a longer amount at this size.

Allow this footer to wrap or put the subtotal below the quantity controls when space is limited. Keep the controls usable rather than shrinking the text. The same real-font check passed at 390 × 844 with 160% text.

### 5. Product-details footer clips at 200% text size

**Priority: medium; reproduced layout defect.**

At 320 × 700 and text scale 2.0, the “Made with love at Smooch Cafe.” footer reports approximately **78 pixels** of horizontal overflow. Its Text is placed in an unconstrained Row beside an icon (`main.dart`, lines 2884–2893).

Make the text flexible or use a wrapping layout. This is a text-layout defect; the product, quantity selector, and add action themselves continue to exist.

## What was verified successfully

| Stage | Result |
| --- | --- |
| App opening | 3D intro appears, continues with idle motion, and waits for SHOP NOW. |
| Start navigation | SHOP NOW opens the menu; Back and re-entry work. |
| Catalog | Product photos load and the compact cards display. No failed asset responses were observed during the reviewed browser journey. |
| Search and categories | Food + “burger” returned six matching items. Reset restored the menu. |
| Favorites | Saving Tiramisu Latte made it available in Favorites. |
| Product details | Selected product and quantity were correct; adding two Tiramisu Lattes returned to the menu. |
| Bag | Two lattes at ₱145 plus one burger at ₱110 gave three items and the correct **₱400** total. |
| Place Order | Opened a demo confirmation, kept quantities and line totals, and cleared the completed bag. |
| Confirmation | Displayed the reference, product/subcategory, quantities, unit prices, line totals, and ₱400 total. Clearly stated that nothing was sent or paid. |
| Finish | Continue Shopping returned to the menu with an empty bag. |
| Navigation edge case | Existing tests cover placing an order from a bag opened through product details, including system Back returning directly to the menu. |
| Browser runtime | No page errors or failed asset requests were recorded during the normal journey. |

## Validation evidence and limits

- `flutter analyze`: no issues.
- Existing `flutter test` suite: **31 passed**.
- Three additional audit checks were run separately with the bundled fonts loaded: the 390px enlarged-text bag check passed; the 320px enlarged-text bag and 320px double-text product-details checks failed as described above.
- The additional reproducer is `.dart_tool/app_journey_audit_test.dart`; it is an audit helper, outside the normal test suite.
- [Reviewed bag](../artifacts/journey-audit-bag.png).
- [Reviewed confirmation](../artifacts/journey-audit-confirmation.png).

The browser review used a 390 × 844 viewport. Widget tests supplied the larger-text stress cases. Physical-device performance, real cafe fulfillment, and real payment processing were not tested. No submission documentation or demonstration video was prepared in this review.

## Recommended next sequence

1. Fix the two reproduced responsive-layout defects.
2. Choose the intended checkout scope: a classroom demo or actual order/payment submission.
3. Add checkout details and a payment-method/status step for that scope, without repeating the bag review.
4. Keep a retrievable receipt/order history and preserve it across restarts if users should rely on it.
5. Repeat the journey including payment cancellation, failure, success/pay-later outcomes, and re-opening a completed order.
