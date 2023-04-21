import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:project_creator/creators/creator.dart';
import 'package:project_creator/creators/utils/setup_github_repo.dart';
import 'package:project_creator/creators/utils/get_template.dart';

class DartProjectCreator extends ProjectCreator {
  @override
  Future<Directory> generate({
    required String name,
    required Directory output,
    required String description,
    required License license,
    required Progress progress,
    required Future<List<String>> Function(String name, Directory directory)
        createRepo,
  }) async {
    if (name.contains("-")) {
      throw Exception("Not a valid Dart project name.");
    }
    await Process.run(
      "dart",
      [
        "create",
        "-t",
        "console",
        name,
      ],
      workingDirectory: output.path,
    );
    final projectDirectory = Directory(path.join(output.path, name));
    await File(path.join(projectDirectory.path, ".envrc"))
        .writeAsString("use flake");
    await File(path.join(projectDirectory.path, "flake.nix"))
        .writeAsString(await getTemplate("dart/flake.nix", {
      "projectName": name.replaceAll("_", "-"),
      "description": description,
    }));
    await File(path.join(projectDirectory.path, ".gitignore"))
        .writeAsString("\n# Nix\nresult\n.direnv", mode: FileMode.append);

    final repoUrl = await setupGithubRepo(
      name,
      projectDirectory,
      description: description,
      license: license,
    );

    await Directory(path.join(projectDirectory.path, "nix")).create();
    await File(path.join(projectDirectory.path, "nix/package.nix"))
        .writeAsString(await getTemplate("dart/package.nix", {
      "projectName": name.replaceAll("_", "-"),
      "repoUrl": repoUrl,
      "license": license.name,
      "description": description
    }));

    return projectDirectory;
  }
}
