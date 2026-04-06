import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/widgets/finger_print/card/fingerprint_card_widget.dart';
import 'package:app_test/features/fingerprint/data/models/fingerprint_model.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_sizes.dart' show AppSizes;
import '../controller/fingerprint_controller.dart';
import '../../../core/widgets/finger_print/loading/fingerprint_loading_screen.dart';

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
            padding: EdgeInsets.symmetric(horizontal: LocalizationService.isArabic(context: context) ? 35.w : 0),
            child: MainAppFabWidget(requests: false,viewRequest: false,),
          ),
          pageContext: context,
          bottomAppbarWidget: widget.empId != null &&
                  widget.empId?.isNotEmpty == true &&
                  viewModel.userSettings?.userId.toString() != widget.empId
              ? PreferredSize(
                  preferredSize: Size.fromHeight(AppSizes.s40.h),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.s12.w, vertical: AppSizes.s6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          "",
                          style: AppStyles.primaryHeading(context).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: AppSizes.s20.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ],
                    ),
                  ),
                )
              : null,
          title: locale.tr(AppStrings.fingerprintsTitle),
          onRefresh: () async => await viewModel.initializeFingerprintScreen(
              context: context, empId: widget.empId),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100.w : double.infinity
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.s12.w),
                child: SingleChildScrollView(
                  child: Consumer<FingerprintViewModel>(
                      builder: (context, viewModel, child) => viewModel.isLoading
                          ? const FingerprintLoadingScreenWidget()
                          : (viewModel.fingerprints?.isEmpty ?? true) && (AppConstants.fingerPrints?.isEmpty ?? true)
                              ? NoExistingPlaceholderScreen(
                                  height: LayoutService.getHeight(context) * 0.6,
                                  title: locale.tr(AppStrings.noFingerprintsYet))
                              : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          if(AppConstants.fingerPrints != null && AppConstants.fingerPrints!.isNotEmpty)  Center(
                                child: CustomElevatedButton(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    titleSize: AppSizes.s12.sp,
                                    title: locale.tr(AppStrings.showOfflineFingerprints).toUpperCase(),
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
                            if(AppConstants.fingerPrints != null && AppConstants.fingerPrints!.isNotEmpty) SizedBox(height: 15.h),
                                if(viewModel.fingerprints != null)  ...viewModel.fingerprints!.map(
                                    (FingerPrintModel fingerprint) => Column(
                                      children: [
                                        FingerprintCard(
                                          fingerprint: fingerprint,
                                        ),
                                        SizedBox(height: 12.h)
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
