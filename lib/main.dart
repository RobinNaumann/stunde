import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:moewe/moewe.dart';
import 'package:stunde/bit/b_settings.dart';
import 'package:stunde/view/dialogs/v_task_dialog.dart';
import 'package:stunde/view/vp_settings.dart';

import 'bit/b_tasks.dart';
import 'bit/b_timespan.dart';
import 'view/v_task_list.dart';

/// This method initializes macos_window_utils and styles the window.
Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig(
    toolbarStyle: NSWindowToolbarStyle.unified,
  );
  await config.apply();
}

void main() async {
  await _configureMacosWindowUtils();
  await AppInfoService.init();
  Hive.init("stunde");
  LoggerService.init(ConsoleLoggerService());
  WidgetsFlutterBinding.ensureInitialized();

  // setup Moewe for crash logging
  await Moewe(
    host: "open.moewe.app",
    project: "826696e99519e47f",
    app: "f9a59b8c05691ff8",
    appVersion: AppInfoService.i.version,
    buildNumber: int.tryParse(AppInfoService.i.buildNr),
  ).init();

  moewe.events.appOpen();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BitProvider(
      create: (_) => SettingsBit(),
      child: BitProvider(
          create: (_) => TimespanBit(),
          child: BitProvider(
              create: (c) => TasksBit(c.bit<TimespanBit>()),
              child: Theme(
                  data: ThemeData(
                      color: ColorThemeData.fromColor(accent: Colors.blue),
                      type: TypeThemeData.preset(),
                      geometry: GeometryThemeData.preset()),
                  child: const MacosApp(
                    debugShowCheckedModeBanner: false,
                    title: 'Stunde',
                    home: MyHomePage(),
                  )))),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      //disableWallpaperTinting: true,
      child: MacosScaffold(
        toolBar: ToolBar(title: const WText("Stunde"), actions: [
          ToolBarIconButton(
              label: "add project",
              icon: const MacosIcon(CupertinoIcons.add),
              showLabel: false,
              onPressed: () => TaskDialog.show(context)),
          const ToolBarSpacer(spacerUnits: .5),
          ToolBarIconButton(
              label: "settings",
              icon: const MacosIcon(CupertinoIcons.settings),
              showLabel: false,
              onPressed: () => SettingsPage.navigate(context)),
          ToolBarIconButton(
              label: "send feedback",
              icon: const MacosIcon(CupertinoIcons.exclamationmark_bubble),
              showLabel: false,
              onPressed: () => MoeweFeedbackPage.show(
                    context,
                    labels: const FeedbackLabels(
                        header: "send feedback",
                        description:
                            "Hey ☺️ Thanks for using Stunde!\nIf you have any feedback, questions or suggestions, please let me know. I'm always happy to hear from you.",
                        contactDescription:
                            "if you want me to respond to you, please provide your email address or social media handle",
                        contactHint: "contact info (optional)"),
                    theme: MoeweTheme(
                        darkTheme:
                            MacosTheme.brightnessOf(context) == Brightness.dark,
                        backButtonOffset: 5),
                  )),
        ]),
        children: [
          ContentArea(builder: (_, ctrl) => TaskList(controller: ctrl)),
        ],
      ),
    );
  }
}
