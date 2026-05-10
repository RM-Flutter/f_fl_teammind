import os
import re

lib_dir = 'lib'
package_name = 'app_test'

# 1. Build a map of filename -> full_path
file_map = {}
for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            # if multiple files have same name, we keep a list
            if f not in file_map:
                file_map[f] = []
            file_map[f].append(filepath)

# 2. Function to resolve relative path
def resolve_relative(base_path, rel_path):
    # base_path is the file containing the import
    dir_path = os.path.dirname(base_path)
    return os.path.normpath(os.path.join(dir_path, rel_path))

# 3. Process all files
import_regex = re.compile(r'''import\s+['"]([^'"]+)['"]\s*;''')
export_regex = re.compile(r'''export\s+['"]([^'"]+)['"]\s*;''')

changes_made = 0

for root, dirs, files in os.walk(lib_dir):
    for f in files:
        if not f.endswith('.dart'):
            continue
        filepath = os.path.join(root, f)
        
        with open(filepath, 'r') as file:
            content = file.read()
            
        new_content = content
        modified = False
        
        def replace_match(match, is_export=False):
            global changes_made
            imported_str = match.group(1)
            
            # We only care about package:app_test/ and relative paths
            if imported_str.startswith('package:' + package_name + '/'):
                # check if exists
                rel_from_lib = imported_str[len('package:' + package_name + '/'):]
                target_path = os.path.join(lib_dir, rel_from_lib)
                
                if not os.path.exists(target_path):
                    basename = os.path.basename(target_path)
                    if basename in file_map and len(file_map[basename]) == 1:
                        new_rel_from_lib = os.path.relpath(file_map[basename][0], lib_dir)
                        new_import = 'package:' + package_name + '/' + new_rel_from_lib
                        replacement = f"export '{new_import}';" if is_export else f"import '{new_import}';"
                        print(f"Fixed {imported_str} -> {new_import} in {filepath}")
                        changes_made += 1
                        return replacement
                    else:
                        print(f"Warning: Could not uniquely resolve {imported_str} in {filepath}")
            
            elif not imported_str.startswith('package:') and not imported_str.startswith('dart:'):
                # Relative import
                target_path = resolve_relative(filepath, imported_str)
                if not os.path.exists(target_path):
                    basename = os.path.basename(target_path)
                    if basename in file_map and len(file_map[basename]) == 1:
                        # change it to package import
                        new_rel_from_lib = os.path.relpath(file_map[basename][0], lib_dir)
                        new_import = 'package:' + package_name + '/' + new_rel_from_lib
                        replacement = f"export '{new_import}';" if is_export else f"import '{new_import}';"
                        print(f"Fixed relative {imported_str} -> {new_import} in {filepath}")
                        changes_made += 1
                        return replacement
                    else:
                        print(f"Warning: Could not uniquely resolve relative {imported_str} in {filepath}")
            
            return match.group(0)

        new_content = import_regex.sub(lambda m: replace_match(m, False), new_content)
        new_content = export_regex.sub(lambda m: replace_match(m, True), new_content)
        
        if new_content != content:
            with open(filepath, 'w') as file:
                file.write(new_content)

print(f"Total changes made: {changes_made}")
