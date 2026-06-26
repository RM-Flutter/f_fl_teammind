import 'dart:io';

void main() {
  final directories = [
    'lib/features/complaints', // Ticket system
    'lib/features/points', // Points
    'lib/features/employee_profiles', // Employees directory
    'lib/features/pages', // Articles / Default Page
    'lib/features/more/about_us', // About Company
    'lib/features/more/contact_us', // Contact Us
    'lib/features/more/faqs', // FAQs
    'lib/features/more/general_data', // Company Policy
    'lib/features/more/request_terms', // Request Terms
    'lib/features/more/company_structure', // Company Structure (just in case)
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
