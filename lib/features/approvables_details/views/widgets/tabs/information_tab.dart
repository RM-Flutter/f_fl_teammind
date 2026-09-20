import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import '../../../data/models/approvable_details_model.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/utils/app_styles.dart';

class InformationTab extends StatelessWidget {
  final String? createdAt;
  final String? seenAt;
  final String? updatedAt;
  final List<SeenByModel>? seenBy;

  const InformationTab({
    super.key,
    this.createdAt,
    this.seenAt,
    this.updatedAt,
    this.seenBy,
  });

  String _formatInfoDate(String? rawDate, BuildContext context) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final lang = LocalizationService.isArabic(context: context) ? "ar" : "en";
      return DateFormat('d-M-y | hh:mm a', lang).format(DateTime.parse(rawDate));
    } catch (_) {
      return rawDate;
    }
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label : ",
            style: AppStyles.darkContent(context).copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: AppStyles.primaryContent(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          if (createdAt != null && createdAt!.isNotEmpty)
            _buildInfoCard(
              context,
              AppStrings.createdOn.tr(),
              _formatInfoDate(createdAt, context),
            ),
          if (seenAt != null && seenAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              AppStrings.seenOn.tr(),
              _formatInfoDate(seenAt, context),
            ),
          ],
          if (updatedAt != null && updatedAt!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              AppStrings.statusUpdate.tr(),
              _formatInfoDate(updatedAt, context),
            ),
          ],
          if (seenBy != null && seenBy!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              isArabic ? 'شوهد بواسطة' : 'Seen By',
              style: AppStyles.darkContent(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            ...seenBy!.map((person) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: (person.avatar != null && person.avatar!.isNotEmpty)
                          ? (kIsWeb ? NetworkImage(person.avatar!) : CachedNetworkImageProvider(person.avatar!)) as ImageProvider
                          : null,
                      child: (person.avatar == null || person.avatar!.isEmpty)
                          ? Icon(Icons.person, color: Colors.grey.shade400)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            person.name ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (person.date != null && person.date!.isNotEmpty)
                            Text(
                              _formatInfoDate(person.date, context),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
