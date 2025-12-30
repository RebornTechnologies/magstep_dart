/// Represents a single gyroscope sample in the time domain.
///
/// Units:
/// - timeSeconds: seconds since session start
/// - gx, gy, gz: angular velocity (rad/s or deg/s depending on source)
class GyroSample {
  final double timeSeconds;
  final double gx;
  final double gy;
  final double gz;

  GyroSample(this.timeSeconds, this.gx, this.gy, this.gz);
}
