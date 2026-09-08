import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'glimmer_icon_button.dart';
import 'glimmer_motion.dart';
import 'glimmer_surface.dart';
import 'glimmer_text_selection.dart';
import 'glimmer_theme.dart';

/// A text field styled to match Glimmer.
///
/// A Material `TextField` dropped into a Glimmer screen brings a filled or
/// underlined decoration that belongs to a different system, so this is a
/// border-led field built from the Glimmer tokens: the resting outline, the
/// focal colour on focus, and the same border widths as every other surface.
class GlimmerTextField extends StatefulWidget {
  /// Creates a Glimmer text field.
  const GlimmerTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.suffix,
    this.autofocus = false,
    this.textInputAction,
  });

  /// An external controller for the field's text.
  final TextEditingController? controller;

  /// The floating label.
  final String? label;

  /// Placeholder text shown while the field is empty.
  final String? hint;

  /// An icon at the start of the field.
  final IconData? prefixIcon;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// A widget at the end of the field, inside its outline.
  final Widget? suffix;

  /// Whether the field takes focus as soon as it appears.
  final bool autofocus;

  /// What the keyboard's action key does.
  final TextInputAction? textInputAction;

  /// Whether to hide the text, for passwords.
  final bool obscureText;

  /// Which keyboard to show.
  final TextInputType? keyboardType;

  /// How many lines the field may grow to.
  final int? maxLines;

  @override
  State<GlimmerTextField> createState() => _GlimmerTextFieldState();
}

class _GlimmerTextFieldState extends State<GlimmerTextField> {
  late final FocusNode _focusNode = FocusNode()..addListener(_onFocusChange);
  var _focused = false;

  void _onFocusChange() {
    if (_focused == _focusNode.hasFocus) return;
    setState(() => _focused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final spacing = tokens.spacing;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.symmetric(horizontal: spacing.large),
      decoration: BoxDecoration(
        color: _focused
            ? Color.lerp(colors.surface, colors.primary, 0.12)
            : colors.surface,
        borderRadius: tokens.shapes.medium,
        border: Border.all(
          color: _focused ? colors.primary : colors.outline,
          width: _focused ? 2 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.prefixIcon != null) ...[
            Icon(
              widget.prefixIcon,
              size: tokens.iconSizes.small,
              color: _focused ? colors.primary : colors.outline,
            ),
            SizedBox(width: spacing.small),
          ],
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                textInputAction: widget.textInputAction,
                // The part a finger actually touches. Without these the field
                // has a Glimmer outline and Material's handles, menu and
                // magnifier inside it.
                selectionControls: GlimmerTextSelection.controls,
                contextMenuBuilder: GlimmerTextSelection.contextMenuBuilder,
                magnifierConfiguration: GlimmerTextSelection.magnifier,
                onChanged: widget.onChanged,
                onSubmitted: widget.onSubmitted,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                maxLines: widget.maxLines,
                cursorColor: colors.primary,
                style: tokens.typography.bodyMedium
                    .copyWith(color: colors.onSurface),
                decoration: InputDecoration(
                  labelText: widget.label,
                  hintText: widget.hint,
                  isDense: true,
                  labelStyle: tokens.typography.bodySmall.copyWith(
                    color: _focused ? colors.primary : colors.outline,
                  ),
                  hintStyle: tokens.typography.bodySmall.copyWith(
                    color: colors.outline,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: spacing.medium,
                  ),
                ),
              ),
            ),
          ),
          if (widget.suffix != null) ...[
            SizedBox(width: spacing.small),
            widget.suffix!,
          ],
        ],
      ),
    );
  }
}

/// A switch, drawn as a lit track with a lit thumb.
///
/// [GlimmerToggleButton] is the other way to say on and off, and it changes
/// colour rather than sliding a thumb. A settings screen usually wants the
/// sliding kind.
///
/// Material fills the track and slides an opaque disc along it. Here the track
/// is a [GlimmerSurface], so it carries the same lit edge and the same press
/// state as everything else, and turning it on is the focus treatment rather
/// than a fill swapping colour. The thumb is the slider's thumb at switch size:
/// a dot with a halo under it that grows as it lights.
///
/// ```dart
/// GlimmerSwitch(
///   value: immersive,
///   label: 'Immersive controls',
///   onChanged: (value) => setState(() => immersive = value),
/// )
/// ```
class GlimmerSwitch extends StatelessWidget {
  /// Creates a Glimmer switch.
  const GlimmerSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  /// Whether the switch is on.
  final bool value;

  /// Called with the new value on tap. When null the switch is disabled.
  final ValueChanged<bool>? onChanged;

  /// The accessibility label.
  final String? label;

  /// The track's size.
  static const trackSize = Size(58, 34);

