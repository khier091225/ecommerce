# Fix: Show a branded fallback if a widget breaks

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/friendly-error-view
- **Needs new dependency**: none

## Why

There is no custom ErrorWidget.builder, so a release build can show a grey error slot. Use the article's adaptive branded view, debug-only technical details and hidden long-press copy, without masking errors during verification.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where

One global startup hook is missing. The fallback may land in any screen, tiny card slot or root, so it must not require a Scaffold, Directionality, MediaQuery, app theme ancestor, or finite constraints. Existing ProductImage and checkout/history error feedback remain their specific recovery paths.

### lib/main.dart:1

```dart
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_map/flutter_map.dart'
    show FlutterMap, MapController, MapOptions, Marker, MarkerLayer, TileLayer;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
```

### lib/main.dart:18

```dart
void main() {
  runApp(MiniShopApp(orderStore: PreferencesOrderStore()));
}
```

### lib/main.dart:35

```dart
abstract final class AppColors {
  static const dark = Color(0xFF0A4952);
  static const teal = Color(0xFF0E6F7A);
  static const coral = Color(0xFFF04C45);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFFC0D8DA);
  static const line = Color(0xFF39747C);
  static const canvas = Color(0xFFF6F3ED);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF163B3D);
  static const secondaryText = Color(0xFF56696B);
  static const border = Color(0xFFDCE3DF);
  static const action = Color(0xFFC23F38);
  static const softTeal = Color(0xFFE8F0EC);
  static const softCoral = Color(0xFFFBE9E5);
}
```

## The fix

Before runApp in main, preserve any existing async startup code and set:

```dart
WidgetsFlutterBinding.ensureInitialized();
ErrorWidget.builder = (details) => FriendlyErrorView(details: details);
```

Merge kDebugMode into the existing foundation show import, and add Clipboard, ClipboardData and HapticFeedback from flutter/services.dart. dart:async and material imports already exist. Add the following article-derived implementation in lib/main.dart. It uses the cafe palette directly, can operate without an inherited theme, shows details only in debug, honors reduced motion and contains unsupported clipboard/haptic failures. The full mode requires at least 300×320; smaller slots use the compact badge.

