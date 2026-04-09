import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/more/user_device/controllers/user_device_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:provider/provider.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
class CustomizeNotificationScreen extends StatefulWidget {
  const CustomizeNotificationScreen({super.key});

  @override
  State<CustomizeNotificationScreen> createState() => _CustomizeNotificationScreenState();
}

class _CustomizeNotificationScreenState extends State<CustomizeNotificationScreen> {
  bool isActive = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DeviceControllerProvider()..getDeviceSysGet(context: context),
      child: Consumer<DeviceControllerProvider>(
        builder: (context, value, child) {
          if(value.isSuccess == true){
            WidgetsBinding.instance.addPostFrameCallback((_) async{
              Navigator.pop(context);
            });
            value.isSuccess = false;
          }
          return (value.isLoading)?
          const SizedBox.shrink() :
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppStrings.customizeNotifications.tr().toUpperCase(), style: AppStyles.heading(context).copyWith(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff0D3B6F)
                  ),),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SwitchRow(
                        isLoginPageStyle: true,
                        value: value.notificationStatus,
                        onChanged: (newValue)  {
                          setState(() {
                            value.notificationStatus = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  if(value.isLoading2)const Center(child: CircularProgressIndicator(),),
                  if(!value.isLoading2)SizedBox(
                    width: 0.6.sw,
                    child: GestureDetector(
                      onTap: (){
                        value.getDeviceSysSet(
                          context: context,
                          state: value.notificationStatus,
                        );
                      },
                      child: Container(
                        height: 50.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xff0D3B6F),
                          borderRadius: BorderRadius.circular(50.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/images/svg/apply_filter.svg"),
                            SizedBox(width: 15.w,),
                            Text(
                              AppStrings.saveChanges.tr().toUpperCase(),
                              style: AppStyles.whiteContent(context).copyWith(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xffFFFFFF)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
class SwitchRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? rightText;
  final String? leftText;
  final bool? isLoginPageStyle;

  const SwitchRow({
    super.key,
    required this.value,
    required this.onChanged,
    this.rightText,
    this.leftText,
    this.isLoginPageStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(AppStrings.deactivate.tr().toUpperCase(),
              style: AppStyles.primaryContent(context).copyWith(
                  fontSize: 11.sp, color: const Color(0xff224982), fontWeight: FontWeight.w500)),
          gapW8,
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xff224982),
            inactiveThumbColor: Colors.black,
          ),
          gapW8,
          Text(AppStrings.activation.tr().toUpperCase(),
              style: AppStyles.primaryContent(context).copyWith(
                  fontSize: 11.sp, color: const Color(0xff224982), fontWeight: FontWeight.w500)),

        ],
      ),
    );
  }
}

