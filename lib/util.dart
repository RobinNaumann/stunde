import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:elbe/util/json_tools.dart';
import 'package:macos_ui/macos_ui.dart';

const _months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

const _monthsShort = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

extension UnixFormat on UnixMs {
  String formatUnixDuration() {
    final Duration d = Duration(milliseconds: this);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    return "${d.inHours}:$twoDigitMinutes";
  }
}

extension DateString on DateTime {
  String sFormatHour() => "${hour.toString().padLeft(2, "0")}:"
      "${minute.toString().padLeft(2, "0")}";
  String sFormat([bool withYear = false]) =>
      "$day. ${_monthsShort[month - 1]}${withYear ? " $year" : ""}";
  String sMonthName([bool withYear = false]) =>
      "${_months[month - 1]}${withYear ? " $year" : ""}";

  UnixMs get unixMs => millisecondsSinceEpoch;
  static fromUnixMs(UnixMs ms) => DateTime.fromMillisecondsSinceEpoch(ms);
}

/// get enum value from string
extension EnumExt on JsonMap {
  List<T> list<T>(String key, T Function(JsonMap) fromMap) =>
      maybeList(key, fromMap)!;

  List<T>? maybeList<T>(String key, T Function(JsonMap) fromMap) {
    List? l = maybeCast(key);
    if (l == null) return null;
    return l.map((e) => fromMap(Map.from(e))).toList();
  }

  T asEnum<T extends Enum>(String key, List<T> values) =>
      maybeEnum(key, values)!;

  T? maybeEnum<T extends Enum>(String key, List<T> values) {
    final String? v = maybeCast(key);
    if (v != null) {
      for (final e in values) {
        if (e.toString().split(".").last == v) return e;
      }
    }
    return null;
  }
}

extension ListMap<T> on Iterable<T> {
  List<O> listMap<O>(O Function(T) f) => map(f).toList();

  bool isEqualTo(Iterable<T> other) {
    if (length != other.length) return false;
    for (int i = 0; i < length; i++) {
      if (elementAt(i) != other.elementAt(i)) return false;
    }
    return true;
  }
}

extension NameCaseExt on String {
  String toNameCase() => split(" ")
      .map((word) => word.isNotEmpty
          ? (word[0].toUpperCase() + word.substring(1).toLowerCase())
          : "")
      .join(" ");
}

BoxDecoration macosBoxDeco(BuildContext c) => BoxDecoration(
    color: MacosTheme.of(c).canvasColor,
    border: WBorder.all(color: MacosTheme.of(c).dividerColor),
    borderRadius: BorderRadius.circular(12));

Future<String?> activeApp() async {
  try {
    // get the current app pid
    final p = (await Process.run("lsappinfo", ["front"])).stdout;

    // get the app name
    final r = await Process.run("lsappinfo", ["info", "--only", "name", p]);

    // parse and return the app name
    if (r.exitCode != 0) throw r.stderr;
    return (r.stdout as String)
        .split("=")
        .last
        .replaceAll('"', '')
        .trim()
        .toLowerCase();
  } catch (e) {
    return null;
  }
}
