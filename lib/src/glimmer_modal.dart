import 'dart:ui' as ui show ImageFilter;

import 'package:flutter/material.dart';

import 'glimmer_button.dart';
import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// The veil drawn over the app while a modal surface is open.
///
/// It blurs what is behind it as well as darkening it. That is the point:
/// Glimmer's surfaces are glass, so a flat black wash over the app would make
/// the panel on top read as a sticker rather than as a pane held in front of
/// something. Blurring the app is also what tells the eye which layer to read.
///
/// Glimmer has no modals, so the numbers come from the nearest thing it does
/// have: the scrim over the items behind the top of a stack, at 50%.
class GlimmerModalScrim extends StatelessWidget {
  /// Creates a modal scrim.
  const GlimmerModalScrim({
    super.key,
    required this.progress,
    this.onDismiss,
    this.semanticLabel,
  });

  /// How far in the modal is, from 0 to 1. The blur and the veil both follow
  /// it, so the app recedes as the panel arrives.
  final double progress;

  /// Called when the scrim is tapped. Null makes the modal non-dismissible.
  final VoidCallback? onDismiss;

  /// What a screen reader announces for the dismiss target.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 1.0);
    final blur = GlimmerMotion.scrimBlur * t;

    Widget scrim = DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF000000).withValues(
          alpha: GlimmerMotion.scrimOpacity * t,
        ),
      ),
      child: const SizedBox.expand(),
    );

    if (blur > 0.05) {
      scrim = BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: scrim,
      );
    }

    if (onDismiss == null) return IgnorePointer(child: scrim);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDismiss,
        child: scrim,
      ),
    );
  }
}

/// A panel that asks for an answer before anything else can happen.
///
/// Use [showGlimmerDialog] to put one on screen. Built directly, it is just the
/// panel, which is useful when a route of your own already provides the scrim.
///
/// Glimmer has no dialog. Display glasses show one thing at a time, so a panel
/// interrupting another panel has nowhere to go. A phone app needs one, and the
/// pieces to build it are all here: a surface at a high depth level over a
/// blurred app is exactly what the design language says "this, not that" with.
class GlimmerDialog extends StatelessWidget {
  /// Creates a dialog panel.
  const GlimmerDialog({
    super.key,
    this.title,
    this.content,
    this.icon,
    this.actions = const [],
    this.child,
  }) : assert(
          child != null || title != null || content != null,
          'A dialog needs a child, or a title or content.',
        );

  /// The dialog's title.
  final String? title;

  /// Supporting copy under the title.
  final String? content;

  /// An icon above the title, centred.
  final IconData? icon;

  /// The actions along the bottom, usually [GlimmerButton]s. They are laid out
  /// as a [GlimmerButtonGroup], so two of them share the width evenly.
  final List<Widget> actions;

  /// Replaces the whole slot layout.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.large),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: GlimmerSurface(
          // A dialog is the front-most thing on screen, so it takes the depth
          // level that says so rather than the one a card rests at.
          depth: tokens.depth.level4,
          padding: EdgeInsets.all(spacing.large),
          child: child ?? _slots(context, tokens),
        ),
      ),
    );
  }

  Widget _slots(BuildContext context, GlimmerTokens tokens) {
    final spacing = tokens.spacing;
    final typography = tokens.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Center(child: Icon(icon, size: tokens.iconSizes.large)),
          SizedBox(height: spacing.medium),
        ],
        if (title != null) ...[
          Text(title!, style: typography.titleMedium),
          SizedBox(height: spacing.small),
        ],
        if (content != null) Text(content!, style: typography.bodySmall),
        if (actions.isNotEmpty) ...[
          SizedBox(height: spacing.large),
          GlimmerButtonGroup(children: actions),
        ],
      ],
    );
  }
}

