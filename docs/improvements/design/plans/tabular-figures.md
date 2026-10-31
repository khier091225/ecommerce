# Fix: Keep changing quantities and totals visually steady

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/tabular-figures
- **Needs new dependency**: none

## Why

Quantity counters and monetary values use proportional digits. Apply the article's FontFeature.tabularFigures only to changing or aligned numeric text, retaining the existing fonts and sizes.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

Numeric-only counters: cart badge, QuantityPicker, bag-summary count. Money: featured/card/details prices, Add total, bag unit/line/overall totals, history total, checkout total, wallet rows/hero/button, receipt line/overall totals. The shared wallet paymentRow covers all its aligned amounts. Sentence counts, product labels, phone numbers, coordinates and dates are excluded.

### lib/main.dart:4

```dart
import 'dart:ui' show PointerDeviceKind;
```

### lib/main.dart:1903

```dart
            isLabelVisible: widget.controller.cartCount > 0,
            backgroundColor: AppColors.action,
            label: Text('${widget.controller.cartCount}'),
            child: const Icon(
```

### lib/main.dart:2086

```dart
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 28),
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
```

### lib/main.dart:3274

```dart
                                              Text(
                                                pesos(product.price),
                                                style: const TextStyle(
                                                  color: AppColors.white,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
```

### lib/main.dart:3380

```dart
                  ),
                  child: Text(
                    '${controller.cartCount}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'View bag',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  pesos(controller.total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
```

### lib/main.dart:3802

```dart
                      final price = Text(
                        pesos(product.price),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.dark,
                        ),
                      );
                      final add = _AnimatedAddButton(
```

### lib/main.dart:3936

```dart
                        const SizedBox(height: 18),
                        Text(
                          pesos(widget.product.price),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
```

### lib/main.dart:4023

```dart
                builder: (buttonContext) => FilledButton.icon(
                  key: const Key('details-add-to-cart'),
                  onPressed: adding ? null : () => addToCart(buttonContext),
                  icon: Icon(
                    adding ? Icons.check : Icons.shopping_bag_outlined,
                    size: 18,
                  ),
                  label: Text(
                    adding
                        ? 'Added to bag'
                        : 'Add to bag • ${pesos(widget.product.price * quantity)}',
                  ),
                ),
```

### lib/main.dart:4165

```dart
                            const Text('Total', style: TextStyle(fontSize: 16)),
                            Text(
                              pesos(orderTotal),
                              key: const Key('cart-total'),
                              style: const TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
```

### lib/main.dart:4278

```dart
                      Text(
                        '${pesos(item.product.price)} each',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
```

### lib/main.dart:4312

```dart
                ),
                Text(
                  pesos(item.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
```

### lib/main.dart:4491

```dart
                              const SizedBox(height: 8),
                              Text(
                                pesos(order.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
```

### lib/main.dart:5371

```dart
                        ),
                        Text(
                          pesos(widget.controller.total),
                          key: const Key('checkout-total'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
```

### lib/main.dart:5541

```dart
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: _WalletDemoColors.text,
                  fontWeight: total ? FontWeight.w800 : FontWeight.w600,
                  fontSize: total ? 18 : 14,
                ),
              ),
            ),
          ],
        ),
      );
```

### lib/main.dart:5839

```dart
                          alignment: Alignment.centerLeft,
                          child: Text(
                            pesos(widget.amount),
                            key: const Key('payment-amount'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.8,
                            ),
                          ),
                        ),
```

### lib/main.dart:5940

```dart
                      child: Text(switch (stage) {
                        _DemoPaymentStage.review =>
                          'Continue · ${pesos(widget.amount)}',
                        _DemoPaymentStage.processing => 'Processing…',
                        _DemoPaymentStage.success => 'Continue to order',
                        _DemoPaymentStage.failed => 'Try again',
                      }),
```

### lib/main.dart:6441

```dart
                                  ),
                                  Text(
                                    pesos(item.total),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
```

### lib/main.dart:6468

```dart
                          ),
                          Text(
                            pesos(order.total),
                            key: const Key('confirmation-total'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.dark,
                            ),
                          ),
                        ],
```

## The fix

Extend the existing dart:ui import with FontFeature. Add this shared constant, then merge its list into each existing affected TextStyle (use copyWith when deriving a style):

```dart
const cafeNumberFeatures = <FontFeature>[FontFeature.tabularFigures()];
```

For example, keep QuantityPicker's weight and alignment but use TextStyle(fontWeight: FontWeight.w700, fontFeatures: cafeNumberFeatures). Keep each amount's current color, size, weight and responsive behavior. For Add and wallet button labels, wrap only the label in DefaultTextStyle.merge(style: const TextStyle(fontFeatures: cafeNumberFeatures), child: existingLabel) so button theme typography is retained. Do not set font features globally: ordinary prose should keep natural spacing.

## Steps

1. Add FontFeature to the dart:ui show import and define cafeNumberFeatures near displayStyle in lib/main.dart.
2. Merge tabular figures into every numeric/amount location enumerated in Where, including shared paymentRow.
3. Preserve current typography and leave sentence counts untouched.
4. Verify digit stability with the bundled Montserrat font; add a focused test only for a changing counter and aligned total, not every literal style.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'FontFeature.tabularFigures|cafeNumberFeatures' lib/main.dart` finds the feature and numeric styles.
- Change quantity through 1, 8, 10, 18, 99 and compare aligned totals. Text must not shift because 1 and 8 have different widths.
- Existing real-font narrow/large-text layout tests remain clean; no global font override is added.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe steadier counters and aligned totals and point to changing quantity in the bag. Report the checks actually executed and any remaining device or hosting verification.
