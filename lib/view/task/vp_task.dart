import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/bit/b_tasks.dart';
import 'package:stunde/service/task/s_task.dart';
import 'package:stunde/view/dialogs/v_task_dialog.dart';
import 'package:stunde/view/task/analysis/v_task_analysis.dart';
import 'package:stunde/view/v_task_list.dart';

import '../../bit/b_timespan.dart';
import '../util/confirm.dart';
import 'v_aspect_list.dart';

class TaskPage extends StatelessWidget {
  final String taskId;
  const TaskPage({super.key, required this.taskId});

  static navigate(BuildContext context, String taskId) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => TaskPage(taskId: taskId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TasksBit.builder(onData: (bit, tasks) {
      final task = tasks.firstWhereOrNull((e) => e.id == taskId);

      return MacosScaffold(
        toolBar: ToolBar(
          title: const WText("task"),
          actions: [
            if (task != null)
              ToolBarIconButton(
                  label: "delete task",
                  icon: const MacosIcon(CupertinoIcons.trash),
                  showLabel: false,
                  onPressed: () => confirm(context,
                          title: "Delete Task",
                          message:
                              "Are you sure you want to delete this task? All tracked time will also be deleted.",
                          onConfirm: () {
                        TaskService.i.deleteTask(task.id);
                        Navigator.of(context).maybePop();
                      }))
          ],
        ),
        children: [
          ContentArea(builder: (_, ctrl) {
            if (task == null) return const WText("Task not found");
            return ListView(
              padding: const EdgeInsets.all(16),
              controller: ctrl,
              children: [
                // task info
                GestureDetector(
                  onTap: () => TaskDialog.show(context, task: task),
                  child: TaskInfoSnippet(
                      style: (t) =>
                          t.headline.copyWith(fontSize: context.rem(1.2)),
                      task: task,
                      detailed: true,
                      actions: [
                        TaskPlayButton(taskId: task.id),
                      ]),
                ),

                TaskAspectsList(task: task),
                TaskAnalysisView(task: task),
              ].spaced(amount: 2),
            );
          }),
        ],
      );
    });
  }
}

class TaskPlayButton extends StatelessWidget {
  final String taskId;
  final String? aspectId;
  const TaskPlayButton({super.key, required this.taskId, this.aspectId});

  @override
  Widget build(BuildContext context) => TimespanBit.builder(
        onData: (bit, span) {
          final r = span?.taskId == taskId && span?.span.aspectId == aspectId;
          final back = r ? MacosTheme.of(context).primaryColor : null;
          final front = r ? Colors.white : null;
          return MacosIconButton(
            backgroundColor: back,
            hoverColor: back,
            icon: MacosIcon(
              r ? CupertinoIcons.stop : CupertinoIcons.play,
              color: front,
            ),
            onPressed: () => r ? bit.stop() : bit.start(taskId, aspectId),
          );
        },
      );
}
