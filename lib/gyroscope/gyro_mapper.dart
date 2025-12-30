import '../core/raw_sample.dart';
import 'gyro_sample.dart';

/// Converts RawSample stream into GyroSample with normalized timestamps.
///
/// Equivalent to Python:
///   t0 = raw[0].timestamp
///   timeSeconds = (ts - t0) / 1000
class GyroMapper {
  static List<GyroSample> fromRaw(List<RawSample> raw) {
    if (raw.isEmpty) return [];

    final int t0Ms = raw.first.timestamp.millisecondsSinceEpoch;

    return raw.map((s) {
      final int tsMs = s.timestamp.millisecondsSinceEpoch;
      final double timeSeconds = (tsMs - t0Ms) / 1000.0;

      return GyroSample(timeSeconds, s.x, s.y, s.z);
    }).toList();
  }
}
