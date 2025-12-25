import 'vo2max_model.dart';

/// Classification utilities for VO₂max.
///
/// These categories are approximate and intended for
/// consumer fitness applications, not clinical diagnosis.
/// library vo2max_classifier;

/// VO₂max fitness categories.
enum Vo2FitnessLevel { veryPoor, poor, fair, good, excellent, superior }

/// Classifies VO₂max into a fitness level.
///
/// Thresholds are generic adult references and can be
/// customized per age and sex if needed.
Vo2FitnessLevel classifyVo2Max(double vo2max) {
  if (vo2max < 30) {
    return Vo2FitnessLevel.veryPoor;
  } else if (vo2max < 35) {
    return Vo2FitnessLevel.poor;
  } else if (vo2max < 40) {
    return Vo2FitnessLevel.fair;
  } else if (vo2max < 45) {
    return Vo2FitnessLevel.good;
  } else if (vo2max < 55) {
    return Vo2FitnessLevel.excellent;
  } else {
    return Vo2FitnessLevel.superior;
  }
}
