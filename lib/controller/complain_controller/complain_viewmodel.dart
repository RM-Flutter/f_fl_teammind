import 'dart:convert';
import 'dart:io';
import 'package:app_test/models/get_one_complain_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_test/constants/app_constants.dart';
import 'package:app_test/constants/app_strings.dart';
import 'package:app_test/constants/user_consts.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/image_file_picker.service.dart';
import '../../../models/settings/user_settings_2.model.dart';
import '../../common_modules_widgets/successful_add.dart';

class ComplainViewModel extends ChangeNotifier {
  bool isAddComplaintLoading = false;
  bool isGetComplainLoading = false;
  bool isGetComplainSuccess = false;
  String? errorAddComplaintMessage;
  List<Map<String, dynamic>>? requestsTypes;
  TextEditingController controller = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController fileController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  FilePickerResult? attachedFile;
  List<Map<String, dynamic>> departments = [];
  String? errorMessage;
  bool isLoading = false;
  bool hasMore = true;
  bool hasMoreComplains = true;
  String? selectedComplaintTypes;
  String? getComplainErrorMessage;
  GetOneComplainModel? getOneComplainModel;
  List complains = [];
  List complainsTeam = [];
  List newComplains = [];
  int currentPage = 1;
  final int itemsCount = 9;
  final picker = ImagePicker();
  List status = [
    "canceled", "approved", "seen", "waiting_seen", "waiting_cancel"
  ];
  @override
  void dispose() {
    controller.dispose();
    reasonController.dispose();
    fileController.dispose();
    amountController.dispose();
    super.dispose();
  }
  void _resetValues() {
    requestsTypes = null;
    controller = TextEditingController();
    reasonController = TextEditingController();
    fileController = TextEditingController();
    amountController = TextEditingController();
    attachedFile = null;
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
  Future<void> getImage( context, {image1, image2, list, bool one = true, list2}) =>
      showModalBottomSheet<void>(
          shape: const RoundedRectangleBorder(
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
                    const Text("Select Photo",
                      style: TextStyle(
                          fontSize: 20, color: Color(0xFF011A51)),
                    ),
                    const SizedBox(
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
                                    : Image.asset(
                                    "assets/images/profileImage.png");
                                Navigator.pop(context);
                              },
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.image,
                                  color: Color(0xFF011A51),
                                ),
                              ),
                            ),
                            const Text("Gallery",
                              style: TextStyle(
                                  fontSize: 18, color: Color(0xFF011A51)),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                              child: const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.camera,
                                  color: Color(0xFF011A51),
                                ),
                              ),
                            ),
                            const Text(
                              "Camera",
                              style: TextStyle(fontSize: 18, color: Color(0xFF011A51)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
  Future<void> pickFile() async {
    FilePickerResult? result = await FileAndImagePickerService.pickFile();
    if (result != null) {
      attachedFile = result;
      fileController.text = result.files.single.name;
    }
    notifyListeners();
  }
  void initializeAddNewComplaintScreen({required BuildContext context}) {
    // Initialize your request types here
    _resetValues();
    _getComplaintTypes(context: context);
    notifyListeners();
  }
  void getDepartment({required BuildContext context}) {
    isLoading = true;
    notifyListeners();
    DioHelper.getData(
      url: "/departments/entities-operations",
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
  void _getComplaintTypes({required BuildContext context}) {
    try {
      var jsonString;
      Map<String, dynamic> gCache = {};
      jsonString = CacheHelper.getString("US2");
      if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
        gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
        UserSettingConst.userSettings2 = UserSettings2Model.fromJson(gCache);
      }
      print("HI 1");
      // Fetch user2Settings data from app settings

      // Fetch generalSettings data from app settings

      // get user balance from User2Settings
      final userBalance = gCache['balance'];
      // check if the user balance is null || empty then there is no requests types
      if (userBalance == null || userBalance.isEmpty) {
        requestsTypes = [];
        return;
      }
      print("HI 2");
      // Fetch request types from generalSettings and if there is no request types in generalSettings then return requests types with empty list
      print("TYPE IS --> ${UserSettingConst.generalSettingsModel!.requestTypes}");
      final requestsTypesDataFromGeneralSettings = UserSettingConst.generalSettingsModel!.requestTypes;
      if (requestsTypesDataFromGeneralSettings == null ||
          requestsTypesDataFromGeneralSettings.isEmpty) {
        requestsTypes = [];
        return;
      }

      // looping on user balance to get the available requests types with considering the the balance and it can be listed or not
      userBalance.forEach((requestId, val) {
        final userBalanceComplaintType = userBalance[requestId];
        final max = userBalanceComplaintType?.max;
        if (max != null &&
            requestsTypesDataFromGeneralSettings.containsKey(requestId)) {
          if (max == -1 || ((userBalanceComplaintType?.take ?? 0) < max)) {
            requestsTypes ??= [];
            requestsTypes!.add((requestsTypesDataFromGeneralSettings[requestId]
                ?.toJson() as Map<String, dynamic>));
            print("requestsTypes is --> $requestsTypes");
            if(requestsTypes != null && requestsTypes!.isNotEmpty){
              AppConstants.requestsTypess = requestsTypes;
            }
          }
        }
      });
      return;
    } catch (ex, t) {
      debugPrint(
          'Error getting request types ${ex.toString()} at :- ${t.toString()}');
      requestsTypes = [];
    }
  }
  Future<void> createNewComplaint(BuildContext context, {List<XFile>? images}) async {
    isAddComplaintLoading = true;
    notifyListeners();
    Response response;
    FormData formData = FormData.fromMap({
      if(subjectController.text.isNotEmpty)"title" : subjectController.text,
      if(detailsController.text.isNotEmpty) "content" : detailsController.text,
      "department_id" : selectedComplaintTypes.toString(),
      "main_thumbnail[]": images != null
          ? await Future.wait(
          images.map((file) async => await MultipartFile.fromFile(file.path, filename: file.name))
      )
          : [],
    });
    try {
      if(images != null && images.isNotEmpty){
        response = await DioHelper.postData(
            url: "/emp_requests/v1/complain",
            context: context,
            data: formData
        );
      }else{
        response = await DioHelper.postData(
            url: "/emp_requests/v1/complain",
            context: context,
            data: {
              if(subjectController.text.isNotEmpty) "title" : subjectController.text,
              if(detailsController.text.isNotEmpty) "content" : detailsController.text,
              "department_id" : selectedComplaintTypes.toString(),
            }
        );
      }
      if(response.data['status']== false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) {
            return SuccessfullAddRequestSheet(
              title: AppStrings.goToComplain.tr().toUpperCase(),
              onTap: ()async{
                Navigator.pop(context);
                Navigator.pop(context);
              },
            );
          },
        );
      }
      isAddComplaintLoading = false;
      notifyListeners();
    } catch (error) {
      errorAddComplaintMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg:errorAddComplaintMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isAddComplaintLoading = false;
      notifyListeners();

    }
  }
  Future<void> getComplain(BuildContext context, {int? page}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isGetComplainLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/complain?type=myTeam",
        context: context, // Pass this explicitly only if necessary
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
        },
      );
      if(response.data['status'] == false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        newComplains = response.data['complains'] ?? [];
        if (page == 1) {
          complainsTeam.clear(); // Clear only when loading the first page
        }
        if (newComplains.isNotEmpty) {
          complainsTeam.addAll(newComplains);
          print("LENGTH IS --> ${newComplains.length}");
          // if (hasMore) currentPage++;
        } else {
          hasMoreComplains = false; // No more data to fetch
        }

        isGetComplainSuccess = true;
      }
      isGetComplainLoading = false;
      notifyListeners();
    } catch (error) {
      getComplainErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getComplainErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetComplainLoading = false;
      notifyListeners();
    }
  }
  Future<void> getOneComplaint(BuildContext context, id, type) async {
    isGetComplainLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/complain/$id?type=$type",
        // query: {
        //   "with" : "ptype_id"
        // },
        context: context,
      );
      if(response.data['status'] == false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        getOneComplainModel = GetOneComplainModel.fromJson(response.data);
      }
      isGetComplainLoading = false;
      notifyListeners();
    } catch (error) {
      getComplainErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getComplainErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetComplainLoading = false;
      notifyListeners();
    }
  }
  Future<void> getComplaintMine(BuildContext context, {int? page}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isGetComplainLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/complain?type=mine",
        context: context, // Pass this explicitly only if necessary
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
        },
      );
      if(response.data['status'] == false){
        Fluttertoast.showToast(
            msg: response.data['message'],
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }else{
        newComplains = response.data['complains'] ?? [];
        if (page == 1) {
          complains.clear(); // Clear only when loading the first page
        }
        if (newComplains.isNotEmpty) {
          complains.addAll(newComplains);
          print("LENGTH IS --> ${newComplains.length}");
          if (hasMore) currentPage++;
        } else {
          hasMoreComplains = false; // No more data to fetch
        }

        isGetComplainSuccess = true;
      }
      isGetComplainLoading = false;
      notifyListeners();
    } catch (error) {
      getComplainErrorMessage = error is DioException
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getComplainErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetComplainLoading = false;
      notifyListeners();
    }
  }

}
