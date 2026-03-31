import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3489EF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "HASSAN RAMY ASKS YOU TO CANCEL THIS REQUEST",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Hint message
              Text(
                "A Message In Case Of Waiting For Approval From The Other Party\n(Another Level Of Management)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(AppColors.almostBlack),
                  fontSize: 10,
                  height: 1.5,
                ),
              ),
              */
              gapH24,
              // request statuses options
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF3489EF)),
                    hint: Text(
                      (viewModel.selectedRequestStatus ?? AppStrings.requestType.tr()).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF090B60),
                      ),
                    ),
                    items: viewModel.availableActions.map((e) => DropdownMenuItem(
                      value: e.toString(),
                      child: Text(
                        e.toString().toUpperCase(),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF090B60)
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
              gapH18,
              TextFormField(
                controller: viewModel.reasonController,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF090B60),
                ),
                decoration: InputDecoration(
                  hintText: AppStrings.reason.tr().toUpperCase(),
                  hintStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF090B60),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              gapH28,
              Center(
                child: CustomElevatedButton(
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  title: AppStrings.sendRequest.tr().toUpperCase(),
                  titleWidget: Text(
                    "SEND RESPONSE",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
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