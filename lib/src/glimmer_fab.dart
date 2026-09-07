import 'package:flutter/material.dart';

import 'glimmer_surface.dart';
import 'glimmer_theme.dart';
import 'glimmer_tooltip.dart';

/// The one action on a screen that matters more than the rest.
///
/// Material lifts its floating button off the page with a shadow. There are no
/// shadows here, so it is lifted with light instead: the focal fill, the lit
/// edge every surface carries, and a soft bloom under it in the same colour.
/// That is the same trick the slider's thumb uses while it is held, at the size
/// of a button.
///
/// Pass a [label] for the extended shape, which is a stadium with the icon and
/// the label side by side. Leave it off for the round one.
///
/// ```dart
/// GlimmerFab(
///   icon: Icons.add,
///   label: 'Add an item',
///   onPressed: addItem,
/// )
/// ```
///
/// [GlimmerScaffold] has a slot for it, which keeps it clear of the navigation
/// strip and the gesture bar.
class GlimmerFab extends StatelessWidget {
  /// Creates a floating action button.
  const GlimmerFab({
    super.key,
    required this.icon,
    required this.onPressed,
    this.label,
    this.tooltip,
    this.color,
    this.prominent = true,
    this.enableAmbientPulse = false,
  });

  /// The glyph.
  final IconData icon;

  /// Called on tap. Null disables the button and dims it.
  final VoidCallback? onPressed;

  /// The label, which makes it the extended shape. Null leaves it round.
  final String? label;

  /// A tooltip, shown on hover or long press. Falls back to [label].
  final String? tooltip;

  /// Overrides the fill.
  final Color? color;

  /// Whether the button takes the focal fill. Off gives it a surface fill.
  final bool prominent;

  /// Runs the ambient sweep around the edge.
  ///
  /// Off by default even here. A permanently animating element costs battery
  /// and is a problem for anyone who has asked for reduced motion, so it is a
  /// decision rather than a default, even for the one action that matters.
  final bool enableAmbientPulse;

  /// The diameter of the round shape, and the height of the extended one.
  static const size = 56.0;

  /// How far the bloom under the button reaches.
  static const bloomExtent = 18.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final fill = color ?? (prominent ? colors.primary : colors.surface);
    final extended = label != null;
    final content = colors.contentColorFor(fill);

    Widget button = GlimmerSurface(
      onTap: onPressed,
      color: fill,
      enableAmbientPulse: enableAmbientPulse,
      borderRadius: tokens.shapes.stadium,
      padding: extended
          ? EdgeInsets.symmetric(horizontal: tokens.spacing.large)
          : EdgeInsets.zero,
      semanticLabel: label ?? tooltip,
      child: SizedBox(
        height: extended ? size : size,
        width: extended ? null : size,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: tokens.iconSizes.medium, color: content),
            if (extended) ...[
              SizedBox(width: tokens.spacing.small),
              Text(
                label!,
                style: tokens.typography.titleSmall.copyWith(color: content),
              ),
            ],
          ],
        ),
      ),
    );

    // The bloom sits behind the button and is what stands in for the shadow
    // every other system puts there. It is drawn outside the shape, so the
    // glass reads its backdrop rather than reading its own glow.
    button = CustomPaint(
      painter: _GlimmerFabBloom(
        radius: tokens.shapes.stadium,
        color: fill,
        opacity: onPressed == null ? 0 : 1,
      ),
      child: button,
    );

    button = AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: onPressed == null ? 0.42 : 1,
      child: button,
    );

    final message = tooltip ?? (extended ? null : label);
    return message == null
        ? button
        : GlimmerTooltip(message: message, child: button);
  }
}

/// The glow under a [GlimmerFab], clipped to outside its own shape.
class _GlimmerFabBloom extends CustomPainter {
  const _GlimmerFabBloom({
    required this.radius,
    required this.color,
    required this.opacity,
  });

  final BorderRadius radius;
  final Color color;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final rrect = radius.toRRect(Offset.zero & size);

    // Only outside the shape. A glass surface reads what is painted behind it,
    // so a glow left underneath is pulled into its own blur and the button
    // ends up wearing its own light.
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect((Offset.zero & size).inflate(GlimmerFab.bloomExtent * 2)),
      Path()..addRRect(rrect),
    );

    canvas
      ..save()
      ..clipPath(outside)
      ..drawRRect(
        rrect,
        Paint()
          ..color = color.withValues(alpha: 0.38 * opacity)
          ..maskFilter = const MaskFilter.blur(
            BlurStyle.normal,
            GlimmerFab.bloomExtent / 2,
          ),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_GlimmerFabBloom old) =>
      old.radius != radius || old.color != color || old.opacity != opacity;
}
