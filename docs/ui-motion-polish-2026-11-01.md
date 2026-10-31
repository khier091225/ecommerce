# Smooch Cafe visual and animation polish

Implemented on 1 November 2026 (Asia/Manila), following authorization to change the app's UI, animations, content, and destinations.

## Design direction

An expressive cafe shopping app with editorial headings, warm ivory surfaces, dark teal structure, coral actions, subtle gold accents, and the existing bundled product photography. Product browsing remains compact and actionable. The opening 3D cup, logo, and ORDER NOW flow remain the app's introduction.

The plain Cafe info destination is now **Discover**. Following a further cleanliness review, it has one short heading, compact image shortcuts for Coffee, Food, and Pastries with real product counts, and one grouped Visit Smooch panel for the address, hours, call/email actions, and delivery area. The oversized story panel, extra introductions, category slogans/icons, and repeated footer copy were removed. The version remains quiet at the bottom. No reviews, discounts, delivery-time promises, or other unsupported claims were invented.

The subsequent [interactive 3D scene upgrade](starting-scene-2026-11-01.md) replaces the original cup with a glazed mug, heart latte art, a floating saucer, curved logo, studio lighting, and spring hover/drag tilt. That report records the latest scene validation; earlier counts below describe their original validation runs.

## Implemented experience

| Area | Result |
| --- | --- |
| Shared design language | `CafeShape`, `CafeMotion`, and `CafeSectionHeading` keep new shapes, timing, and section hierarchy consistent. Existing Montserrat/Playfair typography and teal/coral contrast are retained. |
| Menu navigation | A sliding dark-teal capsule follows the selected category. Horizontal category scrolling, auto visibility, gesture navigation, search, Reset, sorting, and content synchronization remain. Enlarged-text users get a shorter introduction so products remain reachable. |
| Featured products | A wider photographic carousel uses an editorial product title, subtle numbered backdrop, category and price, independently positioned Add action, and gentle scale changes during swipes. Photos retain their original colors. |
| Product cards | Cards have consistent softer corners, a Smooch-pick badge, a subtle press spring, and a small desktop hover lift. Compact sizing and adaptive columns remain. |
| Product details | The image and description enter smoothly without blocking the quantity or Add actions. The existing slow curved photo flight to the bag is retained. |
| Discover | Three compact image shortcuts expose category names, real counts, and accessible actions. They clear an old search, keep the selected sort and bag, and synchronize the destination/category. One compact contact surface replaces the promotional panel and repeated headings. At larger text sizes the shortcuts become rows, while contact details stack into a single column. |
| Bag and checkout | The bag gets a clearer editorial heading. Contact, delivery, and payment steps use numbered icon headings. Primary actions share tactile feedback and stay still when disabled or reduced motion is enabled. Existing validation, manual address protection, GPS, map suggestions, and payment behavior are retained. |
| Order completion | A short custom-painted ring/checkmark confirms a new order and then stops. Reopened receipts show the completed mark immediately. Tracking segments reinforce the existing five stages, advancing on the original timing. |
| Images | Browsing images request a 640-pixel decode; detail images request 1024 pixels. Precache requests match the browsing cache keys. Supported native platforms can avoid full-resolution decodes for small cards. Unsynchronized image loads fade in; cached images appear immediately. |

## Skills and implementation choices

