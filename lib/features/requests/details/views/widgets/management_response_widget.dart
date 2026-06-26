import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/widget/controller/management_response_controller.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/text_form_widget.dart';

class ManagementResponseModal extends StatefulWidget {
  final String requestId;
  const ManagementResponseModal({super.key, required this.requestId});

  @override
  State<ManagementResponseModal> createState() => _ManagementResponseModalState();
}

class _ManagementResponseModalState extends State<ManagementResponseModal> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManagementResponseViewModal(),
      child: Consumer<ManagementResponseViewModal>(
        builder: (context, viewModel, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: Wire up dynamic message from API
              /*
              // Blue info banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(AppColors.buttons),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "HASSAN RAMY ASKS YOU TO CANCEL THIS REQUEST",
                  textAlign: TextAlign.center,
                  style: AppStyles.whiteContent(context).copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Hint message
              Text(
                "A Message In Case Of Waiting For Approval From The Other Party\n(Another Level Of Management)",
                textAlign: TextAlign.center,
                style: AppStyles.almostBlackContent(context).copyWith(
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
              */
              SizedBox(height: 24),
              // request statuses options
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color:  Color(AppColors.buttons), size: 24),
                    hint: Text(
                      (viewModel.selectedRequestStatus ?? AppStrings.requestType.tr()).toUpperCase(),
                      style: AppStyles.darkContent(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(AppColors.secondaryButton),
                      ),
                    ),
                    items: viewModel.availableActions.map((e) => DropdownMenuItem(
                      value: e.toString(),
                      child: Text(
                        e.toString().toUpperCase(),
                        style: AppStyles.darkContent(context).copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(AppColors.secondaryButton)
                        ),),
                    )).toList(),
                    onChanged: (String? values) {
                      setState(() {
                        viewModel.selectedRequestStatus = values;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 18),
              TextFormField(
                controller: viewModel.reasonController,
                maxLines: 5,
                style: AppStyles.darkContent(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(AppColors.secondaryButton),
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.reason.tr().toUpperCase(),
                  hintStyle: AppStyles.darkContent(context).copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.secondaryButton),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 28),
              Center(
                child: CustomElevatedButton(
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.secondaryButton),
                  ),
                  title: AppStrings.sendRequest.tr().toUpperCase(),
                  titleWidget: Text(
                    "SEND RESPONSE",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.whiteContent(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () async => await viewModel.sendManagerAction(
                      requestId: widget.requestId, context: context),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}