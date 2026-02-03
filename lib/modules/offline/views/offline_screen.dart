import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/common_modules_widgets/main_app_fab_widget/main_app_fab.service.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/internet_check.dart';
import 'package:rmemp/constants/restart_app.dart';
import 'package:rmemp/general_services/offline_overlay.service.dart';
import 'package:rmemp/modules/fingerprint/views/widgets/finger_print_offline_card.dart';
import '../../../constants/app_sizes.dart';
import '../view_models/offline_viewmodel.dart';

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
            final viewModel = OfflineViewModel()..initialize(ctx: context);
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
        final viewModel = Provider.of<OfflineViewModel>(context, listen: false);
        viewModel.loadFingerprintsFromPreferences();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Consumer2<OfflineViewModel, ConnectionService>(
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
                  height: MediaQuery.sizeOf(context).height * 1,
                ),
                Stack(
                  children: [
                    // Background image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppSizes.s32),
                          bottomRight: Radius.circular(AppSizes.s32)),
                      child: Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(AppSizes.s32),
                              bottomRight: Radius.circular(AppSizes.s32)),
                        ),
                        child: Image.asset(
                          "assets/images/png/home_back.png",
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 300,
                        ),
                      ),
                    ),

                    // Linear gradient overlay
                    Container(
                      width: double.infinity,
                      height: 300,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(AppColors.dark)
                                .withOpacity(0.9), // Top - darker
                            Color(AppColors.dark)
                                .withOpacity(0.0), // Bottom - transparent
                          ],
                        ),
                      ),
                    ),

                    // Your content goes here, if any
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          topLeft: Radius.circular(15),
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/images/svg/wifi.svg",),
                        const SizedBox(height: 25,),
                        Text(AppStrings.youAreOffline.tr(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),),
                        const SizedBox(height: 15,),
                        Text(AppStrings.pleaseConnectToTheInternetAndTryAgain.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(AppColors.black)),),
                        const SizedBox(height: 25,),
                        Consumer<ConnectionService>(
                          builder: (context, connectionService, _) {
                            return CustomElevatedButton(
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                titleSize: AppSizes.s12,
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
                        const SizedBox(height: 40,),
                        Text(AppStrings.fingerprint.tr().toUpperCase(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),),
                        const SizedBox(height: 15,),
                        if (viewModel.usersFingerprints.isNotEmpty)
                          Container(
                            height: 50,
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
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: context,
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
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: context,
                                        fingerprintMethod: 'fp_wifi',
                                      );
                                    };
                                    break;
                                  case 'fp_navigate':
                                  case 'custom_fp_navigate':
                                    icon = Icons.gps_fixed;
                                    function = () async{
                                      debugPrint("👆 GPS fingerprint button pressed: $fingerprintType");
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: context,
                                        fingerprintMethod: fingerprintType,
                                      );
                                    };
                                    hero = 'gps';
                                    break;
                                  case 'fp_bluetooth':
                                    icon = Icons.bluetooth;
                                    function = ()async{
                                      debugPrint("👆 Bluetooth fingerprint button pressed");
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: context,
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
                        const SizedBox(height: 30,),
                        // Show saved fingerprints
                        if (viewModel.savedFingerprints != null && 
                            viewModel.savedFingerprints!.isNotEmpty)
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.fingerprintsTitle.tr(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(AppColors.dark),
                                  ),
                                ),
                                const SizedBox(height: 15,),
                                if (viewModel.isLoadingFingerprints)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                    child: FingerprintCardOffiline(
                                      fingerprint: viewModel.savedFingerprints,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
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
              backgroundColor: Color(AppColors.primary),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
}
