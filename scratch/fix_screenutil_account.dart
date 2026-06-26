import 'dart:io';

void main() {
  final directories = [
    'lib/features/more/customized_notification',
    'lib/features/more/language_settings',
    'lib/features/more/update_profile',
    'lib/features/personal_profile',
    'lib/features/more/user_device',
    'lib/features/authentication/forgot_password/views' // Just in case, as the user mentioned the forgot password dialog earlier too, though it was somewhat fixed, good to ensure.
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
