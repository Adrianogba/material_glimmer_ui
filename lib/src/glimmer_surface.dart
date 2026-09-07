import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui show ImageFilter;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'glimmer_depth.dart';
import 'glimmer_entrance.dart';
import 'glimmer_edge.dart';
import 'glimmer_motion.dart';
import 'glimmer_theme.dart';
import 'glimmer_tone.dart';

/// The Glimmer building block every other component is made of.
///
/// A surface is glass. It does not paint a colour over the background, it
/// filters the background: whatever sits behind it is blurred and then tinted,
/// so the colour, the texture and the movement underneath still come through.
/// That is why every Glimmer screen wants a [GlimmerBackdrop] rather than a
/// flat fill.
///
/// The edge is lit rather than drawn. A single flat stroke reads as an outline
/// around a box; this border is brightest where it faces the light and
/// almost gone on the opposite side, which is what makes a panel read as a
/// piece of glass catching a highlight.
///
/// Three interaction states:
///
///  * **Resting.** A 1.5 px lit edge in [GlimmerColors.outline].
///  * **Focused.** Over 800 ms the edge grows to 2 px and turns the focal
///    colour and the tint brightens, so the surface reads as turning toward
///    the light. Leaving focus takes 500 ms.
///  * **Pressed.** A white overlay at 16%, sprung in and out, held for at least
///    300 ms so a quick tap is still seen.
///
/// There is no roving focus, so [focused] is driven by whatever selection your
/// screen already has. Keyboard focus feeds into the same treatment for anyone
/// using an external keyboard or a switch device.
///
/// Touch does not draw a ripple. The press state is a flat overlay, and mixing
/// the two reads as two systems arguing.
///
/// Nothing is painted around a surface to say how high it sits. Depth in
/// Glimmer is not a shadow cast by the thing in front, it is the plane behind
/// withdrawing, so it lives on [GlimmerDepthLevel] and is applied by whatever
/// owns both planes: [GlimmerStack] for a stack, [GlimmerModalScrim] for a
/// modal.
class GlimmerSurface extends StatefulWidget {
  /// Creates a Glimmer surface around [child].
  const GlimmerSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.focused = false,
    this.onTap,
    this.onLongPress,
    this.enableAmbientPulse = false,
    this.color,
    this.focusedColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius,
    this.opacity,
    this.blur,
    this.additive,
    this.semanticLabel,
    this.autofocus = false,
    this.focusNode,
  });

  /// The surface content.
  final Widget child;

  /// Space between the border and [child].
  final EdgeInsetsGeometry padding;

  /// Whether the surface is in its focused state.
  ///
  /// Keyboard focus is detected separately and produces the same treatment, so
  /// a surface reading `false` here can still show as focused.
  final bool focused;

  /// Called on tap. When null the surface is inert and draws no press state.
  final VoidCallback? onTap;

  /// Called on long press.
  final VoidCallback? onLongPress;

  /// Runs the slow ambient sweep while the surface is focused.
  ///
  /// A bright highlight travels once around the lit edge. It is the moment the
  /// kit is named after, and it is off by default: a permanently animating
  /// element costs battery, competes with the content and is a problem for
  /// anyone who has asked for reduced motion. Turn it on for a single hero
  /// element, not for every row in a list.
  final bool enableAmbientPulse;

  /// The resting tint. Defaults to [GlimmerColors.surface].
  final Color? color;

  /// The focused tint. Defaults to [color] lightened toward the focal colour.
  final Color? focusedColor;

  /// The resting edge colour. Defaults to [GlimmerColors.outline].
  final Color? borderColor;

  /// The focused edge colour. Defaults to [GlimmerColors.primary].
  final Color? focusedBorderColor;

  /// The corner radius. Defaults to [GlimmerShapes.medium].
  final BorderRadius? borderRadius;

  /// Overrides [GlimmerTokens.surfaceOpacity] for this surface.
  ///
  /// Pass 1 for a panel that has to hide what is under it.
  final double? opacity;

  /// Overrides [GlimmerTokens.surfaceBlur] for this surface.
  ///
  /// Pass 0 on the rows of a long list. A blur costs a compositing pass each,
  /// and a list that scrolls is the one place that cost is felt.
  final double? blur;

  /// Overrides [GlimmerTokens.additive] for this surface.
  final bool? additive;

  /// The accessibility label. Without one the surface is announced by its
  /// content.
  final String? semanticLabel;

  /// Whether to take keyboard focus on mount.
  final bool autofocus;

  /// An external focus node, when the caller needs to drive focus itself.
  final FocusNode? focusNode;

  @override
  State<GlimmerSurface> createState() => _GlimmerSurfaceState();
}

