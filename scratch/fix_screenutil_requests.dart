import 'dart:io';

void main() {
  var files = [
    'lib/features/home/views/widgets/page_body_widgets/my_requests/my_requests_widget.dart',
    'lib/features/home/views/widgets/page_body_widgets/my_requests/widgets/request_card.dart',
  ];

  for (var file in files) {
    var f = File(file);
    if (!f.existsSync()) continue;
    
    var content = f.readAsStringSync();
    
    // Replace extensions attached to numbers or constants
    content = content.replaceAllMapped(RegExp(r'(\d+|\d+\.\d+|AppSizes\.s\d+)\.(w|h|r|sp)'), (match) {
      return match.group(1)!;
    });

    f.writeAsStringSync(content);
    print('Cleaned $file');
  }
}
