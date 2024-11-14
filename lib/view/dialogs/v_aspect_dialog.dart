import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/service/task/s_task.dart';

import '../../model/m_task_aspect.dart';
import '../util/v_dialog.dart';

class AspectDialog extends StatefulWidget {
  final TaskModel task;
  final TaskAspect? aspect;
  const AspectDialog({super.key, required this.task, required this.aspect});

  static void show(BuildContext context, TaskModel task,
          {TaskAspect? aspect}) =>
      showMacosAlertDialog(
          context: context,
          builder: (context) => AspectDialog(task: task, aspect: aspect));

  @override
  State<AspectDialog> createState() => _AspectDialogState();
}

class _AspectDialogState extends State<AspectDialog> {
  late final lCtrl = TextEditingController(text: widget.aspect?.label ?? "");
  late AspectIcon icon = widget.aspect?.icon ?? AspectIcon.values.first;

  void submit() {
    final label = lCtrl.text;
    if (label.isEmpty) return;
    TaskService.i.setAspectMeta(widget.task.id, widget.aspect?.id, label, icon);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return MacosDialog(
        title: widget.aspect == null ? "Add Aspect" : "Edit Aspect",
        primaryButton: PushButton(
            controlSize: ControlSize.large,
            onPressed: () => submit(),
            child: const WText("save")),
        secondaryButton: PushButton(
            controlSize: ControlSize.large,
            secondary: true,
            onPressed: () => Navigator.of(context).maybePop(),
            child: const WText("cancel")),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              child: MacosPopupButton(
                  value: icon,
                  items: AspectIcon.values
                      .map((e) => MacosPopupMenuItem(
                          value: e,
                          child: Image.asset(e.path(widget.task.icon),
                              width: 16, height: 16)))
                      .toList(),
                  onChanged: (v) =>
                      v == null ? null : setState(() => icon = v)),
            ),
            Expanded(
              child: MacosTextField(placeholder: "label", controller: lCtrl),
            ),
          ].spaced(amount: .25),
        ));
  }
}
