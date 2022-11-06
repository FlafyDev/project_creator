import 'dart:io';

enum License {
  mit,
  gpl3,
}

abstract class ProjectCreator {
  final String name;
  final Directory output;
  final String description;
  final License license;

  ProjectCreator({
    required this.name,
    required this.output,
    required this.description,
    required this.license,
  });

  Future<Directory> generate();
}
