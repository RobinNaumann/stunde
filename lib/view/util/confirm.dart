import 'package:elbe/elbe.dart';
import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

Future<bool> confirm(BuildContext context,
    {required String title,
    required String message,
    Function()? onConfirm}) async {
  return await showMacosAlertDialog<bool>(
          context: context,
          builder: (c) => MacosAlertDialog(
                appIcon:
                    const MacosIcon(CupertinoIcons.exclamationmark_triangle),
                title: WText(title),
                message: WText(
                  message,
                  style: MacosTheme.of(c).typography.body,
                ),
                secondaryButton: PushButton(
                    secondary: true,
                    onPressed: () => Navigator.of(context).pop(false),
                    controlSize: ControlSize.large,
                    child: const WText("no")),
                primaryButton: PushButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                      onConfirm?.call();
                    },
                    controlSize: ControlSize.large,
                    child: const WText("yes")),
              )) ??
      false;
}
