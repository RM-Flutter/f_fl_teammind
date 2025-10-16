import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/comments/logic/view_model.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/controller/task_controller/task_view_model.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/profiles/views/widgets/employee_details_loading.widget.dart';
import 'package:rmemp/modules/tasks/widget/task_details_header_widget.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../common_modules_widgets/comments/comments_widget.dart';

class TaskDetailsScreen extends StatefulWidget {
  var id;
  TaskDetailsScreen({this.id,});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
   _scrollController = ScrollController();
    super.initState();
  }
  var icon;
  int? indexSelect;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskViewModel()..getOneTask(context, widget.id),),
        ChangeNotifierProvider(create: (context) => CommentProvider()..getComment(context, "tasks",widget.id),)
      ],
      child: Consumer<TaskViewModel>(
        builder: (context, value, child) {
          if(value.getOneTaskModel != null){
            if(value.getOneTaskModel!.task != null){
              final iconName = value.getOneTaskModel!.task!.icon;
              icon = value.iconsName.firstWhere((item) => item["name"] == iconName,
                  orElse: () => {
                    "value": "assets/images/svg/t3.svg"
                  } );
            }
          }
          var jsonString;
          var gCache;
          jsonString = CacheHelper.getString("US1");
          if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
            gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
            UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
          }
          return Consumer<CommentProvider>(
            builder: (context, values, child) {
              return Scaffold(
                floatingActionButton: value.getOneTaskModel != null ?(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty)?Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.05),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: LocalizationService.isArabic(context: context) ? 35 : 0),
                    width: double.infinity,
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      onPressed: () async {
                        await context.pushNamed(AppRoutes.editTaskScreen.name, pathParameters: {
                          'lang': context.locale.languageCode,
                          'id' : value.getOneTaskModel!.task!.id.toString()
                        });
                       await value.getOneTask(context, widget.id);
                      }, // Icon inside FAB
                      backgroundColor: const Color(AppColors.primary), // Optional: change color
                      tooltip: 'Add',
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/svg/edit.svg",
                          color: AppThemeService.colorPalette.fabIconColor.color,
                          width: AppSizes.s16,
                          height: AppSizes.s16,
                        ),
                      ),
                    ) ,
                  ),
                ): null : null,
                body: value.getOneTaskModel == null || value.getOneTaskModel!.task == null  ?
                const EmployeeDetailsLoadingWidget():RefreshIndicator.adaptive(
                  onRefresh: ()async{
                    await value.getOneTask(context, widget.id);
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaskDetailsHeaderWidget(
                          taskName: value.getOneTaskModel!.task!.title?.toString(),
                          taskDate: value.getOneTaskModel!.task!.dueDate?.toString() ?? "",
                          taskCreatedAt: value.getOneTaskModel!.task!.createAt?.toString() ?? "",
                          assets: icon['value'],

                        ),
                        Padding(padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20,),
                                  Text(
                                    "${(value.getOneTaskModel!.task!.progress! % 1 == 0 ? value.getOneTaskModel!.task!.progress!.toInt().toString() : value.getOneTaskModel!.task!.progress!.toStringAsFixed(1))}% ${AppStrings.ofTaskHasBeenCompleted.tr()}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      color: Color(0xff31394D),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  LinearProgressIndicator(
                                    color: const Color(AppColors.primary),
                                    value: (value.getOneTaskModel!.task!.progress ?? 0) / 100,
                                    borderRadius: BorderRadius.circular(5),
                                    backgroundColor: Colors.transparent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20,),
                              Text(AppStrings.description.tr(),
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(AppColors.primary)),
                              ),
                              const SizedBox(height: 10,),
                              Text(
                                value.getOneTaskModel!.task!.content!,
                                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(AppColors.textC4)),
                              ),
                              const SizedBox(height: 20,),
                              ListView.separated(
                                  padding: EdgeInsets.zero,
                                  reverse: false,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final iconName = value.getOneTaskModel!.task!.icon;
                                    final icon = value.iconsName.firstWhere(
                                          (item) => item["name"] == iconName,
                                      orElse: () => {"value": "assets/images/svg/t3.svg"}, // مسار افتراضي لو لم يوجد
                                    );
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
                                                SvgPicture.asset(icon['value']!),
                                                const SizedBox(width: 12,),
                                                SizedBox(
                                                    width: MediaQuery.sizeOf(context).width * 0.6,
                                                    child: Text(value.getOneTaskModel!.task!.subTasks![index].name ?? "",
                                                      style: const TextStyle(color: Color(AppColors.dark),fontSize: 12,fontWeight: FontWeight.w600),)),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              onTap: (){
                                                setState(() {
                                                  indexSelect = index;
                                                  value.getOneTaskModel!.task!.subTasks![index].status = !value.getOneTaskModel!.task!.subTasks![index].status!;
                                                });
                                                value.updateSubTask(context,
                                                  content: value.getOneTaskModel!.task!.content.toString(),
                                                  assign: value.getOneTaskModel!.task!.assignTo,
                                                  due: value.getOneTaskModel!.task!.dueDate,
                                                  icon: value.getOneTaskModel!.task!.icon.toString(),
                                                  id: value.getOneTaskModel!.task!.id,
                                                  status: value.getOneTaskModel!.task!.status.toString(),
                                                  subTask: value.getOneTaskModel!.task!.subTasks,
                                                  title: value.getOneTaskModel!.task!.title.toString(),
                                                );
                                              },
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: const Color(AppColors.primary)),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: indexSelect == index && value.isUpdateLoading == true?
                                                const CircularProgressIndicator()
                                                    :Container(
                                                  decoration: BoxDecoration(
                                                    color: value.getOneTaskModel!.task!.subTasks![index].status == true ?const Color(AppColors.primary) : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, index) => const SizedBox(height: 15,),
                                  itemCount: value.getOneTaskModel!.task!.subTasks!.length),
                              const SizedBox(height: 15,),
                              if(value.getOneTaskModel!.task!.status == "open")GestureDetector(
                                onTap: (){
                                  value.updateStatusTask(context, value.getOneTaskModel!.task!.id);
                                },
                                child: Container(
                                  padding: EdgeInsets.only(
                                      left: LocalizationService.isArabic(context: context) ?0 :15,
                                      right: LocalizationService.isArabic(context: context) ?15 :0
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff09814D),
                                    borderRadius: BorderRadius.circular(5),

                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(padding: EdgeInsets.symmetric(vertical: 10),
                                        child: Text(AppStrings.closeMainTask.tr(),
                                          style: const TextStyle(color: Color(0xffFFFFFF),fontSize: 12,fontWeight: FontWeight.w600),),
                                      ),
                                      const Spacer(),
                                      Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.symmetric(horizontal: 5 ,vertical: 15),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.only(
                                              topRight: LocalizationService.isArabic(context: context) ?const Radius.circular(0) : const Radius.circular(4) ,
                                              bottomRight: LocalizationService.isArabic(context: context) ?const Radius.circular(0) : const Radius.circular(4) ,
                                              topLeft: LocalizationService.isArabic(context: context) ?const Radius.circular(5) : const Radius.circular(0) ,
                                              bottomLeft: LocalizationService.isArabic(context: context) ?const Radius.circular(5) : const Radius.circular(0) ,
                                            )
                                        ),
                                        child: (value.isLoading == true)? const CircularProgressIndicator(color: Colors.white,):Icon(Icons.check, color: Colors.white,),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(strokeAlign: 1, color: Color(0xffDFDFDF))
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(AppStrings.lastedComments.tr().toUpperCase(), style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w500, color: Color(AppColors.dark))),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(strokeAlign: 1, color: Color(0xffDFDFDF))
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10,),
                              CommentsWidget(
                                  "tasks",
                                  enable: "enable",
                                  comments: values.comments,
                                  pageNumber:  values.pageNumber,
                                  loading: values.isGetCommentLoading,
                                  scrollController: _scrollController,
                                  id : widget.id
                              ),
                              const SizedBox(height: 15,),

                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
          },);
        },
      ),
    );
  }
}
