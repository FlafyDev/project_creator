import 'dart:io';
import 'package:mason_logger/mason_logger.dart';
import 'package:project_creator/creators/creator.dart';

import 'creators/utils/setup_github_repo.dart';

enum GitService { none, local, github, gitlab, bitbucket }

Future<void> projectCreatorQuestions() async {
  final logger = Logger();
  final name = logger.prompt('What name to give the project?');
  final description =
      logger.prompt("What should be the project's description?");
  final projectTypeStr = logger.chooseOne(
    'Which type should the project be?',
    choices: Project.values.map((e) => e.name).toList(),
  );
  final licenseStr = logger.chooseOne(
    'Which license should the project have?',
    choices: License.values.map((e) => e.name).toList(),
  );
  final gitServiceStr = logger.chooseOne(
    'Which Git service should the project be hosted on?',
    choices: GitService.values.map((e) => e.name).toList(),
  );

  final license =
      License.values.firstWhere((e) => e.name.toLowerCase() == licenseStr);

  final project = ProjectCreator.fromProject(
      Project.values.firstWhere((e) => e.name.toLowerCase() == projectTypeStr));

  final gitService = GitService.values
      .firstWhere((e) => e.name.toLowerCase() == gitServiceStr);

  project.additionalQuestions(logger);

  final progress = logger.progress('Generating Project...');
  try {
    project.generate(
      name: name,
      output: Directory.current,
      description: description,
      license: license,
      progress: progress,
      createRepo: (name, directory) async {
        progress.update('Creating repository in "${gitService.name}"...');
        switch (gitService) {
          case GitService.none:
            return [];
          case GitService.github:
            final repoUrl = await setupGithubRepo(
              name,
              directory,
              description: description,
              license: license,
            );
            return [repoUrl];
          default:
            logger.warn(
                '"${gitService.name}" is not yet supported. Repostiroty not created.');
            return [];
        }
      },
    );
    progress.complete();
  } catch (e) {
    progress.fail(e.toString());
  }
}
