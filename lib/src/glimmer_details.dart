import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'glimmer_motion.dart';
import 'glimmer_theme.dart';
import 'glimmer_tone.dart';

/// A line between two groups of content.
///
/// Not a flat rule. It is the same graded light the surfaces carry on their
/// edges, brightest in the middle and gone at both ends, so a divider reads as
/// a seam catching light rather than as a hairline drawn across the page.
///
/// ```dart
/// GlimmerDivider()
/// ```
class GlimmerDivider extends StatelessWidget {
  /// Creates a horizontal divider.
  const GlimmerDivider({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1.5,
    this.indent = 0,
    this.color,
  });

  /// Which way the line runs.
  final Axis axis;

  /// How thick the line is. Matches [GlimmerMotion.borderWidth] by default.
  final double thickness;

  /// How far the line is held back from both ends.
  final double indent;

  /// Overrides the line colour. Defaults to [GlimmerColors.outline].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);
    final line = color ?? colors.outline;
    final horizontal = axis == Axis.horizontal;

    return Padding(
      padding: horizontal
          ? EdgeInsets.symmetric(horizontal: indent)
          : EdgeInsets.symmetric(vertical: indent),
      child: SizedBox(
        height: horizontal ? thickness : null,
        width: horizontal ? null : thickness,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: horizontal ? Alignment.centerLeft : Alignment.topCenter,
              end: horizontal ? Alignment.centerRight : Alignment.bottomCenter,
              colors: [
                line.withValues(alpha: 0),
                line.withValues(alpha: 0.9),
                line.withValues(alpha: 0),
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// A small count or dot attached to the corner of something.
///
/// The pill is filled with a semantic colour and lit at its edge, which is what
/// makes it read as sitting in front of whatever it is marking rather than as a
/// sticker printed on it.
///
/// Wrap the thing being marked:
///
/// ```dart
/// GlimmerBadge(
///   count: 3,
///   child: GlimmerIconButton(icon: Icons.notifications, onPressed: open),
/// )
/// ```
class GlimmerBadge extends StatelessWidget {
  /// Marks [child] with a badge.
  const GlimmerBadge({
    super.key,
    required this.child,
    this.count,
    this.label,
    this.color,
    this.alignment = Alignment.topRight,
    this.visible = true,
  });

  /// The thing being marked.
  final Widget child;

  /// A number to show. Anything above 99 is shown as `99+`.
  final int? count;

  /// Text to show instead of [count].
  final String? label;

  /// The fill. Defaults to [GlimmerColors.negative].
  final Color? color;

  /// Which corner the badge sits in.
  final Alignment alignment;

  /// Whether the badge is shown at all.
  final bool visible;

  /// The diameter of a badge with nothing written on it.
  static const dotSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final fill = color ?? colors.negative;
    final text =
        label ?? (count == null ? null : (count! > 99 ? '99+' : '$count'));

    return Stack(
      clipBehavior: Clip.none,
      alignment: alignment,
      children: [
        child,
        if (visible)
          Positioned(
            top: alignment.y < 0 ? -2 : null,
            bottom: alignment.y > 0 ? -2 : null,
            left: alignment.x < 0 ? -2 : null,
            right: alignment.x > 0 ? -2 : null,
            child: AnimatedScale(
              scale: visible ? 1 : 0,
              duration: GlimmerMotion.modalDuration,
              curve: GlimmerMotion.focusCurve,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: dotSize,
                  minHeight: dotSize,
                ),
                padding: text == null
                    ? EdgeInsets.zero
                    : const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: fill.withTone(math.min(100, fill.tone + 24)),
                    width: 1,
                  ),
                ),
                child: text == null
                    ? null
                    : Text(
                        text,
                        textAlign: TextAlign.center,
                        style: tokens.typography.caption.copyWith(
                          color: colors.contentColorFor(fill),
                          height: 1.1,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A round portrait, or the initials standing in for one.
///
/// The ring is the same graded edge every surface carries, so an avatar in a
/// list sits on the same plane as the rows around it.
///
/// ```dart
/// GlimmerAvatar(label: 'Ana Ribeiro', image: NetworkImage(url))
/// ```
class GlimmerAvatar extends StatelessWidget {
  /// Creates an avatar.
  const GlimmerAvatar({
    super.key,
    this.image,
    this.label,
    this.icon,
    this.size = 40,
    this.color,
  });

  /// The portrait.
  final ImageProvider? image;

  /// A name. Its initials are shown when there is no [image].
  final String? label;

  /// An icon to show when there is neither an [image] nor a [label].
  final IconData? icon;

  /// The diameter.
  final double size;

  /// Overrides the fill behind the initials.
  final Color? color;

  /// The initials [label] reduces to. At most two letters.
  static String initialsOf(String label) {
    final words = label.trim().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words.first.characters.take(2).toString().toUpperCase();
    }
    return (words.first.characters.first + words.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final fill = color ?? colors.surface;
    final initials = label == null ? '' : initialsOf(label!);

    return Semantics(
      label: label,
      image: image != null,
      child: Container(
        width: size,
        height: size,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          image: image == null
              ? null
              : DecorationImage(image: image!, fit: BoxFit.cover),
          // The same asymmetric ring the surfaces carry: brightest where the
          // light falls, almost gone on the far side.
          gradient: image != null
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    fill.withTone(math.min(100, fill.tone + 8)),
                    fill,
                  ],
                ),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.85),
            width: GlimmerMotion.borderWidth,
          ),
        ),
        child: image != null
            ? null
            : Center(
                child: initials.isEmpty
                    ? Icon(
                        icon ?? Icons.person_outline,
                        size: size * 0.5,
                        color: colors.onSurface,
                      )
                    : Text(
                        initials,
                        style: tokens.typography.titleSmall.copyWith(
                          color: colors.contentColorFor(fill),
                          fontSize: size * 0.36,
                        ),
                      ),
              ),
      ),
    );
  }
}
