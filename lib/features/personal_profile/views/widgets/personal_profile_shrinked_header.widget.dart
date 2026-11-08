import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/personal_profile_controller.dart';

class PersonalProfileShrinkedHeaderWidget extends StatelessWidget {
  const PersonalProfileShrinkedHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PersonalProfileController>(
      builder: (context, viewModel, child) => AppBarWithBookmark(
        title: AppStrings.accountAndSettings.tr(),
        showBookmark: false,
        actions: [
          IconButton(
            onPressed: () async => await viewModel.logout(context: context),
            icon: Icon(
              Icons.logout_outlined,
              color: Color(AppColors.failureRed),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
