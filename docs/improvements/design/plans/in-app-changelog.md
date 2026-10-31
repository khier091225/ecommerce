# Fix: Show useful changes once after an app update

> Follow the steps in order. Run every check. If anything in "STOP if" happens, stop and report instead of improvising.

- **Link**: https://flutterpro.design/details/md/in-app-changelog
- **Needs new dependency**: package_info_plus to read the installed version; pub_semver to compare versions. shared_preferences is already present.

## Why

Customers currently get no explanation when an update changes the ordering flow. Show only release notes they have not seen, once after an update, and never interrupt a first installation.

Planning date: 31 October 2026 (Asia/Manila). Source baseline: fc76bcd7192c63460df486deb451a5876d17cc09. These are implementation instructions, not changes already applied. Line numbers identify the reviewed revision; verify the quoted text before editing.

The app is Smooch Cafe, rooted at this repository's Flutter pubspec. All application Dart must remain in lib/main.dart. Preserve all 92 catalog records and the BEGIN CAFE CATALOG / END CAFE CATALOG importer markers. Keep StartScreen first, its logo/name/tagline, the exact ORDER NOW label, and Navigator.push with MaterialPageRoute. Keep search, synchronized category taps/swipes, sorting, product details, quantities, basket counts/totals, local receipts, the current 10 km delivery validation, OpenStreetMap/GPS address flow, and ten-second delivery stages. Payment remains a local preview. Do not reintroduce demo/simulated/simulation wording into the app. Keep the restored Cafe info layout.

Merge a change into an existing import, theme entry, builder, or helper rather than adding duplicate configuration. If a previously executed plan changed a quoted excerpt, apply the STOP rule and refresh that excerpt against the new baseline before resuming; do not overwrite that plan's work. No extraction of app Dart into other files. Tests may be separate under test/.

## Where



### lib/main.dart:18

```dart
void main() {
  runApp(MiniShopApp(orderStore: PreferencesOrderStore()));
}
```

### lib/main.dart:1684

```dart
class _MiniShopAppState extends State<MiniShopApp> {
  late final ShopController controller;

  @override
  void initState() {
    super.initState();
    controller = ShopController(
      repository: const MenuRepository(),
      orderStore: widget.orderStore,
    );
    unawaited(controller.restoreOrders().catchError((Object _) {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smooch Cafe',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: StartScreen(controller: controller),
  );
}

// ============================================================
```

### lib/main.dart:2141

```dart
class StartScreen extends StatefulWidget {
  const StartScreen({super.key, required this.controller});

  final ShopController controller;
  static const duration = Duration(milliseconds: 2400);
  static const transitionDuration = Duration(milliseconds: 600);

  @override
  State<StartScreen> createState() => _StartScreenState();
}

```

### pubspec.yaml:19

```yaml
version: 1.0.0+1

environment:
  sdk: ^3.13.1

# Dependencies specify other packages that your package needs in order to work.
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

Use the article's versioned local map, semantic comparison, installed-version lookup and persisted last-seen key. Keep it local; there is no approved release-notes service. Add these imports in lib/main.dart, using compatible package versions resolved by the commands in Steps:

```dart
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

const releaseNotes = <String, List<String>>{
  '1.0.0': ['Clearer order statuses and payment steps.'],
};

Version? releaseVersion(String value) {
  try { return Version.parse(value); }
  on FormatException { return null; }
}

List<String> unseenChanges(String lastSeen, String current) {
  final previous = releaseVersion(lastSeen);
  final installed = releaseVersion(current);
  if (previous == null || installed == null || installed <= previous) return [];
  final versions = releaseNotes.keys.map(Version.parse).toList()..sort();
  return [
    for (final version in versions)
      if (version > previous && version <= installed)
        ...releaseNotes[version.toString()]!,
  ];
}
```

Add a guarded async method to _StartScreenState, called once by its existing post-frame callback without blocking ORDER NOW. Read PackageInfo.fromPlatform().version and SharedPreferences key 'smooch_last_seen_version'. If missing, save current and show nothing. If equal or older, show nothing and do not move the saved version backwards. If no relevant notes, save current and return. Otherwise, provided mounted, !_leaving and ModalRoute.of(context)?.isCurrent == true, call FocusManager.instance.primaryFocus?.unfocus(), then showDialog<void> with AlertDialog title 'What’s new', a scrollable list of the notes and one FilledButton labeled 'Got it'. Mark current seen after the dialog completes. Await setString; catch plugin/read/write/version parsing failures and leave ordering usable without an error modal. Do not show a late dialog on the menu. Set a per-State boolean guard before loading so rebuilds cannot duplicate the dialog. Include a test-injectable installed-version reader if package platform mocks cannot reliably drive this path.

Implement the guarded State method explicitly (add bool _checkedReleaseNotes = false to that State). Call unawaited(_checkReleaseNotes()) from the existing post-frame callback after its mounted check:

```dart
Future<void> _checkReleaseNotes() async {
  if (_checkedReleaseNotes || !mounted) return;
  _checkedReleaseNotes = true;
  try {
    final current = (await PackageInfo.fromPlatform()).version;
    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString('smooch_last_seen_version');
    if (last == null) {
      await prefs.setString('smooch_last_seen_version', current);
      return;
    }
    final before = releaseVersion(last);
    final after = releaseVersion(current);
    if (after == null) return;
    if (before != null && after <= before) return;
    final notes = unseenChanges(last, current);
    if (notes.isEmpty) {
      await prefs.setString('smooch_last_seen_version', current);
      return;
    }
    if (!mounted || _leaving || ModalRoute.of(context)?.isCurrent != true) return;
    FocusManager.instance.primaryFocus?.unfocus();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('What’s new'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final note in notes)
                Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(note)),
            ]),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it')),
        ],
      ),
    );
    await prefs.setString('smooch_last_seen_version', current);
  } catch (_) {
    // Release-note failure must not prevent ordering.
  }
}
```


## Steps

1. Run `rtk flutter pub add package_info_plus pub_semver` only if these direct dependencies are absent; reuse either already added by another plan.
2. Add the map/comparison helper and guarded version/preferences flow in lib/main.dart. Keep the order-history preferences key separate.
3. Start the check in the StartScreen post-frame path; preserve asset preloading and navigation guard. Wire the dialog and seen-version write as described.
4. Add test/changelog_test.dart for first install, equal version, upgrade spanning several notes, downgrade, malformed version, lookup finishing after navigation, and read/write failures.

## Check it

- `rtk flutter analyze` exits clean.
- `rtk rg -n 'smooch_last_seen_version|unseenChanges' lib/main.dart` finds the helper and load/dismiss path.
- `rtk flutter test test/changelog_test.dart` passes; first launch and repeated launches do not display the dialog, and an upgrade displays it once.
- Tap ORDER NOW while lookup is delayed; the menu must stay usable without a late popup.

## Don't touch

- Product records, images, prices, importer tooling, order calculations, stored receipt schema, payment connectivity, and delivery rules.
- The restored Cafe info design or the mandatory StartScreen navigation contract.
- Do not add remote configuration, a release service, or bump the package version just to demonstrate this feature.
- No new dependencies except those declared above. No refactors, renames, or cleanups beyond this fix.

## STOP if

- The code at a location in Where does not match its quoted excerpt; the codebase moved on since this plan was written.
- The fix seems to require changing anything in Don't touch.
- A check fails twice.

## When you're done

Tell the developer in two or three sentences: describe that customers see relevant changes once after an update; identify reopening an upgraded app as the place to see it. Report the checks actually executed and any remaining device or hosting verification.
