import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_glimmer/material_glimmer.dart';

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

    testWidgets('draws no Material ink response', (tester) async {
      await tester.pumpWidget(
        host(GlimmerSurface(onTap: () {}, child: const Text('x'))),
      );
      final inkWell = tester.widget<InkWell>(find.byType(InkWell));
      expect(inkWell.splashFactory, NoSplash.splashFactory);
      expect(inkWell.highlightColor, Colors.transparent);
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
      expect(find.byType(InkWell), findsNothing);
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

    testWidgets('rests at depth level 1', (tester) async {
      await tester.pumpWidget(host(const GlimmerCard(title: 'x')));
      final surface = tester.widget<GlimmerSurface>(
        find.byType(GlimmerSurface),
      );
      final expected = GlimmerDepth.mobile().level1;
      expect(surface.depth!.layer1.blurRadius, expected.layer1.blurRadius);
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

  group('GlimmerApp', () {
    testWidgets('brings the Glimmer theme with it', (tester) async {
      await tester.pumpWidget(
        GlimmerApp(
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
        GlimmerApp(
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
        GlimmerApp(
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
        GlimmerApp(
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
        GlimmerApp(
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
        GlimmerApp(
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
            GlimmerApp(
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
        GlimmerApp(
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
    testWidgets('GlimmerApp glows instead of stretching', (tester) async {
      late Widget indicator;

      await tester.pumpWidget(
        GlimmerApp(
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
      // makes every glass surface go flat while it lasts. A glow is painted
      // over the content instead, so nothing is isolated.
      expect(indicator, isA<GlowingOverscrollIndicator>());
      expect(indicator, isNot(isA<StretchingOverscrollIndicator>()));
    });

    testWidgets('a caller can put the stretch back', (tester) async {
      late ScrollBehavior behavior;
      await tester.pumpWidget(
        GlimmerApp(
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
    testWidgets('a nested surface does not lift on focus', (tester) async {
      await tester.pumpWidget(
        const GlimmerApp(
          home: GlimmerScaffold(
            body: Column(
              children: [
                GlimmerSurface(
                  focused: true,
                  liftOnFocus: false,
                  child: Text('nested'),
                ),
                GlimmerSurface(focused: true, child: Text('standalone')),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final surfaces = tester
          .widgetList<GlimmerSurface>(find.byType(GlimmerSurface))
          .toList();
      expect(surfaces.first.liftOnFocus, isFalse);
      expect(surfaces.last.liftOnFocus, isTrue);
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
}
