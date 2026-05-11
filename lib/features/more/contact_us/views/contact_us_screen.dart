import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/more/contact_us/controllers/contact_us_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  int selectIndex = 0;
  var gCache;
  Future<void> openGoogleMaps({double? latitude, double? longitude}) async {
    final googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not open Google Maps.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ContactUsController(),
      child: Consumer<ContactUsController>(
        builder: (context, values, child) {
          final jsonString = CacheHelper.getString("USG");
          if (jsonString != null) {
            gCache = json.decode(jsonString)
                as Map<String, dynamic>; // Convert String back to JSON
          }
          debugPrint("gCache['company_contacts'] --> ${gCache['company_contacts']}");
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/png/contact_back.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Scaffold( resizeToAvoidBottomInset: false,
                  backgroundColor: Colors.transparent,
                  appBar: AppBar(
                    backgroundColor: Colors.transparent,
                    surfaceTintColor: Colors.transparent,
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                    title: Text(
                      AppStrings.contactUs.tr().toUpperCase(),
                      style: AppStyles.whiteHeading(context).copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                  body: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,

                    physics: const ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Center(
                      child: SizedBox(
                        height: 1.sh,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 30.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 50.h),
                              if(gCache['company_contacts']['phone'] != null && (gCache['company_contacts']['otherphones'].isNotEmpty && gCache['company_contacts']['otherphones'] != null))Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/svg/contact-phone.svg", height: 20.r, width: 20.r,),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.phone.tr().toUpperCase(),
                                        style: AppStyles.whiteHeading(context).copyWith(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18.sp),
                                      ),
                                      SizedBox(
                                        height: 10.h,
                                      ),
                                      GestureDetector(
                                          onTap: () async {
                                            final String phoneNumber =
                                                'tel:${gCache['company_contacts']['phone']}'; // Replace with the phone number you want to call
                                            if (await canLaunch(phoneNumber)) {
                                              await launch(phoneNumber);
                                            } else {
                                              throw 'Could not launch $phoneNumber';
                                            }
                                          },
                                          child: Text(
                                            "${AppStrings.hotline.tr().toUpperCase()} ${gCache['company_contacts']['phone']}",
                                            style: AppStyles.whiteContent(context).copyWith(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp),
                                          )),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      SizedBox(
                                        width: 0.6.sw,
                                        child: ListView.separated(
                                            shrinkWrap: true,
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            reverse: false,
                                            scrollDirection: Axis.vertical,
                                            itemBuilder: (context, index) =>
                                                GestureDetector(
                                                    onTap: () async {
                                                      final String phoneNumber =
                                                          'tel:${gCache['company_contacts']['otherphones'][index]}'; // Replace with the phone number you want to call
                                                      if (await canLaunch(
                                                          phoneNumber)) {
                                                        await launch(
                                                            phoneNumber);
                                                      } else {
                                                        throw 'Could not launch $phoneNumber';
                                                      }
                                                    },
                                                    child: Text(
                                                      "${gCache['company_contacts']['otherphones'][index]}",
                                                      style: AppStyles.whiteContent(context).copyWith(
                                                          fontWeight:
                                                          FontWeight.w400,
                                                          fontSize: 14.sp),
                                                    )),
                                            separatorBuilder:
                                                (context, index) => SizedBox(
                                              height: 5.h,
                                            ),
                                            itemCount:
                                            gCache['company_contacts']
                                            ['otherphones']
                                                .length),
                                      )
                                    ],
                                  )
                                ],
                              ),
                              if(gCache['company_contacts']['phone'] != null && (gCache['company_contacts']['otherphones'].isNotEmpty && gCache['company_contacts']['otherphones'] != null)) SizedBox(
                                height: 20.h,
                              ),
                              if(gCache['company_contacts']['branches'] != null && gCache['company_contacts']['branches'].isNotEmpty) Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/svg/contact-address.svg", height: 20.r, width: 20.r,),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SizedBox(
                                    width: 0.6.sw,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.address.tr().toUpperCase(),
                                          style: AppStyles.whiteHeading(context).copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18.sp),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        ListView.separated(
                                            shrinkWrap: true,
                                            scrollDirection: Axis.vertical,
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            itemBuilder: (context, index) =>
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      LocalizationService
                                                          .isArabic(
                                                          context:
                                                          context)
                                                          ? gCache['company_contacts']['branches']
                                                      [index]
                                                      ['title']['ar']
                                                          : gCache['company_contacts']['branches'][index]['title']['en'],
                                                      style: AppStyles.whiteHeading(context).copyWith(
                                                          fontWeight:
                                                          FontWeight.w700,
                                                          fontSize: 14.sp),
                                                    ),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    SizedBox(
                                                        width: 0.6.sw,
                                                        child: Text(
                                                          LocalizationService.isArabic(context: context)
                                                              ? "${gCache['company_contacts']['branches'][index]['co_info_address']['ar']}"
                                                              : "${gCache['company_contacts']['branches'][index]['co_info_address']['en']}",
                                                          style: AppStyles.whiteContent(context).copyWith(
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400,
                                                              fontSize: 14.sp),
                                                        )),
                                                    SizedBox(
                                                      height: 5.h,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await openGoogleMaps(
                                                          latitude: double.parse(
                                                              gCache['company_contacts']['branches'][index]['lat']),
                                                          longitude: double.parse(
                                                              gCache['company_contacts']['branches'][index]['lng']),
                                                        );
                                                      },
                                                      child: Container(
                                                        height: 17.h,
                                                        width: 78.w,
                                                        alignment:
                                                        Alignment.center,
                                                        decoration: BoxDecoration(
                                                            color: const Color(
                                                                0xffFFFFFF)
                                                                .withOpacity(
                                                                0.2),
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                50.r)),
                                                        child: Text(
                                                          AppStrings.showMap
                                                              .tr(),
                                                          style: AppStyles.whiteContent(context).copyWith(
                                                              fontSize: 10.sp,
                                                              fontWeight:
                                                              FontWeight
                                                                  .w400),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                            separatorBuilder:
                                                (context, index) => SizedBox(
                                              height: 10.h,
                                            ),
                                            itemCount:
                                            gCache['company_contacts']
                                            ['branches']
                                                .length),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if(gCache['company_contacts']['branches'] != null && gCache['company_contacts']['branches'].isNotEmpty) SizedBox(
                                height: 20.h,
                              ),
                              if(gCache['company_contacts']['otheremails'] != null && gCache['company_contacts']['otheremails'].isNotEmpty) Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SvgPicture.asset(
                                    "assets/images/svg/contact-email.svg", height: 20.r, width: 20.r,),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  SizedBox(
                                    width: 0.6.sw,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.email.tr().toUpperCase(),
                                          style: AppStyles.whiteHeading(context).copyWith(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18.sp),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        //whatsAppConversationStarterMessage en/ar
                                        ListView.separated(
                                            padding: EdgeInsets.zero,
                                            physics: const NeverScrollableScrollPhysics(),
                                            reverse: false,
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) => GestureDetector(
                                              onTap: () async {
                                                values.sendMailToCompany(
                                                    context: context,
                                                    email: gCache['company_contacts']['otheremails'][index],
                                                    subject: null,
                                                    body: null);
                                              },
                                              child: SizedBox(
                                                  width: 0.6.sw,
                                                  child: Text(
                                                    gCache['company_contacts']['otheremails'][index]??"",
                                                    style: AppStyles.whiteContent(context).copyWith(
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 14.sp),
                                                  )),
                                            ),
                                            separatorBuilder: (context, index) => SizedBox(height: 5.h,),
                                            itemCount: gCache['company_contacts']['otheremails'].length)
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              if(gCache['company_contacts']['otheremails'] != null && gCache['company_contacts']['otheremails'].isNotEmpty)SizedBox(
                                height: 50.h,
                              ),
                              Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.followUs.tr().toUpperCase(),
                                      style: AppStyles.whiteHeading(context).copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.sp),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    SizedBox(
                                      height: 60.h,
                                      child: Wrap(
                                        spacing: 10.w,
                                        runSpacing: 10.h,
                                        children: [
                                          if (gCache['company_contacts']['whatsapp'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['whatsapp'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/whatsapp.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['whatsapp']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']['linkedin'] != null && gCache['company_contacts']['linkedin'] != "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/linkedin.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['linkedin']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']
                                          ['youtube'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['youtube'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/youtube.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['youtube']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']
                                          ['instagram'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['instagram'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/instagram.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['instagram']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']
                                          ['facebook'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['facebook'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/facebook.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['facebook']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']
                                          ['tiktok'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['tiktok'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/tiktok.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['tiktok']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']
                                          ['twitter'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['twitter'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/twitter.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['twitter']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                          if (gCache['company_contacts']
                                          ['messenger'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['messenger'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/messenger.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['messenger']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),if (gCache['company_contacts']
                                          ['snapchat'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['snapchat'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/snapchat.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['snapchat']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),if (gCache['company_contacts']
                                          ['telegram'] !=
                                              null &&
                                              gCache['company_contacts']
                                              ['telegram'] !=
                                                  "")
                                            defaultCircularSocial(
                                                src:
                                                "assets/images/svg/telegram.svg",
                                                onTap: () async {
                                                  await launchUrl(
                                                      Uri.parse(gCache[
                                                      'company_contacts']
                                                      ['telegram']),
                                                      mode: LaunchMode
                                                          .externalApplication);
                                                }),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 30.h,
                                    ),
                                    if (gCache['company_contacts']['email'] != null)
                                      CustomElevatedButton(
                                        title: AppStrings.sendEmail.tr(),
                                        onPressed: () async {
                                          values.sendMailToCompany(
                                              context: context,
                                              email: gCache['company_contacts']['email'],
                                              subject: null,
                                              body: null);
                                        },
                                        isPrimaryBackground: false,
                                      ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget defaultCircularSocial({onTap, src}) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          padding: EdgeInsets.all(5.r),
          height: 30.r,
          width: 30.r,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Color(AppColors.buttons)),
          child: SvgPicture.asset(src, color: Colors.white),
        ),
      );
}
