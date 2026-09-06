import 'package:flutter/animation.dart';

/// Timing and easing taken from Glimmer's `Surface` implementation.
///
/// They live apart from component styling so a custom widget can share the same
/// interaction language without depending on any of the widgets here.
///
/// Unlike the type, shape and depth scales, none of these values are scaled for
/// mobile. Motion timing does not depend on how far the display sits from the
/// eye.
class GlimmerMotion {
  const GlimmerMotion._();

  /// How long a surface takes to reach its focused state.
  static const focusEnterDuration = Duration(milliseconds: 800);

  /// How long a surface takes to return to its resting state.
  static const focusExitDuration = Duration(milliseconds: 500);

  /// The length of one ambient focus sweep.
  static const ambientPulseDuration = Duration(seconds: 2);

  /// How long a surface waits after gaining focus before the first sweep.
  static const ambientInitialDelay = Duration(milliseconds: 1800);

  /// How long a surface waits between sweeps.
  static const ambientRepeatDelay = Duration(seconds: 4);

  /// The shortest time a press overlay stays visible, so a quick tap still
  /// registers visually.
  static const minimumPressDuration = Duration(milliseconds: 300);

  /// The alpha of the white overlay drawn over a pressed surface.
  static const pressedOverlayOpacity = 0.16;

  /// The border width of a resting surface.
  static const borderWidth = 1.5;

  /// The border width of a focused surface.
  static const focusedBorderWidth = 2.0;

  /// Compose's `LinearOutSlowInEasing`, `cubic-bezier(0, 0, .2, 1)`.
  static const focusCurve = Cubic(0.0, 0.0, 0.2, 1.0);

  /// Compose's `spring(dampingRatio = .84f, stiffness = 8000f)`.
  static const pressEnterSpring = SpringDescription(
    mass: 1,
    stiffness: 8000,
    damping: 150.26,
  );

  /// Compose's `spring(dampingRatio = .85f, stiffness = 50f)`.
  static const pressExitSpring = SpringDescription(
    mass: 1,
    stiffness: 50,
    damping: 12.02,
  );

  /// Glimmer's `spring(dampingRatio = .56f, stiffness = 118f)`, used to settle
  /// something into place.
  ///
  /// Upstream it snaps stack items. It is the only positional spring Glimmer
  /// publishes, so anything that moves into position uses it: a sheet rising, a
  /// dialog arriving, a snackbar sliding in.
  static const settleSpring = SpringDescription(
    mass: 1,
    stiffness: 118,
    damping: 12.19,
  );

  /// How long a modal surface takes to arrive or leave.
  ///
  /// Glimmer has no modals, so this is a mobile addition. It is deliberately
  /// far shorter than the 800 ms focus transition: focus is ambient and can
  /// afford to be slow, while a panel the user asked for cannot.
  static const modalDuration = Duration(milliseconds: 260);

  /// The alpha of the veil drawn over the app behind a modal surface.
  ///
  /// Taken from the scrim Glimmer puts over the items behind the top of a
  /// stack, which is the same idea: this is not the thing being read.
  static const scrimOpacity = 0.5;

  /// How far the app behind a modal surface is blurred.
  static const scrimBlur = 18.0;

  /// The ambient sweep envelope at [progress] through
  /// [ambientPulseDuration].
  ///
  /// The source shader ramps in over the first 28.35% of the cycle, holds to
  /// 37.5%, then tapers across the remainder. That envelope is reproduced here
  /// without copying the glasses-specific runtime shader that draws it.
  static double ambientEnvelope(double progress) {
    if (progress < 0.375) return (progress / 0.2835).clamp(0.0, 1.0);
    return (1 - ((progress - 0.375) / 0.625)).clamp(0.0, 1.0);
  }
}
