import 'package:flutter/material.dart';

import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// The two Glimmer button sizes.
enum GlimmerButtonSize {
  /// The default. 48 tall, with 16 of horizontal and 8 of vertical padding.
  medium,

  /// The prominent size. 72 tall, with 16 of padding all round.
  large;

  /// The minimum height for this size.
  double get minHeight => this == GlimmerButtonSize.medium ? 48 : 72;

  /// The content padding for this size, resolved against the Glimmer spacing
  /// scale.
  EdgeInsets padding(GlimmerTokens tokens) {
    final spacing = tokens.spacing;
    if (this == GlimmerButtonSize.medium) {
      return EdgeInsets.symmetric(
        horizontal: spacing.large,
        vertical: spacing.small,
      );
    }
    return EdgeInsets.all(spacing.large);
  }
}

/// A Glimmer button: a stadium-shaped surface with a required label and
/// optional leading and trailing icons.
///
/// Buttons carry the full surface state model, so a focused button grows its
/// outline to the focal colour and lifts to depth level 2, and a pressed one
/// takes the white overlay.
///
/// [prominent] fills the button with the focal colour for the one action on a
/// screen that should pull the eye. Everything else stays on the neutral
/// surface and lets focus provide the emphasis, which is how Glimmer's own
/// buttons behave.
///
/// Use an icon-only button ([GlimmerIconButton]) only when the icon is
/// unambiguous on its own.
///
/// ```dart
/// GlimmerButton(
///   label: 'Reply',
///   leadingIcon: Icons.mic_none,
///   onPressed: () => reply(),
/// )
/// ```
class GlimmerButton extends StatelessWidget {
  /// Creates a Glimmer button.
  const GlimmerButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.size = GlimmerButtonSize.medium,
    this.prominent = false,
    this.color,
    this.focused = false,
    this.expand = false,
  });

  /// The button's text. Glimmer buttons always have one.
  final String label;

  /// Called on tap. When null the button is disabled and dimmed.
  final VoidCallback? onPressed;

  /// An icon before the label.
  final IconData? leadingIcon;

  /// An icon after the label.
  final IconData? trailingIcon;

  /// Which of the two Glimmer sizes to use.
  final GlimmerButtonSize size;

  /// Whether to fill the button with the focal colour.
  final bool prominent;

  /// Overrides the fill. Pass [GlimmerColors.positive] or
  /// [GlimmerColors.negative] for a semantic action; the content colour follows
  /// automatically.
  final Color? color;

  /// Whether the button is in its focused state.
  final bool focused;

  /// Whether to stretch to the available width instead of hugging the label.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final fill = color ?? (prominent ? colors.primary : colors.surface);
    final enabled = onPressed != null;

    final row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: tokens.iconSizes.small),
          SizedBox(width: tokens.spacing.extraSmall),
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
        if (trailingIcon != null) ...[
          SizedBox(width: tokens.spacing.extraSmall),
          Icon(trailingIcon, size: tokens.iconSizes.small),
        ],
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: enabled ? 1 : 0.42,
      child: GlimmerSurface(
        onTap: onPressed,
        focused: focused,
        color: fill,
        borderRadius: tokens.shapes.stadium,
        padding: size.padding(tokens),
        // No semanticLabel here. The label is on screen, so the Text already
        // carries it, and setting both makes a screen reader say it twice.
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.minHeight - 16),
          child: Center(widthFactor: expand ? null : 1, child: row),
        ),
      ),
    );
  }
}

/// A Glimmer button with a selected state.
///
/// Use it for things that stay on or off, such as a mute control, rather than
/// for one-shot actions. When selected it fills with the focal colour; when not
/// it is an ordinary neutral button.
class GlimmerToggleButton extends StatelessWidget {
  /// Creates a Glimmer toggle button.
  const GlimmerToggleButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
    this.leadingIcon,
    this.size = GlimmerButtonSize.medium,
    this.expand = false,
  });

  /// The button's text.
  final String label;

  /// Whether the button is currently on.
  final bool selected;

  /// Called with the new value on tap. When null the button is disabled.
  final ValueChanged<bool>? onChanged;

  /// An icon before the label.
  final IconData? leadingIcon;

  /// Which of the two Glimmer sizes to use.
  final GlimmerButtonSize size;

  /// Whether to stretch to the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: selected,
      child: GlimmerButton(
        label: label,
        leadingIcon: leadingIcon,
        size: size,
        expand: expand,
        prominent: selected,
        focused: selected,
        onPressed: onChanged == null ? null : () => onChanged!(!selected),
      ),
    );
  }
}

/// A row of related buttons, spaced the Glimmer way.
///
/// Glimmer groups buttons so a one-dimensional focus search moves between them
/// discretely. On a phone the grouping is purely visual, but the spacing and
/// the equal widths still matter: a pair of actions reads as a pair.
class GlimmerButtonGroup extends StatelessWidget {
  /// Creates a button group.
  const GlimmerButtonGroup({
    super.key,
    required this.children,
    this.equalWidths = true,
  });

  /// The buttons, in order.
  final List<Widget> children;

  /// Whether every child gets the same width. Turn it off to let each button
  /// hug its own label.
  final bool equalWidths;

  @override
  Widget build(BuildContext context) {
    final spacing = GlimmerTheme.of(context).spacing.medium;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(SizedBox(width: spacing));
      items.add(
        equalWidths ? Expanded(child: children[i]) : children[i],
      );
    }
    // IntrinsicHeight lets the buttons match the tallest of them without
    // needing a bounded height, so a group works inside a scroll view.
    return IntrinsicHeight(
      child: Row(
        mainAxisSize: equalWidths ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }
}
