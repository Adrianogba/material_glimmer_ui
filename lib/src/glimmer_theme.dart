import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'glimmer_colors.dart';
import 'glimmer_depth.dart';
import 'glimmer_metrics.dart';
import 'glimmer_typography.dart';

/// Which set of measurements a [GlimmerTheme] uses.
enum GlimmerScale {
  /// Type, radii, icon sizes and depth at two thirds of the published values.
  ///
  /// This is the default. Glimmer's sizes are set by the legibility floor of a
  /// lens a few centimetres from the eye; a phone held at arm's length does not
  /// need them, and at full size a Glimmer card overflows a handset.
  mobile,

  /// The published Glimmer measurements, unchanged.
  ///
  /// Useful for reproducing a glasses layout for reference, or on a tablet or
  /// desktop window where the sizes are not absurd.
  glasses,
}

/// Every Glimmer design token, resolved and reachable from the widget tree.
///
/// Read it with [GlimmerTheme.of].
@immutable
class GlimmerTokens extends ThemeExtension<GlimmerTokens> {
  /// Creates a token set with every scale given explicitly.
  const GlimmerTokens({
    required this.scale,
    required this.colors,
    required this.typography,
    required this.shapes,
    required this.spacing,
    required this.iconSizes,
    required this.depth,
    required this.surfaceOpacity,
    required this.surfaceBlur,
    required this.additive,
  });

  /// Builds the tokens for [scale], optionally re-skinning the focal colour.
  /// Builds the tokens for [scale] and [brightness].
  factory GlimmerTokens.forScale(
    GlimmerScale scale, {
    Brightness brightness = Brightness.dark,
    Color? primary,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    bool? additive,
  }) {
    final isMobile = scale == GlimmerScale.mobile;
    final isDark = brightness == Brightness.dark;
    return GlimmerTokens(
      scale: scale,
      colors: isDark
          ? GlimmerColors.standard(
              primary: primary ?? const Color(0xFF9BBFFF),
            )
          : GlimmerColors.light(primary: primary ?? const Color(0xFF2E6BD6)),
      typography: isMobile
          ? GlimmerTypography.mobile(fontFamily: fontFamily)
          : GlimmerTypography.glasses(fontFamily: fontFamily),
      shapes: isMobile ? GlimmerShapes.mobile() : GlimmerShapes.glasses(),
      spacing: const GlimmerSpacing.standard(),
      iconSizes: isMobile
          ? const GlimmerIconSizes.mobile()
          : const GlimmerIconSizes.glasses(),
      // The published shadow alphas assume a pure black ground. Over a backdrop
      // they read as a dark halo and on a light ground as a bruise, so both
      // themes pull them well down.
      depth: isMobile
          ? GlimmerDepth.mobile(opacity: isDark ? 0.55 : 0.12)
          : GlimmerDepth.glasses(opacity: isDark ? 0.55 : 0.12),
      // A light surface cannot add light: white plus anything is white. It
      // filters what is behind it instead, which is the same glass seen from
      // the other side.
      surfaceOpacity: surfaceOpacity ?? (isDark ? 0.72 : 0.66),
      surfaceBlur: surfaceBlur ?? (isMobile ? 26 : 0),
      additive: additive ?? isDark,
    );
  }

  /// Which set of measurements these tokens carry.
  ///
  /// Components read it to pick minimum heights, which are touch targets rather
  /// than visual measurements and so do not follow the two-thirds rule the
  /// other scales use.
  final GlimmerScale scale;

  /// The colour roles.
  final GlimmerColors colors;

  /// The type scale.
  final GlimmerTypography typography;

  /// The corner radii.
  final GlimmerShapes shapes;

  /// The spacing steps.
  final GlimmerSpacing spacing;

  /// The icon sizes.
  final GlimmerIconSizes iconSizes;

  /// The five depth levels.
  final GlimmerDepth depth;

  /// How strongly a surface tints what is behind it, from 0 to 1.
  ///
  /// At 1 the published colours come out exactly over a black background, but a
  /// surface over a backdrop then reads as a slab rather than as glass. The
  /// default holds it below that so the backdrop keeps coming through, which is
  /// the whole point of the material.
  ///
  /// It applies to the surface role only. A colour passed to
  /// [GlimmerSurface.color] is a decision rather than a default, so a prominent
  /// or semantic fill keeps its full strength.
  final double surfaceOpacity;

  /// The blur sigma applied to whatever sits behind a surface.
  ///
  /// 18 on mobile and 0 on the glasses scale, where the real world provides the
  /// depth of field by itself.
  ///
  /// A blur is a compositing pass per surface. It is worth it for cards and
  /// panels; for a long list of rows, pass `blur: 0` on the row and let the
  /// list's own backdrop carry the effect.
  final double surfaceBlur;

  /// Whether a surface adds its tint to the backdrop instead of painting over
  /// it.
  ///
  /// This is the lens behaviour, and it is on by default because it is right in
  /// both directions. Over the black Glimmer background, adding `#303030` to
  /// black gives `#303030`, so the published colours come out exact. Over a
  /// photograph or a gradient, the same operation makes the surface brighter
  /// than what it covers, which is what a pane of glass catching light
  /// actually does and what keeps a Glimmer panel from reading as a grey slab.
  ///
  /// Turn it off for a surface that has to darken what is under it, such as one
  /// covering content it needs to hide.
  final bool additive;

