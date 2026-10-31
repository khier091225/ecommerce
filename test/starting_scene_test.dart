import 'dart:ui' as ui;

import 'package:ecommerce/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

CoffeeScenePainter scenePainter(WidgetTester tester) =>
    tester.widget<CustomPaint>(find.byKey(const Key('coffee-scene'))).painter!
        as CoffeeScenePainter;

Future<ValueNotifier<bool>> pumpStartingScene(
  WidgetTester tester, {
  double textScale = 1,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final shop = ShopController(repository: const MenuRepository());
  final reduced = ValueNotifier(false);
  addTearDown(shop.dispose);
  addTearDown(reduced.dispose);
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.theme,
      builder: (context, child) => ValueListenableBuilder<bool>(
        valueListenable: reduced,
        builder: (context, disabled, _) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disabled,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
      ),
      home: StartScreen(controller: shop, versionReader: () async => '1.0.0'),
    ),
  );
  await tester.pump();
  await tester.pump(StartScreen.duration + const Duration(milliseconds: 100));
  await tester.pump(const Duration(milliseconds: 100));
  return reduced;
}

void expectBoundedTilt(Offset value) {
  expect(value.dx, inInclusiveRange(-1.0, 1.0));
  expect(value.dy, inInclusiveRange(-1.0, 1.0));
}

Future<Uint8List> rasterizeScene(CoffeeScenePainter painter) async {
  const width = 320, height = 360;
  final recorder = ui.PictureRecorder();
  painter.paint(ui.Canvas(recorder), const Size(320, 360));
  final picture = recorder.endRecording();
  ui.Image? image;
  try {
    image = await picture.toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    return Uint8List.fromList(
      bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
    );
  } finally {
    image?.dispose();
    picture.dispose();
  }
}

