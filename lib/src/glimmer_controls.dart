import 'package:flutter/material.dart';

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

/// A progress bar in the Glimmer palette.
///
/// Pass a [value] between 0 and 1 for determinate progress, or leave it null
/// for an indeterminate sweep. The track is a lit edge and the fill is the
/// focal colour, so it sits in a list of surfaces without announcing itself.
class GlimmerProgressBar extends StatelessWidget {
  /// Creates a progress bar.
  const GlimmerProgressBar({super.key, this.value, this.height = 8});

  /// Progress between 0 and 1, or null for indeterminate.
  final double? value;

  /// The bar's thickness.
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: LinearProgressIndicator(
          value: value,
          minHeight: height,
          backgroundColor: colors.surface,
          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
        ),
      ),
    );
  }
}
