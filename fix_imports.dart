import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final Map<String, String> replacements = {
    'package:app_test/features/services/view_models/create_cv_view_model.dart': 'package:app_test/features/services/views/all_free_services/free_service_home_childs/cv_generator/controllers/create_cv_view_model.dart',
    'package:app_test/features/services/view_models/smart_card_view_model.dart': 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/controllers/smart_card_view_model.dart',
    'package:app_test/features/services/view_models/my_cv_view_model.dart': 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart',
    'package:app_test/features/services/view_models/free_services_view_model.dart': 'package:app_test/features/services/controllers/free_services_view_model.dart',
    'package:app_test/features/services/view_models/select_template_view_model.dart': 'package:app_test/features/services/controllers/select_template_view_model.dart',
    
    'package:app_test/features/services/services/cv_templates_service.dart': 'package:app_test/features/services/data/repos/cv_templates_service.dart',
    'package:app_test/features/services/services/cv_reference_data_service.dart': 'package:app_test/features/services/data/repos/cv_reference_data_service.dart',
    'package:app_test/features/services/services/smart_card_service.dart': 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/repos/smart_card_service.dart',
    
    'package:app_test/features/services/models/cv_data_model.dart': 'package:app_test/features/services/data/models/cv_data_model.dart',
    'package:app_test/features/services/models/cv_template_model.dart': 'package:app_test/features/services/data/models/cv_template_model.dart',
    'package:app_test/features/services/models/premium_file_model.dart': 'package:app_test/features/services/data/models/premium_file_model.dart',
    'package:app_test/features/services/models/smart_card_profile_models.dart': 'package:app_test/features/services/views/all_free_services/free_service_home_childs/smart_card/data/models/smart_card_profile_models.dart',

    'package:app_test/features/services/all_free_services/': 'package:app_test/features/services/views/all_free_services/',
    'package:app_test/features/services/common_ui/': 'package:app_test/features/services/views/common_ui/',
  };

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    replacements.forEach((oldStr, newStr) {
      if (content.contains(oldStr)) {
        content = content.replaceAll(oldStr, newStr);
        modified = true;
      }
    });

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated imports in ${file.path}');
    }
  }
}
