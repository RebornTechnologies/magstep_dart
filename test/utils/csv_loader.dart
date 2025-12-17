import 'dart:io';

import 'package:magstep_dart/magstep_dart.dart';

List<List<String>> _readCsv(String path) {
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
