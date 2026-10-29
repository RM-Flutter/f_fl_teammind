import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/complaints/data/models/get_one_request_model.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routing/app_router.dart';
import '../../../../../core/widgets/bookmark_widgets/bookmark_button.widget.dart';

class RequestDetailsAppbarWidget extends StatelessWidget {
  GetOneComplainsRequestModel? getOneRequestModel;
  List? types;
  RequestDetailsAppbarWidget({super.key, this.getOneRequestModel, this.types});
  var type;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s240,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/png/home_back.png"),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
        color: Color(AppColors.secondaryButton),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.s28),
          bottomRight: Radius.circular(AppSizes.s28),
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: AppSizes.s220,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (context.canPop()) {
                                context.pop(); // هيرجع لورا
                              } else {
                                context.goNamed(
                                  AppRoutes.home.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode,
                                  },
                                );
                              }
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(AppColors.background),
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Spacer(),
                          Text(
                            AppStrings.myRequests.tr().toUpperCase(),
                            style: AppStyles.whiteHeading(context).copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),
                          BookmarkButton(
                            routeName: AppRoutes.complainDetails.name,
                            defaultTitle: AppStrings.myRequests.tr(),
                            iconColor: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: kIsWeb ? 1100 : double.infinity,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (getOneRequestModel?.complain?.type != null &&
                                  getOneRequestModel!.complain!.type!.isNotEmpty) ...[
                                _buildTypeBadge(
                                  getOneRequestModel!.complain!.type,
                                  context,
                                ),
                                const SizedBox(height: 8),
                              ],
                              Text(
                                (getOneRequestModel?.complain?.subject ?? "").toUpperCase(),
                                style: AppStyles.whiteContent(context).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if (getOneRequestModel?.complain?.createdAt != null)
                                    SizedBox(
                                      width: kIsWeb
                                          ? MediaQuery.sizeOf(context).width * 0.1
                                          : MediaQuery.sizeOf(context).width * 0.25,
                                      child: Text(
                                        DateFormat(
                                          "dd/MM/yyyy",
                                          LocalizationService.isArabic(context: context)
                                              ? "ar"
                                              : "en",
                                        ).format(
                                          DateTime.parse(
                                            getOneRequestModel!.complain!.createdAt.toString(),
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                        style: AppStyles.whiteContent(context).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  _buildTargetInfo(context),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      SizedBox(
                                        width: kIsWeb
                                            ? MediaQuery.sizeOf(context).width * 0.1
                                            : MediaQuery.sizeOf(context).width * 0.2,
                                        child: Text(
                                          getOneRequestModel?.complain?.pstatus?.tr().toUpperCase() ?? "",
                                          textAlign: TextAlign.center,
                                          style: AppStyles.whiteContent(context).copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetInfo(BuildContext context) {
    final complain = getOneRequestModel?.complain;
    if (complain == null) return const SizedBox.shrink();

    String? targetName;
    IconData iconData = Icons.folder_open_outlined;

    if (complain.relatedTo == 'person' &&
        complain.relatedProfile?.name != null &&
        complain.relatedProfile!.name!.isNotEmpty) {
      targetName = complain.relatedProfile!.name;
      iconData = Icons.person_outline;
    } else if (complain.departmentName != null && complain.departmentName!.isNotEmpty) {
      targetName = complain.departmentName;
      iconData = Icons.business_outlined;
    }

    if (targetName == null || targetName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(iconData, color: Colors.white, size: 15),
        const SizedBox(width: 4),
        SizedBox(
          width: kIsWeb
              ? MediaQuery.sizeOf(context).width * 0.15
              : MediaQuery.sizeOf(context).width * 0.28,
          child: Text(
            targetName.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: AppStyles.whiteContent(context).copyWith(
              overflow: TextOverflow.ellipsis,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge(String? type, BuildContext context) {
    if (type == null || type.isEmpty) return const SizedBox.shrink();
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;

    switch (type.toLowerCase()) {
      case 'suggestion':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = AppStrings.suggestion.tr();
        icon = Icons.lightbulb_outline;
        break;
      case 'other':
        bgColor = const Color(0xFFEDE7F6);
        textColor = const Color(0xFF512DA8);
        label = AppStrings.other.tr();
        icon = Icons.more_horiz;
        break;
      case 'complaint':
      default:
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        label = AppStrings.complaint.tr();
        icon = Icons.report_problem_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
