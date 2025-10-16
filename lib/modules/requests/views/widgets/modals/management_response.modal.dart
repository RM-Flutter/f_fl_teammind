import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';
import '../../../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../../../constants/app_strings.dart';
import '../../../../../general_services/localization.service.dart';
import '../../../../../utils/animated_custom_dropdown/custom_dropdown.dart';
import '../../../view_models/management_response.viewmodel.dart';

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
              gapH28,
              // request statuses options
              defaultDropdownField(
                value: viewModel.selectedRequestStatus,
                title: viewModel.selectedRequestStatus ?? AppStrings.requestType.tr(),
                items: viewModel.availableActions!.map((e) => DropdownMenuItem(
                  value: e.toString(),
                  child: Text(
                    e.toString(),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff191C1F)
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
                    backgroundColor: Theme.of(context).colorScheme.secondary,
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
