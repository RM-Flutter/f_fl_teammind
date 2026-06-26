import 'dart:io';

void main() {
  final directories = [
    'lib/features/more/notifications',
    'lib/features/requests',
    'lib/features/payrolls',
    'lib/features/salary_advance_requests',
    'lib/features/overtime_requests',
    'lib/features/daily_reports',
    'lib/features/complaints',
    'lib/features/tasks/views/details',
    'lib/features/employee_profiles/details',
    'lib/core/widgets', // For notification_card.widget.dart and others
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
