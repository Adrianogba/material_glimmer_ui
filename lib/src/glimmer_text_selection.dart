import 'package:flutter/material.dart';

import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// The handles, the menu and the magnifier a [GlimmerTextField] edits with.
///
/// Everything around a text field can be restyled, but the part a finger
/// actually touches usually cannot: the teardrop handles, the Cut/Copy/Paste
/// menu and the magnifier come from whichever design system the field was built
/// on. A field with a Glimmer outline and Material's handles is a Glimmer
/// screen with somebody else's fingerprints on it.
///
/// So the handles are round and lit, the menu is a glass panel like every other
/// panel in the kit, and the magnifier carries the same graded edge as a
/// surface.
///
/// [GlimmerTextField] and [GlimmerSearchField] install all three. Pass
/// [GlimmerTextSelection.controls] and [GlimmerTextSelection.contextMenuBuilder]
/// to a plain `TextField` to get them there too.
abstract final class GlimmerTextSelection {
  /// The handles at either end of a selection.
  static final TextSelectionControls controls = _GlimmerSelectionControls();

  /// Builds the selection menu as a glass panel.
  ///
  /// ```dart
  /// TextField(contextMenuBuilder: GlimmerTextSelection.contextMenuBuilder)
  /// ```
  static Widget contextMenuBuilder(
    BuildContext context,
    EditableTextState editableTextState,
  ) {
    return GlimmerTextSelectionMenu(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: editableTextState.contextMenuButtonItems,
    );
  }

  /// The magnifier shown while a handle is being dragged.
  static final TextMagnifierConfiguration magnifier =
      TextMagnifierConfiguration(
    magnifierBuilder: (context, controller, magnifierInfo) =>
        _GlimmerMagnifier(magnifierInfo: magnifierInfo),
  );

  /// The diameter of a selection handle.
  static const handleSize = 14.0;
}

// The TextSelectionHandleControls mixin is not optional. A selection overlay
// handed plain TextSelectionControls uses their old buildToolbar and ignores
// contextMenuBuilder entirely, so the handles come out right and no menu
// appears at all. The mixin is how a controls object says it draws handles and
// leaves the menu to contextMenuBuilder.
class _GlimmerSelectionControls extends TextSelectionControls
    with TextSelectionHandleControls {
  @override
  Size getHandleSize(double textLineHeight) => const Size(
        GlimmerTextSelection.handleSize * 2,
        GlimmerTextSelection.handleSize * 2,
      );

  @override
  Offset getHandleAnchor(TextSelectionHandleType type, double textLineHeight) {
    const centre = GlimmerTextSelection.handleSize;
    switch (type) {
      case TextSelectionHandleType.left:
        return const Offset(centre + 3, centre);
      case TextSelectionHandleType.right:
        return const Offset(centre - 3, centre);
      case TextSelectionHandleType.collapsed:
        return const Offset(centre, centre);
    }
  }

  @override
  Widget buildHandle(
    BuildContext context,
    TextSelectionHandleType type,
    double textLineHeight, [
    VoidCallback? onTap,
  ]) {
    final colors = GlimmerTheme.colorsOf(context);

    // A lit dot rather than a teardrop. The stem is drawn by the field's own
    // selection highlight, so the handle only has to mark where it ends.
    final handle = SizedBox(
      width: GlimmerTextSelection.handleSize * 2,
      height: GlimmerTextSelection.handleSize * 2,
      child: Center(
        child: CustomPaint(
          size: const Size.square(GlimmerTextSelection.handleSize),
          painter: _GlimmerHandlePainter(color: colors.primary),
        ),
      ),
    );

    return onTap == null
        ? handle
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onTap,
            child: handle,
          );
  }
}

