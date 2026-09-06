import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'glimmer_entrance.dart';
import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';
import 'glimmer_title_chip.dart';

/// One row of a [GlimmerList].
///
/// A list item has a required primary [label] and any combination of
/// [supportingLabel], [leadingIcon] and [trailingIcon]. It does not delegate to
/// Material's `ListTile`: the layout, the selected outline and the press
/// response all belong to the Glimmer system, and borrowing Material's would
/// bring its ripple and its elevation along with it.
///
/// Glimmer says never to put a card inside a list item. If a row needs its own
/// surface, it should be a card in a [GlimmerStack] instead.
class GlimmerListItem extends StatelessWidget {
  /// Creates a Glimmer list item.
  const GlimmerListItem({
    super.key,
    required this.label,
    this.supportingLabel,
    this.leadingIcon,
    this.trailingIcon,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.color,
  });

  /// The row's primary text.
  final String label;

  /// Secondary text under [label].
  final String? supportingLabel;

  /// An icon at the start of the row.
  final IconData? leadingIcon;

  /// An icon at the end of the row.
  final IconData? trailingIcon;

  /// A widget at the start of the row, taking priority over [leadingIcon].
  final Widget? leading;

  /// A widget at the end of the row, taking priority over [trailingIcon].
  final Widget? trailing;

  /// Called on tap.
  final VoidCallback? onTap;

  /// Whether the row is selected. Selection uses Glimmer's focus treatment.
  final bool selected;

  /// Overrides the fill. Keep it consistent across a list unless you are
  /// deliberately grouping different kinds of content.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;
    final minHeight = tokens.scale == GlimmerScale.glasses ? 80.0 : 64.0;
    final leadingWidget = leading ??
        (leadingIcon == null
            ? null
            : Icon(leadingIcon, size: tokens.iconSizes.large));
    final trailingWidget = trailing ??
        (trailingIcon == null
            ? null
            : Icon(trailingIcon, size: tokens.iconSizes.small));

    return GlimmerSurface(
      focused: selected,
      onTap: onTap,
      color: color,
      // Glimmer pads a list item by one large step on every side, not by a
      // tighter vertical inset.
      padding: EdgeInsets.all(spacing.large),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: minHeight - (spacing.large * 2),
        ),
        child: Row(
          children: [
            if (leadingWidget != null) ...[
              leadingWidget,
              SizedBox(width: spacing.small),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label, style: tokens.typography.titleSmall),
                  if (supportingLabel != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      supportingLabel!,
                      style: tokens.typography.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (trailingWidget != null) ...[
              SizedBox(width: spacing.small),
              trailingWidget,
            ],
          ],
        ),
      ),
    );
  }
}

/// A vertically scrolling list of Glimmer items.
///
/// It is a thin wrapper over [ListView] that applies Glimmer's list rules:
/// [GlimmerSpacing.extraLarge] between items, an optional integrated
/// [GlimmerTitleChip] header, and a builder API so only visible rows are built.
///
/// Glimmer says to use a list when the items are of the same kind, and a
/// [GlimmerStack] when they are not or when only one should be visible at a
/// time.
class GlimmerList extends StatelessWidget {
  /// Creates a list from a builder.
  const GlimmerList.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.title,
    this.padding,
    this.spacing,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  }) : children = null;

  /// Creates a list from a fixed set of children.
  GlimmerList({
    super.key,
    required List<Widget> this.children,
    this.title,
    this.padding,
    this.spacing,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  })  : itemCount = children.length,
        itemBuilder = ((context, index) => children[index]);

  /// The fixed children, when built with the default constructor.
  final List<Widget>? children;

  /// How many rows the list has.
  final int itemCount;

  /// Builds the row at a given index.
  final IndexedWidgetBuilder itemBuilder;

  /// An integrated title chip above the first row.
  ///
  /// Glimmer prefers this over a free-standing [GlimmerTitleChip] before the
  /// list, because the integrated one scrolls with the content and keeps the
  /// spacing consistent.
  final String? title;

  /// Padding around the whole list.
  final EdgeInsetsGeometry? padding;

  /// The gap between rows. Defaults to [GlimmerSpacing.extraLarge].
  final double? spacing;

  /// An optional scroll controller.
  final ScrollController? controller;

  /// Whether the list should size itself to its content.
  final bool shrinkWrap;

  /// The scroll physics.
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final gap = spacing ?? tokens.spacing.extraLarge;
    final hasTitle = title != null;
    final total = itemCount + (hasTitle ? 1 : 0);

    return ListView.separated(
      controller: controller,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? EdgeInsets.all(tokens.spacing.large),
      itemCount: total,
      separatorBuilder: (context, index) => SizedBox(
        // The gap under an integrated title chip is the chip's own associated
        // content spacing, not the list gap.
        height: hasTitle && index == 0 ? tokens.spacing.medium : gap,
      ),
      itemBuilder: (context, index) {
        if (hasTitle && index == 0) {
          return Center(child: GlimmerTitleChip(title!));
        }
        return itemBuilder(context, hasTitle ? index - 1 : index);
      },
    );
  }
}

