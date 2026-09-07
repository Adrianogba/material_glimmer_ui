import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'glimmer_theme.dart';

/// A placeholder for content that has not arrived.
///
/// Every other system does this as a grey block with a lighter band sliding
/// across it. A grey block is the one thing a glass surface is not, so this is
/// the shape of the missing content drawn as light instead: a dim bar with a
/// highlight travelling it, the same highlight [GlimmerProgressBar] sends along
/// its track and the ambient sweep sends around an edge.
///
/// Give it the size of the thing that is coming, so the layout does not move
/// when the content lands.
///
/// ```dart
/// GlimmerSkeleton(width: 180, height: 16)
/// ```
///
/// For a block of them, [GlimmerSkeleton.lines] builds a paragraph with the
/// last line short, the way a paragraph actually ends.
class GlimmerSkeleton extends StatefulWidget {
  /// Creates a placeholder of a given size.
  const GlimmerSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  /// How wide the placeholder is. Null fills the space it is given.
  final double? width;

  /// How tall the placeholder is.
  final double height;

  /// The corner radius. Defaults to a stadium, which is what a line of text
  /// standing in for itself should look like.
  final BorderRadius? borderRadius;

  /// How long the highlight takes to cross once.
  static const sweepDuration = Duration(milliseconds: 1500);

  /// A stack of placeholder lines, with the last one short.
  static Widget lines({
    Key? key,
    int count = 3,
    double height = 14,
    double spacing = 10,
    double lastLineFraction = 0.55,
  }) {
    return _GlimmerSkeletonLines(
      key: key,
      count: count,
      height: height,
      spacing: spacing,
      lastLineFraction: lastLineFraction,
    );
  }

  @override
  State<GlimmerSkeleton> createState() => _GlimmerSkeletonState();
}

class _GlimmerSkeletonState extends State<GlimmerSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: GlimmerSkeleton.sweepDuration,
  )..repeat();

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;

    return ExcludeSemantics(
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, child) => CustomPaint(
            painter: _GlimmerSkeletonPainter(
              sweep: _sweep.value,
              radius: widget.borderRadius ??
                  BorderRadius.circular(widget.height / 2),
              // The surface colour on its own is the same tone as the card
              // a placeholder usually sits on, which on a light ground makes
              // the bars read as gaps rather than as shapes. A touch of the
              // outline separates them in both themes.
              base: Color.alphaBlend(
                colors.outline.withValues(alpha: 0.3),
                colors.surface,
              ),
              highlight: colors.outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlimmerSkeletonLines extends StatelessWidget {
  const _GlimmerSkeletonLines({
    super.key,
    required this.count,
    required this.height,
    required this.spacing,
    required this.lastLineFraction,
  });

  final int count;
  final double height;
  final double spacing;
  final double lastLineFraction;

  @override
  Widget build(BuildContext context) {
    return Column(
      // Stretch, not start: a placeholder has no intrinsic width, so a line
      // left to size itself would come out as nothing at all.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          if (i == count - 1)
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: lastLineFraction,
              child: GlimmerSkeleton(height: height),
            )
          else
            GlimmerSkeleton(height: height),
        ],
      ],
    );
  }
}

class _GlimmerSkeletonPainter extends CustomPainter {
  const _GlimmerSkeletonPainter({
    required this.sweep,
    required this.radius,
    required this.base,
    required this.highlight,
  });

  final double sweep;
  final BorderRadius radius;
  final Color base;
  final Color highlight;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);

    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRRect(rrect, Paint()..color = base);

    // The highlight is wider than the bar is tall and tapers at both ends, so
    // it reads as light passing over the shape rather than a block sliding
    // behind a window.
    final span = math.max(size.width * 0.45, size.height * 4);
    final travel = size.width + span;
    final centre = (-span / 2) + (travel * sweep);
    final band = Rect.fromLTWH(centre - (span / 2), 0, span, size.height);

    canvas
      ..drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              highlight.withValues(alpha: 0),
              highlight.withValues(alpha: 0.55),
              highlight.withValues(alpha: 0),
            ],
            stops: const [0, 0.5, 1],
          ).createShader(band),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlimmerSkeletonPainter old) =>
      old.sweep != sweep ||
      old.radius != radius ||
      old.base != base ||
      old.highlight != highlight;
}
