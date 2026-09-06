import 'package:flutter/material.dart';

import 'glimmer_entrance.dart';
import 'glimmer_motion.dart';
import 'glimmer_theme.dart';

/// A route whose page arrives instead of sliding.
///
/// `MaterialPageRoute` slides the incoming page up and fades it, and
/// `CupertinoPageRoute` pushes it in from the side. Both move the page, and
/// both put it in a layer of its own while they do, which takes the backdrop
/// away from every glass surface on it: a pushed screen goes flat for the
/// length of the transition and snaps back at the end.
///
/// This one moves nothing. The arriving page comes in through
/// [GlimmerEntrance], so its ground fades up and its surfaces build their own
/// tint, blur and edge as they land, with no layer anywhere. The page being
/// covered withdraws by [GlimmerDepth.level3] rather than sliding away, which
/// is the same thing a modal does to the app behind it and the same thing a
/// stack does to the item behind the top one.
///
/// ```dart
/// Navigator.of(context).push(
///   GlimmerPageRoute(builder: (context) => const DetailScreen()),
/// );
/// ```
///
/// A page has to be built from this kit's pieces for any of this to show. A
/// [GlimmerScaffold] fades its own ground with the entrance; a bare [Scaffold]
/// paints an opaque background that arrives in one frame.
class GlimmerPageRoute<T> extends PageRoute<T> {
  /// Creates a route that builds its page with [builder].
  GlimmerPageRoute({
    required this.builder,
    super.settings,
    this.maintainState = true,
    super.fullscreenDialog,
    super.barrierDismissible,
  });

  /// Builds the page.
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => GlimmerMotion.pageDuration;

  @override
  Duration get reverseTransitionDuration => GlimmerMotion.pageDuration;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) =>
      previousRoute is GlimmerPageRoute;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) =>
      nextRoute is GlimmerPageRoute;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      builder(context);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final recede = GlimmerTheme.of(context).depth.level3.recede;

    return AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      builder: (context, child) {
        final arriving =
            GlimmerMotion.focusCurve.transform(animation.value.clamp(0.0, 1.0));
        final covered = GlimmerMotion.focusCurve
            .transform(secondaryAnimation.value.clamp(0.0, 1.0));

        // One number does both halves. Arriving takes the page from nothing to
        // fully present; being covered takes it back down by the depth level
        // of whatever is now in front of it.
        return GlimmerEntrance(
          progress: arriving * (1 - (covered * recede)),
          child: child!,
        );
      },
      child: child,
    );
  }
}
