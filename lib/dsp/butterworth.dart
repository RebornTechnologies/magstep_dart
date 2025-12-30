import 'dart:math' as math;

/// Butterworth SOS coefficients.
///
/// Matches:
/// scipy.signal.butter(order, cutoff/(fs/2), output="sos")
class Butterworth {
  /// Low-pass Butterworth in SOS form
  static List<List<double>> lowpassSos({
    required int order,
    required double cutoffHz,
    required double fsHz,
  }) {
    if (order % 2 != 0) {
      throw ArgumentError('Order must be even for SOS Butterworth');
    }

    final List<List<double>> sos = [];

    final double nyquist = fsHz / 2.0;
    final double wc = cutoffHz / nyquist;
    final double ita = 1.0 / math.tan(math.pi * wc);

    final int sections = order ~/ 2;

    for (int k = 0; k < sections; k++) {
      final double theta = math.pi * (2.0 * k + 1.0) / (2.0 * order);
      final double q = 1.0 / (2.0 * math.cos(theta));

      final double b0 = 1.0 / (1.0 + q * ita + ita * ita);
      final double b1 = 2.0 * b0;
      final double b2 = b0;

      final double a1 = 2.0 * (ita * ita - 1.0) * b0;
      final double a2 = (1.0 - q * ita + ita * ita) * b0;

      sos.add([b0, b1, b2, 1.0, a1, a2]);
    }

    return sos;
  }

  /// High-pass Butterworth in SOS form
  ///
  /// Numerically matches:
  /// scipy.signal.butter(order, cutoff, btype='high', output='sos')
  static List<List<double>> highpassSos({
    required int order,
    required double cutoffHz,
    required double fsHz,
  }) {
    final lp = lowpassSos(order: order, cutoffHz: cutoffHz, fsHz: fsHz);

    // High-pass transformation: flip sign of b1
    return lp
        .map(
          (s) => [
            s[0], // b0
            -s[1], // -b1
            s[2], // b2
            s[3], // a0 (1.0)
            s[4], // a1
            s[5], // a2
          ],
        )
        .toList();
  }

  /// Band-pass Butterworth in SOS form
  ///
  /// Matches:
  /// scipy.signal.butter(order, [low, high], btype='band', output='sos')
  static List<List<double>> bandpassSos({
    required int order,
    required double lowHz,
    required double highHz,
    required double fsHz,
  }) {
    if (order % 2 != 0) {
      throw ArgumentError('Order must be even for SOS Butterworth');
    }
    if (lowHz >= highHz) {
      throw ArgumentError('lowHz must be < highHz');
    }

    final List<List<double>> sos = [];

    final double nyquist = fsHz / 2.0;
    final double w1 = lowHz / nyquist;
    final double w2 = highHz / nyquist;

    final double bw = w2 - w1;
    final double w0 = math.sqrt(w1 * w2);

    final int sections = order ~/ 2;

    for (int k = 0; k < sections; k++) {
      final double theta = math.pi * (2.0 * k + 1.0) / (2.0 * order);
      final double q = 1.0 / (2.0 * math.cos(theta));

      final double ita = 1.0 / math.tan(math.pi * bw / 2.0);

      final double b0 = ita / (1.0 + q * ita + ita * ita);
      final double b1 = 0.0;
      final double b2 = -b0;

      final double a1 = 2.0 * (ita * ita - 1.0) * b0;
      final double a2 = (1.0 - q * ita + ita * ita) * b0;

      sos.add([b0, b1, b2, 1.0, a1, a2]);
    }

    return sos;
  }
}
