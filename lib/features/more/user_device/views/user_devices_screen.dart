import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:app_test/core/widgets/custom_elevated_button.widget.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/features/more/user_device/controllers/user_device_controller.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/app_card.widget.dart';
import 'package:app_test/core/widgets/app_content_width.widget.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:app_test/core/utils/custom_shimmer_loading/app_shimmer_list.dart';

class UserDeviceScreen extends StatefulWidget {
  const UserDeviceScreen({super.key});

  @override
  State<UserDeviceScreen> createState() => _UserDeviceScreenState();
}

class _UserDeviceScreenState extends State<UserDeviceScreen> {
  final ScrollController _scrollController = ScrollController();
  int? selectIndex;
  var appConfigServiceProvider;
  @override
  void initState() {
    super.initState();
    appConfigServiceProvider =
        Provider.of<AppConfigService>(context, listen: false);
    final notificationProvider = Provider.of<DeviceControllerProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationProvider.getDevices(context: context); // Load initial notifications
    });
  }
  /// Names saved by older logins when the server couldn't tell what the device was
  /// ("Bilinmeyen Tarayıcı" is Turkish for "Unknown Browser").
  static bool _isUnknownLabel(String v) {
    final t = v.trim().toLowerCase();
    return t.isEmpty || t == 'null' || t.contains('bilinmeyen') || t.startsWith('unknown');
  }

  String _deviceTitle(Map device) {
    final browser = device['browser']?.toString() ?? '';
    if (!_isUnknownLabel(browser)) return browser;
    final os = device['os']?.toString() ?? '';
    if (!_isUnknownLabel(os)) return os;
    return AppStrings.unknownDevice.tr();
  }

  String _deviceSubtitle(Map device) {
    final v = device['os_version']?.toString() ?? '';
    return _isUnknownLabel(v) ? '' : v;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceControllerProvider>(
      builder: (context, value, child) {
        if(value.isDeleteSuccess == true){
          WidgetsBinding.instance.addPostFrameCallback((_) {
            value.getDevices(context: context);
          });
          value.isDeleteSuccess = false;
        }
        return Scaffold(
          backgroundColor: const Color(0xffFFFFFF),
          appBar: AppBarWithBookmark(
            title: AppStrings.userDevices.tr(),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: AppContentWidth(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  ListView.separated(
                    padding: EdgeInsets.zero,
                    clipBehavior: Clip.none,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.cardGap),
                    shrinkWrap: true,
                    reverse: false,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (value.isLoading) ? 5 : value.devices.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      if (value.isLoading) {
                        return const AppShimmerCard();
                      }
                      final device = value.devices[index];
                      final isLaptop = device['device_type'] == "PC/Laptop";
                      final isCurrent = appConfigServiceProvider
                              .deviceInformation.deviceUniqueId ==
                          device['unique_id'].toString();
                      final accentColor = isCurrent
                          ? const Color(0xFF2E7D32)
                          : Color(AppColors.buttons);
                      final subtitle = _deviceSubtitle(device);

                      return AppCard(animateIn: true, 
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppCardLeadingAvatar(
                              icon: isLaptop
                                  ? Icons.laptop_mac_rounded
                                  : Icons.phone_iphone_rounded,
                              borderColor: accentColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _deviceTitle(device),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.heading(context),
                                  ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyles.subtitleContent(context),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isCurrent)
                              AppStatusBadge(
                                label: AppStrings.currentDevice.tr(),
                                color: const Color(0xFF2E7D32),
                                icon: Icons.check_circle_outline,
                              ),
                            if (!isCurrent)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectIndex = index;
                                  });
                                  value.deleteDevices(
                                      context: context, deviceId: device['id']);
                                },
                                child: (value.isDeleteLoading == true &&
                                        selectIndex == index)
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.logout_rounded,
                                        color: Color(0xFFC62828), size: 20),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.s20),
                  Center(
                      child: (value.isDeleteLoading == false)
                          ? CustomElevatedButton(
                              titleSize: AppSizes.s14,
                              width: double.infinity,
                              backgroundColor: const Color(0xffFF0000),
                              title: AppStrings.logoutFromAllDevices.tr(),
                              onPressed: () async => await value.deleteDevices(
                                  context: context, deviceId: null))
                          : const CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