  @override
  GlimmerTokens copyWith({
    GlimmerScale? scale,
    GlimmerColors? colors,
    GlimmerTypography? typography,
    GlimmerShapes? shapes,
    GlimmerSpacing? spacing,
    GlimmerIconSizes? iconSizes,
    GlimmerDepth? depth,
    double? surfaceOpacity,
    double? surfaceBlur,
    bool? additive,
  }) {
    return GlimmerTokens(
      scale: scale ?? this.scale,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      shapes: shapes ?? this.shapes,
      spacing: spacing ?? this.spacing,
      iconSizes: iconSizes ?? this.iconSizes,
      depth: depth ?? this.depth,
      surfaceOpacity: surfaceOpacity ?? this.surfaceOpacity,
      surfaceBlur: surfaceBlur ?? this.surfaceBlur,
      additive: additive ?? this.additive,
    );
  }

  @override
  GlimmerTokens lerp(covariant GlimmerTokens? other, double t) {
    if (other == null) return this;
    return GlimmerTokens(
      scale: t < 0.5 ? scale : other.scale,
      colors: GlimmerColors.lerp(colors, other.colors, t),
      typography: GlimmerTypography.lerp(typography, other.typography, t),
      shapes: GlimmerShapes.lerp(shapes, other.shapes, t),
      spacing: GlimmerSpacing.lerp(spacing, other.spacing, t),
      iconSizes: GlimmerIconSizes.lerp(iconSizes, other.iconSizes, t),
      depth: GlimmerDepth.lerp(depth, other.depth, t),
      surfaceOpacity:
          lerpDouble(surfaceOpacity, other.surfaceOpacity, t) ?? surfaceOpacity,
      surfaceBlur: lerpDouble(surfaceBlur, other.surfaceBlur, t) ?? surfaceBlur,
      additive: t < 0.5 ? additive : other.additive,
    );
  }
}

/// Builds a Material [ThemeData] carrying the Glimmer tokens.
///
/// Glimmer itself tells you not to mix in Material components, because on an
/// additive display Material's dark-on-light foregrounds resolve to colours the
/// lens renders as invisible. On a phone that constraint does not exist, so this
/// package does the opposite: it produces a real [ThemeData] whose colour scheme
/// and text theme are derived from the Glimmer tokens, and any Material widget
/// you drop alongside a Glimmer one inherits the same palette and type.
class GlimmerTheme {
  const GlimmerTheme._();

  /// Creates the Glimmer theme.
  ///
  /// [primary] re-skins the focal colour, which is what focused outlines, glows
  /// and primary buttons use. [scale] chooses between the mobile and the
  /// published glasses measurements. [fontFamily] sets the typeface; Glimmer's
  /// own is Google Sans Flex, which is not bundled here because this package
  /// ships no assets.
  static ThemeData dark({
    Color? primary,
    GlimmerScale scale = GlimmerScale.mobile,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    bool? additive,
  }) =>
      _build(
        brightness: Brightness.dark,
        primary: primary,
        scale: scale,
        fontFamily: fontFamily,
        surfaceOpacity: surfaceOpacity,
        surfaceBlur: surfaceBlur,
        additive: additive,
      );

  /// Creates the Glimmer theme on a light ground.
  ///
  /// Glimmer itself is dark only, and on a lens it has to be: an additive
  /// display renders black as transparent, so a light interface would be a wall
  /// of light in front of the wearer. A phone has no such constraint, and an
  /// app that sits alongside a light system theme needs the option.
  ///
  /// The hues are the published ones at the lightness they need to read on a
  /// light ground, and surfaces filter the backdrop instead of adding to it,
  /// which is the same glass seen from the other side. The timing, the spacing,
  /// the depth levels and the graded edge are untouched.
  static ThemeData light({
    Color? primary,
    GlimmerScale scale = GlimmerScale.mobile,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    bool? additive,
  }) =>
      _build(
        brightness: Brightness.light,
        primary: primary,
        scale: scale,
        fontFamily: fontFamily,
        surfaceOpacity: surfaceOpacity,
        surfaceBlur: surfaceBlur,
        additive: additive,
      );

  static ThemeData _build({
    required Brightness brightness,
    Color? primary,
    GlimmerScale scale = GlimmerScale.mobile,
    String? fontFamily,
    double? surfaceOpacity,
    double? surfaceBlur,
    bool? additive,
  }) {
    final tokens = GlimmerTokens.forScale(
      scale,
      brightness: brightness,
      primary: primary,
      fontFamily: fontFamily,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      additive: additive,
    );
    final colors = tokens.colors;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onPrimary,
        error: colors.negative,
        onError: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.onSurface,
        outline: colors.outline,
      ),
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      textTheme: tokens.typography.toTextTheme(colors.onSurface),
      iconTheme: IconThemeData(
        color: colors.onSurface,
        size: tokens.iconSizes.medium,
      ),
      splashFactory: NoSplash.splashFactory,
      extensions: [tokens],
    );
  }

  /// The Glimmer tokens in scope.
  ///
  /// Asserts in debug mode if the tree is not under a [GlimmerTheme.dark]
  /// theme.
  static GlimmerTokens of(BuildContext context) {
    final tokens = Theme.of(context).extension<GlimmerTokens>();
    assert(
      tokens != null,
      'No GlimmerTokens found. Set GlimmerTheme.dark() as your theme, or add '
      'GlimmerTokens.forScale(...) to ThemeData.extensions.',
    );
    return tokens!;
  }

  /// The Glimmer colours in scope. Shorthand for `GlimmerTheme.of(context).colors`.
  static GlimmerColors colorsOf(BuildContext context) => of(context).colors;

  /// The Glimmer type scale in scope.
  static GlimmerTypography typographyOf(BuildContext context) =>
      of(context).typography;
}
