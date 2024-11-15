import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/model/m_timespan.dart';
import 'package:stunde/util.dart';
import 'package:stunde/view/task/analysis/v_viz_box.dart';

import '../../v_donut.dart';

class ByAspectViz extends StatelessWidget {
  final List<TaskTimespan> spans;
  final TaskModel task;
  const ByAspectViz({super.key, required this.spans, required this.task});

  @override
  Widget build(BuildContext context) {
    return DonutWiz(
        title: "By Aspect",
        spans: spans,
        keyFn: (span) => span.aspectId,
        labelFn: (key) =>
            task.aspects.firstWhereOrNull((t) => t.id == key)?.label ?? "none");
  }
}

class ByAppViz extends StatelessWidget {
  final List<TaskTimespan> spans;
  final TaskModel task;
  const ByAppViz({super.key, required this.spans, required this.task});

  @override
  Widget build(BuildContext context) {
    List<TaskTimespan> appSpans = [];
    for (var span in spans) {
      if (span.apps.isEmpty) appSpans.add(span);

      UnixMs start = span.start;
      String? app;

      for (var a in [...span.apps.entries, MapEntry(span.end, null)]) {
        if (app != null) {
          appSpans.add(TaskTimespan(
              start: start,
              end: a.key,
              aspectId: span.aspectId,
              apps: {start: app}));
        }

        app = a.value;
        start = a.key;
      }
    }

    return DonutWiz(
        title: "By Apps",
        spans: appSpans,
        keyFn: (span) => span.apps.entries.firstOrNull?.value,
        labelFn: (key) => (key ?? "none").trim().toNameCase());
  }
}

class DonutWiz extends StatelessWidget {
  final List<TaskTimespan> spans;
  final String title;
  final String? Function(TaskTimespan) keyFn;
  final String Function(String? key) labelFn;

  const DonutWiz(
      {super.key,
      required this.spans,
      required this.title,
      required this.keyFn,
      required this.labelFn});

  @override
  Widget build(BuildContext context) {
    Map<String?, List<TaskTimespan>> byAspect = {};
    for (var span in spans) {
      byAspect.putIfAbsent(keyFn(span), () => []).add(span);
    }

    List<DonutChartSegment> segments = byAspect.entries
        .map((e) => DonutChartSegment(
            value: e.value.fold(0, (p, e) => p + e.duration.inMilliseconds),
            key: e.key,
            label: labelFn(e.key)))
        .sorted((a, b) => b.value.compareTo(a.value));

    int total = max(1, spans.fold(0, (p, e) => p + e.duration.inMilliseconds));

    return VizBox(
      label: title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              DonutChart(
                size: 5,
                segments: segments,
              )
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var seg in segments)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: seg.color,
                      ),
                      width: 10,
                      height: 10,
                    ),
                    Expanded(
                        child: WText(
                      seg.label,
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    )),
                    WText(
                        "${seg.value.round().formatUnixDuration()} (${((seg.value / total).clamp(0, 1) * 100).round()}%)")
                  ].spaced(amount: .5),
                )
            ].spaced(),
          ))
        ].spaced(amount: 1),
      ),
    );
  }
}
