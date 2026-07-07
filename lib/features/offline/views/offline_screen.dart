import 'dart:async';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/main_app_fab_widget/main_app_fab.service.dart';
import 'package:app_test/features/offline/views/widgets/finger_print_offline_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/services/internet_check.dart';
import 'package:app_test/core/services/offline_overlay_service.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/features/offline/controller/offline_controller.dart';
import 'package:go_router/go_router.dart';

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
                height: MediaQuery.of(context).size.height,
              ),
              Stack(
                children: [
                  // Background image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(AppSizes.s32),
                        bottomRight: Radius.circular(AppSizes.s32)),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(AppSizes.s32),
                            bottomRight: Radius.circular(AppSizes.s32)),
                      ),
                      child: Image.asset(
                        "assets/images/png/home_back.png",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 220,
                      ),
                    ),
                  ),

                  // Linear gradient overlay
                  Container(
                    width: double.infinity,
                    height: 220,
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                        topLeft: Radius.circular(16),
                      )),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/svg/wifi.svg"),
                        const SizedBox(height: 24),
                        Text(
                          AppStrings.youAreOffline.tr(),
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.pleaseConnectToTheInternetAndTryAgain.tr(),
                          style: AppStyles.blackContent(context).copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<ConnectionService>(
                          builder: (context, connectionService, _) {
                            return CustomElevatedButton(
                                backgroundColor: Color(AppColors.secondaryButton),
                                titleSize: AppSizes.s12,
                                title: AppStrings.retry.tr().toUpperCase(),
                                onPressed: () async {
                                  // Perform real connectivity check
                                  await connectionService.checkConnection();
                                  if (!mounted) return;
                                  if (connectionService.isConnected) {
                                    // Case 1: screen shown via overlay (dynamic offline)
                                    if (OfflineOverlayService.isShowing) {
                                      OfflineOverlayService.hideOfflineOverlay();
                                    } else {
                                      // Case 2: screen shown via GoRouter navigation (startup offline)
                                      // Navigate back to splash so it re-initializes and goes to home
                                      final lang = context.locale.languageCode;
                                      context.goNamed(
                                        AppRoutes.splash.name,
                                        pathParameters: {'lang': lang},
                                      );
                                    }
                                  } else {
                                    // Still offline — inform user
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppStrings.pleaseConnectToTheInternetAndTryAgain.tr(),
                                          textAlign: TextAlign.center,
                                        ),
                                        backgroundColor: Colors.red,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        if (viewModel.usersFingerprints.isNotEmpty)
                          Text(
                            AppStrings.fingerprint.tr().toUpperCase(),
                            style: AppStyles.heading(context).copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 12),
                        if (viewModel.usersFingerprints.isNotEmpty)
                          SizedBox(
                            height: 60,
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
                                    function = () async {
                                      debugPrint("👆 QR Code fingerprint button pressed");
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: 'fp_scan',
                                      );
                                      await viewModel.loadFingerprintsFromPreferences();
                                    };
                                    hero = 'QR';
                                    break;
                                  case 'fp_wifi':
                                    icon = Icons.wifi;
                                    hero = 'wifi';
                                    function = () async {
                                      debugPrint("👆 WiFi fingerprint button pressed");
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: 'fp_wifi',
                                      );
                                      await viewModel.loadFingerprintsFromPreferences();
                                    };
                                    break;
                                  case 'fp_navigate':
                                  case 'custom_fp_navigate':
                                    icon = Icons.gps_fixed;
                                    function = () async {
                                      debugPrint("👆 GPS fingerprint button pressed: $fingerprintType");
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: fingerprintType,
                                      );
                                      await viewModel.loadFingerprintsFromPreferences();
                                    };
                                    hero = 'gps';
                                    break;
                                  case 'fp_bluetooth':
                                    icon = Icons.bluetooth;
                                    function = () async {
                                      debugPrint("👆 Bluetooth fingerprint button pressed");
                                      final navContext = rootNavigatorKey.currentContext ?? context;
                                      await MainFabServices.getFingerprintActionMethodDependsOnFingerprintMethod(
                                        context: navContext,
                                        fingerprintMethod: 'fp_bluetooth',
                                      );
                                      await viewModel.loadFingerprintsFromPreferences();
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
                        const SizedBox(height: 24),
                        // Show saved fingerprints
                        if (viewModel.savedFingerprints != null &&
                            viewModel.savedFingerprints!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.fingerprintsTitle.tr(),
                                  style: AppStyles.heading(context).copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                 if (viewModel.isLoadingFingerprints)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: FloatingActionButton(
          heroTag: hero,
          onPressed: onPress,
          backgroundColor: Color(AppColors.buttons),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      );
}
