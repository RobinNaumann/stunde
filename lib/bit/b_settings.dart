import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:hive/hive.dart';
import 'package:stunde/model/m_task.dart';

class Settings extends JsonModel {
  final bool showHomeStats;

  Settings({required this.showHomeStats});

  Settings copyWith({bool? showHomeStats}) {
    return Settings(showHomeStats: showHomeStats ?? this.showHomeStats);
  }

  factory Settings.fromMap(JsonMap map) {
    return Settings(showHomeStats: map.maybeCast("showHomeStats") ?? false);
  }

  @override
  get map => {"showHomeStats": showHomeStats};
}

class SettingsBit extends MapMsgBitControl<Settings> {
  static const builder = MapMsgBitBuilder<Settings, SettingsBit>.make;

  SettingsBit()
      : super.worker((v) async {
          final b = await Hive.openBox("config");
          return Settings.fromMap(Map.from(b.get("settings") ?? {})
              .map((k, v) => MapEntry("$k", v)));
        });

  set(Settings data) => act((_) async {
        (await Hive.openBox("config")).put("settings", data.map);
        return data;
      });
}
