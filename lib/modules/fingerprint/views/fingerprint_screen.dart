import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../common_modules_widgets/main_app_fab_widget/main_app_fab.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/layout.service.dart';
import '../../../utils/general_screen_message_widget.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../view_models/fingerprint.viewmodel.dart';
import 'widgets/fingerprint_card.widget.dart';
import 'widgets/fingerprint_loading_screen.dart';

class FingerprintScreen extends StatefulWidget {
  final String? empId;
  const FingerprintScreen({super.key, this.empId,});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  late final FingerprintViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = FingerprintViewModel();
    viewModel.initializeFingerprintScreen(
        context: context, empId: widget.empId);
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
    return ChangeNotifierProvider<FingerprintViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(horizontal: LocalizationService.isArabic(context: context) ? 35: 0),
            child: MainAppFabWidget(requests: false,viewRequest: false,),
          ),
          pageContext: context,
          bottomAppbarWidget: widget.empId != null &&
                  widget.empId?.isNotEmpty == true &&
                  viewModel.userSettings?.userId.toString() != widget.empId
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(AppSizes.s40),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.s12, vertical: AppSizes.s6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          "",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: AppSizes.s20),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          title: AppStrings.fingerprintsTitle.tr(),
          onRefresh: () async => await viewModel.initializeFingerprintScreen(
              context: context, empId: widget.empId),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100 : double.infinity
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.s12),
                child: SingleChildScrollView(
                  child: Consumer<FingerprintViewModel>(
                      builder: (context, viewModel, child) => viewModel.isLoading
                          ? const FingerprintLoadingScreenWidget()
                          : (viewModel.fingerprints?.isEmpty == true ||
                          viewModel.fingerprints == null) && (AppConstants.fingerPrints == null && AppConstants.fingerPrints!.isEmpty)
                              ? NoExistingPlaceholderScreen(
                                  height: LayoutService.getHeight(context) * 0.6,
                                  title: AppStrings.noFingerprintsYet.tr())
                              : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //    if(widget.empName != null && widget.empName!.isNotEmpty && widget.empName != "noName") Center(
                            //       child: Text(widget.empName!, style:
                            //         const TextStyle(
                            //           fontWeight: FontWeight.w400,fontSize: 22,
                            //           color: Color(AppColors.dark)
                            //         )
                            //         ,),
                            //     ),
                            // if(widget.empName != null && widget.empName!.isNotEmpty && widget.empName != "noName")  const SizedBox(height: 20,),
                            //       /// general screen message widget for other requests types
                            //       // GeneralScreenMessageWidget(
                            //       //     screenId: '/fingerprints'),
                          if(AppConstants.fingerPrints != null && AppConstants.fingerPrints!.isNotEmpty)  Center(
                                child: CustomElevatedButton(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    titleSize: AppSizes.s12,
                                    title: AppStrings.showOfflineFingerprints.tr().toUpperCase(),
                                    onPressed: () async{
                                      await context.pushNamed(
                                          AppRoutes.fingerPrintOffline.name,
                                          pathParameters: {
                                            'lang': context.locale.languageCode
                                          });
                                      await viewModel.initializeFingerprintScreen(
                                          context: context, empId: widget.empId);
                                    }
                                )),
                            if(AppConstants.fingerPrints != null && AppConstants.fingerPrints!.isNotEmpty)   const SizedBox(height: 15,),
                                if(viewModel.fingerprints != null)  ...viewModel.fingerprints!.map(
                                    (fingerprint) => Column(
                                      children: [
                                        FingerprintCard(
                                          fingerprint: fingerprint,
                                        ),
                                        gapH12
                                      ],
                                    ),
                                  ),
                                ])),
                ),
              ),
            ),
          )),
    );
  }
}
