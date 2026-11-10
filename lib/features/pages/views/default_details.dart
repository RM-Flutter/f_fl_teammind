import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/styles.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/features/more/blog/controllers/blog_controller.dart';

/// Details of one item of a generic content type (blog, announcement, ...). Same page frame as
/// the other details screens (TemplatePage: app bar with back + bookmark, page padding).
class DefaultDetails extends StatelessWidget {
  final String? id;
  final String? type;
  const DefaultDetails({super.key, required this.id, this.type});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BlogProviderModel()
        ..getOneBlog(context, type: type, id: id.toString()),
      child: Consumer<BlogProviderModel>(
        builder: (context, value, child) {
          return TemplatePage(
            pageContext: context,
            routeName: AppRoutes.defaultSinglePage.name,
            title: type == "rmnotifications"
                ? AppStrings.notifications.tr()
                : type.toString().tr(),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page, vertical: AppSpacing.md),
              child: value.getOneBlogModel?.item != null
                  ? _buildContent(context, value)
                  : const _DetailsShimmer(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BlogProviderModel value) {
    final item = value.getOneBlogModel!.item!;
    final imageUrl = (item.mainThumbnail != null && item.mainThumbnail!.isNotEmpty)
        ? item.mainThumbnail![0].file
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The image (and its gap) only exists when it loads: a failed image leaves no blank area.
        if (imageUrl != null && imageUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, provider) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.section),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: Image(
                  image: provider,
                  width: double.infinity,
                  height: 0.225.sh,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            placeholder: (context, url) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.section),
              child: _shimmerBox(height: 0.225.sh, radius: AppRadius.lg),
            ),
            errorWidget: (context, url, error) => const SizedBox.shrink(),
          ),
        Row(
          children: [
            Text(
              item.createdAt ?? "",
              style: AppStyles.c1Content(context).copyWith(
                fontSize: AppSizes.s10,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (item.category?.title != null) ...[
              const SizedBox(width: 20),
              Icon(Icons.category, color: Colors.black, size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  item.category!.title!,
                  style: AppStyles.c1Content(context).copyWith(
                    fontSize: AppSizes.s10,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        gapH14,
        Text(
          item.title ?? "",
          style: AppStyles.heading(context).copyWith(
              fontSize: AppSizes.s16,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.c1)),
        ),
        gapH14,
        Html(data: item.content ?? "", style: TextsStyles.htmlStyle),
      ],
    );
  }
}

Widget _shimmerBox({double? height, double? width, double radius = AppRadius.sm}) {
  return Container(
    width: width ?? double.infinity,
    height: height,
    decoration: BoxDecoration(
      color: Colors.grey,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

/// Loading skeleton with the same layout as the loaded page: image, date / category line,
/// title and a few body lines.
class _DetailsShimmer extends StatelessWidget {
  const _DetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBox(height: 0.225.sh, radius: AppRadius.lg),
          const SizedBox(height: AppSpacing.section),
          _shimmerBox(height: 10, width: 160),
          gapH14,
          _shimmerBox(height: 16),
          gapH8,
          _shimmerBox(height: 16, width: 220),
          gapH14,
          for (int i = 0; i < 6; i++) ...[
            _shimmerBox(height: 12, width: i == 5 ? 180 : null),
            gapH8,
          ],
        ],
      ),
    );
  }
}
