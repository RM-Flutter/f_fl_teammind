import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/common_modules_widgets/custom_elevated_button.widget.dart';
import 'package:rmemp/common_modules_widgets/main_app_fab_widget/main_app_fab.service.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/restart_app.dart';
import 'package:rmemp/modules/fingerprint/views/widgets/finger_print_offline_card.dart';
import '../../../constants/app_sizes.dart';
import '../view_models/offline_viewmodel.dart';

class OfflineScreen extends StatefulWidget {
  const OfflineScreen({super.key});

  @override
  State<OfflineScreen> createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
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
        body: Consumer<OfflineViewModel>(
          builder: (context, viewModel, _) {
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
                        Text(AppStrings.youAreOffline.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),),
                        const SizedBox(height: 15,),
                        Text(AppStrings.pleaseConnectToTheInternetAndTryAgain.tr(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(AppColors.black)),),
                        const SizedBox(height: 25,),
                        CustomElevatedButton(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            titleSize: AppSizes.s12,
                            title: AppStrings.retry.tr().toUpperCase(),
                            onPressed: () async{
                              RestartWidget.restartApp(context);
                            }
                        ),
                        const SizedBox(height: 40,),
                        Text(AppStrings.fingerprint.tr().toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(AppColors.dark)),),
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
                                switch (viewModel.usersFingerprints[index]) {
                                  case 'fp_scan':
                                    icon = Icons.qr_code;
                                    function = () async{
                                      await MainFabServices.addFingerprintUsingQrCode(context: context);
                                    };
                                    hero = 'QR';
                                    break;
                                  case 'fp_wifi':
                                    icon = Icons.wifi;
                                    hero = 'wifi';
                                    function = ()async {
                                     await MainFabServices.addFingerprintUsingWiFi(context: context);
                                    };
                                    break;
                                  case 'fp_navigate' || 'custom_fp_navigate':
                                    icon = Icons.gps_fixed;
                                    function = () async{
                                      await MainFabServices.addFingerprintUsingGPS(context: context);
                                    };
                                    hero = 'gps';
                                    break;
                                  case 'fp_bluetooth':
                                    icon = Icons.bluetooth;
                                    function = ()async{
                                      await MainFabServices.addFingerprintUsingBluetooth(context: context);
                                    };
                                    hero = 'bluetooth';
                                    break;
                                  default:
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
                                  style: const TextStyle(
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
