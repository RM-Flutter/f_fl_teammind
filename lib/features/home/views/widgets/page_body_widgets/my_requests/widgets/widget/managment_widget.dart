import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