/// A collapsed list that shows one item at a time, with the next ones stacked
/// behind it and receding.
///
/// Glimmer uses a stack when the items are of different kinds, or when showing
/// more than one at once would cover too much of what the wearer is looking at.
/// On a phone that second reason does not apply, but the pattern still earns
/// its place: it is the right shape for a queue of notifications, a card deck
/// or a step-by-step flow.
///
/// The geometry is the published one. Items behind sit *below* the top item and
/// are revealed by [revealSize], each scaled to [GlimmerStack.nextItemScale] and
/// receding by [GlimmerStack.itemRecede] once it is fully behind. At most two
/// are visible at a time. Moving between items uses Glimmer's snap spring.
///
/// Swipe up and down to move through the items.
class GlimmerStack extends StatefulWidget {
  /// Creates a Glimmer stack.
  const GlimmerStack({
    super.key,
    required this.children,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.visibleBehind = 2,
  }) : assert(visibleBehind >= 0, 'visibleBehind cannot be negative.');

  /// The stacked items, front to back.
  final List<Widget> children;

  /// Which item starts at the front.
  final int initialIndex;

  /// Called when the front item changes.
  final ValueChanged<int>? onIndexChanged;

  /// How many items are visible behind the front one.
  ///
  /// Glimmer shows at most two, which is the default.
  final int visibleBehind;

  /// How far each item behind peeks out below the one in front of it.
  static const revealSize = 18.0;

  /// The scale of an item once it is fully behind the top one.
  static const nextItemScale = 0.94;

  /// How far an item recedes once it is fully behind the top one.
  ///
  /// Upstream this is the alpha of a black scrim drawn over that item, which is
  /// how depth is expressed on a display where black is transparent. Here it is
  /// how far the item's own surface is taken down, which is the same thing said
  /// from inside the surface rather than by covering it, and it lands between
  /// [GlimmerDepth.level4] and [GlimmerDepth.level5].
  static const itemRecede = 0.5;

  /// The spring Glimmer snaps stack items with. See
  /// [GlimmerMotion.settleSpring].
  static const snapSpring = GlimmerMotion.settleSpring;

  @override
  State<GlimmerStack> createState() => _GlimmerStackState();
}

