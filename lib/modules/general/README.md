# general

Company-level info: the organization structure tree.

## Files
- `views/company_structure_tree_screen.dart`: `CompanyStructureTreeScreen` (`more/company-tree`). An org chart drawn with `graphview` (`widgets/company_tree_node.widget.dart`).
- `views/comapny_structure_info_screen.dart`: `CompanyStructureInfoScreen`, a company profile with a header (`widgets/company_info_header/`) and social links (`company_social_contacts.widget.dart`). **It is not wired to any route right now.**
- `viewmodels/company_structure_tree.viewmodel.dart`, `viewmodels/company_structure_info.viewmodel.dart`.
- `models/company_tree_node.model.dart`: `CompanyTreeNodeModel` (a recursive tree).
- `services/general.service.dart`: `GeneralService.getCompanyTreeStructure`, which calls `emp_reports/v1/company_structure` (`EndpointsNames.companyStructure`).

## How it works
The tree view model fetches the structure, converts it into `CompanyTreeNodeModel` nodes, and builds a `graphview` `Graph` with `BuchheimWalker` layout. Each node shows a department or manager.

There is also a web version of the company structure in `more/views/company_structure/company_structure_screen.dart` (a `WebViewStack` on `more/webview`).
