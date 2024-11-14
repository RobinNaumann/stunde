import 'package:stunde/bit/b_analysis.dart';
import 'package:stunde/util.dart';

import 'm_timespan.dart';

class Bucket {
  final DateTime start;
  final DateTime end;
  final List<TaskTimespan> spans;

  int get totalMs => spans.fold(0, (p, e) => p + e.duration.inMilliseconds);

  Bucket(this.start, this.end, this.spans);

  static List<Bucket> generate(List<TaskTimespan> spans,
      {AnalysisPeriod? period, bool hourly = false}) {
    final start =
        period?.start ?? spans.firstOrNull?.startDate ?? DateTime.now();
    final end = period?.end ?? DateTime.now();

    DateTime next(DateTime t) =>
        hourly ? t.add(const Duration(hours: 1)) : t.copyWith(day: t.day + 1);

    final List<Bucket> buckets = [];
    for (var t = start; !t.isAfter(end); t = next(t)) {
      final tEnd = next(t);

      buckets.add(Bucket(
          t,
          tEnd,
          spans
              .map((s) => s.sliced(t.unixMs, tEnd.unixMs))
              .where((s) => s != null)
              .map((s) => s!)
              .toList()));
    }
    return buckets;
  }
}
