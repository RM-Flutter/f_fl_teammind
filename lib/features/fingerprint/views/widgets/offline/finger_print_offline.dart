import 'dart:convert';

import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/fingerprint/views/widgets/offline/widget/finger_print_offline_card.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_sizes.dart' show AppSizes;
import '../../../controller/fingerprint_controller.dart';
import '../../../../../core/widgets/finger_print/loading/fingerprint_loading_screen.dart';

class FingerprintOfflineScreen extends StatefulWidget {
  final String? empId;
  final String? empName;
  const FingerprintOfflineScreen({super.key, this.empId, this.empName});

  @override
  State<FingerprintOfflineScreen> createState() => _FingerprintOfflineScreenState();
}

class _FingerprintOfflineScreenState extends State<FingerprintOfflineScreen> {
  late final FingerprintViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = FingerprintViewModel();
    viewModel.loadFingerprintsFromPreferences();
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
            child: MainAppFabWidget(requests: false, viewRequest: false,),
          ),
          pageContext: context,
          bottomAppbarWidget: widget.empId != null &&
              widget.empId?.isNotEmpty == true &&
              widget.empName != null &&
              widget.empName?.isNotEmpty == true &&
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
                    widget.empName!,
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
          body: Padding(
            padding: const EdgeInsets.all(AppSizes.s12),
            child: SingleChildScrollView(
              child: Consumer<FingerprintViewModel>(
                  builder: (context, viewModel, child) {
                    if(viewModel.isLoading == false){
                      debugPrint("THE LISTS --> ${AppConstants.fingerPrints}");
                    }
                    return viewModel.isLoading
                        ? const FingerprintLoadingScreenWidget()
                        : AppConstants.fingerPrints?.isEmpty == true ||
                        AppConstants.fingerPrints == null
                        ? Center(
                          child: NoExistingPlaceholderScreen(
                          height: LayoutService.getHeight(context) * 0.6,
                          title: AppStrings.noFingerprintsYet.tr()),
                        )
                        : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Center(
                          //   child: Text(gCache['name'], style:
                          //   TextStyle(
                          //       fontWeight: FontWeight.w400,fontSize: 22,
                          //       color: Color(AppColors.dark)
                          //   )
                          //     ,),
                          // ),
                          //
                          // const SizedBox(height: 20,),
                          if(viewModel.isLoading == true) Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: const CircularProgressIndicator(),
                          ),
                         if(viewModel.isLoading == false) Center(
                              child: CustomElevatedButton(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  titleSize: AppSizes.s12,
                                  title: AppStrings.resend.tr().toUpperCase(),
                                  onPressed: () async{
                                    viewModel.addFingerPrints(context, AppConstants.fingerPrints);
                                  }
                              )),
                          const SizedBox(height: 20,),
                          /// general screen message widget for other requests types
                          // GeneralScreenMessageWidget(
                          //     screenId: '/fingerprints'),
                          FingerprintCardOffline(
                            fingerprint: AppConstants.fingerPrints,
                          ),
                          // ...AppConstants.fingerPrints!.map(
                          //       (fingerprint) => Column(
                          //     children: [
                          //       FingerprintCardOffline(
                          //         fingerprint: fingerprint,
                          //       ),
                          //       gapH12
                          //     ],
                          //   ),
                          // )
                        ]);
                  }),
            ),
          )),
    );
  }
}
