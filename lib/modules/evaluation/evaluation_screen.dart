import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/controller/evaluation_controller/evaluation_controller.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/profiles/views/widgets/profile_tile.widget.dart';
import '../../../common_modules_widgets/main_app_fab_widget/main_app_fab.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../general_services/layout.service.dart';
import '../../../utils/general_screen_message_widget.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../../common_modules_widgets/payrolls_and_penalties_and_rewards_loading_screens.widget.dart';

class EvaluationScreen extends StatefulWidget {
  final String? empId;
  const EvaluationScreen({super.key, this.empId});

  @override
  State<EvaluationScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<EvaluationScreen> {
  late final EvaluationViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EvaluationViewModel();
    viewModel.getEvaluation(context, widget.empId);
  }

  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<EvaluationViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.evaluation.tr(),
          onRefresh: () async => await viewModel.getEvaluation(context, widget.empId),
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.s12),
            child: SingleChildScrollView(
              child: Consumer<EvaluationViewModel>(
                  builder: (context, viewModel, child) => viewModel.isLoading
                      ? const PayrollsAndPenaltiesRewardsLoadingScreensWidget()
                      : viewModel.evaluations?.isEmpty == true ||
                      viewModel.evaluations == null
                      ? NoExistingPlaceholderScreen(
                      height: LayoutService.getHeight(context) * 0.6,
                      title: AppStrings.noExistingEvaluation.tr())
                      : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                       if(gCache['employee_profile_id'].toString() != widget.empId.toString()) Text("", style:
                        const TextStyle(
                            fontWeight: FontWeight.w600,fontSize: 20,
                            color: Color(AppColors.dark)
                        )
                          ,),
                        if(gCache['employee_profile_id'].toString() != widget.empId.toString()) const SizedBox(height: 20,),
                        /// general screen message widget for other requests types
                        // GeneralScreenMessageWidget(
                        //     screenId: '/payrolls'),
                        ListView.separated(
                            reverse: false,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return ProfileTileEva(
                                isTitleOnly: false,
                                isViewArrow: true,
                                createAt: viewModel.evaluations[index]['created_at'],
                                eva: viewModel.evaluations[index]['results'],
                                title: "${viewModel.evaluations[index]['title']}",
                                icon: (viewModel.evaluations[index]['done'] != null)?
                                viewModel.evaluations[index]['done'] == true ?const Icon(Icons.check_circle_outline, color: Colors.green,):const Icon(Icons.calendar_month, color: Colors.black,): const Icon(Icons.check_circle_outline, color: Colors.green,),
                                url: (viewModel.evaluations[index]['submitUrl'] != null)? viewModel.evaluations[index]['submitUrl'].toString() : null,
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(height: 15,),
                            itemCount: viewModel.evaluations!.length)
                      ])),
            ),
          )),
    );
  }
}
