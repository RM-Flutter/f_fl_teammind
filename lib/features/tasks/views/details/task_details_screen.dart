import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/widgets/comments/comments_widget.dart';
import 'package:app_test/core/widgets/comments/logic/controller.dart';
import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:app_test/features/tasks/controllers/tasks_controller.dart';
import 'package:app_test/features/tasks/views/details/widgets/task_details_header_widget.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  var id;
  TaskDetailsScreen({super.key, this.id,});

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
        ChangeNotifierProvider(create: (context) => TasksController()..getOneTask(context, widget.id),),
        ChangeNotifierProvider(create: (context) => CommentProvider()..getComment(context, "tasks",widget.id),)
      ],
      child: Consumer<TasksController>(
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
          final jsonString = CacheHelper.getString("US1");
          Map<String, dynamic>? gCache;
          if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
            gCache = json.decode(jsonString) as Map<String, dynamic>;
            UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
          }
          return Consumer<CommentProvider>(
            builder: (context, values, child) {
              return Scaffold(
                floatingActionButton: value.getOneTaskModel != null && gCache != null ?(gCache['is_teamleader_in'].isNotEmpty || gCache['is_manager_in'].isNotEmpty)?Padding(
                  padding: EdgeInsets.only(bottom: 0.05.sh),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: LocalizationService.isArabic(context: context) ? 35.w : 0),
                    width: 1.sw,
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton(
                      heroTag: 'task_details_edit',
                      onPressed: () async {
                        await context.pushNamed(AppRoutes.editTaskScreen.name, pathParameters: {
                          'lang': context.locale.languageCode,
                          'id' : value.getOneTaskModel!.task!.id.toString()
                        });
                        await value.getOneTask(context, widget.id);
                      }, // Icon inside FAB
                      backgroundColor: Color(AppColors.buttons), // Optional: change color
                      tooltip: 'Add',
                      child: Center(
                        child: SvgPicture.asset(
                          "assets/images/svg/edit.svg",
                          color: AppThemeService.colorPalette.fabIconColor.color,
                          width: AppSizes.s16.r,
                          height: AppSizes.s16.r,
                        ),
                      ),
                    ) ,
                  ),
                ): null : null,
                body: value.getOneTaskModel == null || value.getOneTaskModel!.task == null  ?
                const DetailsLoadingWidget():RefreshIndicator.adaptive(
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
                        Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxWidth: kIsWeb ? 800.w : double.infinity
                            ),
                            child: Padding(padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 20.h,),
                                      Text(
                                        "${(value.getOneTaskModel!.task!.progress! % 1 == 0 ? value.getOneTaskModel!.task!.progress!.toInt().toString() : value.getOneTaskModel!.task!.progress!.toStringAsFixed(1))}% ${AppStrings.ofTaskHasBeenCompleted.tr()}",
                                        style: AppStyles.blackContent(context).copyWith(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: Color(AppColors.darkBlueGrey),
                                        ),
                                      ),
                                      SizedBox(height: 10.h,),
                                      LinearProgressIndicator(
                                        color: Color(AppColors.buttons),
                                        value: (value.getOneTaskModel!.task!.progress ?? 0) / 100,
                                        borderRadius: BorderRadius.circular(5.r),
                                        backgroundColor: Colors.transparent,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 20.h,),
                                  Text(
                                    AppStrings.description.tr().toUpperCase(),
                                    style: AppStyles.primaryContent(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp),
                                  ),
                                  SizedBox(height: 10.h,),
                                  Text(
                                    value.getOneTaskModel!.task!.content!,
                                    style: AppStyles.greyContent(context).copyWith(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 13.sp,
                                        color: Color(0xff606060)),
                                  ),
                                  SizedBox(height: 20.h,),
                                  ListView.separated(
                                    padding: EdgeInsets.zero,
                                    reverse: false,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final subTask = value.getOneTaskModel!.task!.subTasks![index];
                                      final isCompleted = subTask.status == true;
                                      final iconName = value.getOneTaskModel!.task!.icon;
                                      final icon = value.iconsName.firstWhere(
                                        (item) => item["name"] == iconName,
                                        orElse: () => {"value": "assets/images/svg/t3.svg"},
                                      );

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            indexSelect = index;
                                            subTask.status = !subTask.status!;
                                          });
                                          value.updateSubTask(
                                            context,
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
                                        child: IntrinsicHeight(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.zero,
                                              border: Border.all(
                                                color: isCompleted
                                                    ?  (Color(AppColors.buttons))
                                                    : Color(AppColors.border),
                                                width: 1.r,
                                              ),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                                                  child: SvgPicture.asset(
                                                    icon['value']!,
                                                    width: 24.r,
                                                    height: 24.r,
                                  colorFilter: isCompleted
                                      ?  ColorFilter.mode((Color(AppColors.buttons)), BlendMode.srcIn)
                                      : null,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 12.h),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          subTask.name?.toUpperCase() ?? "",
                                                          style: AppStyles.heading(context).copyWith(
                                                            color: isCompleted
                                                                ? Color(AppColors.secondaryButton)
                                                                : Color(AppColors.secondaryButton),
                                                            fontSize: 13.sp,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Text(
                                                          "${value.getOneTaskModel!.task!.createAt != null ? locale.DateFormat('yyyy-MM-dd').format(DateTime.parse(value.getOneTaskModel!.task!.createAt!)) : ""} : ${value.getOneTaskModel!.task!.dueDate != null ? locale.DateFormat('yyyy-MM-dd').format(DateTime.parse(value.getOneTaskModel!.task!.dueDate!)) : ""}",
                                                          style: AppStyles.greyContent(context).copyWith(
                                                            color: Color(0xff606060).withOpacity(0.7),
                                                            fontSize: 10.sp,
                                                            fontWeight: FontWeight.w400,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (isCompleted)
                                                  Container(
                                                    width: 40.w,
                                                    decoration:  BoxDecoration(
                                                      color: (Color(AppColors.buttons)),
                                                      borderRadius: BorderRadius.zero,
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.check,
                                                        color: Colors.white,
                                                        size: 20.r,
                                                      ),
                                                    ),
                                                  )
                                                else if (indexSelect == index && value.isUpdateLoading == true)
                                                  SizedBox(
                                                    width: 40.w,
                                                    child: Center(
                                                      child: SizedBox(
                                                        width: 20.r,
                                                        height: 20.r,
                                                        child: const CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    width: 40.w,
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      width: 20.r,
                                                      height: 20.r,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        border: Border.all(color:  (Color(AppColors.buttons)), width: 1.5.r),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) => SizedBox(height: 15.h),
                                    itemCount: value.getOneTaskModel!.task!.subTasks!.length,
                                  ),
                                  SizedBox(height: 15.h,),
                                  if(value.getOneTaskModel!.task!.status == "open")GestureDetector(
                                    onTap: (){
                                      value.updateStatusTask(context, value.getOneTaskModel!.task!.id);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: LocalizationService.isArabic(context: context) ?0 :15.w,
                                          right: LocalizationService.isArabic(context: context) ?15.w :0
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color(AppColors.green),
                                        borderRadius: BorderRadius.circular(5.r),

                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(padding: EdgeInsets.symmetric(vertical: 10.h),
                                            child: Text(AppStrings.closeMainTask.tr(),
                                              style: AppStyles.whiteContent(context).copyWith(fontSize: 12.sp,fontWeight: FontWeight.w600),),
                                          ),
                                          const Spacer(),
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(horizontal: 5.w ,vertical: 15.h),
                                            decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.only(
                                                  topRight: LocalizationService.isArabic(context: context) ?const Radius.circular(0) : Radius.circular(4.r) ,
                                                  bottomRight: LocalizationService.isArabic(context: context) ?const Radius.circular(0) : Radius.circular(4.r) ,
                                                  topLeft: LocalizationService.isArabic(context: context) ?Radius.circular(5.r) : const Radius.circular(0) ,
                                                  bottomLeft: LocalizationService.isArabic(context: context) ?Radius.circular(5.r) : const Radius.circular(0) ,
                                                )
                                            ),
                                            child: (value.isLoading == true)? SizedBox(width: 24.r, height: 24.r, child: const CircularProgressIndicator(color: Colors.white,)):Icon(Icons.check, color: Colors.white, size: 24.r,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.h,),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(strokeAlign: 1, color: Color(AppColors.divider))
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(AppStrings.comments.tr().toUpperCase(), style: AppStyles.primaryContent(context).copyWith(fontSize: 14.sp,
                                          fontWeight: FontWeight.bold)),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(strokeAlign: 1, color: Color(AppColors.divider))
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10.h,),
                                  CommentsWidget(
                                      "tasks",
                                      enable: "enable",
                                      comments: values.comments,
                                      pageNumber:  values.pageNumber,
                                      loading: values.isGetCommentLoading,
                                      scrollController: _scrollController,
                                      id : widget.id
                                  ),
                                  SizedBox(height: 15.h,),

                                ],
                              ),
                            ),
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