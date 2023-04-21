import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:project_creator/creators/creator.dart';

Future<String> setupGithubRepo(
  String name,
  Directory directory, {
  required String description,
  required License license,
}) async {
  final ghRes = await Process.run(
    "gh",
    [
      "repo",
      "create",
      name,
      "--private",
      "--description",
      description,
      "--license",
      license.key,
    ],
    workingDirectory: directory.path,
  );
  final repoFullname =
      RegExp("github\\.com/(.*)").firstMatch(ghRes.stdout)?.group(1);
  if (repoFullname == null) throw Exception("Couldn't create gh repo.");
  await Process.run(
    "git",
    ["clone", "git@github.com:$repoFullname.git"],
    workingDirectory: directory.path,
  );
  await Directory(path.joinAll([directory.path, name, ".git"]))
      .rename(path.joinAll([directory.path, ".git"]));
  await File(path.joinAll([directory.path, name, "LICENSE"]))
      .rename(path.joinAll([directory.path, "LICENSE"]));
  await Directory(path.joinAll([directory.path, name])).delete();
  final repoUrl = "https://github.com/$repoFullname";
  return repoUrl;
}
