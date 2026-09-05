import 'dart:math' as math;
import 'dart:ui' as ui show ImageFilter;

import 'package:flutter/material.dart';

import 'glimmer_theme.dart';

/// A horizontally paging view, one page at a time.
///
/// Pages do not simply slide. As a page leaves the centre it shortens, blurs
/// and fades, so the one arriving reads as the only thing being looked at. The
/// three effects have different falloffs, which is what stops the transition
/// feeling like a single crossfade: the scale finishes first, then the blur,
/// while the alpha runs the whole way.
///
/// Every value here is the published one. A page centred exactly gets no
/// transform at all, which matters on a phone: a scale, a blur or an opacity
/// forces the page into its own layer, and a [GlimmerSurface] inside it would
/// have no backdrop left to read. Upstream skips the effects at rest for its
/// own reasons and it happens to be exactly what is needed here.
///
/// ```dart
/// GlimmerPager(
///   itemCount: 3,
///   itemBuilder: (context, page) => GlimmerCard(title: 'Page $page'),
/// )
/// ```
class GlimmerPager extends StatefulWidget {
  /// Creates a Glimmer pager.
  const GlimmerPager({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.pageSpacing = 0,
    this.showPageIndicator = true,
    this.edgeScrim = true,
    this.userScrollEnabled = true,
  });

  /// How many pages there are.
  final int itemCount;

  /// Builds the page at a given index.
  final IndexedWidgetBuilder itemBuilder;

  /// An external controller, when the caller needs to drive the pager.
  final PageController? controller;

  /// Called when the settled page changes.
  final ValueChanged<int>? onPageChanged;

  /// The gap between pages.
  final double pageSpacing;

  /// Whether to draw the dot indicator under the pages.
  final bool showPageIndicator;

  /// Whether to erase the content toward the left and right edges while a page
  /// transition is in progress.
  ///
  /// The erase needs its own layer, so it is applied only while a transition is
  /// actually running. At rest there is no layer and a glass surface inside a
  /// page keeps its backdrop.
  final bool edgeScrim;

  /// Whether the user can swipe between pages.
  final bool userScrollEnabled;

  @override
  State<GlimmerPager> createState() => _GlimmerPagerState();
}

class _GlimmerPagerState extends State<GlimmerPager> {
  // The edge scrim wraps and unwraps the pager as a transition starts and
  // ends. Without a key that reparenting would remount the PageView and throw
  // its scroll position away mid-swipe.
  final _pagesKey = GlobalKey();
  PageController? _internalController;
  var _position = 0.0;

  PageController get _controller =>
      widget.controller ?? (_internalController ??= PageController());

  @override
  void initState() {
    super.initState();
    _position = _controller.initialPage.toDouble();
    _controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant GlimmerPager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      _controller.addListener(_onScroll);
    }
  }

  void _onScroll() {
    // page throws when the controller has no position yet, and reads as null
    // before the viewport has been measured.
    if (!_controller.hasClients) return;
    if (!_controller.position.hasContentDimensions) return;
    final page = _controller.page;
    if (page == null || page == _position) return;
    setState(() => _position = page);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _internalController?.dispose();
    super.dispose();
  }

  /// How far through a transition the pager is, from 0 at one page to 1 at the
  /// next. The edge scrim and the indicator both key off this.
  double get _transitionProgress {
    final fraction = _position - _position.floorToDouble();
    return fraction;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);

    final pages = PageView.builder(
      key: _pagesKey,
      controller: _controller,
      itemCount: widget.itemCount,
      onPageChanged: widget.onPageChanged,
      physics: widget.userScrollEnabled
          ? null
          : const NeverScrollableScrollPhysics(),
      padEnds: false,
      itemBuilder: (context, page) {
        final distance = (_position - page).abs().clamp(0.0, 1.0);
        var child = widget.itemBuilder(context, page);

        if (widget.pageSpacing > 0) {
          child = Padding(
            padding: EdgeInsets.symmetric(horizontal: widget.pageSpacing / 2),
            child: child,
          );
        }

        // A page sitting exactly at the centre is placed with no layer of any
        // kind, so glass inside it still works. Everything below only happens
        // while a transition is running.
        if (distance == 0) return child;

        final scale = _lerp(
          1,
          GlimmerPagerDefaults.minScale,
          (distance / GlimmerPagerDefaults.scaleProgressThreshold)
              .clamp(0.0, 1.0),
        );
        final blur = _lerp(
          0,
          GlimmerPagerDefaults.maxBlurRadius,
          (distance / GlimmerPagerDefaults.blurProgressThreshold)
              .clamp(0.0, 1.0),
        );

        if (blur > 0.05) {
          child = ImageFiltered(
            imageFilter: ui.ImageFilter.blur(
              sigmaX: blur,
              sigmaY: blur,
              tileMode: TileMode.decal,
            ),
            child: child,
          );
        }

        return Opacity(
          opacity: 1 - distance,
          child: Transform(
            // The page shortens toward its own bottom edge rather than its
            // centre, so a column of content appears to settle rather than to
            // shrink away from under itself.
            alignment: Alignment.bottomCenter,
            transform: Matrix4.diagonal3Values(1, scale, 1),
            child: child,
          ),
        );
      },
    );

    final scrimAlpha = widget.edgeScrim
        ? GlimmerPagerDefaults.edgeScrimAlpha(_transitionProgress)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: scrimAlpha <= 0
              ? pages
              : ShaderMask(
                  blendMode: BlendMode.dstOut,
                  shaderCallback: (bounds) {
                    final edge = bounds.width <= 0
                        ? 0.0
                        : (GlimmerPagerDefaults.edgeScrimSize / bounds.width)
                            .clamp(0.0, 0.5);
                    final black = const Color(
                      0xFF000000,
                    ).withValues(alpha: scrimAlpha);
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        black,
                        const Color(0x00000000),
                        const Color(0x00000000),
                        black,
                      ],
                      stops: [0, edge, 1 - edge, 1],
                    ).createShader(bounds);
                  },
                  child: pages,
                ),
        ),
        if (widget.showPageIndicator) ...[
          SizedBox(height: tokens.spacing.large),
          GlimmerPageIndicator(
            position: _position,
            pageCount: widget.itemCount,
          ),
        ],
      ],
    );
  }

  static double _lerp(double a, double b, double t) => a + ((b - a) * t);
}

