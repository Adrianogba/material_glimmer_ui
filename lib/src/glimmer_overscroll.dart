import 'dart:async';
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
  /// Whether a [GlimmerRefreshIndicator] is already lighting the leading edge.
  ///
  /// Both of them draw the same light on the same edge, so inside one of them
  /// this leaves the leading edge alone. Two lights on one edge read as one
  /// fast glow followed by a slower one rather than as a single push.
  var _refreshOwnsLeading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshOwnsLeading = _GlimmerRefreshScope.of(context);
  }

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
        if (_refreshOwnsLeading) return false;
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
          tint: colors.highlightTint,
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
    required this.tint,
    required this.leading,
    required this.trailing,
  });

  final AxisDirection axisDirection;
  final Color color;

  /// Which way contrast runs on this ground. See
  /// [GlimmerColors.highlightTint].
  final Color tint;
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
    // saveLayer, not save. The mask below composes with BlendMode.dstIn, and
    // on the bare canvas that would take the alpha out of everything already
    // painted under the bloom rather than out of the bloom itself, leaving a
    // black band across the top of the page.
    canvas
      ..saveLayer(band, Paint())
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
            Color.lerp(color, tint, 0.45)!.withValues(alpha: 0.95 * strength),
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
      old.tint != tint ||
      old.axisDirection != axisDirection;
}

/// Pull past the top of a list to refresh it.
///
/// Material spins a circle on a card that slides down over the content, and
/// Cupertino drops a spinner into a gap it opens above it. Both move something,
/// and this kit does not move content: the same edge light
/// [GlimmerOverscrollIndicator] uses says how far the pull has gone, reaches
/// full brightness at [triggerDistance], and then breathes on the ambient
/// envelope while the refresh runs.
///
/// So the whole gesture is one continuous piece of light. Pushing a list that
/// cannot refresh lights the edge and lets go; pushing one that can lights the
/// edge, holds, and pulses until the work is done.
///
/// Wrap the scrollable, the way you would wrap it in a `RefreshIndicator`:
///
/// ```dart
/// GlimmerRefreshIndicator(
///   onRefresh: () => model.reload(),
///   child: GlimmerList(children: rows),
/// )
/// ```
///
/// The scrollable needs to reach its edge for a pull to register, so give it
/// [AlwaysScrollableScrollPhysics] if it might hold less than one screen.
class GlimmerRefreshIndicator extends StatefulWidget {
  /// Creates a refresh indicator around [child].
  const GlimmerRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
  });

  /// The scrollable being wrapped.
  final Widget child;

  /// Called once the pull passes [triggerDistance] and the finger lifts.
  ///
  /// The edge holds and pulses until the returned future completes.
  final Future<void> Function() onRefresh;

  /// The colour of the light. Defaults to [GlimmerColors.primary].
  final Color? color;

  /// How far the list has to be pulled to arm a refresh.
  ///
  /// Shorter than [GlimmerOverscrollIndicator.pullDistance], so a pull that
  /// arms one is a deliberate gesture rather than the end of a fling.
  static const triggerDistance = 120.0;

  /// The floor the light holds at while the refresh runs.
  ///
  /// It breathes between this and full on [GlimmerMotion.ambientEnvelope], so
  /// a list that is working never looks like a list that has simply stopped.
  static const workingFloor = 0.55;

  @override
  State<GlimmerRefreshIndicator> createState() =>
      _GlimmerRefreshIndicatorState();
}

class _GlimmerRefreshIndicatorState extends State<GlimmerRefreshIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _pull = AnimationController.unbounded(
    vsync: this,
  )..addListener(_repaint);
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: GlimmerMotion.ambientPulseDuration,
  )..addListener(_repaint);

  bool _armed = false;
  bool _refreshing = false;

  void _repaint() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pull.dispose();
    _pulse.dispose();
    super.dispose();
  }

  bool _onNotification(ScrollNotification notification) {
    if (notification.depth != 0 || _refreshing) return false;

    if (notification is OverscrollNotification) {
      // Only the leading edge arms a refresh. Running off the bottom of a list
      // is a different gesture with a different meaning.
      if (notification.overscroll >= 0) return false;
      _pull
        ..stop()
        ..value = (_pull.value +
                (-notification.overscroll /
                    GlimmerRefreshIndicator.triggerDistance))
            .clamp(0.0, 1.0);
      // The edge lights for any overscroll, but only a finger still on the
      // screen arms a refresh. A fling that runs off the top is the list
      // stopping, not a request to reload, and treating it as one is what puts
      // a second slower glow on the edge after the first.
      if (notification.dragDetails != null && _pull.value >= 1) _armed = true;
    } else if (notification is ScrollEndNotification) {
      if (_armed) {
        unawaited(_run());
      } else {
        _settle();
      }
    }
    return false;
  }

  void _settle() {
    _armed = false;
    if (_pull.value == 0) return;
    _pull.animateWith(
      SpringSimulation(GlimmerMotion.settleSpring, _pull.value, 0, 0),
    );
  }

  Future<void> _run() async {
    _armed = false;
    _refreshing = true;
    _pull
      ..stop()
      ..value = 1;
    _pulse.repeat();
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _pulse.stop();
        _pulse.value = 0;
        _refreshing = false;
        _settle();
      }
    }
  }

  /// How bright the edge is right now.
  double get _strength {
    if (!_refreshing) return _pull.value.clamp(0.0, 1.0);
    const floor = GlimmerRefreshIndicator.workingFloor;
    return floor + ((1 - floor) * GlimmerMotion.ambientEnvelope(_pulse.value));
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);

    return _GlimmerRefreshScope(
      child: NotificationListener<ScrollNotification>(
        onNotification: _onNotification,
        child: CustomPaint(
          foregroundPainter: _GlimmerOverscrollPainter(
            axisDirection: AxisDirection.down,
            color: widget.color ?? colors.primary,
            tint: colors.highlightTint,
            leading: _strength,
            trailing: 0,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Marks the subtree of a [GlimmerRefreshIndicator].
///
/// [GlimmerOverscrollIndicator] reads it and leaves the leading edge alone, so
/// only one of them lights it.
class _GlimmerRefreshScope extends InheritedWidget {
  const _GlimmerRefreshScope({required super.child});

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_GlimmerRefreshScope>() !=
      null;

  @override
  bool updateShouldNotify(_GlimmerRefreshScope oldWidget) => false;
}
