import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/app_styles.dart';
import '../../../../core/widgets/template_page.widget.dart';
import '../controllers/daily_reports_controller.dart';
import '../models/daily_report_model.dart';

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

  void _submit() async {
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
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCardSection(
                    title: AppStrings.accomplishments.tr(),
                    subtitle: AppStrings.whatHaveYouDoneToday.tr(),
                    icon: Icons.task_alt_rounded,
                    iconColor: Colors.green.shade500,
                    child: _buildTextField(_doneController, AppStrings.detailCompletedTasks.tr()),
                  ),
                  SizedBox(height: 20),
                  _buildCardSection(
                    title: AppStrings.inProgressTasks.tr(),
                    subtitle: AppStrings.whatAreYouCurrentlyWorkingOn.tr(),
                    icon: Icons.sync_rounded,
                    iconColor: Colors.blue.shade500,
                    child: _buildTextField(_inProgressController, AppStrings.detailOngoingTasks.tr()),
                  ),
                  SizedBox(height: 20),
                  _buildCardSection(
                    title: AppStrings.blockersAndProblems.tr(),
                    subtitle: AppStrings.anyIssuesYouFaced.tr(),
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.orange.shade500,
                    child: _buildTextField(_problemsController, AppStrings.describeBlockers.tr()),
                  ),
                  SizedBox(height: 20),
                  _buildCardSection(
                    title: AppStrings.attachments.tr(),
                    subtitle: AppStrings.uploadScreenshots.tr(),
                    icon: Icons.attach_file_rounded,
                    iconColor: Color(AppColors.buttons),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (selectedFiles.isNotEmpty) ...[
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: selectedFiles.length,
                              separatorBuilder: (context, index) => SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final file = selectedFiles[index].files.first;
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.insert_drive_file_rounded, color: Colors.grey.shade600, size: 24),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          file.name, 
                                          maxLines: 1, 
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)
                                        ),
                                      ),
                                      IconButton(
                                        icon: Container(
                                          padding: EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.close_rounded, color: Colors.red, size: 16)
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedFiles.removeAt(index);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 16),
                          ],
                          InkWell(
                            onTap: _pickFiles,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Color(AppColors.buttons).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Color(AppColors.buttons).withOpacity(0.2), style: BorderStyle.solid),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cloud_upload_rounded, color: Color(AppColors.buttons), size: 32),
                                  SizedBox(height: 8),
                                  Text(
                                    AppStrings.tapToBrowseFiles.tr(),
                                    style: TextStyle(
                                      color: Color(AppColors.buttons),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 48),
                  _buildSubmitButton(provider, isEditing),
                  SizedBox(height: 40),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildCardSection({
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color iconColor, 
    required Widget child
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.titleTextContent(context).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(AppColors.secondaryButton),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
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
      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  Widget _buildSubmitButton(DailyReportsProvider provider, bool isEditing) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(AppColors.buttons).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: provider.isActionLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(AppColors.buttons),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: provider.isActionLoading
            ? const SizedBox(
                height: 24, 
                width: 24, 
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
              )
            : Text(
                isEditing ? AppStrings.updateReport.tr() : AppStrings.saveReport.tr(),
                style: AppStyles.whiteContent(context).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
