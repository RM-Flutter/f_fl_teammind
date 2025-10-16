import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/alert_service/alerts.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/get_one_notification_model.dart';
import 'package:rmemp/models/get_request_comment_model.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';

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
  GetRequestCommentModel? getRequestCommentModel;
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
      if (error is DioError) {
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
        "under_my_management" : true
      },
      context: context,
    ).then((value){
      isLoading = false;
      departments = List<Map<String, dynamic>>.from(value.data['data']);
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }
  Future<void> getNotification(BuildContext context, {int? page, forWho}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isGetNotificationLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/notifications/list",
        context: context, // Pass this explicitly only if necessary
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
          "for" : forWho
        },
      );

       newNotifications = response.data['notifications'] ?? [];
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
      getNotificationErrorMessage = error is DioError
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
        context: context, // Pass this explicitly only if necessary
      );
      if(response.data["status"] == true){
        notificationModel = NotificationSingleModel.fromJson(response.data['item']);
        isGetNotificationSuccess = true;
        isGetNotificationLoading = false;
        notifyListeners();
      }
    } catch (error) {
      getNotificationErrorMessage = error is DioError
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
    final image = listAttachmentPersonalImage
        .map((e) => XFile(e["compressed"].path)) // تحويل File → XFile
        .toList();
    final images = image != null
        ? await Future.wait(
      listXAttachmentPersonalImage.map(
            (file) async => await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
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
      if(listXAttachmentPersonalImage == null || listXAttachmentPersonalImage.isEmpty){
        response = await DioHelper.postFormData(
            url: "/emp_requests/v1/notifications/create",
            context: context,
            formdata: formData
        );
      }else{
        response = await DioHelper.postFormData(
            url: "/emp_requests/v1/notifications/create",
            context: context,
            formdata: formData
        );
      }
      if(response.data['status'] == true){
        titleEnController.clear();
        titleArController.clear();
        contentEnController.clear();
        contentArController.clear();
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
      errorAddNotificationMessage = error is DioError
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
    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 75,
      minWidth: 1600,
      minHeight: 1600,
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
      listXAttachmentPersonalImage.add(imageFileProfile); // XFile
      listAttachmentPersonalImage.add({
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
      listXAttachmentPersonalImage.add(imageFileProfile); // XFile
      listAttachmentPersonalImage.add({
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

}
