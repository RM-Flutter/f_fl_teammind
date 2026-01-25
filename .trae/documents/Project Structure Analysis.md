I will reorganize the project structure to address points 2 and 3:

1. **Unify Widgets:**

   * Create `lib/core/widgets`.

   * Move and merge widgets from `common_modules_widgets` and `utils/componentes` to `lib/core/widgets`.

   * Specifically, adopt the `ButtonWidget` from `utils` as the standard and remove the duplicate.

2. **Clean Root Directory:**

   * Create `lib/core/services`.

   * Move `lib/general_services` and `lib/services` into `lib/core/services`.

   * Move `lib/controller` to `lib/core/controllers`.

3. **Update Imports:**

   * Perform global search and replace to fix all broken imports resulting from the file moves.

