import os

def fix_file_content(filepath, replacements):
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        new_content = content
        for old, new in replacements:
            new_content = new_content.replace(old, new)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Updated: {filepath}")
    except Exception as e:
        print(f"Error processing {filepath}: {e}")

def remove_const_at_lines(file_line_map):
    for filepath, lines in file_line_map.items():
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                file_lines = f.readlines()
            
            modified = False
            for line_num in lines:
                idx = line_num - 1
                if 0 <= idx < len(file_lines):
                    if 'const ' in file_lines[idx]:
                        file_lines[idx] = file_lines[idx].replace('const ', '', 1) # Replace first occurrence
                        modified = True
            
            if modified:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.writelines(file_lines)
                print(f"Removed const from: {filepath}")
        except Exception as e:
            print(f"Error processing {filepath}: {e}")

def main():
    # 1. Fix dynamic_app_config.service.dart import
    fix_file_content(
        '/Users/zeyad/StudioProjects/f_fl_core/lib/general_services/dynamic_app_config.service.dart',
        [("../backend_services/api_service/dio_api_service/shared.dart", "backend_services/api_service/dio_api_service/shared.dart")]
    )

    # 2. Fix app_theme.service.dart (Try changing BottomAppBarTheme to BottomAppBarThemeData???)
    # Actually, let's just comment it out if it persists, but let's try replacing it first.
    # Wait, if I replace it and it's wrong, I'll get another error.
    # Let's try to just remove the line if I can't fix it.
    # But let's try replacing first.
    # fix_file_content(
    #     '/Users/zeyad/StudioProjects/f_fl_core/lib/general_services/app_theme.service.dart',
    #     [("bottomAppBarTheme: BottomAppBarTheme(", "bottomAppBarTheme: BottomAppBarThemeData(")]
    # )
    # On second thought, let's just remove the `const` from lines identified.

    # 3. Fix const errors (Updated list from latest run)
    error_log = """
lib/common_modules_widgets/comments/comments_widget.dart:88:96
lib/common_modules_widgets/comments/list_comments.dart:83:32
lib/common_modules_widgets/comments/list_comments.dart:101:21
lib/common_modules_widgets/comments/list_comments.dart:196:104
lib/common_modules_widgets/custom_alert_dialog_with_two_buttons.dart:39:28
lib/common_modules_widgets/successful_add.dart:34:59
lib/common_modules_widgets/successful_add.dart:58:52
lib/common_modules_widgets/successful_add.dart:72:52
lib/constants/general_listener.dart:114:36
lib/general_services/app_theme.service.dart:14:28
lib/general_services/app_theme.service.dart:14:66
lib/general_services/app_theme.service.dart:16:28
lib/general_services/app_theme.service.dart:16:61
lib/general_services/app_theme.service.dart:18:28
lib/general_services/app_theme.service.dart:18:61
lib/general_services/app_theme.service.dart:21:28
lib/general_services/app_theme.service.dart:21:63
lib/general_services/app_theme.service.dart:23:28
lib/general_services/app_theme.service.dart:23:63
lib/general_services/app_theme.service.dart:25:28
lib/general_services/app_theme.service.dart:25:63
lib/general_services/app_theme.service.dart:28:28
lib/general_services/app_theme.service.dart:29:27
lib/general_services/app_theme.service.dart:31:28
lib/general_services/app_theme.service.dart:32:27
lib/general_services/app_theme.service.dart:34:28
lib/general_services/app_theme.service.dart:35:27
lib/general_services/app_theme.service.dart:37:28
lib/general_services/app_theme.service.dart:38:27
lib/general_services/app_theme.service.dart:40:28
lib/general_services/app_theme.service.dart:41:27
lib/general_services/app_theme.service.dart:44:28
lib/general_services/app_theme.service.dart:45:27
lib/general_services/app_theme.service.dart:47:28
lib/general_services/app_theme.service.dart:48:27
lib/general_services/app_theme.service.dart:50:28
lib/general_services/app_theme.service.dart:51:27
lib/general_services/app_theme.service.dart:53:28
lib/general_services/app_theme.service.dart:54:27
lib/general_services/app_theme.service.dart:56:28
lib/general_services/app_theme.service.dart:57:27
lib/general_services/app_theme.service.dart:60:28
lib/general_services/app_theme.service.dart:61:27
lib/general_services/app_theme.service.dart:63:28
lib/general_services/app_theme.service.dart:64:27
lib/general_services/app_theme.service.dart:66:28
lib/general_services/app_theme.service.dart:67:27
lib/general_services/app_theme.service.dart:69:28
lib/general_services/app_theme.service.dart:70:27
lib/general_services/app_theme.service.dart:72:28
lib/general_services/general_listener.dart:114:34
lib/modules/complain_screen/widget/successful_send_request_bottomsheet.dart:25:57
lib/modules/home/widget/appbar_profile_container.dart:126:34
lib/modules/home/widget/home_grid_view_item.dart:51:38
lib/modules/home/widget/home_grid_view_item.dart:62:38
lib/modules/more/views/blog/view/blog_details_screen.dart:110:44
lib/modules/more/views/company_structure/views/company_structure_tree_screen.dart:39:32
lib/modules/more/views/company_structure/views/company_structure_tree_screen.dart:47:38
lib/modules/more/views/contactus/view/contact_screen.dart:600:52
lib/modules/more/views/faq/view/faq_screen.dart:28:30
lib/modules/more/views/lang_setting/lang_setting_screen.dart:68:32
lib/modules/more/views/more_screen.dart:93:50
lib/modules/more/views/notification/view/add_notification_screen.dart:128:60
lib/modules/more/views/notification/view/add_notification_screen.dart:473:44
lib/modules/more/views/notification/view/notification_details_screen.dart:255:85
lib/modules/more/views/notification/view/notification_screen.dart:92:32
lib/modules/more/views/notification/view/notification_screen.dart:110:21
lib/modules/more/views/notification/view/widget/successful_send_notification_bottomsheet.dart:25:57
lib/modules/more/views/update_password/update_password_screen.dart:61:40
lib/modules/more/views/user_devices/user_devices_screen.dart:131:52
lib/modules/pages/default_details.dart:110:44
lib/modules/pages/default_page.dart:96:32
lib/modules/points/fawry_view/charge_phone_screen.dart:262:67
lib/modules/points/fawry_view/charge_phone_screen.dart:512:50
lib/modules/points/fawry_view/charge_phone_screen.dart:554:32
lib/modules/points/fawry_view/charge_phone_screen.dart:562:32
lib/modules/points/fawry_view/fawry_provider_screen.dart:31:36
lib/modules/points/fawry_view/fawry_provider_screen.dart:38:36
lib/modules/points/fawry_view/fawry_provider_screen.dart:129:36
lib/modules/points/widgets/add_friend_bottom_sheet.dart:69:44
lib/modules/points/widgets/referral_section.dart:73:34
lib/modules/points/widgets/select_contact_screen.dart:117:34
lib/modules/points/widgets/select_contact_screen.dart:124:34
lib/modules/points/widgets/sliver_list_points.dart:70:40
lib/utils/componentes/general_components/all_bottom_sheet.dart:238:56
lib/utils/componentes/general_components/all_bottom_sheet.dart:500:38
lib/utils/componentes/general_components/all_text_field.dart:293:24
    """

    file_line_map = {}
    base_path = '/Users/zeyad/StudioProjects/f_fl_core/'
    for line in error_log.strip().split('\n'):
        parts = line.split(':')
        if len(parts) >= 2:
            rel_path = parts[0]
            line_num = int(parts[1])
            abs_path = os.path.join(base_path, rel_path)
            
            if abs_path not in file_line_map:
                file_line_map[abs_path] = []
            file_line_map[abs_path].append(line_num)
    
    remove_const_at_lines(file_line_map)

if __name__ == "__main__":
    main()
