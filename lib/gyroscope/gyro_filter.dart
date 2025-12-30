import 'dart:math';

/// Represents one Second-Order Section (SOS)
class SosSection {
  final double b0, b1, b2;
  final double a1, a2;

  double _z1 = 0.0;
  double _z2 = 0.0;

  SosSection({
    required this.b0,
    required this.b1,
    required this.b2,
    required this.a1,
    required this.a2,
  });

  /// Direct Form II Transposed
  double process(double x) {
    final y = b0 * x + _z1;
    _z1 = b1 * x - a1 * y + _z2;
    _z2 = b2 * x - a2 * y;
    return y;
  }

  void reset() {
    _z1 = 0.0;
    _z2 = 0.0;
  }
}

class GyroHighPassFilter {
  final List<SosSection> _sections;

  GyroHighPassFilter._(this._sections);

  /// Coefficients copied EXACTLY from SciPy output
  factory GyroHighPassFilter.scipyMatched() {
    return GyroHighPassFilter._([
      SosSection(
        b0: 0.000806359865,
        b1: 0.00161271973,
        b2: 0.000806359865,
        a1: -1.38761971,
        a2: 0.492422887,
      ),
      SosSection(b0: 1.0, b1: 2.0, b2: 1.0, a1: -1.62993553, a2: 0.753040172),
    ]);
  }

  /// Forward filtering
  List<double> filter(List<double> input) {
    final output = List<double>.from(input);

    for (final section in _sections) {
      section.reset();
      for (int i = 0; i < output.length; i++) {
        output[i] = section.process(output[i]);
      }
    }
    return output;
  }

  /// Zero-phase filtering (equivalent to scipy.signal.filtfilt)
  List<double> filtfilt(List<double> input) {
    // Forward
    var y = filter(input);

    // Reverse
    y = y.reversed.toList();

    // Backward
    y = filter(y);

    // Reverse back
    return y.reversed.toList();
  }
}
