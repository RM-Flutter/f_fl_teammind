import 'dart:convert';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/finger_print/card/fingerprint_card_widget.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_sizes.dart' show AppSizes, gapH12;
import '../../../../fingerprint/data/models/fingerprint_model.dart';
import '../../../../fingerprint/controller/fingerprint_controller.dart';
import '../../../../../core/widgets/finger_print/loading/fingerprint_loading_screen.dart';

class FingerPrintViewScreen extends StatefulWidget {
  final String? empId;
  final String? empName;

  const FingerPrintViewScreen({super.key, this.empId, this.empName});

  @override
  State<FingerPrintViewScreen> createState() => _FingerPrintViewScreenState();
}

class _FingerPrintViewScreenState extends State<FingerPrintViewScreen> {
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
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<FingerprintViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          floatingActionButton: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    LocalizationService.isArabic(context: context) ? 35.w : 0),
            child: MainAppFabWidget(
              requests: false,
              viewRequest: false,
            ),
          ),
          pageContext: context,
          title: AppStrings.fingerprintsTitle.tr(),
          onRefresh: () async => await viewModel.initializeFingerprintScreen(
              context: context, empId: widget.empId),
          body: Padding(
            padding: EdgeInsets.all(AppSizes.s12.r),
            child: SingleChildScrollView(
              child: Consumer<FingerprintViewModel>(
                  builder: (context, viewModel, child) => viewModel.isLoading
                      ? const FingerprintLoadingScreenWidget()
                      : viewModel.fingerprints?.isEmpty == true ||
                              viewModel.fingerprints == null
                          ? NoExistingPlaceholderScreen(
                              height: 0.6.sh,
                              title: AppStrings.noFingerprintsYet.tr())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                  if (widget.empName != null &&
                                      widget.empName!.isNotEmpty &&
                                      widget.empName != "noName")
                                    Container(
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      child: Center(
                                        child: Text(
                                          widget.empName!,
                                          style: AppStyles.darkHeading(context).copyWith(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 22.sp),
                                        ),
                                      ),
                                    ),
                                  if (widget.empName != null &&
                                      widget.empName!.isNotEmpty &&
                                      widget.empName != "noName")
                                    SizedBox(
                                      height: 20.h,
                                    ),

                                  /// general screen message widget for other requests types
                                  // GeneralScreenMessageWidget(
                                  //     screenId: '/fingerprints'),
                                  // if(AppConstants.fingerPrints != null && AppConstants.fingerPrints!.isNotEmpty)  Center(
                                  //     child: CustomElevatedButton(
                                  //         backgroundColor: Theme.of(context).colorScheme.primary,
                                  //         titleSize: AppSizes.s12,
                                  //         title: AppStrings.showOfflineFingerprints.tr().toUpperCase(),
                                  //         onPressed: () async{
                                  //           await context.pushNamed(
                                  //               AppRoutes.fingerPrintOffline.name,
                                  //               pathParameters: {
                                  //                 'lang': context.locale.languageCode
                                  //               });
                                  //         }
                                  //     )),
                                  // if(AppConstants.fingerPrints != null && AppConstants.fingerPrints!.isNotEmpty)   const SizedBox(height: 15,),
                                  ...viewModel.fingerprints!.map(
                                    (FingerPrintModel fingerprint) => Column(
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
          )),
    );
  }
}
