import 'dart:io';

import 'package:elbe/elbe.dart';
import 'package:file_picker/file_picker.dart';
import 'package:stunde/model/m_task.dart';
import 'package:stunde/model/m_timespan.dart';

void exportAsFile(
    TaskModel task, String label, List<TaskTimespan> spans) async {
  String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'save the Stunde export file',
      fileName:
          "stunde_export_${task.label.toLowerCase().replaceAll(" ", "-")}_$label.csv");
  if (outputFile == null) return;

  final List<List<String>> lines = [
    ["task", "aspect", "start", "end", "apps"],
    ...spans.map((span) => _transformToCsv(task, span))
  ];

  await File(outputFile)
      .writeAsString(lines.map((l) => l.join(",")).join("\n"));
}

List<String> _transformToCsv(TaskModel task, TaskTimespan span) => [
      task.label,
      task.aspects.firstWhereOrNull((a) => a.id == span.aspectId)?.label ?? "",
      span.startDate.toIso8601String(),
      span.endDate.toIso8601String(),
      span.apps.values.toSet().map((a) => "'$a'").join(" ")
    ];
