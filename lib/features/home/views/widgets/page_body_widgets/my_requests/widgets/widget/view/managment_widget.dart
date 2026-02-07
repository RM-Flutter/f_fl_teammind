import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/home/views/widgets/page_body_widgets/my_requests/widgets/widget/controller/management_response_controller.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../../../core/constants/app_sizes.dart';
import '../../../../../../../../../core/widgets/text_form_widget.dart';

class ManagementModule extends StatefulWidget {
  final String requestId;
  const ManagementModule({super.key, required this.requestId});

  @override
  State<ManagementModule> createState() => _ManagementResponseModalState();
}

class _ManagementResponseModalState extends State<ManagementModule> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ManagementResponseViewModal(),
      child: Consumer<ManagementResponseViewModal>(
        builder: (context, viewModel, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              gapH28,
              // request statuses options
              defaultDropdownField(
                value: viewModel.selectedRequestStatus,
                title: viewModel.selectedRequestStatus ?? AppStrings.requestType.tr(),
                hasShadows: false,
                items: viewModel.availableActions.map((e) => DropdownMenuItem(
                  value: e.toString(),
                  child: Text(
                    e.toString(),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(AppColors.almostBlack)
                    ),),
                ),
                ).toList(),
                onChanged: (String? values) {
                  print(values);
                  setState(() {
                    viewModel.selectedRequestStatus = values;
                  });
                },
              ),
              gapH18,
              TextFormField(
                controller: viewModel.reasonController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: AppStrings.reason.tr(),
                ),
              ),
              gapH28,
              Center(
                child: CustomElevatedButton(
                  buttonStyle: ElevatedButton.styleFrom(
                    backgroundColor: Color(AppColors.blue),
                  ),
                  title: AppStrings.sendRequest.tr(),
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
