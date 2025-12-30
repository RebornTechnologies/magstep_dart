import 'sos_filter.dart';

/// Zero-phase digital filtering using forward-backward SOS filtering.
///
/// This matches the behavior of:
/// scipy.signal.sosfiltfilt
///
/// Important:
/// - Works on SOS (biquad sections), NOT (b, a)
/// - Resets state between passes
/// - Numerically stable for mobile / Dart
class FiltFilt {
  static List<double> apply(List<double> input, SosFilter sos) {
    if (input.length < 3) {
      return List<double>.from(input);
    }

    // -------------------------------------------------------------------------
    // Forward pass
    // -------------------------------------------------------------------------
    var y = sos.filter(input);

    // -------------------------------------------------------------------------
    // Reverse
    // -------------------------------------------------------------------------
    y = y.reversed.toList();

    // -------------------------------------------------------------------------
    // Backward pass
    // -------------------------------------------------------------------------
    y = sos.filter(y);

    // -------------------------------------------------------------------------
    // Reverse back
    // -------------------------------------------------------------------------
    return y.reversed.toList();
  }
}
