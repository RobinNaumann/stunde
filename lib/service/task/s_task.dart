import 'dart:math';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:hive/hive.dart' as hive;
import 'package:stunde/util.dart';

import '../../model/m_task.dart';
import '../../model/m_task_aspect.dart';
import '../../model/m_timespan.dart';

part "s_task_demo.dart";

abstract class TaskService {
  Function()? _onChange;
  static TaskService i = _RealTaskService();

  void setObserver(Function() onChange) => _onChange = onChange;
  void notify() => _onChange?.call();

  Future<TaskModel> getTask(String id);
  Future<List<TaskModel>> list();
  Future<List<String>> listTaskIds();

  @mustCallSuper
  Future<void> save(List<TaskModel> tasks) async => notify();

  @mustCallSuper
  Future<void> setTask(TaskModel task) async => notify();

  @mustCallSuper
  Future<void> deleteTask(String id) async => notify();

  @mustCallSuper
  Future<void> reset() async => notify();

  /// ======= CONCRETE METHODS =======

  Future<String> uniqueId(List<String> existing, [int length = 8]) async {
    final key =
        "id${Random().nextDouble().toStringAsFixed(length).substring(2)}";
    return existing.contains(key) ? uniqueId(existing) : key;
  }

  Future<String> uniqueTaskId() async => uniqueId(await listTaskIds());

  Future<void> deleteAspect(String taskId, String aspectId) async {
    final task = await getTask(taskId);
    await setTask(task.copyWith(
        aspects: task.aspects..removeWhere((a) => a.id == aspectId)));
  }

  Future<void> setTaskMeta(
    String? id,
    String label,
    TaskIcon icon,
    Opt<String> description,
  ) async {
    final task = id != null
        ? (await getTask(id))
        : TaskModel.preset(await uniqueTaskId());

    await setTask(
        task.copyWith(label: label, icon: icon, description: description));

    notify();
  }

  Future<void> setTimespan(String taskId, TaskTimespan timespan) async {
    final task = await getTask(taskId);
    final spans = [...task.timespans];
    // delete overlapping timespans
    spans.removeWhere((t) => t.isFullyShadowed(timespan));
    await setTask(task.copyWith(timespans: [...spans, timespan]));
    notify();
  }

  Future<void> deleteTimespan(String taskId, UnixMs start) async {
    final task = await getTask(taskId);
    await setTask(task.copyWith(
        timespans: task.timespans.where((t) => t.start != start).toList()));
    notify();
  }

  Future<void> setAspectMeta(
    String taskId,
    String? id,
    String label,
    AspectIcon icon,
  ) async {
    final task = await getTask(taskId);
    final aspect = id != null
        ? task.aspects.firstWhere((a) => a.id == id)
        : TaskAspect.preset(await uniqueId(task.aspects.listMap((a) => a.id)));

    await setTask(task.copyWith(
      aspects: [...task.aspects]
        ..removeWhere((a) => a.id == id)
        ..add(aspect.copyWith(label: label, icon: icon)),
    ));

    notify();
  }
}

class _RealTaskService extends TaskService {
  static const _name = "tasks";

  Future<hive.Box<Map>> _taskBox() async => hive.Hive.isBoxOpen(_name)
      ? hive.Hive.box(_name)
      : hive.Hive.openBox(_name);

  Future<JsonMap<JsonMap>> _tasksMap() async {
    final box = await _taskBox();
    final JsonMap map = box.toMap().map((k, v) => MapEntry("$k", v));
    final JsonMap<JsonMap> jmap = map.map(
        (k, v) => MapEntry(k, (v as Map).map((k, v) => MapEntry("$k", v))));
    return jmap;
  }

  @override
  getTask(String id) async => TaskModel.fromMap((await _tasksMap()).get(id)!);
  @override
  list() async =>
      (await _tasksMap()).values.listMap((v) => TaskModel.fromMap(v));
  @override
  listTaskIds() async => (await _tasksMap()).keys.listMap((k) => k);

  @override
  save(List<TaskModel> tasks) async {
    final box = await _taskBox();
    await box.clear();
    await box.putAll(Map.fromEntries(tasks.map((t) => MapEntry(t.id, t.map))));
    super.save(tasks);
  }

  @override
  Future<void> setTask(TaskModel task) async {
    final box = await _taskBox();
    await box.put(task.id, task.map);
    super.setTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    await (await _taskBox()).delete(id);
    super.deleteTask(id);
  }

  @override
  Future<void> reset() async {
    await (await _taskBox()).clear();
    super.reset();
  }
}
