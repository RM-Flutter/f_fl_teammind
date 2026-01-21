import yaml

def main():
    lock_file = 'pubspec.lock'
    yaml_file = 'pubspec.yaml'

    try:
        with open(lock_file, 'r') as f:
            lock_data = yaml.safe_load(f)
        
        with open(yaml_file, 'r') as f:
            pubspec_content = f.read()
        
        packages = lock_data.get('packages', {})
        
        lines = pubspec_content.split('\n')
        new_lines = []
        
        dependencies_section = False
        dev_dependencies_section = False
        
        for line in lines:
            trimmed_line = line.strip()
            
            if trimmed_line == 'dependencies:':
                dependencies_section = True
                dev_dependencies_section = False
                new_lines.append(line)
                continue
            elif trimmed_line == 'dev_dependencies:':
                dependencies_section = False
                dev_dependencies_section = True
                new_lines.append(line)
                continue
            elif trimmed_line.startswith('flutter:') or trimmed_line.startswith('environment:') or trimmed_line == '':
                 # simple heuristic to detect end of dependencies section if not caught by dev_dependencies
                 if trimmed_line.startswith('flutter:'):
                     dependencies_section = False
                     dev_dependencies_section = False

            if (dependencies_section or dev_dependencies_section) and ':' in line:
                parts = line.split(':')
                package_name = parts[0].strip()
                
                # Check if it is a package line (and not sdk or other keys)
                if package_name in packages:
                    current_version_part = parts[1].strip() if len(parts) > 1 else ""
                    
                    # Don't update if it's already versioned or has 'sdk: flutter' or similar complex definitions that might be on next lines
                    # However, the user wants versions put in.
                    # If the line ends with just :, it means version might be empty or on next line?
                    # The prompt implies adding versions where they are missing.
                    
                    # If the current version is empty or 'any', we replace it.
                    # We also want to respect caret syntax if possible, but exact version is safer given the request.
                    # Let's use `^version` from lock file.
                    
                    locked_version = packages[package_name].get('version')
                    if locked_version:
                        # preserve indentation
                        indent = line[:line.find(package_name)]
                        if not current_version_part:
                             new_lines.append(f"{indent}{package_name}: ^{locked_version}")
                        elif current_version_part == 'any':
                             new_lines.append(f"{indent}{package_name}: ^{locked_version}")
                        else:
                            # It has a version or path/git dependency. 
                            # If it looks like a simple version (starts with ^, >, <, or digit), we update it?
                            # The user said "put versions for packages".
                            # Let's assume we update if it doesn't look like a git/path dependency.
                            # But wait, existing pubspec has empty versions like "  dartz:"
                            if not current_version_part:
                                new_lines.append(f"{indent}{package_name}: ^{locked_version}")
                            else:
                                # keep existing if it's not empty, unless it is "any"
                                # Actually, user said "put versions", so maybe overwrite?
                                # Let's overwrite only if it doesn't have a version (empty) or is 'any'.
                                # The previous `cat` showed many packages with empty versions.
                                new_lines.append(line) 
                else:
                    new_lines.append(line)
            else:
                new_lines.append(line)
                
        with open(yaml_file, 'w') as f:
            f.write('\n'.join(new_lines))
            
        print("Updated pubspec.yaml with versions from pubspec.lock")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
