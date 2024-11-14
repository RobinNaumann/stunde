import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/service/task/s_task.dart';

import '../../model/m_task.dart';
import '../util/v_dialog.dart';

class TaskDialog extends StatefulWidget {
  final TaskModel? task;
  const TaskDialog({super.key, required this.task});

  static void show(BuildContext context, {TaskModel? task}) =>
      showMacosAlertDialog(
          context: context, builder: (context) => TaskDialog(task: task));

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final lCtrl = TextEditingController(text: widget.task?.label);
  late final dCtrl = TextEditingController(text: widget.task?.description);

  late TaskIcon icon = widget.task?.icon ?? TaskIcon.values.first;

  void submit() {
    final label = lCtrl.text;
    final description = dCtrl.text;
    if (label.isEmpty) return;
    TaskService.i.setTaskMeta(widget.task?.id, label, icon, () => description);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return MacosDialog(
        title: widget.task == null ? "Add Task" : "Edit Task",
        primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () => submit(),
            child: const WText("save")),
        secondaryButton: PushButton(
            controlSize: ControlSize.large,
            secondary: true,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const WText("cancel")),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  child: MacosPopupButton(
                      value: icon,
                      items: TaskIcon.values
                          .map((e) => MacosPopupMenuItem(
                              value: e,
                              child:
                                  Image.asset(e.path, width: 16, height: 16)))
                          .toList(),
                      onChanged: (v) =>
                          v == null ? null : setState(() => icon = v)),
                ),
                Expanded(
                  child:
                      MacosTextField(placeholder: "label", controller: lCtrl),
                ),
              ].spaced(amount: .25),
            ),
            MacosTextField(
                maxLines: 2,
                minLines: 2,
                placeholder: "description",
                controller: dCtrl),
          ].spaced(amount: .5),
        ));
  }
}
