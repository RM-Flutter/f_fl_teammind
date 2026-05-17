import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/tasks/controllers/tasks_controller.dart';
import 'package:app_test/features/tasks/views/add/widgets/add_new_task_list_widget.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/text_form_widget.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final TasksController viewModel;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    viewModel = TasksController();
    viewModel.initializeAddTaskScreen(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TasksController>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.addNewTask.tr(),
          body: Scaffold(
            body: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 1100.w : double.infinity,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: AppSizes.s16.h, horizontal: AppSizes.s12.w),
                    child: Consumer<TasksController>(
                      builder: (context, viewModel, child) => Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            gapH14,
                            Text(
                              AppStrings.mainData.tr(),
                              style: AppStyles.primaryContent(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp),
                            ),
                            gapH14,
                            TextFormField(
                              controller: viewModel.titleController,
                              decoration: InputDecoration(
                                hintText: AppStrings.title.tr(),
                              ),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return "${AppStrings.title.tr()} ${AppStrings.isRequired.tr()}";
                                }
                                return null;
                              },
                            ),
                            gapH14,
                            TextFormField(
                              maxLines: 8,
                              controller: viewModel.contentController,
                              decoration: InputDecoration(
                                hintText: AppStrings.content.tr(),
                              ),
                              validator: (String? value) {
                                if (value!.isEmpty) {
                                  return "${AppStrings.content.tr()} ${AppStrings.isRequired.tr()}";
                                }
                                return null;
                              },
                            ),
                            gapH14,
                            TextField(
                              controller: viewModel.selectedDatecontroller,
                              decoration: InputDecoration(
                                hintText: AppStrings.deadline.tr(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () =>
                                      viewModel.selectDate(context),
                                ),
                              ),
                              readOnly: true,
                              onTap: () => viewModel.selectDate(context),
                            ),
                            gapH14,
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16.r)),
                                  ),
                                  builder: (context) {
                                    return StatefulBuilder(
                                      builder: (context, setModalState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.all(16.0.r),
                                              child: Text(
                                                AppStrings.employeeName.tr(),
                                                style: AppStyles.heading(context).copyWith(
                                                    fontSize: 18.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount:
                                                    viewModel.employees.length,
                                                itemBuilder: (context, index) {
                                                  final emp = viewModel
                                                      .employees[index];
                                                  final id = emp['id'] as int;
                                                  final isSelected = viewModel
                                                      .selectedEmployeeIds
                                                      .contains(id);
                                                  return CheckboxListTile(
                                                    value: isSelected,
                                                    title: Text(emp['name']),
                                                    onChanged: (checked) {
                                                      setModalState(() {
                                                        if (checked == true) {
                                                          viewModel
                                                              .selectedEmployeeIds
                                                              .add(id);
                                                        } else {
                                                          viewModel
                                                              .selectedEmployeeIds
                                                              .remove(id);
                                                        }
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  EdgeInsets.all(16.0.r),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  setState(() {});
                                                },
                                                child: Text(
                                                    AppStrings.send.tr(),
                                                    style: AppStyles.whiteContent(context).copyWith(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14.sp)),
                                              ),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                height: 65.h,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 0),
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppSizes.s10.r),
                                    side: BorderSide(
                                      color: Color(AppColors.border),
                                      width: 1.0.r,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      viewModel.selectedEmployeeIds.isNotEmpty
                                          ? "${viewModel.selectedEmployeeIds.length} ${AppStrings.selected.tr()}"
                                          : AppStrings.employeeName.tr(),
                                      style: AppStyles.greyContent(context).copyWith(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: Color(AppColors.overlay)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            gapH14,
                            defaultDropdownField(
                              value: viewModel.selectedIcon,
                              icon: Icons.ios_share,
                              title: viewModel.selectedIcon ?? AppStrings.selectIcon.tr(),
                              items: viewModel.iconsName.map(
                                    (e) => DropdownMenuItem(
                                        value: e['name'].toString(),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SvgPicture.asset(
                                              e['value']!,
                                              fit: BoxFit.scaleDown,
                                              width: 27.r,
                                              height: 24.r,
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Text(
                                              e['name'].toString(),
                                              style: AppStyles.greyContent(context).copyWith(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(
                                                      AppColors.overlay)),
                                            ),
                                          ],
                                        )),
                                  )
                                  .toList(),
                              onChanged: (String? values) {
                                debugPrint(values);
                                setState(() {
                                  viewModel.selectedIcon = values;
                                  debugPrint(
                                      "selectedIcon is --> ${viewModel.selectedIcon}");
                                });
                              },
                            ),
                            gapH14,
                            defaultDropdownField(
                              value: viewModel.selectedStatus,
                              title: viewModel.selectedStatus ??
                                  AppStrings.status.tr(),
                              items: viewModel.statusTypes
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e['value'].toString(),
                                      child: Text(
                                        e['name'].toString(),
                                        style: AppStyles.greyContent(context).copyWith(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Color(AppColors.overlay)),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (String? values) {
                                debugPrint(values);
                                setState(() {
                                  viewModel.selectedStatus = values;
                                });
                              },
                            ),
                            gapH24,
                            AddNewTaskListWidget(),
                            gapH14,
                            SizedBox(
                              height: 30.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (viewModel.isLoading == false)
                                  CustomElevatedButton(
                                    backgroundColor:  Theme.of(context).colorScheme.secondary,
                                    titleSize: AppSizes.s14.sp,
                                    radius: AppSizes.s24.r,
                                    title: AppStrings.addTask.tr().toUpperCase(),
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        viewModel.addTask(context);
                                      }
                                    },
                                  ),
                                if (viewModel.isLoading == true)
                                  const CircularProgressIndicator()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
