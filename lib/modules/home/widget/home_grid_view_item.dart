import 'package:inv/constants/app_colors.dart';
import 'package:inv/constants/app_sizes.dart';
import 'package:inv/modules/home/widget/grid_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeGridViewItem extends StatelessWidget {
  final GrideViewItemModel itemModel;

  const HomeGridViewItem({super.key, required this.itemModel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: itemModel.onTap,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding:EdgeInsets.symmetric(vertical: 25),
            width: kIsWeb ? AppSizes.s240:AppSizes.s150,
            height: AppSizes.s200,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(AppColors.textC5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 10,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ],
                  borderRadius: BorderRadius.circular(AppSizes.s15)),
              padding: const EdgeInsetsDirectional.only(
                bottom: AppSizes.s30,
                start: AppSizes.s12,
                end: AppSizes.s12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    itemModel.title.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(AppColors.dark),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  gapH4,
                  Text(
                    itemModel.description!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Color(AppColors.dark),
                  ),
                  )
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: itemModel.onTap,
            child: Container(
              width: AppSizes.s64,
              height: AppSizes.s64,
              alignment: Alignment.center,
              padding: const EdgeInsetsDirectional.all(AppSizes.s12),
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                        blurRadius: 5)
                  ],
                  color: itemModel.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSizes.s15)),
              child: SvgPicture.asset(
                itemModel.image,
                width: AppSizes.s36,
                height: AppSizes.s36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
