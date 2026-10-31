# Fix: Make the installed app version easy to find

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/show-app-version
- **Needs new dependency**: package_info_plus for the actual installed version/build; do not add Shorebird because this app does not use it.

## Why

The package declares a version but customers cannot see the installed build. Add the article's small asynchronous version label at the bottom of existing Cafe info, without redesigning that page.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where



### pubspec.yaml:19

```yaml
version: 1.0.0+1

environment:
  sdk: ^3.13.1

# Dependencies specify other packages that your package needs in order to work.
```

### lib/main.dart:6532

```dart
class CafeSection extends StatelessWidget {
  const CafeSection({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
```

### lib/main.dart:6598

```dart
        link: 'mailto:smoochcafe25@gmail.com',
        actionLabel: 'Email cafe',
      ),
      const SizedBox(height: 24),
      FilledButton.icon(
        onPressed: onBrowse,
        icon: const Icon(Icons.restaurant_menu),
        label: const Text('Explore our menu'),
      ),
    ],
  );
}

class _CafeInfo extends StatelessWidget {
```

### pubspec.yaml:35 — dependency insertion area; let pub add update the lockfile

```yaml
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.5.6
  flutter_map: ^8.3.2
  geolocator: ^14.1.2
  geocoding: ^5.0.1
  http: ^1.6.0
  latlong2: ^0.10.1
  url_launcher: ^6.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
```

## The fix

Use PackageInfo.fromPlatform, not a hard-coded copy of pubspec.yaml. Add AppVersionLabel in lib/main.dart:

```dart
class AppVersionLabel extends StatefulWidget {
  const AppVersionLabel({super.key});
  @override
  State<AppVersionLabel> createState() => _AppVersionLabelState();
}
class _AppVersionLabelState extends State<AppVersionLabel> {
  String? label;
  @override
  void initState() { super.initState(); unawaited(load()); }
  Future<void> load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => label = 'Smooch Cafe ${info.version} (${info.buildNumber})');
    } catch (_) { /* Do not block Cafe info if platform metadata is unavailable. */ }
  }
  @override
  Widget build(BuildContext context) => label == null
      ? const SizedBox.shrink()
      : Text(label!, style: const TextStyle(
          fontSize: 12, color: AppColors.secondaryText, height: 1.5));
}
```

Append SizedBox(height: 24) then AppVersionLabel after the existing Explore our menu button. Leave every current Cafe info element in place. If FontFeature.tabularFigures is already available from another plan, merge it into this numeric version label; otherwise it is optional for this static label. There is no patch updater to query.

## Steps

1. Run `rtk flutter pub add package_info_plus` if it is not already a direct dependency.
2. Import the package and add AppVersionLabel in lib/main.dart.
3. Append the quiet label at the existing CafeSection bottom; keep its restored layout.
4. Add test/app_version_label_test.dart with mocked version 1.2.3/build 7, platform read failure and disposal before completion.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'class AppVersionLabel|AppVersionLabel\(|PackageInfo.fromPlatform' lib/main.dart` finds the widget and read path.
- `rtk flutter test test/app_version_label_test.dart` passes and shows Smooch Cafe 1.2.3 (7).
- On an installed app, scroll Cafe info to the bottom and compare with actual package version/build.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not introduce a settings screen, Shorebird, patch infrastructure, or modify the package version to make the label appear.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe where users can find version and build, pointing to the bottom of Cafe info. Report the checks actually executed and any remaining device or hosting verification.
