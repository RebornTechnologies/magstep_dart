/// Represents a single heart rate measurement at a given time.
///
/// Time is expressed in **seconds since session start** (double precision)
/// Heart rate is expressed in **beats per minute (BPM)**.
///
/// This model is intentionally minimal to:
/// - Reduce memory overhead
/// - Improve performance in real-time streaming scenarios
/// - Match Polar BLE timestamp resolution
class HrSample {
  /// Time in seconds since start of recording
  final double time;

  /// Heart rate in beats per minute (BPM)
  final double hr;

  const HrSample(this.time, this.hr);
}
