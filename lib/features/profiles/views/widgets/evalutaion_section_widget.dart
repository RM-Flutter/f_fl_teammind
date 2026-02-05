import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/modules/profiles/models/employee_profile.model.dart';
import 'package:rmemp/modules/profiles/views/widgets/profile_tile.widget.dart';
import 'package:rmemp/routing/app_router.dart';
import '../../../../../constants/app_sizes.dart';

class EvalutaionSectionWidget extends StatelessWidget {
  final EmployeeProfileModel? employee;
  List? evaluations = [];
  var id;
  var empName;
  EvalutaionSectionWidget({super.key, required this.employee, this.evaluations, this.id, this.empName});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.primary,
      fontSize: AppSizes.s13,
    );
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
                   icon: evaluations![index]['done'] == true ?const Icon(Icons.check_circle_outline, color: Colors.green,):const Icon(Icons.calendar_month, color: Colors.black,),
                   url: (evaluations![index]['submitUrl'] != null)? evaluations![index]['submitUrl'].toString() : null,
                 ),
                 separatorBuilder: (context, index) => const SizedBox(height: 15,),
                 itemCount:evaluations!.length <= 6 ? evaluations!.length : 6),
          if(evaluations!.isNotEmpty)gapH24,
          if(evaluations!.isNotEmpty) Center(
              child: CustomElevatedButton(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
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
