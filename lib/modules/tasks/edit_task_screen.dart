import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/controller/task_controller/task_view_model.dart';
import 'package:rmemp/modules/tasks/widget/add_new_task_list_widget.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/localization.service.dart';
import '../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import 'widget/edit_new_task_list_widget.dart';

class EditTaskScreen extends StatefulWidget {
  var id;
  EditTaskScreen({super.key, this.id});

  @override
  State<EditTaskScreen> createState() =>
      _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late final TaskViewModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = TaskViewModel();
    viewModel.getEmployees(context: context);
    viewModel.getOneTask(context, widget.id).then((_) {
      if (viewModel.getOneTaskModel != null) {
        var model = viewModel.getOneTaskModel;
        viewModel.titleController.text = model!.task!.title ?? '';
        viewModel.contentController.text = model.task!.content ?? '';
        viewModel.selectedDatecontroller.text = model.task!.dueDate ?? '';
        viewModel.selectedIcon = model.task?.icon;
        viewModel.selectedStatus = model.task?.status;
        if (model.task!.assignTo!.isNotEmpty) {
          viewModel.selectedEmployeeIds = model.task!.assignTo!
              .map((e) => e.id as int)
              .toList();
          print("listIds is --> ${viewModel.listIds}");
        }
        setState(() {}); // Refresh UI after setting data
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TaskViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.updateTask.tr(),
          body: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.s16, horizontal: AppSizes.s12),
                child: Consumer<TaskViewModel>(
                  builder: (context, viewModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gapH14,
                      Text(AppStrings.mainData.tr(), style: const TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.w600, fontSize: 14),),
                      gapH14,
                      TextField(
                        controller: viewModel.titleController,
                        decoration: InputDecoration(
                          hintText: AppStrings.title.tr(),
                        ),
                      ),gapH14,
                      TextField(
                        maxLines: 8,
                        controller: viewModel.contentController,
                        decoration: InputDecoration(
                          hintText: AppStrings.content.tr(),

                        ),
                      ),
                      gapH14,
                      TextField(
                        controller: viewModel.selectedDatecontroller,
                        decoration: InputDecoration(
                          hintText: AppStrings.deadline.tr(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => viewModel.selectDate(context),
                          ),
                        ),
                        readOnly: true,
                        onTap: () => viewModel.selectDate(context),
                      ),
                      gapH14,
                      InkWell(
                        onTap: (){
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          AppStrings.employeeName.tr(),
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: viewModel.employees.length,
                                          itemBuilder: (context, index) {
                                            final emp = viewModel.employees[index];
                                            final id = emp['id'] as int;
                                            final isSelected = viewModel.selectedEmployeeIds.contains(id);
                                            return CheckboxListTile(
                                              value: isSelected,
                                              title: Text(emp['name']),
                                              onChanged: (checked) {
                                                setModalState(() {
                                                  if (checked == true) {
                                                    viewModel.selectedEmployeeIds.add(id);
                                                  } else {
                                                    viewModel.selectedEmployeeIds.remove(id);
                                                  }
                                                });
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            setState(() {});
                                          },
                                          child: Text(AppStrings.send.tr(), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),),
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
                          height: 65,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.s10),
                              side: BorderSide(
                                color :const Color(0xffE3E5E5),
                                width: 1.0,
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                viewModel.selectedEmployeeIds.isNotEmpty? "${viewModel.selectedEmployeeIds.length} ${AppStrings.selected.tr()}": AppStrings.employeeName.tr(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xff191C1F)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      gapH14,
                      defaultDropdownField(
                        value: viewModel.iconsName.any((item) => item['value'].toString() == viewModel.selectedIcon)
                            ? viewModel.selectedIcon
                            : null,
                        title: viewModel.selectedIcon ?? AppStrings.selectIcon.tr(),
                        items: viewModel.iconsName.map((e) => DropdownMenuItem(
                            value: e['name'].toString(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(e['value']!, fit: BoxFit.scaleDown, width: 27, height: 24,),
                                const SizedBox(width: 10,),
                                Text(
                                  e['name'].toString(),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xff191C1F)
                                  ),),
                              ],
                            )
                        ),
                        ).toList(),
                        onChanged: (String? values) {
                          print(values);
                          setState(() {
                            viewModel.selectedIcon = values;
                            print("selectedIcon is --> ${viewModel.selectedIcon}");
                          });
                        },
                      ),
                      gapH14,
                      defaultDropdownField(
                        value: viewModel.statusTypes.any((item) => item['value'].toString() == viewModel.selectedStatus)
                            ? viewModel.selectedStatus
                            : null,
                        title: viewModel.selectedStatus ?? AppStrings.status.tr(),
                        items: viewModel.statusTypes.map((e) => DropdownMenuItem(
                          value: e['value'].toString(),
                          child: Text(
                            e['name'].toString(),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff191C1F)
                            ),),
                        ),
                        ).toList(),
                        onChanged: (String? values) {
                          print(values);
                          setState(() {
                            viewModel.selectedStatus = values;
                          });
                        },
                      ),
                      gapH14,
                     if(viewModel.getOneTaskModel != null && viewModel.getOneTaskModel!.task!.subTasks != null) EditNewTaskListWidget(
                        subTasks: viewModel.subTasks,
                      ),
                      gapH14,
                      const SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(viewModel.isLoading == false) CustomElevatedButton(
                            backgroundColor:
                            Theme.of(context).colorScheme.primary,
                            titleSize: AppSizes.s14,
                            radius: AppSizes.s24,
                            title: AppStrings.updateTask.tr(),
                            onPressed: () async {
                              viewModel.updateTask(context, widget.id);
                            },
                          ),
                          if(viewModel.isLoading == true) const CircularProgressIndicator()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
}
