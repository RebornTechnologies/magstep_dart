import 'dart:math';

class MagPathProcessor {
  /// Entry point – mirrors Python magstep behavior
  static List<double> preprocess(
    List<double> raw, {
    required List<bool> motionlessMask,
  }) {
    var signal = List<double>.from(raw);

    // 1️⃣ Remove DC offset (MANDATORY)
    signal = _removeMean(signal);

    // 2️⃣ Handle motionless regions (flatten, not zero)
    signal = _flattenMotionless(signal, motionlessMask);

    // 3️⃣ Normalize amplitude if Python does
    signal = normalize(signal);

    return signal;
  }

  static List<double> _removeMean(List<double> s) {
    final mean = s.reduce((a, b) => a + b) / s.length;
    return s.map((v) => v - mean).toList();
  }

  static List<double> _flattenMotionless(List<double> s, List<bool> mask) {
    final out = List<double>.from(s);

    for (int i = 1; i < out.length; i++) {
      if (mask[i]) {
        out[i] = out[i - 1];
      }
    }
    return out;
  }

  static List<double> normalize(List<double> s) {
    final mean = s.reduce((a, b) => a + b) / s.length;
    final centered = s.map((v) => v - mean).toList();

    final variance =
        centered.map((v) => v * v).reduce((a, b) => a + b) / centered.length;

    final std = sqrt(variance);
    if (std == 0) return centered;

    return centered.map((v) => v / std).toList();
  }
}
