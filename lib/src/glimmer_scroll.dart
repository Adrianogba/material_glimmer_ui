import 'package:flutter/material.dart';

/// Scrolling that does not break glass.
///
/// Android's default overscroll is a stretch, and to scale the content Flutter
/// renders it into an offscreen layer. A [GlimmerSurface] reads what is painted
/// behind it, and inside that layer there is nothing behind it, so every glass
/// panel on the screen goes flat for as long as the stretch lasts and snaps
/// back when it ends.
///
/// The fix is not to drop overscroll feedback. Reaching the end of a list is
/// worth saying, and saying nothing is its own bug. This paints a glow instead:
/// it is drawn over the content rather than by transforming it, so nothing is
/// isolated and the surfaces stay transparent throughout.
///
/// [GlimmerApp] installs it. Pass your own `scrollBehavior` to opt out, and
/// expect the flicker if you choose the stretch.
class GlimmerScrollBehavior extends MaterialScrollBehavior {
  /// Creates the Glimmer scroll behaviour.
  const GlimmerScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // These bounce instead, which is a physics effect on the scroll
        // position rather than a layer, so it is already safe.
        return child;
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return GlowingOverscrollIndicator(
          axisDirection: details.direction,
          color: Theme.of(context).colorScheme.primary,
          child: child,
        );
    }
  }
}
