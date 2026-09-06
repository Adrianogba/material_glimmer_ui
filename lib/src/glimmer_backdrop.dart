import 'package:flutter/material.dart';

import 'glimmer_theme.dart';

/// What sits behind Glimmer's surfaces.
///
/// A surface has to have something to be glass over. Against a flat fill the
/// surfaces still work, they are simply doing less: the blur has nothing to
/// soften and the tint has nothing to colour. So the app supplies a backdrop,
/// and [GlimmerSurface] frosts it.
///
/// The default is a slow gradient built from the theme's own focal colours,
/// dark enough to keep white text at full contrast. Pass [image] for a photo,
/// [colors] for your own gradient, or [child] for anything else, including live
/// content such as a camera preview or a map.
///
/// ```dart
/// GlimmerScaffold(
///   backdrop: const GlimmerBackdrop(),
///   body: ...,
/// )
/// ```
class GlimmerBackdrop extends StatelessWidget {
  /// Creates a backdrop.
  const GlimmerBackdrop({
    super.key,
    this.child,
    this.colors,
    this.image,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
    this.dim = 0,
  });

  /// Arbitrary content to put behind the surfaces, drawn to fill the space.
  ///
  /// Takes priority over [image] and [colors].
  final Widget? child;

  /// An image to fill the backdrop with.
  final ImageProvider? image;

  /// Gradient stops. Defaults to a dark wash of the theme's focal colours.
  final List<Color>? colors;

  /// Where the gradient starts.
  final Alignment begin;

  /// Where the gradient ends.
  final Alignment end;

  /// A black veil over the backdrop, from 0 to 1.
  ///
  /// Raise it when a photograph is bright enough to fight the text on top of
  /// it. Glimmer's contrast guidance asks for a 70% tone difference between
  /// foreground and background, and a busy image rarely gets there on its own.
  final double dim;

  @override
  Widget build(BuildContext context) {
    final palette = GlimmerTheme.colorsOf(context);

    Widget content;
    if (child != null) {
      content = Positioned.fill(child: child!);
    } else if (image != null) {
      content = Positioned.fill(
        child: Image(image: image!, fit: BoxFit.cover),
      );
    } else {
      final stops = colors ??
          [
            Color.alphaBlend(
              palette.primary.withValues(alpha: 0.16),
              palette.background,
            ),
            palette.background,
            Color.alphaBlend(
              palette.secondary.withValues(alpha: 0.22),
              palette.background,
            ),
          ];
      content = Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: begin, end: end, colors: stops),
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: palette.background),
        content,
        if (dim > 0)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xFF000000).withValues(alpha: dim),
            ),
          ),
      ],
    );
  }
}
