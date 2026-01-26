import 'dart:io';

import 'package:easy_localization/easy_localization.dart' as locale;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/widgets/template_page.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/features/more/views/notification/controllers/notification_provider.dart';
import 'package:app_test/core/widgets/text_form_widget.dart';

import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/check_values.dart';


class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  @override
  State<AddNotificationScreen> createState() =>
      _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  late final NotificationProviderModel viewModel;
  @override
  void initState() {
    super.initState();
    viewModel = NotificationProviderModel();
    viewModel.initializeAddTaskScreen(context: context);
    viewModel.listAttachmentPersonalImage = [];
    viewModel.listXAttachmentPersonalImage = [];
  }
  @override
  Widget build(BuildContext context) {
    List<int> tempSelectedIds = List.from(viewModel.listIds);
    List<int> tempDepSelectedIds = List.from(viewModel.listIdsDepartment);
    return ChangeNotifierProvider<NotificationProviderModel>(
      create: (_) => viewModel,
      child: TemplatePage(
          pageContext: context,
          title: AppStrings.addNotification.tr(),
          body: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.s16, horizontal: AppSizes.s12),
                child: Consumer<NotificationProviderModel>(
                  builder: (context, viewModel, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      gapH14,
                      TextField(
                        controller: viewModel.titleArController,
                        decoration: InputDecoration(
                          hintText: AppStrings.titleAr.tr(),
                        ),
                      ),gapH14,
                      TextField(
                        controller: viewModel.titleEnController,
                        decoration: InputDecoration(
                          hintText: AppStrings.titleEn.tr(),
                        ),
                      ),gapH14,
                      TextField(
                        maxLines: 8,
                        controller: viewModel.contentArController,
                        decoration: InputDecoration(
                          hintText: AppStrings.contentAr.tr(),

                        ),
                      ),
                      gapH14,TextField(
                        maxLines: 8,
                        controller: viewModel.contentEnController,
                        decoration: InputDecoration(
                          hintText: AppStrings.contentEn.tr(),

                        ),
                      ),
                      gapH14,
                      defaultDropdownField(
                        value: viewModel.selectNotificationType,
                        title: viewModel.selectNotificationType ?? AppStrings.type.tr(),
                        items: viewModel.notificationsType.map((e) => DropdownMenuItem(
                            value: e['value'].toString(),
                            child: Text(
                              e['name'].toString(),
                              style:  const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff191C1F)
                              ),),
                        ),
                        ).toList(),
                        onChanged: (String? values) {
                          print(values);
                          setState(() {
                            viewModel.selectNotificationType = values;
                            print("selectNotificationType is --> ${viewModel.selectNotificationType}");
                            viewModel.listIds.clear();
                            viewModel.listIdsDepartment.clear();
                          });
                        },
                      ),
                      if(viewModel.selectNotificationType == "some_employees"&& viewModel.employees.isNotEmpty) gapH14,
                      if(viewModel.selectNotificationType == "some_employees"&& viewModel.employees.isNotEmpty) GestureDetector(
                        onTap: () async {
                          String searchQuery = "";
                          List<Map> filteredEmployees = viewModel.employees;
                          final selected = await showModalBottomSheet<List<Map>>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          AppStrings.employeeName.tr(),
                                          style:  TextStyle(
                                              color: Color(AppColors.dark),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 18),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          decoration: InputDecoration(
                                            hintText: AppStrings.searchByName.tr(),
                                            prefixIcon:  const Icon(Icons.search),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            setModalState(() {
                                              searchQuery = value.toLowerCase();
                                              filteredEmployees = viewModel.employees
                                                  .where((e) => e['name']
                                                  .toString()
                                                  .toLowerCase()
                                                  .contains(searchQuery))
                                                  .toList();
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: filteredEmployees.map((employee) {
                                              final isSelected =
                                              tempSelectedIds.contains(employee['id']);
                                              return CheckboxListTile(
                                                value: isSelected,
                                                title: Text(employee['name']),
                                                onChanged: (bool? value) {
                                                  setModalState(() {
                                                    if (value == true) {
                                                      tempSelectedIds.add(employee['id']);
                                                    } else {
                                                      tempSelectedIds.remove(employee['id']);
                                                    }
                                                  });
                                                },
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                              viewModel.employees
                                                  .where((e) => tempSelectedIds.contains(e['id']))
                                                  .toList(),
                                            );
                                          },
                                          child: Text(
                                            AppStrings.confirm.tr(),
                                            style:  const TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );


                          if (selected != null) {
                            setState(() {
                              viewModel.listIds = selected.map((e) => e['id']).toList();
                            });
                          }
                        },
                        child: Container(
                          height: 65,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.s10),
                              side: const BorderSide(
                                color: Color(0xffE3E5E5),
                                width: 1.0,
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(viewModel.listIds.isEmpty
                                  ? AppStrings.employeeName.tr()
                                  : '${viewModel.listIds.length} ${AppStrings.selected.tr()}', style:  const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff191C1F)),),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      if(viewModel.selectNotificationType == "departments"&& viewModel.departments.isNotEmpty) gapH14,
                      if(viewModel.selectNotificationType == "departments" && viewModel.departments.isNotEmpty) GestureDetector(
                        onTap: () async {
                          final selected = await showModalBottomSheet<List<Map>>(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return StatefulBuilder(
                                builder: (context, setModalState) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(AppStrings.departmentName.tr(), style:
                                        TextStyle(color: Color(AppColors.dark), fontWeight: FontWeight.w700, fontSize: 18),),
                                        ...viewModel.departments.map((department) {
                                          final isSelected = tempDepSelectedIds.contains(department['id']);
                                          return CheckboxListTile(
                                            value: isSelected,
                                            selectedTileColor: Color(AppColors.dark),
                                            title: Text(department['title']),
                                            onChanged: (bool? value) {
                                              setModalState(() {
                                                if (value == true) {
                                                  tempDepSelectedIds.add(department['id']);
                                                } else {
                                                  tempDepSelectedIds.remove(department['id']);
                                                }
                                              });
                                            },
                                          );
                                        }),
                                        ElevatedButton(
                                          onPressed: () {
                                            print("tempDepSelectedIds --> $tempDepSelectedIds");
                                            print("listIds --> ${viewModel.listIdsDepartment}");
                                            Navigator.pop(context, viewModel.departments.where((e) => tempDepSelectedIds.contains(e['id'])).toList());
                                          },
                                          child: Text(AppStrings.confirm.tr(), style:  const TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.w500
                                          ),),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );

                          if (selected != null) {
                            setState(() {
                              viewModel.listIdsDepartment = selected.map((e) => e['id']).toList();
                            });
                          }
                        },
                        child: Container(
                          height: 65,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.s10),
                              side: const BorderSide(
                                color: Color(0xffE3E5E5),
                                width: 1.0,
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(viewModel.listIdsDepartment.isEmpty
                                  ? AppStrings.departmentName.tr()
                                  : '${viewModel.listIdsDepartment.length} ${AppStrings.selected.tr()}', style:  const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff191C1F)),),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      gapH14,
                      GestureDetector(
                        // onTap: ()async{
                        //   await viewModel.getImage(
                        //       context,
                        //       image1: viewModel.attachmentPersonalImage,
                        //       image2: viewModel.XImageFileAttachmentPersonal,
                        //       list2: viewModel.listXAttachmentPersonalImage,
                        //       one: false,
                        //       list: viewModel.listAttachmentPersonalImage);
                        //   Fluttertoast.showToast(
                        //       msg: AppStrings.addImageSuccessful.tr().toUpperCase(),
                        //       toastLength: Toast.LENGTH_LONG,
                        //       gravity: ToastGravity.BOTTOM,
                        //       timeInSecForIosWeb: 1,
                        //       backgroundColor: Colors.green,
                        //       textColor: Colors.white,
                        //       fontSize: 16.0
                        //   );
                        // },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.only(
                              right: 16, left: 16, top: 16, bottom: 10
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0xffFFFFFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side:  const BorderSide(
                                color: Color(0xffE3E5E5),
                                width: 1.0,
                              ),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0C000000),
                                blurRadius: 10,
                                offset: Offset(0, 1),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child:  Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    AppStrings.uploadImage.tr(),
                                    style:  const TextStyle(

                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff191C1F)
                                    ),
                                  ),
                                  const Spacer(),
                                  CustomElevatedButton(
                                      onPressed: ()async{
                                        await viewModel.getImage(
                                            context,
                                            image1: viewModel.attachmentPersonalImage,
                                            image2: viewModel.XImageFileAttachmentPersonal,
                                            list2: viewModel.listXAttachmentPersonalImage,
                                            one: false,
                                            list: viewModel.listAttachmentPersonalImage);
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
                              if(viewModel.listAttachmentPersonalImage.isNotEmpty) SizedBox(
                                height: 90,
                                child: GridView.builder(
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: viewModel.listAttachmentPersonalImage.length,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4),
                                  itemBuilder: (c, i) {
                                    return buildCustomContainer(
                                        file: CheckValuesFromApi.safeArray(viewModel.listAttachmentPersonalImage)[i]['compressed'] as File,
                                    onTap: (){
                                        setState(() {
                                          viewModel.listAttachmentPersonalImage.removeAt(i);
                                          viewModel.listXAttachmentPersonalImage.removeAt(i);
                                        });
                                    }
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      gapH14,
                      Container(
                        height: 65,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.s10),
                            side: const BorderSide(
                              color: Color(0xffE3E5E5),
                              width: 1.0,
                            ),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x0C000000),
                              blurRadius: 10,
                              offset: Offset(0, 1),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(AppStrings.allowComments.tr(), style:  TextStyle(
                              color: Color(AppColors.textC4), fontWeight: FontWeight.w400, fontSize: 12,
                            ),),
                            const Spacer(),
                            GestureDetector(
                              onTap: (){
                                setState(() {
                                  viewModel.allowComment = !viewModel.allowComment;
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xff090B60)),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: viewModel.allowComment == true? const Color(0xff090B60) : Colors.transparent
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      gapH14,
                      const SizedBox(height: 30,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(viewModel.isLoading == false) CustomElevatedButton(
                            backgroundColor:
                            Theme.of(context).colorScheme.primary,
                            titleSize: AppSizes.s14,
                            radius: AppSizes.s24,
                            title: AppStrings.addNotification.tr(),
                            onPressed: () async {
                              viewModel.addNotification(context, depIds: tempDepSelectedIds, empIds: tempSelectedIds);
                            },
                          ),
                          if(viewModel.isLoading == true) const CircularProgressIndicator()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }
  Widget buildCustomContainer({file, onTap}
      ) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: const Color(0xFF011A51),
                  width: 2
              ),
            ),
            child:  Image(
              image: FileImage(file!),
              fit: BoxFit.cover,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: const Padding(
              padding: EdgeInsets.all(5.0),
              child: Icon(Icons.delete, color: Colors.red,),
            ),
          )
        ],
      ),
    );
  }
}
