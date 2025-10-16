import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/profiles/models/employee_profile.model.dart';
import 'package:rmemp/modules/profiles/views/widgets/profile_tile.widget.dart';
import '../../../../../constants/app_sizes.dart';

class AssetsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  AssetsSectionWidget({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
      fontSize: AppSizes.s13,
    );
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH4,
          Text(AppStrings.assets.tr().toUpperCase(),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff606060)),
          ),
          gapH12,
          ListView.separated(
              reverse: false,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) =>  ProfileTileNotTap(
                url: null,
                createAt: null,
                gainedPoints: null,
                totalPoints: null,
                isViewArrow: false,
                title: "${employee!.assets![index].assets}",
                icon: const Icon(Icons.check_circle_outline, color: Colors.black,),
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 15,),
              itemCount: employee!.assets!.length),
          const SizedBox(height: 20,),
          Text(AppStrings.customData.tr().toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xff606060)),),
          gapH12,
          ListView.separated(
              reverse: false,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) => Container(
                margin: EdgeInsets.only(bottom:AppSizes.s12),
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.s12, horizontal: AppSizes.s10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.s8),
                    border: Border.all(color: Colors.grey.withOpacity(0.1))),
                child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  const Icon(Icons.check_circle_outline, color: Colors.black,),
                    gapW4,
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.75,
                        child: Text("${employee!.empCustomData![index].item}",style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black)))),
                  ],
                ),
              ),
              separatorBuilder: (context, index) => const SizedBox(height: 15,),
              itemCount: employee!.empCustomData!.length)
        ],
      ),
    );
  }
}
