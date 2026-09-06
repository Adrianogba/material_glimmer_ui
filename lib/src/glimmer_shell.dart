import 'package:flutter/material.dart';

import 'glimmer_entrance.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// An app frame in the Glimmer language.
///
/// Material's own bars carry elevation, tonal overlays and a ripple that fight
/// the Glimmer surface treatment, so this is the familiar structure drawn with
/// Glimmer's tokens instead: a bar, a body over a backdrop, and a navigation
/// strip that is one surface rather than a row of them.
///
/// It is entirely optional. A plain [Scaffold] under [GlimmerTheme.dark] works
/// too and inherits the palette and type.
class GlimmerScaffold extends StatelessWidget {
  /// Creates a Glimmer app frame.
  const GlimmerScaffold({
    super.key,
    required this.body,
    this.backdrop,
    this.title,
    this.action,
    this.leading,
    this.navigationItems = const [],
    this.selectedIndex = 0,
    this.onNavigationChanged,
    this.backgroundColor,
  });

  /// The screen's content.
  final Widget body;

  /// What the surfaces are glass over.
  ///
  /// Usually a [GlimmerBackdrop]. Without one the window is a flat fill, the
  /// surfaces have nothing to filter, and the system loses the effect it is
  /// built around.
  final Widget? backdrop;

  /// The title shown in the top bar. Without one the bar is omitted.
  final String? title;

  /// A widget at the end of the top bar, usually a [GlimmerIconButton].
  final Widget? action;

  /// A widget at the start of the top bar, replacing the accent mark.
  final Widget? leading;

  /// The bottom navigation destinations. Without any the strip is omitted.
  final List<GlimmerNavigationItem> navigationItems;

  /// Which destination is selected.
  final int selectedIndex;

  /// Called with the tapped destination's index.
  final ValueChanged<int>? onNavigationChanged;

  /// Overrides the window colour.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;

    // A scaffold fades its own ground with the entrance, so a page arriving
    // through GlimmerPageRoute builds up from the screen behind it rather than
    // cutting its background in on the first frame. This is the ground itself,
    // not a layer over the page, so the glass on top still reads its backdrop.
    final entrance = GlimmerEntrance.of(context);
    final ground = backgroundColor ?? colors.background;

    // Flutter's ambient text style is only defined inside a Material. Without
    // one, any Text in the body renders in the red monospace error style, so
    // the scaffold has to establish the same context Material's own does.
    return Material(
      type: MaterialType.canvas,
      color: ground.withValues(alpha: ground.a * entrance),
      child: DefaultTextStyle(
        style: tokens.typography.bodySmall.copyWith(color: colors.onSurface),
        child: IconTheme(
          data: IconThemeData(
            color: colors.onSurface,
            size: tokens.iconSizes.medium,
          ),
          child: Stack(
            children: [
              if (backdrop != null)
                Positioned.fill(
                  // An Opacity here is a sibling of the glass rather than an
                  // ancestor, so it costs the surfaces above nothing.
                  child: entrance >= 1
                      ? backdrop!
                      : Opacity(opacity: entrance, child: backdrop!),
                ),
              SafeArea(
                child: Column(
                  children: [
                    if (title != null)
                      GlimmerTopBar(
                        title: title!,
                        action: action,
                        leading: leading,
                      ),
                    Expanded(child: body),
                    if (navigationItems.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          tokens.spacing.large,
                          tokens.spacing.small,
                          tokens.spacing.large,
                          tokens.spacing.large,
                        ),
                        child: _GlimmerNavigationStrip(
                          items: navigationItems,
                          selectedIndex: selectedIndex,
                          onChanged: onNavigationChanged,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The top bar used by [GlimmerScaffold].
class GlimmerTopBar extends StatelessWidget {
  /// Creates a Glimmer top bar.
  const GlimmerTopBar({
    super.key,
    required this.title,
    this.action,
    this.leading,
  });

  /// The bar's title.
  final String title;

  /// A widget at the end of the bar.
  final Widget? action;

  /// A widget at the start of the bar, replacing the accent mark.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;

    return Container(
      height: 68,
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing.large),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outline.withValues(alpha: 0.34)),
        ),
      ),
      child: Row(
        children: [
          leading ??
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SizedBox(width: 8, height: 26),
              ),
          SizedBox(width: tokens.spacing.medium),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tokens.typography.titleMedium
                  .copyWith(color: colors.onSurface),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// One destination in a [GlimmerScaffold]'s navigation strip.
@immutable
class GlimmerNavigationItem {
  /// Creates a navigation destination.
  const GlimmerNavigationItem({required this.label, required this.icon});

  /// The destination's name.
  final String label;

  /// The destination's icon.
  final IconData icon;
}

class _GlimmerNavigationStrip extends StatelessWidget {
  const _GlimmerNavigationStrip({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<GlimmerNavigationItem> items;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    // The outline colour is sized for a border, not for text. A destination
    // nobody has selected still has to be readable, so it uses a dimmed
    // foreground rather than the border colour.
    final unselected = colors.onSurface.withValues(alpha: 0.7);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.extraSmall),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: tokens.shapes.stadium,
        border: Border.all(color: colors.outline, width: 1.5),
      ),
      child: Row(
        // A gap between the destinations, so the selected one reads as chosen
        // rather than as one segment of a single bar. Without it the pills
        // touch and the strip looks like a divided rectangle.
        spacing: tokens.spacing.small,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final selected = index == selectedIndex;
          return Expanded(
            child: GlimmerSurface(
              borderRadius: tokens.shapes.stadium,
              padding: EdgeInsets.symmetric(vertical: tokens.spacing.small),
              focused: selected,
              semanticLabel: item.label,
              onTap: onChanged == null ? null : () => onChanged!(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item.icon,
                    size: tokens.iconSizes.small,
                    color: selected ? colors.primary : unselected,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.typography.caption.copyWith(
                      color: selected ? colors.primary : unselected,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
