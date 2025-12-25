class UnityImport {
  static List<double> parseScalarSignal(List<double> raw) {
    // Python unity_import often normalizes or rescales
    return raw;
  }

  static List<DateTime> parseTimestamps(List<int> millis) {
    return millis.map((t) => DateTime.fromMillisecondsSinceEpoch(t)).toList();
  }
}
