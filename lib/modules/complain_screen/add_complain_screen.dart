import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/controller/request_controller/request_controller.dart';
import 'package:rmemp/modules/requests/view_models/add_new_request.viewmodel.dart';
import 'package:rmemp/utils/widgets/text_form_widget.dart';

import '../../constants/check_values.dart';
import '../../utils/gradient_bg_image.dart';
import '../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../routing/app_router.dart';

class NewComplainScreen extends StatefulWidget {
  @override
  State<NewComplainScreen> createState() => _NewComplainScreenState();
}

class _NewComplainScreenState extends State<NewComplainScreen> {
  var selectDepartment;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController subjectController = TextEditingController();
  TextEditingController detailsController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (context) => AddNewRequestViewModel()..initializeAddNewRequestScreen(context: context),
      child: Consumer<AddNewRequestViewModel>(
        builder: (context, value, child) {
          return Scaffold(
            appBar: AppBarWithBookmark(
              title: AppStrings.newRequest.tr().toUpperCase(),
              titleStyle: TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.bold, fontSize: 20),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              routeName: AppRoutes.newComplainScreen.name,
            ),
            backgroundColor: Color(AppColors.white),
            body: Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: SizedBox(
                width: MediaQuery.of(context).size.width < 600
                    ? double.infinity
                    : 800,
                child: SingleChildScrollView(
                  child: Padding(padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        SizedBox(height: 20,),
                        defaultDropdownField(
                          value: value.selectedRequestTypes,
                          title: value.selectedRequestTypes ?? AppStrings.departmentName.tr(),
                          items: value.departments!.map((e) => DropdownMenuItem(
                            value: e['id'].toString(),
                            child: Text(
                              e['title'].toString(),
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(AppColors.almostBlack)
                              ),),
                          ),
                          ).toList(),
                          onChanged: (String? values) {
                            print(values);
                            setState(() {
                              value.selectedRequestTypes = values;
                            });
                          },
                        ),
                        SizedBox(height: 15,),
                        Form(
                          key: formKey,
                          child: defaultTextFormField(
                              hintText: AppStrings.subject.tr(),
                              controller: value.subjectController,
                              context: context,
                              validator: (value){
                                if(value!.isEmpty){
                                  return "${AppStrings.subject.tr()} ${AppStrings.isRequired.tr()}";
                                }
                              }
                          ),
                        ),
                        SizedBox(height: 15,),
                        defaultTextFormField(
                            hintText: AppStrings.details.tr(),
                            controller: value.detailsController,
                            maxLines: 7,
                            context: context,
                            containerHeight: 200
                        ),
                        GestureDetector(
                          onTap: ()async{
                            await value.getImage(
                                context,
                                image1: value.attachmentPersonalImage,
                                image2: value.XImageFileAttachmentPersonal,
                                list2: value.listXAttachmentPersonalImage,
                                one: false,
                                list: value.listAttachmentPersonalImage);
                            Fluttertoast.showToast(
                                msg: AppStrings.addImageSuccessful.tr().toUpperCase(),
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                fontSize: 16.0
                            );
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.only(
                                right: 16, left: 16, top: 16, bottom: 10
                            ),
                            decoration: ShapeDecoration(
                              color: Color(AppColors.white),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:  BorderSide(
                                  color: Color(AppColors.whiteGrey),
                                  width: 1.0,
                                ),
                              ),
                            ),
                            child:  Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      AppStrings.uploadImage.tr(),
                                      style: TextStyle(

                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Color(AppColors.almostBlack)
                                      ),
                                    ),
                                    const Spacer(),
                                    CustomElevatedButton(
                                        onPressed: ()async{
                                          await value.getImage(
                                              context,
                                              image1: value.attachmentPersonalImage,
                                              image2: value.XImageFileAttachmentPersonal,
                                              list2: value.listXAttachmentPersonalImage,
                                              one: false,
                                              list: value.listAttachmentPersonalImage);
                                          Fluttertoast.showToast(
                                              msg: AppStrings.addImageSuccessful.tr().toUpperCase(),
                                              toastLength: Toast.LENGTH_LONG,
                                              gravity: ToastGravity.BOTTOM,
                                              timeInSecForIosWeb: 1,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              fontSize: 16.0
                                          );
                                        },
                                        title: AppStrings.image.tr().toUpperCase(),
                                        width: 100,
                                        isPrimaryBackground: true,
                                        isFuture: false),
                                  ],
                                ),
                                if(value.listAttachmentPersonalImage.isNotEmpty) SizedBox(
                                  height: 90,
                                  child: GridView.builder(
                                    physics: const ClampingScrollPhysics(),
                                    shrinkWrap: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: value.listAttachmentPersonalImage.length,
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4),
                                    itemBuilder: (c, i) {
                                      return buildCustomContainer(
                                          file: value.listAttachmentPersonalImage[i]['preview']);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 35,),
                        if(value.isAddRequestLoading == true) Center(child: CircularProgressIndicator(),),
                        if(value.isAddRequestLoading == false) CustomElevatedButton(
                            onPressed: () async {
                              print("value.listXAttachmentPersonalImage ${value.listXAttachmentPersonalImage}");
                              if(formKey.currentState!.validate()){
                                // value.createNewComplaint(context, images: value.listAttachmentPersonalImage
                                //     .map((e) => XFile(e["compressed"].path)) // تحويل File → XFile
                                //     .toList(),);
                                value.createNewComplaint(context, images: value.listXAttachmentPersonalImage);
                              }
                            },
                            title: AppStrings.sendRequest.tr().toUpperCase(),
                            isPrimaryBackground: true,
                            isFuture: false),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget buildCustomContainer({required dynamic file}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(AppColors.darkBlue),
            width: 2,
          ),
        ),
        child: kIsWeb
            ? (file is Uint8List
            ? Image.memory(file, fit: BoxFit.cover) // 🖥️ ويب
            : const Icon(Icons.image_not_supported))
            : Image.file(file as File, fit: BoxFit.cover), // 📱 موبايل
      ),
    );
  }
}