import 'package:flutter/material.dart';

import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// A box that is either ticked or not.
///
/// The box is a [GlimmerSurface], so it carries the same lit edge, the same
/// focus treatment and the same flat press overlay as everything else, and the
/// tick is drawn on rather than faded in: the stroke is traced from one end to
/// the other on the focus curve, which is the same motion the edge uses when it
/// turns toward the focal colour.
///
/// Pass a [label] to get a row that is tappable along its whole width.
///
/// ```dart
/// GlimmerCheckbox(
///   value: subscribed,
///   label: 'Send me the weekly digest',
///   onChanged: (value) => setState(() => subscribed = value),
/// )
/// ```
class GlimmerCheckbox extends StatelessWidget {
  /// Creates a checkbox.
  const GlimmerCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.semanticLabel,
  });

  /// Whether the box is ticked.
  final bool value;

  /// Called with the new value. Null disables the checkbox.
  final ValueChanged<bool>? onChanged;

  /// An optional label drawn beside the box.
  final String? label;

  /// What a screen reader announces. Falls back to [label].
  final String? semanticLabel;

  /// The side of the box itself. The tap target around it is 48.
  static const boxSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final enabled = onChanged != null;

    final box = GlimmerSurface(
      borderRadius: tokens.shapes.small,
      padding: EdgeInsets.zero,
      focused: value,
      blur: 0,
      color: value ? colors.primary : colors.surface,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: SizedBox(
        width: boxSize,
        height: boxSize,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: value ? 1 : 0),
          duration: GlimmerMotion.modalDuration,
          curve: GlimmerMotion.focusCurve,
          builder: (context, progress, child) => CustomPaint(
            painter: _GlimmerTickPainter(
              progress: progress,
              color: colors.contentColorFor(colors.primary),
            ),
          ),
        ),
      ),
    );

    // The label is on screen, so the Text already carries it. Setting it here
    // as well makes a screen reader say it twice; semanticLabel replaces it
    // rather than adding to it.
    return Semantics(
      checked: value,
      enabled: enabled,
      label: semanticLabel,
      child: _SelectionRow(
        enabled: enabled,
        label: label,
        silentLabel: semanticLabel != null,
        onTap: enabled ? () => onChanged!(!value) : null,
        control: box,
      ),
    );
  }
}

/// One choice out of several.
///
/// The ring is a [GlimmerSurface] and the dot springs out of its centre on the
/// same spring a stack item snaps with, so choosing one reads like every other
/// selection in the kit rather than like a dot appearing.
///
/// ```dart
/// for (final size in Size.values)
///   GlimmerRadio<Size>(
///     value: size,
///     groupValue: chosen,
///     label: size.name,
///     onChanged: (value) => setState(() => chosen = value),
///   )
/// ```
class GlimmerRadio<T> extends StatelessWidget {
  /// Creates a radio button.
  const GlimmerRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    this.semanticLabel,
  });

  /// The value this button stands for.
  final T value;

  /// The value currently chosen in the group.
  final T? groupValue;

  /// Called with [value] when this button is chosen. Null disables it.
  final ValueChanged<T>? onChanged;

  /// An optional label drawn beside the ring.
  final String? label;

  /// What a screen reader announces. Falls back to [label].
  final String? semanticLabel;

  /// The outer diameter of the ring. The tap target around it is 48.
  static const ringSize = 24.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final enabled = onChanged != null;
    final selected = value == groupValue;

    final ring = GlimmerSurface(
      borderRadius: tokens.shapes.stadium,
      padding: EdgeInsets.zero,
      focused: selected,
      blur: 0,
      onTap: enabled ? () => onChanged!(value) : null,
      child: SizedBox(
        width: ringSize,
        height: ringSize,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: selected ? 1 : 0),
          duration: GlimmerMotion.modalDuration,
          curve: GlimmerMotion.focusCurve,
          builder: (context, progress, child) => CustomPaint(
            painter: _GlimmerDotPainter(
              progress: progress,
              color: colors.primary,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      enabled: enabled,
      label: semanticLabel,
      child: _SelectionRow(
        enabled: enabled,
        label: label,
        silentLabel: semanticLabel != null,
        onTap: enabled ? () => onChanged!(value) : null,
        control: ring,
      ),
    );
  }
}

