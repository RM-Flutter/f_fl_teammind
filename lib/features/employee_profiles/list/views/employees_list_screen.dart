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
                constraints: BoxConstraints(
                    maxWidth: kIsWeb ? 1100 : double.infinity
                ),
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
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: viewModel.searchController.text.isNotEmpty 
                                  ? IconButton(
                                      icon: Icon(Icons.close, color: Color(0xff606060), size: 20),
                                      onPressed: viewModel.releaseSearchValuesAndFilters)
                                  : null,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12)),
                        ),
                      ),
                      SizedBox(width: 4),
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
                  constraints: BoxConstraints(
                      maxWidth: kIsWeb ? 1100 : double.infinity
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSizes.s12),
                    child: Consumer<EmployeesListViewModel>(
                        builder: (context, viewModel, child) => viewModel.isLoading
                            ? const LoadingPageWidget(
                                reverse: true,
                                height: AppSizes.s75,
                              )
                            : viewModel.employees == null ||
                                    viewModel.employees?.isEmpty == true
                                ? NoExistingPlaceholderScreen(
                                    height: LayoutService.getHeight(context) * 0.6,
                                    title: AppStrings.thereIsNoEmployees.tr())
                                : Column(children: [
                                    // GeneralScreenMessageWidget(
                                    //     screenId: '/employees-list'),
                                    ...viewModel.filteredEmployees.map((employee) {
                                      return Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                            leading: employee.avatar != null && employee.avatar!.isNotEmpty
                                                ? CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor: Colors.transparent,
                                                    child: Center(
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(50),
                                                        child: CachedNetworkImage(
                                                            imageUrl: employee.avatar!,
                                                            fit: BoxFit.cover,
                                                            width: 50,
                                                            height: 50,
                                                            placeholder: (context,
                                                                    url) =>
                                                                const ShimmerAnimatedLoading(
                                                                  circularRaduis:
                                                                      AppSizes.s50,
                                                                ),
                                                            errorWidget: (context,
                                                                    url, error) =>
                                                                Image.asset(
                                                                  "assets/images/user.png",
                                                                  fit: BoxFit.cover,
                                                                  width: 50,
                                                                  height: 50,
                                                                )),
                                                      ),
                                                    ),
                                                  )
                                                : CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor: Colors.transparent,
                                                    child: Image.asset(
                                                      "assets/images/user.png",
                                                      fit: BoxFit.cover,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  ),
                                            title: Text(
                                              employee.name ?? '',
                                              style: AppStyles.blackContent(context).copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                              ),
                                            ),
                                            subtitle: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                if (employee.jobTitle != null && employee.jobTitle!.isNotEmpty)
                                                  Text(
                                                    employee.jobTitle!,
                                                    style: AppStyles.greyContent(context).copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                if (employee.phone != null && employee.phone.toString().isNotEmpty) ... [
                                                  SizedBox(height: 3),
                                                  Text(
                                                    employee.countryKey != null
                                                        ? LocalizationService.isArabic(context: context)
                                                        ? '${employee.phone.toString()}(${employee.countryKey ?? ''}+)'
                                                        : '(+${employee.countryKey ?? ''}) ${employee.phone.toString()}'
                                                        : '${employee.phone.toString()}',
                                                    style: AppStyles.greyContent(context).copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ],

                                              ],
                                            ),
                                            onTap: () async {
                                              FocusManager.instance.primaryFocus?.unfocus();
                                              await context.pushNamed(
                                                  AppRoutes.employeeDetails.name,
                                                  pathParameters: {
                                                    'id': employee.id.toString(),
                                                    'lang': context.locale.languageCode
                                                  });
                                            },
                                          ),
                                           Divider(
                                            color: Color(AppColors.divider).withOpacity(.3),
                                            height: 1,
                                            indent: 16,
                                            endIndent: 16,
                                          )
                                        ],
                                      );
                                    })
                                  ])),
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
