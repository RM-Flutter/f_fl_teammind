import 'package:flutter/material.dart';
import '../../../models/cv_data.model.dart';
import 'cv_info_item.widget.dart';

class CVPersonalTab extends StatelessWidget {
  final CVDataModel? cvData;

  const CVPersonalTab({super.key, this.cvData});

  @override
  Widget build(BuildContext context) {
    final personal = cvData?.personal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CVInfoItem(
            label: 'NAME',
            value: personal?.name,
            isRequired: true,
            hint: 'لو فاضى هات نسخة من اسم الاكونت',
          ),
          CVInfoItem(
            label: 'FAMILY STATUS',
            value: personal?.familyStatus,
          ),
          CVInfoItem(
            label: 'BIRTHDAY',
            value: personal?.birthday,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'GANDER',
            value: personal?.gender,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'NATIONALITY',
            value: personal?.nationality,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'COUNTRY',
            value: personal?.country,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'GOVERNORATE/STATE',
            value: personal?.governorateState,
            isRequired: true,
          ),
          CVInfoItem(
            label: 'CITY',
            value: personal?.city,
          ),
          CVInfoItem(
            label: 'ADDRESS',
            value: personal?.address,
          ),
        ],
      ),
    );
  }
}

