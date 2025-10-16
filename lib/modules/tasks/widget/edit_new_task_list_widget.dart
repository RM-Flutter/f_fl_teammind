import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/controller/task_controller/task_view_model.dart';

class EditNewTaskListWidget extends StatefulWidget {
  var subTasks;
  EditNewTaskListWidget({this.subTasks});
  @override
  _EditNewTaskListWidgetState createState() => _EditNewTaskListWidgetState();
}

class _EditNewTaskListWidgetState extends State<EditNewTaskListWidget> {
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final taskViewModel = Provider.of<TaskViewModel>(context, listen: false);
      final tasks = taskViewModel.tasksList;

      if (tasks.isNotEmpty && _controllers.isEmpty) {
        _controllers = List.generate(
          tasks.length,
              (index) => TextEditingController(text: tasks[index]),
        );
      }

      if (widget.subTasks != null && widget.subTasks!.isNotEmpty) {
        taskViewModel.tasksList2.addAll(widget.subTasks!);

        if (taskViewModel.tasksList.isEmpty) {
          taskViewModel.tasksList = widget.subTasks!
              .map((e) => e['name'] ?? '')
              .toList()
              .cast<String>();
        } else {
          taskViewModel.tasksList.addAll(widget.subTasks!
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
    return Consumer<TaskViewModel>(
      builder: (context, taskViewModel, child) {
        // Only sync controllers if tasksList is not empty
        if (taskViewModel.tasksList2.isNotEmpty) {
          print("taskViewModel.tasksList is --> ${taskViewModel.tasksList}");
          _syncControllersWithTasks(taskViewModel.tasksList2);
        }

        // Log the updated taskViewModel.tasksList
        print("Updated taskViewModel.tasksList is --> ${taskViewModel.tasksList2}");
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

            ...taskViewModel.tasksList2.asMap().entries.map((entry) {
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
                        taskViewModel.tasksList2[index]['name'] = text;
                        print("Updated index $index: ${taskViewModel.tasksList2[index]}");
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
                            taskViewModel.tasksList2.removeAt(index);
                            _controllers.removeAt(index);
                            setState(() {});
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Color(AppColors.red),
                          ),
                        ),
                        SizedBox(width: 15,),
                        GestureDetector(
                          onTap: () {
                            taskViewModel.tasksList2[index]['status'] = !taskViewModel.tasksList2[index]['status'];
                            print("TASK LIST ONE --> ${taskViewModel.tasksList}");
                            print("TASK LIST TWO --> ${taskViewModel.tasksList2}");
                            setState(() {});
                          },
                          child: Icon(
                            taskViewModel.tasksList2[index]["status"] == true
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: const Color(AppColors.primary),
                          ),
                        ),
                      ],
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
                  int nextIndex = taskViewModel.tasksList.length + 1;
                  taskViewModel.tasksList2.add({
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
