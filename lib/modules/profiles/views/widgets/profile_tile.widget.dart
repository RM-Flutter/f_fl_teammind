import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_sizes.dart';

class ProfileTile extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  final Widget? icon;
  final double? marginBottom;
  List? weekends;
  bool? isList = false;
  ProfileTile({
    super.key,
    this.icon,
    this.isList,
    this.weekends,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom ?? AppSizes.s12),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.s12, horizontal: AppSizes.s10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.s8),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: isTitleOnly == true
          ? Center(
              child: Text(title.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xff000000)),
              ),
            )
          : icon != null && trailingTitle != null
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon ?? const SizedBox.shrink(),
                    gapW4,
                    Text(title,style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black))),
                    gapW12,
                    if(isList == false)Expanded(
                      child: AutoSizeText(
                        trailingTitle ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    if(isList == true)Container(
                      width: MediaQuery.sizeOf(context).width * 0.5,
                      alignment: Alignment.centerRight,
                      height: 15,
                      child: ListView.separated(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          reverse: false,
                          itemBuilder: (context, index) => AutoSizeText(
                            weekends![index] ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),
                            textAlign: TextAlign.end,
                          ),
                          separatorBuilder: (context, index) => SizedBox(width: 10,child: Text(index == weekends!.length - 1 ? "" : ",", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff000000)),),),
                          itemCount: weekends!.length),
                    )
                  ],
                )
              : const SizedBox.shrink(),
    );
  }
}
class ProfileTileEva extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var eva;
  var createAt;
  var totalPoints;
  var gainedPoints;
  final double? marginBottom;
  ProfileTileEva({
    super.key,
    this.totalPoints,
    this.eva,
    this.gainedPoints,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        showEvaluationBottomSheet(context);
      }
      ,
      child: Container(
        margin: EdgeInsets.only(bottom: marginBottom ?? AppSizes.s12),
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.s12, horizontal: AppSizes.s10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.s8),
            border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      icon ?? const SizedBox.shrink(),
                      gapW4,
                      Text(title,style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black))),
                      gapW12,
                      if(isViewArrow == true) const Spacer(),
                     if(isViewArrow == true) const CircleAvatar(
                        backgroundColor: Color(0xff3489EF),
                        radius: 12,
                        child: Icon(Icons.arrow_forward_sharp,color: Colors.white, size: 10,),
                      )
                    ],
                  ),
      ),
    );
  }
  void showEvaluationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          height: MediaQuery.sizeOf(context).height * 0.6,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppStrings.evaluationsInfo.tr(),style: const TextStyle(fontSize: 20, color: Color(AppColors.dark), fontWeight: FontWeight.w600),),
               const SizedBox(height: 15,),
               Container(
                 width: double.infinity,
                 alignment: Alignment.center,
                 height: 40,
                 decoration: BoxDecoration(
                   color: const Color(0xff3489EF),
                   borderRadius: BorderRadius.circular(10)
                 ),
                 child: Text(
                   DateFormat('MMMM yyyy', LocalizationService.isArabic(context: context)? "ar" : "en").format(DateTime.parse(createAt)).toString(),
                   style: const TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: Color(0xffFFFFFF),
                   ),
                 ),
               ),
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: ListView.separated(
                    shrinkWrap: true,
                    reverse: false,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) =>eva[index]['gained_points'] != null? Column(
                      children: [
                        Text("${eva[index]['employee_name']} (${eva[index]['created_at']})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),),
                        const SizedBox(height: 10,),
                        Text("${AppStrings.totalEvalutaions.tr().toUpperCase()} : ${eva[index]['gained_points']?.toString() ?? 0}/${eva[index]['total_points']?.toString() ?? 0}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12),),
                      ],
                    ): const SizedBox.shrink(), separatorBuilder: (context, index) => const SizedBox(height: 20,), itemCount: eva.length),
              )
            ],
          ),
        );
      },
    );
  }

}
class ProfileTileNotTap extends StatelessWidget {
  final String title;
  final String? trailingTitle;
  final bool? isTitleOnly;
  bool? isViewArrow = true;
  final Widget? icon;
  var url;
  var eva;
  var createAt;
  var totalPoints;
  var gainedPoints;
  final double? marginBottom;
  ProfileTileNotTap({
    super.key,
    this.totalPoints,
    this.eva,
    this.gainedPoints,
    this.icon,
    this.createAt,
    this.url,
    this.isViewArrow,
    this.marginBottom,
    this.trailingTitle,
    this.isTitleOnly = true,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom ?? AppSizes.s12),
      padding: const EdgeInsets.symmetric(
          vertical: AppSizes.s12, horizontal: AppSizes.s10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.s8),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    icon ?? const SizedBox.shrink(),
                    gapW4,
                    SizedBox(
                        width: !kIsWeb? MediaQuery.sizeOf(context).width * 0.7 : MediaQuery.sizeOf(context).width * 0.3,
                        child: Text(title,style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: Color(AppColors.black)))),
                    gapW12,
                    if(isViewArrow == true) const Spacer(),
                   if(isViewArrow == true) const CircleAvatar(
                      backgroundColor: Color(0xff3489EF),
                      radius: 12,
                      child: Icon(Icons.arrow_forward_sharp,color: Colors.white, size: 10,),
                    )
                  ],
                ),
    );
  }
  void showEvaluationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          height: MediaQuery.sizeOf(context).height * 0.6,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(AppStrings.evaluationsInfo.tr(),style: const TextStyle(fontSize: 20, color: Color(AppColors.dark), fontWeight: FontWeight.w600),),
               const SizedBox(height: 15,),
               Container(
                 width: double.infinity,
                 alignment: Alignment.center,
                 height: 40,
                 decoration: BoxDecoration(
                   color: const Color(0xff3489EF),
                   borderRadius: BorderRadius.circular(10)
                 ),
                 child: Text(
                   DateFormat('MMMM yyyy', LocalizationService.isArabic(context: context)? "ar" : "en").format(DateTime.parse(createAt)).toString(),
                   style: const TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                     color: Color(0xffFFFFFF),
                   ),
                 ),
               ),
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: ListView.separated(
                    shrinkWrap: true,
                    reverse: false,
                    padding: EdgeInsets.zero,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) =>eva[index]['gained_points'] != null? Column(
                      children: [
                        Text("${eva[index]['employee_name']} (${eva[index]['created_at']})", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),),
                        const SizedBox(height: 10,),
                        Text("${AppStrings.totalEvalutaions.tr().toUpperCase()} : ${eva[index]['gained_points']?.toString() ?? 0}/${eva[index]['total_points']?.toString() ?? 0}", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 12),),
                      ],
                    ): const SizedBox.shrink(), separatorBuilder: (context, index) => const SizedBox(height: 20,), itemCount: eva.length),
              )
            ],
          ),
        );
      },
    );
  }

}
class ProfileTileEvaReq extends StatelessWidget {
  final String title;
  final String createAt;
  final String empName;
  final String department;
  final String name;
  var icon;
  var url;
  ProfileTileEvaReq({
    super.key,
    this.url,
    this.icon,
    required this.department,
    required this.title, required this.createAt, required this.empName, required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()async{
        if(url != null){
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        }else{
          return;
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSizes.s12),
        padding: const EdgeInsets.symmetric(
            vertical: AppSizes.s12, horizontal: AppSizes.s10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.s8),
            border: Border.all(color: Colors.grey.withOpacity(0.1))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xff09051C))),
                          Text("$empName - $department",style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12, color: Color(0xff707070))),
                          Text(name,style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xff707070))),

                        ],
                      ),
                      const Spacer(),
                      icon
                    ],
                  ),
      ),
    );
  }
}
