import 'dart:io';

import 'package:magstep_dart/magstep_dart.dart';
import 'package:magstep_dart/src/signal_analysis.dart';

List<List<String>> readCsv(String path) {
  return File(path).readAsLinesSync().skip(1).map((l) => l.split(',')).toList();
}

List<RawSample> loadMagPathCsv(String path) {
  final lines = File(path).readAsLinesSync().skip(1);

  // Synthetic session start (BLE-style timestamps)
  final sessionStart = DateTime.fromMillisecondsSinceEpoch(0);

  return lines.map((l) {
    final r = l.split(',');

    final elapsedSeconds = double.parse(r[0]);

    return RawSample(
      timestamp: sessionStart.add(
        Duration(milliseconds: (elapsedSeconds * 1000).round()),
      ),
      ax: double.parse(r[1]),
      ay: double.parse(r[2]),
      az: double.parse(r[3]),
    );
  }).toList();
}

/// Loads a CSV with format:
/// time,value
///
/// - time can be:
///   - ISO-8601 string
///   - milliseconds since start
///   - unix epoch milliseconds
List<SignalSample> loadSignalCsv(String path) {
  final file = File(path);

  if (!file.existsSync()) {
    throw Exception('CSV file not found: $path');
  }

  final lines = file.readAsLinesSync();

  // Detect header
  final startIndex = lines.first.toLowerCase().contains('time') ? 1 : 0;

  DateTime? baseTime;

  return lines.skip(startIndex).where((l) => l.trim().isNotEmpty).map((line) {
    final parts = line.split(',');

    if (parts.length < 2) {
      throw FormatException('Invalid CSV line: $line');
    }

    final rawTime = parts[0].trim();
    final value = double.parse(parts[1].trim());

    DateTime timestamp;

    // Case 1: numeric timestamp
    if (double.tryParse(rawTime) != null) {
      final t = double.parse(rawTime);

      // First sample defines base time
      baseTime ??= DateTime.fromMillisecondsSinceEpoch(0);

      timestamp = baseTime!.add(Duration(milliseconds: t.round()));
    }
    // Case 2: ISO-8601 timestamp
    else {
      timestamp = DateTime.parse(rawTime);
    }

    return SignalSample(timestamp: timestamp, value: value);
  }).toList();
}
