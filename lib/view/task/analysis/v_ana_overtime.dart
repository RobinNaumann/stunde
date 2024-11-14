import 'dart:math' as math;

import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/bit/b_analysis.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/model/m_timespan.dart';
import 'package:stunde/util.dart';
import 'package:stunde/view/task/analysis/v_viz_box.dart';

import '../../../model/m_bucket.dart';

class OverTimeViz extends StatelessWidget {
  final AnalysisOptions options;
  final List<TaskTimespan> spans;
  final TaskModel task;
  const OverTimeViz(
      {super.key,
      required this.options,
      required this.spans,
      required this.task});

  @override
  Widget build(BuildContext context) {
    final bool hourly = options.period?.scope == ATScope.day;
    final buckets =
        Bucket.generate(spans, period: options.period, hourly: hourly);

    return VizBox(
      label: "Over Time",
      child: TimeChart(buckets: buckets, hourly: hourly),
    );
  }
}

class TaskTimeChart extends StatelessWidget {
  final List<TaskModel> tasks;
  const TaskTimeChart({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    List<TaskTimespan> spans = tasks
        .map((t) => t.timespans.map((e) => e.copyWith(taskId: () => t.id)))
        .flattened
        .toList()
        .sorted((a, b) => a.start.compareTo(b.start));

    if (spans.isEmpty) return const SizedBox();

    final b = Bucket.generate(spans,
        hourly: true,
        period: AnalysisPeriod(scope: ATScope.day, within: DateTime.now()));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          WText("Overview Today",
              style: MacosTheme.of(context).typography.headline),
          TimeChart(buckets: b, hourly: true, tasks: tasks)
        ].spaced());
  }
}

class TimeChart extends StatelessWidget {
  final List<Bucket> buckets;
  final List<TaskModel>? tasks;
  final bool hourly;

  const TimeChart(
      {super.key, required this.buckets, required this.hourly, this.tasks});

  @override
  Widget build(BuildContext context) {
    final max = math.max(
        (hourly ? 1 : 4) * 60 * 60 * 1000, buckets.map((b) => b.totalMs).max);

    Widget _col(BuildContext context, Bucket b, bool hourly, int max) {
      // grouped by task
      final JsonMap<List<TaskTimespan>>? byTask = tasks != null ? {} : null;
      if (byTask != null) {
        for (final span in b.spans) {
          byTask.update(span.taskId ?? "", (v) => [...v, span],
              ifAbsent: () => [span]);
        }
      }

      return MacosTooltip(
          message: "${hourly ? b.start.sFormatHour() : b.start.sFormat()}"
              "\n(${b.totalMs ~/ (1000 * 60)} min.)",
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                  height: 100,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(2)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: byTask == null
                            ? [
                                Container(
                                  color: MacosTheme.of(context).primaryColor,
                                  height: (b.totalMs / max)
                                          .clamp(b.totalMs == 0 ? 0 : .01, 1) *
                                      100,
                                ),
                              ]
                            : byTask.entries.map((e) {
                                final total = e.value.fold<int>(
                                    0, (p, e) => p + e.duration.inMilliseconds);
                                return Container(
                                  color: (tasks!
                                      .firstWhereOrNull((t) => t.id == e.key)
                                      ?.icon
                                      .color),
                                  height: math.max(
                                      0,
                                      ((total / max).clamp(0, 1) * 100) -
                                          context.rem(.07)),
                                );
                              }).spaced(amount: .07),
                      ),
                    ),
                  )),
              Container(
                color: MacosTheme.of(context).dividerColor,
                height: 2,
              )
            ].spaced(amount: .125),
          ));
    }

    return Row(
      children: [
        for (final b in buckets) Expanded(child: _col(context, b, hourly, max)),
      ].spaced(amount: .25),
    );
  }
}
