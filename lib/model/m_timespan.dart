import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';

import 'm_task.dart';

class TaskTimespan extends JsonModel {
  final UnixMs start;
  final UnixMs end;
  final String? taskId;
  final String? aspectId;
  final Map<UnixMs, String> apps;

  DateTime get startDate => DateTime.fromMillisecondsSinceEpoch(start);
  DateTime get endDate => DateTime.fromMillisecondsSinceEpoch(end);

  TaskTimespan({
    required this.start,
    required this.end,
    this.taskId,
    this.aspectId,
    this.apps = const {},
  });

  Duration get duration => Duration(milliseconds: end - start);

  TaskTimespan? sliced(UnixMs start, UnixMs end) {
    if (this.start >= end || this.end <= start) return null;

    final UnixMs sT = this.start < start ? start : this.start;
    final UnixMs eT = this.end > end ? end : this.end;

    final apps = this.apps.entries.where((e) => e.key >= sT && e.key < eT);

    return TaskTimespan(
      start: sT,
      end: eT,
      aspectId: aspectId,
      taskId: taskId,
      apps: Map.fromEntries(apps),
    );
  }

  JsonMap<int> get appDurations {
    final Map<String, int> durations = {};

    UnixMs start = this.start;
    String? currentApp;

    for (final app in [...apps.entries, MapEntry(end, null)]) {
      if (currentApp != null) {
        final dur = app.key - start;
        durations.update(currentApp, (v) => v + dur, ifAbsent: () => dur);
      }

      currentApp = app.value;
      start = app.key;
    }

    return durations;
  }

  TaskTimespan copyWith({
    UnixMs? start,
    UnixMs? end,
    Opt<String> taskId,
    Opt<String> aspectId,
    Map<UnixMs, String>? apps,
  }) {
    return TaskTimespan(
      start: start ?? this.start,
      end: end ?? this.end,
      taskId: optEval(taskId, this.taskId),
      aspectId: optEval(aspectId, this.aspectId),
      apps: apps ?? this.apps,
    );
  }

  bool isFullyShadowed(TaskTimespan other) {
    return start >= other.start && end <= other.end;
  }

  factory TaskTimespan.fromMap(JsonMap map) => TaskTimespan(
        start: map.asCast("start"),
        end: map.asCast("end"),
        aspectId: map.maybeCast("aspectId"),
        apps: map.containsKey("apps") && map["apps"] != null
            ? Map.from(map["apps"])
                .map((k, v) => MapEntry(k as UnixMs, v as String))
            : {},
      );

  @override
  get map => {
        "start": start,
        "end": end,
        "aspectId": aspectId,
        "apps": apps,
      };
}
