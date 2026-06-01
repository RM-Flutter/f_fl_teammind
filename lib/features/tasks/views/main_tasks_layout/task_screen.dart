import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/loading_page.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/tasks/controllers/tasks_controller.dart';
import 'package:app_test/features/tasks/views/main_tasks_layout/widgets/task_calender_widget.dart';
import 'package:app_test/features/tasks/views/main_tasks_layout/widgets/task_list_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TasksController viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = TasksController();
    viewModel.getTask(context, date: null);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    dynamic jsonString;
    dynamic gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString)
      as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<TasksController>(
      create: (_) => viewModel,
      child: TemplatePage(
          backgroundColor: Colors.white,
          pageContext: context,
          actions: [Padding(
            padding: EdgeInsets.all(AppSizes.s10.r),
            child: InkWell(
              onTap: (){
                viewModel.getTask(context, date: null);
              },
              child: Container(
                height: 35.r,
                width: 35.r,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppColors.secondaryButton)),
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: AppSizes.s18.r,
                ),
              ),
            ),
          )],
          floatingActionButton: (gCache['is_teamleader_in'].isNotEmpty ||
              gCache['is_manager_in'].isNotEmpty)
              ? Container(
            padding: EdgeInsets.symmetric(
                horizontal: LocalizationService.isArabic(context: context)
                    ? 35.w
                    : 0),
            width: 1.sw,
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              heroTag: 'tasks_add',
              onPressed: () async {
                await context.pushNamed(
                    AppRoutes.addTaskScreen.name,
                    pathParameters: {
                      'lang': context.locale.languageCode
                    });
                viewModel.currentPage = 1;
                await viewModel.getTask(context, date: null);
              },
              backgroundColor: Color(AppColors.buttons), // Optional: change color
              tooltip: 'Add',
              child: Center(
                child: Image.asset(
                  AppImages.addFloatingActionButtonIcon,
                  color: AppThemeService.colorPalette.fabIconColor.color,
                  width: AppSizes.s16.r,
                  height: AppSizes.s16.r,
                ),
              ),
            ),
          )
              : null,
          title: AppStrings.tasks.tr().toUpperCase(),
          onRefresh: () async {
            viewModel.currentPage = 1;
            viewModel.getTask(context);
          },
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100.w : double.infinity,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.s12.h),
                    child: Consumer<TasksController>(
                        builder: (context, viewModel, child) => viewModel.isLoading
                            ? const LoadingPageWidget(
                          reverse: true,
                          height: AppSizes.s75,
                        )
                            : SingleChildScrollView(
                          child: Column(
                            children: [
                              HorizontalCalendar(),
                              SizedBox(
                                height: 20.h,
                              ),
                              if (viewModel.tasks.isEmpty)
                                NoExistingPlaceholderScreen(
                                    height: 0.6.sh,
                                    title: AppStrings.thereIsNoTasks.tr()),
                              if (viewModel.tasks.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w),
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    reverse: false,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final iconName =
                                          viewModel.tasks[index]["icon"];
                                      final icon = viewModel.iconsName.firstWhere(
                                        (item) => item["name"] == iconName,
                                        orElse: () => {"value": "assets/images/svg/t3.svg"},
                                      );
                                      return TaskListTileWidget(
                                        onTap: () async {
                                          await context.pushNamed(
                                              AppRoutes.taskDetails.name,
                                              pathParameters: {
                                                'lang': context.locale.languageCode,
                                                'id': viewModel.tasks[index]['id']
                                                    .toString(),
                                              });
                                          viewModel.currentPage = 1;
                                          await viewModel.getTask(context,
                                              date: null);
                                        },
                                        complete: viewModel.tasks[index]['status']
                                            .toString(),
                                        assetName: icon['value']!,
                                        title: viewModel.tasks[index]['title'],
                                        id: viewModel.tasks[index]['id']
                                            .toString(),
                                        date: viewModel.tasks[index]['dueDate'] ??
                                            "",
                                        createdAt: viewModel.tasks[index]
                                                ['createdAt'] ??
                                            "",
                                      );
                                    },
                                    itemCount: viewModel.tasks.length,
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: 15.h),
                                  ),
                                ),
                              SizedBox(height: 20.h),
                              if (viewModel.hasMore && !viewModel.isLoadingMore)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 30.h),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        viewModel.getTask(context, loadMore: true);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(AppColors.secondaryButton),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 40.w, vertical: 12.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.r),
                                        ),
                                      ),
                                      child: Text(
                                        AppStrings.loadMore.tr().toUpperCase(),
                                        style: AppStyles.whiteContent(context).copyWith(fontWeight: FontWeight.bold, fontSize: 14.sp),
                                      ),
                                    ),
                                  ),
                                ),
                              if (viewModel.isLoadingMore)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 30.h),
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                              SizedBox(height: 20.h),
                            ],
                          ),
                        )),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}