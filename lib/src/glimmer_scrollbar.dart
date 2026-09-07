import 'package:flutter/material.dart';

import 'glimmer_motion.dart';
import 'glimmer_theme.dart';

/// The bar that says how far down a long list you are.
///
/// Material draws a grey capsule on a solid track. The track is the part that
/// does not belong here: a surface is glass so that what is behind it comes
/// through, and a track is an opaque stripe painted over that for the whole
/// length of the list. So there is no track, the thumb is thinner, it takes the
/// outline colour rather than a grey of its own, and it fades out once
/// scrolling stops.
///
/// [GlimmerScrollBehavior] installs it, so an app using [MaterialGlimmerApp]
/// gets it without asking. It only shows itself where the platform shows one at
/// all, which is desktop and web; a phone gets nothing until a finger moves.
///
/// ```dart
/// GlimmerScrollbar(child: ListView(children: rows))
/// ```
class GlimmerScrollbar extends StatelessWidget {
  /// Creates a scrollbar around [child].
  const GlimmerScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.thumbVisibility,
  });

  /// The scrollable being wrapped.
  final Widget child;

  /// The controller the bar follows. Defaults to the nearest scrollable's.
  final ScrollController? controller;

  /// Whether the thumb stays up once scrolling stops.
  ///
  /// Null leaves it to the platform, which is what a phone wants: the bar
  /// appears while a finger is moving and goes again afterwards.
  final bool? thumbVisibility;

  /// How wide the thumb is. Material's is 8.
  static const thickness = 4.0;

  /// How long the thumb stays up after scrolling stops.
  static const timeToFade = Duration(milliseconds: 900);

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);

    return RawScrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      thickness: thickness,
      radius: const Radius.circular(999),
      trackVisibility: false,
      thumbColor: colors.outline.withValues(alpha: 0.9),
      fadeDuration: GlimmerMotion.modalDuration,
      timeToFade: timeToFade,
      pressDuration: Duration.zero,
      child: child,
    );
  }
}
