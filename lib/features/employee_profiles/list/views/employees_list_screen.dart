import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/loading_page.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import '../controller/employees_list_controller.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  late final EmployeesListViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = EmployeesListViewModel();
    viewModel.initializeEmployeesListScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EmployeesListViewModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          backgroundColor: Colors.white,
          bottomAppbarWidget: PreferredSize(
            preferredSize: Size.fromHeight(AppSizes.s70),
            child: Center(
              child: ConstrainedBox(
                constraints: LayoutService.contentConstraints(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: viewModel.searchController,
                          onChanged: viewModel.updateSearchQuery,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: Color(0xff606060), size: 20),
                              hintText: AppStrings.searchByName.tr(),
                              hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 14),
                              filled: true,
                              fillColor: Color(AppColors.scaffoldBackGround),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: viewModel.searchController.text.isNotEmpty 
                                  ? IconButton(
                                      icon: Icon(Icons.close, color: Color(0xff606060), size: 20),
                                      onPressed: viewModel.releaseSearchValuesAndFilters)
                                  : null,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: AppSizes.s10, horizontal: AppSizes.s12)),
                        ),
                      ),
                      SizedBox(width: AppSizes.s4),
                      IconButton(
                        icon: Image.asset(
                          AppImages.profileFilter,
                          width: AppSizes.s22,
                          height: AppSizes.s22,
                          fit: BoxFit.cover,
                        ),
                        onPressed: () async =>
                        await viewModel.showDepartmentFilterModal(context),
                      ),
                    ],
                  ),
                ),
              )
            )
          ),
          pageContext: context,
          title: AppStrings.employeesList.tr(),
          onRefresh: () async =>
              await viewModel.initializeEmployeesListScreen(context),
          body: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: LayoutService.contentConstraints(context),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
                    child: Consumer<EmployeesListViewModel>(
                        builder: (context, viewModel, child) => viewModel.isLoading
                            ? const LoadingPageWidget(padding: AppSpacing.pagePadding)
                            : viewModel.employees == null ||
                                    viewModel.employees?.isEmpty == true
                                ? NoExistingPlaceholderScreen(
                                    height: LayoutService.getHeight(context) * 0.6,
                                    title: AppStrings.thereIsNoEmployees.tr())
                                : Padding(
                                    padding: AppSpacing.pagePadding,
                                    child: Column(children: [
                                      ...viewModel.filteredEmployees.map((employee) {
                                        final String phoneStr = (employee.phone != null &&
                                                employee.phone.toString().isNotEmpty)
                                            ? (employee.countryKey != null
                                                ? (LocalizationService.isArabic(context: context)
                                                    ? '${employee.phone.toString()}(${employee.countryKey ?? ''}+)'
                                                    : '(+${employee.countryKey ?? ''}) ${employee.phone.toString()}')
                                                : employee.phone.toString())
                                            : '';
                                        final subtitleParts = <String>[
                                          if (employee.jobTitle != null &&
                                              employee.jobTitle!.isNotEmpty)
                                            employee.jobTitle!,
                                          if (phoneStr.isNotEmpty) phoneStr,
                                        ];

                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: AppSpacing.cardGap),
                                          child: AppCard(animateIn: true, 
                                            onTap: () async {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              await context.pushNamed(
                                                  AppRoutes.employeeDetails.name,
                                                  pathParameters: {
                                                    'id': employee.id.toString(),
                                                    'lang': context
                                                        .locale.languageCode
                                                  });
                                            },
                                            child: Row(
                                              children: [
                                                AppCardLeadingAvatar(
                                                  imageUrl: employee.avatar,
                                                  name: employee.name,
                                                  borderColor: Color(
                                                      AppColors.buttons),
                                                ),
                                                const SizedBox(width: AppSizes.s12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        employee.name ?? '',
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: AppStyles.heading(
                                                            context),
                                                      ),
                                                      if (subtitleParts
                                                          .isNotEmpty) ...[
                                                        const SizedBox(height: AppSizes.s2),
                                                        Text(
                                                          subtitleParts
                                                              .join(' · '),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: AppStyles
                                                              .subtitleContent(
                                                                  context),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      })
                                    ]),
                                  )),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
