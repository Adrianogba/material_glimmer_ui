import 'dart:async';

import 'package:flutter/material.dart';

import 'glimmer_entrance.dart';
import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_theme.dart';

/// A brief message that appears over the app and leaves on its own.
///
/// Show one with [showGlimmerSnackbar]. Built directly it is just the pill,
/// which is useful for putting a message somewhere other than the bottom of the
/// screen.
///
/// Glimmer has no snackbar, but it does have a shape for this: everything
/// transient in the language is a stadium-edged pill, so that is what a message
/// is. It sits above the content and below a modal.
class GlimmerSnackbar extends StatelessWidget {
  /// Creates a snackbar pill.
  const GlimmerSnackbar({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'An action needs both a label and a callback.',
        );

  /// The message.
  final String message;

  /// An icon before the message.
  final IconData? icon;

  /// The label of the single trailing action.
  final String? actionLabel;

  /// Called when the action is tapped. The snackbar dismisses itself first.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final spacing = tokens.spacing;

    return GlimmerSurface(
      borderRadius: tokens.shapes.stadium,
      padding: EdgeInsets.symmetric(
        horizontal: spacing.large,
        vertical: spacing.medium,
      ),
      semanticLabel: message,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: tokens.iconSizes.small),
            SizedBox(width: spacing.small),
          ],
          Flexible(
            child: Text(
              message,
              style: tokens.typography.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (actionLabel != null) ...[
            SizedBox(width: spacing.medium),
            GestureDetector(
              onTap: onAction,
              behavior: HitTestBehavior.opaque,
              child: Text(
                actionLabel!,
                style: tokens.typography.titleSmall.copyWith(
                  color: tokens.colors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shows a [GlimmerSnackbar] over the app and removes it when [duration] is up.
///
/// Only one is on screen at a time. Showing a second replaces the first rather
/// than queueing behind it, on the reasoning that the newer message is the one
/// worth reading and a queue makes the app feel like it is talking to itself.
///
/// Pass [bottomInset] to lift the pill above something the app keeps at the
/// bottom of the screen, such as a [GlimmerScaffold]'s navigation strip. The
/// library cannot know what is down there, so it does not guess.
///
/// Returns a handle that dismisses it early.
GlimmerSnackbarHandle showGlimmerSnackbar(
  BuildContext context, {
  required String message,
  IconData? icon,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
  double bottomInset = 0,
  bool useRootOverlay = true,
}) {
  final overlay = Overlay.of(context, rootOverlay: useRootOverlay);
  return _GlimmerSnackbarHost.show(
    overlay,
    message: message,
    icon: icon,
    actionLabel: actionLabel,
    onAction: onAction,
    duration: duration,
    bottomInset: bottomInset,
  );
}

/// A handle to a snackbar that is on screen.
class GlimmerSnackbarHandle {
  GlimmerSnackbarHandle._(this._dismiss);

  final void Function() _dismiss;
  var _done = false;

  /// Takes the snackbar off screen now. Safe to call more than once.
  void dismiss() {
    if (_done) return;
    _done = true;
    _dismiss();
  }
}

/// Owns the single entry that is on screen, per overlay.
class _GlimmerSnackbarHost {
  static final _current = Expando<_GlimmerSnackbarEntry>();

  static GlimmerSnackbarHandle show(
    OverlayState overlay, {
    required String message,
    required Duration duration,
    required double bottomInset,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _current[overlay]?.remove();

    late final _GlimmerSnackbarEntry entry;
    entry = _GlimmerSnackbarEntry(
      overlay: overlay,
      onRemoved: () {
        if (identical(_current[overlay], entry)) _current[overlay] = null;
      },
    );
    _current[overlay] = entry;

    entry.insert(
      duration: duration,
      bottomInset: bottomInset,
      builder: (context) => GlimmerSnackbar(
        message: message,
        icon: icon,
        actionLabel: actionLabel,
        onAction: onAction == null
            ? null
            : () {
                entry.remove();
                onAction();
              },
      ),
    );

    return GlimmerSnackbarHandle._(entry.remove);
  }
}

class _GlimmerSnackbarEntry {
  _GlimmerSnackbarEntry({required this.overlay, required this.onRemoved});

  final OverlayState overlay;
  final VoidCallback onRemoved;
  OverlayEntry? _entry;
  Timer? _timer;
  final _dismissing = ValueNotifier<bool>(false);

  void insert({
    required WidgetBuilder builder,
    required Duration duration,
    required double bottomInset,
  }) {
    _entry = OverlayEntry(
      builder: (context) => _GlimmerSnackbarLayer(
        dismissing: _dismissing,
        onGone: _dispose,
        bottomInset: bottomInset,
        child: Builder(builder: builder),
      ),
    );
    overlay.insert(_entry!);
    _timer = Timer(duration, remove);
  }

  void remove() {
    _timer?.cancel();
    if (_entry == null) return;
    _dismissing.value = true;
  }

  void _dispose() {
    _timer?.cancel();
    _entry?.remove();
    _entry = null;
    _dismissing.dispose();
    onRemoved();
  }
}

/// Positions the pill and animates it in and out.
///
/// The animation is driven by a controller started in `initState` rather than
/// by an implicit animation waiting on a post-frame callback. That callback
/// costs a frame, and for that frame the pill is parked off the bottom of the
/// screen where it is neither visible nor tappable.
class _GlimmerSnackbarLayer extends StatefulWidget {
  const _GlimmerSnackbarLayer({
    required this.dismissing,
    required this.child,
    required this.onGone,
    required this.bottomInset,
  });

  final ValueNotifier<bool> dismissing;
  final Widget child;
  final VoidCallback onGone;
  final double bottomInset;

  @override
  State<_GlimmerSnackbarLayer> createState() => _GlimmerSnackbarLayerState();
}

class _GlimmerSnackbarLayerState extends State<_GlimmerSnackbarLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: GlimmerMotion.modalDuration,
  );
  late final Animation<double> _eased = CurvedAnimation(
    parent: _controller,
    curve: GlimmerMotion.focusCurve,
    reverseCurve: GlimmerMotion.focusCurve.flipped,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    widget.dismissing.addListener(_onDismissing);
  }

  void _onDismissing() {
    if (!widget.dismissing.value) return;
    _controller.reverse().whenComplete(widget.onGone);
  }

  @override
  void dispose() {
    widget.dismissing.removeListener(_onDismissing);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);

    return Positioned(
      left: tokens.spacing.large,
      right: tokens.spacing.large,
      bottom: tokens.spacing.large +
          widget.bottomInset +
          MediaQuery.paddingOf(context).bottom,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1.4),
          end: Offset.zero,
        ).animate(_eased),
        // The pill is glass, so it arrives through GlimmerEntrance rather than
        // a FadeTransition. It also lives in the overlay, above whatever
        // Material the app provides, so it establishes its own.
        child: AnimatedBuilder(
          animation: _eased,
          builder: (context, child) => GlimmerEntrance(
            progress: _eased.value,
            child: child!,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
