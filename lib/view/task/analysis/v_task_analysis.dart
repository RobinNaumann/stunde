import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/bit/b_analysis.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/util.dart';
import 'package:stunde/view/task/analysis/v_ana_bytask.dart';
import 'package:stunde/view/task/analysis/v_ana_overtime.dart';
import 'package:stunde/view/util/export_analysis.dart';

import 'v_ana_overview.dart';

class TaskAnalysisView extends StatelessWidget {
  final TaskModel task;
  const TaskAnalysisView({super.key, required this.task});

  Widget _arrowBtn(AnalysisOptions options, bool next) {
    final t = next ? options.period?.next : options.period?.prev;
    return Builder(
        builder: (context) => MacosIconButton(
            disabledColor: Colors.transparent,
            onPressed: t == null
                ? null
                : () => context.bit<AnalysisBit>().setPeriod(t),
            icon: WIcon(
                next
                    ? CupertinoIcons.chevron_right
                    : CupertinoIcons.chevron_left,
                color:
                    t == null ? MacosTheme.of(context).dividerColor : null)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = MacosTheme.of(context);
    return BitBuildProvider(
      create: (context) => AnalysisBit(),
      onData: (bit, AnalysisOptions view) {
        final spans = bit.filtered(task.timespans) ?? [];
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                    child: WText("Analysis", style: theme.typography.headline)),
                MacosIconButton(
                    onPressed: () {}, icon: const WIcon(CupertinoIcons.add)),
              ].spaced(),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                height: 42,
                decoration: macosBoxDeco(context),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    MacosPopupButtonTheme(
                        data: MacosPopupButtonTheme.of(context).copyWith(
                          highlightColor: MacosTheme.of(context).dividerColor,
                          backgroundColor: MacosTheme.of(context).canvasColor,
                        ),
                        child: MacosPopupButton(
                            onChanged: (v) => bit.setPeriod(v == null
                                ? null
                                : AnalysisPeriod(
                                    scope: v, within: DateTime.now())),
                            value: view.period?.scope,
                            items: [
                              ...ATScope.values
                                  .listMap((e) => MacosPopupMenuItem(
                                        value: e,
                                        child: WText(e.label),
                                      )),
                              const MacosPopupMenuItem(
                                  value: null, child: WText("All")),
                            ])),
                    Row(children: [
                      _arrowBtn(view, false),
                      _arrowBtn(view, true),
                    ]),
                    if (view.period != null &&
                        MediaQuery.of(context).size.width > 400)
                      Padded.only(
                          right: .25,
                          child: WText(view.period?.spanLabel ?? "")),
                  ].spaced(amount: .5),
                ),
              ),
              Container(
                  height: 42,
                  decoration: macosBoxDeco(context),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: MacosIconButton(
                      onPressed: () => exportAsFile(
                          task,
                          view.period?.spanLabel
                                  .toLowerCase()
                                  .replaceAll(" ", "") ??
                              "all",
                          spans),
                      icon: const MacosIcon(CupertinoIcons.share)))
            ]),
            Padded.only(
              top: .5,
              child: Column(
                children: [
                  OverviewViz(options: view, spans: spans, task: task),
                  OverTimeViz(options: view, spans: spans, task: task),
                  ByAspectViz(spans: spans, task: task),
                  ByAppViz(spans: spans, task: task)
                ].spaced(amount: 1),
              ),
            )
          ].spaced(amount: .5),
        );
      },
    );
  }
}
