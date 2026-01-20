import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_test/constants/cache_consts.dart';
import '../../../constants/app_colors.dart';
import '../../../general_services/backend_services/api_service/dio_api_service/shared.dart';
import '../../../general_services/general_listener.dart';
import '../../../utils/base_page/mobile.scaffold.dart';
import '../view_models/home.viewmodel.dart';

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
    var gCache;
    jsonString = CacheHelper.getString("USG");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      gCache = json.decode(jsonString) as Map<String, dynamic>; // Convert String back to JSON
    }
    final popups = gCache?['popups'];
    if (popups != null && popups.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          generalListener.startAll(context, "home", popups);
        }
      });
    }

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    Widget _sectionTitle(String title) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideScreen = constraints.maxWidth >= 800;
          final double sidePadding = isWideScreen ? 20 : 10;
          final double textFontSize = isWideScreen ? 16 : 14;

          return Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xffDFDFDF), width: 1),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.w500,
                  color: Color(AppColors.dark),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sidePadding),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xffDFDFDF), width: 1),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWeb = constraints.maxWidth >= 800;
        final EdgeInsets pagePadding = isWeb
            ? const EdgeInsets.symmetric(horizontal: 10)
            : const EdgeInsets.symmetric(horizontal: 10);
        final double gridChildAspectRatio = isWeb ? 1.2 : 1 / 1.3;
        final int gridCount = isWeb ? 4 : 2;

        return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          body: RefreshIndicator.adaptive(
            onRefresh: () async {},
            child: SingleChildScrollView(
              child: Center(
                  child: Text("HOME SCREEN")
              ),
            ),
          ),
        );
      },
    );

  }
}
