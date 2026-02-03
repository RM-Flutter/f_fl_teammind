import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/string_convert.dart';
import 'package:rmemp/constants/user_consts.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/get_one_task_model.dart';
import 'package:rmemp/models/get_comment_model.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';

import '../../general_services/alert_service/alerts.service.dart';

class TaskViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool isUpdateLoading = false;
  bool isAddCommentSuccess = false;
  bool isAddCommentLoading = false;
  bool isGetRequestCommentSuccess = false;
  bool isGetRequestCommentLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  String? errorMessage;
  String? selectedStatus;
  String? selectedIcon;
  int? selectedIndex;
  String? getRequestCommentErrorMessage;
  String? errorAddCommentMessage;
  List assigns = [];
  List statusTypes = [
    {
      "name": AppStrings.open.tr(),
      "value" : "open"
    }, {
      "name": AppStrings.closed.tr(),
      "value" : "closed"
    }, {
      "name": AppStrings.completed.tr(),
      "value" : "completed"
    },
  ];
  List<Map<String, String>> iconsName = [
    {
      "name": "المالية",
      "value": "assets/images/svg/t1.svg"
    },
    {
      "name": "أعمال إدارية",
      "value": "assets/images/svg/t2.svg"
    },
    {
      "name": "أعمال تقنية المعلومات",
      "value": "assets/images/svg/t3.svg"
    },
    {
      "name": "حضور اجتماع",
      "value": "assets/images/svg/t4.svg"
    },
    {
      "name": "مكالمات",
      "value": "assets/images/svg/t5.svg"
    },
    {
      "name": "أعمال تنظيف",
      "value": "assets/images/svg/t6.svg"
    },
    {
      "name": "إرسال بريد إلكتروني",
      "value": "assets/images/svg/t7.svg"
    },
  ];

  List tasks = [];
  String? selectEmpId;
  List listIds = [];
  List subTasks = [];
  List<String> tasksList = [];
  List tasksList2 = [];
  List newComments = [];
  List comments = [];
  final picker = ImagePicker();
  final ScrollController controller = ScrollController();
  final int expectedPageSize = 9;
  int pageNumber = 1;
  int count = 0;
  Set<int> commentIds = {};
  List<Map<String, dynamic>> selectedEmployees = [];
  List<int> selectedEmployeeIds = [];
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  Map<String, dynamic>? selectedEmployee;
  List<Map<String, dynamic>> employees = [];
  Map<String, dynamic>? selectedType;
  DateTime? selectedDate;
  GetOneTaskModel? getOneTaskModel;
  TextEditingController selectedDatecontroller = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  void initializeAddTaskScreen({required BuildContext context}) {
    getEmployees(context: context);
    _resetValues();
    notifyListeners();
  }
  @override
  void dispose() {
    selectedDatecontroller.dispose();
    super.dispose();
  }

  void _resetValues() {
    selectedType = null;
    selectedDatecontroller = TextEditingController();
    contentController = TextEditingController();
    titleController = TextEditingController();
    selectedDate = null;
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
  Future<void> getTask(BuildContext context, {String? date, int? index, bool loadMore = false,}) async {
    selectedIndex = index;
    if (isLoading || isLoadingMore) return;
    if (!loadMore) {
      isLoading = true;
      currentPage = 1;
      hasMore = true;
      tasks.clear();
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/task",
        query: {
          "page": currentPage,
          if (date != null) "date": StringConvert.sanitizeDateString(date),
        },
        context: context,
      );

      final List<dynamic> newTasks = response.data['tasks'] ?? [];

      if (newTasks.isEmpty) {
        hasMore = false;
      } else {
        tasks.addAll(newTasks);
        currentPage++;
      }
      assigns = response.data['assigns'];

      errorMessage = null;
      notifyListeners();
    } catch (error) {
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    }

    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> getOneTask(BuildContext context, id) {
    isLoading = true;
    notifyListeners();
    return DioHelper.getData(
      url: "/emp_requests/v1/task/$id",
      context: context,
    ).then((value) {
      getOneTaskModel = GetOneTaskModel.fromJson(value.data);
      subTasks = value.data['task']['subTasks'];
      isLoading = false;
      notifyListeners();
    }).catchError((error) {
      isLoading = false;
      print("TASK ERROR IN --> ${error.toString()}");
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
    });
  }

  void addTask(BuildContext context) {
    if(selectedEmployeeIds.isEmpty || selectedStatus.toString().isEmpty){
      AlertsService.warning(
          context: context,
          message: selectedEmployeeIds.isEmpty? AppStrings.theAssignToFieldIsRequired.tr(): AppStrings.theSelectedStatusIsInvalid.tr(),
          title: AppStrings.warning.tr().toUpperCase());
      return;
    }
    listIds = listIds.isNotEmpty ? [listIds.first] : [];
    isLoading = true;
    notifyListeners();
    DioHelper.postData(
      url: "/emp_requests/v1/task",
      context: context,
      data: {
        "title" : titleController.text,
        "content" : contentController.text,
        "due_date" : StringConvert.sanitizeDateString(selectedDatecontroller.text),
        "assign_to" : selectedEmployeeIds,
        "sub_tasks": tasksList2,
        "status": selectedStatus.toString(),
        "icon": selectedIcon.toString(),
      }
    ).then((value){
      if(value.data['status'] == true){
        Navigator.pop(context);
        Navigator.pop(context);
        AlertsService.success(
            context: context,
            message: value.data['message'],
            title: AppStrings.success.tr());
      }else{
        AlertsService.error(
            context: context,
            message: value.data['message'],
            title: AppStrings.failed.tr());
      }
      isLoading = false;
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      AlertsService.error(
          context: context,
          message: errorMessage.toString(),
          title: AppStrings.failed.tr());
    });
  }
  void updateTask(BuildContext context, id) {
    listIds = listIds.isNotEmpty ? [listIds.first] : [];
    isLoading = true;
    notifyListeners();
    DioHelper.putData(
      url: "/emp_requests/v1/task/$id",
      context: context,
      data: {
        "title" : titleController.text,
        "content" : contentController.text,
        "due_date" : selectedDatecontroller.text,
        "assign_to" : selectedEmployeeIds,
        "sub_tasks": tasksList2,
        "status": selectedStatus.toString(),
        "icon": selectedIcon.toString(),
      }
    ).then((value){
      if(value.data['status'] == true){
        Navigator.pop(context);
        Navigator.pop(context);
        AlertsService.success(
            context: context,
            message: value.data['message'],
            title: AppStrings.success.tr());
      }else{
        AlertsService.error(
            context: context,
            message: value.data['message'],
            title: AppStrings.failed.tr());
      }
      isLoading = false;
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      AlertsService.error(
          context: context,
          message: errorMessage.toString(),
          title: AppStrings.failed.tr());
    });
  }
  void updateSubTask(BuildContext context, {id,
    title,
    content,
    due,
    assign,
    subTask,
    status,
    icon
  }) {
    listIds = listIds.isNotEmpty ? [listIds.first] : [];
    isUpdateLoading = true;
    notifyListeners();
    DioHelper.putData(
      url: "/emp_requests/v1/task/$id",
      context: context,
      data: {
        "title" : title,
        "content" : content,
       if(due != null && due.toString().isNotEmpty) "due_date" : due.toString(),
        "assign_to" : (assign as List<AssignTo>).map((e) => e.id).toList(),
        "sub_tasks": (subTask as List<SubTasks>).map((e) => e.toJson()).toList(),
        "status": status,
        "icon": icon,
      }
    ).then((value){
      if(value.data['status'] == true){
        AlertsService.success(
            context: context,
            message: value.data['message'],
            title: AppStrings.success.tr());
        getOneTask(context, id);
      }else{
        AlertsService.error(
            context: context,
            message: value.data['message'],
            title: AppStrings.failed.tr());
      }
      isUpdateLoading = false;
      notifyListeners();
    }).catchError((error){
      isUpdateLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      AlertsService.error(
          context: context,
          message: errorMessage.toString(),
          title: AppStrings.failed.tr());
    });
  }
  updateStatusTask(BuildContext context, id) async{
    isLoading = true;
    notifyListeners();
    DioHelper.patchData(
      url: "/emp_requests/v1/task/$id/status",
      context: context,
      data: {
        "status" : "completed"
      }
    ).then((value){
      if(value.data['status'] == true){
        AlertsService.success(
            context: context,
            message: value.data['message'],
            title: AppStrings.success.tr());
        Navigator.pop(context);
      }else{
        AlertsService.error(
            context: context,
            message: value.data['message'],
            title: AppStrings.failed.tr());
      }
      isLoading = false;
      notifyListeners();
    }).catchError((error){
      isLoading = false;
      notifyListeners();
      if (error is DioError) {
        errorMessage = error.response?.data['message'] ?? 'Something went wrong';
      } else {
        errorMessage = error.toString();
      }
      AlertsService.error(
          context: context,
          message: errorMessage.toString(),
          title: AppStrings.failed.tr());
    });
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
  Future<void> selectDate(BuildContext context) async {
    await _selectDate(context);
    if (selectedDate == null) {
      AlertsService.warning(
          context: context,
          message: 'please select the Date again !',
          title: AppStrings.warning.tr());
      return;
    }
    selectedDatecontroller.text = formatDateTimeRange(selectedDate!);
    notifyListeners();
  }

  /// USED WHEN THE DURATION TYPE IN THE SELECTED REQUEST IS DAYS
  Future<void> _selectDate(BuildContext context) async {
    final newDateRange = await showDatePicker(
        context: context,
        switchToInputEntryModeIcon: const Icon(Icons.add, color: Colors.transparent,),
        firstDate: DateTime(DateTime.now().year - 5),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDate: DateTime.now());
    if (newDateRange == null) return;
    selectedDate = newDateRange;
  }

  String formatDateTimeRange(DateTime date) {
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd', "en");
    return dateFormatter.format(date);
  }
}