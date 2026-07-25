import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_theme_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/loading_page.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/widgets/vocation_list.widget.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/request_card.dart';
import 'package:app_test/features/requests/main_request_layout/controller/filter_controller.dart';
import 'package:app_test/features/requests/main_request_layout/controller/requests_controller.dart';
import 'package:app_test/features/requests/main_request_layout/views/widgets/active_filters_widget.dart';
import 'package:app_test/features/requests/main_request_layout/views/widgets/search_filter_widget.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/ui/widgets/custom_requests_page_button.widget.dart';
import 'widgets/loading_appbar_loading_widget.dart';

class RequestsScreen extends StatefulWidget {
  final GetRequestsTypes? requestsType;
  const RequestsScreen({super.key, this.requestsType = GetRequestsTypes.mine});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  late final RequestsViewModel viewModel;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    viewModel = RequestsViewModel();

    // Read filter state from CacheHelper (may be restored from bookmark)
    final reqId = CacheHelper.getString("reqId");
    final empId = CacheHelper.getString("empId");
    final from = CacheHelper.getString("from");
    final to = CacheHelper.getString("to");
    final depId = CacheHelper.getString("depId");
    final selectStatus = CacheHelper.getString("selectStatus");

    viewModel.initializeRequestsScreen(
        context: context,
        requestsType: widget.requestsType ?? GetRequestsTypes.mine,
        requestTypeId: reqId.isNotEmpty ? reqId : null,
        empIds: empId.isNotEmpty ? empId : null,
        from: from.isNotEmpty ? from : null,
        to: to.isNotEmpty ? to : null,
        depId: depId.isNotEmpty ? depId : null,
        status: selectStatus.isNotEmpty ? selectStatus : null);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !viewModel.isLoadingMore &&
          viewModel.hasMore) {
        viewModel.initializeRequestsScreen(
            context: context,
            requestsType:widget.requestsType??  GetRequestsTypes.mine,
            loadMore: true,
            requestTypeId: CacheHelper.getString("reqId"),
            empIds: CacheHelper.getString("empId"),
            from: CacheHelper.getString("from"),
            to: CacheHelper.getString("to"),
            depId: CacheHelper.getString("depId"),
            status: CacheHelper.getString("selectStatus"));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RequestsViewModel>.value(value: viewModel),
        ChangeNotifierProvider(create: (context) => FilterController()..getDepartment(context: context)..getRequestTypes(context: context)..getEmployees(context: context)),
      ],
      child: TemplatePage(
          pageContext: context,
          routeName: AppRoutes.requests.name,
          floatingActionButton: Container(
            padding: EdgeInsets.symmetric(horizontal: LocalizationService.isArabic(context: context) ? 35 : 0),
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'requests_add',
                  onPressed: () async {
                    await context.pushNamed(AppRoutes.addRequest.name, pathParameters: {
                      'type': 'mine',
                      'lang': context.locale.languageCode
                    });
                  }, // Icon inside FAB
                  backgroundColor: Color(AppColors.buttons), // Optional: change color
                  tooltip: 'Add',
                  child: Center(
                    child: Image.asset(
                      AppImages.addFloatingActionButtonIcon,
                      color: AppThemeService.colorPalette.fabIconColor.color,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                FloatingActionButton(
                  heroTag: 'requests_calendar',
                  onPressed: ()async {
                    final Map<String, String?>? filterResult;
                    if (kIsWeb) {
                      // Use showDialog for web to ensure it's fully visible
                      filterResult = await showDialog<Map<String, String?>>(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext dialogContext) {
                          final screenHeight = MediaQuery.of(dialogContext).size.height;
                          final screenWidth = MediaQuery.of(dialogContext).size.width;
                          return Dialog(
                            alignment: Alignment.center,
                            insetPadding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.15,
                              vertical: screenHeight * 0.1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(35),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: screenHeight * 0.8,
                                maxWidth: 600,
                              ),
                              child: SearchFilterWidget(
                                contexts: dialogContext,
                                requestsType: widget.requestsType,
                                isWeb: true,
                                // underMyManagement: true,
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      // Use showModalBottomSheet for mobile
                      filterResult = await showModalBottomSheet<Map<String, String?>>(
                        context: context,
                        isScrollControlled: true,
                        enableDrag: false,
                        isDismissible: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.vertical(
                              top: Radius.circular(
                                  35)),
                        ),
                        builder: (BuildContext context) {
                          return SearchFilterWidget(
                            contexts: context,
                            requestsType: widget.requestsType,
                            isWeb: false,
                            // underMyManagement: true,
                          );
                        },
                      );
                    }
                    if (filterResult != null) {
                      final _v = (String? s) => (s == null || s.isEmpty) ? null : s;
                      viewModel.initializeRequestsScreen(
                        context: context,
                        requestsType: widget.requestsType!,
                        requestTypeId: _v(filterResult['reqId']),
                        empIds: _v(filterResult['empId']),
                        from: _v(filterResult['from']),
                        to: _v(filterResult['to']),
                        depId: _v(filterResult['depId']),
                        status: _v(filterResult['selectStatus']),
                      );
                      // مزامنة الكاش مع نتيجة الفلتر حتى لا يرسل التمرير/التحديث الـ id من قيمة قديمة
                      final _sync = (String key, String? value) async {
                        if (value == null || value.isEmpty) {
                          await CacheHelper.deleteData(key: key);
                        } else {
                          await CacheHelper.setString(key: key, value: value);
                        }
                      };
                      await _sync("reqId", filterResult['reqId']);
                      await _sync("empId", filterResult['empId']);
                      await _sync("depId", filterResult['depId']);
                      await _sync("selectStatus", filterResult['selectStatus']);
                      await _sync("from", filterResult['from']);
                      await _sync("to", filterResult['to']);
                    } else {
                      viewModel.initializeRequestsScreen(
                        context: context,
                        requestsType: widget.requestsType!,
                        requestTypeId: CacheHelper.getString("reqId").isEmpty ? null : CacheHelper.getString("reqId"),
                        empIds: CacheHelper.getString("empId"),
                        from: CacheHelper.getString("from"),
                        to: CacheHelper.getString("to"),
                        depId: CacheHelper.getString("depId"),
                        status: CacheHelper.getString("selectStatus"),
                      );
                    }
                  },
                  backgroundColor: Color(AppColors.buttons), // Optional: change color
                  tooltip: 'Filter',
                  child: Center(
                    child: Image.asset(
                      "assets/images/png/filter.png",
                      color: AppThemeService.colorPalette.fabIconColor.color,
                      width: 16,
                      height: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomAppbarWidget: widget.requestsType == GetRequestsTypes.mine
              ? PreferredSize(
            preferredSize: const Size.fromHeight(170),
            child: Consumer<RequestsViewModel>(
                builder: (context, viewModel, child) => Padding(
                  padding: const EdgeInsets.only(
                      left: 12,
                      right: 12,
                      top: 10),
                  child: viewModel.isLoading
                      ? const RequestsAppbarLoading()
                      : VacationListWidget(
                    isInRequestsPage: true,
                    tap: true,
                    requests: viewModel.requests,
                  ),
                )),
          )
              : null,
          title: viewModel.getRequestsScreenTitleDependsOnRequestsType(
              requestsType: widget.requestsType!),
          onRefresh: () async {
            viewModel.currentPage = 1;
            viewModel.initializeRequestsScreen(
                context: context,
                requestsType: widget.requestsType!,
                requestTypeId: CacheHelper.getString("reqId"),
                empIds: CacheHelper.getString("empId"),
                from: CacheHelper.getString("from"),
                to: CacheHelper.getString("to"),
                depId: CacheHelper.getString("depId"),
                status: CacheHelper.getString("selectStatus"));
          },
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100 : 1.sw
              ),
              child: Container(
                alignment: Alignment.topCenter,
                height: 1.sh,
                child: Column(
                  children: [
                    // Active Filters Widget at the top - only show if there are active filters
                    Consumer<RequestsViewModel>(
                      builder: (context, viewModel, child) {
                        if (ActiveFiltersWidget.hasActiveFilters()) {
                          return ActiveFiltersWidget(
                            requestsType: widget.requestsType,
                            viewModel: viewModel,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    // Main content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Consumer<RequestsViewModel>(
                          builder: (context, viewModel, child) {
                            if (viewModel.isLoading) return const LoadingPageWidget();

                            final hasRequests =
                                (viewModel.requests?.isNotEmpty == true) ||
                                    (viewModel.myTeamRequests?.isNotEmpty == true) ||
                                    (viewModel.otherDepartmentRequestModel?.isNotEmpty == true);

                            if (!hasRequests) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (viewModel.rulesMessage != null)
                                    AutoSizeText(
                                      viewModel.rulesMessage ?? "",
                                      style: AppStyles.greyContent(context).copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 10,
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                    ),
                                  NoExistingPlaceholderScreen(
                                    height: 0.6.sh,
                                    title: AppStrings.thereIsNoRequests.tr(),
                                  ),
                                ],
                              );
                            }

                            return RefreshIndicator.adaptive(
                              onRefresh: () async {
                                viewModel.currentPage = 1;
                                viewModel.initializeRequestsScreen(
                                    context: context,
                                    requestsType: widget.requestsType!,
                                    requestTypeId: CacheHelper.getString("reqId"),
                                    empIds: CacheHelper.getString("empId"),
                                    from: CacheHelper.getString("from"),
                                    to: CacheHelper.getString("to"),
                                    depId: CacheHelper.getString("depId"),
                                    status: CacheHelper.getString("selectStatus"));
                              },
                              child: Container(
                                alignment: Alignment.topCenter,
                                height: 0.9.sh,
                                child: ListView(
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  children: [
                                    /// calendar button
                                    if (widget.requestsType == GetRequestsTypes.myTeam ||
                                        widget.requestsType == GetRequestsTypes.otherDepartment)
                                      CustomRequestsPageButton(
                                        onPressed: () async => await context.pushNamed(
                                          AppRoutes.requestsCalendar.name,
                                          pathParameters: {
                                            'type': widget.requestsType?.name ?? 'mine',
                                            'lang': context.locale.languageCode,
                                          },
                                          extra: widget.requestsType == GetRequestsTypes.mine
                                              ? viewModel.requests
                                              : (widget.requestsType == GetRequestsTypes.myTeam)
                                              ? viewModel.myTeamRequests
                                              : viewModel.otherDepartmentRequestModel,
                                        ),
                                        title: AppStrings.viewTeamRequestsOnCalendar.tr(),
                                        icon: Icons.calendar_month_outlined,
                                      ),

                                    const SizedBox(height: 10),

                                    if (viewModel.rulesMessage != null && viewModel.rulesMessage != "")
                                      AutoSizeText(
                                        viewModel.rulesMessage ?? "",
                                        maxLines: 10,
                                        style: AppStyles.greyContent(context).copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),

                                    if (viewModel.rulesMessage != null && viewModel.rulesMessage != "")
                                      const SizedBox(height: 15),

                                    /// requests cards
                                    if (viewModel.requests != null &&
                                        viewModel.requests!.isNotEmpty &&
                                        widget.requestsType == GetRequestsTypes.mine)
                                      ...viewModel.requests!.map(
                                            (req) => RequestCard(
                                          reqType: widget.requestsType ?? GetRequestsTypes.mine,
                                          request: req,
                                        ),
                                      ),

                                    if (viewModel.otherDepartmentRequestModel != null &&
                                        viewModel.otherDepartmentRequestModel!.isNotEmpty &&
                                        widget.requestsType == GetRequestsTypes.otherDepartment)
                                      ...viewModel.otherDepartmentRequestModel!.map(
                                            (req) => RequestCard(
                                          reqType: widget.requestsType ?? GetRequestsTypes.mine,
                                          request: req,
                                        ),
                                      ),

                                    if (viewModel.myTeamRequests != null &&
                                        viewModel.myTeamRequests!.isNotEmpty &&
                                        widget.requestsType == GetRequestsTypes.myTeam)
                                      ...viewModel.myTeamRequests!.map(
                                            (req) => RequestCard(
                                          reqType: widget.requestsType ?? GetRequestsTypes.myTeam,
                                          request: req,
                                        ),
                                      ),
                                    if (viewModel.isLoadingMore)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(child: CircularProgressIndicator()),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}
