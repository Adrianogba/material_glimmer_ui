import 'package:flutter_test/flutter_test.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';
import 'package:material_glimmer_ui_example/main.dart';

void main() {
  testWidgets('the gallery opens on the overview page', (tester) async {
    await tester.pumpWidget(const MaterialGlimmerGallery());
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Material Glimmer UI'), findsOneWidget);
    expect(find.text('Museu do Café'), findsOneWidget);
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

    expect(find.text('SCALE'), findsOneWidget);
    expect(find.text('COLOUR'), findsOneWidget);
  });

  testWidgets('the scale toggle re-themes the whole gallery', (tester) async {
    await tester.pumpWidget(const MaterialGlimmerGallery());
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Foundations'));
    await tester.pump(const Duration(seconds: 1));

    GlimmerScale scaleInScope() =>
        GlimmerTheme.of(tester.element(find.text('SCALE'))).scale;

    expect(scaleInScope(), GlimmerScale.mobile);
    final before = tester.getSize(find.text('SCALE')).height;

    await tester.tap(find.text('Glasses'));
    // One frame to commit the setState, then past the theme transition.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(scaleInScope(), GlimmerScale.glasses);
    expect(tester.getSize(find.text('SCALE')).height, greaterThan(before));
  });
}
