import 'package:flutter/material.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:rmemp/general_services/url_launcher.service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../constants/app_sizes.dart';
import '../../../models/employee_profile.model.dart';
import '../employee_social_icons.widget.dart';
import '../profile_tile.widget.dart';

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
    return Column(
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
          EmployeeSocialContacts(socialData: employee?.social)
      ],
    );
  }
}
