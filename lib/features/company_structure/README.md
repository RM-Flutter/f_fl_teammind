# company_structure

The company org chart as a tree.

- `data/repos/company_structure_repo.dart`: GET `emp_reports/v1/company_structure` (`EndpointsNames.companyStructure`).
- `controller/company_structure_tree.viewmodel.dart`: `CompanyStructureTreeViewModel`. `getCompanyTreeStructure` loads the data and `buildGraph` turns `CompanyTreeNodeModel` nodes into a `graphview` graph. `onNodeTap` handles a node tap.
- `views/company_structure_tree_screen.dart`: zoomable, pannable tree. `widgets/company_tree_node.widget.dart` draws one node (department or manager).

There is also an older WebView version in `more/company_structure`.
