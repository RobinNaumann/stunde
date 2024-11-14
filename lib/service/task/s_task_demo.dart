part of "s_task.dart";

final _demoTasks = [
  TaskModel(
    id: "1",
    label: "Task 1",
    icon: TaskIcon.green,
    description: "This is a task",
    aspects: [
      TaskAspect(id: "1", icon: AspectIcon.code, label: "Code"),
      TaskAspect(id: "2", icon: AspectIcon.design, label: "Design App"),
      TaskAspect(id: "3", icon: AspectIcon.read, label: "Research open source"),
    ],
  ),
  TaskModel(
    id: "2",
    label: "Task 2",
    icon: TaskIcon.red,
    description: "This is a task",
  ),
];

class _DemoTaskService extends TaskService {
  Map<String, TaskModel> _tasks = _toMap(_demoTasks);

  static _toMap(List<TaskModel> t) =>
      Map.fromEntries(t.map((t) => MapEntry(t.id, t)));

  @override
  list() async => _tasks.values.toList();
  @override
  getTask(String id) async => _tasks[id]!;
  @override
  listTaskIds() async => _tasks.keys.toList();

  @override
  save(List<TaskModel> tasks) async {
    _tasks = _toMap(tasks);
    super.save(tasks);
  }

  @override
  Future<void> setTask(TaskModel task) {
    _tasks[task.id] = task;
    return super.setTask(task);
  }

  @override
  Future<void> deleteTask(String id) {
    _tasks.remove(id);
    return super.deleteTask(id);
  }
}
