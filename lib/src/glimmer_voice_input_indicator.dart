import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'glimmer_theme.dart';

/// The three-bar indicator Glimmer shows while it is listening.
///
/// It rests as three dots and rises into bars while [listening] is true, the
/// centre bar reaching further than the two beside it. Glimmer's version is
/// driven by the microphone; this one animates on its own, because a Flutter
/// package has no business reaching for a microphone. Pass [amplitude] to drive
/// it from real audio if you have it.
///
/// Glimmer's numbers are used verbatim: a 32 container, 6 dots, a centre bar
/// reaching five times the dot size, side bars 4.2 shorter, and 3 between them.
class GlimmerVoiceInputIndicator extends StatefulWidget {
  /// Creates a voice input indicator.
  const GlimmerVoiceInputIndicator({
    super.key,
    this.listening = true,
    this.amplitude,
    this.color,
    this.size = 32,
    this.semanticLabel = 'Listening',
  });

  /// Whether to animate. When false the indicator settles to three dots.
  final bool listening;

  /// A live level between 0 and 1. When null the indicator animates itself.
  final double? amplitude;

  /// The bar colour. Defaults to [GlimmerColors.primary].
  final Color? color;

  /// The container size. Glimmer's is 32.
  final double size;

  /// The accessibility label.
  final String? semanticLabel;

  @override
  State<GlimmerVoiceInputIndicator> createState() =>
      _GlimmerVoiceInputIndicatorState();
}

class _GlimmerVoiceInputIndicatorState extends State<GlimmerVoiceInputIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(covariant GlimmerVoiceInputIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listening != widget.listening ||
        oldWidget.amplitude != widget.amplitude) {
      _sync();
    }
  }

  void _sync() {
    if (widget.listening && widget.amplitude == null) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? GlimmerTheme.colorsOf(context).primary;
    final scale = widget.size / 32;

    return Semantics(
      label: widget.semanticLabel,
      liveRegion: widget.listening,
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final level = widget.amplitude?.clamp(0.0, 1.0) ??
                (widget.listening ? 1.0 : 0.0);
            return CustomPaint(
              painter: _VoiceInputPainter(
                color: color,
                scale: scale,
                centre: level * _wave(t, 0),
                left: level * _wave(t, 0.33),
                right: level * _wave(t, 0.66),
              ),
            );
          },
        ),
      ),
    );
  }

  /// A phase-shifted sine, clamped to the positive half so the bars settle back
  /// to dots rather than dipping below them.
  double _wave(double t, double phase) =>
      math.max(0, math.sin((t + phase) * 2 * math.pi));
}

class _VoiceInputPainter extends CustomPainter {
  const _VoiceInputPainter({
    required this.color,
    required this.scale,
    required this.centre,
    required this.left,
    required this.right,
  });

  final Color color;
  final double scale;
  final double centre;
  final double left;
  final double right;

  static const _dotSize = 6.0;
  static const _middleBarMaxHeight = _dotSize * 5;
  static const _sideBarHeightOffset = 4.2;
  static const _barSpacing = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final dot = _dotSize * scale;
    final spacing = _barSpacing * scale;
    final maxCentre = _middleBarMaxHeight * scale;
    final maxSide = maxCentre - (_sideBarHeightOffset * scale);
    final paint = Paint()..color = color;
    final centreX = size.width / 2;

    void bar(double x, double height) {
      final rect = Rect.fromCenter(
        center: Offset(x, size.height / 2),
        width: dot,
        height: height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(dot / 2)),
        paint,
      );
    }

    bar(centreX - dot - spacing, dot + (maxSide - dot) * left);
    bar(centreX, dot + (maxCentre - dot) * centre);
    bar(centreX + dot + spacing, dot + (maxSide - dot) * right);
  }

  @override
  bool shouldRepaint(_VoiceInputPainter old) =>
      old.color != color ||
      old.scale != scale ||
      old.centre != centre ||
      old.left != left ||
      old.right != right;
}