  /// The thumb's diameter when the switch is off.
  static const thumbSize = 18.0;

  /// How much bigger the thumb gets once the switch is on.
  static const onThumbScale = 1.15;

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final enabled = onChanged != null;

    return Semantics(
      toggled: value,
      enabled: enabled,
      label: label,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.42,
        child: GlimmerSurface(
          focused: value,
          blur: 0,
          borderRadius: tokens.shapes.stadium,
          padding: EdgeInsets.zero,
          onTap: enabled ? () => onChanged!(!value) : null,
          child: SizedBox(
            width: trackSize.width,
            height: trackSize.height,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: value ? 1 : 0),
              duration: GlimmerMotion.focusExitDuration,
              curve: GlimmerMotion.focusCurve,
              builder: (context, progress, child) => CustomPaint(
                painter: _GlimmerSwitchPainter(
                  progress: progress,
                  on: colors.primary,
                  off: colors.outline,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlimmerSwitchPainter extends CustomPainter {
  const _GlimmerSwitchPainter({
    required this.progress,
    required this.on,
    required this.off,
  });

  final double progress;
  final Color on;
  final Color off;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.clamp(0.0, 1.0);
    final radius = (GlimmerSwitch.thumbSize / 2) *
        (1 + ((GlimmerSwitch.onThumbScale - 1) * t));
    final inset = (GlimmerSwitch.trackSize.height / 2);
    final travel = size.width - (inset * 2);
    final centre = Offset(inset + (travel * t), size.height / 2);
    final colour = Color.lerp(off, on, t)!;

    // The halo is what makes the thumb read as lit rather than as a disc. It
    // is the same glow the slider puts under its thumb while it is held.
    if (t > 0) {
      canvas.drawCircle(
        centre,
        radius + (7 * t),
        Paint()
          ..color = colour.withValues(alpha: 0.3 * t)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    canvas
      ..drawCircle(centre, radius, Paint()..color = colour)
      ..drawCircle(
        centre,
        radius - 0.75,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.4 * t),
      );
  }

  @override
  bool shouldRepaint(_GlimmerSwitchPainter old) =>
      old.progress != progress || old.on != on || old.off != off;
}

/// A progress bar drawn as a lit track.
///
/// Pass a [value] between 0 and 1 for determinate progress, or leave it null
/// for an indeterminate one.
///
/// The determinate bar is the slider's track without its thumb: the same
/// stadium shape, the same graded edge, and a fill in the focal colour with a
/// glow at its leading end so the bar reads as light arriving rather than as a
/// box growing.
///
/// The indeterminate bar does not slide a block along the track, which is how
/// every other system says "still working". A highlight travels the track and
/// tapers at both ends, the same light that runs around a surface's edge during
/// the ambient sweep, so waiting looks like the rest of the language.
class GlimmerProgressBar extends StatefulWidget {
  /// Creates a progress bar.
  const GlimmerProgressBar({super.key, this.value, this.height = 8});

  /// Progress between 0 and 1, or null for indeterminate.
  final double? value;

  /// The bar's thickness.
  final double height;

  /// How long the indeterminate highlight takes to cross the track once.
  static const sweepDuration = Duration(milliseconds: 1400);

  @override
  State<GlimmerProgressBar> createState() => _GlimmerProgressBarState();
}

class _GlimmerProgressBarState extends State<GlimmerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: GlimmerProgressBar.sweepDuration,
  );

  @override
  void initState() {
    super.initState();
    _syncSweep();
  }

  @override
  void didUpdateWidget(GlimmerProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSweep();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  void _syncSweep() {
    if (widget.value == null) {
      if (!_sweep.isAnimating) _sweep.repeat();
    } else if (_sweep.isAnimating) {
      _sweep.stop();
      _sweep.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = GlimmerTheme.of(context);
    final colors = tokens.colors;
    final value = widget.value;

    return Semantics(
      value: value == null ? null : '${(value * 100).round()}%',
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, child) => CustomPaint(
            painter: _GlimmerProgressPainter(
              value: value,
              sweep: _sweep.value,
              track: colors.surface,
              active: colors.primary,
              edge: colors.outline,
              tint: colors.highlightTint,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlimmerProgressPainter extends CustomPainter {
  const _GlimmerProgressPainter({
    required this.value,
    required this.sweep,
    required this.track,
    required this.active,
    required this.edge,
    required this.tint,
  });

  final double? value;
  final double sweep;
  final Color track;
  final Color active;
  final Color edge;

  /// Which way contrast runs on this ground. See
  /// [GlimmerColors.highlightTint]: the crest of a highlight is a step toward
  /// this, not a step toward white, because on a light track a whiter blue is
  /// less visible rather than more.
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(999));

    // The bloom goes down first and outside the clip. Light that cannot leave
    // the track is not a glow, it is a softer stretch of track, which is what
    // it looked like when this was drawn inside the clip with everything else.
    if (value == null) _sweepBloom(canvas, size);

    // The same track and graded edge the slider carries, so a bar in a list of
    // surfaces reads as part of the system rather than as a plain rule.
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRRect(rrect, Paint()..color = track);

    final progress = value;
    if (progress == null) {
      _sweepHighlight(canvas, size);
    } else if (progress > 0) {
      _fill(canvas, size, progress.clamp(0.0, 1.0));
    }

    canvas
      ..restore()
      ..drawRRect(
        rrect.deflate(0.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = GlimmerMotion.borderWidth
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              edge.withValues(alpha: 0.85),
              edge.withValues(alpha: 0.2),
            ],
          ).createShader(rect),
      );
  }

  void _fill(Canvas canvas, Size size, double progress) {
    final width = size.width * progress;
    final filled = Rect.fromLTWH(0, 0, width, size.height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(filled, const Radius.circular(999)),
      Paint()..color = active,
    );

    // A glow at the leading end, so the bar reads as light reaching a point
    // rather than as a rectangle that happens to stop there.
    final reach = math.min(size.height * 3, width);
    if (reach <= 0) return;
    canvas.drawRect(
      Rect.fromLTWH(width - reach, 0, reach, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            active.withValues(alpha: 0),
            Color.lerp(active, tint, 0.5)!.withValues(alpha: 0.9),
          ],
        ).createShader(Rect.fromLTWH(width - reach, 0, reach, size.height)),
    );
  }

  /// Where the travelling highlight sits, or null when there is no room.
  ///
  /// It is wider than a block and tapers to nothing at both ends, which is what
  /// makes it read as light passing rather than as an object sliding. It starts
  /// fully off one end and finishes fully off the other.
  Rect? _sweepBand(Size size) {
    final span = size.width * 0.42;
    final travel = size.width + span;
    final centre = (-span / 2) + (travel * sweep);
    final band = Rect.fromLTWH(centre - (span / 2), 0, span, size.height);
    return band.width <= 0 ? null : band;
  }

  void _sweepHighlight(Canvas canvas, Size size) {
    final band = _sweepBand(size);
    if (band == null) return;

    canvas.drawRect(band, Paint()..shader = _highlightShader(band));
  }

  /// The light the highlight throws past the edges of the track.
  ///
  /// Drawn outside the clip, taller than the bar and blurred, so it reads as a
  /// glow travelling under the surface rather than as a bright patch of track.
  void _sweepBloom(Canvas canvas, Size size) {
    final band = _sweepBand(size);
    if (band == null) return;
    final bloom = Rect.fromLTRB(
      band.left,
      band.top - size.height,
      band.right,
      band.bottom + size.height,
    );
    canvas.drawRect(
      bloom,
      Paint()
        ..shader = _highlightShader(band)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size.height * 0.9),
    );
  }

  Shader _highlightShader(Rect band) => LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          active.withValues(alpha: 0),
          active,
          Color.lerp(active, tint, 0.45)!,
          active,
          active.withValues(alpha: 0),
        ],
        stops: const [0, 0.32, 0.5, 0.68, 1],
      ).createShader(band);

  @override
  bool shouldRepaint(_GlimmerProgressPainter old) =>
      old.value != value ||
      old.sweep != sweep ||
      old.track != track ||
      old.active != active ||
      old.edge != edge ||
      old.tint != tint;
}

/// A ring of light, for progress with no bar to put it in.
///
/// Determinate: an arc runs from the top, brightening toward its leading end so
/// the ring reads as light arriving rather than as a gauge filling. Not
/// determinate: a tapered arc travels the ring, the same highlight the bar
/// sends along its track.
///
/// ```dart
/// GlimmerCircularProgress(value: 0.6)
/// ```
class GlimmerCircularProgress extends StatefulWidget {
  /// Creates a circular progress ring.
  const GlimmerCircularProgress({
    super.key,
    this.value,
    this.size = 40,
    this.strokeWidth = 4,
  });

  /// Progress between 0 and 1, or null for indeterminate.
  final double? value;

  /// The ring's diameter.
  final double size;

  /// How thick the ring is.
  final double strokeWidth;

  /// How long the indeterminate arc takes to travel the ring once.
  static const sweepDuration = Duration(milliseconds: 1600);

  @override
  State<GlimmerCircularProgress> createState() =>
      _GlimmerCircularProgressState();
}

class _GlimmerCircularProgressState extends State<GlimmerCircularProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: GlimmerCircularProgress.sweepDuration,
  );

