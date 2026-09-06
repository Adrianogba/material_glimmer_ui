import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// Corner radii for the three Glimmer shape roles.
///
/// A very round system: buttons and chips are fully stadium-shaped, and the
/// standard surface radius is 36 dp at the large scale. [GlimmerShapes.mobile]
/// keeps that character at a radius that does not eat a phone-sized
/// component.
@immutable
class GlimmerShapes {
  /// Creates a shape set with every role given explicitly.
  const GlimmerShapes({
    required this.small,
    required this.medium,
    required this.stadium,
  });

  /// The large radii: 12 dp small, 36 dp medium.
  factory GlimmerShapes.glasses() => GlimmerShapes._scaled(1);

  /// The phone radii: 8 dp small, 24 dp medium.
  factory GlimmerShapes.mobile() => GlimmerShapes._scaled(2 / 3);

  factory GlimmerShapes._scaled(double scale) => GlimmerShapes(
        small: BorderRadius.circular(12 * scale),
        medium: BorderRadius.circular(36 * scale),
        stadium: BorderRadius.circular(999),
      );

  /// The tight radius, for images and nested content.
  final BorderRadius small;

  /// The default radius for surfaces, cards and list items.
  final BorderRadius medium;

  /// Fully rounded ends, for buttons, chips and icon buttons.
  final BorderRadius stadium;

  /// Linearly interpolates between two shape sets.
  static GlimmerShapes lerp(GlimmerShapes a, GlimmerShapes b, double t) {
    return GlimmerShapes(
      small: BorderRadius.lerp(a.small, b.small, t)!,
      medium: BorderRadius.lerp(a.medium, b.medium, t)!,
      stadium: BorderRadius.lerp(a.stadium, b.stadium, t)!,
    );
  }
}

/// The five Glimmer spacing steps.
///
/// The same at both scales. They are already phone-sized, and scaling them
/// would break touch targets rather than help them.
@immutable
class GlimmerSpacing {
  /// Creates a spacing scale with every step given explicitly.
  const GlimmerSpacing({
    required this.extraSmall,
    required this.small,
    required this.medium,
    required this.large,
    required this.extraLarge,
  });

  /// The spacing scale: 6, 8, 12, 16 and 20.
  const GlimmerSpacing.standard()
      : extraSmall = 6,
        small = 8,
        medium = 12,
        large = 16,
        extraLarge = 20;

  /// 6. Very tightly coupled content, such as an icon and its label.
  final double extraSmall;

  /// 8. The gap between a [GlimmerTitleChip] and the content it titles.
  final double small;

  /// 12. The default gap inside a component.
  final double medium;

  /// 16. The default gap between components.
  final double large;

  /// 20. Distinct sections. Glimmer's default gap between list items.
  final double extraLarge;

  /// Linearly interpolates between two spacing scales.
  static GlimmerSpacing lerp(GlimmerSpacing a, GlimmerSpacing b, double t) {
    return GlimmerSpacing(
      extraSmall: lerpDouble(a.extraSmall, b.extraSmall, t)!,
      small: lerpDouble(a.small, b.small, t)!,
      medium: lerpDouble(a.medium, b.medium, t)!,
      large: lerpDouble(a.large, b.large, t)!,
      extraLarge: lerpDouble(a.extraLarge, b.extraLarge, t)!,
    );
  }
}

/// The three Glimmer icon sizes.
///
/// [GlimmerIconSizes.glasses] is sized for a display close to the eye.
/// [GlimmerIconSizes.mobile] scales it down so an icon still sits correctly
/// inside a phone-sized button.
@immutable
class GlimmerIconSizes {
  /// Creates an icon size set with every size given explicitly.
  const GlimmerIconSizes({
    required this.small,
    required this.medium,
    required this.large,
  });

  /// The large icon sizes: 32, 40 and 48.
  const GlimmerIconSizes.glasses()
      : small = 32,
        medium = 40,
        large = 48;

  /// The phone icon sizes: 21.3, 26.7 and 32.
  const GlimmerIconSizes.mobile()
      : small = 32 * 2 / 3,
        medium = 40 * 2 / 3,
        large = 48 * 2 / 3;

  /// The smallest icon, for list item affordances.
  final double small;

  /// The default icon size.
  final double medium;

  /// The largest icon, for a single focal symbol.
  final double large;

  /// Linearly interpolates between two icon size sets.
  static GlimmerIconSizes lerp(
    GlimmerIconSizes a,
    GlimmerIconSizes b,
    double t,
  ) {
    return GlimmerIconSizes(
      small: lerpDouble(a.small, b.small, t)!,
      medium: lerpDouble(a.medium, b.medium, t)!,
      large: lerpDouble(a.large, b.large, t)!,
    );
  }
}
