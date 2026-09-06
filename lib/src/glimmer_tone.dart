import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Perceptual lightness, the axis Glimmer derives its surface and border
/// colours along.
///
/// Those colours are not hand-picked, they are stated as tones: a surface is
/// its base colour at tone 20, a focused surface the same colour at tone 34,
/// and the four corners of a focused border are the focal colour at tones 85,
/// 69 and 77 with white at the lit corner. That is what makes a re-skinned
/// palette derive its own focused fill and border correctly instead of only
/// the default looking right.
///
/// Tone here is CIELAB's L*. Colours that leave sRGB after a large lightness
/// shift are clamped per channel, which desaturates slightly rather than
/// re-finding the maximum chroma available at the new tone.
extension GlimmerTone on Color {
  /// This colour's perceptual lightness, from 0 (black) to 100 (white).
  double get tone {
    final y = _toXyz(this)[1];
    return (116 * _labF(y / 100)) - 16;
  }

  /// This colour at [newTone], keeping its hue and chroma and its alpha.
  ///
  /// ```dart
  /// const Color(0xFF9BBFFF).withTone(85) // the focused border's second corner
  /// ```
  Color withTone(double newTone) {
    final xyz = _toXyz(this);
    final l = newTone.clamp(0.0, 100.0);

    // Keep a* and b* by recovering them from the source and rebuilding at the
    // requested lightness.
    final fx = _labF(xyz[0] / _whiteX);
    final fy = _labF(xyz[1] / 100);
    final fz = _labF(xyz[2] / _whiteZ);
    final a = 500 * (fx - fy);
    final b = 200 * (fy - fz);

    final newFy = (l + 16) / 116;
    final newFx = newFy + (a / 500);
    final newFz = newFy - (b / 200);

    return _fromXyz(
      _labFInverse(newFx) * _whiteX,
      _labFInverse(newFy) * 100,
      _labFInverse(newFz) * _whiteZ,
      a: this.a,
    );
  }
}

const _whiteX = 95.047;
const _whiteZ = 108.883;
const _epsilon = 216 / 24389;
const _kappa = 24389 / 27;

double _labF(double t) => t > _epsilon ? _cbrt(t) : ((_kappa * t) + 16) / 116;

double _labFInverse(double t) {
  final cubed = t * t * t;
  return cubed > _epsilon ? cubed : ((116 * t) - 16) / _kappa;
}

double _cbrt(double t) => math.pow(t, 1 / 3).toDouble();

double _linearise(double channel) => channel <= 0.04045
    ? channel / 12.92
    : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();

double _delinearise(double channel) {
  final v = channel <= 0.0031308
      ? channel * 12.92
      : (1.055 * math.pow(channel, 1 / 2.4)) - 0.055;
  return v.clamp(0.0, 1.0);
}

List<double> _toXyz(Color color) {
  final r = _linearise(color.r);
  final g = _linearise(color.g);
  final b = _linearise(color.b);
  return [
    (41.24 * r) + (35.76 * g) + (18.05 * b),
    (21.26 * r) + (71.52 * g) + (7.22 * b),
    (1.93 * r) + (11.92 * g) + (95.05 * b),
  ];
}

Color _fromXyz(double x, double y, double z, {required double a}) {
  final xn = x / 100;
  final yn = y / 100;
  final zn = z / 100;
  return Color.from(
    alpha: a,
    red: _delinearise((3.2406 * xn) - (1.5372 * yn) - (0.4986 * zn)),
    green: _delinearise((-0.9689 * xn) + (1.8758 * yn) + (0.0415 * zn)),
    blue: _delinearise((0.0557 * xn) - (0.2040 * yn) + (1.0570 * zn)),
  );
}