The separate loading view was removed after the user chose the 3D Start Screen as the only introduction. Web now starts Flutter without a logo overlay, loading caption, or progress bar. Its error-only recovery view appears if initialization fails and offers Reload. Android launch backgrounds are plain teal; the Android 12+ system icon drawable is transparent, and the extra Android 13+ forced-icon overrides were removed. iOS uses a plain matching launch storyboard. Unused startup logo copies were removed; the original logo inside the 3D welcome screen remains. There is no minimum wait or additional splash route. Platform initialization still follows [Flutter's launch-screen guidance](https://docs.flutter.dev/platform-integration/android/splash-screen).

Startup verification: nine XML resources parsed; removed artwork and unused logo assets were checked; JavaScript syntax and both metadata-tool tests passed. Web and Android debug builds succeeded again. With bootstrap paused, browser inspection found no loading panels, logo, or caption before Flutter initialized. Restoring startup opened the 3D welcome screen directly: idle motion changed between frames, reduced-motion snapshots stayed still, and ORDER NOW opened the menu. A controlled initialization failure showed the error-only Reload action and recovered to the 3D screen. See [the current starting screen](../artifacts/direct-3d-start-phone.png). iOS resources were checked statically but could not be built or run on this Windows host; native launch appearance still needs hardware/emulator validation.

Applied the applicable guidance from `flutter-design-taste`, `flutter-animations`, responsive layout, layout repair, widget testing, and the design-system/performance/state audit skills. Existing menu previews also render the new widgets and permit navigation to Discover. CI/CD build guidance was used for local validation; deployment automation was outside this UI task.

The audit guidance was used to make focused implementation decisions:

- Lazy product slivers and `PageView.builder` stay in place.
- Press, reveal, and success animation controllers belong to their local widget states and are disposed with them. There are no new persistent animation loops.
- Entrance builders cache their static children. Carousel animation builders cache their product-card subtree and animate transforms rather than grid layout.
- Press feedback observes pointer events without taking the child's gesture recognizer or navigation action. Canceled presses return to rest. Disabled primary actions skip feedback.
- Reduced-motion preferences produce static, complete states, including when preferences change during an entrance.
- Existing receipt timers, controller ownership, local persistence, and validation seams remain. The UI task does not require a state-management framework migration or additional runtime packages.

All application Dart stays in `lib/main.dart`, following the user's starter-code convention. Catalog/importer source is unchanged, preserving all 92 product names, prices, categories, and asset paths. No backend, order schema, map provider, payment gateway, or tracking service was introduced. Existing customer-facing payment-preview disclosures remain accurate.

## Validation

- `flutter analyze --no-pub`: **no issues**.
- `flutter test --no-pub --reporter expanded`: **88 passed**.
- Six new interaction/layout/lifecycle tests are in `test/polish_experience_test.dart`. Existing tests now use the intentional Discover destination/title and updated heading. The payment test dismisses the input focus before scrolling to the payment choice, matching the customer flow.
- `node --test test/web_preview_test.mjs`: **2 passed**.
- `flutter build web --no-pub`: **successful**, including the Wasm compatibility dry run. Browser checks used the default JavaScript build.
- `flutter build apk --debug --no-pub`: **successful**. Updated artifact: `build/app/outputs/flutter-apk/app-debug.apk`.
- Catalog integrity comparison, single-file application source check, and `git diff --check`: **passed**.

Browser inspection covered phone (390 × 844), tablet (768 × 1024), and desktop (1440 × 1000) layouts. The complete browser journey exercised ORDER NOW, Discover's accessible Coffee shortcut, search, product details, quantity changes, the bag flight, checkout, a manual OpenStreetMap pin and suggested address, GCash failure/retry/cancellation/success, the new completion animation, timed tracking, saved history, and return navigation. The manually typed multiline address was preserved. Titles followed each destination. No JavaScript page or console errors appeared during this journey.

The widget suite additionally covers a 320-pixel screen with 2× text and reduced-motion behavior. A browser check with reduced motion enabled also tapped Pastries and swiped to Ice Blended; the selected tab and eight matching products stayed synchronized. Physical haptics, native GPS/geocoding accuracy, the iPhone status-bar gesture, iOS builds, and target-device frame rates were not measured in this pass. An Android APK was built but not installed on hardware. The share-preview hosting setup remains waiting for a public HTTPS URL, as previously agreed.

## Visual evidence

Latest Discover cleanup: [before](../artifacts/discover-cleanup-before.png), [phone](../artifacts/discover-cleanup-phone.png), [phone contact details](../artifacts/discover-cleanup-details-phone.png), [tablet](../artifacts/discover-cleanup-tablet.png), [desktop](../artifacts/discover-cleanup-desktop.png). All 88 Flutter tests and analysis passed after this cleanup, and both web and Android debug builds succeeded. Browser checks confirmed each category shortcut, the menu action, retained contact controls, and no JavaScript page errors.

Earlier app-polish screenshots:

- [Menu — phone](../artifacts/polish-menu-phone.png), [desktop](../artifacts/polish-menu-desktop.png)
- [Discover — phone](../artifacts/polish-discover-phone.png), [tablet](../artifacts/polish-discover-tablet.png), [desktop](../artifacts/polish-discover-desktop.png)
- [Product details](../artifacts/polish-details-phone.png), [bag](../artifacts/polish-bag-phone.png), [checkout](../artifacts/polish-checkout-phone.png)
- [Confirmation](../artifacts/polish-confirmation-phone.png), [history](../artifacts/polish-history-phone.png), [opening screen](../artifacts/polish-start-phone.png)
