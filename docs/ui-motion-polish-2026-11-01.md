# Smooch Cafe visual and animation polish

Implemented on 1 November 2026 (Asia/Manila), following authorization to change the app's UI, animations, content, and destinations.

## Design direction

An expressive cafe shopping app with editorial headings, warm ivory surfaces, dark teal structure, coral actions, subtle gold accents, and the existing bundled product photography. Product browsing remains compact and actionable. The opening 3D cup, logo, and ORDER NOW flow remain the app's introduction.

The plain Cafe info destination is now **Discover**. Its first content is useful: Coffee, Food, and Pastries collections open the corresponding menu category. A cafe story follows, with the original address, hours, call/email actions, and installed version below it. No reviews, discounts, delivery-time promises, or other unsupported claims were invented.

## Implemented experience

| Area | Result |
| --- | --- |
| Shared design language | `CafeShape`, `CafeMotion`, and `CafeSectionHeading` keep new shapes, timing, and section hierarchy consistent. Existing Montserrat/Playfair typography and teal/coral contrast are retained. |
| Menu navigation | A sliding dark-teal capsule follows the selected category. Horizontal category scrolling, auto visibility, gesture navigation, search, Reset, sorting, and content synchronization remain. Enlarged-text users get a shorter introduction so products remain reachable. |
| Featured products | A wider photographic carousel uses an editorial product title, subtle numbered backdrop, category and price, independently positioned Add action, and gentle scale changes during swipes. Photos retain their original colors. |
| Product cards | Cards have consistent softer corners, a Smooch-pick badge, a subtle press spring, and a small desktop hover lift. Compact sizing and adaptive columns remain. |
| Product details | The image and description enter smoothly without blocking the quantity or Add actions. The existing slow curved photo flight to the bag is retained. |
| Discover | Real collection shortcuts clear an old search, keep the selected sort and bag, synchronize the destination/category, and expose labeled accessibility actions. Contacts remain available on narrow screens and at 2× text. |
| Bag and checkout | The bag gets a clearer editorial heading. Contact, delivery, and payment steps use numbered icon headings. Primary actions share tactile feedback and stay still when disabled or reduced motion is enabled. Existing validation, manual address protection, GPS, map suggestions, and payment behavior are retained. |
| Order completion | A short custom-painted ring/checkmark confirms a new order and then stops. Reopened receipts show the completed mark immediately. Tracking segments reinforce the existing five stages, advancing on the original timing. |
| Images | Browsing images request a 640-pixel decode; detail images request 1024 pixels. Precache requests match the browsing cache keys. Supported native platforms can avoid full-resolution decodes for small cards. Unsynchronized image loads fade in; cached images appear immediately. |

## Skills and implementation choices

The startup loading view was subsequently branded with the original Smooch wordmark. Web uses an independent, high-priority PNG so the logo can display before Flutter initializes; the progress bar and first-frame removal remain. Android's legacy launch background and Android 12+/13+ day/night themes now use the logo on teal, with a transparent square and safe centered wordmark for the system icon. iOS launch assets and aspect-fit storyboard constraints match the same branding. The logo files are unchanged copies of the supplied asset. No minimum wait or additional splash route was introduced. Android configuration follows [Flutter's launch-screen guidance](https://docs.flutter.dev/platform-integration/android/splash-screen) and [Android's system splash dimensions](https://developer.android.com/develop/ui/views/launch/splash-screen).

Startup verification: 11 XML resources parsed; five logo copies matched the original; Android icon bounds and iOS aspect-fit constraints passed static checks. Web and Android debug builds succeeded again, as did both metadata-tool tests. The browser loader was inspected with bootstrap paused to capture [the loading view](../artifacts/startup-logo-phone.png), then normal loading was restored and confirmed to remove the boot overlay and reveal ORDER NOW. iOS launch resources were configured but could not be built or run on this Windows host; native launch appearance still needs hardware/emulator validation.

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

- [Menu — phone](../artifacts/polish-menu-phone.png), [desktop](../artifacts/polish-menu-desktop.png)
- [Discover — phone](../artifacts/polish-discover-phone.png), [tablet](../artifacts/polish-discover-tablet.png), [desktop](../artifacts/polish-discover-desktop.png)
- [Product details](../artifacts/polish-details-phone.png), [bag](../artifacts/polish-bag-phone.png), [checkout](../artifacts/polish-checkout-phone.png)
- [Confirmation](../artifacts/polish-confirmation-phone.png), [history](../artifacts/polish-history-phone.png), [opening screen](../artifacts/polish-start-phone.png)
