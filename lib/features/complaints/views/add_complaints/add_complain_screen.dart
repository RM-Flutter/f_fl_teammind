import 'package:app_test/core/services/app_toast.dart';
import 'dart:io';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/all_text_field.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
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
  const NewComplainScreen(
      {super.key, this.initialSubject, this.initialDetails});

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
          return TemplatePage(
            pageContext: context,
            title: AppStrings.newRequest.tr(),
            routeName: AppRoutes.newComplainScreen.name,
            backgroundColor: Color(AppColors.background),
            body: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page, vertical: AppSpacing.md),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Interactive Type Selector (complaint | suggestion | other)
                        _buildTypeSelector(value, context),
                        gapH14,

                        // 2. Interactive Related To Selector (department | person)
                        _buildRelatedToSelector(value, context),
                        gapH14,

                        // 3. Conditional Dropdown (Department or Person)
                        _buildTargetDropdown(value, context),
                        gapH14,

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
                        gapH14,

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
                        gapH14,

                        // 6. Photo Attachments
                        _buildImageAttachmentSection(value, context),
                        gapH24,

                        // 7. Submit Button
                        if (value.isAddRequestLoading == true)
                          const Center(child: CircularProgressIndicator())
                        else
                          Center(
                            child: CustomElevatedButton(
                              backgroundColor: Color(AppColors.secondaryButton),
                              titleSize: AppSizes.s14,
                              radius: AppSizes.s24,
                              onPressed: () async {
                                if (formKey.currentState!.validate()) {
                                  if (value.complainRelatedTo == 'department' &&
                                      (value.selectedComplainDepartmentId ==
                                              null ||
                                          value.selectedComplainDepartmentId!
                                              .isEmpty)) {
                                    AppToast.showToast(
                                      msg: AppStrings.selectDepartment.tr(),
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                    );
                                    return;
                                  }
                                  if (value.complainRelatedTo == 'person' &&
                                      (value.selectedComplainEmployeeId ==
                                              null ||
                                          value.selectedComplainEmployeeId!
                                              .isEmpty)) {
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
                              title: AppStrings.sendRequest.tr(),
                              isFuture: false,
                            ),
                          ),
                        gapH24,
                      ],
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

  /// Dropdown with the same look as the other add screens (theme field, hint = field name).
  Widget _buildSelectDropdown({
    required BuildContext context,
    required String hint,
    required String value,
    required List<MapEntry<String, String>> options,
    required ValueChanged<String> onChanged,
  }) {
    final style = AppStyles.darkContent(context)
        .copyWith(fontSize: 14, fontWeight: FontWeight.w400);
    return DropdownButtonFormField<String>(
      value: options.any((o) => o.key == value) ? value : null,
      isExpanded: true,
      style: style,
      dropdownColor: Colors.white,
      decoration: InputDecoration(hintText: hint),
      items: [
        for (final o in options)
          DropdownMenuItem<String>(value: o.key, child: Text(o.value, style: style)),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _buildTypeSelector(AddNewRequestController value, BuildContext context) {
    return _buildSelectDropdown(
      context: context,
      hint: AppStrings.requestType.tr(),
      value: value.complainType,
      options: [
        MapEntry('complaint', AppStrings.complaint.tr()),
        MapEntry('suggestion', AppStrings.suggestion.tr()),
        MapEntry('other', AppStrings.other.tr()),
      ],
      onChanged: value.setComplainType,
    );
  }

  Widget _buildRelatedToSelector(AddNewRequestController value, BuildContext context) {
    return _buildSelectDropdown(
      context: context,
      hint: AppStrings.relatedTo.tr(),
      value: value.complainRelatedTo,
      options: [
        MapEntry('department', AppStrings.department.tr()),
        MapEntry('person', AppStrings.person.tr()),
      ],
      onChanged: value.setComplainRelatedTo,
    );
  }

  Widget _buildTargetDropdown(
      AddNewRequestController value, BuildContext context) {
    if (value.isComplainLoadingData) {
      return Container(
        height: 56,
        padding: const EdgeInsets.all(AppSizes.s12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: const Color(0xffE3E5E5)),
        ),
        child: const Center(
          child: SizedBox(
            height: AppSizes.s20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (value.complainRelatedTo == 'person') {
      Map<String, dynamic>? selectedEmp;
      for (final e in value.complainEmployees) {
        if (e['id']?.toString() ==
            value.selectedComplainEmployeeId?.toString()) {
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
        if (e['id']?.toString() ==
            value.selectedComplainDepartmentId?.toString()) {
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
        items: value.complainDepartments
            .map((e) => DropdownMenuItem(
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
                ))
            .toList(),
        onChanged: (String? val) {
          value.setComplainDepartment(val);
        },
      );
    }
  }

  Widget _buildImageAttachmentSection(
      AddNewRequestController value, BuildContext context) {
    Future<void> pick() async {
      await value.getImage(
        context,
        image1: value.attachmentPersonalImage,
        image2: value.XImageFileAttachmentPersonal,
        list2: value.listXAttachmentPersonalImage,
        one: false,
        list: value.listAttachmentPersonalImage,
      );
      AppToast.showToast(
        msg: AppStrings.addImageSuccessful.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }

    // Same attachment field as the other add screens: a read-only field with a paper-clip,
    // the picked images as thumbnails above it.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (value.listAttachmentPersonalImage.isNotEmpty) ...[
          SizedBox(
            height: AppSizes.s80,
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
          gapH8,
        ],
        TextFormField(
          readOnly: true,
          onTap: pick,
          decoration: InputDecoration(
            hintText: AppStrings.uploadImage.tr(),
            suffixIcon: const Icon(Icons.attach_file_rounded),
          ),
        ),
      ],
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
