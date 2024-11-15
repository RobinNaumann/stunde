import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:hive/hive.dart' as e;
import 'package:hive/hive.dart';
import 'package:stunde/model/m_task.dart';

class Settings extends JsonModel {
  final bool showHomeStats;

  Settings({required this.showHomeStats});

  Settings copyWith({bool? showHomeStats}) {
    return Settings(showHomeStats: showHomeStats ?? this.showHomeStats);
  }

  factory Settings.fromMap(JsonMap map) {
    return Settings(showHomeStats: map.maybeCast("showHomeStats") ?? true);
  }

  @override
  get map => {"showHomeStats": showHomeStats};
}

class SettingsBit extends MapMsgBitControl<Settings> {
  static const _boxName = "config";
  static const builder = MapMsgBitBuilder<Settings, SettingsBit>.make;

  static Future<e.Box> get _box async => Hive.isBoxOpen(_boxName)
      ? Hive.box(_boxName)
      : await Hive.openBox(_boxName);

  SettingsBit()
      : super.worker((v) async =>
            (await tryCatchAsync(() async => Settings.fromMap(
                Map.from((await _box).get("settings") ?? {})
                    .map((k, v) => MapEntry("$k", v))))) ??
            Settings(showHomeStats: true));

  set(Settings data) => act((_) async {
        (await _box).put("settings", data.map);
        return data;
      });
}
