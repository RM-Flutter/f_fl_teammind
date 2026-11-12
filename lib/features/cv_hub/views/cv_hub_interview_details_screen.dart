import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/requests/shared/ui/widgets/custom_request_details_button.widget.dart';

import '../controllers/cv_hub_interview_details_controller.dart';
import 'widgets/interview_details_header_widget.dart';
import 'widgets/interview_details_tabs_widget.dart';
import 'package:app_test/core/constants/app_design.dart';

/// Interview details, laid out like the approvals details screen: the navy header with the
/// status box and info tiles, the navy tab bar (candidate / skills / my evaluation) and the
/// action button at the bottom.
class CvHubInterviewDetailsScreen extends StatefulWidget {
  final String id;
  const CvHubInterviewDetailsScreen({super.key, required this.id});

  @override
  State<CvHubInterviewDetailsScreen> createState() => _CvHubInterviewDetailsScreenState();
}

class _CvHubInterviewDetailsScreenState extends State<CvHubInterviewDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { context.read<CvHubInterviewDetailsController>().fetchInterviewDetails(context, widget.id); }
    });
  }

  void _showEvaluationSheet(BuildContext context, CvHubInterviewDetailsController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EvaluationForm(controller: controller, interviewId: widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(AppColors.background),
      body: Consumer<CvHubInterviewDetailsController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            // Same skeleton as the approvals details: navy header, tabs, cards.
            return const DetailsLoadingWidget(headerHeight: 260);
          }
          if (controller.error != null || controller.interview == null) {
            return Column(
              children: [
                AppBarWithBookmark(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  routeName: AppRoutes.cvHubInterviewDetails.name,
                  title: 'Interview Details'.tr(),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          controller.error != null ? Icons.error_outline : Icons.info_outline,
                          size: 64,
                          color: Color(controller.error != null
                              ? AppColors.failureRed
                              : AppColors.iconSecondary),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.error ?? 'No details found.'.tr(),
                          style: TextStyle(fontSize: 16, color: Color(AppColors.titleText)),
                        ),
                        if (controller.error != null) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => controller.fetchInterviewDetails(context, widget.id),
                            style: ElevatedButton.styleFrom(backgroundColor: Color(AppColors.c1)),
                            child: Text('Retry'.tr(), style: const TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final interview = controller.interview!;
          final candidate = interview.candidate;
          final skills = candidate?.skills ?? const [];
          final canEvaluate =
              interview.myEvaluation == null || interview.myEvaluation!.canEdit == true;

          final tabTitles = <String>[
            'Candidate Info'.tr(),
            if (skills.isNotEmpty) 'Skills'.tr(),
            'My Evaluation'.tr(),
          ];
          final sections = <Widget>[
            CandidateInfoTab(candidate: candidate),
            if (skills.isNotEmpty) SkillsTab(skills: skills),
            MyEvaluationTab(evaluation: interview.myEvaluation),
          ];

          return Column(
            children: [
              InterviewDetailsHeaderWidget(interview: interview),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: LayoutService.contentConstraints(context),
                    child: _buildTabs(context, tabTitles, sections),
                  ),
                ),
              ),
              if (canEvaluate)
                Center(
                  child: ConstrainedBox(
                    constraints: LayoutService.contentConstraints(context),
                    child: Padding(
                      // Same place and size as the approvals bottom action bar.
                      padding: EdgeInsets.fromLTRB(
                          34, 8, 34, 12 + MediaQuery.paddingOf(context).bottom),
                      child: SizedBox(
                        height: 44,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CustomRequestDetailsButton(
                              title: interview.myEvaluation == null
                                  ? 'Submit Evaluation'.tr()
                                  : 'Edit Evaluation'.tr(),
                              onPressed: () async => _showEvaluationSheet(context, controller),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// The navy pill tab bar of the approvals details (CustomTabbarViewApprovableDetails),
  /// with the tabs sharing the bar equally.
  Widget _buildTabs(BuildContext context, List<String> titles, List<Widget> views) {
    final labelStyle = AppStyles.heading(context).copyWith(
      fontSize: 10.5,
      fontWeight: FontWeight.bold,
    );
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.page, right: AppSpacing.page, top: AppSpacing.md),
      child: DefaultTabController(
        length: titles.length,
        child: Column(
          children: [
            Container(
              width: double.infinity, // full-width bar, even when the tabs are fewer
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryButton),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: TabBar(
                dividerColor: Colors.transparent,
                // Few tabs: they share the bar equally, from edge to edge.
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                labelPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: Color(AppColors.buttons),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: labelStyle,
                unselectedLabelStyle: labelStyle,
                tabs: [
                  for (final t in titles)
                    Tab(child: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: TabBarView(
                  children: [
                    for (final v in views)
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: v,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class _EvaluationForm extends StatefulWidget {
  final CvHubInterviewDetailsController controller;
  final String interviewId;

  const _EvaluationForm({required this.controller, required this.interviewId});

  @override
  State<_EvaluationForm> createState() => _EvaluationFormState();
}

class _EvaluationFormState extends State<_EvaluationForm> {
  final _formKey = GlobalKey<FormState>();
  final _techScoreController = TextEditingController();
  final _softScoreController = TextEditingController();
  final _notesController = TextEditingController();
  String? _recommendation;

  @override
  void initState() {
    super.initState();
    final ev = widget.controller.interview?.myEvaluation;
    if (ev != null) {
      _techScoreController.text = ev.technicalScore?.toString() ?? '';
      _softScoreController.text = ev.softSkillsScore?.toString() ?? '';
      _notesController.text = ev.notes ?? '';
      _recommendation = ev.recommendation;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Color(AppColors.scaffoldBackGround),
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evaluation Form'.tr(),
                  style: AppStyles.primaryContent(context).copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildFormField(
                  controller: _techScoreController,
                  label: 'Technical Score (0-100)'.tr(),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _softScoreController,
                  label: 'Soft Skills Score (0-100)'.tr(),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                FormField<String>(
                  initialValue: _recommendation,
                  validator: (val) => (_recommendation == null || _recommendation!.isEmpty) ? 'Required'.tr() : null,
                  builder: (state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Theme(
                          data: Theme.of(context).copyWith(
                            hoverColor: Colors.grey.shade100,
                            highlightColor: Colors.grey.shade200,
                          ),
                          child: PopupMenuButton<String>(
                            position: PopupMenuPosition.under,
                            color: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            elevation: AppElevation.raised,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            onSelected: (val) {
                              setState(() {
                                _recommendation = val;
                                state.didChange(val);
                              });
                            },
                            itemBuilder: (context) => ['Accept', 'Reject', 'Need Another Interview'].map((String value) {
                              final isSelected = _recommendation == value;
                              return PopupMenuItem<String>(
                                value: value,
                                height: 44,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        value.tr(),
                                        style: TextStyle(
                                          color: isSelected ? Color(AppColors.buttons) : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (isSelected)
                                      Icon(Icons.check, size: 18, color: Color(AppColors.buttons)),
                                  ],
                                ),
                              );
                            }).toList(),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Recommendation'.tr(),
                                labelStyle: TextStyle(color: Color(AppColors.subTitleText)),
                                errorText: state.errorText,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(color: Color(AppColors.border)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(
                                    color: state.hasError ? Color(AppColors.failureRed) : Color(AppColors.border),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  borderSide: BorderSide(color: Color(AppColors.c1)),
                                ),
                                filled: true,
                                fillColor: Color(AppColors.cardBackground),
                                suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                              ),
                              child: Text(
                                _recommendation != null ? _recommendation!.tr() : '',
                                style: TextStyle(color: Color(AppColors.titleText), fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildFormField(
                  controller: _notesController,
                  label: 'Notes'.tr(),
                  maxLines: 4,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomElevatedButton(
                    backgroundColor: Color(AppColors.buttons),
                    title: 'Submit'.tr(),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {

                        
                        final ev = widget.controller.interview?.myEvaluation;
                        bool success;
                        if (ev != null) {
                          success = await widget.controller.updateEvaluation(
                            context, 
                            technicalScore: int.tryParse(_techScoreController.text) ?? 0,
                            softSkillsScore: int.tryParse(_softScoreController.text) ?? 0,
                            recommendation: _recommendation ?? '',
                            notes: _notesController.text,
                          );
                        } else {
                          success = await widget.controller.submitEvaluation(
                            context,
                            technicalScore: int.tryParse(_techScoreController.text) ?? 0,
                            softSkillsScore: int.tryParse(_softScoreController.text) ?? 0,
                            recommendation: _recommendation ?? '',
                            notes: _notesController.text,
                          );
                        }
                        
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: Color(AppColors.titleText)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(AppColors.subTitleText)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Color(AppColors.border)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Color(AppColors.border)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Color(AppColors.c1)),
        ),
        filled: true,
        fillColor: Color(AppColors.cardBackground),
      ),
      validator: (val) => (val == null || val.isEmpty) ? 'Required'.tr() : null,
    );
  }
}
