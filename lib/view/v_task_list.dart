import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/bit/b_settings.dart';
import 'package:stunde/bit/b_tasks.dart';
import 'package:stunde/bit/b_timespan.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/model/m_task_aspect.dart';
import 'package:stunde/util.dart';
import 'package:stunde/view/task/analysis/v_ana_overtime.dart';

import 'task/vp_task.dart';

class TaskList extends StatelessWidget {
  final ScrollController controller;
  const TaskList({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TasksBit.builder(
        onData: (bit, tasks) => ListView(
                padding: const EdgeInsets.all(16),
                controller: controller,
                children: [
                  _CurrentView(tasks: tasks),
                  if (tasks.isEmpty)
                    Padded.symmetric(
                      vertical: 1,
                      child: WText("create a task to get started",
                          textAlign: TextAlign.center,
                          style: MacosTheme.of(context).typography.body),
                    )
                  else
                    ...tasks
                        .sortedBy((t) => t.label.toLowerCase())
                        .map((t) => _TaskSnippet(task: t))
                        .spaced(),
                  SettingsBit.builder(
                      onData: (_, s) => s.showHomeStats
                          ? Padded.only(
                              top: 2, child: TaskTimeChart(tasks: tasks))
                          : const SizedBox())
                ]));
  }
}

class _TaskSnippet extends StatelessWidget {
  final TaskModel task;
  const _TaskSnippet({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => TaskPage.navigate(context, task.id),
        child: Container(
            padding: const EdgeInsets.all(16),
            decoration: macosBoxDeco(context),
            child:
                TaskInfoSnippet(style: (t) => t.headline, task: task, actions: [
              TaskPlayButton(taskId: task.id),
            ])));
  }
}

class TaskInfoSnippet extends StatelessWidget {
  final TextStyle Function(MacosTypography) style;
  final TaskModel task;
  final List<Widget> actions;
  final bool detailed;
  const TaskInfoSnippet(
      {super.key,
      required this.style,
      required this.task,
      required this.actions,
      this.detailed = false});

  @override
  Widget build(BuildContext context) {
    final type = MacosTheme.of(context).typography;
    return Row(
      children: [
        Expanded(
          child: Hero(
              tag: "task_${task.id}",
              child: Row(
                children: [
                  Image.asset(task.icon.path, width: 16, height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WText(task.label, style: style(type)),
                        WText(
                          task.description ?? "-",
                          style: type.body,
                          maxLines: detailed ? null : 1,
                          softWrap: detailed,
                          overflow: TextOverflow.fade,
                        ),
                      ].spaced(amount: .5),
                    )),
                  )
                ].spaced(),
              )),
        ),
        ...actions.spaced(amount: .5),
      ].spaced(),
    );
  }
}

class _CurrentView extends StatelessWidget {
  final List<TaskModel> tasks;
  const _CurrentView({required this.tasks});

  Widget _stopBtn(BuildContext context) {
    final theme = MacosTheme.of(context);
    return MacosIconButton(
        boxConstraints: const BoxConstraints(),
        icon: Row(
          children: [
            MacosIcon(cupertino.CupertinoIcons.stop, color: theme.primaryColor),
            WText("stop",
                style: theme.typography.body.copyWith(
                  color: theme.primaryColor,
                )),
          ].spaced(amount: .5),
        ),
        onPressed: () => context.bit<TimespanBit>().stop());
  }

  Widget _chip(BuildContext context,
      {required String? label, IconData? icon, String? image}) {
    final theme = MacosTheme.of(context);
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: macosBoxDeco(context),
      child: Row(
        children: [
          if (image != null) Image.asset(image, width: 16, height: 16),
          if (icon != null)
            MacosIcon(
              icon,
              color: theme.typography.body.color?.withOpacity(.25),
            ),
          WText(label ?? "-", style: theme.typography.body),
        ].spaced(amount: .5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: TimespanBit.builder(
          onData: (bit, d) {
            if (d == null) return Spaced.zero;
            TaskModel? t = tasks.firstWhereOrNull((e) => e.id == d.taskId);
            TaskAspect? asp =
                t?.aspects.firstWhereOrNull((e) => e.id == d.span.aspectId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WText(
                    durString(d.span.duration),
                    textAlign: TextAlign.center,
                    style:
                        MacosTheme.of(context).typography.largeTitle.copyWith(
                      fontFeatures: [const FontFeature.tabularFigures()],
                    ),
                  ),
                  Center(
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          children: [
                        t != null && asp != null
                            ? _chip(context,
                                image: asp.icon.path(t.icon),
                                label: "${asp.label} (${t.label})")
                            : _chip(context,
                                label: t?.label, image: t?.icon.path),
                        _chip(context,
                            label: d.span.apps.values.lastOrNull?.toNameCase(),
                            icon: Icons.appWindow),
                      ].spaced(amount: .75)),
                    ),
                  ),
                  Container(
                      alignment: Alignment.center, child: _stopBtn(context))
                ].spaced(),
              ),
            );
          },
        ));
  }
}
