import 'dart:convert';
import 'package:app_test/core/constants/user_consts.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/modules/home/widgets/appbar_profile_container.dart';
import 'package:app_test/modules/home/widgets/home_grid_view.dart';
import 'package:app_test/modules/personal_profile/views/personal_profile_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/services/general_listener.dart';
import 'package:app_test/core/widgets/gradient_bg_image.dart';
import 'package:app_test/modules/home/controllers/home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final generalListener = GeneralListener();
  @override
  void initState() {
    var jsonString;
    Map<String, dynamic> gCache = {};
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    final popups = gCache['popups'];
    if (popups != null && popups.isNotEmpty) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (context.mounted) {
      //     generalListener.startAll(context, "home", popups);
      //   }
      // });
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    final json2String = CacheHelper.getString("US2");
    Map<String, dynamic> us2Cache;
    if (json2String != null && json2String != "") {
      us2Cache = json.decode(json2String) as Map<String, dynamic>;// Convert String back to JSON
    }
    final json1String = CacheHelper.getString("US1");
    Map<String, dynamic> us1Cache = {};
    if (json1String != null && json1String != "") {
      us1Cache = json.decode(json1String) as Map<String, dynamic>;// Convert String back to JSON

      UserSettingConst.userSettings = UserSettingsModel.fromJson(us1Cache);
    }
    return ChangeNotifierProvider(create: (context) => HomeController()..initializeHomeScreen(context, [   "general_settings",
      "user_settings",
      "user2_settings",]),
    child: Consumer<HomeController>(
      builder: (context, value, child) {
      return Scaffold(
        backgroundColor: const Color(0xffFFFFFF),
        body: GradientBgImage(
          padding: const EdgeInsets.all(0),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
            },
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: height * 0.2,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      var top = constraints.biggest.height;
                      return Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          FlexibleSpaceBar(
                            background: Container(
                              decoration:  const BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(30),
                                      bottomRight: Radius.circular(30)),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                      "assets/images/home_images/appbar_images/home_top_background.png",
                                    ),
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap:(){
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PersonalProfileScreen(),));
                                      },
                                      child: AppbarProfileContainer(
                                        imageUrl:(us1Cache['photo'] != null)?
                                        "${us1Cache['photo']}" : '',
                                        userName:(us1Cache['name'] != null)?
                                        "${us1Cache['name']}" : "",
                                        userRole:(us1Cache['role'] != null)?(us1Cache['role'].isNotEmpty)?
                                        "${us1Cache['role'][0]}".tr() : "" : "",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  const HomeGridView(),
                ],
              ),
            ),
          ),
        ),
      );
    },),
    );
  }
}
