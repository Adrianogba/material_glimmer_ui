import 'package:flutter/material.dart';

import 'glimmer_entrance.dart';
import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// One choice in a [GlimmerMenu].
@immutable
class GlimmerMenuItem<T> {
  /// Creates a menu item.
  const GlimmerMenuItem({
    required this.label,
    required this.value,
    this.icon,
    this.enabled = true,
    this.destructive = false,
  });

  /// The item's text.
  final String label;

  /// What selecting it returns.
  final T value;

  /// An icon before the label.
  final IconData? icon;

  /// Whether the item can be chosen.
  final bool enabled;

  /// Whether the item does something the user cannot undo, which colours it
  /// with [GlimmerColors.negative].
  final bool destructive;
}

/// A short list of choices, anchored to whatever opened it.
///
/// Use [showGlimmerMenu], which positions it against a widget for you. Built
/// directly it is just the panel.
///
/// A panel of rows with the same focus treatment a list item has. The rows
/// carry no fill and no blur of their own: glass over glass compounds, and the
/// panel behind them would disappear under a stack of lighter bars.
class GlimmerMenu<T> extends StatelessWidget {
  /// Creates a menu panel.
  const GlimmerMenu({
    super.key,
    required this.items,
    this.onSelected,
    this.selected,
    this.maxWidth = 280,
  });

  /// The choices, in order.
  final List<GlimmerMenuItem<T>> items;

  /// Called with the chosen value.
  final ValueChanged<T>? onSelected;

  /// The value to mark as currently chosen.
  final T? selected;

  /// The widest the panel may become.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: GlimmerSurface(
        padding: EdgeInsets.all(spacing.small),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              Padding(
                padding: EdgeInsets.symmetric(vertical: spacing.extraSmall / 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 160),
                  opacity: item.enabled ? 1 : 0.42,
                  child: GlimmerSurface(
                    borderRadius: tokens.shapes.small,
                    // A row adds no tint and no resting edge of its own. Glass
                    // over glass compounds: give every row a fill and the panel
                    // behind them disappears under a stack of lighter bars. The
                    // surface treatment arrives with focus and with a press,
                    // which is when it means something.
                    opacity: 0,
                    // No blur either. A row that blurs samples the panel it is
                    // sitting on, so every row gets its own slightly different
                    // background and the panel reads as a stack of bands with
                    // seams between them rather than as one surface.
                    blur: 0,
                    borderColor: const Color(0x00000000),
                    focused: item.value == selected,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.medium,
                      vertical: spacing.small,
                    ),
                    onTap: item.enabled && onSelected != null
                        ? () => onSelected!(item.value)
                        : null,
                    child: Row(
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: tokens.iconSizes.small,
                            color: item.destructive ? colors.negative : null,
                          ),
                          SizedBox(width: spacing.small),
                        ],
                        Expanded(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tokens.typography.bodySmall.copyWith(
                              color: item.destructive ? colors.negative : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Opens a [GlimmerMenu] against the widget that [context] belongs to.
///
/// The menu opens below the anchor when there is room and above it when there
/// is not, and it is nudged inside the screen rather than clipped.
///
/// ```dart
/// final choice = await showGlimmerMenu<String>(
///   context: context,
///   items: const [
///     GlimmerMenuItem(label: 'Share', value: 'share', icon: Icons.ios_share),
///     GlimmerMenuItem(label: 'Delete', value: 'delete', destructive: true),
///   ],
/// );
/// ```
Future<T?> showGlimmerMenu<T>({
  required BuildContext context,
  required List<GlimmerMenuItem<T>> items,
  T? selected,
  double maxWidth = 280,
  String barrierLabel = 'Dismiss',
}) {
  final anchor = context.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
  final target = Rect.fromPoints(
    anchor.localToGlobal(Offset.zero, ancestor: overlay),
    anchor.localToGlobal(
      anchor.size.bottomRight(Offset.zero),
      ancestor: overlay,
    ),
  );

  return Navigator.of(context).push<T>(
    _GlimmerMenuRoute<T>(
      anchor: target,
      overlaySize: overlay.size,
      barrierLabel: barrierLabel,
      builder: (context) => GlimmerMenu<T>(
        items: items,
        selected: selected,
        maxWidth: maxWidth,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    ),
  );
}

class _GlimmerMenuRoute<T> extends PopupRoute<T> {
  _GlimmerMenuRoute({
    required this.anchor,
    required this.overlaySize,
    required this.builder,
    required this.barrierLabel,
  });

  final Rect anchor;
  final Size overlaySize;
  final WidgetBuilder builder;

  @override
  final String barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => GlimmerMotion.modalDuration;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final tokens = GlimmerTheme.of(context);
    final eased = CurvedAnimation(
      parent: animation,
      curve: GlimmerMotion.focusCurve,
      reverseCurve: GlimmerMotion.focusCurve.flipped,
    );

    // Below the anchor if it fits, above it otherwise. A menu that runs off the
    // bottom of the screen is worse than one that opens the other way.
    final gap = tokens.spacing.small;
    final below = anchor.bottom + gap;
    final opensDown = below + 200 < overlaySize.height;

    return Material(
      // The menu is its own route, so it establishes the Material context the
      // app would otherwise have provided.
      type: MaterialType.transparency,
      child: CustomSingleChildLayout(
        delegate: _MenuLayout(
          anchor: anchor,
          gap: gap,
          opensDown: opensDown,
        ),
        // The panel is glass, so it arrives through GlimmerEntrance rather
        // than a FadeTransition: an opacity layer would leave it flat for the
        // whole animation and then snap the backdrop in at the end.
        child: AnimatedBuilder(
          animation: eased,
          builder: (context, child) => GlimmerEntrance(
            progress: eased.value,
            child: child!,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(eased),
            alignment: opensDown ? Alignment.topCenter : Alignment.bottomCenter,
            child: Builder(builder: builder),
          ),
        ),
      ),
    );
  }
}

class _MenuLayout extends SingleChildLayoutDelegate {
  const _MenuLayout({
    required this.anchor,
    required this.gap,
    required this.opensDown,
  });

  final Rect anchor;
  final double gap;
  final bool opensDown;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest).deflate(
      EdgeInsets.symmetric(horizontal: gap, vertical: gap),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final y =
        opensDown ? anchor.bottom + gap : anchor.top - gap - childSize.height;
    // Aligned to the anchor's left edge, then pulled back inside the screen
    // rather than allowed to hang off it.
    final x = anchor.left.clamp(
        gap, (size.width - childSize.width - gap).clamp(gap, double.infinity));
    return Offset(
      x.toDouble(),
      y
          .clamp(
              gap,
              (size.height - childSize.height - gap)
                  .clamp(gap, double.infinity))
          .toDouble(),
    );
  }

  @override
  bool shouldRelayout(_MenuLayout old) =>
      old.anchor != anchor || old.gap != gap || old.opensDown != opensDown;
}
