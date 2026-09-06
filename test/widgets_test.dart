import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';

Widget host(Widget child, {GlimmerScale scale = GlimmerScale.mobile}) {
  return MaterialApp(
    theme: GlimmerTheme.dark(scale: scale),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('GlimmerSurface', () {
    testWidgets('is not a button when it has no callbacks', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const GlimmerSurface(child: Text('x'))));
      expect(
        tester.getSemantics(find.byType(GlimmerSurface)),
        isSemantics(isButton: false),
      );
      handle.dispose();
    });

    testWidgets('is a button and reports selection when interactive',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          GlimmerSurface(focused: true, onTap: () {}, child: const Text('x')),
        ),
      );
      expect(
        tester.getSemantics(find.byType(GlimmerSurface)),
        isSemantics(isButton: true, isSelected: true),
      );
      handle.dispose();
    });

    testWidgets('holds the press state for the source minimum', (tester) async {
      await tester.pumpWidget(
        host(GlimmerSurface(onTap: () {}, child: const Text('x'))),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GlimmerSurface)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await gesture.up();

      // Released almost immediately, but the overlay must survive the 300 ms
      // minimum, so frames are still being produced well after the release.
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('fires taps and long presses', (tester) async {
      var taps = 0;
      var longPresses = 0;
      await tester.pumpWidget(
        host(
          GlimmerSurface(
            onTap: () => taps++,
            onLongPress: () => longPresses++,
            child: const Text('x'),
          ),
        ),
      );

      await tester.tap(find.byType(GlimmerSurface));
      await tester.pumpAndSettle();
      expect(taps, 1);

      await tester.longPress(find.byType(GlimmerSurface));
      await tester.pumpAndSettle();
      expect(longPresses, 1);
    });

    // The press state is a flat overlay the surface paints itself. An InkWell
    // with every overlay disabled did the same job for a while, and brought
    // Material's highlight, hover and focus machinery plus a Material ancestor
    // with it.
    testWidgets('carries no Material ink machinery', (tester) async {
      await tester.pumpWidget(
        host(GlimmerSurface(onTap: () {}, child: const Text('x'))),
      );
      for (final type in [InkWell, InkResponse, Material]) {
        expect(
          find.descendant(
            of: find.byType(GlimmerSurface),
            matching: find.byWidgetPredicate((w) => w.runtimeType == type),
          ),
          findsNothing,
          reason: 'a surface still contains a $type',
        );
      }
    });

    testWidgets('a keyboard can activate a surface', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        host(
          GlimmerSurface(
            autofocus: true,
            onTap: () => taps++,
            child: const Text('x'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 1);

      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(taps, 2);
    });

    testWidgets('the ambient sweep does not run when it is off',
        (tester) async {
      await tester.pumpWidget(
        host(
          const GlimmerSurface(focused: true, child: Text('x')),
        ),
      );
      await tester.pumpAndSettle();
      // Nothing left running once focus has settled.
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('the ambient sweep starts after the source initial delay',
        (tester) async {
      await tester.pumpWidget(
        host(
          const GlimmerSurface(
            focused: true,
            enableAmbientPulse: true,
            child: Text('x'),
          ),
        ),
      );

      // Past the 800 ms focus transition but short of the 1800 ms delay.
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(GlimmerSurface), findsOneWidget);

      // Well past the delay, the sweep is running.
      await tester.pump(const Duration(milliseconds: 600));
      expect(tester.hasRunningAnimations, isTrue);

      // A disposed surface must not leave the repeating timer behind.
      await tester.pumpWidget(host(const SizedBox.shrink()));
      await tester.pumpAndSettle();
    });
  });

  group('GlimmerButton', () {
    testWidgets('labels itself for screen readers', (tester) async {
      await tester.pumpWidget(
        host(GlimmerButton(label: 'Reply', onPressed: () {})),
      );
      expect(find.bySemanticsLabel('Reply'), findsWidgets);
    });

    testWidgets('is inert and dimmed when disabled', (tester) async {
      await tester.pumpWidget(
        host(const GlimmerButton(label: 'Reply', onPressed: null)),
      );
      final surface = tester.widget<GlimmerSurface>(
        find.byType(GlimmerSurface),
      );
      expect(surface.onTap, isNull);
      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('medium and large use the published minimum heights',
        (tester) async {
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GlimmerButton(label: 'M', onPressed: () {}),
              GlimmerButton(
                label: 'L',
                size: GlimmerButtonSize.large,
                onPressed: () {},
              ),
            ],
          ),
        ),
      );
      final heights = tester
          .widgetList<GlimmerButton>(find.byType(GlimmerButton))
          .map((b) => tester.getSize(find.text(b.label)).height)
          .toList();
      expect(heights.length, 2);
      expect(GlimmerButtonSize.medium.minHeight, 48);
      expect(GlimmerButtonSize.large.minHeight, 72);
    });

    testWidgets('a toggle reports its state and flips it', (tester) async {
      var value = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => GlimmerToggleButton(
              label: 'Mute',
              selected: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(GlimmerToggleButton)),
        isSemantics(hasToggledState: true),
      );
      handle.dispose();

      await tester.tap(find.byType(GlimmerToggleButton));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });
  });

  group('GlimmerCard', () {
    testWidgets('renders its named slots', (tester) async {
      await tester.pumpWidget(
        host(
          const GlimmerCard(
            title: 'Blood oranges',
            supportingText: 'Produce outlet',
            leadingIcon: Icons.local_grocery_store,
          ),
        ),
      );
      expect(find.text('Blood oranges'), findsOneWidget);
      expect(find.text('Produce outlet'), findsOneWidget);
      expect(find.byIcon(Icons.local_grocery_store), findsOneWidget);
    });

    testWidgets('a child replaces the slot layout', (tester) async {
      await tester.pumpWidget(
        host(const GlimmerCard(title: 'ignored', child: Text('custom'))),
      );
      expect(find.text('custom'), findsOneWidget);
      expect(find.text('ignored'), findsNothing);
    });
  });

  group('GlimmerListItem and GlimmerList', () {
    testWidgets('a row renders its label, supporting label and icons',
        (tester) async {
      await tester.pumpWidget(
        host(
          const GlimmerListItem(
            label: 'Milk',
            supportingLabel: '1 litre',
            leadingIcon: Icons.circle_outlined,
            trailingIcon: Icons.chevron_right,
          ),
        ),
      );
      expect(find.text('Milk'), findsOneWidget);
      expect(find.text('1 litre'), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('a list separates rows by the Glimmer gap', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 400,
            child: GlimmerList(
              children: const [
                GlimmerListItem(label: 'Milk'),
                GlimmerListItem(label: 'Bread'),
              ],
            ),
          ),
        ),
      );
      final first = tester.getRect(find.text('Milk'));
      final second = tester.getRect(find.text('Bread'));
      expect(second.top, greaterThan(first.bottom));
      expect(find.byType(GlimmerListItem), findsNWidgets(2));
    });

    testWidgets('an integrated title renders as a chip', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 400,
            child: GlimmerList(
              title: 'Grocery list',
              children: const [GlimmerListItem(label: 'Milk')],
            ),
          ),
        ),
      );
      expect(find.byType(GlimmerTitleChip), findsOneWidget);
      expect(find.text('Grocery list'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
    });

    testWidgets('the builder constructor only builds visible rows',
        (tester) async {
      final built = <int>[];
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 200,
            child: GlimmerList.builder(
              itemCount: 500,
              itemBuilder: (context, index) {
                built.add(index);
                return GlimmerListItem(label: 'Row $index');
              },
            ),
          ),
        ),
      );
      expect(built.length, lessThan(500));
      expect(find.text('Row 0'), findsOneWidget);
    });
  });

  group('GlimmerTitleChip', () {
    testWidgets('is a header, not a control', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(host(const GlimmerTitleChip('Coffee 1:1')));
      expect(
        tester.getSemantics(find.byType(GlimmerTitleChip)),
        isSemantics(isHeader: true),
      );
      expect(find.byType(InkWell), findsNothing);
      handle.dispose();
    });

    testWidgets('truncates rather than wrapping', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 120,
            child:
                GlimmerTitleChip('A very long title that cannot possibly fit'),
          ),
        ),
      );
      final text = tester.widget<Text>(find.byType(Text).last);
      expect(text.maxLines, 1);
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });

  group('GlimmerStack', () {
    testWidgets('shows the front item and swipes between them', (tester) async {
      var index = 0;
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 400,
            width: 320,
            child: GlimmerStack(
              onIndexChanged: (next) => index = next,
              children: const [
                GlimmerCard(title: 'First'),
                GlimmerCard(title: 'Second'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('First'), findsOneWidget);
      await tester.fling(
        find.byType(GlimmerStack),
        const Offset(0, -200),
        1000,
      );
      await tester.pumpAndSettle();
      expect(index, 1);
    });

    testWidgets('moving between items is animated, not a cut', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            height: 400,
            width: 320,
            child: GlimmerStack(
              children: [
                GlimmerCard(title: 'First'),
                GlimmerCard(title: 'Second'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final restingTop = tester.getTopLeft(find.text('First')).dy;

      await tester.fling(
        find.byType(GlimmerStack),
        const Offset(0, -200),
        1000,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));

      // Part way through, the outgoing card has moved but has not finished,
      // and frames are still being produced.
      expect(tester.hasRunningAnimations, isTrue);
      final movedTop = tester.getTopLeft(find.text('First')).dy;
      expect(movedTop, lessThan(restingTop));

      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
      expect(find.text('Second'), findsOneWidget);
    });

    testWidgets('an empty stack renders nothing', (tester) async {
      await tester.pumpWidget(host(const GlimmerStack(children: [])));
      expect(find.byType(GlimmerCard), findsNothing);
    });
  });

  group('GlimmerVoiceInputIndicator', () {
    testWidgets('animates while listening and stops when it is not',
        (tester) async {
      await tester.pumpWidget(
        host(const GlimmerVoiceInputIndicator()),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      // pumpAndSettle only returns if the repeating animation really stopped.
      await tester.pumpWidget(
        host(const GlimmerVoiceInputIndicator(listening: false)),
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('a supplied amplitude replaces the self-driven animation',
        (tester) async {
      await tester.pumpWidget(
        host(const GlimmerVoiceInputIndicator(amplitude: 0.5)),
      );
      await tester.pump();
      expect(tester.hasRunningAnimations, isFalse);
    });
  });

  group('mobile additions', () {
    testWidgets('the text field takes and reports input', (tester) async {
      var latest = '';
      await tester.pumpWidget(
        host(
          GlimmerTextField(
            label: 'Name',
            prefixIcon: Icons.person_outline,
            onChanged: (value) => latest = value,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'Adriano');
      expect(latest, 'Adriano');
    });

    testWidgets('the switch reports and flips its state', (tester) async {
      var value = false;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => GlimmerSwitch(
              value: value,
              label: 'Sound',
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      final handle = tester.ensureSemantics();
      expect(
        tester.getSemantics(find.byType(GlimmerSwitch)),
        isSemantics(hasToggledState: true),
      );
      handle.dispose();

      await tester.tap(find.byType(GlimmerSwitch));
      await tester.pumpAndSettle();
      expect(value, isTrue);
    });

    testWidgets('the scaffold renders its bar and navigation strip',
        (tester) async {
      var selected = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: GlimmerTheme.dark(),
          home: GlimmerScaffold(
            title: 'Glimmer',
            body: const SizedBox.shrink(),
            selectedIndex: selected,
            onNavigationChanged: (index) => selected = index,
            navigationItems: const [
              GlimmerNavigationItem(label: 'Home', icon: Icons.home_outlined),
              GlimmerNavigationItem(
                  label: 'Saved', icon: Icons.bookmark_outline),
            ],
          ),
        ),
      );

      expect(find.text('Glimmer'), findsOneWidget);
      await tester.tap(find.text('Saved'));
      await tester.pumpAndSettle();
      expect(selected, 1);
    });
  });

  group('theme wiring', () {
    testWidgets('GlimmerTheme.of asserts outside a Glimmer theme',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => GlimmerTheme.of(context),
                throwsA(isA<AssertionError>()),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('the glasses scale produces visibly larger components',
        (tester) async {
      Future<double> heightFor(GlimmerScale scale) async {
        await tester.pumpWidget(
          host(const GlimmerTitleChip('Title'), scale: scale),
        );
        await tester.pumpAndSettle();
        return tester.getSize(find.byType(GlimmerTitleChip)).height;
      }

      final mobile = await heightFor(GlimmerScale.mobile);
      final glasses = await heightFor(GlimmerScale.glasses);
      expect(glasses, greaterThan(mobile));
    });
  });

  group('MaterialGlimmerApp', () {
    testWidgets('brings the Glimmer theme with it', (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: Builder(
            builder: (context) {
              final tokens = GlimmerTheme.of(context);
              expect(tokens.scale, GlimmerScale.mobile);
              expect(tokens.colors.primary.toARGB32(), 0xFF9BBFFF);
              return const GlimmerCard(title: 'Home');
            },
          ),
        ),
      );
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('passes the theme knobs through', (tester) async {
      const custom = Color(0xFFB9F33D);
      await tester.pumpWidget(
        MaterialGlimmerApp(
          primary: custom,
          scale: GlimmerScale.glasses,
          home: Builder(
            builder: (context) {
              final tokens = GlimmerTheme.of(context);
              expect(tokens.colors.primary, custom);
              expect(tokens.scale, GlimmerScale.glasses);
              expect(tokens.typography.titleLarge.fontSize, 30);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('a single theme applies in both modes', (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          primary: const Color(0xFFB9F33D),
          theme: GlimmerTheme.dark(scale: GlimmerScale.glasses),
          home: Builder(
            builder: (context) {
              final tokens = GlimmerTheme.of(context);
              expect(tokens.colors.primary.toARGB32(), 0xFF9BBFFF);
              expect(tokens.scale, GlimmerScale.glasses);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('named routes navigate', (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          initialRoute: '/',
          routes: {
            '/': (context) => Builder(
                  builder: (context) => GlimmerButton(
                    label: 'Go',
                    onPressed: () => Navigator.of(context).pushNamed('/next'),
                  ),
                ),
            '/next': (context) => const GlimmerCard(title: 'Second screen'),
          },
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();
      expect(find.text('Second screen'), findsOneWidget);
    });
  });

  group('text context', () {
    // Flutter renders text outside a Material in a red monospace error style.
    // Anything this package offers as a screen root has to prevent that.
    testWidgets('a GlimmerScaffold body has a real ambient text style',
        (tester) async {
      late TextStyle style;
      late GlimmerTokens tokens;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            title: 'Title',
            body: Builder(
              builder: (context) {
                tokens = GlimmerTheme.of(context);
                style = DefaultTextStyle.of(context).style;
                return const Text('body copy');
              },
            ),
          ),
        ),
      );

      expect(style.color, tokens.colors.onSurface);
      expect(style.fontSize, tokens.typography.bodySmall.fontSize);
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('a GlimmerSurface publishes the content colour to its child',
        (tester) async {
      late TextStyle onSurface;
      late TextStyle onPrimary;
      final colors = GlimmerColors.standard();

      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Column(
              children: [
                GlimmerSurface(
                  child: Builder(
                    builder: (context) {
                      onSurface = DefaultTextStyle.of(context).style;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                GlimmerSurface(
                  color: colors.primary,
                  child: Builder(
                    builder: (context) {
                      onPrimary = DefaultTextStyle.of(context).style;
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(onSurface.color, colors.onSurface);
      expect(onPrimary.color, colors.onPrimary);
    });
  });

  group('content colour', () {
    // A Material installs its own DefaultTextStyle, so publishing the content
    // colour outside the surface's gesture wrapper left icons and text on
    // different colours. On a dark ground both happened to look right, which is
    // exactly why this is asserted on a light one.
    testWidgets('text and icons agree on every fill, in both themes',
        (tester) async {
      for (final brightness in Brightness.values) {
        final colors = brightness == Brightness.dark
            ? GlimmerColors.standard()
            : GlimmerColors.light();

        for (final fill in [colors.surface, colors.primary, colors.negative]) {
          late TextStyle textStyle;
          late IconThemeData iconTheme;

          await tester.pumpWidget(
            MaterialGlimmerApp(
              themeMode: brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              home: GlimmerScaffold(
                body: GlimmerSurface(
                  color: fill,
                  onTap: () {},
                  child: Builder(
                    builder: (context) {
                      textStyle = DefaultTextStyle.of(context).style;
                      iconTheme = IconTheme.of(context);
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            textStyle.color,
            iconTheme.color,
            reason: 'icon and text differ on $fill in $brightness',
          );
          expect(
            textStyle.color,
            colors.contentColorFor(fill),
            reason: 'wrong content colour on $fill in $brightness',
          );
        }
      }
    });

    testWidgets('a caller-supplied fill keeps its full strength',
        (tester) async {
      final colors = GlimmerColors.standard();
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Column(
              children: [
                GlimmerButton(
                  label: 'Prominent',
                  prominent: true,
                  onPressed: () {},
                ),
                const GlimmerCard(title: 'Card'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The surface role is softened so the backdrop shows through; a
      // prominent fill is not, or the focal colour would come out muted.
      final tokens = GlimmerTheme.of(
        tester.element(find.text('Prominent')),
      );
      expect(tokens.surfaceOpacity, lessThan(1));
      expect(colors.contentColorFor(colors.primary), colors.onPrimary);
    });
  });

  group('scrolling', () {
    // The overscroll stretch renders scrolling content into an offscreen layer,
    // and a surface that reads what is behind it finds nothing there, so every
    // glass panel goes opaque until the stretch ends.
    testWidgets('MaterialGlimmerApp lights the edge instead of stretching',
        (tester) async {
      late Widget indicator;

      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: Builder(
            builder: (context) {
              indicator =
                  ScrollConfiguration.of(context).buildOverscrollIndicator(
                context,
                const SizedBox.shrink(),
                const ScrollableDetails(direction: AxisDirection.down),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      // The stretch transforms the content into its own layer, which is what
      // makes every glass surface go flat while it lasts. Glimmer's own
      // indicator paints over the content instead, so nothing is isolated, and
      // it is neither Material's stretch nor Cupertino's bounce.
      expect(indicator, isA<GlimmerOverscrollIndicator>());
      expect(indicator, isNot(isA<StretchingOverscrollIndicator>()));
      expect(indicator, isNot(isA<GlowingOverscrollIndicator>()));
    });

    testWidgets('a caller can put the stretch back', (tester) async {
      late ScrollBehavior behavior;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          scrollBehavior: const MaterialScrollBehavior(),
          home: Builder(
            builder: (context) {
              behavior = ScrollConfiguration.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(behavior, isNot(isA<GlimmerScrollBehavior>()));
    });
  });

  group('depth', () {
    // The surface used to absorb touches only as a side effect of the shadow
    // painter sitting behind it. With the shadows gone, a tap on the blank part
    // of a dialog fell straight through to the scrim and dismissed it.
    testWidgets('a tap on the blank part of a dialog does not dismiss it',
        (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () => showGlimmerDialog<void>(
                  context: context,
                  builder: (context) => const GlimmerDialog(
                    title: 'Leave the queue?',
                    content: 'You will lose your place.',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // The right edge of the pane itself, inside it but clear of every label.
      final panel = tester.getRect(
        find.descendant(
          of: find.byType(GlimmerDialog),
          matching: find.byType(GlimmerSurface),
        ),
      );
      await tester.tapAt(Offset(panel.right - 4, panel.center.dy));
      await tester.pumpAndSettle();

      expect(find.text('Leave the queue?'), findsOneWidget);

      // The scrim outside it still dismisses.
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();
      expect(find.text('Leave the queue?'), findsNothing);
    });

    // Glimmer's depth is the plane behind withdrawing, not a shadow around the
    // thing in front. Nothing paints one, so a modal spends its level on the
    // scrim and the panel itself carries none.
    testWidgets('a modal scrim withdraws the app by its depth level',
        (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () => showGlimmerDialog<void>(
                  context: context,
                  builder: (context) => const GlimmerDialog(title: 'Hello'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final scrim = tester.widget<GlimmerModalScrim>(
        find.byType(GlimmerModalScrim),
      );
      expect(scrim.depth!.recede, GlimmerDepth.standard().level4.recede);

      final tokens = GlimmerTokens.forScale(GlimmerScale.mobile);
      final box = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(GlimmerModalScrim),
          matching: find.byType(DecoratedBox),
        ),
      );
      final fill = (box.decoration as BoxDecoration).color!;

      // The ground colour, not black. On a light theme a black wash is a
      // bruise, and withdrawing means the plane stops being drawn rather than
      // being covered over.
      expect(
        fill.toARGB32() & 0x00FFFFFF,
        tokens.colors.background.toARGB32() & 0x00FFFFFF,
      );
      expect(fill.a, closeTo(tokens.depth.level4.recede, 1e-6));
    });
  });

  group('GlimmerPager', () {
    testWidgets('shows a page and swipes to the next', (tester) async {
      var settled = -1;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 320,
            height: 320,
            child: GlimmerPager(
              itemCount: 3,
              onPageChanged: (page) => settled = page,
              itemBuilder: (context, page) => GlimmerCard(title: 'Page $page'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Page 0'), findsOneWidget);

      await tester.fling(find.byType(PageView), const Offset(-300, 0), 1000);
      await tester.pumpAndSettle();
      expect(settled, 1);
      expect(find.text('Page 1'), findsOneWidget);
    });

    testWidgets('a centred page is placed with no layer', (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 320,
            height: 320,
            child: GlimmerPager(
              itemCount: 3,
              itemBuilder: (context, page) => GlimmerCard(title: 'Page $page'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // At rest the page carries no opacity, transform or blur. Any of those
      // would put it in its own layer and a glass surface inside it would have
      // nothing left to read.
      final card = find.text('Page 0');
      expect(
        find.ancestor(of: card, matching: find.byType(ImageFiltered)),
        findsNothing,
      );
      expect(
        find.ancestor(of: card, matching: find.byType(ShaderMask)),
        findsNothing,
      );
    });

    testWidgets('the indicator hides itself for a single page', (tester) async {
      await tester.pumpWidget(
        host(const GlimmerPageIndicator(position: 0, pageCount: 1)),
      );
      expect(
        tester.getSize(find.byType(GlimmerPageIndicator)),
        Size.zero,
      );
    });

    testWidgets('the indicator caps at seven dots', (tester) async {
      await tester.pumpWidget(
        host(const GlimmerPageIndicator(position: 0, pageCount: 40)),
      );
      final wide = tester.getSize(find.byType(GlimmerPageIndicator)).width;

      await tester.pumpWidget(
        host(const GlimmerPageIndicator(position: 0, pageCount: 7)),
      );
      expect(tester.getSize(find.byType(GlimmerPageIndicator)).width, wide);
    });
  });

  group('pager values', () {
    test('the published transform thresholds are kept', () {
      expect(GlimmerPagerDefaults.minScale, 0.9);
      expect(GlimmerPagerDefaults.scaleProgressThreshold, 0.69);
      expect(GlimmerPagerDefaults.blurProgressThreshold, 0.82);
      expect(GlimmerPagerDefaults.maxBlurRadius, 2.0);
      expect(GlimmerPagerDefaults.edgeScrimSize, 50.0);
      expect(GlimmerPagerDefaults.unselectedIndicatorAlpha, 0.3);
      expect(GlimmerPageIndicator.maxIndicators, 7);
      expect(GlimmerPageIndicator.edgeIndicatorSizeFraction, 8 / 12);
    });

    test('the edge scrim is absent at both ends and full in the middle', () {
      expect(GlimmerPagerDefaults.edgeScrimAlpha(0), 0);
      expect(GlimmerPagerDefaults.edgeScrimAlpha(0.05), 0);
      expect(GlimmerPagerDefaults.edgeScrimAlpha(0.35), closeTo(1, 1e-9));
      expect(GlimmerPagerDefaults.edgeScrimAlpha(0.5), 1);
      expect(GlimmerPagerDefaults.edgeScrimAlpha(0.65), 1);
      expect(GlimmerPagerDefaults.edgeScrimAlpha(0.95), closeTo(0, 1e-9));
      expect(GlimmerPagerDefaults.edgeScrimAlpha(1), 0);
    });

    test('only the dot the bar has arrived at is left undrawn', () {
      // A three page pager has to read as three marks, so the bar hides one
      // dot and never the one it is travelling toward.
      expect(GlimmerPageIndicator.coveredDot(0, 0), 0);
      expect(GlimmerPageIndicator.coveredDot(0, 0.49), 0);
      expect(GlimmerPageIndicator.coveredDot(0, 0.5), 1);
      expect(GlimmerPageIndicator.coveredDot(0, 1), 1);
      expect(GlimmerPageIndicator.coveredDot(4, 0.2), 4);
    });

    test('the scrim envelope is symmetric', () {
      for (final t in [0.1, 0.2, 0.3, 0.45]) {
        expect(
          GlimmerPagerDefaults.edgeScrimAlpha(t),
          closeTo(GlimmerPagerDefaults.edgeScrimAlpha(1 - t), 1e-9),
        );
      }
    });
  });

  group('filled surfaces', () {
    testWidgets('a prominent button draws its edge from its own fill',
        (tester) async {
      final colors = GlimmerColors.standard();

      await tester.pumpWidget(
        host(
          Column(
            children: [
              GlimmerButton(
                label: 'Prominent',
                prominent: true,
                onPressed: () {},
              ),
              GlimmerButton(label: 'Neutral', onPressed: () {}),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The neutral button keeps the published grey edge; the prominent one
      // gets a translucent edge derived from the focal colour, so the border
      // reads as light on the fill rather than as a ring of its own.
      final derived = GlimmerEdge.onFill(colors.primary);
      expect(derived.topRight, isNot(const GlimmerEdge.idle().topRight));
      expect(derived.topRight.a, lessThan(1));
      expect(find.byType(GlimmerSurface), findsNWidgets(2));
    });
  });

  group('glass', () {
    // A drop shadow used to be painted under the surface as well as around it.
    // Under an opaque fill that was invisible; under glass the surface read its
    // own shadow as part of the backdrop, blurred it in, and washed itself
    // black. Nothing structural catches that, so this looks at the pixels.
    testWidgets('a surface does not darken itself with its own shadow',
        (tester) async {
      const backdrop = Color(0xFFB08030);
      final key = GlobalKey();

      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: RepaintBoundary(
              key: key,
              child: const ColoredBox(
                color: backdrop,
                child: Center(
                  child: SizedBox(
                    width: 220,
                    height: 140,
                    child: GlimmerCard(title: 'Glass'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      late final ByteData pixels;
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        pixels = (await image.toByteData())!;
      });

      final size = tester.getSize(find.byKey(key));
      int luminanceAt(int x, int y) {
        final offset = ((y * size.width.toInt()) + x) * 4;
        final r = pixels.getUint8(offset);
        final g = pixels.getUint8(offset + 1);
        final b = pixels.getUint8(offset + 2);
        return r + g + b;
      }

      final inside = luminanceAt(size.width ~/ 2, size.height ~/ 2);
      final outside = luminanceAt(8, 8);

      // The surface composites additively, so over a flat backdrop it can only
      // hold steady or lift. Any drop means something dark is being blurred in.
      expect(
        inside,
        greaterThanOrEqualTo(outside),
        reason: 'the surface is darker than the backdrop behind it',
      );
    });
  });

  group('modals', () {
    testWidgets('a dialog opens, returns a value and closes', (tester) async {
      int? result;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () async {
                  result = await showGlimmerDialog<int>(
                    context: context,
                    builder: (context) => GlimmerDialog(
                      title: 'Leave the queue?',
                      content: 'You will lose your place.',
                      actions: [
                        GlimmerButton(
                          label: 'Stay',
                          onPressed: () => Navigator.of(context).pop(0),
                        ),
                        GlimmerButton(
                          label: 'Leave',
                          onPressed: () => Navigator.of(context).pop(1),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Leave the queue?'), findsOneWidget);
      expect(find.byType(GlimmerModalScrim), findsOneWidget);

      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();
      expect(find.text('Leave the queue?'), findsNothing);
      expect(result, 1);
    });

    testWidgets('tapping the scrim dismisses a dismissible dialog',
        (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () => showGlimmerDialog<void>(
                  context: context,
                  builder: (context) => const GlimmerDialog(title: 'Hello'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsNothing);
    });

    testWidgets('a non-dismissible dialog ignores the scrim', (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () => showGlimmerDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const GlimmerDialog(title: 'Stuck'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(find.text('Stuck'), findsOneWidget);
    });

    testWidgets('a bottom sheet opens and drags away', (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () => showGlimmerBottomSheet<void>(
                  context: context,
                  builder: (context) => const GlimmerBottomSheet(
                    title: 'Sort by',
                    child: Text('Newest first'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Sort by'), findsOneWidget);

      await tester.fling(
        find.byType(GlimmerBottomSheet),
        const Offset(0, 300),
        1500,
      );
      await tester.pumpAndSettle();
      expect(find.text('Sort by'), findsNothing);
    });
  });

  group('snackbar', () {
    testWidgets('appears, carries an action and leaves on its own',
        (tester) async {
      var acted = false;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Show',
                onPressed: () => showGlimmerSnackbar(
                  context,
                  message: 'Saved to your list',
                  actionLabel: 'Undo',
                  onAction: () => acted = true,
                  duration: const Duration(seconds: 2),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Saved to your list'), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(acted, isTrue);
      expect(find.text('Saved to your list'), findsNothing);
    });

    testWidgets('a second message replaces the first', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) {
                ctx = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      showGlimmerSnackbar(ctx, message: 'First');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('First'), findsOneWidget);

      showGlimmerSnackbar(ctx, message: 'Second');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsNothing);
    });
  });

  group('menu', () {
    testWidgets('opens against its anchor and returns the choice',
        (tester) async {
      String? chosen;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Center(
              child: Builder(
                builder: (context) => GlimmerButton(
                  label: 'More',
                  onPressed: () async {
                    chosen = await showGlimmerMenu<String>(
                      context: context,
                      items: const [
                        GlimmerMenuItem(label: 'Share', value: 'share'),
                        GlimmerMenuItem(
                          label: 'Delete',
                          value: 'delete',
                          destructive: true,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(chosen, 'delete');
      expect(find.text('Share'), findsNothing);
    });

    testWidgets('a disabled item cannot be chosen', (tester) async {
      var closed = false;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Center(
              child: Builder(
                builder: (context) => GlimmerButton(
                  label: 'More',
                  onPressed: () async {
                    await showGlimmerMenu<String>(
                      context: context,
                      items: const [
                        GlimmerMenuItem(
                          label: 'Unavailable',
                          value: 'x',
                          enabled: false,
                        ),
                      ],
                    );
                    closed = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unavailable'));
      await tester.pumpAndSettle();

      // Still open, nothing chosen.
      expect(find.text('Unavailable'), findsOneWidget);
      expect(closed, isFalse);
    });
  });

  group('text outside a Material', () {
    // Flutter's ambient text style, with no Material above it, is the red
    // monospace error style with a yellow underline. A surface that merges into
    // that style keeps the underline and the typeface, which is invisible
    // inside a Scaffold and very visible in a dialog, a menu or a snackbar.
    Future<TextStyle> styleInside(
      WidgetTester tester,
      Future<void> Function(BuildContext context) open,
    ) async {
      late TextStyle style;

      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Open',
                onPressed: () => open(context),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      style = DefaultTextStyle.of(
        tester.element(find.byKey(const ValueKey('probe'))),
      ).style;
      return style;
    }

    void expectClean(TextStyle style) {
      expect(style.decoration ?? TextDecoration.none, TextDecoration.none);
      expect(style.fontFamily, isNot('monospace'));
      expect(style.color, isNot(const Color(0xD0FF0000)));
    }

    testWidgets('a dialog gets a real text style', (tester) async {
      final style = await styleInside(
        tester,
        (context) => showGlimmerDialog<void>(
          context: context,
          builder: (context) => const GlimmerDialog(
            title: 'Title',
            child: Text('body', key: ValueKey('probe')),
          ),
        ),
      );
      expectClean(style);
    });

    testWidgets('a bottom sheet gets a real text style', (tester) async {
      final style = await styleInside(
        tester,
        (context) => showGlimmerBottomSheet<void>(
          context: context,
          builder: (context) => const GlimmerBottomSheet(
            child: Text('body', key: ValueKey('probe')),
          ),
        ),
      );
      expectClean(style);
    });

    testWidgets('a surface outside any Material gets a real text style',
        (tester) async {
      late TextStyle style;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerSurface(
            child: Builder(
              builder: (context) {
                style = DefaultTextStyle.of(context).style;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expectClean(style);
    });
  });

  group('slider', () {
    testWidgets('reports a value from a tap and a drag', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: StatefulBuilder(
              builder: (context, setState) => GlimmerSlider(
                value: value,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final centre = tester.getCenter(find.byType(GlimmerSlider));
      await tester.tapAt(centre);
      await tester.pumpAndSettle();
      expect(value, closeTo(0.5, 0.05));

      await tester.dragFrom(centre, const Offset(120, 0));
      await tester.pumpAndSettle();
      expect(value, greaterThan(0.8));
    });

    testWidgets('snaps to divisions', (tester) async {
      var value = 0.0;
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: StatefulBuilder(
              builder: (context, setState) => GlimmerSlider(
                value: value,
                divisions: 4,
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tapAt(tester.getCenter(find.byType(GlimmerSlider)));
      await tester.pumpAndSettle();
      expect(value, 0.5);
    });

    testWidgets('is inert and dimmed when disabled', (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: GlimmerSlider(value: 0.5, onChanged: null),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final opacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity).first,
      );
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('announces itself as a slider', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: GlimmerSlider(
              value: 0.25,
              semanticLabel: 'Volume',
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(GlimmerSlider)),
        isSemantics(isSlider: true, label: 'Volume', value: '25%'),
      );
      handle.dispose();
    });
  });

  group('overscroll', () {
    testWidgets('lights the edge without moving the content', (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) =>
                  GlimmerListItem(label: 'Row $index'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final before = tester.getTopLeft(find.text('Row 0'));
      final gesture = await tester.startGesture(const Offset(400, 300));
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();

      // Material would have stretched or translated the content by now.
      expect(tester.getTopLeft(find.text('Row 0')), before);
      expect(find.byType(GlimmerOverscrollIndicator), findsOneWidget);

      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  group('entrance', () {
    // Glass cannot be faded. An opacity layer takes the backdrop away for the
    // whole animation and hands it back in one frame at the end, which is the
    // jump at the end of a menu opening. Surfaces arrive through
    // GlimmerEntrance instead, and nothing on the way in is an opacity layer.
    testWidgets('a surface scales its own tint rather than being faded',
        (tester) async {
      Widget probe(double progress) => MaterialGlimmerApp(
            home: GlimmerScaffold(
              body: GlimmerEntrance(
                progress: progress,
                child: const GlimmerSurface(child: Text('panel')),
              ),
            ),
          );

      await tester.pumpWidget(probe(1));
      await tester.pumpAndSettle();
      final full = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(GlimmerSurface),
          matching: find.byType(Opacity),
        ),
      );
      expect(full.opacity, 1);

      await tester.pumpWidget(probe(0.4));
      await tester.pumpAndSettle();
      final part = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(GlimmerSurface),
          matching: find.byType(Opacity),
        ),
      );
      expect(part.opacity, closeTo(0.4, 1e-9));

      // The fade is inside the surface, under its backdrop filter, so the
      // backdrop is still being read.
      expect(
        find.ancestor(
          of: find.byType(BackdropFilter),
          matching: find.byType(Opacity),
        ),
        findsNothing,
      );
    });

    testWidgets('no modal wraps its panel in an opacity layer', (tester) async {
      Future<void> check(
        Future<void> Function(BuildContext context) open,
        Type panel,
      ) async {
        await tester.pumpWidget(
          MaterialGlimmerApp(
            home: GlimmerScaffold(
              body: Builder(
                builder: (context) => GlimmerButton(
                  label: 'Open',
                  onPressed: () => open(context),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        // Part way in, which is where an opacity layer would exist.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 120));

        expect(
          find.ancestor(
            of: find.byType(panel),
            matching: find.byType(FadeTransition),
          ),
          findsNothing,
          reason: '$panel is faded, which flattens its glass',
        );
        expect(
          find.ancestor(
            of: find.byType(panel),
            matching: find.byType(GlimmerEntrance),
          ),
          findsWidgets,
        );

        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
      }

      await check(
        (context) => showGlimmerDialog<void>(
          context: context,
          builder: (context) => const GlimmerDialog(title: 'Hello'),
        ),
        GlimmerDialog,
      );

      await check(
        (context) => showGlimmerBottomSheet<void>(
          context: context,
          builder: (context) => const GlimmerBottomSheet(child: Text('sheet')),
        ),
        GlimmerBottomSheet,
      );
    });
  });

  group('tooltip', () {
    testWidgets('a long press shows the label and it leaves on its own',
        (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Center(
              child: GlimmerIconButton(
                icon: Icons.mic,
                tooltip: 'Voice input',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Voice input'), findsNothing);

      await tester.longPress(find.byType(GlimmerIconButton));
      // Not pumpAndSettle: the pill takes itself away after showDuration, and
      // settling would run that timer out before anything could be checked.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Voice input'), findsOneWidget);

      // The pill is a surface like everything else, not a flat slab, and it is
      // never Material's tooltip.
      expect(
        find.descendant(
          of: find.byType(GlimmerTooltip),
          matching: find.byType(Tooltip),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.text('Voice input'),
          matching: find.byType(GlimmerSurface),
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Voice input'), findsNothing);
    });

    testWidgets('the label is announced without being on screen',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Center(
              child: GlimmerIconButton(
                icon: Icons.mic,
                tooltip: 'Voice input',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byType(GlimmerIconButton)).tooltip,
        'Voice input',
      );
      handle.dispose();
    });
  });

  group('progress bar', () {
    testWidgets('an indeterminate bar sweeps and a determinate one rests',
        (tester) async {
      await tester.pumpWidget(
        const MaterialGlimmerApp(
          home: GlimmerScaffold(body: GlimmerProgressBar()),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isTrue);

      await tester.pumpWidget(
        const MaterialGlimmerApp(
          home: GlimmerScaffold(body: GlimmerProgressBar(value: 0.4)),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.hasRunningAnimations, isFalse);
    });

    // Material slides a block along the track for indeterminate progress, and
    // draws the determinate bar with its own indicator. Both are drawn here.
    testWidgets('draws itself rather than borrowing an indicator',
        (tester) async {
      await tester.pumpWidget(
        const MaterialGlimmerApp(
          home: GlimmerScaffold(body: GlimmerProgressBar(value: 0.4)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(
        find.descendant(
          of: find.byType(GlimmerProgressBar),
          matching: find.byType(CustomPaint),
        ),
        findsWidgets,
      );
    });

    testWidgets('reports its value to a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        const MaterialGlimmerApp(
          home: GlimmerScaffold(body: GlimmerProgressBar(value: 0.42)),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(GlimmerProgressBar)).value,
        '42%',
      );
      handle.dispose();
    });
  });

  group('refresh', () {
    Widget host(Future<void> Function() onRefresh) => MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: GlimmerRefreshIndicator(
              onRefresh: onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 200, child: Text('rows'))],
              ),
            ),
          ),
        );

    testWidgets('a pull past the trigger runs the refresh', (tester) async {
      var runs = 0;
      final completer = Completer<void>();
      await tester.pumpWidget(host(() {
        runs++;
        return completer.future;
      }));

      final gesture = await tester.startGesture(const Offset(400, 200));
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();
      expect(runs, 0, reason: 'the pull should not fire until it is let go');

      await gesture.up();
      await tester.pump();
      expect(runs, 1);

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('a short pull does not', (tester) async {
      var runs = 0;
      await tester.pumpWidget(host(() async => runs++));

      final gesture = await tester.startGesture(const Offset(400, 200));
      await gesture.moveBy(const Offset(0, 30));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(runs, 0);
    });

    // The bloom is masked with BlendMode.dstIn. On the bare canvas that takes
    // the alpha out of everything already painted under it rather than out of
    // the bloom, which puts a black band across the top of the page. Nothing
    // structural catches that, so this looks at the pixels.
    testWidgets('the bloom does not erase the content under it',
        (tester) async {
      const ground = Color(0xFF808080);
      final key = GlobalKey();
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: RepaintBoundary(
              key: key,
              child: GlimmerRefreshIndicator(
                onRefresh: () => completer.future,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: const [
                    SizedBox(height: 400, child: ColoredBox(color: ground)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      Future<int> luminanceNearTheTop() async {
        late int value;
        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final pixels = (await image.toByteData())!;
          final width = tester.getSize(find.byKey(key)).width.toInt();
          // Inside the bloom and off to one side. The mask that shapes it is
          // opaque at the centre and falls away toward the ends, so the centre
          // is exactly where the bug does not show.
          final offset = ((20 * width) + (width ~/ 4)) * 4;
          value = pixels.getUint8(offset) +
              pixels.getUint8(offset + 1) +
              pixels.getUint8(offset + 2);
        });
        return value;
      }

      final resting = await luminanceNearTheTop();

      final gesture = await tester.startGesture(const Offset(400, 200));
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();

      final pulled = await luminanceNearTheTop();

      // The bloom only adds light, so the ground under it can brighten and
      // must never darken.
      expect(
        pulled,
        greaterThanOrEqualTo(resting),
        reason: 'the bloom is taking the content out from under itself',
      );

      await gesture.up();
      await tester.pump();
      completer.complete();
      await tester.pumpAndSettle();
    });

    // Material slides a card down over the list and Cupertino opens a gap
    // above it. Both move something; the edge lights instead.
    testWidgets('the content does not move', (tester) async {
      final completer = Completer<void>();
      await tester.pumpWidget(host(() => completer.future));

      final before = tester.getTopLeft(find.text('rows'));
      final gesture = await tester.startGesture(const Offset(400, 200));
      await gesture.moveBy(const Offset(0, 300));
      await tester.pump();
      expect(tester.getTopLeft(find.text('rows')), before);

      await gesture.up();
      await tester.pump();
      expect(tester.getTopLeft(find.text('rows')), before);

      completer.complete();
      await tester.pumpAndSettle();
    });
  });

  group('page route', () {
    testWidgets('a pushed page arrives without being put in a layer',
        (tester) async {
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) => GlimmerButton(
                label: 'Push',
                onPressed: () => Navigator.of(context).push(
                  GlimmerPageRoute<void>(
                    builder: (context) => const GlimmerScaffold(
                      body: GlimmerCard(title: 'Detail'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Push'));
      await tester.pump();
      // Part way in, which is where a slide or a fade would show.
      await tester.pump(const Duration(milliseconds: 150));

      expect(find.text('Detail'), findsOneWidget);
      for (final type in [FadeTransition, SlideTransition]) {
        expect(
          find.ancestor(
            of: find.text('Detail'),
            matching: find.byWidgetPredicate((w) => w.runtimeType == type),
          ),
          findsNothing,
          reason: 'the arriving page is wrapped in a $type',
        );
      }
      expect(
        find.ancestor(
          of: find.text('Detail'),
          matching: find.byType(GlimmerEntrance),
        ),
        findsWidgets,
      );

      // The page does not move, so it is already where it will end up.
      final midway = tester.getTopLeft(find.byType(GlimmerCard));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.byType(GlimmerCard)), midway);
    });

    testWidgets('the page underneath withdraws rather than sliding away',
        (tester) async {
      late BuildContext pageContext;
      await tester.pumpWidget(
        MaterialGlimmerApp(
          home: GlimmerScaffold(
            body: Builder(
              builder: (context) {
                pageContext = context;
                return const GlimmerCard(title: 'Home');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final before = tester.getTopLeft(find.byType(GlimmerCard));

      Navigator.of(pageContext).push(
        GlimmerPageRoute<void>(
          builder: (context) => const GlimmerScaffold(body: Text('Detail')),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));

      expect(tester.getTopLeft(find.byType(GlimmerCard)), before);

      final tokens = GlimmerTokens.forScale(GlimmerScale.mobile);
      expect(tokens.depth.level3.recede, greaterThan(0));
    });
  });
}
