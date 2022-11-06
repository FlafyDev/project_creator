import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:project_creator/creators/creator.dart';
import 'flake.nix.dart';
import 'package.nix.dart';
import 'package:project_creator/creators/shared/setup_github_repo.dart';

class DartProjectCreator extends ProjectCreator {
  DartProjectCreator({
    required super.name,
    required super.description,
    required super.output,
    required super.license,
  });

  @override
  Future<Directory> generate() async {
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
    await File(path.join(projectDirectory.path, "flake.nix")).writeAsString(
      flakeNix
          .replaceAll("<<projectName>>", name.replaceAll("_", "-"))
          .replaceAll("<<description>>", description),
    );
    await File(path.join(projectDirectory.path, ".gitignore"))
        .writeAsString("\n# Nix\nresult\n.direnv", mode: FileMode.append);

    final repoFullname = await setupGithubRepo(
      name,
      projectDirectory,
      description: description,
      license: license,
    );

    await Directory(path.join(projectDirectory.path, "nix")).create();
    await File(path.join(projectDirectory.path, "nix/package.nix"))
        .writeAsString(
      packageNix
          .replaceAll("<<projectName>>", name.replaceAll("_", "-"))
          .replaceAll("<<repoFullname>>", repoFullname)
          .replaceAll("<<license>>", license.name)
          .replaceAll("<<description>>", description),
    );

    return projectDirectory;
  }
}
