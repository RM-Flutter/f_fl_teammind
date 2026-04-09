import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/company_structure/controller/company_structure_tree.viewmodel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/utils/app_styles.dart';
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
      appBar: AppBarWithBookmark(
       surfaceTintColor: Colors.transparent,
       title: AppStrings.companyStructure.tr().toUpperCase(),
       titleStyle: AppStyles.darkContent(context).copyWith(fontSize: 16.sp,
          
         fontWeight: FontWeight.w700),
       leading: Padding(
        padding: EdgeInsets.all(AppSizes.s10.w),
        child: InkWell(
         onTap: () => Navigator.pop(context),
         child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(AppColors.titleText)),
          child: Icon(
           Icons.arrow_back_sharp,
           color: Colors.white,
           size: AppSizes.s18.r)),
        ),
       ),
       backgroundColor: Colors.transparent,
       routeName: AppRoutes.companyTree.name,
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
        boundaryMargin: EdgeInsets.all(AppSizes.s18.w),
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
            ?.firstWhere((element) => element!.id == nodeId);
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