  @override
  void initState() {
    super.initState();
    _syncSweep();
  }

  @override
  void didUpdateWidget(GlimmerCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncSweep();
  }

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  void _syncSweep() {
    if (widget.value == null) {
      if (!_sweep.isAnimating) _sweep.repeat();
    } else if (_sweep.isAnimating) {
      _sweep.stop();
      _sweep.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = GlimmerTheme.colorsOf(context);
    final value = widget.value;

    return Semantics(
      value: value == null ? null : '${(value * 100).round()}%',
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _sweep,
          builder: (context, child) => CustomPaint(
            painter: _GlimmerRingPainter(
              value: value,
              sweep: _sweep.value,
              strokeWidth: widget.strokeWidth,
              track: colors.surface,
              active: colors.primary,
              edge: colors.outline,
              tint: colors.highlightTint,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlimmerRingPainter extends CustomPainter {
  const _GlimmerRingPainter({
    required this.value,
    required this.sweep,
    required this.strokeWidth,
    required this.track,
    required this.active,
    required this.edge,
    required this.tint,
  });

  final double? value;
  final double sweep;
  final double strokeWidth;
  final Color track;
  final Color active;
  final Color edge;

  /// Which way contrast runs on this ground.
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.shortestSide - strokeWidth) / 2;
    if (radius <= 0) return;
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: radius,
    );

    // The unlit ring, with the graded edge the surfaces carry.
    canvas.drawCircle(
      rect.center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(edge.withValues(alpha: 0.5), track),
            track,
          ],
        ).createShader(rect),
    );

    const top = -math.pi / 2;
    final progress = value;

    if (progress != null) {
      final extent = progress.clamp(0.0, 1.0) * 2 * math.pi;
      if (extent <= 0) return;
      canvas.drawArc(
        rect,
        top,
        extent,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: 2 * math.pi,
            transform: const GradientRotation(top),
            colors: [
              active.withValues(alpha: 0.35),
              active,
              Color.lerp(active, tint, 0.5)!,
            ],
            stops: [
              0,
              progress.clamp(0.0, 1.0) * 0.7,
              progress.clamp(0.0, 1.0)
            ],
          ).createShader(rect),
      );
      return;
    }

    // A quarter of the ring, travelling, tapered at both ends.
    //
    // Drawn as a run of short segments rather than as one arc under a sweep
    // gradient. A sweep gradient has to be rotated into place to line its
    // stops up with the arc, and when that rotation is even slightly off the
    // bright part of the gradient sits somewhere the arc is not, so nothing
    // shows at all. Segments cannot drift.
    const arc = math.pi / 2;
    const segments = 14;
    final start = top + (sweep * 2 * math.pi);
    const step = arc / segments;

    for (var i = 0; i < segments; i++) {
      // Nothing at either end, brightest in the middle.
      final t = (i + 0.5) / segments;
      final taper = math.sin(t * math.pi);
      canvas.drawArc(
        rect,
        start + (i * step),
        step * 1.08,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color =
              Color.lerp(active, tint, taper * 0.4)!.withValues(alpha: taper),
      );
    }
  }

