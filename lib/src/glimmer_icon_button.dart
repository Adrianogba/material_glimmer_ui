import 'package:flutter/material.dart';

import 'glimmer_surface.dart';
import 'glimmer_theme.dart';
import 'glimmer_tooltip.dart';

/// A circular Glimmer button holding a single icon.
///
/// It is 48 across, which is both Glimmer's minimum and Material's minimum
/// touch target, so it stays tappable on a phone without any adjustment.
///
/// Only reach for an icon-only button when the icon is unambiguous. Otherwise
/// use a [GlimmerButton] with a label.
class GlimmerIconButton extends StatelessWidget {
  /// Creates a Glimmer icon button.
  const GlimmerIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.semanticLabel,
    this.prominent = false,
    this.color,
    this.focused = false,
    this.size = 48,
  });

  /// The glyph to draw.
  final IconData icon;

  /// Called on tap. When null the button is disabled and dimmed.
  final VoidCallback? onPressed;

  /// A tooltip shown on long press or hover.
  final String? tooltip;

  /// The accessibility label. Falls back to [tooltip].
  final String? semanticLabel;

  /// Whether to fill the button with the focal colour.
  final bool prominent;

  /// Overrides the fill.
  final Color? color;

  /// Whether the button is in its focused state.
  final bool focused;

  /// The diameter. Do not go below 48 on a touch screen.
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final fill = color ?? (prominent ? colors.primary : colors.surface);

    final button = AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: onPressed == null ? 0.42 : 1,
      child: GlimmerSurface(
        onTap: onPressed,
        focused: focused,
        color: fill,
        borderRadius: tokens.shapes.stadium,
        padding: EdgeInsets.zero,
        semanticLabel: semanticLabel ?? tooltip,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: tokens.iconSizes.small),
        ),
      ),
    );

    return tooltip == null
        ? button
        : GlimmerTooltip(message: tooltip!, child: button);
  }
}

/// An icon button with a selected state, for controls like mute or bookmark.
class GlimmerIconToggleButton extends StatelessWidget {
  /// Creates a Glimmer icon toggle button.
  const GlimmerIconToggleButton({
    super.key,
    required this.icon,
    required this.selected,
    required this.onChanged,
    this.selectedIcon,
    this.tooltip,
    this.semanticLabel,
    this.size = 48,
  });

  /// The glyph shown when not selected.
  final IconData icon;

  /// The glyph shown when selected. Defaults to [icon].
  final IconData? selectedIcon;

  /// Whether the button is currently on.
  final bool selected;

  /// Called with the new value on tap. When null the button is disabled.
  final ValueChanged<bool>? onChanged;

  /// A tooltip shown on long press or hover.
  final String? tooltip;

  /// The accessibility label. Falls back to [tooltip].
  final String? semanticLabel;

  /// The diameter.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: selected,
      child: GlimmerIconButton(
        icon: selected ? (selectedIcon ?? icon) : icon,
        tooltip: tooltip,
        semanticLabel: semanticLabel,
        prominent: selected,
        focused: selected,
        size: size,
        onPressed: onChanged == null ? null : () => onChanged!(!selected),
      ),
    );
  }
}
