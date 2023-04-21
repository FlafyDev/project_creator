import 'dart:io';

import 'package:mason_logger/mason_logger.dart';

import 'dart/dart.dart';
import 'flutter/flutter.dart';

enum License {
  mit,
  gpl3,
}

extension LicenseExtension on License {
  String get key {
    switch (this) {
      case License.mit:
        return "mit";
      case License.gpl3:
        return "gpl-3.0";
    }
  }
}

enum Project {
  dart,
  flutter,
}

abstract class ProjectCreator {
  ProjectCreator();

  factory ProjectCreator.fromProject(Project project) {
    switch (project) {
      case Project.dart:
        return DartProjectCreator();
      case Project.flutter:
        return FlutterProjectCreator();
    }
  }

  Future<Directory> generate({
    required String name,
    required Directory output,
    required String description,
    required License license,
    required Progress progress,
    required Future<List<String>> Function(String name, Directory directory) createRepo,
  });

  void additionalQuestions(Logger logger) {}
}
