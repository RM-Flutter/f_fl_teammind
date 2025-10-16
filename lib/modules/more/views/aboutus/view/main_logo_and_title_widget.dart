import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class MainLogoAndTitleWidget extends StatelessWidget {
  const MainLogoAndTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Center(
          child: SizedBox(
            height: 177,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(60),
                bottomLeft: Radius.circular(60),
              ),
              child: Image.asset("assets/images/app_logo.png"),
            ),
          ),
        ),
      ],
    );
  }
}