```dart
/// Friendly replacement for Flutter's red error screen, installed via
/// [ErrorWidget.builder]. Release builds show no technical details; debug
/// builds add the exception and stack trace. A long press anywhere copies
/// the details to the clipboard.
///
/// Adapts to the space the broken widget occupied: a full layout when there
/// is room, an icon-only badge inside small slots.
class FriendlyErrorView extends StatefulWidget {
  const FriendlyErrorView({
    super.key,
    required this.details,
  });

  final FlutterErrorDetails details;

  @override
  State<FriendlyErrorView> createState() => _FriendlyErrorViewState();
}

class _FriendlyErrorViewState extends State<FriendlyErrorView> {
  Timer? _timer;
  bool _copied = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    try {
      await HapticFeedback.mediumImpact();

      await Clipboard.setData(
        ClipboardData(
          text:
              '${widget.details.exceptionAsString()}\n\n${widget.details.stack}',
        ),
      );
    } catch (_) { return; }

    if (!mounted) return;

    setState(() => _copied = true);

    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // The view can land anywhere in the tree, including where no Material or
    // Directionality ancestor exists, so it provides its own. The transparent
    // Material also prevents the yellow "missing Material" text underlines.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        type: MaterialType.transparency,
        child: Semantics(
          container: true,
          label: 'Something went wrong. Please reopen the app and try again.',
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: _copy,
              child: LayoutBuilder(
                builder: (context, c) {
                  final bool full =
                      c.maxHeight.isFinite &&
                      c.maxHeight >= 320 &&
                      c.maxWidth.isFinite &&
                      c.maxWidth >= 300;

                  // Only fill bounded axes; under unbounded constraints
                  // (lists, FittedBox) the view sizes to its content.
                  return Container(
                    width: c.hasBoundedWidth ? c.maxWidth : null,
                    height: c.hasBoundedHeight ? c.maxHeight : null,
                    decoration: BoxDecoration(
                      color: AppColors.softTeal,
                      borderRadius: BorderRadius.circular(full ? 0 : 28),
                    ),
                    child: full
                        ? _FriendlyErrorFullView(
                            details: widget.details,
                            copied: _copied,
                          )
                        : _FriendlyErrorCompactView(
                            details: widget.details,
                            copied: _copied,
                          ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FriendlyErrorFullView extends StatelessWidget {
  const _FriendlyErrorFullView({
    required this.details,
    required this.copied,
  });

  final FlutterErrorDetails details;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    final TextTheme tt = AppTheme.theme.textTheme;

    final Widget header = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FriendlyErrorBadge(
          size: 104,
          copied: copied,
        ),
        const SizedBox(height: 24),
        Text(
          'Something went wrong',
          textAlign: TextAlign.center,
          style: tt.titleLarge?.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please reopen the app and try again.',
          textAlign: TextAlign.center,
          style: tt.bodyMedium?.copyWith(
            color: AppColors.ink.withValues(alpha: 0.75),
          ),
        ),
      ],
    );

    // Centered while the content fits, scrollable once it doesn't: the
    // sliver forces the child to at least viewport height, and the centered
    // column simply grows past it when the debug stack trace is long.
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            // Clear the status bar and home indicator; the view has no
            // Scaffold or SafeArea above it (and possibly no MediaQuery).
            padding: EdgeInsets.fromLTRB(
              32,
              (MediaQuery.maybePaddingOf(context)?.top ?? 0) + 32,
              32,
              (MediaQuery.maybePaddingOf(context)?.bottom ?? 0) + 32,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                header,
                if (kDebugMode) ...[
                  const SizedBox(height: 32),
                  _FriendlyErrorDebugText(
                    '${details.exceptionAsString()}\n\n${details.stack}',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FriendlyErrorCompactView extends StatelessWidget {
  const _FriendlyErrorCompactView({
    required this.details,
    required this.copied,
  });

  final FlutterErrorDetails details;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _FriendlyErrorBadge(
                size: 48,
                copied: copied,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: 240,
                  child: _FriendlyErrorDebugText(
                    details.exceptionAsString(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The badge briefly swaps its "!" for a check after the hidden long-press
/// copy gesture, so regular users never see a hint.
class _FriendlyErrorBadge extends StatelessWidget {
  const _FriendlyErrorBadge({
    required this.size,
    required this.copied,
  });

  final double size;
  final bool copied;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: AppColors.teal,
        // A soft flower built with the SDK's StarBorder, so this file needs
        // no shape package.
        shape: const StarBorder(
          points: 12,
          innerRadiusRatio: 0.8,
          pointRounding: 0.7,
          valleyRounding: 0.3,
        ),
      ),
      child: AnimatedSwitcher(
        duration: (MediaQuery.maybeOf(context)?.disableAnimations ?? false)
            ? Duration.zero : const Duration(milliseconds: 200),
        child: Icon(
          copied ? Icons.check_rounded : Icons.priority_high_rounded,
          key: ValueKey<bool>(copied),
          color: AppColors.white,
          size: size * 0.4,
        ),
      ),
    );
  }
}

/// Exception text shown only in debug builds.
class _FriendlyErrorDebugText extends StatelessWidget {
  const _FriendlyErrorDebugText(this.text, {this.maxLines, this.textAlign});

  final String text;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      overflow: maxLines == null ? TextOverflow.fade : TextOverflow.ellipsis,
      style: TextStyle(
        fontFamily: 'monospace',
        fontFamilyFallback: const ['Menlo', 'Courier'],
        fontSize: 12,
        color: AppColors.ink.withValues(alpha: 0.6),
      ),
    );
  }
}
```

Keep FlutterError.onError/reporting untouched. A fallback does not mean a failing test or overflow is acceptable. Do not install this builder globally inside ordinary widget tests to silence framework failures.

## Steps

1. Merge the specified imports in lib/main.dart and install ErrorWidget.builder before runApp.
2. Add the full implementation above in the shared-widgets section; keep all application classes in main.dart.
3. Add test/friendly_error_view_test.dart covering 400×700, 40×40 and unbounded list constraints, no inherited app widgets, debug semantics, reduced motion, copy success/failure, timer disposal and fallback-hook restoration.
4. Use a separate test harness under test/ for a release web/device run with synthetic FlutterErrorDetails, verifying no exception/stack text is exposed. Keep synthetic failures out of production flows.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'ErrorWidget.builder|class FriendlyErrorView|kDebugMode' lib/main.dart` finds hook, adaptive view and debug-only details.
- `rtk flutter test test/friendly_error_view_test.dart` passes without suppressing unrelated test errors.
- `rtk flutter build web` succeeds; a release harness shows only friendly branded content. Long-press copy on a supported platform copies synthetic diagnostic text, while denial does not cause a second exception.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not override FlutterError.onError, hide analyzer/test failures, expose stacks in release UI, or deliberately break the real ordering flow.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe the branded recovery view and point to the isolated synthetic-error harness, not a deliberately broken customer screen. Report the checks actually executed and any remaining device or hosting verification.
