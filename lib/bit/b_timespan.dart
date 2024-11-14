import 'dart:async';

import 'package:elbe/elbe.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/service/s_tray.dart';
import 'package:stunde/util.dart';

import '../model/m_timespan.dart';
import '../service/task/s_task.dart';

const _timerDur = Duration(seconds: 1);

class TimespanState {
  final String taskId;
  final TaskTimespan span;

  TimespanState.now(this.taskId, [String? aspectId])
      : span = TaskTimespan(
          start: DateTime.now().asUnixMs,
          end: DateTime.now().asUnixMs,
          aspectId: aspectId,
        );

  TimespanState({required this.taskId, required this.span});

  TimespanState update(String? app) {
    var apps = span.apps;

    if (app != null && apps.entries.lastOrNull?.value != app) {
      apps = {...apps, DateTime.now().asUnixMs: app};
    }

    return TimespanState(
      taskId: taskId,
      span: span.copyWith(apps: apps, end: DateTime.now().asUnixMs),
    );
  }
}

class TimespanBit extends MapMsgBitControl<TimespanState?> {
  static const builder = MapMsgBitBuilder<TimespanState?, TimespanBit>.make;

  TimespanBit() : super.worker((_) => null);

  @override
  effect(state) => state.whenData((d) async {
        _setTrayInfo(d);
        if (d != null) TaskService.i.setTimespan(d.taskId, d.span);

        Future.delayed(_timerDur, () async {
          var appName = await activeApp();
          if (appName == "stunde") appName = "finder";

          final s = this.state.whenData((d) => d);
          if (s != null) emit(s.update(appName));
        });
      });

  void _setTrayInfo(TimespanState? d) async {
    if (d == null) {
      TrayService.i
        ..setTitle("")
        ..setIcon("assets/tray_icon.png")
        ..setActiveTask(null, null);
      return;
    }

    TrayService.i
      ..setTitle(durString(d.span.duration, true))
      ..setActiveTask(d.taskId, d.span.aspectId);

    final tasks = await TaskService.i.list();
    final task = tasks.firstWhereOrNull((e) => e.id == d.taskId);
    if (task != null) {
      if (d.span.aspectId != null) {
        final a = task.aspects.firstWhereOrNull((e) => e.id == d.span.aspectId);
        if (a != null) TrayService.i.setIcon(a.icon.path(task.icon));
      } else {
        TrayService.i.setIcon(task.icon.path);
      }
    }
  }

  void start(String taskId, String? aspectId) {
    stop();
    emit(TimespanState.now(taskId, aspectId));
  }

  void stop() => state.whenData((d) {
        if (d == null) return;
        //TaskService.i.setTimespan(d.taskId, d.span);
        emit(null);
      });

  void onTap(String taskId) => state.whenData(
      (d) => d == null || d.taskId != taskId ? start(taskId, null) : stop());

  void onAspectTap(String taskId, String aspectId) =>
      state.whenData((d) => d?.span.aspectId != aspectId
          ? start(taskId, aspectId)
          : start(taskId, null));
}
