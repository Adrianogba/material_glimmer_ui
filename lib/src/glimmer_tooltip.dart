import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'glimmer_entrance.dart';
import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// A short label that appears beside a control on hover or long press.
///
/// The pill is a [GlimmerSurface] like everything else, so it is glass over
/// whatever it covers rather than a flat slab, and it arrives through
/// [GlimmerEntrance] rather than being faded, which a glass surface cannot
/// survive.
///
/// It goes above the control when there is room and below it otherwise, and it
/// is held inside the screen horizontally, so a tooltip on the last icon in a
/// row does not run off the edge.
///
/// [GlimmerIconButton] wraps one around itself when given a `tooltip`. Use this
/// directly for anything else that needs a label it cannot show inline.
///
/// ```dart
/// GlimmerTooltip(
///   message: 'Mute',
///   child: GlimmerIconButton(icon: Icons.mic_off, onPressed: mute),
/// )
/// ```
class GlimmerTooltip extends StatefulWidget {
  /// Wraps [child] in a tooltip showing [message].
  const GlimmerTooltip({
    super.key,
    required this.message,
    required this.child,
    this.waitDuration = const Duration(milliseconds: 400),
    this.showDuration = const Duration(milliseconds: 1800),
    this.verticalOffset = 8,
  });

  /// The label to show.
  final String message;

  /// The control the tooltip belongs to.
  final Widget child;

  /// How long a pointer has to rest on the control before the label appears.
  final Duration waitDuration;

  /// How long it stays up after a long press. Hover keeps it up instead.
  final Duration showDuration;

  /// The gap between the control and the pill.
  final double verticalOffset;

  @override
  State<GlimmerTooltip> createState() => _GlimmerTooltipState();
}

class _GlimmerTooltipState extends State<GlimmerTooltip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlimmerMotion.modalDuration,
  );

  OverlayEntry? _entry;
  Timer? _wait;
  Timer? _hide;

  @override
  void dispose() {
    _wait?.cancel();
    _hide?.cancel();
    _entry?.remove();
    _entry = null;
    _controller.dispose();
    super.dispose();
  }

  void _show() {
    _wait?.cancel();
    _hide?.cancel();
    if (_entry == null) {
      final overlay = Overlay.maybeOf(context);
      if (overlay == null) return;
      _entry = OverlayEntry(builder: _buildOverlay);
      overlay.insert(_entry!);
    }
    _controller.forward();
  }

  Future<void> _dismiss() async {
    _wait?.cancel();
    _hide?.cancel();
    if (_entry == null) return;
    await _controller.reverse();
    _entry?.remove();
    _entry = null;
  }

  void _scheduleShow() {
    _wait?.cancel();
    _wait = Timer(widget.waitDuration, _show);
  }

  void _onLongPress() {
    _show();
    _hide = Timer(widget.showDuration, _dismiss);
  }

  Widget _buildOverlay(BuildContext overlayContext) {
    final tokens = GlimmerTheme.of(context);
    final box = context.findRenderObject() as RenderBox?;
    final overlayBox = Overlay.maybeOf(context)?.context.findRenderObject();
    if (box == null || !box.hasSize || overlayBox is! RenderBox) {
      return const SizedBox.shrink();
    }

    final centre = box.localToGlobal(
      box.size.center(Offset.zero),
      ancestor: overlayBox,
    );

    // The overlay covers the notch and the gesture bar, so the pill has to be
    // kept out of them itself. A control in the top bar then puts its label
    // below itself rather than under the clock.
    final gap = tokens.spacing.small;
    final safe = MediaQuery.paddingOf(overlayContext);

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomSingleChildLayout(
          delegate: _GlimmerTooltipLayout(
            target: centre,
            // From the centre of the control to its edge, plus the gap.
            verticalOffset: (box.size.height / 2) + widget.verticalOffset,
            margin: EdgeInsets.fromLTRB(
              safe.left + gap,
              safe.top + gap,
              safe.right + gap,
              safe.bottom + gap,
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => GlimmerEntrance(
              progress: GlimmerMotion.focusCurve.transform(_controller.value),
              child: child!,
            ),
            child: GlimmerSurface(
              borderRadius: tokens.shapes.stadium,
              padding: EdgeInsets.symmetric(
                horizontal: tokens.spacing.medium,
                vertical: tokens.spacing.small,
              ),
              child: Text(
                widget.message,
                style: tokens.typography.caption,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: widget.message,
      child: MouseRegion(
        onEnter: (_) => _scheduleShow(),
        onExit: (_) => _dismiss(),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onLongPress: _onLongPress,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Puts the pill above its control, or below it when there is no room, and
/// keeps it inside the screen either way.
class _GlimmerTooltipLayout extends SingleChildLayoutDelegate {
  const _GlimmerTooltipLayout({
    required this.target,
    required this.verticalOffset,
    required this.margin,
  });

  /// The centre of the control, in overlay coordinates.
  final Offset target;

  /// From that centre to where the pill's near edge should sit.
  final double verticalOffset;

  /// The smallest gap left between the pill and the edge of the safe area.
  final EdgeInsets margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().copyWith(
            maxWidth: math.max(
              0,
              constraints.maxWidth - margin.horizontal,
            ),
          );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final fitsAbove =
        target.dy - verticalOffset - childSize.height >= margin.top;
    final y = fitsAbove
        ? target.dy - verticalOffset - childSize.height
        : target.dy + verticalOffset;

    double clamp(double value, double low, double high) =>
        value.clamp(low, math.max(low, high));

    return Offset(
      clamp(
        target.dx - (childSize.width / 2),
        margin.left,
        size.width - childSize.width - margin.right,
      ),
      clamp(
        y,
        margin.top,
        size.height - childSize.height - margin.bottom,
      ),
    );
  }

  @override
  bool shouldRelayout(_GlimmerTooltipLayout oldDelegate) =>
      oldDelegate.target != target ||
      oldDelegate.verticalOffset != verticalOffset ||
      oldDelegate.margin != margin;
}
