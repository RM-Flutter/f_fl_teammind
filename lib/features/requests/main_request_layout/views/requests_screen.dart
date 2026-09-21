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
import 'package:app_test/core/services/general_listener.dart';
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
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/features/requests/details/views/widgets/management_response_widget.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'dart:convert';

import 'package:app_test/core/widgets/approvable_card_widget.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String? jsonString = CacheHelper.getString("USG");
      if (jsonString != null && jsonString.isNotEmpty) {
        Map<String, dynamic> gCache = json.decode(jsonString);
        final popups = gCache['popups'];
        if (popups != null && popups.isNotEmpty) {
          GeneralListener().startAll(context, "requests", popups);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    
    // Clear filter state when exiting the screen
    CacheHelper.deleteData(key: "reqId");
    CacheHelper.deleteData(key: "empId");
    CacheHelper.deleteData(key: "from");
    CacheHelper.deleteData(key: "to");
    CacheHelper.deleteData(key: "depId");
    CacheHelper.deleteData(key: "selectStatus");

    super.dispose();
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
                    final result = await context.pushNamed(AppRoutes.addRequest.name, pathParameters: {
                      'type': 'mine',
                      'lang': context.locale.languageCode
                    });
                    
                    if (result == true) {
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
                    }
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

                            bool hasRequests =
                                (viewModel.requests?.isNotEmpty == true) ||
                                    (viewModel.myTeamRequests?.isNotEmpty == true) ||
                                    (viewModel.otherDepartmentRequestModel?.isNotEmpty == true) ||
                                    (viewModel.allCompanyRequests?.isNotEmpty == true);

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
                                        widget.requestsType == GetRequestsTypes.otherDepartment ||
                                        widget.requestsType == GetRequestsTypes.allCompany)
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
                                              : (widget.requestsType == GetRequestsTypes.otherDepartment)
                                              ? viewModel.otherDepartmentRequestModel
                                              : viewModel.allCompanyRequests,
                                        ),
                                        title: widget.requestsType == GetRequestsTypes.otherDepartment
                                            ? AppStrings.otherDepartmentRequests.tr()
                                            : widget.requestsType == GetRequestsTypes.allCompany
                                                ? AppStrings.allCompanyRequests.tr()
                                                : AppStrings.viewTeamRequestsOnCalendar.tr(),
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
                                            (req) => ApprovableCardWidget(
                                          request: req,
                                          isForDepartment: widget.requestsType != null && widget.requestsType != GetRequestsTypes.mine,
                                          onActionTaken: () {
                                            viewModel.currentPage = 1;
                                            viewModel.initializeRequestsScreen(
                                                context: context,
                                                requestsType: widget.requestsType!,
                                                requestTypeId: CacheHelper.getString("reqId"),
                                                empIds: CacheHelper.getString("empId"),
                                                from: CacheHelper.getString("from"),
                                                to: CacheHelper.getString("to"),
                                                status: CacheHelper.getString("status"),
                                                depId: CacheHelper.getString("depId"));
                                          },
                                          onLongPress: () async {
                                            var jsonString = CacheHelper.getString("US1");
                                            UserSettingsModel? userSettings;
                                            if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                                              var gCache = json.decode(jsonString) as Map<String, dynamic>;
                                              userSettings = UserSettingsModel.fromJson(gCache);
                                            }
                                            final bool canShowManagementResponse =
                                                (widget.requestsType == GetRequestsTypes.myTeam || widget.requestsType == GetRequestsTypes.otherDepartment || widget.requestsType == GetRequestsTypes.allCompany) &&
                                                    (req.status == 'waiting_seen' || req.status == 'waiting_cancel' || req.status == 'waiting') &&
                                                    req.id != null &&
                                                    (userSettings?.empId != null && req.employeeId != null && userSettings!.empId != req.employeeId);
                                            
                                            if (canShowManagementResponse) {
                                              await ModalSheetHelper.showModalSheet(
                                                context: context,
                                                viewProfile: false,
                                                modalContent: ManagementResponseModal(
                                                  requestId: req.id.toString(),
                                                ),
                                                title: AppStrings.managementResponse.tr(),
                                                height: LayoutService.getHeight(context) * 0.5,
                                              );
                                            }
                                          },
                                          onTap: () async {
                                            if (widget.requestsType == null || widget.requestsType == GetRequestsTypes.mine) {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req ?? [],
                                                pathParameters: {
                                                  'lang': context.locale.languageCode,
                                                  'id': req!.id.toString(),
                                                  'type': widget.requestsType != null ? widget.requestsType!.name : "me",
                                                },
                                              );
                                            } else {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req,
                                                pathParameters: {
                                                  'type': widget.requestsType!.name,
                                                  'id': req!.id.toString(),
                                                  'lang': context.locale.languageCode
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),

                                    if (viewModel.otherDepartmentRequestModel != null &&
                                        viewModel.otherDepartmentRequestModel!.isNotEmpty &&
                                        widget.requestsType == GetRequestsTypes.otherDepartment)
                                      ...viewModel.otherDepartmentRequestModel!.map(
                                            (req) => ApprovableCardWidget(
                                          request: req,
                                          isForDepartment: widget.requestsType != null && widget.requestsType != GetRequestsTypes.mine,
                                          onActionTaken: () {
                                            viewModel.currentPage = 1;
                                            viewModel.initializeRequestsScreen(
                                                context: context,
                                                requestsType: widget.requestsType!,
                                                requestTypeId: CacheHelper.getString("reqId"),
                                                empIds: CacheHelper.getString("empId"),
                                                from: CacheHelper.getString("from"),
                                                to: CacheHelper.getString("to"),
                                                status: CacheHelper.getString("status"),
                                                depId: CacheHelper.getString("depId"));
                                          },
                                          onLongPress: () async {
                                            var jsonString = CacheHelper.getString("US1");
                                            UserSettingsModel? userSettings;
                                            if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                                              var gCache = json.decode(jsonString) as Map<String, dynamic>;
                                              userSettings = UserSettingsModel.fromJson(gCache);
                                            }
                                            final bool canShowManagementResponse =
                                                (widget.requestsType == GetRequestsTypes.myTeam || widget.requestsType == GetRequestsTypes.otherDepartment || widget.requestsType == GetRequestsTypes.allCompany) &&
                                                    (req.status == 'waiting_seen' || req.status == 'waiting_cancel' || req.status == 'waiting') &&
                                                    req.id != null &&
                                                    (userSettings?.empId != null && req.employeeId != null && userSettings!.empId != req.employeeId);
                                            
                                            if (canShowManagementResponse) {
                                              await ModalSheetHelper.showModalSheet(
                                                context: context,
                                                viewProfile: false,
                                                modalContent: ManagementResponseModal(
                                                  requestId: req.id.toString(),
                                                ),
                                                title: AppStrings.managementResponse.tr(),
                                                height: LayoutService.getHeight(context) * 0.5,
                                              );
                                            }
                                          },
                                          onTap: () async {
                                            if (widget.requestsType == null || widget.requestsType == GetRequestsTypes.mine) {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req ?? [],
                                                pathParameters: {
                                                  'lang': context.locale.languageCode,
                                                  'id': req!.id.toString(),
                                                  'type': widget.requestsType != null ? widget.requestsType!.name : "me",
                                                },
                                              );
                                            } else {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req,
                                                pathParameters: {
                                                  'type': widget.requestsType!.name,
                                                  'id': req!.id.toString(),
                                                  'lang': context.locale.languageCode
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),

                                    if (viewModel.allCompanyRequests != null &&
                                        viewModel.allCompanyRequests!.isNotEmpty &&
                                        widget.requestsType == GetRequestsTypes.allCompany)
                                      ...viewModel.allCompanyRequests!.map(
                                            (req) => ApprovableCardWidget(
                                          request: req,
                                          isForDepartment: widget.requestsType != null && widget.requestsType != GetRequestsTypes.mine,
                                          onActionTaken: () {
                                            viewModel.currentPage = 1;
                                            viewModel.initializeRequestsScreen(
                                                context: context,
                                                requestsType: widget.requestsType!,
                                                requestTypeId: CacheHelper.getString("reqId"),
                                                empIds: CacheHelper.getString("empId"),
                                                from: CacheHelper.getString("from"),
                                                to: CacheHelper.getString("to"),
                                                status: CacheHelper.getString("status"),
                                                depId: CacheHelper.getString("depId"));
                                          },
                                          onLongPress: () async {
                                            var jsonString = CacheHelper.getString("US1");
                                            UserSettingsModel? userSettings;
                                            if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                                              var gCache = json.decode(jsonString) as Map<String, dynamic>;
                                              userSettings = UserSettingsModel.fromJson(gCache);
                                            }
                                            final bool canShowManagementResponse =
                                                (widget.requestsType == GetRequestsTypes.myTeam || widget.requestsType == GetRequestsTypes.otherDepartment || widget.requestsType == GetRequestsTypes.allCompany) &&
                                                    (req.status == 'waiting_seen' || req.status == 'waiting_cancel' || req.status == 'waiting') &&
                                                    req.id != null &&
                                                    (userSettings?.empId != null && req.employeeId != null && userSettings!.empId != req.employeeId);
                                            
                                            if (canShowManagementResponse) {
                                              await ModalSheetHelper.showModalSheet(
                                                context: context,
                                                viewProfile: false,
                                                modalContent: ManagementResponseModal(
                                                  requestId: req.id.toString(),
                                                ),
                                                title: AppStrings.managementResponse.tr(),
                                                height: LayoutService.getHeight(context) * 0.5,
                                              );
                                            }
                                          },
                                          onTap: () async {
                                            if (widget.requestsType == null || widget.requestsType == GetRequestsTypes.mine) {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req ?? [],
                                                pathParameters: {
                                                  'lang': context.locale.languageCode,
                                                  'id': req!.id.toString(),
                                                  'type': widget.requestsType != null ? widget.requestsType!.name : "me",
                                                },
                                              );
                                            } else {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req,
                                                pathParameters: {
                                                  'type': widget.requestsType!.name,
                                                  'id': req!.id.toString(),
                                                  'lang': context.locale.languageCode
                                                },
                                              );
                                            }
                                          },
                                        ),
                                      ),

                                    if (viewModel.myTeamRequests != null &&
                                        viewModel.myTeamRequests!.isNotEmpty &&
                                        widget.requestsType == GetRequestsTypes.myTeam)
                                      ...viewModel.myTeamRequests!.map(
                                            (req) => ApprovableCardWidget(
                                          request: req,
                                          isForDepartment: widget.requestsType != null && widget.requestsType != GetRequestsTypes.mine,
                                          onActionTaken: () {
                                            viewModel.currentPage = 1;
                                            viewModel.initializeRequestsScreen(
                                                context: context,
                                                requestsType: widget.requestsType!,
                                                requestTypeId: CacheHelper.getString("reqId"),
                                                empIds: CacheHelper.getString("empId"),
                                                from: CacheHelper.getString("from"),
                                                to: CacheHelper.getString("to"),
                                                status: CacheHelper.getString("status"),
                                                depId: CacheHelper.getString("depId"));
                                          },
                                          onLongPress: () async {
                                            var jsonString = CacheHelper.getString("US1");
                                            UserSettingsModel? userSettings;
                                            if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
                                              var gCache = json.decode(jsonString) as Map<String, dynamic>;
                                              userSettings = UserSettingsModel.fromJson(gCache);
                                            }
                                            final bool canShowManagementResponse =
                                                (widget.requestsType == GetRequestsTypes.myTeam || widget.requestsType == GetRequestsTypes.otherDepartment || widget.requestsType == GetRequestsTypes.allCompany) &&
                                                    (req.status == 'waiting_seen' || req.status == 'waiting_cancel' || req.status == 'waiting') &&
                                                    req.id != null &&
                                                    (userSettings?.empId != null && req.employeeId != null && userSettings!.empId != req.employeeId);
                                            
                                            if (canShowManagementResponse) {
                                              await ModalSheetHelper.showModalSheet(
                                                context: context,
                                                viewProfile: false,
                                                modalContent: ManagementResponseModal(
                                                  requestId: req.id.toString(),
                                                ),
                                                title: AppStrings.managementResponse.tr(),
                                                height: LayoutService.getHeight(context) * 0.5,
                                              );
                                            }
                                          },
                                          onTap: () async {
                                            if (widget.requestsType == null || widget.requestsType == GetRequestsTypes.mine) {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req ?? [],
                                                pathParameters: {
                                                  'lang': context.locale.languageCode,
                                                  'id': req!.id.toString(),
                                                  'type': widget.requestsType != null ? widget.requestsType!.name : "me",
                                                },
                                              );
                                            } else {
                                              await context.pushNamed(
                                                AppRoutes.requestDetails.name,
                                                extra: req,
                                                pathParameters: {
                                                  'type': widget.requestsType!.name,
                                                  'id': req!.id.toString(),
                                                  'lang': context.locale.languageCode
                                                },
                                              );
                                            }
                                          },
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
