import 'package:elbe/util/json_tools.dart';
import 'package:stunde/util.dart';

import 'm_task.dart';

enum AspectIcon {
  check,
  code,
  cook,
  design,
  mail,
  people,
  present,
  read,
  report;

  String path(TaskIcon t) => "assets/icons/aspect/a_${t.name}_$name.png";
}

class TaskAspect extends IdDoc {
  final String label;
  final AspectIcon icon;

  TaskAspect({
    required super.id,
    required this.label,
    required this.icon,
  });

  factory TaskAspect.preset(String id) => TaskAspect(
        id: id,
        label: "New Aspect",
        icon: AspectIcon.design,
      );

  TaskAspect copyWith({
    String? id,
    String? label,
    AspectIcon? icon,
  }) =>
      TaskAspect(
        id: id ?? this.id,
        label: label ?? this.label,
        icon: icon ?? this.icon,
      );

  factory TaskAspect.fromMap(JsonMap map) => TaskAspect(
        id: map.asCast("id"),
        label: map.asCast("label"),
        icon: map.asEnum("icon", AspectIcon.values),
      );

  @override
  get map => {
        ...super.map,
        "label": label,
        "icon": icon.name,
      };
}
