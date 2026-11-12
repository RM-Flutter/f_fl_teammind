import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_elevated_button.widget.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../controllers/daily_reports_controller.dart';
import '../models/daily_report_model.dart';
import 'package:app_test/core/constants/app_design.dart';

class AddEditDailyReportScreen extends StatefulWidget {
  final DailyReportModel? report;
  const AddEditDailyReportScreen({super.key, this.report});

  @override
  State<AddEditDailyReportScreen> createState() => _AddEditDailyReportScreenState();
}

class _AddEditDailyReportScreenState extends State<AddEditDailyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doneController = TextEditingController();
  final _inProgressController = TextEditingController();
  final _problemsController = TextEditingController();
  
  List<FilePickerResult> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    if (widget.report != null) {
      _doneController.text = widget.report!.done ?? '';
      _inProgressController.text = widget.report!.inProgress ?? '';
      _problemsController.text = widget.report!.problems ?? '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = Provider.of<DailyReportsProvider>(context, listen: false);
    
    bool success = false;
    if (widget.report == null) {
      success = await provider.addReport(
        context, 
        _doneController.text, 
        _inProgressController.text, 
        _problemsController.text, 
        selectedFiles
      );
    } else {
      success = await provider.updateReport(
        context, 
        widget.report!.id.toString(), 
        _doneController.text, 
        _inProgressController.text, 
        _problemsController.text, 
        selectedFiles
      );
    }
    
    if (success) {
      context.pop();
    }
  }

  void _pickFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      
      if (images.isNotEmpty) {
        List<PlatformFile> platformFiles = [];
        for (var file in images) {
          platformFiles.add(PlatformFile(
            name: file.name,
            path: file.path,
            size: await file.length(),
            bytes: await file.readAsBytes(),
          ));
        }
        FilePickerResult result = FilePickerResult(platformFiles);
        setState(() {
          if (result.files.isNotEmpty) {
            for (var file in result.files) {
              selectedFiles.add(FilePickerResult([file]));
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Failed to pick images from gallery: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.report != null;
    return TemplatePage(
      pageContext: context,
      title: isEditing ? AppStrings.editReport.tr() : AppStrings.createDailyReport.tr(),
      routeName: AppRoutes.addEditDailyReportScreen.name,
      body: Consumer<DailyReportsProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page, vertical: AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(_doneController, AppStrings.accomplishments.tr(),
                      AppStrings.detailCompletedTasks.tr()),
                  gapH14,
                  _buildTextField(_inProgressController,
                      AppStrings.inProgressTasks.tr(), AppStrings.detailOngoingTasks.tr()),
                  gapH14,
                  _buildTextField(_problemsController,
                      AppStrings.blockersAndProblems.tr(), AppStrings.describeBlockers.tr()),
                  gapH14,
                  Text(
                    AppStrings.attachments.tr(),
                    style: AppStyles.primaryContent(context)
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  gapH14,
                  for (int i = 0; i < selectedFiles.length; i++) ...[
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.insert_drive_file_rounded,
                              color: Colors.grey.shade600, size: 20),
                          const SizedBox(width: AppSizes.s12),
                          Expanded(
                            child: Text(selectedFiles[i].files.first.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.red, size: 18),
                            onPressed: () =>
                                setState(() => selectedFiles.removeAt(i)),
                          ),
                        ],
                      ),
                    ),
                    gapH8,
                  ],
                  TextFormField(
                    readOnly: true,
                    onTap: _pickFiles,
                    decoration: InputDecoration(
                      hintText: AppStrings.tapToBrowseFiles.tr(),
                      suffixIcon: const Icon(Icons.attach_file_rounded),
                    ),
                  ),
                  gapH24,
                  Center(child: _buildSubmitButton(provider, isEditing)),
                  gapH24,
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint) {
    return TextFormField(
      controller: controller,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return AppStrings.fieldIsRequired.tr();
        }
        return null;
      },
      maxLines: 4,
      minLines: 2,
      decoration: InputDecoration(hintText: label),
    );
  }

  Widget _buildSubmitButton(DailyReportsProvider provider, bool isEditing) {
    if (provider.isActionLoading) return const CircularProgressIndicator();
    return CustomElevatedButton(
      backgroundColor: Color(AppColors.secondaryButton),
      titleSize: AppSizes.s14,
      radius: AppSizes.s24,
      title: isEditing ? AppStrings.updateReport.tr() : AppStrings.saveReport.tr(),
      onPressed: _submit,
    );
  }
}
