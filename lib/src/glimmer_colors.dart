import 'package:flutter/widgets.dart';

/// The Glimmer colour roles.
///
/// A small set of luminous accents on true black, plus the surface and outline
/// roles every component reads. [GlimmerColors.light] re-grounds the same hues
/// for a light background.
///
/// See also:
///
///  * [GlimmerColors.contentColorFor], which picks the foreground colour for a
///    given background.
@immutable
class GlimmerColors {
  /// Creates a Glimmer palette with every role given explicitly.
  const GlimmerColors({
    required this.brightness,
    required this.primary,
    required this.secondary,
    required this.positive,
    required this.negative,
    required this.background,
    required this.surface,
    required this.outline,
    required this.onPrimary,
    required this.onSurface,
  });

  /// The default dark palette.
  ///
  /// Pass [primary] to re-skin the focal colour without losing the rest of the
  /// roles.
  factory GlimmerColors.standard({Color primary = const Color(0xFF9BBFFF)}) {
    return GlimmerColors(
      brightness: Brightness.dark,
      primary: primary,
      secondary: const Color(0xFF4C88E9),
      positive: const Color(0xFF63FEA8),
      negative: const Color(0xFFFFA7A0),
      background: const Color(0xFF000000),
      surface: const Color(0xFF303030),
      outline: const Color(0xFF606460),
      onPrimary: const Color(0xFF0B0F14),
      onSurface: const Color(0xFFFFFFFF),
    );
  }

  /// Whether these colours are meant for a dark or a light ground.
  ///
  /// Components read it to decide which way light falls: a highlight on a dark
  /// surface is white, and on a light one it is a shadow.
  final Brightness brightness;

  /// The focal colour. Used for focused outlines, primary fills and icons.
  final Color primary;

  /// The supporting focal colour, for accents that must not compete with
  /// [primary].
  final Color secondary;

  /// The affirmative colour, for confirmations and success states.
  final Color positive;

  /// The cautionary colour, for destructive actions and errors.
  final Color negative;

  /// The window colour. Black, which an additive display renders as fully
  /// transparent and a phone renders as true black.
  final Color background;

  /// The base fill for surfaces, cards, buttons and list items.
  ///
  /// Glimmer states this as its base colour at tone 20, and `#303030` is what
  /// that resolves to. The developer guide quotes `#262626`, which is tone 15;
  /// the value here follows the source, so deriving the focused fill by lifting
  /// the tone lands on the intended number rather than near it.
  final Color surface;

  /// The resting border colour of an unfocused surface.
  final Color outline;

  /// The foreground drawn on [primary], [secondary], [positive] and [negative].
  final Color onPrimary;

  /// The foreground drawn on [surface] and [background].
  final Color onSurface;

  /// The palette re-grounded for a light background.
  ///
  /// The hues are the dark palette's. Only lightness moves, far enough that
  /// each role clears the 70% tone difference against a light ground rather
  /// than a dark one. Surfaces stop adding light and start filtering it
  /// instead, which is the same glass seen from the other side.
  factory GlimmerColors.light({Color primary = const Color(0xFF2E6BD6)}) {
    return GlimmerColors(
      brightness: Brightness.light,
      primary: primary,
      secondary: const Color(0xFF1B4FA8),
      positive: const Color(0xFF0E7A47),
      negative: const Color(0xFFB43A2F),
      background: const Color(0xFFF3F4F7),
      surface: const Color(0xFFFFFFFF),
      outline: const Color(0xFF9AA0A6),
      onPrimary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF101418),
    );
  }

  /// The foreground colour Glimmer would place on [background].
  ///
  /// Glimmer computes content colour from the nearest surface rather than
  /// asking the caller to set it, which is why [GlimmerText] and the component
  /// widgets never require an explicit text colour.
  ///
  /// The rule: a background below the luminance
  /// breakpoint takes [onSurface] and anything at or above it takes
  /// [onPrimary]. Comparing against the named roles instead would look right
  /// for the default palette and then quietly fail the moment a caller passed
  /// a colour of its own.
  Color contentColorFor(Color background) {
    final wantsLightForeground =
        background.computeLuminance() < contentColorLuminanceBreakpoint;
    // Which of the two foregrounds is the light one depends on the ground the
    // palette was built for. On dark it is onSurface; on light it is onPrimary,
    // because there the focal colours are the dark ones. Picking by role rather
    // than by luminance puts white text on white glass in a light theme.
    final onSurfaceIsLight = onSurface.computeLuminance() >= 0.5;
    return wantsLightForeground == onSurfaceIsLight ? onSurface : onPrimary;
  }

  /// The luminance at which content flips from light to dark.
  ///
  /// Chosen so either foreground clears the contrast ratio
  /// Glimmer asks for on the background it is paired with.
  static const contentColorLuminanceBreakpoint = 0.179129;

  /// Returns a copy with the given roles replaced.
  GlimmerColors copyWith({
    Brightness? brightness,
    Color? primary,
    Color? secondary,
    Color? positive,
    Color? negative,
    Color? background,
    Color? surface,
    Color? outline,
    Color? onPrimary,
    Color? onSurface,
  }) {
    return GlimmerColors(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      outline: outline ?? this.outline,
      onPrimary: onPrimary ?? this.onPrimary,
      onSurface: onSurface ?? this.onSurface,
    );
  }

  /// Linearly interpolates between two palettes.
  static GlimmerColors lerp(GlimmerColors a, GlimmerColors b, double t) {
    return GlimmerColors(
      brightness: t < 0.5 ? a.brightness : b.brightness,
      primary: Color.lerp(a.primary, b.primary, t)!,
      secondary: Color.lerp(a.secondary, b.secondary, t)!,
      positive: Color.lerp(a.positive, b.positive, t)!,
      negative: Color.lerp(a.negative, b.negative, t)!,
      background: Color.lerp(a.background, b.background, t)!,
      surface: Color.lerp(a.surface, b.surface, t)!,
      outline: Color.lerp(a.outline, b.outline, t)!,
      onPrimary: Color.lerp(a.onPrimary, b.onPrimary, t)!,
      onSurface: Color.lerp(a.onSurface, b.onSurface, t)!,
    );
  }
}
