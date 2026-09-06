import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'glimmer_motion.dart';
import 'glimmer_theme.dart';

/// What a Glimmer list does when it has no more to show.
///
/// Material stretches the content and Cupertino bounces it. Both move the
/// content itself, and moving the content is the one thing this design language
/// cannot afford: a stretch renders the list into an offscreen layer, and every
/// glass surface inside it loses the backdrop it was reading.
///
/// So the content does not move at all. The edge it ran into lights up, using
/// the same graded light the surfaces use for their own edges: a crisp line at
/// the boundary and a bloom falling away from it, both brightening with how
/// hard the list is pushed. It is painted over the content rather than by
/// transforming it, so nothing is isolated and the glass keeps working.
///
/// [GlimmerScrollBehavior] installs it, so an app using [MaterialGlimmerApp] gets it
/// without asking.
class GlimmerOverscrollIndicator extends StatefulWidget {
  /// Creates an overscroll indicator around [child].
  const GlimmerOverscrollIndicator({
    super.key,
    required this.child,
    required this.axisDirection,
    this.color,
  });

  /// The scrollable being wrapped.
  final Widget child;

  /// Which way the scrollable grows.
  final AxisDirection axisDirection;

  /// The colour of the light. Defaults to [GlimmerColors.primary].
  final Color? color;

  /// How far the list has to be pushed for the edge to reach full brightness.
  static const pullDistance = 180.0;

  /// How far the bloom reaches in from the edge at full brightness.
  static const bloomExtent = 72.0;

  @override
  State<GlimmerOverscrollIndicator> createState() =>
      _GlimmerOverscrollIndicatorState();
}

class _GlimmerOverscrollIndicatorState extends State<GlimmerOverscrollIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _leading = AnimationController.unbounded(
    vsync: this,
  )..addListener(_repaint);
  late final AnimationController _trailing = AnimationController.unbounded(
    vsync: this,
  )..addListener(_repaint);

  void _repaint() => setState(() {});

  @override
  void dispose() {
    _leading.dispose();
    _trailing.dispose();
    super.dispose();
  }

  void _pull(AnimationController edge, double amount) {
    edge
      ..stop()
      ..value =
          (edge.value + (amount / GlimmerOverscrollIndicator.pullDistance))
              .clamp(0.0, 1.0);
  }

  void _release(AnimationController edge) {
    if (edge.value == 0) return;
    // The light falls away on the same spring everything else settles with, so
    // letting go of a list feels like letting go of anything else.
    edge.animateWith(
      SpringSimulation(GlimmerMotion.settleSpring, edge.value, 0, 0),
    );
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.depth != 0) return false;

    if (notification is OverscrollNotification) {
      final overscroll = notification.overscroll;
      if (overscroll < 0) {
        _pull(_leading, -overscroll);
      } else {
        _pull(_trailing, overscroll);
      }
    } else if (notification is ScrollEndNotification ||
        notification is ScrollUpdateNotification) {
      _release(_leading);
      _release(_trailing);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);

    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: CustomPaint(
        foregroundPainter: _GlimmerOverscrollPainter(
          axisDirection: widget.axisDirection,
          color: widget.color ?? colors.primary,
          leading: _leading.value.clamp(0.0, 1.0),
          trailing: _trailing.value.clamp(0.0, 1.0),
        ),
        child: widget.child,
      ),
    );
  }
}

class _GlimmerOverscrollPainter extends CustomPainter {
  const _GlimmerOverscrollPainter({
    required this.axisDirection,
    required this.color,
    required this.leading,
    required this.trailing,
  });

  final AxisDirection axisDirection;
  final Color color;
  final double leading;
  final double trailing;

  @override
  void paint(Canvas canvas, Size size) {
    if (leading <= 0 && trailing <= 0) return;
    final vertical = axisDirection == AxisDirection.down ||
        axisDirection == AxisDirection.up;
    // A reversed scrollable puts its leading edge at the far side.
    final flipped = axisDirection == AxisDirection.up ||
        axisDirection == AxisDirection.left;

    if (leading > 0) _edge(canvas, size, leading, vertical, atStart: !flipped);
    if (trailing > 0) _edge(canvas, size, trailing, vertical, atStart: flipped);
  }

  void _edge(
    Canvas canvas,
    Size size,
    double strength,
    bool vertical, {
    required bool atStart,
  }) {
    final span = vertical ? size.width : size.height;
    final depth = vertical ? size.height : size.width;
    final reach = math.min(
      GlimmerOverscrollIndicator.bloomExtent * strength,
      depth / 2,
    );
    if (reach <= 0 || span <= 0) return;

    // The line opens from the middle outward rather than appearing all at once
    // along the whole edge. A full-width line arriving in one frame reads as a
    // border switching on; a line that grows from the point of contact reads as
    // the push landing somewhere.
    final half = (span / 2) * _openness(strength);
    final centre = span / 2;
    final from = centre - half;
    final to = centre + half;
    if (to - from <= 0) return;

    final near = atStart ? 0.0 : (vertical ? size.height : size.width) - reach;
    final band = vertical
        ? Rect.fromLTWH(from, near, to - from, reach)
        : Rect.fromLTWH(near, from, reach, to - from);

    final inward = vertical
        ? (atStart ? Alignment.topCenter : Alignment.bottomCenter)
        : (atStart ? Alignment.centerLeft : Alignment.centerRight);

    // The bloom falls away from the edge and also away from the middle, so the
    // light is brightest exactly where the line is being pushed.
    canvas
      ..save()
      ..clipRect(band)
      ..drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: inward,
            end: -inward,
            colors: [
              color.withValues(alpha: 0.32 * strength),
              const Color(0x00000000),
            ],
          ).createShader(band),
      )
      ..drawRect(
        band,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = LinearGradient(
            begin: vertical ? Alignment.centerLeft : Alignment.topCenter,
            end: vertical ? Alignment.centerRight : Alignment.bottomCenter,
            colors: const [
              Color(0x00000000),
              Color(0xFF000000),
              Color(0x00000000),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(band),
      )
      ..restore();

    // The line itself, tapering to nothing at both ends so it has no hard tips.
    final line = vertical
        ? Rect.fromLTWH(from, atStart ? 0 : size.height - 2, to - from, 2)
        : Rect.fromLTWH(atStart ? 0 : size.width - 2, from, 2, to - from);

    canvas.drawRect(
      line,
      Paint()
        ..shader = LinearGradient(
          begin: vertical ? Alignment.centerLeft : Alignment.topCenter,
          end: vertical ? Alignment.centerRight : Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0),
            Color.lerp(color, const Color(0xFFFFFFFF), 0.45)!
                .withValues(alpha: 0.95 * strength),
            color.withValues(alpha: 0),
          ],
          stops: const [0, 0.5, 1],
        ).createShader(line),
    );
  }

  /// How much of the edge the line covers at a given strength.
  ///
  /// It opens quickly and then keeps widening, so a small push already shows
  /// something and a hard one reaches the corners.
  static double _openness(double strength) =>
      math.min(1, 0.25 + (strength * 0.85));

  @override
  bool shouldRepaint(_GlimmerOverscrollPainter old) =>
      old.leading != leading ||
      old.trailing != trailing ||
      old.color != color ||
      old.axisDirection != axisDirection;
}
