import 'vo2max_model.dart';
import 'vo2max_classifier.dart';

/// High-level summary builder for VO₂max results.
///
/// This file exists to keep UI logic clean and
/// avoid fitness-specific rules leaking into widgets.
/// library vo2max_summary;

/// VO₂max summary suitable for UI and analytics.
class Vo2MaxSummary {
  final double value;
  final Vo2FitnessLevel level;

  const Vo2MaxSummary({required this.value, required this.level});
}

/// Builds a VO₂max summary from estimation result.
Vo2MaxSummary buildVo2MaxSummary(Vo2MaxResult result) {
  return Vo2MaxSummary(
    value: result.vo2max,
    level: classifyVo2Max(result.vo2max),
  );
}
