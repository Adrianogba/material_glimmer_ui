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
/// [GlimmerScrollBehavior] installs it, so an app using [GlimmerApp] gets it
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
    final span = vertical ? size.height : size.width;
    final reach = math.min(
      GlimmerOverscrollIndicator.bloomExtent * strength,
      span / 2,
    );
    if (reach <= 0) return;

    final rect = vertical
        ? (atStart
            ? Rect.fromLTWH(0, 0, size.width, reach)
            : Rect.fromLTWH(0, size.height - reach, size.width, reach))
        : (atStart
            ? Rect.fromLTWH(0, 0, reach, size.height)
            : Rect.fromLTWH(size.width - reach, 0, reach, size.height));

    final from = vertical
        ? (atStart ? Alignment.topCenter : Alignment.bottomCenter)
        : (atStart ? Alignment.centerLeft : Alignment.centerRight);

    // The bloom, falling away from the edge.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: from,
          end: -from,
          colors: [
            color.withValues(alpha: 0.28 * strength),
            const Color(0x00000000),
          ],
        ).createShader(rect),
    );

    // The line at the boundary itself, which is what makes it read as an edge
    // rather than as a wash.
    final line = vertical
        ? (atStart
            ? Rect.fromLTWH(0, 0, size.width, 2)
            : Rect.fromLTWH(0, size.height - 2, size.width, 2))
        : (atStart
            ? Rect.fromLTWH(0, 0, 2, size.height)
            : Rect.fromLTWH(size.width - 2, 0, 2, size.height));

    canvas.drawRect(
      line,
      Paint()
        ..color = Color.lerp(color, const Color(0xFFFFFFFF), 0.4)!
            .withValues(alpha: 0.9 * strength),
    );
  }

  @override
  bool shouldRepaint(_GlimmerOverscrollPainter old) =>
      old.leading != leading ||
      old.trailing != trailing ||
      old.color != color ||
      old.axisDirection != axisDirection;
}
