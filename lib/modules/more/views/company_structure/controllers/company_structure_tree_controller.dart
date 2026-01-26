import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:app_test/modules/more/views/company_structure/models/company_tree_node.model.dart';
import 'package:app_test/modules/more/views/company_structure/services/general.service.dart';

class CompanyStructureTreeController extends ChangeNotifier {
  List<CompanyTreeNodeModel>? companyStructureTree;
  final Graph graph = Graph();
  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  bool isLoading = false;

  void updateLoading(bool newVal) {
    isLoading = newVal;
    notifyListeners();
  }

  Future<void> initializeCompanyinformationScreen(
      {required BuildContext context}) async {
    updateLoading(true);
    await getCompanyTreeStructure(context: context);
    buildGraph();
    updateLoading(false);
  }

  void buildGraph() {
    if (companyStructureTree == null) return;
    Map<int, Node> nodes = {};

    for (var data in companyStructureTree!) {
      int id = data.id;
      nodes[id] = Node.Id(id);
    }

    for (var data in companyStructureTree!) {
      int id = data.id;
      for (var nextId in data.next) {
        graph.addEdge(nodes[id]!, nodes[nextId]!);
      }
    }
  }

  void onNodeTap(CompanyTreeNodeModel nodeData) {
    // Handle node tap
    print('Node tapped: ${nodeData.name}');
  }

  Future<void> getCompanyTreeStructure({required BuildContext context}) async {
    try {
      final result =
          await GeneralService.getCompanyTreeStructure(context: context);
      if (result.success && result.data != null) {
        companyStructureTree = (result.data?['data'] as List<dynamic>)
            .map((item) => CompanyTreeNodeModel.fromJson(item))
            .toList();
      }
    } catch (ex, t) {
      print(
          'Failed to get company structure tree ${ex.toString()} at :- $t');
    }
  }
}
