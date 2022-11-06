import 'dart:io';

import 'package:project_creator/creators/dart/dart.dart';
import 'package:project_creator/front.dart';

void main(List<String> arguments) async {
  await projectCreatorQuestions();
  // await DartProjectCreator(
  //   name: "this_is_a_test",
  //   output: Directory("/mnt/general/repos/flafydev/project-creator/tests/one"),
  //   githubToken:
  //       "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",
  // ).generate();
}
