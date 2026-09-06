import 'package:flutter/material.dart';

import 'glimmer_overscroll.dart';

/// Scrolling that looks like Glimmer and does not break glass.
///
/// Two problems with the platform defaults, and they have the same answer.
///
/// Android stretches the content at the end of a list. To scale it, Flutter
/// renders the scrollable into an offscreen layer, and a [GlimmerSurface] reads
/// what is painted behind it: inside that layer there is nothing behind it, so
/// every glass panel on screen goes flat for as long as the stretch lasts.
///
/// The second problem is that a stretch is Material's gesture and a bounce is
/// Cupertino's. A kit that wants an identity of its own cannot borrow either.
///
/// So the content does not move. [GlimmerOverscrollIndicator] lights up the
/// edge the list ran into instead, with the same graded light the surfaces use
/// on their own edges. It is painted over the content, so nothing is isolated.
///
/// [GlimmerApp] installs this. Pass your own `scrollBehavior` to opt out.
class GlimmerScrollBehavior extends MaterialScrollBehavior {
  /// Creates the Glimmer scroll behaviour.
  const GlimmerScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlimmerOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}
