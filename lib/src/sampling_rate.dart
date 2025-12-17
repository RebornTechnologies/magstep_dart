import 'session_analysis.dart';

/// Estimate sampling frequency (Hz) from timestamps
double estimateSamplingRate(List<RawSample> samples) {
  if (samples.length < 2) {
    throw ArgumentError('At least two samples are required.');
  }

  final intervals = <double>[];

  for (int i = 1; i < samples.length; i++) {
    final dtMicro = samples[i].timestamp
        .difference(samples[i - 1].timestamp)
        .inMicroseconds;

    if (dtMicro > 0) {
      intervals.add(dtMicro / 1e6);
    }
  }

  if (intervals.isEmpty) {
    throw StateError('Invalid timestamps: zero intervals.');
  }

  // Median is more robust than mean for BLE jitter
  intervals.sort();
  final mid = intervals.length ~/ 2;
  final medianDt = intervals.length.isOdd
      ? intervals[mid]
      : (intervals[mid - 1] + intervals[mid]) / 2;

  return 1.0 / medianDt;
}
