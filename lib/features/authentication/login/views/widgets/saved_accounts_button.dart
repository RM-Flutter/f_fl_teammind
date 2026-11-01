import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/features/authentication/login/controller/login_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'saved_accounts_sheet.dart';

/// "Saved accounts (n)" button pinned to the top-left of the login page, the
/// mirror of the language button on the right. Hidden until an account has
/// been saved on the current domain.
class SavedAccountsButton extends StatelessWidget {
  const SavedAccountsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb || PlatformIs.web;
    return Consumer<AuthenticationController>(
      builder: (context, viewModel, child) {
        if (viewModel.savedAccounts.isEmpty) return const SizedBox.shrink();
        return Positioned(
          top: MediaQuery.of(context).padding.top + AppSizes.s12,
          left: AppSizes.s10,
          child: Material(
            color: Colors.grey.shade800.withOpacity(0.5),
            borderRadius: BorderRadius.circular(isWeb ? 20 : 20.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(isWeb ? 20 : 20.r),
              onTap: () async {
                FocusManager.instance.primaryFocus?.unfocus();
                final picked = await SavedAccountsSheet.show(
                  context,
                  accounts: viewModel.savedAccounts,
                  onDelete: viewModel.deleteSavedAccount,
                );
                if (picked != null) viewModel.applySavedAccount(picked);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isWeb ? 12 : 12.w,
                  vertical: isWeb ? 8 : 8.h,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.manage_accounts_outlined,
                        color: Colors.white, size: isWeb ? 18 : 18.r),
                    SizedBox(width: isWeb ? 6 : 6.w),
                    Text(
                      '${AppStrings.savedAccounts.tr()} (${viewModel.savedAccounts.length})',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isWeb ? 13 : 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
