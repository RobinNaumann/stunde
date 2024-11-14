import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:stunde/util.dart';

import 'm_task_aspect.dart';
import 'm_timespan.dart';

abstract class JsonModel {
  JsonMap get map;
  const JsonModel();

  @override
  String toString() => map.toString();

  @override
  bool operator ==(Object other) =>
      other is JsonModel && map.toString() == other.map.toString();

  @override
  int get hashCode => map.toString().hashCode;
}

abstract class IdDoc extends JsonModel {
  final String id;
  const IdDoc({required this.id});

  @override
  get map => {"id": id};
}

enum TaskIcon {
  green(Color(0xFF04cb81)),
  red(Color(0xFFcb0237)),
  yellow(Color(0xFFcbae00)),
  blue(Color(0xFF015acb)),
  purple(Color(0xFFB71BFF)),
  orange(Color(0xFFFB7400));

  final Color color;

  const TaskIcon(this.color);

  String get path => "assets/icons/task/task_$name.png";
}

class TaskModel extends IdDoc {
  final String label;
  final TaskIcon icon;
  final String? description;
  final List<TaskAspect> aspects;

  final List<TaskTimespan> timespans;

  TaskModel({
    required super.id,
    required this.label,
    required this.icon,
    this.description,
    this.aspects = const [],
    this.timespans = const [],
  });

  factory TaskModel.preset(String id) => TaskModel(
        id: id,
        label: "New Task",
        icon: TaskIcon.green,
        description: null,
        aspects: [],
        timespans: [],
      );

  TaskModel copyWith({
    String? id,
    String? label,
    TaskIcon? icon,
    Opt<String> description,
    List<TaskAspect>? aspects,
    List<TaskTimespan>? timespans,
  }) =>
      TaskModel(
        id: id ?? this.id,
        label: label ?? this.label,
        icon: icon ?? this.icon,
        description: optEval(description, this.description),
        aspects: aspects ?? this.aspects,
        timespans: timespans ?? this.timespans,
      );

  factory TaskModel.fromMap(JsonMap map) => TaskModel(
        id: map.asCast("id"),
        label: map.asCast("label"),
        icon: map.asEnum("icon", TaskIcon.values),
        description: map.maybeCast("description"),
        aspects: map.maybeList("aspects", TaskAspect.fromMap) ?? [],
        timespans: map.maybeList("timespans", TaskTimespan.fromMap) ?? [],
      );

  @override
  get map => {
        ...super.map,
        "label": label,
        "icon": icon.name,
        "description": description,
        "aspects": aspects.map((e) => e.map).toList(),
        "timespans": timespans.map((e) => e.map).toList(),
      };
}

String durString(Duration d, [bool short = false]) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  final hm = "$h:${m.toString().padLeft(2, '0')}";
  return short ? hm : "$hm:${s.toString().padLeft(2, '0')}";
}
