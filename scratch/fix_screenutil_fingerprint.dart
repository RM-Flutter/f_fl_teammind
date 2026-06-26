import 'dart:io';

void main() {
  final directories = [
    'lib/features/more/team_fingerprint',
    'lib/features/fingerprint',
    'lib/core/widgets/finger_print',
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
