import 'package:flutter/material.dart';

import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// A Glimmer card: a surface that groups a header, a title, supporting text and
/// an action into one focal point.
///
/// Give it an [onTap] when the whole card is a single trigger, and leave it null
/// when the card holds several interactive things of its own. Glimmer is
/// explicit about that: nesting focusable elements inside a focusable card
/// makes focus ambiguous.
///
/// The named slots are optional. Pass [child] instead to lay the card out
/// yourself and keep only the surface treatment.
///
/// ```dart
/// GlimmerCard(
///   header: Image.asset('blood_oranges.jpg'),
///   title: 'Blood oranges',
///   supportingText: 'Produce outlet, R\$2 per kilo',
///   onTap: () => open(),
/// )
/// ```
class GlimmerCard extends StatelessWidget {
  /// Creates a Glimmer card from the named slots.
  const GlimmerCard({
    super.key,
    this.title,
    this.supportingText,
    this.header,
    this.leadingIcon,
    this.action,
    this.child,
    this.padding,
    this.focused = false,
    this.onTap,
    this.enableAmbientPulse = false,
    this.opacity,
    this.blur,
  }) : assert(
          child != null ||
              title != null ||
              supportingText != null ||
              header != null,
          'A card needs a child or at least one of title, supportingText and '
          'header.',
        );

  /// The card's title, drawn in [GlimmerTypography.titleMedium].
  final String? title;

  /// Supporting copy under the title, drawn in
  /// [GlimmerTypography.bodySmall].
  final String? supportingText;

  /// A widget above the text, usually an image. It is clipped to
  /// [GlimmerShapes.small].
  final Widget? header;

  /// An icon before the title.
  final IconData? leadingIcon;

  /// A widget under the text, usually a button.
  final Widget? action;

  /// Replaces the slot layout entirely.
  final Widget? child;

  /// Space between the border and the content. Defaults to
  /// [GlimmerSpacing.medium], which is what Glimmer specifies for a card.
  final EdgeInsetsGeometry? padding;

  /// Whether the card is in its focused state.
  final bool focused;

  /// Called on tap. Leave null when the card contains its own controls.
  final VoidCallback? onTap;

  /// Runs Glimmer's ambient sweep while focused. See
  /// [GlimmerSurface.enableAmbientPulse] for why it is off by default.
  final bool enableAmbientPulse;

  /// Overrides [GlimmerTokens.surfaceOpacity] for this card.
  ///
  /// Lower it for a card that should be mostly backdrop and lit edge.
  final double? opacity;

  /// Overrides [GlimmerTokens.surfaceBlur] for this card.
  final double? blur;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;
    final minHeight = tokens.scale == GlimmerScale.glasses ? 80.0 : 72.0;

    return GlimmerSurface(
      focused: focused,
      onTap: onTap,
      enableAmbientPulse: enableAmbientPulse,
      opacity: opacity,
      blur: blur,
      padding: padding ?? EdgeInsets.all(spacing.medium),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight - (spacing.medium * 2),
        ),
        child: child ?? _slots(context, tokens),
      ),
    );
  }

  Widget _slots(BuildContext context, GlimmerTokens tokens) {
    final spacing = tokens.spacing;
    final typography = tokens.typography;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null) ...[
          ClipRRect(borderRadius: tokens.shapes.small, child: header),
          SizedBox(height: spacing.medium),
        ],
        if (title != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: tokens.iconSizes.large),
                SizedBox(width: spacing.small),
              ],
              Expanded(child: Text(title!, style: typography.titleMedium)),
            ],
          ),
        if (title != null && supportingText != null)
          // Glimmer keeps title and supporting text tightly coupled: 3 between
          // the two lines, not a full spacing step.
          const SizedBox(height: 3),
        if (supportingText != null)
          Text(supportingText!, style: typography.bodySmall),
        if (action != null) ...[
          SizedBox(height: spacing.large),
          action!,
        ],
      ],
    );
  }
}