class _GlimmerSurfaceState extends State<GlimmerSurface>
    with TickerProviderStateMixin {
  late final AnimationController _pressController;
  late final AnimationController _ambientController;
  Timer? _pressReleaseTimer;
  Timer? _ambientTimer;
  DateTime? _pressStartedAt;
  var _hasKeyboardFocus = false;

  bool get _isFocused => widget.focused || _hasKeyboardFocus;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController.unbounded(vsync: this);
    _ambientController = AnimationController(
      vsync: this,
      duration: GlimmerMotion.ambientPulseDuration,
    );
    _syncAmbientPulse();
  }

  @override
  void didUpdateWidget(covariant GlimmerSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focused != widget.focused ||
        oldWidget.enableAmbientPulse != widget.enableAmbientPulse) {
      _syncAmbientPulse();
    }
  }

  @override
  void dispose() {
    _pressReleaseTimer?.cancel();
    _ambientTimer?.cancel();
    _pressController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _handlePressStart() {
    _pressReleaseTimer?.cancel();
    _pressStartedAt = DateTime.now();
    _pressController.animateWith(
      SpringSimulation(
        GlimmerMotion.pressEnterSpring,
        _pressController.value,
        1,
        0,
      ),
    );
  }

  void _handlePressEnd() {
    final elapsed = DateTime.now().difference(
      _pressStartedAt ?? DateTime.now(),
    );
    final remaining = GlimmerMotion.minimumPressDuration - elapsed;
    _pressReleaseTimer?.cancel();
    _pressReleaseTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        if (!mounted) return;
        _pressController.animateWith(
          SpringSimulation(
            GlimmerMotion.pressExitSpring,
            _pressController.value,
            0,
            0,
          ),
        );
      },
    );
  }

  void _syncAmbientPulse() {
    _ambientTimer?.cancel();
    _ambientController.stop();
    _ambientController.value = 0;
    if (widget.enableAmbientPulse && _isFocused) {
      _ambientTimer = Timer(
        GlimmerMotion.ambientInitialDelay,
        _runAmbientPulse,
      );
    }
  }

  void _runAmbientPulse() {
    if (!mounted || !_isFocused || !widget.enableAmbientPulse) return;
    _ambientController.forward(from: 0).whenComplete(() {
      if (!mounted || !_isFocused || !widget.enableAmbientPulse) return;
      _ambientController.value = 0;
      _ambientTimer = Timer(GlimmerMotion.ambientRepeatDelay, _runAmbientPulse);
    });
  }

  /// Resolves the four corner colours of the border for this frame.
  ///
  /// The resting and focused edges cross-fade, and on top of that both the
  /// focus transition and the ambient sweep drive every corner toward white.
  /// The focus flash peaks exactly halfway through the transition, so a surface
  /// glints once as it is chosen rather than simply arriving lit.
  GlimmerEdge _edgeFor({
    required double focusProgress,
    required double ambient,
    required Color focal,
    required Color? override,
    required Color? fill,
    required Brightness brightness,
  }) {
    final GlimmerEdge idle;
    if (override != null) {
      idle = GlimmerEdge(
        topLeft: override,
        topRight: override,
        bottomRight: override,
        bottomLeft: override,
      );
    } else if (fill != null) {
      // A surface with a fill of its own gets an edge derived from that fill,
      // so the border reads as light landing on the colour rather than as a
      // grey ring with a colour of its own.
      idle = GlimmerEdge.onFill(fill);
    } else {
      idle = brightness == Brightness.dark
          ? const GlimmerEdge.idle()
          : const GlimmerEdge.idleLight();
    }
    final light = brightness == Brightness.light;
    final edge = GlimmerEdge.lerp(
      idle,
      light ? GlimmerEdge.focusedLight(focal) : GlimmerEdge.focused(focal),
      focusProgress,
    );
    final focusPulse = (1 - (2 * (focusProgress - 0.5).abs())).clamp(0.0, 1.0);

    // The sweep and the focus flash brighten toward white on a dark ground,
    // which is where the language comes from. On a light one white is the
    // ground, so brightening washes the ring out and the alternative, dulling
    // toward black, is a smudge. The flash goes to the focal colour instead:
    // the same event said as colour rather than as lightness.
    return edge.blendToward(
      light ? focal : const Color(0xFFFFFFFF),
      math.max(ambient, focusPulse) * (light ? 0.55 : 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final radius = widget.borderRadius ?? tokens.shapes.medium;
    final enabled = widget.onTap != null || widget.onLongPress != null;
    final additive = widget.additive ?? tokens.additive;
    // A surface arrives by scaling its own tint, blur and edge rather
    // than by being faded. An opacity layer would take the backdrop away from
    // it for the whole animation and hand it back in one frame at the end.
    final entrance = GlimmerEntrance.of(context);
    final opacity =
        (widget.opacity ?? tokens.surfaceOpacity).clamp(0.0, 1.0) * entrance;
    final blur = (widget.blur ?? tokens.surfaceBlur) * entrance;

    // Glimmer states its fills as tones rather than as hex values: a surface is
    // its base colour at tone 20 and a focused one the same colour at tone 34.
    // Deriving them keeps a re-skinned palette behaving the way the published
    // one does, instead of only the default looking right.
    // Opacity softens the surface role so a card lets more of the backdrop
    // through. A colour the caller passed is a decision, not a default, so a
    // prominent or semantic fill keeps its full strength.
    final baseTint = widget.color ?? colors.surface;
    final tintOpacity =
        widget.color == null || widget.opacity != null ? opacity : 1.0;
    final restingTint = baseTint.withValues(alpha: baseTint.a * tintOpacity);
    final focusedTint = widget.focusedColor ??
        baseTint
            .withTone(baseTint.tone + _focusedToneLift)
            .withValues(alpha: baseTint.a * tintOpacity);
    final focalEdge = widget.focusedBorderColor ?? colors.primary;
    final contentColor = colors.contentColorFor(widget.color ?? colors.surface);

    return Semantics(
      button: enabled,
      selected: widget.focused,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        // Enter and Space used to reach the surface through InkWell's own
        // actions. Nothing else here listens for them, so the surface says so
        // itself, which is what keyboard and switch users activate it with.
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        onFocusChange: (hasFocus) {
          if (_hasKeyboardFocus == hasFocus) return;
          setState(() => _hasKeyboardFocus = hasFocus);
          _syncAmbientPulse();
        },
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: _isFocused ? 1 : 0),
          duration: _isFocused
              ? GlimmerMotion.focusEnterDuration
              : GlimmerMotion.focusExitDuration,
          curve: GlimmerMotion.focusCurve,
          builder: (context, focusProgress, child) {
            return AnimatedBuilder(
              animation: Listenable.merge([
                _pressController,
                _ambientController,
              ]),
              builder: (context, child) {
                final ambient = widget.enableAmbientPulse
                    ? GlimmerMotion.ambientEnvelope(_ambientController.value)
                    : 0.0;
                final pressed = _pressController.value.clamp(0.0, 1.0);
                final tint =
                    Color.lerp(restingTint, focusedTint, focusProgress)!;

                // The tint is a filter over the backdrop, not a fill painted on
                // top of it. Composing it with the blur keeps both in the one
                // pass that actually reads what is behind the surface. Painting
                // the colour into a child layer instead would silently lose the
                // backdrop, and a plus blend against nothing is just a fill.
                final ui.ImageFilter filter = blur <= 0
                    ? ColorFilter.mode(
                        tint,
                        additive ? BlendMode.plus : BlendMode.srcOver,
                      )
                    : ui.ImageFilter.compose(
                        outer: ColorFilter.mode(
                          tint,
                          additive ? BlendMode.plus : BlendMode.srcOver,
                        ),
                        inner: ui.ImageFilter.blur(
                          sigmaX: blur,
                          sigmaY: blur,
                        ),
                      );

                return CustomPaint(
                  foregroundPainter: _GlimmerSurfaceEdge(
                    radius: radius,
                    edge: _edgeFor(
                      focusProgress: focusProgress,
                      ambient: ambient,
                      focal: focalEdge,
                      override: widget.borderColor,
                      fill:
                          widget.color == colors.surface ? null : widget.color,
                      brightness: colors.brightness,
                    ).scaleAlpha(entrance),
                    // The soft pass is a bloom, and a bloom made of light sits
                    // well on a dark ground. On a light one the same pass is
                    // made of shadow, and at full strength it reads as a
                    // smudge that widens every time focus arrives or leaves.
                    bloom: colors.brightness == Brightness.dark ? 1.0 : 0.35,
                    edgeWidth: lerpDouble(
                      GlimmerMotion.borderWidth,
                      GlimmerMotion.focusedBorderWidth,
                      focusProgress,
                    )!,
                    focusProgress: focusProgress,
                    ambient: ambient,
                    pressedOpacity:
                        GlimmerMotion.pressedOverlayOpacity * pressed,
                  ),
                  // A surface is a pane, not a decoration: a touch that lands
                  // on it stops there even where the content has a gap. The
                  // shape used to absorb hits only as a side effect of the
                  // shadow painter behind it, so removing that painter would
                  // otherwise let a tap on the blank part of a dialog fall
                  // through to the scrim and dismiss it.
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    child: ClipRRect(
                      borderRadius: radius,
                      child: BackdropFilter(filter: filter, child: child),
                    ),
                  ),
                );
              },
              child: child,
            );
          },
          // The style replaces the ambient one rather than merging into it,
          // the way Material's own Material does. Merging looks equivalent
          // until a surface is used outside any Material, where the ambient
          // style is Flutter's red monospace error style: a merge keeps its
          // underline and its typeface and only changes the size and colour.
          //
          // Glimmer's ambient text style is bodySmall and its ambient icon size
          // is medium. Components that want something else say so.
          child: _GlimmerSurfaceGesture(
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            onPressStart: enabled ? _handlePressStart : null,
            onPressEnd: enabled ? _handlePressEnd : null,
            child: DefaultTextStyle(
              style: tokens.typography.bodySmall.copyWith(
                color: contentColor,
                decoration: TextDecoration.none,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: contentColor,
                  size: tokens.iconSizes.medium,
                ),
                // The content is faded, not the surface. This sits inside
                // the backdrop filter, so fading it costs nothing.
                child: Opacity(
                  opacity: entrance,
                  child: Padding(
                    padding: widget.padding,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Routes taps and presses to the surface's own states.
///
/// An [InkWell] with every overlay turned off would do the same job, and used
/// to. It also drags in Material's highlight, hover and focus machinery for
/// effects that are all disabled, and needs a [Material] ancestor to exist at
/// all, which meant every interactive surface planted one. This is the part
/// that was actually being used.
class _GlimmerSurfaceGesture extends StatelessWidget {
  const _GlimmerSurfaceGesture({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onPressStart,
    this.onPressEnd,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPressStart;
  final VoidCallback? onPressEnd;

  @override
  Widget build(BuildContext context) {
    if (onTap == null && onLongPress == null) return child;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        onTapDown: onPressStart == null ? null : (_) => onPressStart!(),
        onTapUp: onPressEnd == null ? null : (_) => onPressEnd!(),
        onTapCancel: onPressEnd,
        child: child,
      ),
    );
  }
}

/// Draws the press overlay and the graded, progressively blurred border.
class _GlimmerSurfaceEdge extends CustomPainter {
  const _GlimmerSurfaceEdge({
    required this.radius,
    required this.edge,
    required this.edgeWidth,
    required this.focusProgress,
    required this.ambient,
    required this.pressedOpacity,
    this.bloom = 1,
  });

  final BorderRadius radius;
  final GlimmerEdge edge;
  final double edgeWidth;
  final double focusProgress;
  final double ambient;
  final double pressedOpacity;

  /// How strongly the soft pass reads, from 0 to 1.
  final double bloom;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = radius.toRRect(rect);

    if (pressedOpacity > 0) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFFFFFFF).withValues(alpha: pressedOpacity),
      );
    }

    // Glimmer blurs its border progressively: crisp where the light lands and
    // soft on the far side. One stroke cannot vary its blur along its own
    // length, so it is drawn twice. The soft pass covers the whole perimeter at
    // the far-side radius, and the crisp pass fades out away from the lit
    // corner so only that arc reads as sharp.
    //
    // Both are clipped to the surface. Glimmer's border is an inner one, with
    // its outer edge on the component's boundary, and without the clip a
    // blurred stroke blooms outside the shape and pools wherever the gradient
    // is brightest.
    canvas
      ..save()
      ..clipRRect(rrect);
    final gradient = edge.toGradient(focusProgress: focusProgress);

    // The soft pass sits under the sharp one and only supplies the bloom.
    //
    // Its strength has to come from the gradient's own alpha. A Paint ignores
    // its color once it carries a shader, so scaling the stroke by setting
    // paint.color does nothing at all.
    _stroke(
      canvas,
      rrect,
      width: edgeWidth * 2,
      shader: (bloom >= 1 ? edge : edge.scaleAlpha(bloom))
          .toGradient(focusProgress: focusProgress)
          .createShader(rect),
      sigma: GlimmerEdgeBlur.resolve(focusProgress, ambient) / 3,
    );

    // The sharp pass carries the shape of the edge, so it is drawn at the
    // published width with no blur at all. It is what makes the gradient
    // readable all the way round rather than only where it is brightest.
    _stroke(
      canvas,
      rrect,
      width: edgeWidth,
      shader: gradient.createShader(rect),
      sigma: 0,
    );
    canvas.restore();
  }

  void _stroke(
    Canvas canvas,
    RRect rrect, {
    required double width,
    required Shader shader,
    required double sigma,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = shader;
    if (sigma > 0.1) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);
    }
    canvas.drawRRect(rrect.deflate(width / 2), paint);
  }

  @override
  bool shouldRepaint(_GlimmerSurfaceEdge old) =>
      old.radius != radius ||
      old.edge != edge ||
      old.edgeWidth != edgeWidth ||
      old.focusProgress != focusProgress ||
      old.ambient != ambient ||
      old.pressedOpacity != pressedOpacity ||
      old.bloom != bloom;
}

/// Glimmer lifts a focused surface from tone 20 to tone 34.
const _focusedToneLift = 14.0;
