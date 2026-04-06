import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/features/tasks/controllers/tasks_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';

class EditNewTaskListWidget extends StatefulWidget {
  var subTasks;
  EditNewTaskListWidget({super.key, this.subTasks});
  @override
  _EditNewTaskListWidgetState createState() => _EditNewTaskListWidgetState();
}

class _EditNewTaskListWidgetState extends State<EditNewTaskListWidget> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tasksController = Provider.of<TasksController>(context, listen: false);
      final tasks = tasksController.tasksList;

      if (tasks.isNotEmpty && _controllers.isEmpty) {
        _controllers = List.generate(
          tasks.length,
              (index) => TextEditingController(text: tasks[index]),
        );
      }

      if (widget.subTasks != null && widget.subTasks!.isNotEmpty) {
        tasksController.tasksList2.addAll(widget.subTasks!);

        if (tasksController.tasksList.isEmpty) {
          tasksController.tasksList = widget.subTasks!
              .map((e) => e['name'] ?? '')
              .toList()
              .cast<String>();
        } else {
          tasksController.tasksList.addAll(widget.subTasks!
              .map((e) => e['name'] ?? '')
              .toList());
        }

        setState(() {});
      }
    });
  }

  void _syncControllersWithTasks(List? tasks) {
    // Sync controllers only if the length of tasks is different from _controllers
    if (_controllers.length != tasks!.length) {
      _controllers = List.generate(
        tasks.length,
            (index) => TextEditingController(text: tasks![index]['name']),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksController>(
      builder: (context, tasksController, child) {
        // Only sync controllers if tasksList is not empty
        if (tasksController.tasksList2.isNotEmpty) {
          debugPrint("tasksController.tasksList is --> ${tasksController.tasksList}");
          _syncControllersWithTasks(tasksController.tasksList2);
        }

        // Log the updated tasksController.tasksList
        debugPrint("Updated tasksController.tasksList is --> ${tasksController.tasksList2}");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.taskList.tr(),
              style: AppStyles.primaryContent(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),

            ...tasksController.tasksList2.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value['name'];

              return Padding(
                padding: EdgeInsets.only(bottom: 12.0.h),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    title: TextField(
                      controller: _controllers[index],
                      onChanged: (text) {
                        tasksController.tasksList2[index]['name'] = text;
                        debugPrint("Updated index $index: ${tasksController.tasksList2[index]}");
                        setState(() {}); // if you want to reflect changes immediately
                      },
                      onTap: (){
                        if(_controllers[index].text == AppStrings.taskName.tr()){
                          setState(() {
                            _controllers[index].text = "";
                          });
                        }
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: AppStrings.taskName.tr(),
                        contentPadding: EdgeInsets.zero,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            tasksController.tasksList2.removeAt(index);
                            _controllers.removeAt(index);
                            setState(() {});
                          },
                          child: Icon(
                            Icons.delete,
                            color: Color(AppColors.red),
                            size: 24.r,
                          ),
                        ),
                        SizedBox(width: 15.w,),
                        GestureDetector(
                          onTap: () {
                            tasksController.tasksList2[index]['status'] = !tasksController.tasksList2[index]['status'];
                            debugPrint("TASK LIST ONE --> ${tasksController.tasksList}");
                            debugPrint("TASK LIST TWO --> ${tasksController.tasksList2}");
                            setState(() {});
                          },
                          child: Icon(
                            tasksController.tasksList2[index]["status"] == true
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: Color(AppColors.primary),
                            size: 24.r,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 20.h),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.dark),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {
                setState(() {
                  int nextIndex = tasksController.tasksList.length + 1;
                  tasksController.tasksList2.add({
                    "name" : AppStrings.taskName.tr(),
                    "status" : false
                  });
                  _controllers.add(TextEditingController(text: AppStrings.taskName.tr()));
                });
              },
              icon: Icon(Icons.add, color: Colors.white, size: 16.r,),
              label: Text(
                AppStrings.addOne.tr().toUpperCase(),
                style: AppStyles.whiteContent(context).copyWith(fontSize: 10.sp, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}