/// The control, its label, and a 48 tap target around both.
class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.control,
    required this.enabled,
    this.label,
    this.onTap,
    this.silentLabel = false,
  });

  final Widget control;
  final bool enabled;
  final String? label;
  final VoidCallback? onTap;

  /// Whether the visible label is kept out of the semantics tree, because
  /// something above has already said it.
  final bool silentLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);

    Widget row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          control,
          if (label != null) ...[
            SizedBox(width: tokens.spacing.medium),
            Flexible(
              child: ExcludeSemantics(
                excluding: silentLabel,
                child: Text(label!, style: tokens.typography.bodyMedium),
              ),
            ),
          ],
        ],
      ),
    );

    if (label != null && onTap != null) {
      row = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: row,
      );
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.42,
      child: row,
    );
  }
}

/// Traces the tick from one end to the other rather than fading it in.
class _GlimmerTickPainter extends CustomPainter {
  const _GlimmerTickPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.52)
      ..lineTo(size.width * 0.43, size.height * 0.71)
      ..lineTo(size.width * 0.77, size.height * 0.31);

    final drawn = Path();
    for (final metric in path.computeMetrics()) {
      drawn.addPath(
        metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0)),
        Offset.zero,
      );
    }

    canvas.drawPath(
      drawn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_GlimmerTickPainter old) =>
      old.progress != progress || old.color != color;
}

/// Grows the dot out of the centre of the ring.
class _GlimmerDotPainter extends CustomPainter {
  const _GlimmerDotPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final centre = size.center(Offset.zero);
    final radius = (size.shortestSide / 2 - 5) * progress.clamp(0.0, 1.0);
    if (radius <= 0) return;

    // A soft halo under the dot, the same way the slider's thumb glows while
    // it is held, so a chosen option reads as lit rather than as filled in.
    canvas
      ..drawCircle(
        centre,
        radius + 4,
        Paint()
          ..color = color.withValues(alpha: 0.28 * progress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawCircle(centre, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_GlimmerDotPainter old) =>
      old.progress != progress || old.color != color;
}

/// A row of choices with a lit marker that slides between them.
///
/// One surface holds every option, and the selection is a second, lit surface
/// that travels to whichever option was chosen on
/// [GlimmerMotion.settleSpring]. Material moves an underline and Cupertino
/// slides an opaque pill; this slides light, which is the movement the rest of
/// the kit is built from.
///
/// Use it as a segmented control or as a tab bar. It is the same control.
///
/// ```dart
/// GlimmerTabs(
///   labels: const ['All', 'Unread', 'Starred'],
///   selectedIndex: tab,
///   onChanged: (index) => setState(() => tab = index),
/// )
/// ```
class GlimmerTabs extends StatelessWidget {
  /// Creates a row of choices.
  const GlimmerTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.icons,
  }) : assert(labels.length > 1, 'A tab row needs at least two choices.');

  /// The label for each choice.
  final List<String> labels;

  /// An optional icon for each choice. Must be the same length as [labels].
  final List<IconData>? icons;

  /// Which choice is selected, counting from 0.
  final int selectedIndex;

  /// Called with the index that was tapped. Null disables the row.
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final enabled = onChanged != null;
    final selected = selectedIndex.clamp(0, labels.length - 1).toDouble();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.42,
      child: GlimmerSurface(
        borderRadius: tokens.shapes.stadium,
        padding: EdgeInsets.all(tokens.spacing.extraSmall),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final slot = constraints.maxWidth / labels.length;

            return TweenAnimationBuilder<double>(
              tween: Tween<double>(end: selected),
              duration: GlimmerMotion.focusExitDuration,
              curve: GlimmerMotion.focusCurve,
              builder: (context, position, child) {
                return Stack(
                  children: [
                    // The marker sits under the labels and never moves them,
                    // so the text stays put while the light travels.
                    Positioned(
                      left: slot * position,
                      top: 0,
                      bottom: 0,
                      width: slot,
                      child: GlimmerSurface(
                        focused: true,
                        blur: 0,
                        opacity: 0.4,
                        borderRadius: tokens.shapes.stadium,
                        padding: EdgeInsets.zero,
                        child: const SizedBox.expand(),
                      ),
                    ),
                    child!,
                  ],
                );
              },
              child: Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: Semantics(
                        selected: i == selectedIndex,
                        button: true,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: enabled ? () => onChanged!(i) : null,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: tokens.spacing.small,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (icons != null) ...[
                                  Icon(
                                    icons![i],
                                    size: tokens.iconSizes.small,
                                    color: i == selectedIndex
                                        ? colors.primary
                                        : colors.onSurface,
                                  ),
                                  SizedBox(width: tokens.spacing.extraSmall),
                                ],
                                Flexible(
                                  child: Text(
                                    labels[i],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        tokens.typography.titleSmall.copyWith(
                                      color: i == selectedIndex
                                          ? colors.primary
                                          : colors.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
