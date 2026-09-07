import 'package:flutter/material.dart';

import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// A small stadium-shaped control for a filter, a tag or a suggestion.
///
/// It is a [GlimmerSurface] at chip size, so selecting one is the focus
/// treatment rather than a fill swapping colour: the edge grows, turns toward
/// the focal colour and the tint brightens. Material's chip changes its
/// background and draws a tick; this one lights up.
///
/// [onDeleted] puts a close affordance at the end, which is what makes it an
/// input chip. Leave it off and it is a filter or a suggestion.
///
/// ```dart
/// GlimmerChip(
///   label: 'Open now',
///   selected: openOnly,
///   onPressed: () => setState(() => openOnly = !openOnly),
/// )
/// ```
class GlimmerChip extends StatelessWidget {
  /// Creates a chip.
  const GlimmerChip({
    super.key,
    required this.label,
    this.icon,
    this.avatar,
    this.selected = false,
    this.onPressed,
    this.onDeleted,
    this.deleteTooltip = 'Remove',
    this.color,
  });

  /// The chip's text.
  final String label;

  /// An icon at the start, behind [avatar] if both are given.
  final IconData? icon;

  /// A widget at the start, taking priority over [icon].
  final Widget? avatar;

  /// Whether the chip is selected. Selection uses the focus treatment.
  final bool selected;

  /// Called on tap. Null makes the chip a label rather than a control.
  final VoidCallback? onPressed;

  /// Called when the close affordance is tapped. Null leaves it off.
  final VoidCallback? onDeleted;

  /// What a screen reader announces for the close affordance.
  final String deleteTooltip;

  /// Overrides the fill.
  final Color? color;

  /// The smallest a chip gets. Below this it stops being a touch target.
  static const minHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final leading = avatar ??
        (icon == null ? null : Icon(icon, size: tokens.iconSizes.small));

    return GlimmerSurface(
      focused: selected,
      onTap: onPressed,
      color: color,
      borderRadius: tokens.shapes.stadium,
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.medium,
        vertical: tokens.spacing.extraSmall,
      ),
      semanticLabel: onPressed == null ? null : label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: minHeight - 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[
              leading,
              SizedBox(width: tokens.spacing.extraSmall),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tokens.typography.bodySmall.copyWith(
                  color: selected ? colors.primary : colors.onSurface,
                ),
              ),
            ),
            if (onDeleted != null) ...[
              SizedBox(width: tokens.spacing.extraSmall),
              Semantics(
                button: true,
                label: deleteTooltip,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDeleted,
                  child: Icon(
                    Icons.close,
                    size: tokens.iconSizes.small * 0.8,
                    color: colors.outline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A row of chips that wraps onto the next line.
///
/// Nothing clever, just the spacing so a group of them lines up the way the
/// rest of the kit does.
class GlimmerChipGroup extends StatelessWidget {
  /// Creates a wrapping row of chips.
  const GlimmerChipGroup({super.key, required this.children});

  /// The chips.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final spacing = GlimmerTheme.of(context).spacing;
    return Wrap(
      spacing: spacing.small,
      runSpacing: spacing.small,
      children: children,
    );
  }
}
