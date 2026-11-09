import 'package:app_test/features/points/controllers/fawry_controller/fawry_controller.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/button_widget.dart';
import 'package:app_test/core/constants/app_design.dart';

class ChargePhoneBottomBar extends StatelessWidget {
  var serviceId;
  ChargePhoneBottomBar({this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FawryController>(
      builder: (context, value, child) {
        return Container(
          height: 136,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.raised,
          ),
          padding: const EdgeInsets.all(16.0),
          child: (value.isPostPayLoading == false)?ButtonWidget(
            title:
            "${AppStrings.pay.tr().toUpperCase()} ${value.numberOfPointsController.text.isNotEmpty? value.numberOfPointsController.text : "0"  } ${AppStrings.point.tr().toUpperCase()}",
            svgIcon: "assets/images/svg/wallet.svg",
            onPressed: () {
              value.postPay(context,
                id: serviceId.toString(),
                inputsValues: value.inputValues,
                payAmount: value.rechargeAmountController.text,
              );
            },
            padding: EdgeInsets.zero,
            fontSize: 12,
          ) : const CircularProgressIndicator(),
        );
      },
    );
  }
}
