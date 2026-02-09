import 'package:flutter/material.dart';
import '../../data/models/cv_data_model.dart';
import 'widgets/cv_info_item_widget.dart';

class CVContactTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVContactTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final contact = cvData?.contact;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Separator line
          _buildSeparator(),
          
          CVInfoItem(
            label: 'PHONE',
            value: contact?.phone,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'MORE PHONES',
            value: contact?.morePhones?.join(', '),
          ),
          CVInfoItem(
            label: 'EMAIL',
            value: contact?.email,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'SOCIAL MEDIA LINKS',
            value: _formatSocialMediaLinks(contact?.socialMediaLinks),
            hint: 'محدثين (فيهم) (لينكدإن وغيرها)',
          ),
          CVInfoItem(
            label: 'WHATSAPP',
            value: contact?.whatsapp,
          ),
        ],
      ),
    );
  }

  String? _formatSocialMediaLinks(Map<String, String>? links) {
    if (links == null || links.isEmpty) return null;
    return links.entries.map((e) => '${e.key}: ${e.value}').join('\n');
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

