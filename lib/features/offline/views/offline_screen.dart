import 'dart:async';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.service.dart';
import 'package:app_test/features/offline/views/widgets/finger_print_offline_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/internet_check.dart';
import 'package:app_test/core/services/restart_app.dart';
import 'package:app_test/core/services/offline_overlay_service.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/features/offline/controller/offline_controller.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  Timer? _connectionCheckTimer;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    // Check connection status immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkConnection();
    });

    // Periodic check every 2 seconds as backup
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isNavigating && mounted) {
        _checkConnection();
      }
    });
  }

  void _checkConnection() {
    if (_isNavigating || !mounted) return;

    final connectionService = Provider.of<ConnectionService>(context, listen: false);
    connectionService.checkConnection().then((_) {
      if (connectionService.isConnected && mounted && !_isNavigating) {
        _isNavigating = true;
        // Connection restored, just close the overlay
        // The underlying screen will remain as is
        OfflineOverlayService.hideOfflineOverlay();
      }
    });
  }

  @override
  void dispose() {
    _connectionCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) {
          final viewModel = OfflineController()..initialize(ctx: context);
          // Reload fingerprints after provider is created
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              viewModel.loadFingerprintsFromPreferences();
            }
          });
          return viewModel;
        }),
      ],
      child: _OfflineScreenContent(),
    );
  }
}

class _OfflineScreenContent extends StatefulWidget {
  @override
  State<_OfflineScreenContent> createState() => _OfflineScreenContentState();
}

class _OfflineScreenContentState extends State<_OfflineScreenContent> {
  @override
  void initState() {
    super.initState();
    // Reload fingerprints when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = Provider.of<OfflineController>(context, listen: false);
        viewModel.loadFingerprintsFromPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<OfflineController, ConnectionService>(
        builder: (context, viewModel, connectionService, _) {
          // Listen to connection changes and close overlay automatically when connection is restored
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (connectionService.isConnected && mounted) {
              OfflineOverlayService.hideOfflineOverlay();
            }
          });
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 1.sh,
              ),
              Stack(
                children: [
                  // Background image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppSizes.s32.r),
                        bottomRight: Radius.circular(AppSizes.s32.r)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(AppSizes.s32.r),
                            bottomRight: Radius.circular(AppSizes.s32.r)),
                      ),
                      child: Image.asset(
                        "assets/images/png/home_back.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 300.h,
                      ),
                    ),
                  ),

                  // Linear gradient overlay
                  Container(
                    width: double.infinity,
                    height: 300.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(AppColors.secondaryButton)
                              .withOpacity(0.9), // Top - darker
                          Color(AppColors.secondaryButton)
                              .withOpacity(0.0), // Bottom - transparent
                        ],
                      ),
                    ),
                  ),

                  // Your content goes here, if any
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 200.h),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15.r),
                        topLeft: Radius.circular(15.r),
                      )),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/svg/wifi.svg",),
                        SizedBox(height: 25.h,),
                        Text(AppStrings.youAreOffline.tr(), style: AppStyles.heading(context).copyWith(fontSize: 18.sp, fontWeight: FontWeight.w700),),
                        SizedBox(height: 15.h,),
                        Text(AppStrings.pleaseConnectToTheInternetAndTryAgain.tr(), style: AppStyles.blackContent(context).copyWith(fontSize: 13.sp, fontWeight: FontWeight.w500),),
                        SizedBox(height: 25.h,),
                        Consumer<ConnectionService>(
                          builder: (context, connectionService, _) {
                            return CustomElevatedButton(
                                backgroundColor: Color(AppColors.secondaryButton),
                                titleSize: AppSizes.s12.sp,
                                title: AppStrings.retry.tr().toUpperCase(),
                                onPressed: () async {
                                  // Check connection immediately
                                  await connectionService.checkConnection();
                                  if (connectionService.isConnected && mounted) {
                                    // Connection restored, just close the overlay
                                    OfflineOverlayService.hideOfflineOverlay();
                                  } else {
                                    // Still offline, restart app
                                    RestartWidget.restartApp(context);
                                  }
                                }
                            );
                          },
                        ),
                        SizedBox(height: 40.h,),
                        if (viewModel.usersFingerprints.isNotEmpty) Text(AppStrings.fingerprint.tr().toUpperCase(), style: AppStyles.heading(context).copyWith(fontSize: 18.sp, fontWeight: FontWeight.w700),),
                        SizedBox(height: 15.h,),
                        if (viewModel.usersFingerprints.isNotEmpty)
                          SizedBox(
                            height: 60.h,
                            child: ListView.builder(
                              itemCount: viewModel.usersFingerprints.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                IconData icon;
                                Function()? function;
                                String hero;
                                final fingerprintType = viewModel.usersFingerprints[index];
                                debugPrint("🔍 Setting up fingerprint button: $fingerprintType");
                                switch (fingerprintType) {
                                  case 'fp_scan':
                                    icon = Icons.qr_code;
                                    function = () async{
                                      debugPrint("👆 QR Code fingerprint button pressed");
                                      OfflineOverlayService.hideOfflineOverlay();
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: 'fp_scan',
                                      );
                                    };
                                    hero = 'QR';
                                    break;
                                  case 'fp_wifi':
                                    icon = Icons.wifi;
                                    hero = 'wifi';
                                    function = ()async {
                                      debugPrint("👆 WiFi fingerprint button pressed");
                                      OfflineOverlayService.hideOfflineOverlay();
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: 'fp_wifi',
                                      );
                                    };
                                    break;
                                  case 'fp_navigate':
                                  case 'custom_fp_navigate':
                                    icon = Icons.gps_fixed;
                                    function = () async{
                                      debugPrint("👆 GPS fingerprint button pressed: $fingerprintType");
                                      OfflineOverlayService.hideOfflineOverlay();
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: fingerprintType,
                                      );
                                    };
                                    hero = 'gps';
                                    break;
                                  case 'fp_bluetooth':
                                    icon = Icons.bluetooth;
                                    function = ()async{
                                      debugPrint("👆 Bluetooth fingerprint button pressed");
                                      // لما نفتح بصمة أوفلاين، نشيل overlay ونستخدم سياق الـ root navigator
                                      OfflineOverlayService.hideOfflineOverlay();
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: 'fp_bluetooth',
                                      );
                                    };
                                    hero = 'bluetooth';
                                    break;
                                  default:
                                    debugPrint("⚠️ Unknown fingerprint type: $fingerprintType");
                                    return const SizedBox.shrink();
                                }

                                return _widget(
                                    icon: icon, onPress: function, hero: hero);
                              },
                            ),
                          ),
                        SizedBox(height: 30.h,),
                        // Show saved fingerprints
                        if (viewModel.savedFingerprints != null &&
                            viewModel.savedFingerprints!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.fingerprintsTitle.tr(),
                                  style: AppStyles.heading(context).copyWith(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 15.h,),
                                if (viewModel.isLoadingFingerprints)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: FingerprintCardOffiline(
                                      fingerprint: viewModel.savedFingerprints,
                                      onDelete: (index) async {
                                        await viewModel.deleteOfflineFingerprintAt(index);
                                      },
                                      deletingIndexes: viewModel.deletingOfflineIndexes,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),

    );
  }

  Widget _widget(
      {required IconData icon,
        Function()? onPress,
        required String hero}) =>
      Padding(
        padding: const EdgeInsets.all(AppSizes.s0),
        child: Row(
          children: [
            FloatingActionButton(
              heroTag: hero,
              onPressed: onPress,
              backgroundColor: Color(AppColors.buttons),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}
