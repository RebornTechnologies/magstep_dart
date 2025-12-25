/// Definition of heart rate intensity zones.
///
/// Zones are defined as percentages of maximum heart rate (HRmax).
/// These are commonly used in endurance training and match
/// the zones used by Edwards TRIMP.
/// library hr_zone;

/// Heart rate intensity zones.
enum HrZone { zone1, zone2, zone3, zone4, zone5 }

/// Lower bounds of HR zones expressed as %HRmax.
///
/// Zone mapping:
/// - Zone 1: < 60%
/// - Zone 2: 60–70%
/// - Zone 3: 70–80%
/// - Zone 4: 80–90%
/// - Zone 5: ≥ 90%
HrZone zoneFromIntensity(double intensityPct) {
  if (intensityPct < 0.6) {
    return HrZone.zone1;
  } else if (intensityPct < 0.7) {
    return HrZone.zone2;
  } else if (intensityPct < 0.8) {
    return HrZone.zone3;
  } else if (intensityPct < 0.9) {
    return HrZone.zone4;
  } else {
    return HrZone.zone5;
  }
}
