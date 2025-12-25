import 'dart:math';

/// Mathematical models used for Heart Rate Recovery (HRR).
///
/// This file replaces SciPy's curve_fit-based exponential fitting
/// with a fast, deterministic least-squares approximation.
///
/// The model used is:
///   HR(t) = a * exp(-k * t) + c
///
/// Where:
/// - a: amplitude
/// - k: recovery rate constant
/// - c: asymptotic heart rate
/// library hrr_model;

/// Holds parameters of an exponential HR recovery model.
class HrrModel {
  /// Amplitude of the exponential decay
  final double a;

  /// Recovery rate constant (higher = faster recovery)
  final double k;

  /// Asymptotic heart rate (resting component)
  final double c;

  const HrrModel({required this.a, required this.k, required this.c});

  /// Computes HR at time [t] using the fitted model.
  double valueAt(double t) {
    return a * exp(-k * t) + c;
  }
}
