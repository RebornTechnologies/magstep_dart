double estimateSamplingRateFromTimestamps(List<DateTime> timestamps) {
  if (timestamps.length < 2) return 0.0;

  final deltas = <double>[];

  for (int i = 1; i < timestamps.length; i++) {
    final dt = timestamps[i]
        .difference(timestamps[i - 1])
        .inMicroseconds
        .toDouble();

    if (dt > 0) deltas.add(dt);
  }

  if (deltas.isEmpty) return 0.0;

  // Python uses median to resist BLE jitter
  deltas.sort();
  final medianUs = deltas[deltas.length ~/ 2];

  return 1e6 / medianUs;
}
