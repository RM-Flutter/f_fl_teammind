import 'dart:io';

void main() {
  final directories = [
    'lib/features/rewards_and_penalties',
    'lib/features/evaluation', // Might as well fix evaluations if they have the same issue
  ];

  final regex = RegExp(r'(\d+|\d+\.\d+|AppSizes\.s\d+)\.(w|h|r|sp)');

  for (final dirPath in directories) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;

    final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final content = file.readAsStringSync();
      if (regex.hasMatch(content)) {
        final newContent = content.replaceAllMapped(regex, (match) {
          return match.group(1)!;
        });
        file.writeAsStringSync(newContent);
        print('Cleaned ${file.path}');
      }
    }
  }
}