/// The published values a [GlimmerPager] is built from.
class GlimmerPagerDefaults {
  const GlimmerPagerDefaults._();

  /// The shortest a page gets as it leaves the centre.
  static const minScale = 0.9;

  /// How far through the transition the scale reaches [minScale].
  static const scaleProgressThreshold = 0.69;

  /// How far through the transition the blur reaches [maxBlurRadius].
  static const blurProgressThreshold = 0.82;

  /// The strongest blur applied to a page leaving the centre.
  static const maxBlurRadius = 2.0;

  /// How far the erase reaches in from each edge.
  static const edgeScrimSize = 50.0;

  /// The alpha of the unselected indicator dots.
  static const unselectedIndicatorAlpha = 0.3;

  /// The strength of the edge erase at a given point in a transition.
  ///
  /// It is deliberately absent at both ends and full through the middle, so the
  /// edges only soften while a page is actually moving. The envelope is
  /// symmetric, so a swipe looks the same in both directions.
  static double edgeScrimAlpha(double transitionProgress) {
    final t = transitionProgress;
    if (t <= 0.05 || t > 0.95) return 0;
    if (t <= 0.35) return (t - 0.05) / 0.3;
    if (t <= 0.65) return 1;
    return 1 - ((t - 0.65) / 0.3);
  }
}

/// The dot indicator under a [GlimmerPager].
///
/// The selected page is not a larger dot but a rounded bar, and during a
/// transition it stretches from one dot toward the next and contracts onto it,
/// so the indicator reads as one thing moving rather than two dots swapping
/// brightness.
///
/// At most seven dots are shown. Beyond that the window slides and the dots at
/// its edges shrink, which says there is more on that side without turning the
/// indicator into a ruler.
class GlimmerPageIndicator extends StatelessWidget {
  /// Creates a page indicator.
  const GlimmerPageIndicator({
    super.key,
    required this.position,
    required this.pageCount,
    this.selectedColor,
    this.unselectedColor,
  });

  /// The pager's continuous position.
  final double position;

  /// How many pages there are.
  final int pageCount;

  /// The colour of the selected bar. Defaults to the content colour.
  final Color? selectedColor;

  /// The colour of the unselected dots. Defaults to [selectedColor] at
  /// [GlimmerPagerDefaults.unselectedIndicatorAlpha].
  final Color? unselectedColor;

  /// The most dots shown at once.
  static const maxIndicators = 7;

  /// How much smaller the dots at the edge of a sliding window are.
  static const edgeIndicatorSizeFraction = 8 / 12;

