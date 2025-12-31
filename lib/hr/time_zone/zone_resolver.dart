/// Resolves Edwards HR zone for a single HR value.
///
/// Returns:
/// -1 → below zone 1
///  1–5 → Edwards zones
int resolveHrZone(double hr, double hrMax) {
  final pct = hr / hrMax;

  if (pct < 0.50) return -1;
  if (pct < 0.60) return 1;
  if (pct < 0.70) return 2;
  if (pct < 0.80) return 3;
  if (pct < 0.90) return 4;
  return 5;
}
