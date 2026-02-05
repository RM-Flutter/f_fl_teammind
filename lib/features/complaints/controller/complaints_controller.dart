import 'dart:io';
import 'package:app_test/core/models/get_request_comment_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;         // هيتجاهلها في Web
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/dio.dart';
import 'package:app_test/features/complaints/data/models/get_one_request_model.dart';
import 'package:app_test/features/complaints/shared/widgets/success_send_complain.dart';
import 'package:app_test/features/complaints/data/remote_data/complaints_repo.dart';

class ComplaintsController extends ChangeNotifier {
  bool isGetRequestLoading = false;
  bool empty = false;
  bool isAddCommentLoading = false;
  bool getMore = false;
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
  bool loading = true;
  final ScrollController controller = ScrollController();
  final int expectedPageSize = 9;
  int pageNumber = 1;
  int count = 0;
  Set<int> requestsIds = {};
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
  Future<void> getRequestType(BuildContext context) async {
    isGetRequestTypeLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/csrequests-type/entities-operations",
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
        isGetRequestTypeSuccess = true;
        requestTypes = response.data['data'];
      }
      isGetRequestTypeLoading = false;
      notifyListeners();
    } catch (error) {
      getRequestTypeErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
      Fluttertoast.showToast(
          msg: getRequestTypeErrorMessage!,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    } finally {
      isGetRequestTypeLoading = false;
      notifyListeners();
    }
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
    if (page != null) currentPage = page;

    print("currentPage is --> $currentPage");
    isGetRequestLoading = true;
    notifyListeners();

    try {
      final response = await DioHelper.getData(
        url: "/csrequests/entities-operations",
        context: context,
        query: {
          "itemsCount": itemsCount,
          "page": page ?? currentPage,
        },
      );

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
        isGetRequestSuccess = true;

        List newRequest = response.data['data'] ?? [];

        if (currentPage == 1) {
          requests.clear();
          requestsIds.clear();
        }

        if (newRequest.isNotEmpty) {
          getMore = true;
          // شيل التكرار
          List uniqueRequests = newRequest
              .where((p) => !requestsIds.contains(p['id']))
              .toList();

          requests.addAll(uniqueRequests);
          requestsIds.addAll(uniqueRequests.map((p) => p['id']));

          hasMoreRequests = uniqueRequests.isNotEmpty;
          if (hasMoreRequests) currentPage++;
        } else {
          getMore = false;
          hasMoreRequests = false;
          if (currentPage == 1) empty = true;
        }
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
        fontSize: 16.0,
      );
    } finally {
      isGetRequestLoading = false;
      notifyListeners();
    }
  }
  // Future<void> getRequestMine(BuildContext context, {int? page}) async {
  //   if(page != null){currentPage = page;}
  //   print("currentPage is --> $currentPage}");
  //   isGetRequestLoading = true;
  //   notifyListeners();
  //   try {
  //     final response = await DioHelper.getData(
  //       url: "/emp_requests/v1/complain?type=mine",
  //       context: context, // Pass this explicitly only if necessary
  //       query: {
  //         "itemsCount": itemsCount,
  //         "page": page ?? currentPage,
  //       },
  //     );
  //     if(response.data['status'] == false){
  //       Fluttertoast.showToast(
  //           msg: response.data['message'],
  //           toastLength: Toast.LENGTH_LONG,
  //           gravity: ToastGravity.BOTTOM,
  //           timeInSecForIosWeb: 5,
  //           backgroundColor: Colors.red,
  //           textColor: Colors.white,
  //           fontSize: 16.0
  //       );
  //     }else{
  //       newRequests = response.data['complains'] ?? [];
  //       if (page == 1) {
  //         requests.clear(); // Clear only when loading the first page
  //       }
  //       if (newRequests.isNotEmpty) {
  //         requests.addAll(newRequests);
  //         print("LENGTH IS --> ${newRequests.length}");
  //         if (hasMore) currentPage++;
  //       } else {
  //         hasMoreRequests = false; // No more data to fetch
  //       }
  //
  //       isGetRequestSuccess = true;
  //     }
  //     isGetRequestLoading = false;
  //     notifyListeners();
  //   } catch (error) {
  //     getRequestErrorMessage = error is DioError
  //         ? error.response?.data['message'] ?? 'Something went wrong'
  //         : error.toString();
  //     Fluttertoast.showToast(
  //         msg: getRequestErrorMessage!,
  //         toastLength: Toast.LENGTH_LONG,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 5,
  //         backgroundColor: Colors.red,
  //         textColor: Colors.white,
  //         fontSize: 16.0
  //     );
  //   } finally {
  //     isGetRequestLoading = false;
  //     notifyListeners();
  //   }
  // }
  Future<void> getOneRequest(BuildContext context, id) async {
    isGetRequestLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/csrequests/entities-operations/$id",
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
    images = listAttachmentPersonalImage
        .map((e) => XFile(e["upload"].path)) // تحويل File → XFile
        .toList();
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
            return SuccessfulSendRequestBottomsheet(response.data['message']);
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
  Future<void> getProfileImageByGallery() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.gallery);
    if (imageFileProfile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await imageFileProfile.readAsBytes();

      listAttachmentPersonalImage.add({
        "preview": bytes,     // 🖥️ للعرض
        "upload": bytes,      // 🖥️ للرفع برضه
      });
    } else {
      File originalFile = File(imageFileProfile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        listAttachmentPersonalImage.add({
          "preview": compressedFile,   // 📱 للعرض
          "upload": compressedFile,    // 📱 للرفع
        });
      }
    }


    notifyListeners();
  }

  Future<void> getProfileImageByCam() async {
    final XFile? imageFileProfile = await picker.pickImage(source: ImageSource.camera);
    if (imageFileProfile == null) return;

    if (kIsWeb) {
      Uint8List bytes = await imageFileProfile.readAsBytes();

      listAttachmentPersonalImage.add({
        "preview": bytes,     // 🖥️ للعرض
        "upload": bytes,      // 🖥️ للرفع برضه
      });
    } else {
      File originalFile = File(imageFileProfile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        listAttachmentPersonalImage.add({
          "preview": compressedFile,   // 📱 للعرض
          "upload": compressedFile,    // 📱 للرفع
        });
      }
    }


    notifyListeners();
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
