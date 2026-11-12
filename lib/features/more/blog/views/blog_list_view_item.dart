import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/shimmer_animated_loading.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';

class BlogListViewItem extends StatelessWidget {
  final List blog;
  final int index;
  var type;
  BlogListViewItem({super.key, required this.blog, required this.index, this.type});

  @override
  Widget build(BuildContext context) {
    final item = blog[index];
    final String? imageUrl = (item['main_thumbnail'] != null &&
            (item['main_thumbnail'] as List).isNotEmpty)
        ? item['main_thumbnail'][0]['file']?.toString()
        : null;
    final String? createdAt = item['created_at']?.toString();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      child: AppCard(animateIn: true,
      onTap: () {
        context.pushNamed(AppRoutes.defaultSinglePage.name,
            pathParameters: {
              'lang': context.locale.languageCode,
              "id": "${item['id']}",
              "type": type.toString()
            });
      },
      child: Row(
        children: [
          AppCardLeadingAvatar(
            imageUrl: imageUrl,
            icon: Icons.article_outlined,
            borderColor: Color(AppColors.buttons),
          ),
          const SizedBox(width: AppSizes.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.heading(context),
                ),
                if (createdAt != null && createdAt.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    createdAt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.subtitleContent(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}
