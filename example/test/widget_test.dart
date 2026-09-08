import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';
import 'package:material_glimmer_ui_example/main.dart';

void main() {
  testWidgets('the gallery opens on the components page', (tester) async {
    await tester.pumpWidget(const MaterialGlimmerGallery());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Material Glimmer UI'), findsOneWidget);
    expect(find.text('Jabuticaba'), findsOneWidget);
    expect(find.byType(GlimmerCard), findsWidgets);
  });

  testWidgets('saving a card switches it to its focused state', (tester) async {
    await tester.pumpWidget(const MaterialGlimmerGallery());
    await tester.pump(const Duration(seconds: 1));

    // pumpAndSettle is not usable here: the voice input indicator on the
    // components page keeps animating inside the IndexedStack even while that
    // page is not showing, so the tree never settles.
    final save = find.text('Save');
    await tester.scrollUntilVisible(save, 160);
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(save, warnIfMissed: true);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('the navigation strip moves between pages', (tester) async {
    await tester.pumpWidget(const MaterialGlimmerGallery());
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Foundations'));
    await tester.pump(const Duration(seconds: 1));

    // The depth section is below the fold, and a ListView does not build what
    // it has not reached.
    expect(find.text('COLOUR'), findsOneWidget);
    expect(find.text('TYPE'), findsOneWidget);
  });

  testWidgets('the top bar toggle re-themes the whole gallery', (tester) async {
    await tester.pumpWidget(const MaterialGlimmerGallery());
    await tester.pump(const Duration(seconds: 1));

    Brightness brightnessInScope() =>
        GlimmerTheme.of(tester.element(find.text('CARD AND ACTIONS')))
            .colors
            .brightness;

    expect(brightnessInScope(), Brightness.dark);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    // One frame to commit the setState, then past the theme transition.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(brightnessInScope(), Brightness.light);
    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
  });
}
