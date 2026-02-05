import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/features/complaints/data/models/get_one_request_model.dart';

import '../../../../../core/constants/app_colors.dart';


class RequestDetailsAppbarWidget extends StatelessWidget {
  GetOneRequestModel? getOneRequestModel;
  List? types;
  RequestDetailsAppbarWidget({super.key, this.getOneRequestModel, this.types});
  var type;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.s200,
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      width: LayoutService.getWidth(context),
      decoration: BoxDecoration(
        image: const DecorationImage(
            image: AssetImage("assets/images/png/home_back.png"),
            fit: BoxFit.cover,
            opacity: 0.4),
        color: Color(AppColors.dark),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(AppSizes.s28),
            bottomRight: Radius.circular(AppSizes.s28)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: kIsWeb ? 1100 : double.infinity,
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: (){Navigator.pop(context);},
                            child: Icon(Icons.arrow_back, color: Color(0xffFFFFFF),)),
                        Spacer(),
                        Text(
                          AppStrings.myRequest.tr().toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Spacer(),
                        Container(width: 20,),
                      ],
                    ),
                    SizedBox(height: 16,),
                    Text(
                      getOneRequestModel!.item!.title!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: kIsWeb? MediaQuery.sizeOf(context).width * 0.1:MediaQuery.sizeOf(context).width * 0.25,
                          child: Text(
                            DateFormat("dd/MM/yyyy", LocalizationService.isArabic(context: context)? "ar" : "en").format(DateTime.parse(getOneRequestModel!.item!.createdAt.toString())).toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.folder_open_outlined, color: Colors.white,),
                            SizedBox(width: 5,),
                            SizedBox(
                              width: kIsWeb? MediaQuery.sizeOf(context).width * 0.1:MediaQuery.sizeOf(context).width * 0.25,
                              child: Text( getOneRequestModel!.item!.pType!.title.toString().tr(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle
                              ),
                            ),
                            SizedBox(width: 5,),
                            SizedBox(
                              width:kIsWeb? MediaQuery.sizeOf(context).width * 0.1: MediaQuery.sizeOf(context).width * 0.25,
                              child: Text(
                                getOneRequestModel!.item!.pstatus!.key!.toString().tr().toUpperCase() ?? "",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 16,),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
