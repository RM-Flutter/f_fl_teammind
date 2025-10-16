import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../../../general_services/app_config.service.dart';
import '../../../general_services/location.service.dart';
import '../../../general_services/settings.service.dart';
import '../../../routing/app_router.dart';

class OfflineViewModel with ChangeNotifier {
  final List<String> _usersFingerprints = [];

  List<String> get usersFingerprints => _usersFingerprints;

  void initialize({required BuildContext ctx}) async {
    final appConfigServiceProvider =
    Provider.of<AppConfigService>(ctx, listen: false);

    final settings =
    appConfigServiceProvider.getSettings(type: SettingsType.userSettings);

    final fingerprints = settings?.toJson()['av_fingerprint'];

    if (fingerprints != null && fingerprints is Map) {
      fingerprints.forEach((key, value) {
        if (value == 'active_all' || value == 'active_some') {
          _usersFingerprints.add(key);
          print("_usersFingerprints --> $_usersFingerprints");
        }
      });
    } else {
      print("⚠️ fingerprints is null or not a Map");
    }

    // ConnectionsService.connectionStream.listen((result) {
    //   if (result.contains(ConnectivityResult.none)) {
    //     Navigator.pop(ctx);
    //   }
    // });
  }


  qrCode({required BuildContext ctx}) =>
      ctx.goNamed(AppRoutes.qrcodeScreen.name);

  Future<LocationData?> gps() async {
    return LocationService.getLocation();
  }
}
