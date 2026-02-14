import 'package:app_test/features/points/core/points_api/api_services_implementation.dart';
import 'package:app_test/features/points/views/points/points_categories/widgets/silver_app_bar/sliver_app_bar_points.dart';
import 'package:app_test/features/points/views/points/points_categories/widgets/sliver_list/sliver_list_points.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/features/home/controllers/home_controller.dart';
 
import '../../../controllers/points_controller/points_controller.dart';
import '../../../controllers/prize_controller/prize_controller.dart';
import '../../../data/repositories/prize_repository/prize_repository_implementation.dart';
import '../../../data/repositories/redeem_prize_repository/redeem_prize_repository_implementation.dart';


class PointsScreen extends StatefulWidget {
  bool arrow;
  PointsScreen({super.key, required this.arrow});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PointsController()),
        ChangeNotifierProvider(create: (context) => HomeController()),
        // BlocProvider(create: (context) => HistoryCubit(GetHistoryRepositoryImplementation(ApiServicesImplementation()))..getHistory()),

        //BlocProvider(create: (context) => ConditionCubit(GetConditionRepositoryImplementation(ApiServicesImplementation()))..getCondition()),
      ],
      child: ChangeNotifierProvider(
        create: (context) => PrizeController(
            GetPrizeRepositoryImplementation(ApiServicesImplementation(),context), RedeemPrizeRepositoryImplementation(ApiServicesImplementation(), context)),
        child: Scaffold( resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xffFFFFFF),
          body: SafeArea(
            child: GradientBgImage(
              padding: EdgeInsets.zero,
              child: CustomScrollView(
                physics: ClampingScrollPhysics(),
                slivers: [
                  SliverAppBarPoints(arrow: widget.arrow,),
                  SliverListPoints(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
