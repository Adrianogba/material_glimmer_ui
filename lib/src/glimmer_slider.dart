import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'glimmer_motion.dart';
import 'glimmer_theme.dart';

/// A value chosen along a track.
///
/// A thin track with a round thumb, shaped after a media scrubber rather than
/// after Material's slider.
///
/// The differences from Material's are the same ones that run through the rest
/// of this kit. There is no ripple and no value bubble. The thumb
/// carries the surface states instead: a lit edge at rest, the focal colour and
/// depth while it is held, and the white press overlay at 16%. Dragging uses
/// the press springs, and letting go settles on the same spring a stack item
/// snaps with.
class GlimmerSlider extends StatefulWidget {
  /// Creates a slider.
  const GlimmerSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.semanticLabel,
  }) : assert(max > min, 'max has to be greater than min.');

  /// The current value.
  final double value;

  /// Called as the value changes. Null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called once, when the drag ends.
  final ValueChanged<double>? onChangeEnd;

  /// The lowest value.
  final double min;

  /// The highest value.
  final double max;

  /// How many steps to snap to. Null slides continuously.
  final int? divisions;

  /// The accessibility label.
  final String? semanticLabel;

  /// The track's thickness.
  static const trackHeight = 8.0;

  /// The thumb's diameter at rest.
  static const thumbSize = 22.0;

  /// How much the thumb grows while it is held.
  static const heldThumbScale = 1.18;

  @override
  State<GlimmerSlider> createState() => _GlimmerSliderState();
}

class _GlimmerSliderState extends State<GlimmerSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _held = AnimationController.unbounded(
    vsync: this,
  )..addListener(_repaint);
  var _dragging = false;

  void _repaint() => setState(() {});

  @override
  void dispose() {
    _held.dispose();
    super.dispose();
  }

  double get _fraction =>
      ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  void _setHeld(bool held) {
    _dragging = held;
    _held.animateWith(
      SpringSimulation(
        held ? GlimmerMotion.pressEnterSpring : GlimmerMotion.settleSpring,
        _held.value,
        held ? 1 : 0,
        0,
      ),
    );
  }

  double _valueAt(double dx, double width) {
    final usable = width - GlimmerSlider.thumbSize;
    if (usable <= 0) return widget.min;
    var fraction =
        ((dx - (GlimmerSlider.thumbSize / 2)) / usable).clamp(0.0, 1.0);
    if (widget.divisions != null && widget.divisions! > 0) {
      fraction = (fraction * widget.divisions!).round() / widget.divisions!;
    }
    return widget.min + (fraction * (widget.max - widget.min));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final enabled = widget.onChanged != null;

    return Semantics(
      slider: true,
      label: widget.semanticLabel,
      value: '${(_fraction * 100).round()}%',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          void report(Offset local) {
            if (!enabled) return;
            widget.onChanged!(_valueAt(local.dx, width));
          }

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: enabled ? 1 : 0.42,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (!enabled) return;
                _setHeld(true);
                report(details.localPosition);
              },
              onTapUp: (_) {
                if (!enabled) return;
                _setHeld(false);
                widget.onChangeEnd?.call(widget.value);
              },
              onTapCancel: () => _setHeld(false),
              onHorizontalDragStart: (details) {
                if (!enabled) return;
                _setHeld(true);
                report(details.localPosition);
              },
              onHorizontalDragUpdate: (details) =>
                  report(details.localPosition),
              onHorizontalDragEnd: (_) {
                if (!enabled) return;
                _setHeld(false);
                widget.onChangeEnd?.call(widget.value);
              },
              onHorizontalDragCancel: () => _setHeld(false),
              child: SizedBox(
                height: GlimmerSlider.thumbSize * GlimmerSlider.heldThumbScale,
                width: double.infinity,
                child: CustomPaint(
                  painter: _GlimmerSliderPainter(
                    fraction: _fraction,
                    held: _held.value.clamp(0.0, 1.0),
                    pressed: _dragging,
                    track: colors.surface,
                    active: colors.primary,
                    edge: colors.outline,
                    tint: colors.highlightTint,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GlimmerSliderPainter extends CustomPainter {
  const _GlimmerSliderPainter({
    required this.tint,
    required this.fraction,
    required this.held,
    required this.pressed,
    required this.track,
    required this.active,
    required this.edge,
  });

  final double fraction;
  final double held;
  final bool pressed;
  final Color track;
  final Color active;
  final Color edge;

  /// Which way contrast runs on this ground. See
  /// [GlimmerColors.highlightTint]. The shine across the thumb stays white
  /// either way, because it sits on a saturated fill rather than on the page;
  /// the press flash does not, because a white flash on a light ground is
  /// nothing happening.
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final thumbSize = GlimmerSlider.thumbSize *
        (1 + ((GlimmerSlider.heldThumbScale - 1) * held));
    final usable = size.width - GlimmerSlider.thumbSize;
    final centreX = (GlimmerSlider.thumbSize / 2) + (usable * fraction);
    final centreY = size.height / 2;

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        centreY - (GlimmerSlider.trackHeight / 2),
        size.width,
        GlimmerSlider.trackHeight,
      ),
      const Radius.circular(999),
    );

    // The inactive track, and the same lit edge every other surface carries so
    // the track reads as part of the system rather than as a plain bar.
    canvas
      ..drawRRect(trackRect, Paint()..color = track)
      ..drawRRect(
        trackRect.deflate(0.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = GlimmerMotion.borderWidth
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              edge.withValues(alpha: 0.85),
              edge.withValues(alpha: 0.2),
            ],
          ).createShader(trackRect.outerRect),
      );

    // The filled portion.
    if (fraction > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            centreY - (GlimmerSlider.trackHeight / 2),
            centreX,
            GlimmerSlider.trackHeight,
          ),
          const Radius.circular(999),
        ),
        Paint()..color = active,
      );
    }

    // The thumb takes the focal colour and lifts as it is held, which is the
    // surface focus treatment applied to a circle.
    final centre = Offset(centreX, centreY);
    if (held > 0) {
      canvas.drawCircle(
        centre,
        (thumbSize / 2) + (10 * held),
        Paint()
          ..color = active.withValues(alpha: 0.22 * held)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    canvas
      ..drawCircle(centre, thumbSize / 2, Paint()..color = active)
      ..drawCircle(
        centre,
        (thumbSize / 2) - (GlimmerMotion.borderWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = GlimmerMotion.borderWidth
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFFFFFFF).withValues(alpha: 0.75),
              const Color(0x00FFFFFF),
            ],
          ).createShader(
            Rect.fromCircle(center: centre, radius: thumbSize / 2),
          ),
      );

    if (pressed) {
      canvas.drawCircle(
        centre,
        thumbSize / 2,
        Paint()
          ..color = tint.withValues(
            alpha: GlimmerMotion.pressedOverlayOpacity *
                (tint.computeLuminance() > 0.5 ? 1 : 0.7),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_GlimmerSliderPainter old) =>
      old.fraction != fraction ||
      old.held != held ||
      old.pressed != pressed ||
      old.track != track ||
      old.active != active ||
      old.edge != edge ||
      old.tint != tint;
}
