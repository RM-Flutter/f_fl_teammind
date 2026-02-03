import 'package:flutter/material.dart';
import 'package:rmemp/general_services/url_launcher.service.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsController extends ChangeNotifier{
 bool isLoading = false;
 bool isSuccess = false;
 String? errorMessage;


 Future<void> sendMailToCompany({
   required BuildContext context,
   required String email,
   required String? subject,
   required String? body,
 }) async {
   if (email.isEmpty) return;

   final Uri emailUri = Uri(
     scheme: 'mailto',
     path: email,
     queryParameters: {
       'subject': subject ?? 'Contact From Application',
       'body': body ?? 'Hello',
     },
   );

   if (await canLaunchUrl(emailUri)) {
     await launchUrl(emailUri);
   } else {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text("لا يمكن فتح تطبيق البريد")),
     );
   }
 }

}

