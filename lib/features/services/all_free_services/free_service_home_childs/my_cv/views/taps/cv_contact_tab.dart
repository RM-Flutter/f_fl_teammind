import 'package:app_test/features/services/models/cv_data.model.dart';
import 'package:app_test/features/services/view_models/my_cv.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/cv_info_item.widget.dart';

class CVContactTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVContactTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MyCVViewModel>(context, listen: true);
    final contact = viewModel.cvData?.contact ?? cvData?.contact;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Separator line
          _buildSeparator(),
          
          CVInfoItem(
            label: 'PHONE',
            value: contact?.phone,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'EMAIL',
            value: contact?.email,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'LINKEDIN',
            value: contact?.linkedin,
          ),
          CVInfoItem(
            label: 'BEHANCE',
            value: contact?.behance,
          ),
          CVInfoItem(
            label: 'WHATSAPP',
            value: contact?.whatsapp,
          ),
        ],
      ),
    );
  }


  Widget _buildSeparator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: const Text(
        '----------',
        style: TextStyle(
          color: Colors.grey,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

