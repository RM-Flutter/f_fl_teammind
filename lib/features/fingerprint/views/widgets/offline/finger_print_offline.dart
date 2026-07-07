import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/fingerprint/controller/fingerprint_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'package:app_test/features/offline/views/widgets/finger_print_offline_card.dart';

class FingerPrintOffline extends StatelessWidget {
  const FingerPrintOffline({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FingerprintViewModel()..loadFingerprintsFromPreferences(),
      child: const _FingerPrintOfflineContent(),
    );
  }
}

class _FingerPrintOfflineContent extends StatelessWidget {
  const _FingerPrintOfflineContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<FingerprintViewModel>(
      builder: (context, viewModel, _) {
        final fingerprints = AppConstants.fingerPrints;
        final hasFingerprints =
            fingerprints != null && fingerprints.isNotEmpty;

        return TemplatePage(
          pageContext: context,
          title: AppStrings.showOfflineFingerprints.tr(),
          body: Center(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxWidth: kIsWeb ? 1100 : double.infinity),
              child: Padding(
                padding: EdgeInsets.all(AppSizes.s12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Re-upload Button ──────────────────────────────────
                      if (hasFingerprints) ...[
                        Center(
                          child: CustomElevatedButton(
                            backgroundColor: Color(AppColors.buttons),
                            titleSize: AppSizes.s14,
                            title: AppStrings.resubmitOfflineFingerprints.tr(),
                            onPressed: () async {
                              await viewModel.addFingerPrints(
                                context,
                                List.from(fingerprints),
                              );
                              // Refresh list after re-upload attempt
                              await viewModel.loadFingerprintsFromPreferences();
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                      ],

                      // ── Fingerprints List ─────────────────────────────────
                      if (!hasFingerprints)
                        Padding(
                          padding: EdgeInsets.only(top: 60),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fingerprint,
                                size: 64,
                                color: Color(AppColors.buttons).withOpacity(0.3),
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppStrings.noFingerprintsYet.tr(),
                                style: AppStyles.greyContent(context).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        FingerprintCardOffiline(
                          fingerprint: fingerprints,
                          onDelete: (index) async {
                            await viewModel.deleteOfflineFingerprintAt(index);
                          },
                          deletingIndexes: viewModel.deletingOfflineIndexes,
                        ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
