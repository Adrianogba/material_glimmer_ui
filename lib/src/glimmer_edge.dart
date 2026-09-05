import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'glimmer_tone.dart';

/// The four corner colours of a Glimmer border, and the maths that turns them
/// into the gradient around a surface.
///
/// Glimmer's border is not a stroke of one colour. It is an angular gradient
/// with a colour at each corner, and the whole gradient rotates as a surface
/// takes focus. That is the detail that makes a panel read as a lit edge rather
/// than an outline someone drew, and it is what the design language is named
/// after.
///
/// Upstream this is an AGSL runtime shader, which needs Android 13 and works
/// only on Android. The shader is short and its maths is plain, so it is
/// reimplemented here as a [SweepGradient] sampled from the same functions.
/// Every constant below is the published one.
@immutable
class GlimmerEdge {
  /// Creates an edge from its four corner colours, in the order top-left,
  /// top-right, bottom-right, bottom-left.
  const GlimmerEdge({
    required this.topLeft,
    required this.topRight,
    required this.bottomRight,
    required this.bottomLeft,
  });

  /// The resting edge.
  ///
  /// Deliberately asymmetric: bright at the top-left where the light falls,
  /// darkest at the bottom-right, and part of the way back up at the
  /// bottom-left. These are the published values and they do not depend on the
  /// palette.
  const GlimmerEdge.idle()
      : topLeft = const Color(0xE6CFCFCF),
        topRight = const Color(0x80404040),
        bottomRight = const Color(0x66292929),
        bottomLeft = const Color(0xB37D7D7D);

  /// The focused edge, derived from [focal].
  ///
  /// White at the lit corner, then the focal colour at tones 85, 69 and 77.
  factory GlimmerEdge.focused(Color focal) => GlimmerEdge(
        topLeft: const Color(0xFFFFFFFF),
        topRight: focal.withTone(85),
        bottomRight: focal.withTone(69),
        bottomLeft: focal.withTone(77),
      );

  /// An edge for a surface that carries a fill of its own.
  ///
  /// The resting edge is a fixed set of greys, which is right on the neutral
  /// surface it was chosen for and wrong on anything else: over a coloured fill
  /// it reads as a grey ring drawn around the component rather than as light
  /// landing on it.
  ///
  /// This derives the edge from the fill instead, and keeps every stop
  /// translucent so the fill stays the colour you see. The lit corner is a white
  /// highlight, the corner beside it lifts the fill's own tone, and the far side
  /// drops it.
  factory GlimmerEdge.onFill(Color fill) {
    final tone = fill.tone;
    return GlimmerEdge(
      topLeft: const Color(0xFFFFFFFF).withValues(alpha: 0.55),
      topRight: fill.withTone(math.min(100, tone + 14)).withValues(alpha: 0.4),
      bottomRight: fill.withTone(math.max(0, tone - 16)).withValues(alpha: 0.3),
      bottomLeft: fill.withTone(math.max(0, tone - 6)).withValues(alpha: 0.36),
    );
  }

  /// The lit corner.
  final Color topLeft;

  /// The corner a quarter turn clockwise from [topLeft].
  final Color topRight;

  /// The corner opposite [topLeft].
  final Color bottomRight;

  /// The corner a quarter turn anticlockwise from [topLeft].
  final Color bottomLeft;

  /// The four colours in the order the gradient walks them.
  List<Color> get corners => [topLeft, topRight, bottomRight, bottomLeft];

  /// Linearly interpolates between two edges.
  static GlimmerEdge lerp(GlimmerEdge a, GlimmerEdge b, double t) =>
      GlimmerEdge(
        topLeft: Color.lerp(a.topLeft, b.topLeft, t)!,
        topRight: Color.lerp(a.topRight, b.topRight, t)!,
        bottomRight: Color.lerp(a.bottomRight, b.bottomRight, t)!,
        bottomLeft: Color.lerp(a.bottomLeft, b.bottomLeft, t)!,
      );

  /// Mixes every corner toward [color] by [t].
  GlimmerEdge blendToward(Color color, double t) {
    if (t <= 0) return this;
    return GlimmerEdge(
      topLeft: Color.lerp(topLeft, color, t)!,
      topRight: Color.lerp(topRight, color, t)!,
      bottomRight: Color.lerp(bottomRight, color, t)!,
      bottomLeft: Color.lerp(bottomLeft, color, t)!,
    );
  }

