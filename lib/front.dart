import 'dart:developer';
import 'dart:io';

import 'package:cli_dialog/cli_dialog.dart';
import 'package:project_creator/creators/creator.dart';
import 'package:project_creator/creators/dart/dart.dart';
import 'package:project_creator/creators/flutter/flutter.dart';

Future<void> projectCreatorQuestions() async {
  final dialog = CLI_Dialog(
    listQuestions: [
      [
        {
          'question': 'Type',
          'options': ['Dart', 'Flutter']
        },
        'project',
      ],
      [
        {
          'question': 'License',
          'options': ['MIT', 'GPL v3']
        },
        'license',
      ],
    ],
    questions: [
      ['Name', 'name'],
      ['Description', 'desc'],
    ],
  );
  final answers = dialog.ask();
  final Project project;
  final License license;

  switch (answers['project'] as String) {
    case "Dart":
      project = Project.dart;
      break;
    case "Flutter":
      project = Project.flutter;
      break;
    default:
      throw Exception("Unknown project.");
  }

  switch (answers['license'] as String) {
    case "MIT":
      license = License.mit;
      break;
    case "GPL v3":
      license = License.gpl3;
      break;
    default:
      throw Exception("Unknown license.");
  }

  createProject(
    project,
    name: answers["name"] as String,
    output: Directory.current,
    description: answers["desc"] as String,
    license: license,
  );
}

enum Project {
  dart,
  flutter,
}

Future<Directory> createProject(
  Project project, {
  required String name,
  required Directory output,
  required String description,
  required License license,
}) {
  switch (project) {
    case Project.dart:
      return DartProjectCreator(
        name: name,
        description: description,
        output: output,
        license: license,
      ).generate();
    case Project.flutter:
      return FlutterProjectCreator(
        name: name,
        description: description,
        output: output,
        license: license,
      ).generate();
  }
}
