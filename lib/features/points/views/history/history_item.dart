import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:provider/provider.dart';
import '../../controllers/history_controller/history_controller.dart';
import 'widget/history_drop_down_widget.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';

class HistoryItem extends StatelessWidget {
  HistoryItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryController>(
      builder: (context, provider, child) {
        if (provider.state == HistoryState.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (provider.state == HistoryState.failure) {
          return Center(
            child: Text('Error: ${provider.errorMessage}'),
          );
        } else if (provider.state == HistoryState.success) {
          return provider.historyModel!.history != null &&
                  provider.historyModel!.history!.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                      children: provider.historyModel!.history!.map(
                    (e) {
                      String apiDate = e.createdAt!;
                      DateTime parsedDate = DateTime.parse(apiDate);
                      String formattedDate = DateFormat(
                              'MMM d, yyyy',
                              LocalizationService.isArabic(context: context)
                                  ? "ar"
                                  : "en")
                          .format(parsedDate);
                      final bool isDeposit = e.operation == "deposit";
                      final Color accentColor = isDeposit
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828);
                      final String pointsLabel = isDeposit
                          ? "+${e.points} ${AppStrings.points.tr()}"
                          : "-${e.points} ${AppStrings.points.tr()}";

                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.cardGap),
                        child: AppCard(
                          onTap: () {
                            if ((e.notes != null && e.notes != "") ||
                                (e.code != null && e.code != "")) {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return HistoryDropDownWidget(
                                        code: e.code?.toString() ?? "",
                                        notes: e.notes?.toString() ?? "");
                                  });
                            }
                          },
                          child: Row(
                            children: [
                              AppCardLeadingAvatar(
                                icon: Icons.card_giftcard_rounded,
                                borderColor: accentColor,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      e.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyles.heading(context),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      formattedDate,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyles.subtitleContent(context),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              AppStatusBadge(
                                label: pointsLabel,
                                color: accentColor,
                                icon: isDeposit
                                    ? Icons.add_circle_outline_rounded
                                    : Icons.remove_circle_outline_rounded,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ).toList()),
                ) : Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/app_logo.png',
                    height: 80,
                    width: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noHistoryFound.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(
            child: ElevatedButton(
              onPressed: () {
                provider.getHistory();
              },
              child: Text(AppStrings.loadHistory.tr()),
            ),
          );
        }
      },
    );
  }
}
