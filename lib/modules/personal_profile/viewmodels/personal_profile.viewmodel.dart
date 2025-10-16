import 'dart:convert';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../common_modules_widgets/custom_elevated_button.widget.dart';
import '../../../constants/app_sizes.dart';
import '../../../constants/app_strings.dart';
import '../../../general_services/alert_service/alerts.service.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/date.service.dart';
import '../../../general_services/image_file_picker.service.dart';
import '../../../general_services/layout.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../general_services/validation_service.dart';
import '../../../models/settings/user_settings.model.dart';
import '../services/personal_profile.service.dart';

class PersonalProfileViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccess = false;
  bool isSuccessUpdate = false;
  bool deleteImage = false;
  bool isSuccessUpdateImage = false;
  String? errorMessage;
  String? uuid;
  TextEditingController emailController = TextEditingController();
  TextEditingController faController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController birthDateController = TextEditingController();
  TextEditingController passwordForRemoveAccountController =
  TextEditingController();
  TextEditingController countryCodeController = TextEditingController();
  String? initialCountry;
  DateTime? birthDate;
  List<XFile>? selectedAvatar = [];
  final GlobalKey<FormState> form1Key = GlobalKey<FormState>();
  final GlobalKey<FormState> form2Key = GlobalKey<FormState>();
  final GlobalKey<FormState> form3Key = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  final double pageLeftRightPadding = AppSizes.s14;
  final double backgroundHeight = AppSizes.s270;
  final double notchedContainerHeight = AppSizes.s200;
  final double notchRadius = AppSizes.s50;
  final double notchPadding = AppSizes.s4;

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    nameController.dispose();
    birthDateController.dispose();
    passwordForRemoveAccountController.dispose();
    countryCodeController.dispose();
    scrollController.dispose();
    super.dispose();
  }
  updatePassword({context,password}){
    isLoading = true;
    notifyListeners();
    DioHelper.postData(
        url: "/rm_users/v1/update_password",
        context: context,
        data: {
          "password" : password
        }
    ).then((value){
      print(value.data);
      isLoading = false;
      notifyListeners();
      if(value.data['errors'] !=null){
        AlertsService.error(
            context: context,
            message: value.data['errors']['password'][0] !,
            title: AppStrings.failed.tr());
      }else{
        isSuccess = true;
        AlertsService.success(
            context: context,
            message: value.data['message'],
            title: AppStrings.success.tr());}
    }).catchError((error){
      isLoading = false;
    AlertsService.error(
        context: context,
        message: AppStrings.errorPleaseTryAgain.tr(),
        title: AppStrings.failed.tr().toUpperCase());
    if (error is DioError) {
      errorMessage = error.response?.data['message'] ?? AppStrings.failed.tr();
    } else {
      errorMessage = error.toString();
    }
    AlertsService.error(
        context: context,
        message: errorMessage!,
        title: AppStrings.failed.tr().toUpperCase());
    });
  }
  Future<void> initializePersonalProfileScreen(
      {required BuildContext context}) async {
    updateLoading(true);
    // First get current user Data
    var jsonString;
    UserSettingsModel userSettingsModel;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    userSettingsModel = UserSettingsModel.fromJson(gCache);
    UserSettingConst.userSettings = userSettingsModel;

    //set initial values for fields
    setInititalValues();
    updateLoading(false);
  }

  setInititalValues() {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    if (UserSettingConst.userSettings == null) return;
    emailController.text = UserSettingConst.userSettings?.email ?? '';
    phoneNumberController.text = UserSettingConst.userSettings?.phone ?? '';
    nameController.text = UserSettingConst.userSettings?.name ?? '';
    birthDateController.text = UserSettingConst.userSettings?.birthDate == null ? ""
        : DateService.formatDateTime(UserSettingConst.userSettings?.birthDate);
  }

  void updateLoading(bool newVal) {
    isLoading = newVal;
    notifyListeners();
  }
  List<Map<String, dynamic>> listProfileImage = [];
  List<XFile> listXProfileImage = [];
  XFile? XImageFileProfile;
  File? profileImage;
  final picker = ImagePicker();
  Future<File?> _compressImage(File file) async {
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 600,
      minHeight: 600,
    );
    return result != null ? File(result.path) : null;
  }

  Future<void> getProfileImageByCam() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.camera);
    if (imageFileProfile == null) return;

    File originalFile = File(imageFileProfile.path);
    File? compressedFile = await _compressImage(originalFile);

    if (compressedFile != null) {
      // احفظ اللي اتنين
      listXProfileImage.add(imageFileProfile); // XFile
      listProfileImage.add({
        "original": imageFileProfile,  // XFile
        "compressed": compressedFile   // File
      });
      notifyListeners();
    }
  }

  Future<void> getProfileImageByGallery() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFileProfile == null) return;

    File originalFile = File(imageFileProfile.path);
    File? compressedFile = await _compressImage(originalFile);

    if (compressedFile != null) {
      // احفظ اللي اتنين
      listXProfileImage.add(imageFileProfile); // XFile
      listProfileImage.add({
        "original": imageFileProfile,  // XFile
        "compressed": compressedFile   // File
      });
      notifyListeners();
    }
  }


  Future<void> getImage(context,{image1, image2, list, bool one = true, list2}) =>
      showModalBottomSheet<void>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      AppStrings.selectPhoto.tr(),
                      style: TextStyle(
                          fontSize: 20, color: Colors.black),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () async {
                                await getProfileImageByGallery();
                                await image2 == null
                                    ? null
                                    : Image.asset("assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.image,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              AppStrings.gallery.tr(),
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                await getProfileImageByCam();
                                print(image1);
                                print(image2);
                                await image2 == null
                                    ? null
                                    : Image.asset(
                                    "assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              AppStrings.camera.tr(),
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
  Future<void> selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: UserSettingConst.userSettings?.birthDate,
      switchToInputEntryModeIcon: const Icon(Icons.add, color: Colors.transparent,),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
      locale:  Locale(LocalizationService.isArabic(context: context)?'ar':'en', ''),
    );
    if (picked != null && picked != birthDate) {
      birthDate = picked;
      var outputFormat = DateFormat('yyyy-MM-dd',LocalizationService.isArabic(context: context)?'ar':'en' );
      var outputDate = outputFormat.format(birthDate!);
      birthDateController.text = outputDate;
      notifyListeners();
      print( birthDateController.text);
    }
  }
  // Future<void> selectBirthDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: UserSettingConst.userSettings?.birthDate,
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime(2101),
  //     locale:  const Locale('en', ''),
  //   );
  //   if (picked != null && picked != birthDate) {
  //     birthDate = picked;
  //     birthDateController.text = DateService.formatDateTime(birthDate, format: 'yyyy-MM-dd');
  //   }
  //   notifyListeners();
  // }

  Future<void> activate2FA({required BuildContext context, tfa , bool twoFa = false}) async {
    try {
      // bool isActivate2FA = await AlertsService.confirmMessage(
      //     context, AppStrings.activate_2fa.tr(),
      //     message: AppStrings.activate_2fa_confirmation.tr());
      // if (UserSettingConst.userSettings?.emailVerifiedAt == null) {
      //   AlertsService.info(
      //       context: context,
      //       message: AppStrings.email_verification_required.tr(),
      //       title: AppStrings.information.tr());
      //   return;
      // }
      // if (isActivate2FA == false) return;
      final result = await PersonalProfileService.activateTfa(context: context, tfa: tfa);
      if (result.success) {
        if(twoFa == true){
          String serial = result.data?['serial'];
          await _showQRCodeDialog(context, serial);
          return;
        }else{
          AlertsService.success(
              context: context,
              message:
              result.message ?? 'Failed To Activate 2FA , Please Try Later',
              title: AppStrings.success.tr());
        }
      } else {
        AlertsService.error(
            context: context,
            message:
            result.message ?? 'Failed To Activate 2FA , Please Try Later',
            title: AppStrings.failed.tr());
        return;
      }
    } catch (ex, t) {
      debugPrint(
          'Failed to Activate 2FA , Please Try Later ,${ex.toString()} at $t');
      AlertsService.error(
          context: context,
          message: 'Failed To Activate 2FA , Please Try Later',
          title: AppStrings.failed.tr());
    }
  }

  Future<void> _showQRCodeDialog(BuildContext context, String serial) async {
    faController.clear();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: Text(
            AppStrings.fa_activated.tr(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: AppSizes.s200,
                  height: AppSizes.s200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.s10),
                    child: QrImageView(
                      data: serial,
                      version: QrVersions.auto,
                      backgroundColor: Colors.transparent,
                      dataModuleStyle:
                      const QrDataModuleStyle(color: Colors.black),
                    ),
                  ),
                ),
                gapH16,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.3,
                        child: SelectableText(serial)),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        FlutterClipboard.copy(serial).then((value) => {
                          AlertsService.success(
                              title: AppStrings.success.tr(),
                              context: context,
                              message: AppStrings.serial_copied.tr())
                        });
                      },
                    ),
                  ],
                ),
                gapH16,
                TextFormField(
                  controller: faController,
                  decoration: InputDecoration(
                    hintText:
                    AppStrings.fa_code.tr().toUpperCase(),
                  ),
                )
              ],
            ),
          ),
          actions: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextButton(
                  child: Text(
                    AppStrings.cancel.tr(),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CustomElevatedButton(
                  title: AppStrings.activeNow.tr(),
                  onPressed: () async {
                    if(faController.text.isNotEmpty){
                      final result = await PersonalProfileService.activateTfa(context: context, type: "verify", code: faController.text, tfa: "1");
                      if (result.success) {
                        Navigator.pop(context);
                        AlertsService.success(
                            context: context,
                            message: result.data!['message'],
                            title: AppStrings.success.tr());
                      }else{
                        Fluttertoast.showToast(
                            msg: result.message!,
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0
                        );
                        return;
                      }
                    }else{
                      Fluttertoast.showToast(
                          msg: "${AppStrings.code.tr()} ${AppStrings.isRequired.tr()}",
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0
                      );
                    }
                  },
                  isPrimaryBackground: false,
                ),
              ],
            ),

          ],
        );
      },
    );
  }

  Future<void> updateUserSettingsData({required BuildContext context}) async {
    //update UserSettings 1,2
    await AppSettingsService.getUserSettingsAndUpdateTheStoredSettings(
        allData: true, context: context);
    // update user data
    await initializePersonalProfileScreen(context: context);
  }

  /// update profile
  Future<void> updateProfileMainInfo({required BuildContext context}) async {
    notifyListeners();
    try {
      final json1String = CacheHelper.getString("US1");
      var us1Cache;
      if (json1String != null && json1String != "") {
        us1Cache = json.decode(json1String) as Map<String, dynamic>;// Convert String back to JSON
        print("S1 IS --> $us1Cache");
        UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
      }
      //check if there is changes on the user profil
      print("isThis --> ${nameController.text == us1Cache['name']}");
      print("isThis --> ${us1Cache['birthday']}");
      print("isThis --> ${birthDateController.text}");
      print("isThis --> ${ birthDateController.text == us1Cache['birthday']}");
      if (nameController.text == us1Cache['name'] &&
          birthDateController.text ==
              us1Cache['birthday']) {
        AlertsService.info(
            context: context,
            message: AppStrings.noChangesDetectedProfileIsAlreadyUpToDate.tr(),
            title: AppStrings.information.tr());
        return;
      }
      // Vaidation
      if (form1Key.currentState?.validate() == true) {
        bool isUpdate = await AlertsService.confirmMessage(
            context, AppStrings.updateProfile.tr(),
            message: AppStrings.areYouSureYouWantToUpdateYourProfile.tr());
        if (isUpdate == false) return;
        var result = PersonalProfileService.updateProfile(
          context: context,
          name: nameController.text,
          birthDay: birthDateController.text ==
              DateService.formatDateTime(UserSettingConst.userSettings?.birthDate) ? birthDateController.text:DateService.formatDateTime(birthDate, format: 'yyyy-MM-dd'),
        );
        result.then((value)async{
          print("Update2");
          Fluttertoast.showToast(
              msg: value.data['message'],
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 5,
              backgroundColor: value.data['status'] == true ? Colors.green : Colors.red,
              textColor: Colors.white,
              fontSize: 16.0
          );
          isSuccessUpdate = true;
          // await updateUserSettingsData(context: context);
          notifyListeners();
          return;
        });
      }
    } catch (ex, t) {
      debugPrint(
          '${AppStrings.failedToUpdateProfilePleaseTryLater.tr()} ,${ex.toString()} at $t');
      Fluttertoast.showToast(
          msg: "${ex.toString()} ${AppStrings.at.tr()} $t",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      notifyListeners();
    }
  }
  Future<void> updateProfileMainInfoImage({required BuildContext context}) async {
    if(listProfileImage.isEmpty){
      deleteImage = true;
    }
    notifyListeners();
    try {
      // Vaidation
      //   bool isUpdate = await AlertsService.confirmMessage(
      //       context, AppStrings.updateProfile.tr(),
      //       message: AppStrings.areYouSureYouWantToUpdateYourProfile.tr());
      //   print("UPDATE IS---> $isUpdate");
      //   if (isUpdate == false) return;
      var result = PersonalProfileService.updateProfile(
        context: context,
        avatar: listProfileImage.isNotEmpty ?listProfileImage
            .map((e) => XFile(e["compressed"].path)) // تحويل File → XFile
            .toList() : null,

      );
      result.then((value)async{
        print("Update2");
        Fluttertoast.showToast(
            msg: value.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor:value.data['status'] == true ? Colors.green : Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        isSuccessUpdateImage = true;
        notifyListeners();
        return;
      });
    } catch (ex, t) {
      debugPrint(
          '${AppStrings.failedToUpdateProfilePleaseTryLater.tr()} ,${ex.toString()} at $t');
      Fluttertoast.showToast(
          msg:"${ex.toString()} ${AppStrings.at.tr()} $t",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      notifyListeners();
    }
  }

  /// update profile email
  Future<void> updateProfileEmail({required BuildContext context}) async {
    try {
      //check if there is changes on the user profile email
      if (emailController.text == UserSettingConst.userSettings?.email) {
        AlertsService.info(
            context: context,
            message: AppStrings.noChangesDetectedEmailIsAlreadyUpToDate.tr(),
            title: AppStrings.information.tr());
        return;
      }
      // Vaidation
      if (form2Key.currentState?.validate() == true) {
        bool isUpdate = await AlertsService.confirmMessage(
          form3Key: form3Key,
            context, AppStrings.updateEmail.tr(),
            message: AppStrings.areYouSureYouWantToUpdateYourEmail.tr());

        if (isUpdate == false) return;
        final result = await PersonalProfileService.updateProfile(
            context: context, email: emailController.text);
        print("result is --> $result");
        if(result != null){
          if(result.data['status'] == true ){
            if (
            result.data?['email_code'] == true &&
                result.data?['email_code_uuid'] != null &&
                result.data?['email_code_uuid'] != '') {
              return await showEmailVerificationPopup(
                  context: context,
                  newEmail: emailController.text,
                  emailUuid: result.data?['email_code_uuid']);
            }
          }else{
            Fluttertoast.showToast(
                msg: result.data['message'] ,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
          }
        }
      }
    } catch (ex, t) {
      debugPrint(
          '${AppStrings.failedToUpdateEmailPleaseTryLater.tr()} ,${ex.toString()} at $t');
      Fluttertoast.showToast(
          msg:"${ex.toString()} ${AppStrings.at.tr()} $t",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
  }

  /// update profile phone number
  Future<void> updateProfilePhoneNumber({required BuildContext context}) async {
    try {
      //check if there is changes on the user profile phone
      if (phoneNumberController.text == UserSettingConst.userSettings?.phone) {
        AlertsService.info(
            context: context,
            message: AppStrings.noChangesDetectedPhoneIsAlreadyUpToDate.tr(),
            title: AppStrings.information.tr());
        return;
      }
      // Vaidation
      if (phoneNumberController.text.isEmpty) {
        Fluttertoast.showToast(
            msg: AppStrings.pleaseEnterAPhoneNumber.tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
        return;
      }

      bool isUpdate = await AlertsService.confirmMessage(
          context, AppStrings.updatePhoneNumber.tr(),
          form3Key: form3Key,
          message: AppStrings.areYouSureYouWantToUpdateYourPhone.tr());
      if (isUpdate == false) return;
      final result = await PersonalProfileService.updateProfile(
          context: context,
          phone: phoneNumberController.text,
          countryKey: countryCodeController.text.trim().isEmpty
              ? '+20'
              : countryCodeController.text.trim());
      if(result != null){
          if(result.data['status'] == true){
            if (
            result.data?['phone_code'] == true &&
                result.data?['phone_code_uuid'] != null &&
                result.data?['phone_code_uuid'] != '') {
              return await showPhoneVerificationPopup(
                  context: context,
                  newPhoneNumber: phoneNumberController.text,
                  phoneUuid: result.data?['phone_code_uuid']);
            }
          }else{
            Fluttertoast.showToast(
                msg: result.data['message'] ,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
            return;
          }
      }
    } catch (ex, t) {
      debugPrint(
          '${AppStrings.failedToUpdatePhonePleaseTryLater.tr()} ,${ex.toString()} at $t');
      Fluttertoast.showToast(
          msg: "${ex.toString()} ${AppStrings.at.tr()} $t",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
      return;
    }
  }

  ///LOGOUT
  Future<void> logout({required BuildContext context}) async {
    try {
      bool isLogout = await AlertsService.confirmMessage(context, AppStrings.logout.tr(),
          message: AppStrings.areYouSureYouWantToLog.tr());
      final appConfigService =
      Provider.of<AppConfigService>(context, listen: false);
      await appConfigService.logout();
      if (isLogout == false) return;
      final result = await PersonalProfileService.logout(context: context);
      if (result.success) {
        // Clear user data and navigate to login screen
        final appConfigService =
        Provider.of<AppConfigService>(context, listen: false);
        await appConfigService.resetConfig();
        await appConfigService.setAuthenticationStatusWithToken(
            isLogin: false, token: null);
        return;
      } else {
        // Fluttertoast.showToast(
        //     msg: result.message!,
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 5,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0
        // );
        return;
      }
    } catch (ex, t) {
      debugPrint('${AppStrings.failedToLogoutPleaseTryLater.tr()} ,${ex.toString()} at $t');
      Fluttertoast.showToast(
          msg: "${ex.toString()} ${AppStrings.at.tr()} $t",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  // DELETE ACCOUNT
  Future<void> removeAccount({required BuildContext context}) async {
    try {
      await AlertsService.confirmMessage(
          context, AppStrings.deleteAccount.tr(),
          form3Key: form3Key,
          viewPassword: true,
          passwordForRemoveAccountController: passwordForRemoveAccountController,
          message: AppStrings.areYouSureYouWantToDeleteAccount.tr(),
        onTap: () async {
          if(form3Key.currentState!.validate()){
            final result = await PersonalProfileService.removeAccount(
                context: context, password: passwordForRemoveAccountController.text);
            if (result.success) {
              // Clear user data and navigate to login screen
              if(result.message != null){
                Navigator.of(context).pop();
                AlertsService.success(
                    context: context,
                    message: result.message!,
                    title: AppStrings.failed.tr());
              }
              final appConfigService =
              Provider.of<AppConfigService>(context, listen: false);
              await appConfigService.resetConfig();
              await appConfigService.setAuthenticationStatusWithToken(
                  isLogin: false, token: null);
              return;
            } else {
              Fluttertoast.showToast(
                  msg: result.message!,
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0
              );
              return;
            }
          }
        },
      );

    } catch (ex, t) {
      debugPrint(
          '${AppStrings.failedToDeleteAccountPleaseTryLater.tr()} ,${ex.toString()} at $t');
      Fluttertoast.showToast(
          msg: "${ex.toString()} ${AppStrings.at.tr()} $t",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }

  getUUID(context, sendBy)async{
    notifyListeners();
    await DioHelper.postData(
        url: "/rm_users/v1/account_verification/create",
        context: context,
        data: {
          "send_by" : sendBy
        }
    ).then((v)async{
      if(v.data['status'] == true){
        uuid = v.data['uuid'];
        CacheHelper.setString(key: "uuid", value: uuid);
      }
      notifyListeners();
    }).catchError((e){
      print(e);
    });
  }
  verfiy(context, {sendBy, code})async{
    var res = await DioHelper.postData(
        url: "/rm_users/v1/account_verification/$uuid/validate-account-code",
        context: context,
        data: {
          "send_by" : sendBy,
          "code"  : code
        }
    );
    return res;
  }
  Future<void> showPhoneVerificationPopup(
      {required BuildContext context,
        required String newPhoneNumber,
        bool validate = false,
        sendBy,
        required String phoneUuid}) async {
    TextEditingController codeController = TextEditingController();
    final GlobalKey<FormState> codeFormKey = GlobalKey<FormState>();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.s12),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(AppSizes.s16),
          titlePadding: const EdgeInsets.all(AppSizes.s16),
          contentPadding: const EdgeInsets.all(AppSizes.s12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.otpVerification.tr(),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: AppSizes.s32,
                    color: Colors.red,
                  ))
            ],
          ),
          content: SizedBox(
            width: LayoutService.getWidth(context),
            height: AppSizes.s300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.verificationCodeSent.tr(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: AppSizes.s16),
                      textAlign: TextAlign.center,
                    ),
                    gapH12,
                    Text(
                      AppStrings.aVerificationCodeHasBeenSentToYourPhoneNumber.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Form(
                  key: codeFormKey,
                  child: TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterVerificationCode.tr(),
                    ),
                    validator: (value) =>
                        ValidationService.validateNumeric(value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomElevatedButton(
                      title: AppStrings.verify.tr(),
                      onPressed: () async {
                        if (codeController.text.isNotEmpty) {
                          final result = validate == false ?  await PersonalProfileService.updateProfile(
                              context: context,
                              phone: newPhoneNumber,
                              phoneCode: codeController.text,
                              phoneUuid: phoneUuid,
                              countryKey: countryCodeController.text.trim().isEmpty
                                  ? '+20'
                                  : countryCodeController.text.trim()) : verfiy(context, code:codeController.text, sendBy:  sendBy);
                          if(result != null){
                            if (result.data['status'] == true) {
                              await updateUserSettingsData(context: context);
                              Navigator.of(context).pop(context);
                              Fluttertoast.showToast(
                                  msg: AppStrings.updatePhoneNumber.tr(),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 5,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg: result.data?['message'] ??
                                      AppStrings.failedVerificationCodePleaseTryLater.tr(),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 5,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );

                              return;
                            }
                          }
                        }else{
                          Fluttertoast.showToast(
                              msg: AppStrings.enterVerificationCode.tr(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 5,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                          return;
                        }

                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Email Update Verification
  Future<void> showEmailVerificationPopup(
      {required BuildContext context,
        required String newEmail,
        bool validate = false,
        sendBy,
        required String emailUuid}) async {
    TextEditingController codeController = TextEditingController();
    final GlobalKey<FormState> codeFormKey = GlobalKey<FormState>();
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.s12),
          ),
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(AppSizes.s16),
          titlePadding: const EdgeInsets.all(AppSizes.s16),
          contentPadding: const EdgeInsets.all(AppSizes.s12),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.emailVerification.tr(),
                style: Theme.of(context).textTheme.displayLarge,
              ),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: AppSizes.s32,
                    color: Colors.red,
                  ))
            ],
          ),
          content: SizedBox(
            width: LayoutService.getWidth(context),
            height: AppSizes.s300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.verificationCodeSent.tr(),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold, fontSize: AppSizes.s16),
                      textAlign: TextAlign.center,
                    ),
                    gapH12,
                    Text(
                      AppStrings.aVerificationCodeHasBeenSentToYourEmail.tr(),
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                Form(
                  key: codeFormKey,
                  child: TextFormField(
                    controller: codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: AppStrings.enterVerificationCode.tr(),
                    ),
                    validator: (value) =>
                        ValidationService.validateNumeric(value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomElevatedButton(
                      title: AppStrings.verify.tr(),
                      onPressed: () async {
                        if (codeController.text.isNotEmpty) {
                          final result = validate== false?  await PersonalProfileService.updateProfile(
                              context: context,
                              email: emailController.text,
                              emailCode: codeController.text,
                              emailUuid: emailUuid) : await verfiy(context, code: codeController.text, sendBy:sendBy );
                          if(result != null){
                            if (result.data?['status'] == true ) {
                              await updateUserSettingsData(context: context);
                              Navigator.of(context).pop(context);
                              Fluttertoast.showToast(
                                  msg: AppStrings.emailUpdatedSuccessfully.tr(),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 5,
                                  backgroundColor: Colors.green,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );
                            } else {
                              Fluttertoast.showToast(
                                  msg: result.data?['message'] ??
                                      AppStrings.failedVerificationCodePleaseTryLater.tr(),
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 5,
                                  backgroundColor: Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0
                              );

                              return;
                            }
                        }

                        }else{
                          Fluttertoast.showToast(
                              msg: AppStrings.enterVerificationCode.tr(),
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 5,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0
                          );
                          return;
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
