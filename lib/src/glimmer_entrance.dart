import 'package:flutter/widgets.dart';

/// How far a surface has arrived, from 0 to 1.
///
/// Glass cannot be faded with an [Opacity] or a [FadeTransition]. Those put the
/// subtree in its own layer, and a [GlimmerSurface] reads what is painted
/// behind it: inside that layer there is nothing behind it. The surface stays
/// flat for the whole animation, and then the layer is dropped at the end and
/// the backdrop appears in one frame. That is the jump at the end of a menu
/// opening, and the same jump in reverse when it closes.
///
/// So a surface is not faded, it is *arrived*. This carries the progress down
/// the tree and every surface under it scales its own tint, blur, edge and
/// shadow by it, and fades only its content. Nothing is isolated at any point,
/// so the backdrop is there from the first frame to the last.
///
/// [showGlimmerDialog], [showGlimmerBottomSheet] and [showGlimmerMenu] provide
/// it. Wrap your own route in one if you build a surface that has to appear.
///
/// ```dart
/// GlimmerEntrance(progress: animation.value, child: GlimmerCard(...))
/// ```
class GlimmerEntrance extends InheritedWidget {
  /// Provides [progress] to every surface below.
  const GlimmerEntrance({
    super.key,
    required this.progress,
    required super.child,
  });

  /// How far the surfaces below have arrived. 1 is fully present.
  final double progress;

  /// The entrance progress in scope, or 1 where there is none.
  static double of(BuildContext context) {
    final entrance =
        context.dependOnInheritedWidgetOfExactType<GlimmerEntrance>();
    return (entrance?.progress ?? 1).clamp(0.0, 1.0);
  }

  @override
  bool updateShouldNotify(GlimmerEntrance oldWidget) =>
      oldWidget.progress != progress;
}
