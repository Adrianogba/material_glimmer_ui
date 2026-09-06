import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'glimmer_motion.dart';
import 'glimmer_theme.dart';

/// A text field styled to match Glimmer.
///
/// A Material `TextField` dropped into a Glimmer screen brings a filled or
/// underlined decoration that belongs to a different system, so this is a
/// border-led field built from the Glimmer tokens: the resting outline, the
/// focal colour on focus, and the same border widths as every other surface.
class GlimmerTextField extends StatefulWidget {
  /// Creates a Glimmer text field.
  const GlimmerTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  /// An external controller for the field's text.
  final TextEditingController? controller;

  /// The floating label.
  final String? label;

  /// Placeholder text shown while the field is empty.
  final String? hint;

  /// An icon at the start of the field.
  final IconData? prefixIcon;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Whether to hide the text, for passwords.
  final bool obscureText;

  /// Which keyboard to show.
  final TextInputType? keyboardType;

  /// How many lines the field may grow to.
  final int? maxLines;

  @override
  State<GlimmerTextField> createState() => _GlimmerTextFieldState();
}

class _GlimmerTextFieldState extends State<GlimmerTextField> {
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);
  var _focused = false;

  void _onFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: spacing.large),
      decoration: BoxDecoration(
        color: _focused
            ? Color.lerp(colors.surface, colors.primary, 0.12)
            : colors.surface,
        borderRadius: tokens.shapes.medium,
        border: Border.all(
          color: _focused ? colors.primary : colors.outline,
          width: _focused ? 2 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(
              widget.prefixIcon,
              size: tokens.iconSizes.small,
              color: _focused ? colors.primary : colors.outline,
            ),
            SizedBox(width: spacing.small),
          ],
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                cursorColor: colors.primary,
                style: tokens.typography.bodyMedium
                    .copyWith(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  isDense: true,
                  labelStyle: tokens.typography.bodySmall.copyWith(
                    color: _focused ? colors.primary : colors.outline,
                  ),
                  hintStyle: tokens.typography.bodySmall.copyWith(
                    color: colors.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: spacing.medium,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A switch styled to match Glimmer.
///
/// [GlimmerToggleButton] is the other way to say on and off, and it changes
/// colour rather than sliding a thumb. A settings screen usually wants the
/// sliding kind, so this is one drawn from the same tokens: the track is a
/// surface, the thumb takes the focal colour, and there is no ripple.
class GlimmerSwitch extends StatelessWidget {
  /// Creates a Glimmer switch.
  const GlimmerSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value on tap. When null the switch is disabled.
  final ValueChanged<bool>? onChanged;

  /// The accessibility label.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);
    return Semantics(
      toggled: value,
      label: label,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: onChanged == null ? 0.42 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 58,
            height: 34,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: value ? colors.primary : colors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: value ? colors.primary : colors.outline,
                width: 1.5,
              ),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: value ? colors.onPrimary : colors.outline,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A progress bar drawn as a lit track.
///
/// Pass a [value] between 0 and 1 for determinate progress, or leave it null
/// for an indeterminate one.
///
/// The determinate bar is the slider's track without its thumb: the same
/// stadium shape, the same graded edge, and a fill in the focal colour with a
/// glow at its leading end so the bar reads as light arriving rather than as a
/// box growing.
///
/// The indeterminate bar does not slide a block along the track, which is how
/// every other system says "still working". A highlight travels the track and
/// tapers at both ends, the same light that runs around a surface's edge during
/// the ambient sweep, so waiting looks like the rest of the language.
class GlimmerProgressBar extends StatefulWidget {
  /// Creates a progress bar.
  const GlimmerProgressBar({super.key, this.value, this.height = 8});

  /// Progress between 0 and 1, or null for indeterminate.
  final double? value;

  /// The bar's thickness.
  final double height;

  /// How long the indeterminate highlight takes to cross the track once.
  static const sweepDuration = Duration(milliseconds: 1400);

  @override
  State<GlimmerProgressBar> createState() => _GlimmerProgressBarState();
}

class _GlimmerProgressBarState extends State<GlimmerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: GlimmerProgressBar.sweepDuration,
  );

  @override
  void initState() {
    super.initState();
    _syncSweep();
  }

  @override
  void didUpdateWidget(GlimmerProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSweep();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  void _syncSweep() {
    if (widget.value == null) {
      if (!_sweep.isAnimating) _sweep.repeat();
    } else if (_sweep.isAnimating) {
      _sweep.stop();
      _sweep.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final value = widget.value;

    return Semantics(
      value: value == null ? null : '${(value * 100).round()}%',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, child) => CustomPaint(
            painter: _GlimmerProgressPainter(
              value: value,
              sweep: _sweep.value,
              track: colors.surface,
              active: colors.primary,
              edge: colors.outline,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlimmerProgressPainter extends CustomPainter {
  const _GlimmerProgressPainter({
    required this.value,
    required this.sweep,
    required this.track,
    required this.active,
    required this.edge,
  });

  final double? value;
  final double sweep;
  final Color track;
  final Color active;
  final Color edge;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(999));

    // The same track and graded edge the slider carries, so a bar in a list of
    // surfaces reads as part of the system rather than as a plain rule.
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRRect(rrect, Paint()..color = track);

    final progress = value;
    if (progress == null) {
      _sweepHighlight(canvas, size);
    } else if (progress > 0) {
      _fill(canvas, size, progress.clamp(0.0, 1.0));
    }

    canvas
      ..restore()
      ..drawRRect(
        rrect.deflate(0.75),
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
          ).createShader(rect),
      );
  }

  void _fill(Canvas canvas, Size size, double progress) {
    final width = size.width * progress;
    final filled = Rect.fromLTWH(0, 0, width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(filled, const Radius.circular(999)),
      Paint()..color = active,
    );

    // A glow at the leading end, so the bar reads as light reaching a point
    // rather than as a rectangle that happens to stop there.
    final reach = math.min(size.height * 3, width);
    if (reach <= 0) return;
    canvas.drawRect(
      Rect.fromLTWH(width - reach, 0, reach, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            active.withValues(alpha: 0),
            Color.lerp(active, const Color(0xFFFFFFFF), 0.5)!
                .withValues(alpha: 0.9),
          ],
        ).createShader(Rect.fromLTWH(width - reach, 0, reach, size.height)),
    );
  }

  void _sweepHighlight(Canvas canvas, Size size) {
    // The highlight is wider than a block and tapers to nothing at both ends,
    // which is what makes it read as light passing rather than as an object
    // sliding. It starts fully off one end and finishes fully off the other.
    final span = size.width * 0.42;
    final travel = size.width + span;
    final centre = (-span / 2) + (travel * sweep);
    final band = Rect.fromLTWH(centre - (span / 2), 0, span, size.height);
    if (band.width <= 0) return;

    canvas.drawRect(
      band,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            active.withValues(alpha: 0),
            active,
            Color.lerp(active, const Color(0xFFFFFFFF), 0.45)!,
            active,
            active.withValues(alpha: 0),
          ],
          stops: const [0, 0.32, 0.5, 0.68, 1],
        ).createShader(band),
    );
  }

  @override
  bool shouldRepaint(_GlimmerProgressPainter old) =>
      old.value != value ||
      old.sweep != sweep ||
      old.track != track ||
      old.active != active ||
      old.edge != edge;
}
