
import 'dart:convert';

import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/alert_service/alerts_service.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/features/more/notifications/data/models/get_one_notification_model.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/dart_io_stub.dart';


class NotificationProviderModel extends ChangeNotifier {
  bool isLoading = false;
  bool isGetNotificationLoading = false;
  bool isGetNotificationSuccess = false;
  bool isGetNotificationCommentLoading = false;
  bool isGetNotificationCommentSuccess = false;
  bool hasMoreNotifications = true; // Track if there are more notifications to load
  bool allowComment = true; // Track if there are more notifications to load
  String? getNotificationErrorMessage;
  String? getRequestCommentErrorMessage;
  String? errorAddNotificationMessage;
  String? errorMessage;
  NotificationSingleModel? notificationModel;
  List comments = [];
  Set<int> commentIds = {};
  List notifications = [];
  List newNotifications = [];
  List listIds = [];
  List listIdsDepartment = [];
  int currentPage = 1;
  final int itemsCount = 9;
  bool hasMore = true;
  final int expectedPageSize = 9;
  final picker = ImagePicker();
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  FilePickerResult? attachedFile;
  Map<String, dynamic>? selectedEmployee;
  List<Map<String, dynamic>> employees = [];
  List<Map<String, dynamic>> departments = [];
  List notificationsType = [
    {
      "name" : AppStrings.allEmployees.tr(),
      "value" : "all_employees"
    },{
      "name" : AppStrings.someEmployees.tr(),
      "value" : "some_employees"
    },{
      "name" : AppStrings.departments.tr(),
      "value" : "departments"
    },
  ];
  TextEditingController titleArController = TextEditingController();
  TextEditingController contentArController = TextEditingController();
  TextEditingController titleEnController = TextEditingController();
  TextEditingController contentEnController = TextEditingController();
  String? selectNotificationType;
  void initializeAddTaskScreen({required BuildContext context}) {
    getEmployees(context: context);
    getDepartment(context: context);
    _resetValues();
    notifyListeners();
  }
  void _resetValues() {
    // selectedType = null;
    // selectedDatecontroller = TextEditingController();
    contentArController = TextEditingController();
    titleArController = TextEditingController();
    contentEnController = TextEditingController();
    titleEnController = TextEditingController();
    selectNotificationType = null;
    listXAttachmentPersonalImage = [];
    listAttachmentPersonalImage = [];
    listIds = [];
    listIdsDepartment = [];
  }
  bool hasMoreData(int length) {
    if (length < expectedPageSize) {
      return false;
    } else {
      currentPage += 1;
      return true;
    }
  }
  Future<void> refreshPaints(context) async{
    currentPage = 1;
    hasMore = true;
    await getNotification(page : 1,context);
  }
  void getEmployees({required BuildContext context}) {
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
      UserSettingConst.userSettings = UserSettingsModel.fromJson(gCache);
    }
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/emp_requests/v1/employees",
      query: {
        "under_my_management" : true
      },
      context: context,
    ).then((value){
      isLoading = false;
      employees = [];
      value.data['employees'].forEach((e){
        employees.add(Map<String, dynamic>.from(e));
      });
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }
  void getDepartment({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/departments/entities-operations",
      query: {
        "itemsCount" : 200,
        "under_my_management" : true,
      },
      context: context,
    ).then((value){
      isLoading = false;
      departments = List<Map<String, dynamic>>.from(value.data['data']);
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioException) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }
  Future<void> getNotification(BuildContext context, {int? page, forWho}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    var jsonString;
    var gCache;
    jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    isGetNotificationLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: (gCache != null && gCache['role'] is List && gCache['role'].isNotEmpty && gCache['role'].contains("personal"))?
        "/rmnotifications/entities-operations":"/emp_requests/v1/notifications/list",
        context: context, // Pass this explicitly only if necessary
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
          "for" : forWho
        },
      );

      newNotifications = (gCache != null && gCache['role'] is List && gCache['role'].isNotEmpty && gCache['role'].contains("personal"))?
      response.data['data'] ?? []:response.data['notifications'] ?? [];
      if (page == 1) {
        notifications.clear(); // Clear only when loading the first page
      }
      if (newNotifications.isNotEmpty) {
        notifications.addAll(newNotifications);
        print("LENGTH IS --> ${newNotifications.length}");
        if (hasMore) currentPage++;
      } else {
        hasMoreNotifications = false; // No more data to fetch
      }

      isGetNotificationSuccess = true;
    } catch (error) {
      getNotificationErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isGetNotificationLoading = false;
      notifyListeners();
    }
  }
  Future<void> getNotificationSingle(BuildContext context, id) async {
    isGetNotificationLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/rmnotifications/entities-operations/$id",
        context: context,
        query: null,
      );
      if(response.data["status"] == true){
        notificationModel = NotificationSingleModel.fromJson(response.data['item']);
        isGetNotificationSuccess = true;
        isGetNotificationLoading = false;
        notifyListeners();
      }
    } catch (error) {
      getNotificationErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isGetNotificationLoading = false;
      notifyListeners();
    }
  }
  addNotification(BuildContext context, {empIds, depIds})async {
    if(selectNotificationType == null || selectNotificationType!.toString().isEmpty){
      AlertsService.warning(
          context: context,
          message: "${AppStrings.type.tr()} ${AppStrings.isRequired.tr()}",
          title: AppStrings.warning.tr());
      return;
    }
    isLoading = true;
    notifyListeners();
    print("empIds is --> ${empIds}");
    print("empIds is --> ${listXAttachmentPersonalImage.length}");

    final images = listXAttachmentPersonalImage.isNotEmpty
        ? await Future.wait(
      listXAttachmentPersonalImage.map(
            (file) async {
          // على الويب، استخدام readAsBytes بدلاً من path
          if (kIsWeb || PlatformIs.web) {
            try {
              final bytes = await file.readAsBytes();
              return MultipartFile.fromBytes(
                bytes,
                filename: file.name,
              );
            } catch (e) {
              print("Error reading image bytes on web: $e");
              // محاولة استخدام path كبديل
              return await MultipartFile.fromFile(file.path, filename: file.name);
            }
          } else {
            return await MultipartFile.fromFile(file.path, filename: file.name);
          }
        },
      ),
    )
        : [];

    FormData formData = FormData.fromMap({
      "titles[en]" : titleEnController.text,
      "titles[ar]" : titleArController.text,
      "contents[en]" : contentEnController.text,
      "contents[ar]" : contentArController.text,
      "allow_comments" : allowComment == true ? "enable" : "disable",
      "type" : selectNotificationType.toString(),
      "image[]": images,
      if(empIds != null && empIds.isNotEmpty)"employee_ids[]" : empIds,
      if(depIds != null && depIds.isNotEmpty)"department_ids[]" : depIds
    });
    var response;
    try{
      response = await DioHelper.postFormData(
        url: "/emp_requests/v1/notifications/create",
        context: context,
        formdata: formData,
        query: null,
        data: {},
      );
      if(response.data['status'] == true){
        titleEnController.clear();
        titleArController.clear();
        contentEnController.clear();
        contentArController.clear();
        // Clear attached images after successful send
        listXAttachmentPersonalImage.clear();
        listAttachmentPersonalImage.clear();
        attachedFile = null;
        notifyListeners();
        print("NOTI IS DONE");
        AlertsService.success(
            context: context,
            message: response.data['message'],
            title: AppStrings.success.tr());
      }else{
        AlertsService.error(
            context: context,
            message: response.data['message'],
            title: AppStrings.failed.tr());
      }
    }catch (error) {
      errorAddNotificationMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg:errorAddNotificationMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  Future<File?> _compressImage(File file) async {
    if (kIsWeb) return null;

    final targetPath =
        "${file.path}_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 75,
      minWidth: 1600,
      minHeight: 1600,
    );

    return result != null ? File(result.path) : null;
  }
  Future<void> getProfileImageByCam() async {
    try {
      final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.camera);
      if (imageFileProfile == null) return;

      // على الويب، لا نحتاج إلى ضغط الصورة
      if (kIsWeb || PlatformIs.web) {
        listXAttachmentPersonalImage.add(imageFileProfile); // XFile
        listAttachmentPersonalImage.add({
          "original": imageFileProfile,  // XFile
          "compressed": imageFileProfile   // على الويب، استخدم نفس الملف
        });
        notifyListeners();
        print("Image added successfully on web. Total images: ${listXAttachmentPersonalImage.length}");
      } else {
        File originalFile = File(imageFileProfile.path);
        File? compressedFile = await _compressImage(originalFile);

        if (compressedFile != null) {
          // احفظ اللي اتنين
          listXAttachmentPersonalImage.add(imageFileProfile); // XFile
          listAttachmentPersonalImage.add({
            "original": imageFileProfile,  // XFile
            "compressed": compressedFile   // File
          });
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error getting image from camera: $e");
      if (kIsWeb || PlatformIs.web) {
        Fluttertoast.showToast(
          msg: "Error selecting image. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Future<void> getProfileImageByGallery() async {
    try {
      final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.gallery);
      if (imageFileProfile == null) return;

      // على الويب، لا نحتاج إلى ضغط الصورة
      if (kIsWeb || PlatformIs.web) {
        listXAttachmentPersonalImage.add(imageFileProfile); // XFile
        listAttachmentPersonalImage.add({
          "original": imageFileProfile,  // XFile
          "compressed": imageFileProfile   // على الويب، استخدم نفس الملف
        });
        notifyListeners();
        print("Image added successfully on web. Total images: ${listXAttachmentPersonalImage.length}");
      } else {
        File originalFile = File(imageFileProfile.path);
        File? compressedFile = await _compressImage(originalFile);

        if (compressedFile != null) {
          // احفظ اللي اتنين
          listXAttachmentPersonalImage.add(imageFileProfile); // XFile
          listAttachmentPersonalImage.add({
            "original": imageFileProfile,  // XFile
            "compressed": compressedFile   // File
          });
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error getting image from gallery: $e");
      if (kIsWeb || PlatformIs.web) {
        Fluttertoast.showToast(
          msg: "Error selecting image. Please try again.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
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

}
