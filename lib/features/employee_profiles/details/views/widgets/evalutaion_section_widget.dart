import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/features/employee_profiles/shared/models/employee_profile_model.dart';
import 'package:app_test/features/evaluation/shared/widgets/profile_tile_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class EvalutaionSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  List? evaluations = [];
  var id;
  var empName;
  EvalutaionSectionWidget({super.key, required this.employee, this.evaluations, this.id, this.empName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          gapH12,
             ListView.separated(
                 reverse: false,
                 shrinkWrap: true,
                 physics: const ClampingScrollPhysics(),
                 padding: EdgeInsets.zero,
                 itemBuilder: (context, index) =>  ProfileTileEva(
                   isTitleOnly: false,
                   isViewArrow: true,
                   createAt: evaluations![index]['created_at'],
                   eva: evaluations![index]['results'],
                   gainedPoints: evaluations![index]['gainedPoints'],
                   totalPoints: evaluations![index]['totalPoints'],
                   title: "${evaluations![index]['title']}",
                   icon: evaluations![index]['done'] == true ? Icon(Icons.check_circle_outline, color: Colors.green, size: 20,): Image.asset("assets/images/new-cale.png", width: 20, height: 20, color: Colors.black),
                   url: (evaluations![index]['submitUrl'] != null)? evaluations![index]['submitUrl'].toString() : null,
                 ),
                 separatorBuilder: (context, index) => SizedBox(height: 12,),
                 itemCount:evaluations!.length <= 6 ? evaluations!.length : 6),
          if(evaluations!.isNotEmpty) SizedBox(height: 24),
          if(evaluations!.isNotEmpty) Center(
              child: CustomElevatedButton(
                  backgroundColor: Color(AppColors.secondaryButton),
                  titleSize: AppSizes.s12,
                  title: AppStrings.viewEvaluations.tr().toUpperCase(),
                  onPressed: ()async{
                    await context.pushNamed(
                        AppRoutes.evaluationScreen.name,
                        extra: {
                          "empId": id.toString(),
                          "begin": const Offset(1.0, 0.0),
                        },
                        pathParameters: {
                          'lang': context.locale.languageCode,
                          // "empName" : empName.toString()
                        });
                  },
              )),

        ],
      ),
    );
  }
}
