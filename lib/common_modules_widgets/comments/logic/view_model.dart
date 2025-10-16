
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rmemp/models/get_comment_model.dart';

import '../../../constants/app_strings.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/dio.dart';

class CommentProvider extends ChangeNotifier{
  bool isGetCommentLoading = false;
  bool isGetCommentSuccess = false;
  bool isAddCommentLoading = false;
  bool isAddCommentSuccess = false;
  int pageNumber = 1;
  Set<int> commentIds = {};
  bool hasMore = true;
  List comments = [];
  List newComments = [];
  GetCommentModel? getCommentModel;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  XFile? XImageFileAttachmentPersonal;
  File? attachmentPersonalImage;
  List listAttachmentPersonalImage = [];
  List<XFile> listXAttachmentPersonalImage = [];
  final picker = ImagePicker();
  String? errorAddCommentMessage;
  String? getRequestCommentErrorMessage;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
  Future<void> addComment(BuildContext context, {required String id, List<XFile>? images, String? voicePath, slug}) async {
    if(images == null  && voicePath == null && contentController.text.isEmpty){
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
        getCommentModel = null;
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
  Future<void> getComment(BuildContext context,slug, id, {pages, bool? isNewPage}) async {
    if(pages != null){pageNumber = pages;}
    isGetCommentLoading = true;
    notifyListeners();
    try {
      final response = await DioHelper.getData(
        url: "/$slug/entities-operations/$id/comments",
        context: context, // Pass this explicitly only if necessary
        query: {
          "page": pages ?? pageNumber,
          "order_dir" : "desc"
        },
      );
      newComments = response.data['comments'] ?? [];
      if (pages == 1) {
        comments.clear(); // Clear only when loading the first page
      }
      if (newComments.isNotEmpty) {
        comments.addAll(newComments);
        print("LENGTH IS --> ${newComments.length}");
        hasMore = true;
         pageNumber++;
        print("LENGTH IS --> ${pageNumber}");
        print("LENGTH IS --> ${hasMore}");
      } else {
        hasMore = false; // No more data to fetch
      }
      isGetCommentLoading = false;
      isGetCommentSuccess = true;
      notifyListeners();
    } catch (error) {
      getRequestCommentErrorMessage = error is DioError
          ? error.response?.data['message'] ?? 'Something went wrong'
          : error.toString();
    } finally {
      isGetCommentLoading = false;
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