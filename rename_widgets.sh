#!/bin/bash

find lib/features/services -type f -name "*.widget.dart" | while read -r file; do
  new_name="${file/.widget.dart/_widget.dart}"
  
  if [ "$file" != "$new_name" ]; then
    echo "Renaming $file to $new_name"
    git mv "$file" "$new_name" || mv "$file" "$new_name"
    
    # Extract basenames
    old_base=$(basename "$file")
    new_base=$(basename "$new_name")
    
    # Replace references in lib/
    find lib -type f -name "*.dart" -exec sed -i '' "s/$old_base/$new_base/g" {} +
  fi
done
