import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:provider/provider.dart';
import '../../../utils/componentes/general_components/all_text_field.dart';
import '../../home/view_models/home.viewmodel.dart';
import '../logic/prize_cubit/prize_provider.dart';


class DropDownAndButtonBottomSheet extends StatefulWidget {
  const DropDownAndButtonBottomSheet({super.key});

  @override
  State<DropDownAndButtonBottomSheet> createState() => _DropDownAndButtonBottomSheetState();
}

class _DropDownAndButtonBottomSheetState extends State<DropDownAndButtonBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
        builder: (context, value, child) {
          return Consumer<PrizeProvider>(
            builder: (context, provider, child) {
              // if(provider.radeemPrize == true){
              //   WidgetsBinding.instance.addPostFrameCallback((_) {
              //     if (context.mounted) {
              //       value.initializeHomeScreen(context);
              //     }
              //   });
              //   provider.radeemPrize = false;
              // }
              if (provider.isLoading == true) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              else{
                if (provider.prizeModel!.status == true) {
                  return Column(
                    children: [
                      defaultDropdownField(
                        value: provider.prize,
                        title: provider.prize ?? AppStrings.chooseThePrize.tr(),
                        items: provider.prizeModel!.prizes!.map(
                              (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style:  const TextStyle(
                                fontFamily: "Poppins",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xff464646)
                            ),),
                          ),
                        ).toList(),
                        onChanged: (String? value) {
                          debugPrint(value);
                          setState(() {
                            provider.prize = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 30,),
                      if(provider.status == RedeemPrizeStatus.loading)const Center(
                        child: CircularProgressIndicator(),
                      ),
                      if(provider.status != RedeemPrizeStatus.loading) GestureDetector(
                        onTap: (){
                          provider.redeemPrize(prizeName: Provider.of<PrizeProvider>(context, listen: false).prize!).then((value) {
                            if (provider.redeemPrizeModel!.status == true) {
                              Fluttertoast.showToast(
                                  msg: provider.redeemPrizeModel!.message!,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                              Navigator.pop(context);
                            }else{
                              Fluttertoast.showToast(
                                  msg: provider.redeemPrizeModel!.message!,
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                              Navigator.pop(context);
                            }
                          },);
                        },
                        child: Container(
                          height: 50,
                          width: 224,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D3B6F),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset("assets/images/png/icon.png"),
                              gapW4,
                              Text(AppStrings.redeemNow.tr().toUpperCase(),style:  const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),)
                            ],
                          ),
                        ),
                      )
                    ],
                  );
                }  else{
                  return Text(AppStrings.failed.tr().toUpperCase());
                }
              }

            },
          );
        },
    );
  }
}