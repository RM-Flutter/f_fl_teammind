import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'widget/finger_print_offline_card.dart';

class FingerPrintOffline extends StatelessWidget {
  const FingerPrintOffline({super.key});

  @override
  Widget build(BuildContext context) {
    return TemplatePage(
        pageContext: context,
        title: AppStrings.showOfflineFingerprints.tr(),
        body: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: kIsWeb ? 1100.w : double.infinity
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSizes.s12.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if(AppConstants.fingerPrints != null) ...[
                      FingerprintCardOffline(fingerprint: AppConstants.fingerPrints,),
                      SizedBox(height: 12.h),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