  /// The colour at [position] around the perimeter, where 0 is the lit corner
  /// and the value runs clockwise to 1.
  ///
  /// The gradient is symmetric about the lit corner: it walks the same way
  /// clockwise and anticlockwise, which is why the two corners next to it can
  /// differ while the pattern still closes.
  Color colorAt(double position) {
    final wrapped = position % 1;
    final distance = math.min(wrapped, 1 - wrapped);
    final c = corners;
    var color = Color.lerp(c[0], c[1], _smoothstep(0, 0.1, distance))!;
    color = Color.lerp(color, c[2], _smoothstep(0.1, 0.25, distance))!;
    color = Color.lerp(color, c[3], _smoothstep(0.25, 0.4, distance))!;
    return color;
  }

  /// Builds the sweep gradient for a surface of [size].
  ///
  /// [focusProgress] rotates the lit corner from the top-left to the top-right
  /// as the surface takes focus, which is the movement a wearer sees when they
  /// look at something. On a phone it reads as the highlight sliding across the
  /// top of whatever the finger just chose.
  Gradient toGradient({
    required double focusProgress,
    int samples = 48,
    bool litArcOnly = false,
  }) {
    // The lit corner starts at 225 degrees measured clockwise from the positive
    // x axis, which is the top-left, and moves a quarter turn with focus.
    final rotation = (_quarterTurns * 5) + (focusProgress * _quarterTurns);
    final start = focusProgress * 0.25;
    return SweepGradient(
      transform: _SquareSweep(rotation),
      colors: [
        for (var i = 0; i <= samples; i++)
          _sample(colorAt((i / samples) + start), i / samples, litArcOnly),
      ],
      stops: [for (var i = 0; i <= samples; i++) i / samples],
    );
  }

  /// Fades a sample out away from the lit corner, for the crisp pass that is
  /// drawn on top of the soft one.
  static Color _sample(Color color, double position, bool litArcOnly) {
    if (!litArcOnly) return color;
    final distance = math.min(position, 1 - position);
    final falloff = 1 - _smoothstep(0.02, 0.3, distance);
    return color.withValues(alpha: color.a * falloff);
  }

  static const _quarterTurns = math.pi / 2;

  static double _smoothstep(double edge0, double edge1, double x) {
    final t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    return t * t * (3 - (2 * t));
  }
}

/// How sharp the border is around the perimeter.
///
/// Glimmer blurs its border progressively: crisp at the lit corner and soft on
/// the far side, and the whole thing sharpens on focus and blooms at the peak
/// of the ambient sweep. These are the published radii.
@immutable
class GlimmerEdgeBlur {
  const GlimmerEdgeBlur._();

  /// Blur at the lit corner while resting.
  static const idleStart = 2.0;

  /// Blur on the far side while resting.
  static const idleEnd = 8.0;

  /// Blur at the lit corner while focused.
  static const focusedStart = 1.0;

  /// Blur on the far side while focused.
  static const focusedEnd = 3.0;

  /// The widest blur the ambient sweep reaches at the lit corner.
  static const ambientMaxStart = 5.3;

  /// The widest blur the ambient sweep reaches on the far side.
  static const ambientMaxEnd = 15.9;

  /// The blur on the far side of the border for the given progresses.
  static double resolve(double focusProgress, double ambientProgress) {
    final focused = _lerp(idleEnd, focusedEnd, focusProgress);
    return _lerp(focused, ambientMaxEnd, ambientProgress);
  }

  /// The blur at the lit corner for the given progresses.
  static double resolveStart(double focusProgress, double ambientProgress) {
    final focused = _lerp(idleStart, focusedStart, focusProgress);
    return _lerp(focused, ambientMaxStart, ambientProgress);
  }

  static double _lerp(double a, double b, double t) => a + ((b - a) * t);
}

/// Rotates a sweep gradient and squares up the space it is measured in.
///
/// The upstream shader normalises each axis independently before taking the
/// angle, so its four colour stops land on the four actual corners of a
/// component whatever its proportions. A sweep measured in screen space does
/// not: on a wide button every stop crowds into the middle of the top and
/// bottom edges, and the gradient collapses into two bright patches instead of
/// running round the shape. Scaling the gradient's space back to a square
/// restores the corners.
class _SquareSweep extends GradientTransform {
  const _SquareSweep(this.rotation);

  /// Clockwise rotation in radians, placing the lit corner.
  final double rotation;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    if (bounds.width <= 0 || bounds.height <= 0) return null;
    final center = bounds.center;
    return Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(1, bounds.height / bounds.width, 1, 1)
      ..rotateZ(rotation)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }

  @override
  bool operator ==(Object other) =>
      other is _SquareSweep && other.rotation == rotation;

  @override
  int get hashCode => rotation.hashCode;
}
