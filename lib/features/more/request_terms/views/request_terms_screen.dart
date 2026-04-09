import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/request_terms_controller.dart';

class RequestTermsScreen extends StatefulWidget {
  const RequestTermsScreen({super.key});

  @override
  State<RequestTermsScreen> createState() => _RequestTermsScreenState();
}

class _RequestTermsScreenState extends State<RequestTermsScreen> {
  late final RequestTermsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = RequestTermsViewModel();
    viewModel.getRequestTypes(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestTermsViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
        pageContext: context,
        title: AppStrings.requestTerms.tr().toUpperCase(),
        onRefresh: () async => await viewModel.getRequestTypes(context: context),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: kIsWeb ? 1100.w : double.infinity,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.s12.r),
              child: Consumer<RequestTermsViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (viewModel.errorMessage != null) {
                    return Center(
                      child: Text(
                        'Error: ${viewModel.errorMessage}',
                        style: AppStyles.redContent(context),
                      ),
                    );
                  }

                  final requestTypes = viewModel.requestTypes;
                  if (requestTypes == null || requestTypes.isEmpty) {
                    return NoExistingPlaceholderScreen(
                      height: 0.6.sh,
                      title: AppStrings.noRequestTypes.tr(),
                    );
                  }

                  return SizedBox(
                    height: 0.9.sh,
                    child: ListView.separated(
                      itemCount: requestTypes.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 32.h,
                        thickness: 1.h,
                        color: Color(AppColors.disableButton),
                      ),
                      itemBuilder: (context, index) {
                        final requestType = requestTypes[index];
                        return _buildRequestTypeCard(requestType, context);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestTypeCard(requestType, BuildContext context) {
    final lang = LocalizationService.isArabic(context: context) ? "ar" : "en";
    final title = lang == "ar" 
        ? requestType.title.ar
        : requestType.title.en;

    return Container(
      padding: EdgeInsets.all(AppSizes.s20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.s12.r),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.disableButton).withValues(alpha: 0.3),
            blurRadius: AppSizes.s5.r,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Request Type Title
          Text(
            title,
            style: AppStyles.darkHeading(context).copyWith(
              fontSize: AppSizes.s20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSizes.s16.h),
          
          // Conditions Header
          Text(
            AppStrings.conditionsForSubmission.tr().replaceAll('{requestType}', title),
            style: AppStyles.darkHeading(context).copyWith(
              fontSize: AppSizes.s16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSizes.s12.h),
          
          // Acceptance Time
          if (requestType.acceptanceTime != null) ...[
            _buildConditionItem(
              _getAcceptanceTimeText(requestType.acceptanceTime, lang),
            ),
            SizedBox(height: AppSizes.s8.h),
          ],
          
          // Attaching File
          if (requestType.fields.attachingFile != null) ...[
            _buildConditionItem(
              requestType.fields.attachingFile.toLowerCase() == 'required'
                  ? AppStrings.mustAttachFile.tr()
                  : AppStrings.preferAttachFile.tr(),
            ),
            SizedBox(height: AppSizes.s8.h),
          ],
          
          // Money Value
          if (requestType.fields.moneyValue != null) ...[
            _buildConditionItem(
              requestType.fields.moneyValue.toLowerCase() == 'required'
                  ? AppStrings.mustAttachMoneyValue.tr()
                  : AppStrings.preferAttachMoneyValue.tr(),
            ),
            SizedBox(height: AppSizes.s16.h),
          ],
          
          // Approval Section
          _buildSectionTitle(AppStrings.approvalSpecialist.tr()),
          SizedBox(height: AppSizes.s8.h),
          _buildConditionItem(
            AppStrings.approvalSpecialistDescription.tr(),
          ),
          SizedBox(height: AppSizes.s8.h),
          _buildConditionItem(
            AppStrings.multiLevelApprovalRequired.tr(),
          ),
          SizedBox(height: AppSizes.s16.h),
          
          // Additional Information
          _buildSectionTitle(AppStrings.additionalInformation.tr()),
          SizedBox(height: AppSizes.s8.h),
          
          // Balance Calculation Method
          _buildConditionItem(
            '${AppStrings.balanceCalculationMethod.tr()}: ${_getCountingTypeText(requestType.countingType, lang)}',
          ),
          SizedBox(height: AppSizes.s8.h),
          
          // Request Unit
          _buildConditionItem(
            '${AppStrings.requestUnit.tr()}: ${_getTypeText(requestType.type, lang)}',
          ),
          
          // Rules Message
          if (requestType.rulesMessage != null &&
              requestType.rulesMessage!.isNotEmpty) ...[
            SizedBox(height: AppSizes.s16.h),
            _buildSectionTitle(AppStrings.rulesMessage.tr()),
            SizedBox(height: AppSizes.s8.h),
            Text(
              requestType.rulesMessage!,
              style: AppStyles.darkContent(context).copyWith(
                fontSize: AppSizes.s14.sp,
                height: 1.5,
              ),
            ),
          ],
          
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.darkHeading(context).copyWith(
        fontSize: AppSizes.s16.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: AppStyles.darkContent(context).copyWith(
            fontSize: AppSizes.s16.sp,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppStyles.darkContent(context).copyWith(
              fontSize: AppSizes.s14.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  String _getAcceptanceTimeText(int? acceptanceTime, String lang) {
    if (acceptanceTime == null) return '';
    
    final hours = acceptanceTime.abs();
    final isBefore = acceptanceTime < 0;
    
    if (lang == 'ar') {
      return isBefore
          ? AppStrings.mustSubmitBeforeHours.tr().replaceAll('{hours}', hours.toString())
          : AppStrings.mustSubmitAfterHours.tr().replaceAll('{hours}', hours.toString());
    } else {
      return isBefore
          ? AppStrings.mustSubmitBeforeHours.tr().replaceAll('{hours}', hours.toString())
          : AppStrings.mustSubmitAfterHours.tr().replaceAll('{hours}', hours.toString());
    }
  }

  String _getCountingTypeText(String? countingType, String lang) {
    if (countingType == null) return '';
    
    switch (countingType.toLowerCase()) {
      case 'daily':
        return AppStrings.daily.tr();
      case 'monthly':
        return AppStrings.monthly.tr();
      case 'annual':
        return AppStrings.annual.tr();
      case 'none':
        return AppStrings.noMaximumDuration.tr();
      default:
        return countingType;
    }
  }

  String _getTypeText(String? type, String lang) {
    if (type == null) return '';
    
    switch (type.toLowerCase()) {
      case 'days':
        return AppStrings.days.tr();
      case 'hours':
        return AppStrings.hours.tr();
      case 'minutes':
        return AppStrings.minutes.tr();
      default:
        return type;
    }
  }
}
