import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:stunde/bit/b_timespan.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/service/s_tray.dart';

import '../service/task/s_task.dart';

//const alphaNum = 'abcdefghijklmnopqrstuvwxyz0123456789';

String uniqueId(List<IdDoc> existing) {
  const length = 8;
  final key = Random().nextDouble().toStringAsFixed(length).substring(2);
  if (existing.any((e) => e.id == key)) return uniqueId(existing);
  return key;
}

class TasksBit extends MapMsgBitControl<List<TaskModel>> {
  static const builder = MapMsgBitBuilder<List<TaskModel>, TasksBit>.make;

  final TimespanBit timespanBit;

  TasksBit(this.timespanBit)
      : super.worker((v) async {
          final tasks = await TaskService.i.list();
          return tasks;
        }) {
    TaskService.i.setObserver(() => reload());
  }

  @override
  void effect(state) => state.whenData((d) {
        TrayService.i.setTaskItems(d
            .map((t) => TaskItem(
                  id: t.id,
                  label: t.label,
                  iconPath: t.icon.path,
                  aspects: t.aspects
                      .map((a) => AspectItem(
                            id: a.id,
                            label: a.label,
                            iconPath: a.icon.path(t.icon),
                            onTap: () => timespanBit.onAspectTap(t.id, a.id),
                          ))
                      .toList(),
                  onTap: () => timespanBit.onTap(t.id),
                ))
            .toList());
      });
}