class _GlimmerStackState extends State<GlimmerStack>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController.unbounded(vsync: this)..addListener(_onTick);
  late int _index = widget.initialIndex.clamp(
    0,
    widget.children.isEmpty ? 0 : widget.children.length - 1,
  );

  /// Where the stack currently sits, as a continuous value between item
  /// indices.
  ///
  /// Animating a position rather than swapping children is what makes the whole
  /// stack move together: every item reads its offset, scale and recede from
  /// its distance to this value, so the card behind rises and returns as
  /// the one in front leaves, instead of the two cutting.
  double _position = 0;

  @override
  void initState() {
    super.initState();
    _position = _index.toDouble();
    _controller.value = _position;
  }

  void _onTick() {
    setState(() => _position = _controller.value);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  void _move(int delta) {
    final next = (_index + delta).clamp(0, widget.children.length - 1);
    if (next == _index) return;
    setState(() => _index = next);
    _controller.animateWith(
      SpringSimulation(
        GlimmerStack.snapSpring,
        _controller.value,
        next.toDouble(),
        0,
      ),
    );
    widget.onIndexChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();

    const reveal = GlimmerStack.revealSize;
    final layers = <Widget>[];

    // Walk from the back forward, taking one extra item on each side so a card
    // entering or leaving is already built when the animation starts.
    for (var i = widget.children.length - 1; i >= 0; i--) {
      final distance = i - _position;
      if (distance < -1 || distance > widget.visibleBehind + 0.999) continue;

      // Behind the top item: sink, shrink and darken. In front of it: the card
      // is leaving, so it rises out and fades.
      final behind = distance.clamp(0.0, widget.visibleBehind.toDouble());
      final leaving = (-distance).clamp(0.0, 1.0);
      if (leaving >= 1) continue;

      final scale = 1 - ((1 - GlimmerStack.nextItemScale) * behind.clamp(0, 1));
      final recede = (behind.clamp(0, 1) * GlimmerStack.itemRecede).toDouble();
      final dy = (reveal * behind) - (leaving * reveal * 3);

      // An item behind the top one recedes rather than being darkened.
      // Glimmer's depth is transparency: on an additive display the thing
      // behind stops being drawn rather than being covered, and the card in
      // front shows the world through the gap.
      //
      // The recede has to happen from inside the surface. Wrapping a glass
      // card in an opacity or a colour-filter layer takes away the backdrop it
      // reads, so the card goes flat for as long as it is receding and snaps
      // back at the end, and the layer's own bounds show up as a rectangle
      // across the page.
      final item = IgnorePointer(
        ignoring: i != _index,
        child: GlimmerEntrance(
          progress: (1 - leaving) * (1 - recede.clamp(0.0, 1.0)),
          child: widget.children[i],
        ),
      );

      final placed = Transform.translate(
        offset: Offset(0, dy),
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: item,
        ),
      );

      if (i == _index) {
        // The item the stack is settling on is the only unpositioned child, so
        // it is what the Stack takes its size from. Everything else is
        // positioned, which keeps it out of the size calculation.
        layers.add(placed);
      } else {
        layers.add(Positioned(left: 0, right: 0, top: 0, child: placed));
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity < -200) _move(1);
        if (velocity > 200) _move(-1);
      },
      child: Semantics(
        value: '${_index + 1} / ${widget.children.length}',
        child: Padding(
          // Room for the items peeking out below, so moving between them does
          // not shift the layout around.
          padding: EdgeInsets.only(bottom: reveal * widget.visibleBehind),
          child: Stack(clipBehavior: Clip.none, children: layers),
        ),
      ),
    );
  }
}

/// Fades content out toward an edge by erasing it.
///
/// Glimmer puts one at the end of a scrolling list and over the top of a stack.
/// It does not paint the background colour over the content, it takes the
/// content's own alpha down with [BlendMode.dstOut], so whatever the app has
/// behind the list comes through rather than a band of flat colour appearing on
/// top of it. Over a [GlimmerBackdrop] that difference is the whole point.
///
/// Wrap the thing being faded:
///
/// ```dart
/// GlimmerScrim(
///   alignment: Alignment.bottomCenter,
///   child: GlimmerList(children: rows),
/// )
/// ```
class GlimmerScrim extends StatelessWidget {
  /// Creates a scrim over [child].
  const GlimmerScrim({
    super.key,
    required this.child,
    this.alignment = Alignment.bottomCenter,
    this.extent = 48,
  });

  /// The content to fade.
  final Widget child;

  /// Which edge the fade is anchored to.
  final Alignment alignment;

  /// How far the fade reaches in from that edge. Glimmer's own is 48.
  final double extent;

  @override
  Widget build(BuildContext context) {
    if (extent <= 0) return child;

    return ShaderMask(
      blendMode: BlendMode.dstOut,
      shaderCallback: (bounds) {
        final vertical = alignment.y.abs() >= alignment.x.abs();
        final span = vertical ? bounds.height : bounds.width;
        final stop = span <= 0 ? 0.0 : (extent / span).clamp(0.0, 1.0);
        return LinearGradient(
          begin: alignment,
          end: -alignment,
          colors: const [Color(0xFF000000), Color(0x00000000)],
          stops: [0, stop],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
