import 'dart:io';

const int maxLines = 500;
const List<String> ignoredDirectoryParts = <String>[
  '/build/',
  '/.dart_tool/',
  '/ios/',
  '/android/',
  '/linux/',
  '/macos/',
  '/windows/',
];

void main(List<String> args) {
  final root = Directory.current;
  final libDir = Directory('${root.path}/lib');

  if (!libDir.existsSync()) {
    stderr.writeln('No lib directory found at ${libDir.path}');
    exitCode = 1;
    return;
  }

  final violations = <({String path, int lines})>[];

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final normalizedPath = entity.path.replaceAll('\\', '/');
    if (ignoredDirectoryParts.any(normalizedPath.contains)) {
      continue;
    }

    final lineCount = entity.readAsLinesSync().length;
    if (lineCount > maxLines) {
      violations.add((path: normalizedPath, lines: lineCount));
    }
  }

  violations.sort((a, b) => b.lines.compareTo(a.lines));

  if (violations.isEmpty) {
    stdout.writeln('All Dart files are within $maxLines lines.');
    return;
  }

  stderr.writeln('Found ${violations.length} Dart files over $maxLines lines:');
  for (final violation in violations) {
    stderr.writeln(
      '${violation.lines.toString().padLeft(5)}  ${violation.path}',
    );
  }
  exitCode = 1;
}
