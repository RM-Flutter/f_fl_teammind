import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/controller/task_controller/task_view_model.dart';

class AddNewTaskListWidget extends StatefulWidget {
  var subTasks;
  AddNewTaskListWidget({this.subTasks});
  @override
  _AddNewTaskListWidgetState createState() => _AddNewTaskListWidgetState();
}

class _AddNewTaskListWidgetState extends State<AddNewTaskListWidget> {
  List<TextEditingController> _controllers = [];
  late TaskViewModel values;
  @override
  void initState() {
    super.initState();

    // This will be called after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tasks = Provider.of<TaskViewModel>(context, listen: false).tasksList;

      // Only initialize _controllers if tasksList isn't empty
      if (tasks.isNotEmpty && _controllers.isEmpty) {
        _controllers = List.generate(
          tasks.length,
              (index) => TextEditingController(text: tasks[index]),
        );
      }

      // Initialize TaskViewModel only once
      values = TaskViewModel();

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
        print("widget.subTasks is --> ${widget.subTasks}");
        print("value.tasksList2 is --> ${values.tasksList2}");
        print("values.tasksList is --> ${values.tasksList}");

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
    return Consumer<TaskViewModel>(
      builder: (context, value, child) {
        // Only sync controllers if tasksList is not empty
        if (value.tasksList.isNotEmpty) {
          print("value.tasksList is --> ${value.tasksList}");
          _syncControllersWithTasks(value.tasksList);
        }

        // Log the updated value.tasksList
        print("Updated value.tasksList is --> ${value.tasksList}");
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.taskList.tr(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(AppColors.primary),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            ...value.tasksList2.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value['name'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ListTile(
                    title: TextField(
                      controller: _controllers[index],
                      onChanged: (text) {
                        value.tasksList2[index]['name'] = text;
                        print("Updated index $index: ${value.tasksList2[index]}");
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
                    trailing: GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        value.tasksList2.removeAt(index);
                        _controllers.removeAt(index);
                        setState(() {});
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Color(AppColors.red),
                      ),
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppColors.dark),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                setState(() {
                  int nextIndex = value.tasksList.length + 1;
                  value.tasksList2.add({
                    "name" : AppStrings.taskName.tr(),
                    "status" : false
                  });
                  _controllers.add(TextEditingController(text: AppStrings.taskName.tr()));
                });
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                AppStrings.addOne.tr().toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        );
      },
    );
  }
}
