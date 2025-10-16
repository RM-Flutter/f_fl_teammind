import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_sizes.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/layout.service.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/models/get_one_notification_model.dart';
import 'package:rmemp/models/get_one_request_model.dart';


class NotificationDetailsAppbarWidget extends StatelessWidget {
  NotificationSingleModel? notificationSingleModel;
  NotificationDetailsAppbarWidget({this.notificationSingleModel});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      clipBehavior: Clip.antiAlias,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/png/home_back.png"),
            fit: BoxFit.fill,
            opacity: 0.4),
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s28),
            bottomRight: Radius.circular(AppSizes.s28)),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                        onTap: (){Navigator.pop(context);},
                        child: Icon(Icons.arrow_back, color: Color(0xffFFFFFF),)),
                    Spacer(),
                    Text(
                      AppStrings.notificationInfo.tr().toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Container(width: 20,),
                  ],
                ),
                SizedBox(height: 16,),
                Text(
                  notificationSingleModel!.title?.toString() ?? "",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 25,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                     DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context)? "ar" : "en").format(DateTime.parse(notificationSingleModel!.createdAt.toString())).toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    //     Row(
                    //   children: [
                    //     Icon(Icons.folder_open_outlined, color: Colors.white,),
                    //     SizedBox(width: 5,),
                    //     SizedBox(
                    //       width: MediaQuery.sizeOf(context).width * 0.25,
                    //       child: Text(
                    //         (notificationSingleModel!.commentStatus != null)?
                    //         notificationSingleModel!.commentStatus!.value!.toUpperCase() : "",
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.white,
                    //           fontWeight: FontWeight.w500,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(width: 15,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.category, color: Color(AppColors.primary),),
                        const SizedBox(width: 5,),
                        Text(
                          notificationSingleModel!.ptype!.key!.toString().tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16,),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
