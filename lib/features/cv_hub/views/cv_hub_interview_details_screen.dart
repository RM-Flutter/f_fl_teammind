import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/cv_hub_interview_details_controller.dart';
import '../models/cv_hub_models.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

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
    final mainColor = Color(AppColors.buttons);
    return Scaffold(
      backgroundColor: Color(AppColors.background),
      body: Consumer<CvHubInterviewDetailsController>(
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
                    onPressed: () => controller.fetchInterviewDetails(context, widget.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(AppColors.c1)),
                    child: Text('Retry'.tr(), style: const TextStyle(color: Colors.white)),
                  )
                ],
              ),
            );
          }
          if (controller.interview == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 64, color: Color(AppColors.iconSecondary)),
                  const SizedBox(height: 16),
                  Text(
                    "No details found.".tr(),
                    style: TextStyle(fontSize: 16, color: Color(AppColors.subTitleText)),
                  ),
                ],
              ),
            );
          }

          final interview = controller.interview!;
          final candidate = interview.candidate;

          return Column(
            children: [
              _buildHeader(context, mainColor, interview),
              Expanded(
                child: AppContentWidth(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page, vertical: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Candidate Info'.tr(), Icons.person_outline),
                        const SizedBox(height: 12),
                        _buildInfoBox([
                          _buildInfoRow('Email', candidate?.email),
                          _buildInfoRow('Phone', candidate?.phone),
                          _buildInfoRow('Job Title', candidate?.job?.title),
                          _buildInfoRow('Expected Salary', candidate?.expectedSalary?.toString()),
                          _buildInfoRow('Years of Experience', candidate?.yearsExperience?.toString()),
                          _buildInfoRow('Education', candidate?.educationLevel),
                          _buildInfoRow('Employment Type', candidate?.employmentType),
                        ]),
                        const SizedBox(height: 24),
                        
                        if (candidate?.skills != null && candidate!.skills!.isNotEmpty) ...[
                          _buildSectionHeader('Skills'.tr(), Icons.star_border),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 8.0,
                            children: candidate.skills!.map((s) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: mainColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Text(s.name ?? '', style: TextStyle(color: mainColor, fontSize: 12, fontWeight: FontWeight.w600)),
                            )).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        if (candidate?.attachments != null && candidate!.attachments!.isNotEmpty) ...[
                          _buildSectionHeader('Attachments'.tr(), Icons.attach_file),
                          const SizedBox(height: 12),
                          ...candidate.attachments!.map((a) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
                            child: AppCard(
                              onTap: () {
                                if (a.fileUrl != null) launchUrl(Uri.parse(a.fileUrl!), mode: LaunchMode.externalApplication);
                              },
                              child: Row(
                                children: [
                                  AppCardLeadingAvatar(
                                    icon: Icons.picture_as_pdf_rounded,
                                    borderColor: Color(AppColors.failureRed),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      a.fileType ?? 'Attachment'.tr(),
                                      style: AppStyles.heading(context),
                                    ),
                                  ),
                                  Icon(Icons.download_rounded, color: mainColor, size: 20),
                                ],
                              ),
                            ),
                          )).toList(),
                          const SizedBox(height: 24),
                        ],

                        _buildSectionHeader('My Evaluation'.tr(), Icons.fact_check_outlined),
                        const SizedBox(height: 12),
                        if (interview.myEvaluation != null) ...[
                          _buildInfoBox([
                            _buildInfoRow('Technical Score', interview.myEvaluation!.technicalScore.toString()),
                            _buildInfoRow('Soft Skills Score', interview.myEvaluation!.softSkillsScore.toString()),
                            _buildInfoRow('Overall Score', interview.myEvaluation!.overallScore.toString()),
                            _buildInfoRow('Recommendation', interview.myEvaluation!.recommendation),
                            _buildInfoRow('Notes', interview.myEvaluation!.notes),
                          ]),
                        ] else ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text('No evaluation submitted yet.'.tr(), style: AppStyles.greyContent(context)),
                          ),
                        ],

                        const SizedBox(height: 24),
                        if (interview.myEvaluation == null || interview.myEvaluation!.canEdit == true)
                          CustomElevatedButton(
                            backgroundColor: mainColor,
                            title: interview.myEvaluation == null ? 'Submit Evaluation'.tr() : 'Edit Evaluation'.tr(),
                            onPressed: () async {
                              _showEvaluationSheet(context, controller);
                            },
                          ),
                          
                        const SizedBox(height: 30),
                      ],
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Color(AppColors.buttons).withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, color: Color(AppColors.buttons), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.primaryContent(context).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(AppColors.secondaryButton),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(List<Widget> children) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: AppBorders.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {bool isLink = false}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, 
            child: Text(
              label.tr(), 
              style: AppStyles.greyContent(context).copyWith(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3, 
            child: isLink 
              ? InkWell(
                  onTap: () => launchUrl(Uri.parse(value), mode: LaunchMode.externalApplication),
                  child: Text(
                    value,
                    style: AppStyles.primaryContent(context).copyWith(
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: AppStyles.primaryContent(context).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.titleText),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color mainColor, InterviewModel interview) {
    final candidate = interview.candidate;
    final String? displayName = candidate?.fullName;
    final subtitleParts = <String>[
      if (candidate?.job?.title != null && candidate!.job!.title!.isNotEmpty)
        candidate.job!.title!,
      if (interview.interviewType != null && interview.interviewType!.isNotEmpty)
        interview.interviewType!,
      if (interview.scheduledAt != null && interview.scheduledAt!.isNotEmpty)
        interview.scheduledAt!,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          routeName: AppRoutes.cvHubInterviewDetails.name,
          title: 'Interview Details'.tr(),
        ),
        AppContentWidth(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppCardLeadingAvatar(
                        name: displayName,
                        icon: Icons.video_camera_front_outlined,
                        borderColor: mainColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName ??
                                  (interview.interviewType ?? 'Interview'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppStyles.heading(context),
                            ),
                            if (subtitleParts.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                subtitleParts.join(' · '),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.subtitleContent(context),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AppStatusBadge.fromStatus(
                        status: interview.status ?? 'Pending',
                      ),
                    ],
                  ),
                  if (interview.location != null &&
                      interview.location!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () {
                        if (interview.location!.startsWith('http')) {
                          launchUrl(Uri.parse(interview.location!),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: mainColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              interview.location!.startsWith('http')
                                  ? 'Meeting Link'.tr()
                                  : interview.location!,
                              style: AppStyles.subtitleContent(context).copyWith(
                                color: interview.location!.startsWith('http')
                                    ? mainColor
                                    : null,
                                decoration: interview.location!.startsWith('http')
                                    ? TextDecoration.underline
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
