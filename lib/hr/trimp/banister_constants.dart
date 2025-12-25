/// Constants used for Banister TRIMP calculation.
///
/// These values are derived from the original Banister model
/// and are sex-specific to account for physiological differences.
/// library banister_constants;

/// Sex of the athlete, required for Banister TRIMP.
enum Sex { male, female }

/// Scaling factor used in Banister TRIMP.
double banisterScale(Sex sex) {
  switch (sex) {
    case Sex.male:
      return 0.64;
    case Sex.female:
      return 0.86;
  }
}

/// Exponential coefficient used in Banister TRIMP.
double banisterExponent(Sex sex) {
  switch (sex) {
    case Sex.male:
      return 1.92;
    case Sex.female:
      return 1.67;
  }
}
