import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/bit/b_analysis.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/model/m_timespan.dart';
import 'package:stunde/util.dart';
import 'package:stunde/view/task/analysis/v_viz_box.dart';

import '../../../model/m_bucket.dart';

const dash = "—";

class OverviewViz extends StatelessWidget {
  final AnalysisOptions options;
  final List<TaskTimespan> spans;
  final TaskModel task;
  const OverviewViz(
      {super.key,
      required this.options,
      required this.spans,
      required this.task});

  Widget _field(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WText(value,
            style: MacosTheme.of(context).typography.largeTitle.copyWith(
                color: MacosTheme.of(context).primaryColor,
                fontWeight: FontWeight.bold)),
        WText(label, style: MacosTheme.of(context).typography.body),
      ].spaced(amount: .25),
    );
  }

  String _topAspect() {
    if (spans.isEmpty) return dash;

    JsonMap<int> durations = {};

    for (final s in spans) {
      final d = s.end - s.start;
      durations.update(s.aspectId ?? dash, (v) => v + d, ifAbsent: () => d);
    }

    final id = durations.entries
            .sortedBy<BigInt>((v) => BigInt.from(v.value))
            .lastOrNull
            ?.key ??
        dash;
    return id == dash
        ? dash
        : task.aspects.firstWhereOrNull((a) => a.id == id)?.label ?? dash;
  }

  String _topApp() {
    if (spans.isEmpty) return dash;

    JsonMap<int> durations = {};

    for (final a in spans) {
      final durs = a.appDurations;
      for (final app in durs.entries) {
        durations.update(app.key, (v) => v + app.value,
            ifAbsent: () => app.value);
      }
    }

    return durations.entries
            .sortedBy<BigInt>((v) => BigInt.from(v.value))
            .lastOrNull
            ?.key ??
        dash;
  }

  @override
  Widget build(BuildContext context) {
    final bool hourly = options.period?.scope == ATScope.day;
    final buckets =
        Bucket.generate(spans, period: options.period, hourly: hourly);

    return VizBox(
      label: "Overview",
      child: SingleChildScrollView(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _field(
                context,
                "Total Time",
                spans
                    .fold(0, (p, e) => p + e.duration.inMilliseconds)
                    .formatUnixDuration()),
            _field(context, "Top App", _topApp().toNameCase()),
            _field(context, "Top Aspect", _topAspect()),
          ].spaced(amount: 2),
        ),
      ),
    );
  }
}
