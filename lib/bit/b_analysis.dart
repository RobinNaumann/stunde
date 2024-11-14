import 'package:elbe/elbe.dart';
import 'package:stunde/model/m_timespan.dart';
import 'package:stunde/util.dart';

enum ATScope {
  day(label: "Day"),
  week(label: "Week"),
  month(label: "Month");

  final String label;
  const ATScope({required this.label});
}

class AnalysisPeriod {
  final ATScope scope;

  late final DateTime start;
  DateTime get end => _offset(1).subtract(const Duration(milliseconds: 1));

  AnalysisPeriod({required this.scope, required DateTime within}) {
    start = _offset(0, within);
  }

  String get spanLabel {
    final y = start.year != DateTime.now().year;
    switch (scope) {
      case ATScope.day:
        return start.sFormat(y);
      case ATScope.week:
        return "${start.sFormat()} - ${end.sFormat(y)}";
      case ATScope.month:
        return start.sMonthName(y);
    }
  }

  AnalysisPeriod get prev => AnalysisPeriod(scope: scope, within: _offset(-1));
  AnalysisPeriod? get next {
    final nextStart = _offset(1);
    return nextStart.isAfter(DateTime.now())
        ? null
        : AnalysisPeriod(scope: scope, within: nextStart);
  }

  DateTime _offset(int offset, [DateTime? startOverride]) {
    final at0 = (startOverride ?? start)
        .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);

    if (scope == ATScope.day) {
      return at0.add(Duration(days: offset, hours: 5)).copyWith(hour: 0);
    } else if (scope == ATScope.week) {
      final monday = at0.weekday == 1
          ? at0
          : at0.subtract(Duration(days: at0.weekday - 1));

      return monday.add(Duration(days: 7 * offset, hours: 5)).copyWith(hour: 0);
    } else {
      final firstDay = at0.copyWith(day: 1);
      final nextMonth = firstDay.month + offset;
      final year = firstDay.year + nextMonth ~/ 12;
      final month = nextMonth % 12;
      return firstDay.copyWith(year: year, month: month);
    }
  }
}

class AnalysisOptions {
  final AnalysisPeriod? period;
  AnalysisOptions({required this.period});

  AnalysisOptions copyWith({Opt<AnalysisPeriod> period}) =>
      AnalysisOptions(period: optEval(period, this.period));
}

class AnalysisBit extends MapMsgBitControl<AnalysisOptions> {
  static const builder = MapMsgBitBuilder<AnalysisOptions, AnalysisBit>.make;

  AnalysisBit()
      : super.worker((v) async => AnalysisOptions(
            period:
                AnalysisPeriod(scope: ATScope.day, within: DateTime.now())));

  void setPeriod(AnalysisPeriod? p) => act((d) => d.copyWith(period: () => p));

  List<TaskTimespan>? filtered(List<TaskTimespan> sp) => state.whenData((o) {
        final start = o.period?.start ?? DateTime.fromMillisecondsSinceEpoch(0);
        final end = o.period?.end ?? DateTime.now();
        return sp
            .where((span) =>
                span.endDate.isAfter(start) && span.startDate.isBefore(end))
            .toList();
      });
}
