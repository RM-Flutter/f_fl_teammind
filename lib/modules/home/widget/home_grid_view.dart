import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/modules/home/widget/grid_view_model.dart';
import 'package:app_test/modules/home/widget/home_grid_view_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeGridView extends StatelessWidget {
  const HomeGridView({super.key});

  @override
  Widget build(BuildContext context) {
    List<GrideViewItemModel> grideItems = [

    ];
    return !kIsWeb?SliverPadding(
      padding: const EdgeInsetsDirectional.only(
          top: AppSizes.s90),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisSpacing: 5,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) => HomeGridViewItem(itemModel: grideItems[index]),
          childCount: grideItems.length,
        ),
      ),

    ): SliverToBoxAdapter(
      child: Align(
        alignment: Alignment.center, // يوسّط الجريد أفقيًا
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemCount: grideItems.length,
              itemBuilder: (context, index) =>
                  HomeGridViewItem(itemModel: grideItems[index]),
            ),
          ),
        ),
      ),
    );
  }

}