/// A panel that rises from the bottom of the screen.
///
/// Use [showGlimmerBottomSheet] to put one on screen.
///
/// A sheet suits Glimmer better than it suits Material: the design language is
/// bottom-aligned already, on the reasoning that whatever covers the least of
/// what you are looking at should be at the bottom.
class GlimmerBottomSheet extends StatelessWidget {
  /// Creates a bottom sheet panel.
  const GlimmerBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.showHandle = true,
  });

  /// The sheet's content.
  final Widget child;

  /// A title above the content.
  final String? title;

  /// Whether to draw the drag handle.
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;
    final colors = tokens.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        spacing.large,
        0,
        spacing.large,
        spacing.large,
      ),
      child: GlimmerSurface(
        depth: tokens.depth.level3,
        padding: EdgeInsets.all(spacing.large),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHandle) ...[
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              SizedBox(height: spacing.medium),
            ],
            if (title != null) ...[
              Text(title!, style: tokens.typography.titleMedium),
              SizedBox(height: spacing.medium),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Puts a [GlimmerDialog] on screen over a [GlimmerModalScrim].
///
/// ```dart
/// final confirmed = await showGlimmerDialog<bool>(
///   context: context,
///   builder: (context) => GlimmerDialog(
///     title: 'Leave the queue?',
///     content: 'You will lose your place.',
///     actions: [
///       GlimmerButton(
///         label: 'Stay',
///         onPressed: () => Navigator.of(context).pop(false),
///       ),
///       GlimmerButton(
///         label: 'Leave',
///         prominent: true,
///         onPressed: () => Navigator.of(context).pop(true),
///       ),
///     ],
///   ),
/// );
/// ```
Future<T?> showGlimmerDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss',
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    // The scrim is part of the transition rather than a flat barrier colour,
    // because it blurs as well as darkens and has to animate with the panel.
    barrierColor: const Color(0x00000000),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    transitionDuration: GlimmerMotion.modalDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondary, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: GlimmerMotion.focusCurve,
        reverseCurve: GlimmerMotion.focusCurve.flipped,
      );
      return _ModalLayer(
        progress: eased,
        onDismiss:
            barrierDismissible ? () => Navigator.of(context).maybePop() : null,
        barrierLabel: barrierLabel,
        alignment: Alignment.center,
        child: FadeTransition(
          opacity: eased,
          child: ScaleTransition(
            // A dialog arrives by settling into place rather than by growing
            // from nothing, so it starts close to its final size.
            scale: Tween<double>(begin: 0.94, end: 1).animate(eased),
            child: child,
          ),
        ),
      );
    },
  );
}

/// Puts a [GlimmerBottomSheet] on screen over a [GlimmerModalScrim].
///
/// The sheet can be dragged down to dismiss.
Future<T?> showGlimmerBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss',
  bool useRootNavigator = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierColor: const Color(0x00000000),
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    transitionDuration: GlimmerMotion.modalDuration,
    pageBuilder: (context, animation, secondaryAnimation) => builder(context),
    transitionBuilder: (context, animation, secondary, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: GlimmerMotion.focusCurve,
        reverseCurve: GlimmerMotion.focusCurve.flipped,
      );
      return _ModalLayer(
        progress: eased,
        onDismiss:
            barrierDismissible ? () => Navigator.of(context).maybePop() : null,
        barrierLabel: barrierLabel,
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(eased),
          child: _DraggableSheet(child: child),
        ),
      );
    },
  );
}

/// The scrim and the panel, laid out together and safe-area padded.
class _ModalLayer extends StatelessWidget {
  const _ModalLayer({
    required this.progress,
    required this.child,
    required this.alignment,
    required this.barrierLabel,
    this.onDismiss,
  });

  final Animation<double> progress;
  final Widget child;
  final Alignment alignment;
  final String barrierLabel;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, panel) {
        return Stack(
          children: [
            Positioned.fill(
              child: GlimmerModalScrim(
                progress: progress.value,
                onDismiss: onDismiss,
                semanticLabel: barrierLabel,
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                // A modal is its own route, outside whatever Material the app
                // provides, so it establishes one. Without it any Material
                // widget placed in a dialog misbehaves, and Flutter's ambient
                // text style is its error style.
                child: Material(
                  type: MaterialType.transparency,
                  child: Align(alignment: alignment, child: panel),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

/// Lets a sheet be pushed down and let go.
class _DraggableSheet extends StatefulWidget {
  const _DraggableSheet({required this.child});

  final Widget child;

  @override
  State<_DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<_DraggableSheet> {
  var _offset = 0.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragUpdate: (details) {
        // Downward only. Dragging up does nothing rather than lifting the sheet
        // off the bottom edge it is anchored to.
        setState(() => _offset = (_offset + details.delta.dy).clamp(0, 600));
      },
      onVerticalDragEnd: (details) {
        final velocity = details.primaryVelocity ?? 0;
        if (velocity > 700 || _offset > 96) {
          Navigator.of(context).maybePop();
          return;
        }
        setState(() => _offset = 0);
      },
      child: AnimatedSlide(
        offset: Offset(0, _offset / 400),
        duration: _offset == 0 ? GlimmerMotion.modalDuration : Duration.zero,
        curve: GlimmerMotion.focusCurve,
        child: widget.child,
      ),
    );
  }
}
