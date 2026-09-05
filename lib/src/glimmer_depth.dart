import 'package:flutter/widgets.dart';

/// One of Glimmer's five depth levels.
///
/// Glimmer expresses z-order with shadows rather than Material's elevation
/// overlay. Each level is two stacked black shadows: a wide, soft base layer at
/// 90% alpha and a tighter opaque layer drawn on top of it. Neither layer is
/// offset, so the shadow spreads evenly around the component.
///
/// Most components rest with no depth at all and only take a level while
/// focused, which is what makes focus read as the surface lifting toward the
/// viewer.
@immutable
class GlimmerDepthLevel {
  /// Creates a depth level from its two shadow layers.
  const GlimmerDepthLevel(this.layer1, this.layer2);

  /// The wide base shadow, drawn first.
  final BoxShadow layer1;

  /// The tighter shadow, drawn on top of [layer1].
  final BoxShadow layer2;

  /// The two layers in draw order, ready for [BoxDecoration.boxShadow].
  List<BoxShadow> get shadows => [layer1, layer2];

  /// Linearly interpolates between two levels.
  ///
  /// A null level is treated as no shadow, so focus can animate from flat to
  /// lifted.
  static List<BoxShadow> lerp(
    GlimmerDepthLevel? a,
    GlimmerDepthLevel? b,
    double t,
  ) {
    if (t <= 0) return a?.shadows ?? const <BoxShadow>[];
    if (t >= 1) return b?.shadows ?? const <BoxShadow>[];
    final from = a?.shadows ?? const <BoxShadow>[];
    final to = b?.shadows ?? const <BoxShadow>[];
    return BoxShadow.lerpList(from, to, t) ?? const <BoxShadow>[];
  }
}

/// The five Glimmer depth levels, from the lowest to the highest z-order.
///
/// [GlimmerDepth.glasses] carries the published radii and spreads verbatim.
/// [GlimmerDepth.mobile] scales the geometry by two thirds, matching the type
/// and shape scales, and leaves the alphas alone.
@immutable
class GlimmerDepth {
  /// Creates a depth scale with every level given explicitly.
  const GlimmerDepth({
    required this.level1,
    required this.level2,
    required this.level3,
    required this.level4,
    required this.level5,
  });

  /// The published Glimmer depth levels, in glasses sizes.
  ///
  /// [opacity] scales how strongly the shadows read. The published alphas
  /// assume a pure black ground, where a hard black shadow is almost invisible
  /// and only its outer edge does any work. Over a backdrop it is a dark halo
  /// instead, and on a light ground it is a bruise, so a theme scales them.
  factory GlimmerDepth.glasses({double opacity = 1}) =>
      GlimmerDepth._scaled(1, opacity);

  /// The glasses depth levels with their radii and spreads at two thirds.
  factory GlimmerDepth.mobile({double opacity = 1}) =>
      GlimmerDepth._scaled(2 / 3, opacity);

  factory GlimmerDepth._scaled(double scale, double opacity) {
    GlimmerDepthLevel level(
      double radius1,
      double spread1,
      double radius2,
      double spread2,
    ) {
      return GlimmerDepthLevel(
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: 0.9 * opacity),
          blurRadius: radius1 * scale,
          spreadRadius: spread1 * scale,
        ),
        BoxShadow(
          color: const Color(0xFF000000).withValues(alpha: opacity),
          blurRadius: radius2 * scale,
          spreadRadius: spread2 * scale,
        ),
      );
    }

    return GlimmerDepth(
      level1: level(12, 6, 6, 2),
      level2: level(23, 13, 8, 5),
      level3: level(34, 19, 9, 7),
      level4: level(45, 26, 11, 10),
      level5: level(56, 32, 12, 12),
    );
  }

  /// The lowest level. The resting state of a card or persistent background UI.
  final GlimmerDepthLevel level1;

  /// The focused or pressed state of a button or an interactive card.
  final GlimmerDepthLevel level2;

  /// Higher than [level2] and lower than [level4].
  final GlimmerDepthLevel level3;

  /// Higher than [level3] and lower than [level5].
  final GlimmerDepthLevel level4;

  /// The highest level, for content that must sit above everything else.
  final GlimmerDepthLevel level5;

  /// Returns the level at [index], counting from 1.
  ///
  /// Throws a [RangeError] outside 1 to 5.
  GlimmerDepthLevel operator [](int index) {
    switch (index) {
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      case 4:
        return level4;
      case 5:
        return level5;
    }
    throw RangeError.range(index, 1, 5, 'index');
  }

  /// Linearly interpolates between two depth scales.
  static GlimmerDepth lerp(GlimmerDepth a, GlimmerDepth b, double t) {
    GlimmerDepthLevel level(GlimmerDepthLevel x, GlimmerDepthLevel y) {
      return GlimmerDepthLevel(
        BoxShadow.lerp(x.layer1, y.layer1, t)!,
        BoxShadow.lerp(x.layer2, y.layer2, t)!,
      );
    }

    return GlimmerDepth(
      level1: level(a.level1, b.level1),
      level2: level(a.level2, b.level2),
      level3: level(a.level3, b.level3),
      level4: level(a.level4, b.level4),
      level5: level(a.level5, b.level5),
    );
  }
}
