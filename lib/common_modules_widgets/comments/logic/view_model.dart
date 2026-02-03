
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:rmemp/models/get_comment_model.dart';
import 'package:rmemp/platform/platform_is.dart';

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

        Map<String, dynamic> formDataMap = {
          // إذا كان هناك صوت فقط بدون نص، أضف نص افتراضي
          "content": contentController.text.isNotEmpty 
              ? contentController.text 
              : (voicePath != null ? "🎤 ${AppStrings.voiceMessage.tr()}" : ""),
        };
        
        if (images != null && images.isNotEmpty) {
          formDataMap["images[]"] = await Future.wait(images.map(
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
          ).toList());
        }
        
        if (voicePath != null) {
          // على الويب، voicePath قد يكون blob URL أو file path
          if (kIsWeb || PlatformIs.web) {
            try {
              // على الويب، نحتاج إلى قراءة blob URL كـ bytes
              if (voicePath.startsWith('blob:') || voicePath.startsWith('http://') || voicePath.startsWith('https://')) {
                // إذا كان blob URL أو http URL، نحتاج إلى تحميله
                try {
                  final response = await http.get(Uri.parse(voicePath));
                  if (response.statusCode == 200) {
                    formDataMap["sounds"] = MultipartFile.fromBytes(
                      response.bodyBytes,
                      filename: "recorded_audio.m4a",
                    );
                  } else {
                    throw Exception("Failed to load blob URL: ${response.statusCode}");
                  }
                } catch (e) {
                  print("Error loading blob URL: $e");
                  // محاولة استخدام path مباشرة كبديل
                  try {
                    formDataMap["sounds"] = await MultipartFile.fromFile(voicePath, filename: "recorded_audio.m4a");
                  } catch (e2) {
                    print("Error using voice path directly: $e2");
                    throw e2;
                  }
                }
              } else {
                // إذا كان file path عادي، محاولة استخدامه مباشرة
                try {
                  formDataMap["sounds"] = await MultipartFile.fromFile(voicePath, filename: "recorded_audio.m4a");
                } catch (e) {
                  print("Error using voice path on web: $e");
                  throw e;
                }
              }
            } catch (e) {
              print("Error handling voice file on web: $e");
              // إذا فشل كل شيء، تخطي إرسال الصوت
              Fluttertoast.showToast(
                msg: "Error uploading voice message. Please try again.",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
              );
              isAddCommentLoading = false;
              notifyListeners();
              return;
            }
          } else {
            // على الموبايل، التحقق من وجود الملف
            if (File(voicePath).existsSync()) {
              formDataMap["sounds"] = await MultipartFile.fromFile(voicePath, filename: "recorded_audio.m4a");
            }
          }
        }
        
        FormData formData = FormData.fromMap(formDataMap);

        response = await DioHelper.postFormData(
          url: "/$slug/entities-operations/$id/comments",
          context: context,
          formdata: formData,
          query: null,
          data: {},
        );
      } else {
        response = await DioHelper.postData(
          url: "/$slug/entities-operations/$id/comments",
          context: context,
          query: null,
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
        // مسح الصور والصوت بعد الإرسال الناجح
        listXAttachmentPersonalImage.clear();
        listAttachmentPersonalImage.clear();
        XImageFileAttachmentPersonal = null;
        attachmentPersonalImage = null;
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
      final fetchedComments = (response.data['comments'] as List?) ?? [];

      if (pages == 1 || isNewPage != true) {
        comments.clear();
        commentIds.clear();
      }

      for (final comment in fetchedComments) {
        final int? commentId = comment['id'] is int
            ? comment['id'] as int
            : int.tryParse('${comment['id']}');

        if (commentId == null) continue;

        if (!commentIds.contains(commentId)) {
          commentIds.add(commentId);
          comments.add(comment);
        } else if (pages == 1) {
          final index = comments.indexWhere(
              (existing) => existing['id'] == commentId);
          if (index != -1) {
            comments[index] = comment;
          }
        }
      }

      hasMore = fetchedComments.isNotEmpty;
      if (hasMore) {
        pageNumber = (pages ?? pageNumber) + 1;
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
          print("Image added successfully. Total images: ${listXAttachmentPersonalImage.length}");
        } else {
          print("Failed to compress image");
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
          print("Image added successfully. Total images: ${listXAttachmentPersonalImage.length}");
        } else {
          print("Failed to compress image");
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