  @override
  bool shouldRepaint(_GlimmerRingPainter old) =>
      old.value != value ||
      old.sweep != sweep ||
      old.strokeWidth != strokeWidth ||
      old.track != track ||
      old.active != active ||
      old.edge != edge ||
      old.tint != tint;
}

/// A field for searching, with a clear button once there is something in it.
///
/// The same field as [GlimmerTextField] with the parts a search box always
/// needs: the leading icon, the clear affordance, and a keyboard that submits
/// rather than adding a newline.
///
/// ```dart
/// GlimmerSearchField(
///   hint: 'Search the list',
///   onChanged: model.filter,
/// )
/// ```
class GlimmerSearchField extends StatefulWidget {
  /// Creates a search field.
  const GlimmerSearchField({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  /// An external controller for the field's text.
  final TextEditingController? controller;

  /// Placeholder text shown while the field is empty.
  final String hint;

  /// Called on every edit, including when the field is cleared.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits from the keyboard.
  final ValueChanged<String>? onSubmitted;

  /// Whether the field takes focus as soon as it appears.
  final bool autofocus;

  @override
  State<GlimmerSearchField> createState() => _GlimmerSearchFieldState();
}

class _GlimmerSearchFieldState extends State<GlimmerSearchField> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final bool _ownsController = widget.controller == null;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return GlimmerTextField(
      controller: _controller,
      hint: widget.hint,
      prefixIcon: Icons.search,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      suffix: _controller.text.isEmpty
          ? null
          : GlimmerIconButton(
              icon: Icons.close,
              size: 32,
              tooltip: 'Clear',
              onPressed: _clear,
            ),
    );
  }
}
