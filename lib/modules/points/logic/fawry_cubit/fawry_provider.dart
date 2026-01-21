import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:app_test/constants/app_colors.dart';
import 'package:app_test/constants/app_sizes.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:app_test/general_services/alert_service/alerts.service.dart';
import 'package:app_test/general_services/app_config.service.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/general_services/birthday_checker.service.dart';
import 'package:app_test/general_services/localization.service.dart';
import 'package:app_test/general_services/settings.service.dart';
import 'package:app_test/models/settings/user_settings.model.dart';
import 'package:app_test/models/settings/user_settings_2.model.dart';
import 'package:provider/provider.dart';

import '../../../../constants/user_consts.dart';
import '../../../../general_services/app_theme.service.dart';
import '../../../../utils/componentes/general_components/all_bottom_sheet.dart';

class FawryProviderModel extends ChangeNotifier {
  bool isGetFawryCategoryLoading = false;
  bool isPostPayLoading = false;
  bool isGetInquerySuccess = false;
  bool isLoading = true;
  int? selectIndix;
  bool isGetNotificationSuccess = false;
  bool hasMoreNotifications = true; // Track if there are more notifications to load
  String? getNotificationErrorMessage;
  Map<String, TextEditingController> controllers = {};
  Map<String, FocusNode> focusNodes = {};
  Map<String, dynamic> inputValues = {};
  Map<String, String?> dropdownValues = {};
  Map<String, String?> dropdownTitles = {};
  List fawryCategory = [];
  List fawryInqury = [];
  DateTime? birthDate;
  double cachedFee = 0;
  FocusNode numberOfPointsFocusNode = FocusNode();
  FocusNode rechargeAmountFocusNode = FocusNode();
  FocusNode fieldFocusNode = FocusNode();
  TextEditingController numberOfPointsController = TextEditingController();
  TextEditingController rechargeAmountController = TextEditingController();
  void setInputValue(String key, dynamic value) {
    inputValues[key] = value;
    notifyListeners();
  }

  dynamic getInputValue(String key) => inputValues[key];
  void updateLoadingStatus({required bool laodingValue}) {
    isLoading = laodingValue;
    notifyListeners();
  }
  Future<void> initializeHomeScreen(BuildContext context, {bool closeDate = false}) async {
    updateLoadingStatus(laodingValue: true);
    final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
    // if (appConfigServiceProvider.isLogin != true ||
    //     appConfigServiceProvider.token.isEmpty) {
    //   return;
    // }
    // initialize [userSettings] and [userSettings2] after chackings about token
    await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(
        allData: true, context: context,);
    if (!context.mounted) return;
    UserSettingConst.userSettings = AppSettingsService.getSettings(
        settingsType: SettingsType.userSettings,
        context: context) as UserSettingsModel;
    UserSettingConst.userSettings2 = AppSettingsService.getSettings(
        settingsType: SettingsType.user2Settings,
        context: context) as UserSettings2Model;
    // get user requests
    //await _getAllUserRequests(context);
    // await _getUserNotification(context);
    // Checking for user BirthDate
    try {
      final userBirthDate = UserSettingConst.userSettings?.birthDate;
      if (userBirthDate != null) {
        // intialize Birthday Service Checker
        BirthdayChecker.checkBirthday(
            context: context,
            birthDate: ((AppSettingsService.getSettings(
                settingsType: SettingsType.userSettings,
                context: context)) as UserSettingsModel)
                .birthDate);
      }
    } catch (err, t) {
      debugPrint("error while checking on user birthday $err at :- $t");
    }
    updateLoadingStatus(laodingValue: false);
  }

  Future<void> refreshPaints(context) async {
    await getFawryCategory(context);
  }

  void updateFee(Map<String, dynamic> service, double amount) {
    cachedFee = calcFees(service, amount);
    notifyListeners();
  }

  double calcFees(Map<String, dynamic> service, double amount) {
    print("service is --> $service");
    List<dynamic> rules = [];

    try {
      rules = service['fees'] != null
          ? List<Map<String, dynamic>>.from(service['fees'])
          : [];
    } catch (e) {
      rules = [];
    }

    // Step 1: Find applicable domain (max "from" <= amount)
    List<double> froms = rules.map((r) => (r['from'] as num).toDouble())
        .toList();
    List<double> validFroms = froms.where((f) => f <= amount).toList();

    double? domain = validFroms.isEmpty ? null : validFroms.reduce((a, b) =>
    a > b ? a : b);

    // Step 2: If a domain was found, apply its rules
    double totalFee = 0;

    if (domain != null) {
      for (var rule in rules) {
        if ((rule['from'] as num).toDouble() == domain) {
          if (rule['percentage'] == true) {
            totalFee += ((rule['value'] as num).toDouble() / 100) * amount;
          } else {
            totalFee += (rule['value'] as num).toDouble();
          }
        }
      }
    }
    print("totalFee --> ${totalFee.toString()}");
    return totalFee;
  }

