import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

abstract class BirthdayChecker {
  static Future<void> checkBirthday(
      {required BuildContext context, required DateTime? birthDate}) async {
    if (birthDate == null) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String lastShownDate =
        prefs.getString('lastBirthdayMessageDate') ?? '';

    // Check if today is the user's birthday and the message was not shown today
    if (DateFormat('MM-dd').format(DateTime.now()) ==
        DateFormat('MM-dd').format(birthDate) &&
        today != lastShownDate) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('happy_birthday'.tr()),
            content: Text('${'birthday_wishes'.tr()} 🎉'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('thank_you'.tr()),
              ),
            ],
          );
        },
      );

      // Record the date to avoid showing the message again today
      await prefs.setString('lastBirthdayMessageDate', today);
    }
  }
}
