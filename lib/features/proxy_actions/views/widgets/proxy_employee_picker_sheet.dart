import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';
import 'package:app_test/core/utils/placeholder_no_existing_screen/no_existing_placeholder_screen.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_filter_actions.widget.dart';
import '../../data/models/proxy_employee_model.dart';
import '../../data/repos/proxy_repo.dart';

/// Picks the employee to act for. Loads the employees allowed for [ability] (the server already
/// limits them to the manager's scope and leaves the manager out), with a search over name,
/// email, phone, department and job title. Returns the chosen employee, or null when closed.
class ProxyEmployeePickerSheet extends StatefulWidget {
  final String ability;
  final String title;

  const ProxyEmployeePickerSheet({super.key, required this.ability, required this.title});

  static Future<ProxyEmployeeModel?> show(BuildContext context,
      {required String ability, required String title}) {
    return showModalBottomSheet<ProxyEmployeeModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Color(AppColors.background),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => ProxyEmployeePickerSheet(ability: ability, title: title),
    );
  }

  @override
  State<ProxyEmployeePickerSheet> createState() => _ProxyEmployeePickerSheetState();
}

class _ProxyEmployeePickerSheetState extends State<ProxyEmployeePickerSheet> {
  List<ProxyEmployeeModel>? _employees;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _employees = null;
      _error = null;
    });
    final res = await ProxyRepo.employees(context, widget.ability);
    if (!mounted) return;
    setState(() {
      if (res.result.success) {
        _employees = res.employees;
      } else {
        _employees = const [];
        _error = res.result.message ?? AppStrings.somethingWentWrong.tr();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final visible = _employees?.where((e) => e.matches(_query)).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: media.size.height * 0.85,
        child: Column(
          children: [
            const SizedBox(height: AppSizes.s12),
            Container(
              width: 63,
              height: AppSizes.s5,
              decoration: BoxDecoration(
                color: Color(AppColors.disableButton),
                borderRadius: BorderRadius.circular(AppRadius.xs),
              ),
            ),
            const SizedBox(height: AppSizes.s20),
            AppFilterTitle(widget.title),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: AppSpacing.pagePadding,
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'proxy_search_employee'.tr(),
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: visible == null
                  ? const AppShimmerList(count: 6)
                  : visible.isEmpty
                      ? NoExistingPlaceholderScreen(
                          compact: true,
                          title: _error != null
                              ? AppStrings.somethingWentWrong.tr()
                              : 'proxy_no_employees'.tr(),
                          message: _error ?? 'proxy_no_employees_hint'.tr(),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.listBottom),
                          itemCount: visible.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.cardGap),
                          itemBuilder: (context, i) {
                            final e = visible[i];
                            return AppCard.listItem(
                              context: context,
                              title: e.name,
                              subtitle: e.subtitle,
                              avatarUrl: e.avatar,
                              trailing: Icon(Icons.chevron_right_rounded,
                                  color: Color(AppColors.secondaryButton)),
                              onTap: () => Navigator.of(context).pop(e),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
