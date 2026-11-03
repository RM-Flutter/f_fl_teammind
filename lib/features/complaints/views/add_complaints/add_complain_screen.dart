import 'package:app_test/core/services/app_toast.dart';
import 'dart:io';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/all_text_field.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/requests/add/controller/add_new_request_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_design.dart';

class NewComplainScreen extends StatefulWidget {
  final String? initialSubject;
  final String? initialDetails;
  const NewComplainScreen({super.key, this.initialSubject, this.initialDetails});

  @override
  State<NewComplainScreen> createState() => _NewComplainScreenState();
}

class _NewComplainScreenState extends State<NewComplainScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final controller = AddNewRequestController();
        controller.fetchComplainData(context);
        if (widget.initialSubject != null) {
          controller.subjectController.text = widget.initialSubject!;
        }
        if (widget.initialDetails != null) {
          controller.detailsController.text = widget.initialDetails!;
        }
        return controller;
      },
      child: Consumer<AddNewRequestController>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBarWithBookmark(
              title: AppStrings.newRequest.tr().toUpperCase(),
              titleStyle: AppStyles.heading(context).copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              routeName: AppRoutes.newComplainScreen.name,
            ),
            backgroundColor: Color(AppColors.background),
            body: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width < 600
                    ? double.infinity
                    : 800,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),

                          // 1. Interactive Type Selector (complaint | suggestion | other)
                          _buildTypeSelector(value, context),
                          const SizedBox(height: 18),

                          // 2. Interactive Related To Selector (department | person)
                          _buildRelatedToSelector(value, context),
                          const SizedBox(height: 18),

                          // 3. Conditional Dropdown (Department or Person)
                          _buildTargetDropdown(value, context),
                          const SizedBox(height: 18),

                          // 4. Subject Field (title)
                          defaultTextFormField(
                            hintText: AppStrings.subject.tr(),
                            controller: value.subjectController,
                            context: context,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "${AppStrings.subject.tr()} ${AppStrings.isRequired.tr()}";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // 5. Details Field (content)
                          defaultTextFormField(
                            hintText: AppStrings.details.tr(),
                            controller: value.detailsController,
                            maxLines: 7,
                            context: context,
                            containerHeight: 180,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return "${AppStrings.details.tr()} ${AppStrings.isRequired.tr()}";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),

                          // 6. Photo Attachments
                          _buildImageAttachmentSection(value, context),
                          const SizedBox(height: 30),

                          // 7. Submit Button
                          if (value.isAddRequestLoading == true)
                            const Center(child: CircularProgressIndicator())
                          else
                            CustomElevatedButton(
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  if (value.complainRelatedTo == 'department' &&
                                      (value.selectedComplainDepartmentId == null ||
                                          value.selectedComplainDepartmentId!.isEmpty)) {
                                    AppToast.showToast(
                                      msg: AppStrings.selectDepartment.tr(),
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                  if (value.complainRelatedTo == 'person' &&
                                      (value.selectedComplainEmployeeId == null ||
                                          value.selectedComplainEmployeeId!.isEmpty)) {
                                    AppToast.showToast(
                                      msg: AppStrings.selectEmployee.tr(),
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                  value.createNewComplaint(
                                    context,
                                    images: value.listXAttachmentPersonalImage,
                                  );
                                }
                              },
                              title: AppStrings.sendRequest.tr().toUpperCase(),
                              isPrimaryBackground: true,
                              isFuture: false,
                            ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector(AddNewRequestController value, BuildContext context) {
    final types = [
      {'key': 'complaint', 'label': AppStrings.complaint.tr(), 'icon': Icons.report_problem_outlined},
      {'key': 'suggestion', 'label': AppStrings.suggestion.tr(), 'icon': Icons.lightbulb_outline},
      {'key': 'other', 'label': AppStrings.other.tr(), 'icon': Icons.more_horiz},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.requestType.tr(),
          style: AppStyles.heading(context).copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((t) {
            final isSelected = value.complainType == t['key'];
            return Expanded(
              child: GestureDetector(
                onTap: () => value.setComplainType(t['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(AppColors.buttons) : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isSelected ? Color(AppColors.buttons) : const Color(0xffE3E5E5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Color(AppColors.buttons).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t['label'] as String,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRelatedToSelector(AddNewRequestController value, BuildContext context) {
    final targets = [
      {'key': 'department', 'label': AppStrings.department.tr(), 'icon': Icons.business_outlined},
      {'key': 'person', 'label': AppStrings.person.tr(), 'icon': Icons.person_outline},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.relatedTo.tr(),
          style: AppStyles.heading(context).copyWith(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(AppColors.secondaryButton),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: targets.map((t) {
            final isSelected = value.complainRelatedTo == t['key'];
            return Expanded(
              child: GestureDetector(
                onTap: () => value.setComplainRelatedTo(t['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: isSelected ? Color(AppColors.buttons) : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isSelected ? Color(AppColors.buttons) : const Color(0xffE3E5E5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: Color(AppColors.buttons).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t['icon'] as IconData,
                        size: 17,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        t['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTargetDropdown(AddNewRequestController value, BuildContext context) {
    if (value.isComplainLoadingData) {
      return Container(
        height: 56,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: const Color(0xffE3E5E5)),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (value.complainRelatedTo == 'person') {
      Map<String, dynamic>? selectedEmp;
      for (final e in value.complainEmployees) {
        if (e['id']?.toString() == value.selectedComplainEmployeeId?.toString()) {
          selectedEmp = e;
          break;
        }
      }
      final currentTitle = (selectedEmp != null &&
              selectedEmp['name'] != null &&
              selectedEmp['name'].toString().isNotEmpty)
          ? selectedEmp['name'].toString()
          : AppStrings.selectEmployee.tr();

      return defaultDropdownField(
        value: value.selectedComplainEmployeeId,
        title: currentTitle,
        items: value.complainEmployees.map((e) {
          final dept = e['department'];
          final label = (dept != null && dept.toString().isNotEmpty)
              ? "${e['name']} ($dept)"
              : e['name'].toString();
          return DropdownMenuItem(
            value: e['id'].toString(),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.whiteContent(context).copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
                color: Color(AppColors.overlay),
              ),
            ),
          );
        }).toList(),
        onChanged: (String? val) {
          value.setComplainEmployee(val);
        },
      );
    } else {
      Map<String, dynamic>? selectedDept;
      for (final e in value.complainDepartments) {
        if (e['id']?.toString() == value.selectedComplainDepartmentId?.toString()) {
          selectedDept = e;
          break;
        }
      }
      final currentTitle = (selectedDept != null &&
              selectedDept['name'] != null &&
              selectedDept['name'].toString().isNotEmpty)
          ? selectedDept['name'].toString()
          : AppStrings.selectDepartment.tr();

      return defaultDropdownField(
        value: value.selectedComplainDepartmentId,
        title: currentTitle,
        items: value.complainDepartments.map((e) => DropdownMenuItem(
          value: e['id'].toString(),
          child: Text(
            e['name'].toString(),
            overflow: TextOverflow.ellipsis,
            style: AppStyles.whiteContent(context).copyWith(
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: Color(AppColors.overlay),
            ),
          ),
        )).toList(),
        onChanged: (String? val) {
          value.setComplainDepartment(val);
        },
      );
    }
  }

  Widget _buildImageAttachmentSection(AddNewRequestController value, BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await value.getImage(
          context,
          image1: value.attachmentPersonalImage,
          image2: value.XImageFileAttachmentPersonal,
          list2: value.listXAttachmentPersonalImage,
          one: false,
          list: value.listAttachmentPersonalImage,
        );
        AppToast.showToast(
          msg: AppStrings.addImageSuccessful.tr().toUpperCase(),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      },
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: ShapeDecoration(
          color: Color(AppColors.background),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            side: BorderSide(
              color: Color(AppColors.border),
              width: 1.0,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  AppStrings.uploadImage.tr(),
                  style: AppStyles.almostBlackContent(context).copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                CustomElevatedButton(
                  onPressed: () async {
                    await value.getImage(
                      context,
                      image1: value.attachmentPersonalImage,
                      image2: value.XImageFileAttachmentPersonal,
                      list2: value.listXAttachmentPersonalImage,
                      one: false,
                      list: value.listAttachmentPersonalImage,
                    );
                    AppToast.showToast(
                      msg: AppStrings.addImageSuccessful.tr().toUpperCase(),
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  },
                  title: AppStrings.image.tr().toUpperCase(),
                  width: 100,
                  isPrimaryBackground: true,
                  isFuture: false,
                ),
              ],
            ),
            if (value.listAttachmentPersonalImage.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: GridView.builder(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: value.listAttachmentPersonalImage.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (c, i) {
                    return _buildCustomContainer(
                      file: value.listAttachmentPersonalImage[i]['preview'],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomContainer({required dynamic file}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(
          color: const Color(AppColors.darkBlue),
          width: 1.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: kIsWeb
          ? (file is Uint8List
              ? Image.memory(file, fit: BoxFit.cover)
              : const Icon(Icons.image_not_supported))
          : Image.file(file as File, fit: BoxFit.cover),
    );
  }
}
