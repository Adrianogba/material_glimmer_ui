import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';

/// The light theme's whole failure mode, in one place.
///
/// Every fault found on the light theme so far has been the same mistake: a
/// value chosen as "light against black", written as a constant, and then used
/// on white where it means nothing. The press flash, the focused edge, the
/// backdrop and the progress crest were all this.
///
/// [GlimmerColors.highlightTint] is the fix, and these are the tests that stop
/// it coming back.
void main() {
  group('highlightTint', () {
    test('runs toward white on dark and toward ink on light', () {
      final dark = GlimmerColors.standard();
      final light = GlimmerColors.light();

      expect(dark.highlightTint.computeLuminance(), greaterThan(0.9));
      expect(light.highlightTint.computeLuminance(), lessThan(0.1));
    });

    test('highlight moves a colour toward the ground it has to stand out on',
        () {
      final dark = GlimmerColors.standard();
      final light = GlimmerColors.light();

      // The same call on the same colour has to go opposite ways, or one of
      // the two themes gets a highlight that is invisible.
      expect(
        dark.highlight(dark.primary, 0.5).computeLuminance(),
        greaterThan(dark.primary.computeLuminance()),
      );
      expect(
        light.highlight(light.primary, 0.5).computeLuminance(),
        lessThan(light.primary.computeLuminance()),
      );
    });

    test('a full step lands on the tint itself', () {
      final light = GlimmerColors.light();
      expect(light.highlight(light.primary, 1), light.highlightTint);
    });
  });

  // The idiom that caused all of it. `Color.lerp(x, white, k)` means "make this
  // brighter", which is only a highlight on a dark ground. Nothing in the kit
  // should say it any more: the ones that are genuinely ground-independent,
  // such as the shine across a slider's thumb, sit on a saturated fill and are
  // written as a plain white paint rather than as a lerp.
  test('no widget brightens toward a hardcoded white', () {
    final offenders = <String>[];
    final sources = Directory('lib/src')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));

    for (final file in sources) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (!line.contains('Color.lerp(')) continue;
        // The colour being lerped toward can be on the next line.
        final window = i + 1 < lines.length ? line + lines[i + 1] : line;
        if (window.contains('0xFFFFFFFF')) {
          offenders.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'use GlimmerColors.highlight, which knows which ground it is on',
    );
  });

  group('a press reads on both grounds', () {
    Future<int> luminanceWhilePressed(
      WidgetTester tester, {
      required ThemeMode mode,
    }) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialGlimmerApp(
          themeMode: mode,
          home: GlimmerScaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 200,
                  height: 80,
                  child: GlimmerSurface(onTap: () {}, child: const Text('x')),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<int> sample() async {
        late int value;
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final pixels = (await image.toByteData())!;
          // Clear of the text and of the edge.
          const offset = ((20 * 200) + 30) * 4;
          value = pixels.getUint8(offset) +
              pixels.getUint8(offset + 1) +
              pixels.getUint8(offset + 2);
        });
        return value;
      }

      final resting = await sample();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlimmerSurface)),
      );
      // One pump to let the tap deadline fire, and another to let the press
      // spring actually get somewhere before the frame is captured.
      await tester.pump(const Duration(milliseconds: 120));
      await tester.pump(const Duration(milliseconds: 120));
      final pressed = await sample();

      await gesture.up();
      await tester.pumpAndSettle();

      return pressed - resting;
    }

    testWidgets('it lightens on a dark ground', (tester) async {
      final change = await luminanceWhilePressed(
        tester,
        mode: ThemeMode.dark,
      );
      expect(change, greaterThan(0));
    });

    // A white flash on a white surface is not a press state, it is nothing
    // happening, which is exactly how it shipped.
    testWidgets('and darkens on a light one', (tester) async {
      final change = await luminanceWhilePressed(
        tester,
        mode: ThemeMode.light,
      );
      expect(change, lessThan(0));
    });
  });
}
