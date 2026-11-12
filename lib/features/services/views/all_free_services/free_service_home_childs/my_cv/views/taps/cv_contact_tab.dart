import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/widgets/app_columns_flow.widget.dart';
import 'package:app_test/features/services/data/models/cv_data_model.dart';
import 'package:app_test/features/services/views/all_free_services/free_service_home_childs/my_cv/controllers/my_cv_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/cv_info_item_widget.dart';

class CVContactTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVContactTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final contact = viewModel.cvData?.contact ?? cvData?.contact;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.s16),
      child: AppColumnsFlow(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: 'PHONE',
                  value: contact?.phone,
                  isRequired: true,
                  icon: Icons.phone,
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: CVInfoItem(
                  label: 'WHATSAPP',
                  value: contact?.whatsapp,
                  icon: Icons.chat_bubble_outline,
                ),
              ),
            ],
          ),
          CVInfoItem(
            label: 'EMAIL',
            value: contact?.email,
            isRequired: true,
            icon: Icons.email_outlined,
          ),
          Row(
            children: [
              Expanded(
                child: CVInfoItem(
                  label: 'LINKEDIN',
                  value: contact?.linkedin,
                  icon: Icons.link,
                ),
              ),
              const SizedBox(width: AppSizes.s8),
              Expanded(
                child: CVInfoItem(
                  label: 'BEHANCE',
                  value: contact?.behance,
                  icon: Icons.brush,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  
}

