import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:project_creator/creators/creator.dart';
import 'package:project_creator/creators/utils/get_template.dart';

class FlutterProjectCreator extends ProjectCreator {
  late bool layerShell;

  @override
  void additionalQuestions(Logger logger) {
    layerShell = logger.confirm("Do you want to implement Layer Shell?");
  }

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
      throw Exception("Not a valid Flutter project name.");
    }

    await Process.run(
      "flutter",
      [
        "create",
        name,
        "--empty",
      ],
      workingDirectory: output.path,
    );
    final projectDirectory = Directory(path.join(output.path, name));
    File getProjFile(String filename) =>
        File(path.join(projectDirectory.path, filename));

    await getProjFile(".envrc").writeAsString("use flake");

    await getProjFile("flake.nix").writeAsString(await getTemplate(
        layerShell ? "flutter/ls/flake.nix" : "flutter/flake.nix", {
      "projectName": name.replaceAll("_", "-"),
      "description": description,
    }));

    await getProjFile(".gitignore")
        .writeAsString("\n# Nix\nresult\n.direnv", mode: FileMode.append);

    await getProjFile("ios").delete(recursive: true);
    await getProjFile("android").delete(recursive: true);
    await getProjFile("macos").delete(recursive: true);
    await getProjFile("web").delete(recursive: true);
    await getProjFile("windows").delete(recursive: true);
    await getProjFile(".idea").delete(recursive: true);
    await getProjFile("$name.iml").delete(recursive: true);

    await getProjFile("pubspec.yaml").writeAsString(
      (await getProjFile("pubspec.yaml").readAsString()).replaceAll(
        "description: A new Flutter project.",
        "description: $description",
      ),
    );

    await getProjFile("analysis_options.yaml")
        .writeAsString(await getTemplate("flutter/analysis_options.yaml"));

    await Directory(path.join(projectDirectory.path, "assets")).create();

    await getProjFile("pubspec.yaml").writeAsString(
      (await getProjFile("pubspec.yaml").readAsString()).replaceFirstMapped(
        RegExp("\$flutter:", multiLine: true),
        (_) => "flutter:\n  assets:\n    - assets/",
      ),
    );

    await getProjFile("lib/main.dart")
        .writeAsString(await getTemplate("flutter/main.dart"));

    await getProjFile("linux/my_application.cc").writeAsString(
        await getTemplate(
            layerShell
                ? "flutter/ls/my_application.cc"
                : "flutter/my_application.cc",
            {
          "projectName": name,
        }));

    await getProjFile("linux/my_application.h").writeAsString(
        "#include <flutter_linux/flutter_linux.h>\n${await getProjFile("linux/my_application.h").readAsString()}");

    if (layerShell) {
      await getProjFile("linux/CMakeLists.txt").writeAsString(
        (await getProjFile("linux/CMakeLists.txt").readAsString()).replaceAll(
            "find_package(PkgConfig REQUIRED)",
            "find_package(PkgConfig REQUIRED)\npkg_check_modules(GTKLAYERSHELL REQUIRED IMPORTED_TARGET gtk-layer-shell-0)"),
      );

      await getProjFile("linux/CMakeLists.txt").writeAsString(
        (await getProjFile("linux/CMakeLists.txt").readAsString()).replaceAll(
            "target_link_libraries(\${BINARY_NAME} PRIVATE flutter)",
            "target_link_libraries(\${BINARY_NAME} PRIVATE flutter)\ntarget_link_libraries(\${BINARY_NAME} PRIVATE PkgConfig::GTKLAYERSHELL)"),
      );
    }

    progress.update("Installing Flutter dependencies...");

    final removeDeps = ["flutter_test", "flutter_lints"];
    final addDevDeps = ["very_good_analysis", "custom_lint", "riverpod_lint"];
    final addDeps = ["flutter_hooks", "hooks_riverpod"];

    await Process.run("flutter", ["pub", "add", ...addDeps],
        workingDirectory: projectDirectory.path);
    await Process.run("flutter", ["pub", "add", "-d", ...addDevDeps],
        workingDirectory: projectDirectory.path);
    await Process.run("flutter", ["pub", "remove", ...removeDeps],
        workingDirectory: projectDirectory.path);

    final repoUrls = await createRepo(name, projectDirectory);

    await Directory(path.join(projectDirectory.path, "nix")).create();
    await getProjFile("nix/package.nix").writeAsString(await getTemplate(
        layerShell ? "flutter/ls/package.nix" : "flutter/package.nix", {
      "projectName": name.replaceAll("_", "-"),
      "repoUrl": repoUrls.isEmpty ? "none" : repoUrls.first,
      "license": license.name,
      "description": description
    }));

    await Process.run("git", ["add", "."],
        workingDirectory: projectDirectory.path);

    return projectDirectory;
  }
}
