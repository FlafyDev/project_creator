import 'dart:io';

Future<String> getTemplate(String filename,
    [Map<String, String>? substitutes]) async {
  final content = await File(
          '${Platform.environment["PCREATORASSETS"]}/templates/$filename.template')
      .readAsString();

  return content.replaceAllMapped(RegExp(r'<<(\w+)>>'),
      (match) => substitutes?[match.group(1)!] ?? "<<${match.group(1)!}>>");
}
