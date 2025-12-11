import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/controller/task_controller/task_view_model.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/modules/tasks/widget/task_calender_widget.dart';
import 'package:rmemp/modules/tasks/widget/task_list_tile_widget.dart';
import '../../../common_modules_widgets/loading_page.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../constants/app_images.dart';
import '../../../constants/app_sizes.dart';
import '../../../general_services/layout.service.dart';
import '../../../routing/app_router.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../../constants/user_consts.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  late final TaskViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = TaskViewModel();
    viewModel.getTask(context, date: null);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !viewModel.isLoadingMore &&
          viewModel.hasMore) {
        viewModel.getTask(context, loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString)
          as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    return ChangeNotifierProvider<TaskViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          backgroundColor: Colors.white,
          pageContext: context,
          actions: [Padding(
            padding: const EdgeInsets.all(AppSizes.s10),
            child: InkWell(
              onTap: (){
                viewModel.getTask(context, date: null);
              },
              child: Container(
                height: 35,
                width: 35,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(AppColors.dark)),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                  size: AppSizes.s18,
                ),
              ),
            ),
          )],
          floatingActionButton: (gCache['is_teamleader_in'].isNotEmpty ||
                  gCache['is_manager_in'].isNotEmpty)
              ? Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: LocalizationService.isArabic(context: context)
                          ? 35
                          : 0),
                  width: double.infinity,
                  alignment: Alignment.bottomRight,
                  child: FloatingActionButton(
                    onPressed: () async {
                      await context.pushNamed(
                          AppRoutes.addTaskScreen.name,
                          pathParameters: {
                            'lang': context.locale.languageCode
                          });
                      viewModel.currentPage = 1;
                      await viewModel.getTask(context, date: null);
                    },
                    backgroundColor: const Color(
                        AppColors.primary), // Optional: change color
                    tooltip: 'Add',
                    child: Center(
                      child: Image.asset(
                        AppImages.addFloatingActionButtonIcon,
                        color: AppThemeService.colorPalette.fabIconColor.color,
                        width: AppSizes.s16,
                        height: AppSizes.s16,
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
                maxWidth: kIsWeb ? 1100 : double.infinity,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
                    child: Consumer<TaskViewModel>(
                        builder: (context, viewModel, child) => viewModel.isLoading
                            ? const LoadingPageWidget(
                                reverse: true,
                                height: AppSizes.s75,
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    HorizontalCalendar(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    if (viewModel.tasks == null ||
                                        viewModel.tasks?.isEmpty == true)
                                      NoExistingPlaceholderScreen(
                                          height: LayoutService.getHeight(context) *
                                              0.6,
                                          title: AppStrings.thereIsNoTasks.tr()),
                                    if (viewModel.tasks != null &&
                                        viewModel.tasks?.isEmpty == false)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: SizedBox(
                                          height: MediaQuery.sizeOf(context).height * 0.7,
                                          child: ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            reverse: false,
                                            controller: _scrollController,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            itemBuilder: (context, index) {
                                              final iconName =
                                                  viewModel.tasks[index]["icon"];
                                              final icon = viewModel.iconsName.firstWhere(
                                                (item) => item["name"] == iconName,
                                                orElse: () => {
                                                  "value": "assets/images/svg/t3.svg"
                                                }, // مسار افتراضي لو لم يوجد
                                              );
                                              return TaskListTileWidget(
                                                onTap: ()async{
                                                  await context
                                                      .pushNamed(AppRoutes.taskDetails.name, pathParameters: {
                                                    'lang': context.locale.languageCode,
                                                    'id' : viewModel.tasks[index]['id'].toString(),
                                                  });
                                                  viewModel.currentPage = 1;
                                                 await viewModel.getTask(context, date: null);
                                                },
                                                complete: viewModel.tasks[index]
                                                            ['status'].toString(),
                                                assetName: icon['value']!,
                                                title: viewModel.tasks[index]
                                                    ['title'],
                                                id: viewModel.tasks[index]['id']
                                                    .toString(),
                                                date:
                                                viewModel.tasks[index]
                                                    ['dueDate'] ?? "",
                                                createdAt:viewModel.tasks[index]
                                                ['createdAt'] ?? ""
                                              );
                                            },
                                            itemCount: viewModel.tasks.length,
                                            separatorBuilder: (context, index) =>
                                                const SizedBox(
                                              height: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if(viewModel.isLoadingMore == true) CircularProgressIndicator()
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
