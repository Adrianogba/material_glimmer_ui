import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'glimmer_tone.dart';

/// The four corner colours of a Glimmer border, and the maths that turns them
/// into the gradient around a surface.
///
/// The border is not a stroke of one colour. It is an angular gradient with a
/// colour at each corner, and the whole gradient rotates as a surface takes
/// focus. That is the detail that makes a panel read as a lit edge rather than
/// an outline someone drew, and it is the part of this kit worth knowing about.
///
/// It is built as a [SweepGradient] sampled from the corner colours, rather
/// than as a runtime shader, so it works on every platform Flutter runs on.
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
  /// bottom-left. Fixed values: the resting edge does not follow the
  /// palette.
  const GlimmerEdge.idle()
      : topLeft = const Color(0xE6CFCFCF),
        topRight = const Color(0x80404040),
        bottomRight = const Color(0x66292929),
        bottomLeft = const Color(0xB37D7D7D);

  /// The resting edge on a light ground.
  ///
  /// Light comes from the top-left in both themes, because that is a fact
  /// about light rather than a fact about the palette. Inverting the dark ring
  /// instead would put the bright stop at the bottom-right, and a form lit from
  /// below reads as pressed into the page rather than raised off it.
  ///
  /// What changes is which direction has room. On `#303030` there is most of a
  /// stop of headroom upward, so the dark ring is a highlight arc at the
  /// top-left and nothing anywhere else. On white there is none at all: a white
  /// highlight on a white surface is zero by definition. So the same shape is
  /// drawn in shade, and the lighting is carried by how steeply the shade
  /// deepens away from the light, not by a bright stop.
  ///
  /// The spread matters more than the depth. These stops run 0, -0.06, -0.20
  /// and -0.46 in luminance against the surface, which is about the swing the
  /// dark ring has. An even outline of roughly equal stops is what made the
  /// light theme read as a flat rectangle with a border.
  const GlimmerEdge.idleLight()
      : topLeft = const Color(0x00101418),
        topRight = const Color(0x07101418),
        bottomRight = const Color(0x42101418),
        bottomLeft = const Color(0x1A101418);

  /// The focused edge, derived from [focal].
  ///
  /// White at the lit corner, then the focal colour at tones 85, 69 and 77.
  factory GlimmerEdge.focused(Color focal) => GlimmerEdge(
        topLeft: const Color(0xFFFFFFFF),
        topRight: focal.withTone(85),
        bottomRight: focal.withTone(69),
        bottomLeft: focal.withTone(77),
      );

  /// The focused edge on a light ground.
  ///
  /// White at the lit corner is right against black and nothing at all against
  /// white: the ring simply breaks wherever the highlight lands, which is what
  /// puts a pale gap in the bottom of every selected component on a light
  /// theme. The light set is the dark set mirrored about tone 70, so the lit
  /// corner is the *darkest* stop rather than the brightest and the ring stays
  /// as visible against its ground, just from the other direction.
  factory GlimmerEdge.focusedLight(Color focal) => GlimmerEdge(
        topLeft: focal.withTone(40),
        topRight: focal.withTone(55),
        bottomRight: focal.withTone(71),
        bottomLeft: focal.withTone(63),
      );

  /// An edge for a surface that carries a fill of its own.
  ///
  /// The resting edge is a fixed set of greys, which is right on the neutral
  /// surface it was chosen for and wrong on anything else: over a coloured fill
  /// it reads as a grey ring drawn around the component rather than as light
  /// landing on it.
  ///
  /// This derives the edge from the fill instead, and keeps every stop
  /// translucent so the fill stays the colour you see. The lit corner is a
  /// highlight, the corner beside it lifts the fill's own tone, and the far
  /// side drops it.
  ///
  /// [highlight] is which way contrast runs on the ground this sits on, from
  /// [GlimmerColors.highlightTint]. White is right against black and invisible
  /// against white, so a fill on a light theme gets an ink highlight instead.
  factory GlimmerEdge.onFill(
    Color fill, {
    Color highlight = const Color(0xFFFFFFFF),
  }) {
    final tone = fill.tone;
    return GlimmerEdge(
      topLeft: highlight.withValues(alpha: 0.55),
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

  /// Every corner at [t] of its own alpha.
  ///
  /// Used to bring an edge in without an opacity layer, which a glass surface
  /// cannot survive.
  GlimmerEdge scaleAlpha(double t) {
    if (t >= 1) return this;
    return GlimmerEdge(
      topLeft: topLeft.withValues(alpha: topLeft.a * t),
      topRight: topRight.withValues(alpha: topRight.a * t),
      bottomRight: bottomRight.withValues(alpha: bottomRight.a * t),
      bottomLeft: bottomLeft.withValues(alpha: bottomLeft.a * t),
    );
  }

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
  /// as the surface takes focus, so the highlight slides across the top of
  /// whatever was just chosen.
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
/// The border is blurred progressively: crisp at the lit corner and soft on the
/// far side, sharpening on focus and blooming at the peak of the ambient
/// sweep.
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
/// Each axis is normalised independently before the angle is taken, so the four
/// colour stops land on the four actual corners of a component whatever its
/// proportions. A sweep measured in screen space does not: on a wide button every stop crowds into the middle of the top and
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
