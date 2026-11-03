import 'package:app_test/core/services/app_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/image_file_picker_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../cubit/approvable_details_cubit.dart';
import '../../cubit/approvable_details_state.dart';
import '../../data/models/approvable_details_model.dart';
import 'manager_take_action/approver_employee_dropdown.dart';
import 'manager_take_action/action_type_toggle.dart';
import 'manager_take_action/action_reply_field.dart';
import 'manager_take_action/action_file_picker.dart';
import 'manager_take_action/action_error_banner.dart';
import 'package:app_test/core/constants/app_design.dart';

class ManagerTakeActionModal extends StatefulWidget {
  final ApprovableDetailsModel details;
  final BuildContext parentContext;
  final bool isAsSomeoneElse;
  final String? approvableStepId; // ID of the required approval step

  const ManagerTakeActionModal({
    super.key,
    required this.details,
    required this.parentContext,
    this.isAsSomeoneElse = false,
    this.approvableStepId,
  });

  @override
  State<ManagerTakeActionModal> createState() => _ManagerTakeActionModalState();
}

class _ManagerTakeActionModalState extends State<ManagerTakeActionModal> {
  String _selectedAction = 'approve'; // 'approve' | 'refuse'
  final TextEditingController _replyController = TextEditingController();
  PlatformFile? _selectedFile;
  String? _selectedEmployeeId;
  String? _errorMessage;
  List<CurrentLevelApproverModel> _activeApprovers = [];

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FileAndImagePickerService.pickFile();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
      });
    }
  }

  Future<void> _submitAction(BuildContext context) async {
    setState(() => _errorMessage = null);
    final cubit = context.read<ApprovableDetailsCubit>();
    final isAsSomeoneElse = widget.isAsSomeoneElse;

    // approvable_id expected by backend is the main approvable/request ID (e.g., 360)
    final String approvableId =
        widget.details.id?.toString() ?? widget.approvableStepId ?? '';

    if (isAsSomeoneElse) {
      if (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty) {
        final msg = 'please_select_an_employee_to_act_on'.tr();
        setState(() {
          _errorMessage = msg;
        });
        AppToast.showToast(
          msg: msg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      await cubit.submitTakeActionAsSomeoneElse(
        context: widget.parentContext,
        approvableId: approvableId,
        action: _selectedAction,
        employeeId: _selectedEmployeeId!,
        reply: _replyController.text,
        file: _selectedFile,
      );
    } else {
      await cubit.submitTakeAction(
        context: widget.parentContext,
        approvableId: approvableId,
        action: _selectedAction,
        reply: _replyController.text,
        file: _selectedFile,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAsSomeoneElse = widget.isAsSomeoneElse;
    final isArabic = LocalizationService.isArabic(context: context);

    return BlocBuilder<ApprovableDetailsCubit, ApprovableDetailsState>(
      builder: (context, state) {
        bool isLoadingApprovers = false;

        if (state is ApprovableDetailsLoaded) {
          _activeApprovers = state.activeApprovers ?? [];
          isLoadingApprovers = state.isLoadingApprovers;
        }

        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAsSomeoneElse
                          ? ('take_action_as_someone_else'.tr())
                          : 'take_action'.tr(),
                      style: AppStyles.darkContent(context).copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.secondaryButton),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),

                // Approver Employee Dropdown (Case B)
                if (isAsSomeoneElse)
                  ApproverEmployeeDropdown(
                    selectedEmployeeId: _selectedEmployeeId,
                    activeApprovers: _activeApprovers,
                    isLoadingApprovers: isLoadingApprovers,
                    isArabic: isArabic,
                    onChanged: (val) =>
                        setState(() => _selectedEmployeeId = val),
                  ),

                // Action Toggle Buttons (Approve / Refuse)
                ActionTypeToggle(
                  selectedAction: _selectedAction,
                  isArabic: isArabic,
                  onActionChanged: (val) =>
                      setState(() => _selectedAction = val),
                ),

                // Reply Notes Field
                ActionReplyField(
                  controller: _replyController,
                  isArabic: isArabic,
                ),

                // File Attachment Picker
                ActionFilePicker(
                  selectedFile: _selectedFile,
                  isArabic: isArabic,
                  onTapPick: _pickAttachment,
                  onTapClear: () => setState(() => _selectedFile = null),
                ),

                // Error Message Banner
                if (_errorMessage != null)
                  ActionErrorBanner(errorMessage: _errorMessage!),

                const SizedBox(height: 24),

                // Submit Button
                Center(
                  child: CustomElevatedButton(
                    isFuture: true,
                    titleSize: 13,
                    width: double.infinity,
                    buttonStyle: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.buttons),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                    ),
                    onPressed: () async => await _submitAction(context),
                    title: 'submit_action'.tr(),
                    titleWidget: Text(
                      ('submit_action'.tr())
                          .toUpperCase(),
                      style: AppStyles.whiteContent(context).copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
