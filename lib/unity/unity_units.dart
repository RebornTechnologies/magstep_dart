/// EXACT Dart port of unity_units.py
class UnityUnits {
  static double unityMagToUT(
    double raw, {
    double scaleUT = 50.0,
    double biasUT = 0.0,
  }) {
    return scaleUT * raw + biasUT;
  }

  static List<double> unityMagSignalToUT(
    List<double> raw, {
    double scaleUT = 50.0,
    double biasUT = 0.0,
  }) {
    return raw
        .map((v) => unityMagToUT(v, scaleUT: scaleUT, biasUT: biasUT))
        .toList();
  }
}
