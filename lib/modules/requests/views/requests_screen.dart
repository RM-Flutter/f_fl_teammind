import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_floating_action_button.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_images.dart';
import 'package:rmemp/general_services/app_theme.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/modules/requests/views/widgets/search_filter_widget.dart';
import '../../../common_modules_widgets/main_app_fab_widget/main_app_fab.widget.dart';
import '../../../common_modules_widgets/loading_page.widget.dart';
import '../../../common_modules_widgets/request_card.widget.dart';
import '../../../common_modules_widgets/template_page.widget.dart';
import '../../../common_modules_widgets/vocation_list.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/layout.service.dart';
import '../../../routing/app_router.dart';
import '../../../services/requests.services.dart';
import '../../../utils/general_screen_message_widget.dart';
import '../../../utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import '../view_models/requests.viewmodel.dart';
import 'widgets/custom_requests_page_button.widget.dart';
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
    viewModel.initializeRequestsScreen(
        context: context,
        requestsType:widget.requestsType??  GetRequestsTypes.mine);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !viewModel.isLoadingMore &&
          viewModel.hasMore) {
        viewModel.initializeRequestsScreen(
            context: context,
            requestsType:widget.requestsType??  GetRequestsTypes.mine, loadMore: true);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RequestsViewModel>(
        create: (_) => viewModel,
        child: TemplatePage(
            pageContext: context,
            floatingActionButton: Container(
              padding: EdgeInsets.symmetric(horizontal: LocalizationService.isArabic(context: context) ? 35 : 0),
              width: double.infinity,
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () async {
                      await context.pushNamed(AppRoutes.addRequest.name, pathParameters: {
                        'type': 'mine',
                        'lang': context.locale.languageCode
                      });
                    }, // Icon inside FAB
                    backgroundColor: const Color(AppColors.primary), // Optional: change color
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
                  const SizedBox(height: 10,),
                  FloatingActionButton(
                    onPressed: ()async {
                      await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      enableDrag: false,
                      isDismissible: false,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(
                            top: Radius.circular(
                                35.0)),
                      ),
                      builder: (BuildContext context) {
                        return SearchFilterWidget(
                          contexts: context,
                          requestsType: widget.requestsType
                        );
                      },
                      );
                      viewModel.initializeRequestsScreen(
                          context: context,
                          requestsType: widget.requestsType!,
                        requestTypeId: CacheHelper.getString("reqId"),
                        empIds: CacheHelper.getString("empId"),
                        from: CacheHelper.getString("from"),
                        to: CacheHelper.getString("to"),
                        depId:CacheHelper.getString("depId"),
                        status: CacheHelper.getString("selectStatus")
                      );
                    },
                    backgroundColor: const Color(AppColors.primary), // Optional: change color
                    tooltip: 'Filter',
                    child: Center(
                      child: Image.asset(
                        "assets/images/png/filter.png",
                        color: AppThemeService.colorPalette.fabIconColor.color,
                        width: AppSizes.s16,
                        height: AppSizes.s16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomAppbarWidget: widget.requestsType == GetRequestsTypes.mine
                ? PreferredSize(
                    preferredSize: const Size.fromHeight(AppSizes.s170),
                    child: Consumer<RequestsViewModel>(
                        builder: (context, viewModel, child) => Padding(
                              padding: const EdgeInsets.only(
                                  left: AppSizes.s12,
                                  right: AppSizes.s12,
                                  top: AppSizes.s10),
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
                  context: context, requestsType: widget.requestsType!);
            },
            body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
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
                    style: const TextStyle(
                        color: Color(0xff404040),
                        fontSize: AppSizes.s12,
                        fontWeight: FontWeight.w400),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 10,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                NoExistingPlaceholderScreen(
                  height: LayoutService.getHeight(context) * 0.6,
                  title: AppStrings.thereIsNoRequests.tr(),
                ),
              ],
            );
          }

          return RefreshIndicator.adaptive(
            onRefresh: () async {
              viewModel.currentPage = 1;
              viewModel.initializeRequestsScreen(
                  context: context, requestsType: widget.requestsType!);
            },
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.85,
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
                          'type': 'mine',
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
                      style: const TextStyle(
                          color: Color(0xff404040),
                          fontSize: AppSizes.s12,
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
    ));
  }
}
