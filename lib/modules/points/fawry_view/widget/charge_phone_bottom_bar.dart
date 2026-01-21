import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../../../../common_modules_widgets/button_widget.dart';
import '../../logic/fawry_cubit/fawry_provider.dart';

class ChargePhoneBottomBar extends StatelessWidget {
  var serviceId;
  ChargePhoneBottomBar({super.key, this.serviceId});

  @override
  Widget build(BuildContext context) {
    return Consumer<FawryProviderModel>(
      builder: (context, value, child) {
        return Container(
          height: 136,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xff000000).withOpacity(0.1),
                  blurRadius: 11,
                  spreadRadius: 0,
                  offset: const Offset(0, -4))
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: (value.isPostPayLoading == false)?ButtonWidget(
            title:
            "${AppStrings.pay.tr().toUpperCase()} ${value.numberOfPointsController.text.isNotEmpty?
            value.numberOfPointsController.text : "0"  } ${AppStrings.point.tr().toUpperCase()}",
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
