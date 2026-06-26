import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' show File;

import 'package:app_test/core/platform/platform_is.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/more/notifications/controllers/notification_controller.dart';
import 'package:app_test/core/widgets/text_form_widget.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/check_values.dart';


class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  @override
  State<AddNotificationScreen> createState() =>
      _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  late final NotificationProviderModel viewModel;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    viewModel = NotificationProviderModel();
    viewModel.initializeAddTaskScreen(context: context);
    viewModel.listAttachmentPersonalImage = [];
    viewModel.listXAttachmentPersonalImage = [];
  }
  @override
  Widget build(BuildContext context) {
    List<int> tempSelectedIds = List.from(viewModel.listIds);
    List<int> tempDepSelectedIds = List.from(viewModel.listIdsDepartment);
    return ChangeNotifierProvider<NotificationProviderModel>(
      create: (_) => viewModel,
      child: TemplatePage(
        pageContext: context,
        title: AppStrings.addNotification.tr(),
        body: Form(
          key: formKey,
          child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 1100 : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSizes.s16,
                      horizontal: AppSizes.s12,
                    ),
                    child: Consumer<NotificationProviderModel>(
                      builder: (context, viewModel, child) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 14),
                          TextFormField(
                            controller: viewModel.titleArController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "${AppStrings.titleAr.tr()} ${AppStrings.isRequired.tr()}";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.titleAr.tr(),
                              hintStyle: AppStyles.darkContent(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          TextFormField(
                            controller: viewModel.titleEnController,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "${AppStrings.titleEn.tr()} ${AppStrings.isRequired.tr()}";
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: AppStrings.titleEn.tr(),
                              hintStyle: AppStyles.darkContent(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                      SizedBox(height: 14),
                      defaultDropdownField(
                          textStyle: AppStyles.darkContent(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                            value: viewModel.selectNotificationType,
                            title: viewModel.selectNotificationType ?? AppStrings.type.tr(),
                            items: viewModel.notificationsType
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e['value'].toString(),
                                    child: Text(
                                      e['name'].toString(),
                                      style: AppStyles.darkContent(context).copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? values) {
                              setState(() {
                                viewModel.selectNotificationType = values;
                                viewModel.listIds.clear();
                                viewModel.listIdsDepartment.clear();
                              });
                            },
                          ),
                          if (viewModel.selectNotificationType == "some_employees" &&
                              viewModel.employees.isNotEmpty)
                            SizedBox(height: 14),
                          if (viewModel.selectNotificationType == "some_employees" &&
                              viewModel.employees.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                String searchQuery = "";
                                List<Map> filteredEmployees = viewModel.employees;
                                final selected = await showModalBottomSheet<List<Map>>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        final maxHeight = 0.7.sh;
                                        return ConstrainedBox(
                                          constraints: BoxConstraints(maxHeight: maxHeight),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AppStrings.employeeName.tr(),
                                                  style: AppStyles.heading(context).copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(height: 10),
                                                TextFormField(
                                                  decoration: InputDecoration(
                                                    hintText: AppStrings.searchByName.tr(),
                                                    prefixIcon: Icon(Icons.search, size: 24),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    setModalState(() {
                                                      searchQuery = value.toLowerCase();
                                                      filteredEmployees = viewModel.employees
                                                          .where((e) => e['name']
                                                              .toString()
                                                              .toLowerCase()
                                                              .contains(searchQuery))
                                                          .toList();
                                                    });
                                                  },
                                                ),
                                                SizedBox(height: 10),
                                                ConstrainedBox(
                                                  constraints:
                                                      BoxConstraints(maxHeight: maxHeight * 0.6),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: filteredEmployees.map((employee) {
                                                        final isSelected =
                                                            tempSelectedIds.contains(employee['id']);
                                                        return CheckboxListTile(
                                                          value: isSelected,
                                                          title: Text(employee['name'], style: AppStyles.content(context).copyWith(fontSize: 14)),
                                                          onChanged: (bool? value) {
                                                            setModalState(() {
                                                              if (value == true) {
                                                                tempSelectedIds.add(employee['id']);
                                                              } else {
                                                                tempSelectedIds.remove(employee['id']);
                                                              }
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      viewModel.employees
                                                          .where((e) =>
                                                              tempSelectedIds.contains(e['id']))
                                                          .toList(),
                                                    );
                                                  },
                                                  child: Text(
                                                    AppStrings.confirm.tr(),
                                                    style: AppStyles.whiteContent(context).copyWith(
                                                        fontSize: 16, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );

                                if (selected != null) {
                                  setState(() {
                                    viewModel.listIds = selected.map((e) => e['id']).toList();
                                  });
                                }
                              },
                              child: Container(
                                height: 65,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.s10),
                                    side: BorderSide(
                                      color: Color(AppColors.border),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      viewModel.listIds.isEmpty
                                          ? AppStrings.employeeName.tr()
                                          : '${viewModel.listIds.length} ${AppStrings.selected.tr()}',
                                      style: AppStyles.darkContent(context).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Icon(Icons.arrow_drop_down, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          if (viewModel.selectNotificationType == "departments" &&
                              viewModel.departments.isNotEmpty)
                            SizedBox(height: 14),
                          if (viewModel.selectNotificationType == "departments" &&
                              viewModel.departments.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                final selected = await showModalBottomSheet<List<Map>>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        final maxHeight = 0.7.sh;
                                        return ConstrainedBox(
                                          constraints: BoxConstraints(maxHeight: maxHeight),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  AppStrings.departmentName.tr(),
                                                  style: AppStyles.heading(context).copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 18),
                                                ),
                                                SizedBox(height: 12),
                                                ConstrainedBox(
                                                  constraints:
                                                      BoxConstraints(maxHeight: maxHeight * 0.6),
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: viewModel.departments.map((department) {
                                                        final isSelected = tempDepSelectedIds
                                                            .contains(department['id']);
                                                        return CheckboxListTile(
                                                          value: isSelected,
                                                          selectedTileColor: Color(AppColors.secondaryButton),
                                                          title: Text(department['title'], style: AppStyles.content(context).copyWith(fontSize: 14)),
                                                          onChanged: (bool? value) {
                                                            setModalState(() {
                                                              if (value == true) {
                                                                tempDepSelectedIds
                                                                    .add(department['id']);
                                                              } else {
                                                                tempDepSelectedIds
                                                                    .remove(department['id']);
                                                              }
                                                            });
                                                          },
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                        context,
                                                        viewModel.departments
                                                            .where((e) =>
                                                                tempDepSelectedIds.contains(e['id']))
                                                            .toList());
                                                  },
                                                  child: Text(
                                                    AppStrings.confirm.tr(),
                                                    style: AppStyles.whiteContent(context).copyWith(
                                                        fontSize: 16, fontWeight: FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );

                                if (selected != null) {
                                  setState(() {
                                    viewModel.listIdsDepartment =
                                        selected.map((e) => e['id']).toList();
                                  });
                                }
                              },
                              child: Container(
                                height: 65,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.s10),
                                    side: BorderSide(
                                      color: Color(AppColors.border),
                                      width: 1.0,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      viewModel.listIdsDepartment.isEmpty
                                          ? AppStrings.departmentName.tr()
                                          : '${viewModel.listIdsDepartment.length} ${AppStrings.selected.tr()}',
                                      style: AppStyles.darkContent(context).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                    ),
                                    Icon(Icons.arrow_drop_down, size: 24),
                                  ],
                                ),
                              ),
                            ),
                          SizedBox(height: 14),
                          TextFormField(
                            maxLines: 8,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "${AppStrings.contentAr.tr()} ${AppStrings.isRequired.tr()}";
                              } else {
                                return null;
                              }
                            },
                            controller: viewModel.contentArController,
                            decoration: InputDecoration(
                              hintText: AppStrings.contentAr.tr(),
                              hintStyle: AppStyles.darkContent(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(height: 14),
                          TextFormField(
                            maxLines: 8,
                            validator: (String? value) {
                              if (value!.isEmpty) {
                                return "${AppStrings.contentEn.tr()} ${AppStrings.isRequired.tr()}";
                              } else {
                                return null;
                              }
                            },
                            controller: viewModel.contentEnController,
                            decoration: InputDecoration(
                              hintText: AppStrings.contentEn.tr(),
                              hintStyle: AppStyles.darkContent(context).copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                          ),
                        ),
                        SizedBox(height: 14),
                          GestureDetector(
                            onTap: () async {
                              await viewModel.getImage(context,
                                  image1: viewModel.attachmentPersonalImage,
                                  image2: viewModel.XImageFileAttachmentPersonal,
                                  list2: viewModel.listXAttachmentPersonalImage,
                                  one: false,
                                  list: viewModel.listAttachmentPersonalImage);
                            },
                            child: Container(
                              height: 65,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppSizes.s10),
                                  side: BorderSide(
                                    color: Color(AppColors.border),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppStrings.imageCover.tr(),
                                    style: AppStyles.darkContent(context).copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  Icon(
                                    Icons.ios_share,
                                    color: Colors.grey,
                                    size: 24,
                                    // color: Color(AppColors.buttons),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (viewModel.listAttachmentPersonalImage.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: GridView.builder(
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: viewModel.listAttachmentPersonalImage.length,
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: kIsWeb ? 7 : 4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                itemBuilder: (c, i) {
                                  return buildCustomContainer(
                                      file: CheckValuesFromApi.safeArray(
                                          viewModel.listAttachmentPersonalImage)[i]['compressed'],
                                      xFile: CheckValuesFromApi.safeArray(
                                          viewModel.listXAttachmentPersonalImage)[i],
                                      onTap: () {
                                        setState(() {
                                          viewModel.listAttachmentPersonalImage.removeAt(i);
                                          viewModel.listXAttachmentPersonalImage.removeAt(i);
                                        });
                                      });
                                },
                              ),
                            ),
                          SizedBox(height: 14),
                          Container(
                            height: 65,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.s10),
                                side: BorderSide(
                                  color: Color(AppColors.border),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.allowComments.tr(),
                                  style: AppStyles.darkContent(context).copyWith(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      viewModel.allowComment = !viewModel.allowComment;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF000080),
                                        width: 2,
                                      ),
                                    ),
                                    padding: EdgeInsets.all(3),
                                    child: viewModel.allowComment
                                        ? Container(
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF000080),
                                            ),
                                          )
                                        : null,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          if (viewModel.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Center(
                              child: SizedBox(
                                width: 164,
                                height: 50,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF000080),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      viewModel.addNotification(context,
                                          depIds: tempDepSelectedIds, empIds: tempSelectedIds);
                                    }
                                  },
                                  child: Text(
                                    AppStrings.send.tr().toUpperCase(),
                                    style: AppStyles.whiteContent(context).copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

  Widget buildCustomContainer({dynamic file, dynamic xFile, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(left: 10, bottom: 10),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color(AppColors.darkBlue),
                  width: 2
              ),
            ),
            child: (kIsWeb || PlatformIs.web)
                ? FutureBuilder<Uint8List?>(
              future: (xFile is XFile) ? xFile.readAsBytes() : Future<Uint8List?>.value(null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData && snapshot.data != null) {
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                }
                return const Icon(Icons.image_not_supported);
              },
            )
                : Image(
              image: FileImage(file as File),
              fit: BoxFit.cover,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: const Icon(Icons.delete, color: Colors.red,),
            ),
          )
        ],
      ),
    );
  }
}