class _GlimmerHandlePainter extends CustomPainter {
  const _GlimmerHandlePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    canvas
      ..drawCircle(
        centre,
        radius + 3,
        Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      )
      ..drawCircle(centre, radius, Paint()..color = color)
      ..drawCircle(
        centre,
        radius - 0.75,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.55),
      );
  }

  @override
  bool shouldRepaint(_GlimmerHandlePainter old) => old.color != color;
}

/// The Cut/Copy/Paste menu, as a glass panel.
///
/// [GlimmerTextSelection.contextMenuBuilder] builds one of these. Use it
/// directly to put the same menu on something that is not a text field, such
/// as a [SelectionArea] with its own `contextMenuBuilder`.
class GlimmerTextSelectionMenu extends StatelessWidget {
  /// Creates a selection menu.
  const GlimmerTextSelectionMenu({
    super.key,
    required this.anchors,
    required this.buttonItems,
  });

  /// Where the menu should sit, above or below the selection.
  final TextSelectionToolbarAnchors anchors;

  /// The actions to offer, in order.
  final List<ContextMenuButtonItem> buttonItems;

  @override
  Widget build(BuildContext context) {
    if (buttonItems.isEmpty) return const SizedBox.shrink();
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;

    return CustomSingleChildLayout(
      delegate: TextSelectionToolbarLayoutDelegate(
        anchorAbove: anchors.primaryAnchor,
        anchorBelow: anchors.secondaryAnchor ?? anchors.primaryAnchor,
      ),
      // The padding is outside the panel rather than inside it. The delegate
      // clamps whatever it is given to the screen, so padding the child is
      // what keeps the panel itself off the edge when the selection is near
      // one.
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing.small),
        child: GlimmerSurface(
          borderRadius: tokens.shapes.stadium,
          padding: EdgeInsets.symmetric(horizontal: tokens.spacing.extraSmall),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < buttonItems.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 18,
                    color: colors.outline.withValues(alpha: 0.5),
                  ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: buttonItems[i].onPressed,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: tokens.spacing.medium,
                      vertical: tokens.spacing.small,
                    ),
                    child: Text(
                      _labelFor(context, buttonItems[i]),
                      style: tokens.typography.bodySmall,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(BuildContext context, ContextMenuButtonItem item) {
    if (item.label != null) return item.label!;
    return AdaptiveTextSelectionToolbar.getButtonLabel(context, item);
  }
}

/// The lens shown while a handle is dragged.
///
/// Material's is a rounded rectangle with a drop shadow. This one is the same
/// shape a surface is, with the same graded edge, so the thing under a finger
/// looks like it belongs to the screen it is over.
class _GlimmerMagnifier extends StatelessWidget {
  const _GlimmerMagnifier({required this.magnifierInfo});

  final ValueNotifier<MagnifierInfo> magnifierInfo;

  /// How much bigger the text under the lens is drawn.
  static const _magnification = 1.4;

  /// The lens itself.
  static const _size = Size(96, 44);

  /// How far above the finger the lens floats.
  static const _verticalOffset = 52.0;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;

    return ValueListenableBuilder<MagnifierInfo>(
      valueListenable: magnifierInfo,
      builder: (context, info, child) {
        // Centred on the finger, held above it, and kept inside the field's
        // own bounds so the lens never wanders off the text it is magnifying.
        final centre = info.globalGesturePosition.dx.clamp(
          info.fieldBounds.left + (_size.width / 2),
          info.fieldBounds.right - (_size.width / 2),
        );
        final top = info.caretRect.top - _size.height - _verticalOffset;

        return Positioned(
          left: centre - (_size.width / 2),
          top: top,
          child: RawMagnifier(
            magnificationScale: _magnification,
            focalPointOffset: Offset(
              centre - info.globalGesturePosition.dx,
              (_size.height / 2) + _verticalOffset,
            ),
            size: _size,
            decoration: MagnifierDecoration(
              shape: RoundedRectangleBorder(
                borderRadius: tokens.shapes.small,
                side: BorderSide(
                  color: colors.outline,
                  width: GlimmerMotion.borderWidth,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
