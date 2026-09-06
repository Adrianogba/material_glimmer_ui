import 'package:flutter/widgets.dart';

/// One of Glimmer's five depth levels.
///
/// Upstream a level is two stacked black shadows drawn around a component. That
/// works on the hardware Glimmer was drawn for, where black is not a colour but
/// the absence of one: the shadow is a hole rather than a dark halo, and what
/// it reads as is the layer behind being taken away near the thing in front.
///
/// A phone screen is opaque, so painting the same two shadows gives a dark
/// halo, which is Material's language rather than Glimmer's. Here a level says
/// how far the plane behind withdraws instead, and nothing at all is painted
/// around a surface. The ratios between the levels are the published spreads,
/// so the five levels stay as far apart as they are upstream.
@immutable
class GlimmerDepthLevel {
  /// Creates a depth level from how far the plane behind withdraws.
  const GlimmerDepthLevel(this.recede) : assert(recede >= 0 && recede <= 1);

  /// How far the plane behind a surface at this level withdraws, from 0 to 1.
  ///
  /// 0 leaves it fully present. 1 takes it away entirely.
  final double recede;

  /// Linearly interpolates between two levels.
  ///
  /// A null level is treated as no depth, so a component can animate from flat
  /// to lifted.
  static double lerp(GlimmerDepthLevel? a, GlimmerDepthLevel? b, double t) {
    final from = a?.recede ?? 0;
    final to = b?.recede ?? 0;
    if (t <= 0) return from;
    if (t >= 1) return to;
    return from + ((to - from) * t);
  }

  @override
  bool operator ==(Object other) =>
      other is GlimmerDepthLevel && other.recede == recede;

  @override
  int get hashCode => recede.hashCode;

  @override
  String toString() => 'GlimmerDepthLevel($recede)';
}

/// The five Glimmer depth levels, from the lowest to the highest z-order.
///
/// The levels are spaced by the published shadow spreads, 6, 13, 19, 26 and 32,
/// normalised against the largest and taken up to [maxRecede]. Depth is not a
/// measurement of anything on screen, so unlike type, radii and icon sizes it
/// is the same at both [GlimmerScale] settings.
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

  /// The five levels, spaced by the published shadow spreads.
  ///
  /// [maxRecede] is how far the plane behind the front-most level withdraws.
  factory GlimmerDepth.standard({double maxRecede = 0.6}) {
    const spreads = [6.0, 13.0, 19.0, 26.0, 32.0];
    GlimmerDepthLevel level(int i) =>
        GlimmerDepthLevel((spreads[i] / spreads.last) * maxRecede);
    return GlimmerDepth(
      level1: level(0),
      level2: level(1),
      level3: level(2),
      level4: level(3),
      level5: level(4),
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
    GlimmerDepthLevel level(GlimmerDepthLevel x, GlimmerDepthLevel y) =>
        GlimmerDepthLevel(GlimmerDepthLevel.lerp(x, y, t));

    return GlimmerDepth(
      level1: level(a.level1, b.level1),
      level2: level(a.level2, b.level2),
      level3: level(a.level3, b.level3),
      level4: level(a.level4, b.level4),
      level5: level(a.level5, b.level5),
    );
  }
}
