import 'package:flutter/material.dart';

import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// A pill that titles the content under it.
///
/// A title chip is not a control. It cannot be focused or tapped, and it exists
/// only to name the card or the list below it. Glimmer's guidance is strict
/// about the copy: centre it, keep it to three words, and never let it wrap.
/// This widget enforces the single line and the centring; the word count is
/// yours to keep.
///
/// Put [GlimmerTitleChipDefaults.associatedContentSpacing] between the chip and
/// what it titles. Inside a [GlimmerList], pass `title:` instead and the list
/// handles the spacing for you.
///
/// ```dart
/// Column(
///   children: [
///     const GlimmerTitleChip('Grocery list'),
///     SizedBox(height: GlimmerTitleChipDefaults.associatedContentSpacing(context)),
///     GlimmerCard(title: 'Milk'),
///   ],
/// )
/// ```
class GlimmerTitleChip extends StatelessWidget {
  /// Creates a title chip.
  const GlimmerTitleChip(
    this.label, {
    super.key,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.maxWidth = 352,
  });

  /// The title. One line, centred, truncated if it does not fit.
  final String label;

  /// A widget before the label, usually an avatar.
  final Widget? leading;

  /// An icon before the label, used when [leading] is null.
  final IconData? leadingIcon;

  /// A widget after the label.
  final Widget? trailing;

  /// The widest the chip may become before its label truncates.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;
    final minHeight = tokens.scale == GlimmerScale.glasses ? 44.0 : 36.0;
    final leadingWidget = leading ??
        (leadingIcon == null
            ? null
            : Icon(leadingIcon, size: tokens.iconSizes.small));

    return Semantics(
      header: true,
      label: label,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: GlimmerSurface(
          borderRadius: tokens.shapes.stadium,
          // Glimmer pads a title chip by one extra-small step all round.
          padding: EdgeInsets.all(spacing.extraSmall),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minHeight - (spacing.extraSmall * 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingWidget != null) ...[
                  leadingWidget,
                  SizedBox(width: spacing.extraSmall),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: tokens.typography.titleSmall,
                  ),
                ),
                if (trailing != null) ...[
                  SizedBox(width: spacing.extraSmall),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Defaults for [GlimmerTitleChip].
class GlimmerTitleChipDefaults {
  const GlimmerTitleChipDefaults._();

  /// The gap Glimmer puts between a chip and the content it titles.
  static double associatedContentSpacing(BuildContext context) =>
      GlimmerTheme.of(context).spacing.medium;
}
