import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';

const _kDialogBorderRadius = BorderRadius.all(Radius.circular(12.0));
const _kDefaultDialogConstraints = BoxConstraints(
  minWidth: 260,
  maxWidth: 260,
);

class MacosDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final PushButton primaryButton;
  final PushButton? secondaryButton;

  const MacosDialog(
      {super.key,
      required this.title,
      required this.child,
      required this.primaryButton,
      this.secondaryButton});

  @override
  Widget build(BuildContext context) {
    final brightness = MacosTheme.brightnessOf(context);

    final outerBorderColor = brightness.resolve(
      Colors.black.withOpacity(0.23),
      Colors.black.withOpacity(0.76),
    );

    final innerBorderColor = brightness.resolve(
      Colors.white.withOpacity(0.45),
      Colors.white.withOpacity(0.15),
    );

    return Dialog(
      backgroundColor: brightness.resolve(Color(0xFFeaeaea), Color(0xFF242424)),

      /*brightness.resolve(
        CupertinoColors.systemGrey6.color,
        MacosColors.controlBackgroundColor.darkColor,
      ),*/
      shape: const RoundedRectangleBorder(
        borderRadius: _kDialogBorderRadius,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          border: WBorder.all(
            width: 2,
            color: innerBorderColor,
          ),
          borderRadius: _kDialogBorderRadius,
        ),
        foregroundDecoration: BoxDecoration(
          border: WBorder.all(
            width: 1,
            color: outerBorderColor,
          ),
          borderRadius: _kDialogBorderRadius,
        ),
        child: ConstrainedBox(
          constraints: _kDefaultDialogConstraints,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              DefaultTextStyle(
                style: MacosTheme.of(context).typography.headline,
                textAlign: TextAlign.center,
                child: WText(title),
              ),
              const SizedBox(height: 16),
              child,
              const SizedBox(height: 16),
              Row(
                children: [
                  if (secondaryButton != null) ...[
                    Expanded(child: secondaryButton!),
                    const SizedBox(width: 8.0),
                  ],
                  Expanded(
                    child: primaryButton,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
