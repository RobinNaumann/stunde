import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/util.dart';
import 'package:system_tray/system_tray.dart';

class AspectItem extends JsonModel {
  final String id;
  final String label;
  final String? iconPath;
  final void Function()? onTap;

  AspectItem({
    required this.id,
    required this.label,
    this.iconPath,
    this.onTap,
  });

  @override
  get map => {"id": id, "label": label, "iconPath": iconPath};
}

class TaskItem extends AspectItem {
  final List<AspectItem> aspects;

  TaskItem({
    required super.id,
    required super.label,
    required this.aspects,
    super.iconPath,
    super.onTap,
  });

  @override
  get map => {"aspects": aspects.map((a) => a.map).toList(), ...super.map};
}

class TrayService {
  static TrayService i = TrayService();

  SystemTray? _trayStore;
  final List<TaskItem> _taskItems = [];
  final List<MenuItemBase> _appMenuItems = [
    MenuItemLabel(
        label: "Show Window",
        onClicked: (MenuItemBase item) => AppWindow().show()),
    MenuItemLabel(label: 'Quit', onClicked: (menuItem) => exit(0)),
  ];
  String? _activeTaskId;
  String? _activeAspectId;

  Future<SystemTray> get _tray async {
    if (_trayStore != null) return _trayStore!;
    SystemTray t = SystemTray();
    await t.initSystemTray(
      toolTip: "stunde",
      iconPath: "assets/tray_icon.png",
    );
    _trayStore = t;
    await _setMenu();

    // set event handler for opening the context menu
    t.registerSystemTrayEventHandler((e) {
      if (e == kSystemTrayEventClick) {
        t.popUpContextMenu();
      } else if (e == kSystemTrayEventRightClick) {
        AppWindow().show();
      }
    });

    return t;
  }

  Future<void> _setMenu() async {
    final task = _taskItems.firstWhereOrNull((t) => t.id == _activeTaskId);
    //final aspectExists = _taskItems.any((t) =>
    //    t.id == _activeTaskId && t.aspects.any((a) => a.id == _activeAspectId));

    MenuItemBase makeItem(AspectItem a, String? id) => MenuItemCheckbox(
          checked: a.id == id,
          label: a.label,
          image: a.iconPath,
          enabled: a.onTap != null,
          onClicked: a.onTap != null ? (MenuItemBase item) => a.onTap!() : null,
        );

    (await _tray).setContextMenu(Menu()
      ..buildFrom([
        if (task != null && task.aspects.isNotEmpty) ...[
          ...task.aspects.map((a) => makeItem(a, _activeAspectId)),
          MenuSeparator()
        ],
        ..._taskItems.map((t) => makeItem(t, _activeTaskId)),
        MenuSeparator(),
        ..._appMenuItems,
      ]));
  }

  void setTaskItems(List<TaskItem> items) {
    // check if its the same and return if it is
    if (_taskItems.isEqualTo(items)) return;

    print("SET TASK ITEMS");

    _taskItems.clear();
    _taskItems.addAll(items);
    _setMenu();
  }

  void setActiveTask(String? taskId, String? aspectId) async {
    if (_activeTaskId == taskId && _activeAspectId == aspectId) return;
    _activeTaskId = taskId;
    _activeAspectId = aspectId;
    _setMenu();
  }

  void setTitle(String title) async => (await _tray).setTitle(title);
  void setIcon(String path) async => (await _tray).setImage(path);
}
