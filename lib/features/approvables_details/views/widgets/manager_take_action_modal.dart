import 'dart:io';
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

class ManagerTakeActionModal extends StatefulWidget {
  final ApprovableDetailsModel details;
  final String? approvableStepId; // ID of the required approval step

  const ManagerTakeActionModal({
    super.key,
    required this.details,
    this.approvableStepId,
  });

  @override
  State<ManagerTakeActionModal> createState() => _ManagerTakeActionModalState();
}

class _ManagerTakeActionModalState extends State<ManagerTakeActionModal> {
  String _selectedAction = 'approve'; // 'approve' | 'refuse'
  final TextEditingController _replyController = TextEditingController();
  File? _selectedFile;
  String? _selectedEmployeeId;
  String? _errorMessage;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachment() async {
    final result = await FileAndImagePickerService.pickFile();
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() {
          _selectedFile = File(path);
        });
      }
    }
  }

  void _submitAction(BuildContext context) {
    setState(() => _errorMessage = null);
    final cubit = context.read<ApprovableDetailsCubit>();
    final isAsSomeoneElse = widget.details.canTakeActionAsSomeoneElse == true;

    // approvable_id expected by backend is the main approvable/request ID (e.g., 360)
    final String approvableId = widget.details.id?.toString() ?? widget.approvableStepId ?? '';

    if (isAsSomeoneElse) {
      if (_selectedEmployeeId == null || _selectedEmployeeId!.isEmpty) {
        final msg = LocalizationService.isArabic(context: context)
            ? 'برجاء اختيار الموظف المراد التنفيذ بدلاً منه'
            : 'Please select an employee to act on behalf of';
        setState(() {
          _errorMessage = msg;
        });
        Fluttertoast.showToast(
          msg: msg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
        return;
      }

      // Close bottom sheet immediately so SnackBar is visible on main screen
      Navigator.of(context).pop();

      cubit.submitTakeActionAsSomeoneElse(
        context: context,
        approvableId: approvableId,
        action: _selectedAction,
        employeeId: _selectedEmployeeId!,
        reply: _replyController.text,
        file: _selectedFile,
      );
    } else {
      // Close bottom sheet immediately so SnackBar is visible on main screen
      Navigator.of(context).pop();

      cubit.submitTakeAction(
        context: context,
        approvableId: approvableId,
        action: _selectedAction,
        reply: _replyController.text,
        file: _selectedFile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAsSomeoneElse = widget.details.canTakeActionAsSomeoneElse == true;
    final isArabic = LocalizationService.isArabic(context: context);

    return BlocBuilder<ApprovableDetailsCubit, ApprovableDetailsState>(
      builder: (context, state) {
        List<CurrentLevelApproverModel> activeApprovers = [];
        bool isLoadingApprovers = false;

        if (state is ApprovableDetailsLoaded) {
          activeApprovers = state.activeApprovers ?? [];
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
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
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
                          ? (isArabic ? 'اتخاذ إجراء نيابة عن موظف' : 'Take Action as Someone Else')
                          : 'can_take_action'.tr(),
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

                // Case B: Select Approver Employee Dropdown
                if (isAsSomeoneElse) ...[
                  Text(
                    isArabic ? 'اختر الشخص المراد التوقيع عنه' : 'Select Approver Employee',
                    style: AppStyles.darkContent(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.secondaryButton),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isLoadingApprovers)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else if (activeApprovers.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade300),
                      ),
                      child: Text(
                        isArabic
                            ? 'لا يوجد مديرون متاحون حالياً لهذا المستوى'
                            : 'No approvers available for this level',
                        style: const TextStyle(fontSize: 12, color: Colors.amber),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEmployeeId,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          icon: Icon(Icons.arrow_drop_down,
                              color: Color(AppColors.buttons), size: 24),
                          hint: Text(
                            isArabic ? 'اختر الموظف' : 'Select Employee',
                            style: AppStyles.darkContent(context).copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(AppColors.secondaryButton),
                            ),
                          ),
                          items: activeApprovers.map((emp) {
                            final label =
                                '${emp.name ?? ''} ${emp.jobTitle != null ? '(${emp.jobTitle})' : ''}';
                            return DropdownMenuItem<String>(
                              value: emp.id?.toString(),
                              child: Text(
                                label,
                                style: AppStyles.darkContent(context).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(AppColors.secondaryButton),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedEmployeeId = val;
                            });
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],

                // Action Toggle Buttons (Approve / Refuse)
                Text(
                  isArabic ? 'نوع الإجراء' : 'Action Type',
                  style: AppStyles.darkContent(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.secondaryButton),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAction = 'approve'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedAction == 'approve'
                                ?  Color(AppColors.successGreen)
                                : const Color(0xFFF3F3F3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedAction == 'approve'
                                  ?  Color(AppColors.successGreen)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: _selectedAction == 'approve'
                                    ? Colors.white
                                    : Color(AppColors.secondaryButton),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isArabic ? 'موافقة' : 'Approve',
                                style: AppStyles.whiteContent(context).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedAction == 'approve'
                                      ? Colors.white
                                      : Color(AppColors.secondaryButton),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedAction = 'refuse'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedAction == 'refuse'
                                ?  Color(AppColors.failureRed)
                                : const Color(0xFFF3F3F3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedAction == 'refuse'
                                  ?  Color(AppColors.failureRed)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cancel_outlined,
                                color: _selectedAction == 'refuse'
                                    ? Colors.white
                                    : Color(AppColors.secondaryButton),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isArabic ? 'رفض' : 'Refuse',
                                style: AppStyles.whiteContent(context).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedAction == 'refuse'
                                      ? Colors.white
                                      : Color(AppColors.secondaryButton),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Reply Notes Field
                Text(
                  isArabic ? 'ملاحظات / الرد (اختياري)' : 'Reply / Notes (Optional)',
                  style: AppStyles.darkContent(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.secondaryButton),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _replyController,
                  maxLines: 3,
                  style: AppStyles.darkContent(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(AppColors.secondaryButton),
                  ),
                  decoration: InputDecoration(
                    hintText: isArabic ? 'أدخل ملاحظاتك هنا...' : 'Enter your notes here...',
                    hintStyle: AppStyles.greyContent(context).copyWith(fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 16),

                // File Attachment Picker
                Text(
                  isArabic ? 'مرفق (اختياري)' : 'Attachment File (Optional)',
                  style: AppStyles.darkContent(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.secondaryButton),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickAttachment,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F3F3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.attach_file, color: Color(AppColors.buttons)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedFile != null
                                ? _selectedFile!.path.split('/').last
                                : (isArabic ? 'اضغط لإرفاق ملف' : 'Tap to attach file'),
                            style: AppStyles.darkContent(context).copyWith(
                              fontSize: 12,
                              color: Color(AppColors.secondaryButton),
                              fontWeight: _selectedFile != null
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedFile != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedFile = null),
                            child: const Icon(Icons.close, size: 18, color: Colors.red),
                          ),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Submit Button
                CustomElevatedButton(
                  titleSize: 13,
                  width: double.infinity,
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.buttons),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  onPressed: () async => _submitAction(context),
                  title: isArabic ? 'إرسال الإجراء' : 'Submit Action',
                  titleWidget: Text(
                    (isArabic ? 'إرسال الإجراء' : 'Submit Action').toUpperCase(),
                    style: AppStyles.whiteContent(context).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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
