import 'dart:io';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:rmemp/models/get_one_request_model.dart';
import 'package:rmemp/models/get_request_comment_model.dart';
import 'package:rmemp/modules/requests/views/widgets/success_send_complain.dart';

import '../../constants/app_strings.dart';

class RequestController extends ChangeNotifier {
  bool isGetRequestLoading = false;
  bool isAddCommentLoading = false;
  bool isAddRequestLoading = false;
  bool isGetRequestCommentLoading = false;
  bool isGetRequestTypeLoading = false;
  bool isGetRequestSuccess = false;
  bool isAddCommentSuccess = false;
  bool isAddRequestSuccess = false;
  bool isGetRequestCommentSuccess = false;
  bool isGetRequestTypeSuccess = false;
  TextEditingController contentController = TextEditingController();
  TextEditingController subjectController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  bool hasMoreRequests = true;
  String? selectDepartment;
  String? getRequestErrorMessage;
  String? getRequestCommentErrorMessage;
  String? getRequestTypeErrorMessage;
  String? errorAddCommentMessage;
  String? errorAddRequestMessage;
  final picker = ImagePicker();
  bool hasMore = true;
  final ScrollController controller = ScrollController();
  final int expectedPageSize = 9;
  int pageNumber = 1;
  int count = 0;
  Set<int> commentIds = {};
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  GetRequestCommentModel? getRequestCommentModel;
  GetOneRequestModel? getOneRequestModel;
  List requests = [];
  List requestsTeam = [];
  List newRequestsTeam = [];
  List requestTypes = [];
  List newComments = [];
  List comments = [];
  List newRequests = [];
  int currentPage = 1;
  final int itemsCount = 9;
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
  }

  Future<void> addComment(BuildContext context, {required String id, List<XFile>? images, String? voicePath, slug}) async {
    if(images == null  && voicePath == null && contentController.text.isEmpty){
      print("NULL COMMENT");
      return;
    }
    isAddCommentLoading = true;
    notifyListeners();

    try {
      var response;
      print("Voice Path: $voicePath");

      // Check if we have either images or a voice file to send
      if (images != null || voicePath != null) {
        print("Uploading media...");

        FormData formData = FormData.fromMap({
          if (contentController.text.isNotEmpty) "content": contentController.text,
          if (images != null && images.isNotEmpty)
            "images[]": await Future.wait(images.map(
                  (file) async => await MultipartFile.fromFile(file.path, filename: file.name),
            ).toList()),
          if (voicePath != null && File(voicePath).existsSync())
            "sounds": await MultipartFile.fromFile(voicePath, filename: "recorded_audio.m4a"),
        });

        response = await DioHelper.postFormData(
          url: "/$slug/entities-operations/$id/comments",
          context: context,
          formdata: formData,
        );
      } else {
        response = await DioHelper.postData(
          url: "/$slug/entities-operations/$id/comments",
          context: context,
          data: {
            if (contentController.text.isNotEmpty) "content": contentController.text,
          },
        );
      }

      if (response.data['status'] == false) {
        Fluttertoast.showToast(
          msg: response.data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        isAddCommentSuccess = true;
        Fluttertoast.showToast(
          msg: response.data['message'],
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        contentController.clear();
        // Refresh comments after successful upload
        getRequestCommentModel = null;
        // getRequestComment(context, id);
      }
    } catch (error) {
      errorAddCommentMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();

      Fluttertoast.showToast(
        msg: errorAddCommentMessage!,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } finally {
      isAddCommentLoading = false;
      notifyListeners();
    }
  }
  Future<void> getRequest(BuildContext context, {int? page}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isGetRequestLoading = true;
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
        newRequestsTeam = response.data['complains'] ?? [];
        if (page == 1) {
          requestsTeam.clear(); // Clear only when loading the first page
        }
        if (newRequests.isNotEmpty) {
          requestsTeam.addAll(newRequestsTeam);
          print("LENGTH IS --> ${newRequestsTeam.length}");
          // if (hasMore) currentPage++;
        } else {
          hasMoreRequests = false; // No more data to fetch
        }

        isGetRequestSuccess = true;
      }
      isGetRequestLoading = false;
      notifyListeners();
    } catch (error) {
      getRequestErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getRequestErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetRequestLoading = false;
      notifyListeners();
    }
  }
  Future<void> getRequestMine(BuildContext context, {int? page}) async {
    if(page != null){currentPage = page;}
    print("currentPage is --> $currentPage}");
    isGetRequestLoading = true;
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
        newRequests = response.data['complains'] ?? [];
        if (page == 1) {
          requests.clear(); // Clear only when loading the first page
        }
        if (newRequests.isNotEmpty) {
          requests.addAll(newRequests);
          print("LENGTH IS --> ${newRequests.length}");
          if (hasMore) currentPage++;
        } else {
          hasMoreRequests = false; // No more data to fetch
        }

        isGetRequestSuccess = true;
      }
      isGetRequestLoading = false;
      notifyListeners();
    } catch (error) {
      getRequestErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getRequestErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetRequestLoading = false;
      notifyListeners();
    }
  }
  Future<void> getOneRequest(BuildContext context, id, type) async {
    isGetRequestLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/emp_requests/v1/complain/$id?type=$type",
        query: {
          "with" : "ptype_id"
        },
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
        getOneRequestModel = GetOneRequestModel.fromJson(response.data);
      }
      isGetRequestLoading = false;
      notifyListeners();
    } catch (error) {
      getRequestErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getRequestErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetRequestLoading = false;
      notifyListeners();
    }
  }

  Future<void> addRequest(BuildContext context, {List<XFile>? images}) async {
    isAddRequestLoading = true;
    notifyListeners();
    var response;
    FormData formData = FormData.fromMap({
      if(subjectController.text != null && subjectController.text.isNotEmpty)"title" : subjectController.text,
      if(detailsController.text != null && detailsController.text.isNotEmpty) "content" : detailsController.text,
      "type_id" : selectDepartment.toString(),
      "main_thumbnail[]": images != null
          ? await Future.wait(
          images.map((file) async => await MultipartFile.fromFile(file.path, filename: file.name))
      )
          : [],
    });
    try {
      if(images != null && images.isNotEmpty){
        response = await DioHelper.postData(
            url: "/rm_postcontrol/v1/add_request",
            context: context,
            data: formData
        );
      }else{
        response = await DioHelper.postData(
            url: "/rm_postcontrol/v1/add_request",
            context: context,
            data: {
              if(subjectController.text != null && subjectController.text.isNotEmpty) "title" : subjectController.text,
              if(detailsController.text != null && detailsController.text.isNotEmpty) "content" : detailsController.text,
              "type_id" : selectDepartment.toString(),
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
        isAddRequestSuccess = true;
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.white,
          builder: (context) {
            return SuccessfulSendRequestBottomsheet();
          },
        );
      }
      isAddRequestLoading = false;
      notifyListeners();
    } catch (error) {
      errorAddRequestMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg:errorAddRequestMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isAddRequestLoading = false;
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