  /// Which dot the selected bar is sitting on at a given point in a transition.
  ///
  /// That one dot is not drawn underneath the bar. Every other dot is,
  /// including the one the bar is travelling toward: the bar reaches it as it
  /// lands, rather than the dot disappearing ahead of it.
  static int coveredDot(int currentPage, double transitionProgress) =>
      transitionProgress < 0.5 ? currentPage : currentPage + 1;

  @override
  Widget build(BuildContext context) {
    if (pageCount <= 1) return const SizedBox.shrink();
    final tokens = GlimmerTheme.of(context);
    final glasses = tokens.scale == GlimmerScale.glasses;

    // The published sizes are 6, 27 and 18. They follow the same two-thirds
    // rule as the rest of the geometry, since they are a visual measurement
    // rather than a touch target.
    final scale = glasses ? 1.0 : 2 / 3;
    final radius = 6 * scale;
    final centreToCentre = 27 * scale;
    final selectedThickness = 18 * scale;

    final selected = selectedColor ?? DefaultTextStyle.of(context).style.color;
    final base = selected ?? tokens.colors.onSurface;
    final visibleDots = math.min(maxIndicators, pageCount);

    return SizedBox(
      width: centreToCentre * (visibleDots - 1) + selectedThickness,
      height: selectedThickness,
      child: CustomPaint(
        painter: _PageIndicatorPainter(
          position: position,
          pageCount: pageCount,
          radius: radius,
          centreToCentre: centreToCentre,
          selectedThickness: selectedThickness,
          selectedColor: base,
          unselectedColor: unselectedColor ??
              base.withValues(
                alpha: GlimmerPagerDefaults.unselectedIndicatorAlpha,
              ),
        ),
      ),
    );
  }
}

class _PageIndicatorPainter extends CustomPainter {
  const _PageIndicatorPainter({
    required this.position,
    required this.pageCount,
    required this.radius,
    required this.centreToCentre,
    required this.selectedThickness,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final double position;
  final int pageCount;
  final double radius;
  final double centreToCentre;
  final double selectedThickness;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  void paint(Canvas canvas, Size size) {
    final visibleDots = math.min(GlimmerPageIndicator.maxIndicators, pageCount);
    if (visibleDots <= 0) return;

    final current = position.floor().clamp(0, pageCount - 1);
    final progress = position - position.floorToDouble();

    // With more pages than dots the window slides so the current page stays
    // one in from the end it is heading toward.
    var hiddenToTheLeft = 0;
    if (pageCount > GlimmerPageIndicator.maxIndicators) {
      hiddenToTheLeft =
          (current - visibleDots + 2).clamp(0, pageCount - visibleDots);
    }

    final y = size.height / 2;
    final left = (size.width - (centreToCentre * (visibleDots - 1))) / 2;

    final covered = GlimmerPageIndicator.coveredDot(current, progress);

    for (var slot = 0; slot < visibleDots; slot++) {
      final page = hiddenToTheLeft + slot;
      if (page == covered) continue;

      // A dot at the edge of a sliding window is drawn smaller, which reads as
      // "there is more this way" without adding another element.
      final atEdge = pageCount > GlimmerPageIndicator.maxIndicators &&
          (slot == 0 || slot == visibleDots - 1);
      canvas.drawCircle(
        Offset(left + (centreToCentre * slot), y),
        atEdge
            ? radius * GlimmerPageIndicator.edgeIndicatorSizeFraction
            : radius,
        Paint()..color = unselectedColor,
      );
    }

    // The selected bar contracts onto the current dot, stretches across the
    // gap, then contracts onto the next one. Weighting it this way keeps a
    // minimum length so it never disappears mid-travel.
    final startWeight = math.max(0.0, 1 - (progress * 2));
    final endWeight = math.max(0.0, (progress * 2) - 1);
    final barWeight = math.max(0.01, 1 - startWeight - endWeight);

    final slot = (current - hiddenToTheLeft).clamp(0, visibleDots - 1);
    final base = left + (centreToCentre * slot);
    final start = base + (centreToCentre * endWeight);
    final end = start + (centreToCentre * barWeight);

    canvas.drawLine(
      Offset(start, y),
      Offset(end, y),
      Paint()
        ..color = selectedColor
        ..strokeWidth = selectedThickness
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PageIndicatorPainter old) =>
      old.position != position ||
      old.pageCount != pageCount ||
      old.radius != radius ||
      old.centreToCentre != centreToCentre ||
      old.selectedThickness != selectedThickness ||
      old.selectedColor != selectedColor ||
      old.unselectedColor != unselectedColor;
}
