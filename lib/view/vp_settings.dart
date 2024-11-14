import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/bit/b_settings.dart';
import 'package:stunde/service/task/s_task.dart';
import 'package:stunde/view/util/confirm.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static navigate(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MacosScaffold(
        toolBar: ToolBar(
          //leading: const MacosBackButton(),
          title: WText("Settings"),
        ),
        children: [
          ContentArea(builder: (context, sc) {
            return SettingsBit.builder(
                onData: (bit, data) => ListView(
                      padding: EdgeInsets.all(context.rem(1)),
                      controller: sc,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: const WText(
                                    "show overview graph on task list")),
                            MacosSwitch(
                              value: data.showHomeStats,
                              onChanged: (v) => bit.set(data.copyWith(
                                  showHomeStats: !data.showHomeStats)),
                            ),
                          ],
                        ),
                        Padded.only(
                          top: 1,
                          child: PushButton(
                              secondary: true,
                              onPressed: () => confirm(context,
                                      title: "Delete all data?",
                                      message:
                                          "Are you sure you want to delete all data? This action cannot be undone. Consider exporting your data first.",
                                      onConfirm: () async {
                                    await TaskService.i.reset();
                                    Navigator.of(context).maybePop();
                                  }),
                              controlSize: ControlSize.large,
                              child: const WText("delete all data")),
                        )
                      ].spaced(),
                    ));
          })
        ]);
  }
}
