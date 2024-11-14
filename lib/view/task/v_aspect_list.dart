import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/service/task/s_task.dart';
import 'package:stunde/view/dialogs/v_aspect_dialog.dart';
import 'package:stunde/view/task/vp_task.dart';
import 'package:stunde/view/util/confirm.dart';

import '../../util.dart';

class TaskAspectsList extends StatelessWidget {
  final TaskModel task;
  const TaskAspectsList({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: WText("Aspects", style: theme.typography.headline)),
            MacosIconButton(
                icon: const WIcon(CupertinoIcons.add),
                onPressed: () => AspectDialog.show(context, task)),
          ].spaced(),
        ),
        if (task.aspects.isEmpty)
          Padded.symmetric(
              vertical: 1,
              child: const WText("create aspects of a task\nto track sub-tasks",
                  textAlign: TextAlign.center)),
        ...task.aspects
            .sortedBy((t) => t.label.toLowerCase())
            .map((a) => GestureDetector(
                  onTap: () => AspectDialog.show(context, task, aspect: a),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                    decoration: macosBoxDeco(context),
                    child: Row(
                      children: [
                        Image.asset(a.icon.path(task.icon),
                            width: 16, height: 16),
                        Expanded(
                            child: WText(
                          a.label,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.fade,
                        )),
                        TaskPlayButton(taskId: task.id, aspectId: a.id),
                        MacosIconButton(
                            icon: WIcon(
                              CupertinoIcons.xmark,
                              color: MacosTheme.of(context).dividerColor,
                            ),
                            onPressed: () => confirm(context,
                                title: "Delete aspect",
                                message:
                                    "Are you sure you want to delete this aspect?",
                                onConfirm: () =>
                                    TaskService.i.deleteAspect(task.id, a.id)))
                      ].spaced(amount: .5),
                    ),
                  ),
                )),
      ].spaced(amount: .5),
    );
  }
}
