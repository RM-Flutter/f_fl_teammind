import 'dart:io';

void main() {
  var files = [
    'lib/features/home/views/home_screen.dart',
    'lib/features/home/views/widgets/page_header_widgets/home_appbar.widget.dart',
    'lib/features/more/more_screen.dart',
    'lib/features/more/more_screen.dart' // Just to make sure we process it
  ];

  for (var file in files) {
    var f = File(file);
    if (!f.existsSync()) continue;
    
    var content = f.readAsStringSync();
    
    // Replace .sh and .sw first
    content = content.replaceAll('0.25.sh', 'MediaQuery.sizeOf(context).height * 0.25');
    content = content.replaceAll('0.14.sh', 'MediaQuery.sizeOf(context).height * 0.14');
    content = content.replaceAll('0.15.sh', 'MediaQuery.sizeOf(context).height * 0.15');
    content = content.replaceAll('1.sw', 'MediaQuery.sizeOf(context).width');
    content = content.replaceAll('0.5.sw', 'MediaQuery.sizeOf(context).width * 0.5');

    // Remove .w, .h, .r, .sp when they are attached to numbers or AppSizes
    // Regex matches digit or AppSizes.sXX followed by .w, .h, .r, .sp
    content = content.replaceAllMapped(RegExp(r'(\d+|\d+\.\d+|AppSizes\.s\d+)\.(w|h|r|sp)'), (match) {
      return match.group(1)!; // Return just the number or AppSize without the extension
    });

    // Handle any left over kIsWeb ? 1100.w : double.infinity inside home_appbar.widget.dart
    content = content.replaceAll('1100.w', '1100');

    f.writeAsStringSync(content);
    print('Cleaned $file');
  }
}
