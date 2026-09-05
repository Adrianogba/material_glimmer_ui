import 'package:flutter/material.dart';

import 'glimmer_theme.dart';

/// Text that takes its colour from the surface it sits on.
///
/// Glimmer computes content colour from the nearest surface instead of asking
/// the caller for it, which is why none of the components here take a text
/// colour. [GlimmerSurface] publishes that colour as the ambient
/// [DefaultTextStyle], so a plain [Text] inside a Glimmer component is already
/// correct. This widget adds the type scale on top: pass a style from
/// [GlimmerTypography] and it merges with the inherited colour.
///
/// ```dart
/// GlimmerText('Blood oranges', style: GlimmerTheme.typographyOf(context).titleMedium)
/// ```
class GlimmerText extends StatelessWidget {
  /// Creates Glimmer text.
  const GlimmerText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.semanticsLabel,
  });

  /// The string to display.
  final String data;

  /// The style to merge over the inherited one. Defaults to
  /// [GlimmerTypography.bodySmall], which is Glimmer's ambient text style.
  final TextStyle? style;

  /// How the text is aligned horizontally.
  final TextAlign? textAlign;

  /// The maximum number of lines before truncation.
  final int? maxLines;

  /// How overflowing text is handled. Defaults to [TextOverflow.ellipsis] when
  /// [maxLines] is set.
  final TextOverflow? overflow;

  /// An alternative string for screen readers.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final inherited = DefaultTextStyle.of(context).style;
    final resolved = (style ?? tokens.typography.bodySmall).copyWith(
      color: style?.color ?? inherited.color ?? tokens.colors.onSurface,
    );
    return Text(
      data,
      style: resolved,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      semanticsLabel: semanticsLabel,
    );
  }
}

/// A non-interactive icon at one of the three Glimmer sizes.
///
/// Use it for status and indicators. When the icon is a trigger, use a
/// [GlimmerIconButton] instead so it gets the focus treatment and a large
/// enough tap target.
///
/// Glimmer's own icon set is Material Symbols Rounded at weight 600. Flutter
/// bundles Material Icons rather than Symbols, so the shipped set is close but
/// not identical; pass any [IconData] you like if that matters to you.
class GlimmerIcon extends StatelessWidget {
  /// Creates a Glimmer icon.
  const GlimmerIcon(
    this.icon, {
    super.key,
    this.size = GlimmerIconSize.medium,
    this.color,
    this.semanticLabel,
  });

  /// The glyph to draw.
  final IconData icon;

  /// Which of the three Glimmer sizes to use.
  final GlimmerIconSize size;

  /// Overrides the inherited content colour.
  ///
  /// Never pass pure black. On an additive display it renders as nothing at
  /// all, and on a dark phone theme it is invisible for the same practical
  /// reason.
  final Color? color;

  /// An accessibility label. Leave it null for a decorative icon.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    return Icon(
      icon,
      size: size.resolve(tokens),
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}

/// One of Glimmer's three named icon sizes.
enum GlimmerIconSize {
  /// The smallest size, for icons inside buttons and list items.
  small,

  /// The default size.
  medium,

  /// The largest size, for a single focal symbol.
  large;

  /// Resolves this size against [tokens].
  double resolve(GlimmerTokens tokens) {
    switch (this) {
      case GlimmerIconSize.small:
        return tokens.iconSizes.small;
      case GlimmerIconSize.medium:
        return tokens.iconSizes.medium;
      case GlimmerIconSize.large:
        return tokens.iconSizes.large;
    }
  }
}
