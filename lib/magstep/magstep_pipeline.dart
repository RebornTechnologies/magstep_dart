import 'motionless_mask.dart';
import 'metrics.dart';
import 'fusion.dart';
import 'detect_extrema.dart';
import 'pair_extrema.dart';
import 'map_pairs_to_steps.dart';

/// Detects steps from magnetometer signals.
///
/// Default parameters:
/// -------------------
/// thrUT = 0.5 µT
///   • Represents a practical boundary between sensor noise and real motion.
///   • Typical magnetometer noise when stationary is < 0.3 µT.
///   • Human/device motion usually produces deviations > 0.8 µT.
///   • 0.5 µT is a conservative threshold to detect motionless segments
///     without masking real steps.
///
/// winSec = 0.5 s
///   • Roughly corresponds to the duration of one human step.
///   • Typical walking cadence is ~1.5–2.5 Hz (0.4–0.7 s per step).
///   • A 0.5 s window smooths noise while preserving step structure.
///
/// These values are used only for **motionless masking**, not step detection.
/// They are chosen to bias toward false motion rather than false stillness,
/// which is safer for step detection.
///
/// Parameters:
/// -----------
/// [t]        : Timestamps in seconds
/// [signals]  : Magnetometer axis signals [x, y, z]
/// [fs]       : Sampling frequency (Hz)
///
/// Direct port of `detect_steps_mag` from Python.
List<double> detectStepsMag({
  required List<double> t,
  required List<List<double>> signals, // [x, y, z]
  required double fs,
  double thrUT = 0.5,
  double winSec = 0.5,
  int minDist = 1,
  // for testing/debugging purposes
  void Function(List<double> fusedMoving, List<double> tMoving)? onDebugSignal,
}) {
  if (t.isEmpty || signals.isEmpty) return <double>[];

  final int n = t.length;

  // Mean signal for motionless detection
  final List<double> meanSignal = List.filled(n, 0.0);
  for (int i = 0; i < n; i++) {
    double sum = 0.0;
    for (final axis in signals) {
      sum += axis[i];
    }
    meanSignal[i] = sum / signals.length;
  }

  // Motionless mask
  final List<bool> mask = motionlessMask(meanSignal, thrUT, winSec, fs);

  // Noise estimation per axis
  final List<double> noiseAbsDev = axisNoiseAbsDev(signals);

  // Axis fusion
  final List<double> fused = fuseAxesWeighted(signals, noiseAbsDev);

  // Remove motionless segments
  final List<double> fusedMoving = [];
  final List<double> tMoving = [];

  for (int i = 0; i < fused.length; i++) {
    if (!mask[i]) {
      fusedMoving.add(fused[i]);
      tMoving.add(t[i]);
    }
  }

  // 🔍 Debug export
  onDebugSignal?.call(fusedMoving, tMoving);

  // Detect extrema
  final extrema = detectExtrema(fusedMoving, minDist: minDist);

  final List<int> maxima = extrema['maxima']!;
  final List<int> minima = extrema['minima']!;

  // Pair extrema
  final pairs = pairExtrema(maxima, minima);

  // Map to step timestamps
  return mapPairsToSteps(pairs, tMoving);
}
