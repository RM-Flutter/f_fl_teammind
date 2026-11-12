import 'package:app_test/core/constants/app_sizes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_field_shell.widget.dart';
import 'package:app_test/core/widgets/app_filter_actions.widget.dart' show AppFilterTitle;
import 'tracking_choice_chip.dart';

/// Bottom sheet to save a key (manual) point during an active leg. The title is optional; the
/// point is saved with the current location and sent right away (spec: mobile §4).
class AddManualPointModal extends StatefulWidget {
  final Function(String label) onSubmit;

  const AddManualPointModal({super.key, required this.onSubmit});

  static Future<void> show(BuildContext context, {required Function(String label) onSubmit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddManualPointModal(onSubmit: onSubmit),
    );
  }

  @override
  State<AddManualPointModal> createState() => _AddManualPointModalState();
}

class _AddManualPointModalState extends State<AddManualPointModal> {
  final TextEditingController _controller = TextEditingController();

  static const _suggestionKeys = [
    'tracking_suggestion_arrived',
    'tracking_suggestion_meeting_ended',
    'tracking_suggestion_inspection',
    'tracking_suggestion_handover',
    'tracking_suggestion_break',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    widget.onSubmit(text.isEmpty ? 'manual_point'.tr() : text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: BoxDecoration(
          color: Color(AppColors.background),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSizes.s10),
              Container(
                width: 63,
                height: 5,
                decoration: BoxDecoration(
                  color: Color(AppColors.disableButton),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
              const SizedBox(height: AppSizes.s10),
              Padding(
                padding: const EdgeInsets.all(AppSizes.s20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppFilterTitle('tracking_add_key_point'.tr()),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'tracking_add_key_point_hint'.tr(),
                      textAlign: TextAlign.center,
                      style: AppStyles.greyContent(context).copyWith(fontSize: 12.5, height: 1.4),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppFieldShell(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        style: AppField.valueStyle,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          hintText: 'tracking_point_title_optional'.tr(),
                          hintStyle: AppField.hintStyle,
                          isDense: true,
                          filled: false,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final key in _suggestionKeys)
                          TrackingChoiceChip(
                            label: key.tr(),
                            selected: _controller.text == key.tr(),
                            onTap: () => setState(() {
                              _controller.text = key.tr();
                              _controller.selection =
                                  TextSelection.collapsed(offset: _controller.text.length);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.s30),
                    SizedBox(
                      height: AppButtonSize.height,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.add_location_alt_outlined, size: 20),
                        label: Text('tracking_save_point'.tr(),
                            style: const TextStyle(
                                fontSize: AppButtonSize.fontSize, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.buttons),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
