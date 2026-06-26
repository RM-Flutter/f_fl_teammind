import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/features/tasks/controllers/tasks_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';

class AddNewTaskListWidget extends StatefulWidget {
  var subTasks;
  AddNewTaskListWidget({super.key, this.subTasks});
  @override
  _AddNewTaskListWidgetState createState() => _AddNewTaskListWidgetState();
}

class _AddNewTaskListWidgetState extends State<AddNewTaskListWidget> {
  List<TextEditingController> _controllers = [];
  late TasksController values;
  @override
  void initState() {
    super.initState();

    // This will be called after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tasks = Provider.of<TasksController>(context, listen: false).tasksList;

      // Only initialize _controllers if tasksList isn't empty
      if (tasks.isNotEmpty && _controllers.isEmpty) {
        _controllers = List.generate(
          tasks.length,
              (index) => TextEditingController(text: tasks[index]),
        );
      }

      // Initialize TasksController only once
      values = TasksController();

      // Ensure that tasksList is updated only once, and data isn't overwritten
      if (widget.subTasks != null && widget.subTasks!.isNotEmpty) {
        // Add new subtasks to tasksList2 without overwriting it
        values.tasksList2.addAll(widget.subTasks!);

        // Only update tasksList if it's empty
        if (values.tasksList.isEmpty) {
          values.tasksList = widget.subTasks!
              .map((e) => e.name ?? '') // Mapping SubTasks to String
              .toList()
              .cast<String>();
        } else {
          // Ensure we preserve existing tasks and don't overwrite them
          values.tasksList.addAll(widget.subTasks!
              .map((e) => e.name ?? '') // Mapping SubTasks to String
              .toList());
        }

        // Log the valuess for debugging
        debugPrint("widget.subTasks is --> ${widget.subTasks}");
        debugPrint("value.tasksList2 is --> ${values.tasksList2}");
        debugPrint("values.tasksList is --> ${values.tasksList}");

        // Trigger a rebuild after the state change
        setState(() {});
      }
    });
  }

  void _syncControllersWithTasks(List<String> tasks) {
    // Sync controllers only if the length of tasks is different from _controllers
    if (_controllers.length != tasks.length) {
      _controllers = List.generate(
        tasks.length,
            (index) => TextEditingController(text: tasks[index]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksController>(
      builder: (context, value, child) {
        // Only sync controllers if tasksList is not empty
        if (value.tasksList.isNotEmpty) {
          debugPrint("value.tasksList is --> ${value.tasksList}");
          _syncControllersWithTasks(value.tasksList);
        }

        // Log the updated value.tasksList
        debugPrint("Updated value.tasksList is --> ${value.tasksList}");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.taskList.tr(),
              style: AppStyles.primaryContent(context).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),

            ...value.tasksList2.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value['name'];

              return Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(AppColors.border)),
                  ),
                  child: ListTile(
                    title: TextField(
                      controller: _controllers[index],
                      onChanged: (text) {
                        value.tasksList2[index]['name'] = text;
                        debugPrint("Updated index $index: ${value.tasksList2[index]}");
                        setState(() {}); // if you want to reflect changes immediately
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: AppStrings.taskName.tr(),
                        hintStyle: AppStyles.greyContent(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(AppColors.overlay)),
                        contentPadding: EdgeInsets.zero,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                    trailing: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        value.tasksList2.removeAt(index);
                        _controllers.removeAt(index);
                        setState(() {});
                      },
                      child: Icon(
                        Icons.delete,
                        color: Color(AppColors.red),
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(AppColors.secondaryButton),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                setState(() {
                  value.tasksList2.add({
                    "name" : "",
                    "status" : false
                  });
                  _controllers.add(TextEditingController(text: ""));
                });
              },
              icon: Icon(Icons.add, color: Colors.white, size: 16,),
              label: Text(
                AppStrings.addOne.tr().toUpperCase(),
                style: AppStyles.whiteContent(context).copyWith(fontSize: 10, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}
