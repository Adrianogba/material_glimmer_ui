import 'package:flutter/material.dart';

/// The seven Glimmer text styles.
///
/// Glimmer's scale is unusually flat: `titleLarge` and `bodyLarge` are the same
/// size and differ only in weight, and the smallest style is a caption rather
/// than a label. That shape is preserved here.
///
/// [GlimmerTypography.glasses] carries the published sizes verbatim, which are
/// set by the 0.6 degree legibility floor of a display lens. On a phone held at
/// arm's length that floor does not apply, so [GlimmerTypography.mobile] scales
/// every size by two thirds and keeps the line-height ratios and weights
/// exactly.
@immutable
class GlimmerTypography {
  /// Creates a type scale with every style given explicitly.
  const GlimmerTypography({
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.caption,
  });

  /// The published Glimmer scale, in glasses sizes.
  ///
  /// Use it when mirroring a Glimmer layout for reference or documentation. It
  /// is far too large for a phone.
  factory GlimmerTypography.glasses({String? fontFamily}) =>
      GlimmerTypography._scaled(1, fontFamily);

  /// The mobile scale: the glasses sizes at two thirds, with the source
  /// line-height ratios and weights untouched.
  factory GlimmerTypography.mobile({String? fontFamily}) =>
      GlimmerTypography._scaled(2 / 3, fontFamily);

  factory GlimmerTypography._scaled(double scale, String? fontFamily) {
    TextStyle style(double size, double lineHeight, FontWeight weight) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size * scale,
        height: lineHeight / size,
        fontWeight: weight,
        letterSpacing: 0,
      );
    }

    // Google Sans Flex is a variable font, so the source weights are exact
    // axis values. Flutter's FontWeight is quantised to hundreds, so 725
    // becomes w700, 650 becomes w600 and 520 becomes w500.
    return GlimmerTypography(
      titleLarge: style(30, 36, FontWeight.w700),
      titleMedium: style(24, 32, FontWeight.w700),
      titleSmall: style(20, 28, FontWeight.w700),
      bodyLarge: style(30, 36, FontWeight.w500),
      bodyMedium: style(24, 32, FontWeight.w500),
      bodySmall: style(20, 28, FontWeight.w500),
      caption: style(18, 28, FontWeight.w600),
    );
  }

  /// The largest title. 30 sp on glasses, 20 on mobile.
  final TextStyle titleLarge;

  /// The default title for cards and screens. 24 sp on glasses, 16 on mobile.
  final TextStyle titleMedium;

  /// The smallest title, for list item labels. 20 sp on glasses, 13.3 on mobile.
  final TextStyle titleSmall;

  /// Body copy at title size, for a single prominent sentence.
  final TextStyle bodyLarge;

  /// The default body style.
  final TextStyle bodyMedium;

  /// Supporting body copy, for list item subtitles.
  final TextStyle bodySmall;

  /// The smallest style, heavier than body so it stays legible.
  final TextStyle caption;

  /// Returns a copy with the given styles replaced.
  GlimmerTypography copyWith({
    TextStyle? titleLarge,
    TextStyle? titleMedium,
    TextStyle? titleSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? caption,
  }) {
    return GlimmerTypography(
      titleLarge: titleLarge ?? this.titleLarge,
      titleMedium: titleMedium ?? this.titleMedium,
      titleSmall: titleSmall ?? this.titleSmall,
      bodyLarge: bodyLarge ?? this.bodyLarge,
      bodyMedium: bodyMedium ?? this.bodyMedium,
      bodySmall: bodySmall ?? this.bodySmall,
      caption: caption ?? this.caption,
    );
  }

  /// Maps the Glimmer styles onto Material's [TextTheme] slots, so Material
  /// widgets used alongside Glimmer ones pick up the same type.
  ///
  /// Glimmer has no display or headline tier, so those slots reuse
  /// [titleLarge]. Its `caption` fills Material's label slots.
  TextTheme toTextTheme(Color color) {
    final title = titleLarge.copyWith(color: color);
    return TextTheme(
      displayLarge: title,
      displayMedium: title,
      displaySmall: title,
      headlineLarge: title,
      headlineMedium: titleMedium.copyWith(color: color),
      headlineSmall: titleMedium.copyWith(color: color),
      titleLarge: title,
      titleMedium: titleMedium.copyWith(color: color),
      titleSmall: titleSmall.copyWith(color: color),
      bodyLarge: bodyLarge.copyWith(color: color),
      bodyMedium: bodyMedium.copyWith(color: color),
      bodySmall: bodySmall.copyWith(color: color),
      labelLarge: titleSmall.copyWith(color: color),
      labelMedium: caption.copyWith(color: color),
      labelSmall: caption.copyWith(color: color),
    );
  }

  /// Linearly interpolates between two type scales.
  static GlimmerTypography lerp(
    GlimmerTypography a,
    GlimmerTypography b,
    double t,
  ) {
    return GlimmerTypography(
      titleLarge: TextStyle.lerp(a.titleLarge, b.titleLarge, t)!,
      titleMedium: TextStyle.lerp(a.titleMedium, b.titleMedium, t)!,
      titleSmall: TextStyle.lerp(a.titleSmall, b.titleSmall, t)!,
      bodyLarge: TextStyle.lerp(a.bodyLarge, b.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(a.bodyMedium, b.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(a.bodySmall, b.bodySmall, t)!,
      caption: TextStyle.lerp(a.caption, b.caption, t)!,
    );
  }
}