void expectSameRaster(
  Uint8List first,
  Uint8List second, {
  required String reason,
}) {
  expect(first.length, second.length);
  var differentChannels = 0;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) differentChannels++;
  }
  expect(differentChannels, 0, reason: reason);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader(
      'Montserrat',
    )..addFont(rootBundle.load('assets/fonts/Montserrat.ttf'))).load();
    await (FontLoader(
      'Playfair',
    )..addFont(rootBundle.load('assets/fonts/PlayfairDisplay.ttf'))).load();
  });
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'Cup hover produces bounded tilt and settles after pointer exit',
    (tester) async {
      await pumpStartingScene(tester);
      final rect = tester.getRect(find.byKey(const Key('coffee-scene')));
      final pointer = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await pointer.addPointer(location: const Offset(1, 1));
      await tester.pump();
      await pointer.moveTo(
        rect.center + Offset(rect.width * .35, -rect.height * .2),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final tilt = scenePainter(tester).interaction;
      expect(tilt.dx.abs(), greaterThan(.02));
      expect(tilt.dy.abs(), greaterThan(.02));
      expectBoundedTilt(tilt);
      await pointer.moveTo(const Offset(1, 1));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(scenePainter(tester).interaction.distance, lessThan(.01));
      await pointer.removePointer();
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Horizontal drag returns to rest after release or cancellation and keeps ordering usable',
    (tester) async {
      await pumpStartingScene(tester);
      final canvas = find.byKey(const Key('coffee-scene'));
      for (final cancel in [false, true]) {
        final gesture = await tester.startGesture(tester.getCenter(canvas));
        await gesture.moveBy(const Offset(45, 2));
        await tester.pump();
        await gesture.moveBy(const Offset(70, 2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(scenePainter(tester).interaction.dx.abs(), greaterThan(.02));
        expectBoundedTilt(scenePainter(tester).interaction);
        if (cancel) {
          await gesture.cancel();
        } else {
          await gesture.up();
        }
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(scenePainter(tester).interaction.distance, lessThan(.01));
      }
      final action = find.byKey(const Key('enter-store'));
      await tester.ensureVisible(action);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(action);
      await tester.pump();
      await tester.pump(
        StartScreen.transitionDuration + const Duration(seconds: 1),
      );
      expect(find.byType(MenuScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Vertical drags over the sculpture still scroll the enlarged-text page',
    (tester) async {
      await pumpStartingScene(tester, textScale: 1.6);
      final scroll = tester.state<ScrollableState>(
        find
            .descendant(
              of: find.byType(StartScreen),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final before = scroll.position.pixels;
      await tester.drag(
        find.byKey(const Key('coffee-scene')),
        const Offset(0, -180),
      );
      await tester.pump(const Duration(milliseconds: 400));
      expect(scroll.position.pixels, greaterThan(before));
      expect(scenePainter(tester).interaction.distance, lessThan(.01));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Reduced motion clears an active tilt and ignores further pointer gestures',
    (tester) async {
      final reduced = await pumpStartingScene(tester);
      final canvas = find.byKey(const Key('coffee-scene'));
      final rect = tester.getRect(canvas);
      final pointer = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await pointer.addPointer(location: const Offset(1, 1));
      await pointer.moveTo(
        rect.center + Offset(rect.width * .3, -rect.height * .2),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(scenePainter(tester).interaction.distance, greaterThan(.02));
      reduced.value = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 32));
      expect(scenePainter(tester).reducedMotion, isTrue);
      expect(scenePainter(tester).interaction, Offset.zero);
      await pointer.moveTo(
        rect.center - Offset(rect.width * .3, -rect.height * .2),
      );
      await tester.drag(canvas, const Offset(100, 0));
      await tester.pump(const Duration(seconds: 1));
      expect(scenePainter(tester).interaction, Offset.zero);
      expect(tester.hasRunningAnimations, isFalse);
      await pointer.removePointer();
      reduced.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  test('Scene invalidation observes tilt, and the painter handles intro endpoints and small bounds', () {
    final neutral = CoffeeScenePainter(
      progress: 1,
      reducedMotion: false,
      idlePhase: .2,
    );
    expect(
      CoffeeScenePainter(
        progress: 1,
        reducedMotion: false,
        idlePhase: .2,
      ).shouldRepaint(neutral),
      isFalse,
    );
    expect(
      CoffeeScenePainter(
        progress: 1,
        reducedMotion: false,
        idlePhase: .2,
        interaction: const Offset(.4, -.2),
      ).shouldRepaint(neutral),
      isTrue,
    );
    for (final size in [
      Size.zero,
      const Size(1, 1),
      const Size(280, 160),
      const Size(500, 460),
    ]) {
      for (final progress in [0.0, .12, .5, 1.0]) {
        for (final interaction in [Offset.zero, const Offset(1, -1)]) {
          final recorder = ui.PictureRecorder();
          final canvas = ui.Canvas(recorder);
          try {
            expect(
              () => CoffeeScenePainter(
                progress: progress,
                reducedMotion: false,
                idlePhase: .85,
                interaction: interaction,
              ).paint(canvas, size),
              returnsNormally,
            );
          } finally {
            if (recorder.isRecording) recorder.endRecording().dispose();
          }
        }
      }
    }
  });

  testWidgets(
    'Completed scene has no raster seam and reduced motion keeps one stable pose',
    (tester) async {
      await tester.runAsync(() async {
        final start = await rasterizeScene(
          CoffeeScenePainter(progress: 1, reducedMotion: false, idlePhase: 0),
        );
        final end = await rasterizeScene(
          CoffeeScenePainter(progress: 1, reducedMotion: false, idlePhase: 1),
        );
        expect(
          start,
          isNot(everyElement(0)),
          reason: 'The scene must paint visible content.',
        );
        expectSameRaster(
          start,
          end,
          reason: 'A completed idle loop must meet its first frame without a visual jump.',
        );
        final stillFirst = await rasterizeScene(
          CoffeeScenePainter(
            progress: 1,
            reducedMotion: true,
            idlePhase: .13,
            interaction: const Offset(.8, -.7),
          ),
        );
        final stillSecond = await rasterizeScene(
          CoffeeScenePainter(
            progress: 1,
            reducedMotion: true,
            idlePhase: .87,
            interaction: const Offset(-.6, .9),
          ),
        );
        expectSameRaster(
          stillFirst,
          stillSecond,
          reason:
              'Reduced motion must ignore animation phase and pointer tilt.',
        );
      });
    },
  );
}
