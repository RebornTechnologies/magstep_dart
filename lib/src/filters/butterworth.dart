import 'dart:math';

/// Butterworth IIR filter coefficients container
class ButterworthFilter {
  final List<double> b; // numerator
  final List<double> a; // denominator

  ButterworthFilter(this.b, this.a);

  /// Low-pass Butterworth filter (digital)
  ///
  /// Matches scipy.signal.butter(..., btype='low', fs=fs)
  factory ButterworthFilter.lowPass({
    required int order,
    required double cutoffHz,
    required double samplingRate,
  }) {
    if (order % 2 != 0) {
      throw ArgumentError('Only even filter orders are supported.');
    }

    final omegaC = 2 * pi * cutoffHz;
    final fs = samplingRate;

    // Pre-warp for bilinear transform
    final warped = 2 * fs * tan(pi * cutoffHz / fs);

    // Second-order sections (biquads)
    final sections = <_Biquad>[];

    for (int k = 0; k < order / 2; k++) {
      final theta = pi * (2 * k + 1) / (2 * order);
      final sinT = sin(theta);
      final cosT = cos(theta);

      final a0 = warped * warped;
      final a1 = 2 * warped * sinT;
      final a2 = 1.0;

      final b0 = warped * warped;
      final b1 = 2 * warped * sinT;
      final b2 = 1.0;

      sections.add(_bilinearTransform(b0, b1, b2, a0, a1, a2, fs));
    }

    return _cascade(sections);
  }
}

/// Represents a digital biquad section
class _Biquad {
  final List<double> b;
  final List<double> a;

  _Biquad(this.b, this.a);
}

/// Bilinear transform for analog → digital
_Biquad _bilinearTransform(
  double b0,
  double b1,
  double b2,
  double a0,
  double a1,
  double a2,
  double fs,
) {
  final k = 2 * fs;

  final a0d = a0 * k * k + a1 * k + a2;
  final a1d = 2 * a2 - 2 * a0 * k * k;
  final a2d = a0 * k * k - a1 * k + a2;

  final b0d = b0 * k * k + b1 * k + b2;
  final b1d = 2 * b2 - 2 * b0 * k * k;
  final b2d = b0 * k * k - b1 * k + b2;

  return _Biquad(
    [b0d / a0d, b1d / a0d, b2d / a0d],
    [1.0, a1d / a0d, a2d / a0d],
  );
}

/// Cascade biquad sections into single IIR filter
ButterworthFilter _cascade(List<_Biquad> sections) {
  List<double> b = [1.0];
  List<double> a = [1.0];

  for (final sec in sections) {
    b = _convolve(b, sec.b);
    a = _convolve(a, sec.a);
  }

  return ButterworthFilter(b, a);
}

List<double> _convolve(List<double> x, List<double> y) {
  final result = List<double>.filled(x.length + y.length - 1, 0.0);

  for (int i = 0; i < x.length; i++) {
    for (int j = 0; j < y.length; j++) {
      result[i + j] += x[i] * y[j];
    }
  }

  return result;
}
