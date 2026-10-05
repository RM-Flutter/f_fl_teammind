import 'package:flutter/material.dart';
import 'package:app_test/core/widgets/approvable_card_widget.dart';

import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/routing/app_router.dart';
import '../controllers/cv_hub_interviews_controller.dart';
import '../models/cv_hub_models.dart';

class CvHubInterviewsScreen extends StatefulWidget {
  const CvHubInterviewsScreen({super.key});

  @override
  State<CvHubInterviewsScreen> createState() => _CvHubInterviewsScreenState();
}

class _CvHubInterviewsScreenState extends State<CvHubInterviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { context.read<CvHubInterviewsController>().fetchInterviews(context); }
    });
  }

@override
  Widget build(BuildContext context) {
    return TemplatePage(
      pageContext: context,
      title: 'My Interviews'.tr(),
      routeName: AppRoutes.cvHubInterviews.name,
      backgroundColor: Color(AppColors.scaffoldBackGround),
      body: Consumer<CvHubInterviewsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
if (controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Color(AppColors.failureRed)),
                  const SizedBox(height: 16),
                  Text(
                    controller.error!,
                    style: TextStyle(fontSize: 16, color: Color(AppColors.titleText)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.fetchInterviews(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(AppColors.c1)),
                    child: Text('Retry'.tr(), style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          if (controller.interviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Color(AppColors.iconSecondary)),
                  const SizedBox(height: 16),
                  Text(
                    "No interviews assigned.".tr(),
                    style: TextStyle(fontSize: 16, color: Color(AppColors.subTitleText)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchInterviews(context),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              itemCount: controller.interviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final interview = controller.interviews[index];
                return _buildInterviewCard(context, interview);
              },
            ),
          );
        },
      ),
    );
  }


  Widget _buildInterviewCard(BuildContext context, InterviewModel interview) {
    return ApprovableCardWidget(
      request: interview,
      isForDepartment: true,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      onTap: () {
        context.pushNamed(
          AppRoutes.cvHubInterviewDetails.name,
          pathParameters: {
            'lang': context.locale.languageCode,
            'id': interview.id.toString(),
          },
        );
      },
    );
  }
}
