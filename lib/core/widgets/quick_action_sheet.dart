import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/services/image_file_picker_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/approvables_details/data/models/approvable_details_model.dart';
import 'package:app_test/features/approvables_details/data/services/approvables_details_service.dart';
import 'package:app_test/features/approvables_details/views/widgets/manager_take_action/action_error_banner.dart';
import 'package:app_test/features/approvables_details/views/widgets/manager_take_action/action_file_picker.dart';
import 'package:app_test/features/approvables_details/views/widgets/manager_take_action/action_reply_field.dart';
import 'package:app_test/features/approvables_details/views/widgets/manager_take_action/action_type_toggle.dart';
import 'package:app_test/features/approvables_details/views/widgets/manager_take_action/approver_employee_dropdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/models/operation_result.model.dart';

/// A self-contained bottom sheet that fetches the approvable details internally
/// and renders the take-action / take-action-as-someone-else form.
/// No need to navigate to a details screen first.
Future<void> showQuickActionSheet({
  required BuildContext context,
  required String type,
  required String id,
  required bool isAsSomeoneElse,
  VoidCallback? onActionTaken,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _QuickActionSheet(
      type: type,
      id: id,
      isAsSomeoneElse: isAsSomeoneElse,
      parentContext: context,
      onActionTaken: onActionTaken,
    ),
  );
}

class _QuickActionSheet extends StatefulWidget {
  final String type;
  final String id;
  final bool isAsSomeoneElse;
  final BuildContext parentContext;
  final VoidCallback? onActionTaken;

  const _QuickActionSheet({
    required this.type,
    required this.id,
    required this.isAsSomeoneElse,
    required this.parentContext,
    this.onActionTaken,
  });

  @override
  State<_QuickActionSheet> createState() => _QuickActionSheetState();
}

class _QuickActionSheetState extends State<_QuickActionSheet> {
  // Loading states
  bool _loadingDetails = true;
  bool _loadingApprovers = false;
  bool _submitting = false;
  String? _loadError;

  // Data
  ApprovableDetailsModel? _details;
  List<CurrentLevelApproverModel> _activeApprovers = [];

  // Form state
  String _selectedAction = 'approve';
  final TextEditingController _replyController = TextEditingController();
  PlatformFile? _selectedFile;
  String? _selectedEmployeeId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    final result = await ApprovablesDetailsService.getApprovableDetails(
      context: widget.parentContext,
      type: widget.type,
      id: widget.id,
    );

    if (!mounted) return;

    if (result.success && result.data != null) {
      setState(() {
        _details = result.data;
        _loadingDetails = false;
      });
      // Pre-fetch approvers if needed
      if (widget.isAsSomeoneElse) {
        _fetchApprovers();
      }
    } else {
      setState(() {
        _loadError = result.message ?? 'Failed to load details';
        _loadingDetails = false;
      });
    }
  }

  Future<void> _fetchApprovers() async {
    if (!mounted) return;
    setState(() => _loadingApprovers = true);

    final result = await ApprovablesDetailsService.getCurrentLevelApprovers(
      context: widget.parentContext,
      type: widget.type,
      id: widget.id,
    );

    if (!mounted) return;
    setState(() {
      _activeApprovers = result.data ?? [];
      _loadingApprovers = false;
    });
  }

  Future<void> _pickAttachment() async {
    final result = await FileAndImagePickerService.pickFile();
    if (result != null && result.files.isNotEmpty && mounted) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _submitAction() async {
    final isArabic = LocalizationService.isArabic(context: context);
    setState(() => _errorMessage = null);

    if (widget.isAsSomeoneElse &&
        (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty)) {
      final msg = isArabic
          ? 'برجاء اختيار الموظف المراد التنفيذ بدلاً منه'
          : 'Please select an employee to act on behalf of';
      setState(() => _errorMessage = msg);
      Fluttertoast.showToast(
        msg: msg,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    setState(() => _submitting = true);

    final approvableId = _details?.id?.toString() ?? widget.id;
    OperationResult<bool>? result;

    if (widget.isAsSomeoneElse) {
      result = await ApprovablesDetailsService.takeActionAsSomeoneElse(
        context: widget.parentContext,
        type: widget.type,
        approvableId: approvableId,
        action: _selectedAction,
        employeeId: _selectedEmployeeId!,
        reply: _replyController.text,
        file: _selectedFile,
      );
    } else {
      result = await ApprovablesDetailsService.takeAction(
        context: widget.parentContext,
        type: widget.type,
        approvableId: approvableId,
        action: _selectedAction,
        reply: _replyController.text,
        file: _selectedFile,
      );
    }

    if (!mounted) return;
    setState(() => _submitting = false);

    if (result!.success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(result.message ??
              (isArabic ? 'تم الإجراء بنجاح' : 'Action taken successfully')),
          backgroundColor: Color(AppColors.successGreen),
        ),
      );
      widget.onActionTaken?.call();
    } else {
      setState(() => _errorMessage =
          result?.message ?? (isArabic ? 'حدث خطأ' : 'Something went wrong'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.isAsSomeoneElse
                          ? const Color(0xFFBF360C).withOpacity(0.1)
                          : const Color(0xFFB71C1C).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.isAsSomeoneElse
                          ? Icons.manage_accounts_rounded
                          : Icons.gavel_rounded,
                      color: widget.isAsSomeoneElse
                          ? const Color(0xFFBF360C)
                          : const Color(0xFFB71C1C),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isAsSomeoneElse
                        ? (isArabic
                            ? 'إجراء نيابةً عن موظف'
                            : 'Act as Someone Else')
                        : 'take_action'.tr(),
                    style: AppStyles.darkContent(context).copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.secondaryButton),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const Divider(height: 24),

          // Body
          if (_loadingDetails)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_loadError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    _loadError!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _loadingDetails = true;
                        _loadError = null;
                      });
                      _fetchDetails();
                    },
                    child: Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                  ),
                ],
              ),
            )
          else ...[
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.isAsSomeoneElse)
                    ApproverEmployeeDropdown(
                      selectedEmployeeId: _selectedEmployeeId,
                      activeApprovers: _activeApprovers,
                      isLoadingApprovers: _loadingApprovers,
                      isArabic: isArabic,
                      onChanged: (val) =>
                          setState(() => _selectedEmployeeId = val),
                    ),
                  ActionTypeToggle(
                    selectedAction: _selectedAction,
                    isArabic: isArabic,
                    onActionChanged: (val) =>
                        setState(() => _selectedAction = val),
                  ),
                  ActionReplyField(
                    controller: _replyController,
                    isArabic: isArabic,
                  ),
                  ActionFilePicker(
                    selectedFile: _selectedFile,
                    isArabic: isArabic,
                    onTapPick: _pickAttachment,
                    onTapClear: () => setState(() => _selectedFile = null),
                  ),
                  if (_errorMessage != null)
                    ActionErrorBanner(errorMessage: _errorMessage!),
                  const SizedBox(height: 20),
                  Center(
                    child: _submitting
                        ? const CircularProgressIndicator()
                        : CustomElevatedButton(
                            isFuture: true,
                            titleSize: 13,
                            width: double.infinity,
                            buttonStyle: ElevatedButton.styleFrom(
                              backgroundColor: Color(AppColors.buttons),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: () async => await _submitAction(),
                            title: isArabic ? 'إرسال الإجراء' : 'Submit Action',
                            titleWidget: Text(
                              (isArabic ? 'إرسال الإجراء' : 'Submit Action')
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
          ],
        ],
      ),
    );
  }
}
