import 'package:app_test/modules/points/controllers/points_cubit/points_provider.dart';
import 'package:app_test/modules/points/controllers/prize_cubit/prize_provider.dart';
import 'package:app_test/modules/points/widgets/sliver_app_bar_points.dart';
import 'package:app_test/modules/points/widgets/sliver_list_points.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/modules/home/controllers/home_controller.dart';
import 'core/api/api_services_implementation.dart';
import 'data/repositories/prize_repository/prize_repository_implementation.dart';
import 'data/repositories/redeem_prize_repository/redeem_prize_repository_implementation.dart';

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
        ChangeNotifierProvider(create: (context) => PointsProvider()),
        ChangeNotifierProvider(create: (context) => HomeController()),
        // BlocProvider(create: (context) => HistoryCubit(GetHistoryRepositoryImplementation(ApiServicesImplementation()))..getHistory()),

        //BlocProvider(create: (context) => ConditionCubit(GetConditionRepositoryImplementation(ApiServicesImplementation()))..getCondition()),
      ],
      child: ChangeNotifierProvider(
        create: (context) => PrizeProvider(
            GetPrizeRepositoryImplementation(ApiServicesImplementation(),context), RedeemPrizeRepositoryImplementation(ApiServicesImplementation(), context)),
        child: Scaffold( resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xffFFFFFF),
          body: SafeArea(
            child: GradientBgImage(
              padding: EdgeInsets.zero,
              child: RefreshIndicator.adaptive(
                onRefresh: () async {
          await Provider.of<HomeController>(context, listen: false).initializeHomeScreen(context, ["user_settings"]);
          },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(), // << مهم هنا
              slivers: [
                SliverAppBarPoints(arrow: widget.arrow),
                // SizedBox(height: 20,),
                const SliverListPoints(),
              ],
            ),
          ),

        ),
          ),
        ),
      ),
    );
  }
}
