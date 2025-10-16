import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/general_services/localization.service.dart';

import '../../../controller/task_controller/task_view_model.dart';
import '../../../models/get_one_task_model.dart';

class TaskDetailsSubTaskWidget extends StatefulWidget {
  var subtaskName;
  var subtaskDate;
  var assetName;
  var status;
  GetOneTaskModel? getOneTaskModel;
  TaskDetailsSubTaskWidget({this.subtaskDate, this.subtaskName, this.assetName, this.status, this.getOneTaskModel});

  @override
  State<TaskDetailsSubTaskWidget> createState() => _TaskDetailsSubTaskWidgetState();
}

class _TaskDetailsSubTaskWidgetState extends State<TaskDetailsSubTaskWidget> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskViewModel(),
      child: Consumer<TaskViewModel>(builder: (context, value, child) {
        return Container(
          padding: EdgeInsets.only(
              left: LocalizationService.isArabic(context: context) ?0 :15,
              right: LocalizationService.isArabic(context: context) ?15 :0
          ),
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: const Color(AppColors.primary),
              )
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(widget.assetName),
                    const SizedBox(width: 12,),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.68,
                        child: Text(widget.subtaskName ?? "",
                          style: const TextStyle(color: Color(AppColors.dark),fontSize: 12,fontWeight: FontWeight.w600),)),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: (){
                  setState(() {
                    widget.status = !widget.status;
                  });
                    value.updateSubTask(context,
                    content: widget.getOneTaskModel!.task!.content.toString(),
                      assign: widget.getOneTaskModel!.task!.content.toString()
                    );
                },
                child: Container(
                  width: 30,
                  height: 30,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(AppColors.primary)),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.status == true ?const Color(AppColors.primary) : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },)
    );
  }
}
