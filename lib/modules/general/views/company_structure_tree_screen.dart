import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_strings.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_sizes.dart';
import '../viewmodels/company_structure_tree.viewmodel.dart';
import 'widgets/company_tree_node.widget.dart';

class CompanyStructureTreeScreen extends StatefulWidget {
  const CompanyStructureTreeScreen({super.key});

  @override
  State<CompanyStructureTreeScreen> createState() =>
      _CompanyStructureTreeScreenState();
}

class _CompanyStructureTreeScreenState
    extends State<CompanyStructureTreeScreen> {
  late final CompanyStructureTreeViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = CompanyStructureTreeViewModel();
    viewModel.initializeCompanyinformationScreen(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<CompanyStructureTreeViewModel>(
        create: (_) => viewModel,
        child: Scaffold(
            appBar: AppBar(
              surfaceTintColor: Colors.transparent,
              title:  Text(AppStrings.companyStructure.tr().toUpperCase(), style: const TextStyle(fontSize: 16,
                  color: Color(AppColors.dark), fontWeight: FontWeight.w700),),
              leading: Padding(
                padding: const EdgeInsets.all(AppSizes.s10),
                child: InkWell(
                  onTap: () =>  Navigator.pop(context),
                  child: Container(
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(AppColors.dark)),
                    child: const Icon(
                      Icons.arrow_back_sharp,
                      color: Colors.white,
                      size: AppSizes.s18,
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
            backgroundColor: Colors.white,
            body: Consumer<CompanyStructureTreeViewModel>(
                builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              return InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(AppSizes.s18),
                minScale: 0.01,
                maxScale: 5.6,
                child: GraphView(
                  graph: viewModel.graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    viewModel.builder,
                    TreeEdgeRenderer(viewModel.builder),
                  ),
                  builder: (Node node) {
                    int nodeId = node.key!.value;
                    var nodeData = viewModel.companyStructureTree
                        ?.firstWhere((element) => element.id == nodeId);
                    return CompanyStructureNode(
                      data: nodeData!,
                      onTap: viewModel.onNodeTap,
                    );
                  },
                ),
              );
            })));
  }
}
