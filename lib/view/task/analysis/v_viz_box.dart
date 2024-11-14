import 'package:elbe/elbe.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:stunde/util.dart';

class VizBox extends StatelessWidget {
  final String label;
  final Widget child;
  const VizBox({super.key, required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.all(16),
        decoration: macosBoxDeco(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WText(label, style: MacosTheme.of(context).typography.headline),
            child,
          ].spaced(amount: 1),
        ));
  }
}
