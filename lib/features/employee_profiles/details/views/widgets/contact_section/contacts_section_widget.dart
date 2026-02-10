import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/url_launcher_service.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widget/employee_social_icons_widget.dart';

class ContactsSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  const ContactsSectionWidget({super.key, required this.employee});
  Future<void> sendMailToCompany(
      {required BuildContext context,
        required String email,
        required String? subject,
        required String? body}) async {
    if (email.isEmpty) return;
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${subject ?? 'Contact From Application'}&body=${body ?? 'Hello'}',
    );
    var url = params.toString();
    await UrlLauncherServiceEx.launch(context: context, url: url);
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: (kIsWeb || PlatformIs.web) ? AppSizes.s32 : 0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          gapH16,
        if (employee?.phone != null)
          GestureDetector(
            onTap: () async {
              final String phoneNumber =
                  'tel:${employee?.phone.toString()}'; // Replace with the phone number you want to call
              if (await canLaunch(phoneNumber)) {
                await launch(phoneNumber);
              } else {
                throw 'Could not launch $phoneNumber';
              }
            },
            child: ProfileTile(
              title:   employee!.countryKey != null?
              LocalizationService.isArabic(context: context)?  '${employee!.phone!}(${employee!.countryKey ?? ''}+)':'(+${employee!.countryKey ?? ''})${employee!.phone!}'
                  : '${employee!.phone!}' ),
          ),
        if (employee?.additionalPhoneNumbers != null &&
            employee?.additionalPhoneNumbers?.isNotEmpty == true)
          ...employee!.additionalPhoneNumbers!.map((phoneNum) =>phoneNum.visible != "hide"? GestureDetector(
            onTap: () async {
              final String phoneNumber =
                  'tel:${phoneNum.phone.toString()}'; // Replace with the phone number you want to call
              if (await canLaunch(phoneNumber)) {
                await launch(phoneNumber);
              } else {
                throw 'Could not launch $phoneNumber';
              }
            },
            child: ProfileTile(
                  title: phoneNum.phone!,
                ),
          ): const SizedBox.shrink()),
        if (employee?.email != null && employee?.email?.isNotEmpty == true)
          GestureDetector(
            onTap: () async {
              sendMailToCompany(
                  context: context,
                  email: employee!.email.toString(),
                  subject: null,
                  body: null);
            },
            child: ProfileTile(
              title: employee?.email ?? '',
            ),
          ),
        if (employee?.social != null)
          EmployeeSocialContacts(socialData: employee?.social),
        SizedBox(height: (kIsWeb || PlatformIs.web) ? AppSizes.s24 : 0),
      ],
      ),
    );
  }
}