  Future<void> getFawryCategory(BuildContext context) async {
    isGetFawryCategoryLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/rm_fawry/v1/categories",
        context: context,
      );
      if (response.data['status'] == true) {
        fawryCategory = response.data['categories'] ?? [];
      } else {
        AlertsService.error(
            title: AppStrings.failed.tr(),
            context: context,
            message: response.data['message']);
      }
      isGetFawryCategoryLoading = true;
      notifyListeners();
    } catch (error) {
      getNotificationErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isGetFawryCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> getInquryCategory(BuildContext context, {
    id,
  }) async {
    isGetFawryCategoryLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_fawry/v1/inquiry",
        data: {
          "service_id": id.toString(),
          ...inputValues
        },
        context: context,
      );
      if (response.data['status'] == true) {
        fawryInqury = response.data['inquiryResult'] ?? [];
        if(fawryInqury.isNotEmpty){
          isGetInquerySuccess = true;
          if(fawryInqury.length == 1){
            selectIndix = 0;
          }else{
            selectIndix = null;
          }
        }
      } else {
        Future.delayed(Duration.zero, () {
          if (context.mounted) {
            AlertsService.error(
              title: AppStrings.failed.tr(),
              context: context,
              message: response.data['message'],
            );
          }else{
            Fluttertoast.showToast(
                msg:response.data['message'],
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
        });

      }
      isGetFawryCategoryLoading = false;
      notifyListeners();
    } catch (error) {
      getNotificationErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isGetFawryCategoryLoading = false;
      notifyListeners();
    }
  }
  Future<void> postPay(BuildContext context, {id, payAmount, inquiryId, inputsValues}) async {
    isPostPayLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.postData(
        url: "/rm_fawry/v1/transaction",
        data: {
          "service_id": id.toString(),
          if(inquiryId != null && inquiryId.toString().isNotEmpty)"inquiryId" : inquiryId.toString(),
          "payAmount" : payAmount.toString(),
          ...inputsValues
        },
        context: context,
      );
      if (response.data['status'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          initializeHomeScreen(context);
        });
        defaultActionBottomSheet2(
          fieldFocusNode: fieldFocusNode,
            context: context,
            home: false,
            view : false , view2Button :false ,
            widgets:
            response.data['code'] != null && response.data['code'].toString() != ""?
            Container(
              height: 50,
              alignment: Alignment.center,
              padding:  EdgeInsets.only(left:LocalizationService.isArabic(context: context) ?0 : 16 ,right: LocalizationService.isArabic(context: context) ?16 : 0),
              decoration: ShapeDecoration(
                color: AppThemeService.colorPalette.tertiaryColorBackground.color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSizes.s10),
                  side: const BorderSide(
                    color: Color(0xffE3E5E5),
                    width: 1.0,
                  ),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x0C000000),
                    blurRadius: 10,
                    offset: Offset(0, 1),
                    spreadRadius: 0,
                  )
                ],
              ),
              child: Row(
                children: [
                  Text(response.data['code'].toString(), style: TextStyle(fontWeight: FontWeight.w400,
                      fontSize: 12, color: Color(AppColors.grey50)),),
                  const Spacer(),
                  GestureDetector(
                    onTap: (){
                      copyToClipboard(context, text: response.data['code'].toString());
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color(0xffE8E8E8)
                      ),
                      child: Text(AppStrings.copy.tr(), style:  const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w400),),
                    ),
                  )
                ],
              ),
            ) : null,
            buttonText: AppStrings.goToHome.tr(),
            onTapButton: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            bottomSheetHeight:(response.data['code'] != null &&
                response.data['code'].toString().isNotEmpty)? MediaQuery.sizeOf(context).height * 0.65:MediaQuery
                .of(context)
                .size
                .height * 0.52,
            title: response.data['message'],
            subTitle: "",
            viewCheckIcon: true,
            headerIcon: Image.asset("assets/images/png/bill_success.png", height: 42, width: 40,)
        );
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Fluttertoast.showToast(
              msg: response.data['message'],
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
        });
      }
      isPostPayLoading = true;
      notifyListeners();
    } catch (error) {
      getNotificationErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isPostPayLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDateField(BuildContext context, String key) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      locale: Locale(LocalizationService.isArabic(context: context) ? 'ar' : 'en'),
    );

    if (picked != null) {
      final outputFormat = DateFormat('yyyy-MM-dd');
      final outputDate = outputFormat.format(picked);

      controllers[key]?.text = outputDate; // ✅ يكتب في الـ TextFormField
      inputValues[key] = outputDate;       // ✅ يخزن القيمة

      notifyListeners(); // ← لو بتستخدم Consumer أو Provider
      print("📅 $key selected: $outputDate");
    }
  }

}