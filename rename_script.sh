#!/bin/bash

# Find files matching the patterns
find lib/features/services -type f | while read -r file; do
  new_name="$file"
  
  if [[ "$file" == *".viewmodel.dart" ]]; then
    new_name="${file/.viewmodel.dart/_view_model.dart}"
  elif [[ "$file" == *".model.dart" ]]; then
    new_name="${file/.model.dart/_model.dart}"
  elif [[ "$file" == *".service.dart" ]]; then
    new_name="${file/.service.dart/_service.dart}"
  fi
  
  if [ "$file" != "$new_name" ]; then
    echo "Renaming $file to $new_name"
    git mv "$file" "$new_name" || mv "$file" "$new_name"
    
    # Extract basenames
    old_base=$(basename "$file")
    new_base=$(basename "$new_name")
    
    # Replace references in lib/
    # Using LC_ALL=C to handle potential binary files issues
    find lib -type f -name "*.dart" -exec sed -i '' "s/$old_base/$new_base/g" {} +
  fi
done
