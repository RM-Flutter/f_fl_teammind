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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        ...candidate.attachments!.map((a) => InkWell(
                          onTap: () {
                            if (a.fileUrl != null) launchUrl(Uri.parse(a.fileUrl!), mode: LaunchMode.externalApplication);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(AppColors.scaffoldBackGround),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                              ]
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.picture_as_pdf, color: Color(AppColors.failureRed)),
                                const SizedBox(width: 12),
                                Expanded(child: Text(a.fileType ?? 'Attachment'.tr(), style: AppStyles.primaryContent(context).copyWith(fontWeight: FontWeight.w600))),
                                Icon(Icons.download, color: mainColor, size: 20),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(AppColors.scaffoldBackGround),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
        ]
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
    String? displayName = candidate?.fullName;

    return Container(
      height: 290,
      width: 1.sw,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(AppColors.secondaryButton),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xl),
          bottomRight: Radius.circular(AppRadius.xl),
        ),
        image: const DecorationImage(
          image: AssetImage("assets/images/request-app-bar.png"),
          fit: BoxFit.fill,
          opacity: 1.0,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1.sw),
          child: Column(
            children: [
              AppBarWithBookmark(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                routeName: AppRoutes.cvHubInterviewDetails.name,
                title: 'Interview Details'.tr(),
                titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 12),
                bookmarkIconColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed(AppRoutes.home.name,
                            pathParameters: {'lang': context.locale.languageCode});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_sharp,
                        color: Color(AppColors.scaffoldBackGround),
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              if (displayName != null) ...[
                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    shadows: [const Shadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))]
                  ),
                ),
                if (candidate?.job?.title != null)
                   Text(
                      candidate!.job!.title!,
                      style: AppStyles.whiteContent(context).copyWith(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                const SizedBox(height: 12),
              ],

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 65,
                          height: 85,
                          decoration: BoxDecoration(
                            color: mainColor.withOpacity(.3),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Status'.tr(), style: AppStyles.whiteContent(context).copyWith(fontSize: 10, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Icon(Icons.video_camera_front, color: Color(AppColors.scaffoldBackGround), size: 28),
                              const SizedBox(height: 4),
                              Text(interview.status ?? '', style: AppStyles.whiteContent(context).copyWith(fontSize: 10, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 85,
                        decoration: BoxDecoration(
                          color: Color(AppColors.scaffoldBackGround),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              interview.interviewType ?? 'Interview',
                              style: AppStyles.primaryContent(context).copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: mainColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (interview.scheduledAt != null)
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 10, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(interview.scheduledAt!, style: AppStyles.greyContent(context).copyWith(fontSize: 10))),
                                ],
                              ),
                            if (interview.location != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 10, color: Colors.grey.shade400),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        if (interview.location!.startsWith('http')) {
                                          launchUrl(Uri.parse(interview.location!), mode: LaunchMode.externalApplication);
                                        }
                                      },
                                      child: Text(
                                        interview.location!.startsWith('http') ? 'Meeting Link'.tr() : interview.location!, 
                                        style: AppStyles.greyContent(context).copyWith(
                                          fontSize: 10,
                                          color: interview.location!.startsWith('http') ? Colors.blue : null,
                                          decoration: interview.location!.startsWith('http') ? TextDecoration.underline : null,
                                        )
                                      ),
                                    )
                                  ),
                                ],
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                            elevation: 4,
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
