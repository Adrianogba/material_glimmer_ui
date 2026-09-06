import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_glimmer_ui/material_glimmer_ui.dart';

/// These tests pin the values this package claims to take from Jetpack Compose
/// Glimmer. If upstream changes, they should fail and the README's fidelity
/// table should change with them.
void main() {
  group('colours', () {
    test('match the published Glimmer palette', () {
      final colors = GlimmerColors.standard();
      expect(colors.primary.toARGB32(), 0xFF9BBFFF);
      expect(colors.secondary.toARGB32(), 0xFF4C88E9);
      expect(colors.positive.toARGB32(), 0xFF63FEA8);
      expect(colors.negative.toARGB32(), 0xFFFFA7A0);
      expect(colors.surface.toARGB32(), 0xFF303030);
      expect(colors.outline.toARGB32(), 0xFF606460);
      expect(colors.background.toARGB32(), 0xFF000000);
    });

    test('content colour follows the published luminance breakpoint', () {
      final colors = GlimmerColors.standard();
      expect(GlimmerColors.contentColorLuminanceBreakpoint, 0.179129);
      expect(colors.contentColorFor(colors.primary), colors.onPrimary);
      expect(colors.contentColorFor(colors.secondary), colors.onPrimary);
      expect(colors.contentColorFor(colors.positive), colors.onPrimary);
      expect(colors.contentColorFor(colors.negative), colors.onPrimary);
      expect(colors.contentColorFor(colors.surface), colors.onSurface);
      expect(colors.contentColorFor(colors.background), colors.onSurface);
    });

    test('content colour works for a colour outside the palette', () {
      final colors = GlimmerColors.standard();
      expect(colors.contentColorFor(const Color(0xFFFFE082)), colors.onPrimary);
      expect(colors.contentColorFor(const Color(0xFF102030)), colors.onSurface);
    });

    test('content colour stays readable on a light ground', () {
      final light = GlimmerColors.light();
      // The light palette's onPrimary is white, so picking by role would put
      // white text on a white surface.
      expect(light.contentColorFor(light.surface), light.onSurface);
      expect(light.contentColorFor(light.background), light.onSurface);
      expect(light.contentColorFor(light.primary), light.onPrimary);
      expect(light.contentColorFor(const Color(0xFFFFFFFF)), light.onSurface);
    });

    test('every palette contrasts its own surface and focal colours', () {
      for (final colors in [GlimmerColors.standard(), GlimmerColors.light()]) {
        for (final background in [
          colors.surface,
          colors.background,
          colors.primary,
          colors.secondary,
          colors.positive,
          colors.negative,
        ]) {
          final foreground = colors.contentColorFor(background);
          final a = foreground.computeLuminance() + 0.05;
          final b = background.computeLuminance() + 0.05;
          final ratio = a > b ? a / b : b / a;
          expect(
            ratio,
            greaterThan(4.5),
            reason: 'foreground on $background',
          );
        }
      }
    });

    test('primary can be re-skinned without losing the other roles', () {
      const custom = Color(0xFFB9F33D);
      final colors = GlimmerColors.standard(primary: custom);
      expect(colors.primary, custom);
      expect(colors.secondary.toARGB32(), 0xFF4C88E9);
    });
  });

  group('typography', () {
    test('glasses sizes are the published ones', () {
      final type = GlimmerTypography.glasses();
      expect(type.titleLarge.fontSize, 30);
      expect(type.titleMedium.fontSize, 24);
      expect(type.titleSmall.fontSize, 20);
      expect(type.bodyLarge.fontSize, 30);
      expect(type.bodyMedium.fontSize, 24);
      expect(type.bodySmall.fontSize, 20);
      expect(type.caption.fontSize, 18);
    });

    test('glasses weights are the published axis values, quantised', () {
      final type = GlimmerTypography.glasses();
      // 725 -> w700, 520 -> w500, 650 -> w600.
      expect(type.titleLarge.fontWeight, FontWeight.w700);
      expect(type.bodyLarge.fontWeight, FontWeight.w500);
      expect(type.caption.fontWeight, FontWeight.w600);
    });

    test('mobile is exactly two thirds of glasses', () {
      final glasses = GlimmerTypography.glasses();
      final mobile = GlimmerTypography.mobile();
      expect(mobile.titleLarge.fontSize, glasses.titleLarge.fontSize! * 2 / 3);
      expect(mobile.caption.fontSize, glasses.caption.fontSize! * 2 / 3);
    });

    test('mobile keeps the glasses line-height ratios and weights', () {
      final glasses = GlimmerTypography.glasses();
      final mobile = GlimmerTypography.mobile();
      expect(mobile.titleLarge.height, glasses.titleLarge.height);
      expect(mobile.bodyMedium.height, glasses.bodyMedium.height);
      expect(mobile.titleMedium.fontWeight, glasses.titleMedium.fontWeight);
      // titleLarge is 30/36 upstream.
      expect(glasses.titleLarge.height, 36 / 30);
    });
  });

  group('shapes, spacing and icon sizes', () {
    test('glasses radii are the published ones', () {
      final shapes = GlimmerShapes.glasses();
      expect(shapes.small.topLeft.x, 12);
      expect(shapes.medium.topLeft.x, 36);
    });

    test('mobile radii are two thirds', () {
      expect(GlimmerShapes.mobile().medium.topLeft.x, 24);
      expect(GlimmerShapes.mobile().small.topLeft.x, 8);
    });

    test('spacing is unscaled on both scales', () {
      const spacing = GlimmerSpacing.standard();
      expect(
        [
          spacing.extraSmall,
          spacing.small,
          spacing.medium,
          spacing.large,
          spacing.extraLarge,
        ],
        [6, 8, 12, 16, 20],
      );
      final mobile = GlimmerTokens.forScale(GlimmerScale.mobile);
      final glasses = GlimmerTokens.forScale(GlimmerScale.glasses);
      expect(mobile.spacing.extraLarge, glasses.spacing.extraLarge);
    });

    test('icon sizes are the published ones, scaled for mobile', () {
      const glasses = GlimmerIconSizes.glasses();
      expect([glasses.small, glasses.medium, glasses.large], [32, 40, 48]);
      expect(const GlimmerIconSizes.mobile().large, 32);
    });
  });

  group('depth', () {
    test('the levels keep the ratios of the published spreads', () {
      final depth = GlimmerDepth.standard(maxRecede: 1);
      const spreads = [6.0, 13.0, 19.0, 26.0, 32.0];
      for (var i = 1; i <= 5; i++) {
        expect(depth[i].recede, closeTo(spreads[i - 1] / 32, 1e-9));
      }
    });

    test('the front-most level recedes by maxRecede', () {
      expect(GlimmerDepth.standard().level5.recede, closeTo(0.6, 1e-9));
      expect(
        GlimmerDepth.standard(maxRecede: 0.4).level5.recede,
        closeTo(0.4, 1e-9),
      );
    });

    test('levels grow monotonically', () {
      final depth = GlimmerDepth.standard();
      var previous = 0.0;
      for (var i = 1; i <= 5; i++) {
        expect(depth[i].recede, greaterThan(previous));
        previous = depth[i].recede;
      }
    });

    test('indexing outside 1 to 5 throws', () {
      expect(() => GlimmerDepth.standard()[0], throwsRangeError);
      expect(() => GlimmerDepth.standard()[6], throwsRangeError);
    });

    test('lerping from no level starts flat', () {
      final level = GlimmerDepth.standard().level2;
      expect(GlimmerDepthLevel.lerp(null, level, 0), 0);
      expect(GlimmerDepthLevel.lerp(null, level, 1), level.recede);
      expect(
        GlimmerDepthLevel.lerp(null, level, 0.5),
        closeTo(level.recede / 2, 1e-9),
      );
    });

    // Glimmer draws its depth as two black shadows, which only works where
    // black is transparent. On an opaque screen the same shadows are a dark
    // halo, which is Material's language, so nothing is painted around a
    // surface at all.
    test('a depth level is a withdrawal rather than a shadow', () {
      expect(const GlimmerDepthLevel(0.5).recede, 0.5);
      expect(() => GlimmerDepthLevel(1.4), throwsAssertionError);
    });
  });

  group('motion', () {
    test('timing matches the Glimmer surface implementation', () {
      expect(
          GlimmerMotion.focusEnterDuration, const Duration(milliseconds: 800));
      expect(
          GlimmerMotion.focusExitDuration, const Duration(milliseconds: 500));
      expect(
        GlimmerMotion.minimumPressDuration,
        const Duration(milliseconds: 300),
      );
      expect(GlimmerMotion.ambientPulseDuration, const Duration(seconds: 2));
      expect(
        GlimmerMotion.ambientInitialDelay,
        const Duration(milliseconds: 1800),
      );
      expect(GlimmerMotion.ambientRepeatDelay, const Duration(seconds: 4));
      expect(GlimmerMotion.pressedOverlayOpacity, 0.16);
      expect(GlimmerMotion.borderWidth, 1.5);
      expect(GlimmerMotion.focusedBorderWidth, 2.0);
    });

    test('the ambient envelope ramps in, peaks at 0.375 and tapers to zero',
        () {
      expect(GlimmerMotion.ambientEnvelope(0), 0);
      expect(GlimmerMotion.ambientEnvelope(0.2835), closeTo(1, 1e-9));
      expect(GlimmerMotion.ambientEnvelope(0.3), 1);
      expect(GlimmerMotion.ambientEnvelope(0.375), closeTo(1, 1e-9));
      expect(GlimmerMotion.ambientEnvelope(0.7), lessThan(1));
      expect(GlimmerMotion.ambientEnvelope(1), closeTo(0, 1e-9));
    });
  });

  group('theme', () {
    test('exposes the tokens as a ThemeExtension', () {
      final theme = GlimmerTheme.dark();
      final tokens = theme.extension<GlimmerTokens>();
      expect(tokens, isNotNull);
      expect(tokens!.scale, GlimmerScale.mobile);
      expect(theme.scaffoldBackgroundColor.toARGB32(), 0xFF000000);
    });

    test('the Material colour scheme is derived from the Glimmer roles', () {
      final theme = GlimmerTheme.dark();
      final colors = theme.extension<GlimmerTokens>()!.colors;
      expect(theme.colorScheme.primary, colors.primary);
      expect(theme.colorScheme.error, colors.negative);
      expect(theme.colorScheme.outline, colors.outline);
    });

    test('the Material text theme is derived from the Glimmer type scale', () {
      final theme = GlimmerTheme.dark();
      final type = theme.extension<GlimmerTokens>()!.typography;
      expect(theme.textTheme.titleMedium!.fontSize, type.titleMedium.fontSize);
      expect(theme.textTheme.bodyMedium!.fontSize, type.bodyMedium.fontSize);
    });

    test('the glasses scale opts out of every mobile adjustment', () {
      final tokens = GlimmerTheme.dark(scale: GlimmerScale.glasses)
          .extension<GlimmerTokens>()!;
      expect(tokens.typography.titleLarge.fontSize, 30);
      expect(tokens.shapes.medium.topLeft.x, 36);
      expect(tokens.iconSizes.large, 48);
      expect(tokens.depth.level5.recede, closeTo(0.6, 1e-9));
    });

    test('tokens lerp across every scale', () {
      final a = GlimmerTokens.forScale(GlimmerScale.mobile);
      final b = GlimmerTokens.forScale(
        GlimmerScale.glasses,
        primary: const Color(0xFFB9F33D),
      );
      final mid = a.lerp(b, 0.5);
      expect(mid.typography.titleLarge.fontSize, closeTo(25, 1e-9));
      expect(mid.shapes.medium.topLeft.x, closeTo(30, 1e-9));
      expect(mid.colors.primary, isNot(a.colors.primary));
    });
  });

  group('tone', () {
    // Glimmer states its surface and border colours as tones, so the tone maths
    // has to agree with the published values it produces.
    test('the published surface colours land on their stated tones', () {
      expect(const Color(0xFF303030).tone, closeTo(20, 0.5));
      expect(const Color(0xFF000000).tone, 0);
      expect(const Color(0xFFFFFFFF).tone, closeTo(100, 0.01));
    });

    test('withTone moves lightness and keeps alpha', () {
      final lifted = const Color(0xFF303030).withTone(34);
      expect(lifted.tone, closeTo(34, 0.5));
      expect(lifted.a, 1);
      expect(
        lifted.computeLuminance(),
        greaterThan(const Color(0xFF303030).computeLuminance()),
      );
    });

    test('withTone keeps the hue of a chromatic colour', () {
      const focal = Color(0xFF9BBFFF);
      final lighter = focal.withTone(85);
      expect(lighter.b, greaterThan(lighter.r));
      expect(lighter.tone, closeTo(85, 1));
    });

    test('the focused edge is derived from the focal colour', () {
      const focal = Color(0xFF9BBFFF);
      final edge = GlimmerEdge.focused(focal);
      expect(edge.topLeft.toARGB32(), 0xFFFFFFFF);
      expect(edge.topRight.tone, closeTo(85, 1));
      expect(edge.bottomRight.tone, closeTo(69, 1));
      expect(edge.bottomLeft.tone, closeTo(77, 1));
    });
  });

  group('edge', () {
    test('the resting corners are the published values', () {
      const edge = GlimmerEdge.idle();
      expect(edge.topLeft.toARGB32(), 0xE6CFCFCF);
      expect(edge.topRight.toARGB32(), 0x80404040);
      expect(edge.bottomRight.toARGB32(), 0x66292929);
      expect(edge.bottomLeft.toARGB32(), 0xB37D7D7D);
    });

    test('the gradient is symmetric about the lit corner', () {
      const edge = GlimmerEdge.idle();
      for (final d in [0.05, 0.15, 0.3, 0.45]) {
        final clockwise = edge.colorAt(d);
        final anticlockwise = edge.colorAt(1 - d);
        expect(clockwise.r, closeTo(anticlockwise.r, 0.005));
        expect(clockwise.g, closeTo(anticlockwise.g, 0.005));
        expect(clockwise.b, closeTo(anticlockwise.b, 0.005));
        expect(clockwise.a, closeTo(anticlockwise.a, 0.005));
      }
    });

    test('the lit corner is the brightest point', () {
      const edge = GlimmerEdge.idle();
      final lit = edge.colorAt(0).computeLuminance();
      for (final d in [0.15, 0.25, 0.35, 0.5]) {
        expect(edge.colorAt(d).computeLuminance(), lessThan(lit));
      }
    });

    test('an edge on a fill is derived from it and stays translucent', () {
      const fill = Color(0xFF9BBFFF);
      final edge = GlimmerEdge.onFill(fill);

      // The lit corner is a white highlight; the rest are the fill's own tone
      // moved up and down. Every stop is translucent so the fill is still the
      // colour you see, rather than a grey ring drawn around it.
      expect(edge.topLeft.toARGB32() & 0x00FFFFFF, 0x00FFFFFF);
      for (final corner in edge.corners) {
        expect(corner.a, lessThan(0.6), reason: 'edge stop is too solid');
      }
      expect(edge.topRight.tone, greaterThan(fill.tone));
      expect(edge.bottomRight.tone, lessThan(fill.tone));
      expect(edge.bottomLeft.tone, lessThan(fill.tone));
    });

    test('an edge on a fill keeps the fill hue', () {
      const fill = Color(0xFF63FEA8);
      final edge = GlimmerEdge.onFill(fill);
      // Green in, green out: the lift and the drop move lightness, not hue.
      expect(edge.topRight.g, greaterThan(edge.topRight.r));
      expect(edge.bottomRight.g, greaterThan(edge.bottomRight.r));
    });

    test('blur sharpens on focus and blooms on the ambient sweep', () {
      expect(GlimmerEdgeBlur.resolve(0, 0), GlimmerEdgeBlur.idleEnd);
      expect(GlimmerEdgeBlur.resolve(1, 0), GlimmerEdgeBlur.focusedEnd);
      expect(GlimmerEdgeBlur.resolve(1, 1), GlimmerEdgeBlur.ambientMaxEnd);
      expect(
        GlimmerEdgeBlur.resolveStart(0, 0),
        lessThan(GlimmerEdgeBlur.resolve(0, 0)),
      );
    });
  });
}
