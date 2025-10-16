import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
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
import 'package:rmemp/modules/fingerprint/views/widgets/finger_print_offline_card.dart';
import 'package:rmemp/routing/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
                      print("THE LISTS --> ${AppConstants.fingerPrints}");
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
                          //   const TextStyle(
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
                          FingerprintCardOffiline(
                            fingerprint: AppConstants.fingerPrints,
                          ),
                          // ...AppConstants.fingerPrints!.map(
                          //       (fingerprint) => Column(
                          //     children: [
                          //       FingerprintCardOffiline(
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
