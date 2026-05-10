#!/bin/bash
set -e

BASE="lib/features/services"

# Create main directories
mkdir -p "$BASE/controllers"
mkdir -p "$BASE/data/models"
mkdir -p "$BASE/data/repos"
mkdir -p "$BASE/views"

# Move free_services_view_model to controllers
if [ -f "$BASE/view_models/free_services_view_model.dart" ]; then
  git mv "$BASE/view_models/free_services_view_model.dart" "$BASE/controllers/" || mv "$BASE/view_models/free_services_view_model.dart" "$BASE/controllers/"
fi

# Move all_free_services inside views
if [ -d "$BASE/all_free_services" ]; then
  git mv "$BASE/all_free_services" "$BASE/views/" || mv "$BASE/all_free_services" "$BASE/views/"
fi

# Now all_free_services is in $BASE/views/all_free_services
CHILDS="$BASE/views/all_free_services/free_service_home_childs"

# --- cv_generator ---
mkdir -p "$CHILDS/cv_generator/controllers"
if [ -f "$BASE/view_models/create_cv_view_model.dart" ]; then
  git mv "$BASE/view_models/create_cv_view_model.dart" "$CHILDS/cv_generator/controllers/" || mv "$BASE/view_models/create_cv_view_model.dart" "$CHILDS/cv_generator/controllers/"
fi
# Reorganize cv_generator views? Wait, they are already in views/
# Let's group cv_generator views into $CHILDS/cv_generator/views/
if [ -d "$CHILDS/cv_generator" ] && [ ! -d "$CHILDS/cv_generator/views" ]; then
  mkdir -p "$CHILDS/cv_generator/views"
  # Move everything except controllers/ and views/ to views/
  find "$CHILDS/cv_generator" -mindepth 1 -maxdepth 1 ! -name controllers ! -name views -exec git mv {} "$CHILDS/cv_generator/views/" \; 2>/dev/null || \
  find "$CHILDS/cv_generator" -mindepth 1 -maxdepth 1 ! -name controllers ! -name views -exec mv {} "$CHILDS/cv_generator/views/" \;
fi

# --- smart_card ---
mkdir -p "$CHILDS/smart_card/controllers"
mkdir -p "$CHILDS/smart_card/data/models"
mkdir -p "$CHILDS/smart_card/data/repos"
if [ -f "$BASE/view_models/smart_card_view_model.dart" ]; then
  git mv "$BASE/view_models/smart_card_view_model.dart" "$CHILDS/smart_card/controllers/" || mv "$BASE/view_models/smart_card_view_model.dart" "$CHILDS/smart_card/controllers/"
fi
if [ -f "$BASE/services/smart_card_service.dart" ]; then
  git mv "$BASE/services/smart_card_service.dart" "$CHILDS/smart_card/data/repos/" || mv "$BASE/services/smart_card_service.dart" "$CHILDS/smart_card/data/repos/"
fi
if [ -f "$BASE/models/smart_card_profile_models.dart" ]; then
  git mv "$BASE/models/smart_card_profile_models.dart" "$CHILDS/smart_card/data/models/" || mv "$BASE/models/smart_card_profile_models.dart" "$CHILDS/smart_card/data/models/"
fi
if [ -d "$CHILDS/smart_card" ] && [ ! -d "$CHILDS/smart_card/views" ]; then
  mkdir -p "$CHILDS/smart_card/views"
  find "$CHILDS/smart_card" -mindepth 1 -maxdepth 1 ! -name controllers ! -name data ! -name views -exec git mv {} "$CHILDS/smart_card/views/" \; 2>/dev/null || \
  find "$CHILDS/smart_card" -mindepth 1 -maxdepth 1 ! -name controllers ! -name data ! -name views -exec mv {} "$CHILDS/smart_card/views/" \;
fi

# --- my_cv ---
mkdir -p "$CHILDS/my_cv/controllers"
if [ -f "$BASE/view_models/my_cv_view_model.dart" ]; then
  git mv "$BASE/view_models/my_cv_view_model.dart" "$CHILDS/my_cv/controllers/" || mv "$BASE/view_models/my_cv_view_model.dart" "$CHILDS/my_cv/controllers/"
fi
if [ -d "$CHILDS/my_cv" ] && [ ! -d "$CHILDS/my_cv/views" ]; then
  mkdir -p "$CHILDS/my_cv/views"
  find "$CHILDS/my_cv" -mindepth 1 -maxdepth 1 ! -name controllers ! -name data ! -name views -exec git mv {} "$CHILDS/my_cv/views/" \; 2>/dev/null || \
  find "$CHILDS/my_cv" -mindepth 1 -maxdepth 1 ! -name controllers ! -name data ! -name views -exec mv {} "$CHILDS/my_cv/views/" \;
fi

# --- premium_templates ---
mkdir -p "$CHILDS/premium_templates/controllers"
# it already has controller/viewmodel.dart, rename it to controllers/premium_templates_view_model.dart
if [ -f "$CHILDS/premium_templates/controller/viewmodel.dart" ]; then
  git mv "$CHILDS/premium_templates/controller/viewmodel.dart" "$CHILDS/premium_templates/controllers/premium_templates_view_model.dart" || mv "$CHILDS/premium_templates/controller/viewmodel.dart" "$CHILDS/premium_templates/controllers/premium_templates_view_model.dart"
  rm -rf "$CHILDS/premium_templates/controller"
fi
if [ -d "$CHILDS/premium_templates" ] && [ ! -d "$CHILDS/premium_templates/views" ]; then
  mkdir -p "$CHILDS/premium_templates/views"
  find "$CHILDS/premium_templates" -mindepth 1 -maxdepth 1 ! -name controllers ! -name data ! -name views -exec git mv {} "$CHILDS/premium_templates/views/" \; 2>/dev/null || \
  find "$CHILDS/premium_templates" -mindepth 1 -maxdepth 1 ! -name controllers ! -name data ! -name views -exec mv {} "$CHILDS/premium_templates/views/" \;
fi

# What about select_template_view_model.dart?
# It's related to common_ui/select_template_screen.dart ? Let's put it in main controllers/ for now.
if [ -f "$BASE/view_models/select_template_view_model.dart" ]; then
  git mv "$BASE/view_models/select_template_view_model.dart" "$BASE/controllers/" || mv "$BASE/view_models/select_template_view_model.dart" "$BASE/controllers/"
fi

# Move common_ui to views/
if [ -d "$BASE/common_ui" ]; then
  git mv "$BASE/common_ui" "$BASE/views/" || mv "$BASE/common_ui" "$BASE/views/"
fi

# Move remaining models to data/models
if [ -d "$BASE/models" ]; then
  for file in "$BASE/models"/*; do
    if [ -f "$file" ]; then
      git mv "$file" "$BASE/data/models/" || mv "$file" "$BASE/data/models/"
    fi
  done
  rm -rf "$BASE/models"
fi

# Move remaining services to data/repos
if [ -d "$BASE/services" ]; then
  for file in "$BASE/services"/*; do
    if [ -f "$file" ]; then
      git mv "$file" "$BASE/data/repos/" || mv "$file" "$BASE/data/repos/"
    fi
  done
  rm -rf "$BASE/services"
fi

# Remove empty view_models directory
if [ -d "$BASE/view_models" ]; then
  rm -rf "$BASE/view_models"
fi

