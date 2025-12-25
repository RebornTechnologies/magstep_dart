/// Converts Unity / normalized magnetometer values to microtesla (µT)
///
/// This mirrors magstep.unity_mag_to_uT in Python.
/// The scale factor must match the data export configuration.
class UnityMagToUT {
  /// Default scale used in Python experiments
  /// Adjust ONLY if Python uses a different value
  static const double defaultScale = 1.0;

  static List<double> convert(List<double> mag, {double scale = defaultScale}) {
    return mag.map((v) => v * scale).toList();
  }
}
