import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:app_settings/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart'
as permission_handler;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:rmemp/common_modules_widgets/custom_alert_dialog_with_two_buttons.dart';
import 'package:rmemp/constants/app_constants.dart';

import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/constants/internet_check.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi_scan/wifi_scan.dart';
// import 'package:wifi_scan/wifi_scan.dart';
import '../../general_services/alert_service/alerts.service.dart';
import '../../general_services/image_file_picker.service.dart';
import '../../general_services/settings.service.dart';
import '../../models/settings/general_settings.model.dart';
import '../../services/fingerprint_service.dart';
import 'widgets/qrcode_Scanner_view.widget.dart';
import 'package:location/location.dart' as location_package;

abstract class MainFabServices {
  static IconData getFingerprintMethodIcon(
      {required String fingerprintMethod}) {
    switch (fingerprintMethod.toLowerCase().trim()) {
      case 'fp_scan':
        return Icons.qr_code;
      case 'fp_navigate' || 'custom_fp_navigate':
        return Icons.gps_fixed_rounded;
      case 'fp_wifi':
        return Icons.wifi;
      case 'fp_bluetooth':
        return Icons.bluetooth_connected;
      case 'fp_machine':
        return Icons.fingerprint;
      default:
        return Icons.fingerprint;
    }
  }

  static Future<void> getFingerprintActionMethodDependsOnFingerprintMethod(
      {required BuildContext context,
        required String fingerprintMethod}) async {
    print("FINGER IS ---> ${fingerprintMethod.toLowerCase().trim()}");
    switch (fingerprintMethod.toLowerCase().trim()) {
      case 'fp_scan':
        await addFingerprintUsingQrCode(context: context);
        return;
      case 'fp_navigate' || 'custom_fp_navigate':
        await addFingerprintUsingGPS(context: context);
      case 'fp_wifi':
        await addFingerprintUsingWiFi(context: context);
      case 'fp_bluetooth':
        await addFingerprintUsingBluetooth(context: context);
      case 'fp_nfc':
        await addFingerprintUsingNFC(context: context);
      case 'fp_machine':
      default:
        AlertsService.error(
            context: context,
            message: AppStrings.failed.tr(),
            title: AppStrings.failed.tr());
    }
  }

 static Future<List<Map<String, dynamic>>> convertFilesAndProcess(List<FilePickerResult> files) async {
    List<Map<String, dynamic>> processedFiles = [];

    // Check if the files list is not empty
    if (files.isNotEmpty) {
      for (var file in files) {
        // Loop over the files in each FilePickerResult
        for (var fileItem in file.files) {
          // Ensure the file has valid bytes
          if (fileItem.bytes != null) {
            // Lookup the MIME type based on the file's name
            String mimeType = lookupMimeType(fileItem.name) ?? 'application/octet-stream';

            // Create a MultipartFile from the file's bytes
            var multipartFile = MultipartFile.fromBytes(
              fileItem.bytes!, // File bytes
              filename: fileItem.name, // File name
              contentType: MediaType.parse(mimeType), // Mime type
            );

            // Add the file metadata to the processedFiles list
            processedFiles.add({
              'fileName': fileItem.name,
              'path': fileItem.path,
              'bytes': base64Encode(fileItem.bytes!), // Convert bytes to base64 for storage
            });

            print("Processed file: ${fileItem.name}, MIME Type: $mimeType");
          }
        }
      }
    } else {
      print("No files selected or files are empty.");
    }

    // Return the list of processed files for caching
    return processedFiles;
  }

  // Cache the fingerprint locally if no internet connection
  static Future<void> _cacheFingerprint({required String data, required String type, List<FilePickerResult>? file}) async {
    // Initialize the list if it is null
    if (AppConstants.fingerPrints == null) {
      AppConstants.fingerPrints = [];
    }
    final fingerprintEntry = {
      'type': type,
      'data': data,
      'finger_day': DateFormat('yyyy-MM-dd HH:mm:ss' , "en").format(DateTime.now()),
    };

    // Handle file serialization
    if (file != null && file.isNotEmpty) {
      final List<Map<String, dynamic>> serializedFiless = [];

      for (var fileResult in file) {
        for (var platformFile in fileResult.files) {
          serializedFiless.add({
            'fileName': platformFile.name,
            'path': platformFile.path,
            'bytes': platformFile.bytes != null ? base64Encode(platformFile.bytes!) : null,
          });
        }
      }

      // Add the serialized files under the 'types' key
      fingerprintEntry['files'] = jsonEncode(serializedFiless);
    }

    // Now save all fingerprint entries under the "types" key
    AppConstants.fingerPrints!.add(fingerprintEntry);

    // Store the list under a single key 'types'
    final Map<String, dynamic> dataToSave = {'fingerprints': AppConstants.fingerPrints};

    // Assuming you have a method to save data in shared preferences
    await _saveFingerprintsToPreferences();

    Fluttertoast.showToast(
        msg: AppStrings.saveSucessFull.tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
    print("Cached fingerprints under 'types': ${AppConstants.fingerPrints}");
  }

// Method to save fingerprints to shared preferences
//   static Future<void> _saveFingerprintsToPreferences(Map<String, dynamic> data) async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Saving under 'types' key
//     await prefs.setString('types', jsonEncode(data));
//   }

  static Map<String, dynamic> filePickerResultToCacheableMap(FilePickerResult result) {
    final file = result.files.first;
    return {
      'fileName': file.name,
      'path': file.path,
      'bytes': file.bytes != null ? base64Encode(file.bytes!) : null,
    };
  }
  // Save the list of fingerprints to shared preferences
  static Future<void> _saveFingerprintsToPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the list of fingerprints to a JSON string
    final String jsonString = jsonEncode(AppConstants.fingerPrints);

    // Save the JSON string in shared preferences
    await prefs.setString('fingerPrints', jsonString);
    print("Fingerprints saved to preferences!");
  }
  // Adding Fingerprint using NFC
  static Future<void> addFingerprintUsingNFC(
      {required BuildContext context}) async {
    try {
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      FilePickerResult? empPhoto;
      if (fingerprintMustUploadImage == true) {
        empPhoto = await FileAndImagePickerService.pickImageWithFilePicker();
      }
      if (fingerprintMustUploadImage == true &&
          (empPhoto == null || empPhoto.files.first.bytes == null)) {
        AlertsService.error(
            context: context,
            message: 'Please Take Photo Before Adding Fingerprint',
            title: 'Photo Required!');
        return;
      }
      // Check if the device supports NFC
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        AlertsService.error(
            context: context,
            message: 'NFC is not supported or enabled on this device!',
            title: AppStrings.failed.tr());
        return;
      }
      AlertsService.info(
          context: context,
          message: 'Please attach the device to the NFC chip',
          title: 'NFC');
      // Start NFC session
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Extract the UID, card content, and tag type
          String uid = tag.data['id']?.toString() ?? '0';
          String cardContent =
              '0'; // Placeholder, customize as per your card type
          String tagType = tag.data['type']?.toString() ?? '0';

          // Combine the UID, card content, and tag type
          String nfcData = '$uid-$cardContent-$tagType';

          // Stop the session
          NfcManager.instance.stopSession();

          // Send the combined data to the server
          final result = await FingerprintService.addNFCFingerprint(
              context: context,
              data: nfcData,
              files: empPhoto != null ? [empPhoto] : []);

          // Handle the server response
          if (result.success) {
            AlertsService.success(
                context: context,
                message: result.message!,
                title: AppStrings.success.tr());
            return;
          } else {
            AlertsService.error(
                context: context,
                message: result.message!,
                title: AppStrings.failed.tr());
            return;
          }
        },
        onError: (NfcError error) {
          AlertsService.error(
              context: context,
              message: 'Error during NFC session: ${error.message}',
              title: AppStrings.failed.tr());
          return NfcManager.instance.stopSession();
        },
      );
    } catch (e) {
      debugPrint('Error Adding NFC Fingerprint: $e');
      AlertsService.error(
          context: context,
          message: 'Error Happened! Please try later!',
          title: AppStrings.failed.tr());
      return;
    }
  }

  static Future<void> addFingerprintUsingBluetooth({required BuildContext context,}) async {
    try {
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;

      List<FilePickerResult> convertMapListToFilePickerResults(List<Map<String, dynamic>> imageMaps) {
        return imageMaps.map((imageData) {
          final path = imageData["image"] as String?;
          final name = imageData["fileName"] as String?;

          if (path != null && name != null) {
            final file = File(path);

            final platformFile = PlatformFile(
              path: path,
              name: name,
              size: file.lengthSync(),
              bytes: file.readAsBytesSync(),
            );

            return FilePickerResult([platformFile]);
          } else {
            throw Exception("Invalid image data format.");
          }
        }).toList();
      }
      var empPhoto;
      empPhoto = await FileAndImagePickerService.pickImage(
          type: "camera",
          cameraDevice: "rear",
          quality: 70
      );
      if(empPhoto == null){
        AlertsService.warning(
            context: context,
            message: AppStrings.pleaseTakePhotoBeforeAddingFingerprint.tr(),
            title: AppStrings.warning.tr());
        return;
      }

      // Uncomment this if photo upload is mandatory
      // if (fingerprintMustUploadImage == true) {
      //   empPhoto = await FileAndImagePickerService.pickImageWithFilePicker();
      //   if (empPhoto == null || empPhoto.files.first.bytes == null) {
      //     AlertsService.error(
      //       context: context,
      //       message: 'Please Take Photo Before Adding Fingerprint',
      //       title: 'Photo Required!',
      //     );
      //     return;
      //   }
      // }

      // Request necessary permissions (Android only)
      if (Platform.isAndroid) {
        var scanStatus = await Permission.bluetoothScan.status;
        var connectStatus = await Permission.bluetoothConnect.status;
        var locationStatus = await Permission.locationWhenInUse.status;

        if (!scanStatus.isGranted) await Permission.bluetoothScan.request();
        if (!connectStatus.isGranted) await Permission.bluetoothConnect.request();
        if (!locationStatus.isGranted) await Permission.locationWhenInUse.request();
      }

      // ✅ Check if Bluetooth is enabled
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      BluetoothAdapterState adapterState = await FlutterBluePlus.adapterState.first;
      Navigator.of(context, rootNavigator: true).pop();
      if (adapterState != BluetoothAdapterState.on) {
        AlertsService.info(
          context: context,
          message: AppStrings.bluetoothIsOffPleaseEnableItToContinue.tr(),
          title: AppStrings.bluetoothRequired.tr(),
        );

        // Optionally: open Bluetooth settings
        // await AppSettings.openBluetoothSettings();

        // Wait for user to enable Bluetooth (max 15 seconds)
        BluetoothAdapterState newState;
        try {
          newState = await FlutterBluePlus.adapterState
              .where((state) => state == BluetoothAdapterState.on)
              .first
              .timeout(const Duration(seconds: 15));
        } catch (_) {
          newState = BluetoothAdapterState.off;
        }

        if (newState != BluetoothAdapterState.on) {
          AlertsService.error(
            context: context,
            message: AppStrings.bluetoothWasNotEnabledInTime.tr(),
            title: AppStrings.cannotProceed.tr(),
          );
          return;
        }
      }

      // ✅ Start scanning for Bluetooth devices
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 25));

      // Show scanned devices

      final selectedDevice = await showModalBottomSheet<ScanResult>(
        context: context,
        builder: (context) {
          return StreamBuilder<List<ScanResult>>(
            stream: FlutterBluePlus.scanResults,
            builder: (context, snapshot) {
              final results = snapshot.data?.where((r) => r.device.name.isNotEmpty).toList() ?? [];

              if (results.isEmpty) {
                return  Center(child: Text('${AppStrings.scanningForDevices.tr()}'));
              }
              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  return ListTile(
                    title: Text(
                      result.device.name.isEmpty ? AppStrings.unknownDevice.tr() : result.device.name,
                      style: const TextStyle(color: Colors.black),
                    ),
                    onTap: ()async{
                      await FlutterBluePlus.stopScan();
                      Navigator.pop(context, result);
                    },
                  );
                },
              );
            },
          );
        },
      );

      if (selectedDevice == null) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
      Navigator.of(context, rootNavigator: true).pop();
      var result;
      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            if (isConnected) {
              result = await FingerprintService.addBluetoothFingerprint(
                context: context,
                data: selectedDevice.device.remoteId.toString(),
                files: empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : [],
              );
            }
            else {
              var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en").format(DateTime.now());
              final encodedData = base64Encode(
                utf8.encode("${selectedDevice.device.remoteId}_$date"),
              );

              if (empPhoto != null) {
                await _cacheFingerprint(
                  data: encodedData,
                  type: "fp_bluetooth",
                  file: empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : [],
                );
              } else {
                await _cacheFingerprint(
                  data: encodedData,
                  type: "fp_bluetooth",
                );
              }
              return;
            }

            // ✅ Show result
            if (result != null && result.success) {
              AlertsService.success(
                context: context,
                message: result.message!,
                title: AppStrings.success.tr(),
              );
            } else {
              AlertsService.error(
                context: context,
                message: result.message ?? 'Unknown error',
                title: AppStrings.failed.tr(),
              );
            }
          }
      );
    } catch (e) {
      debugPrint('Error Adding Bluetooth Fingerprint: $e');
      AlertsService.error(
        context: context,
        message:  AppStrings.noInternetConnection.tr(),
        title: AppStrings.failed.tr(),
      );
    }
  }

  static Future<bool> isWiFiEnabled() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult == ConnectivityResult.wifi;
  }
  // Adding Fingerprint Using Wifi
  static Future<void> addFingerprintUsingWiFi({
    required BuildContext context,
  }) async {
    try {
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
              settingsType: SettingsType.generalSettings,
              context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      final status = await WiFiScan.instance.canStartScan();
      if (status != CanStartScan.yes) {
        AlertsService.warning(
          context: context,
          message: AppStrings.pleaseEnableWifiFirst.tr(),
          title: AppStrings.warning.tr(),
        );
        AppSettings.openAppSettings(type: AppSettingsType.wifi);
        return;
      }
      List<FilePickerResult> convertMapListToFilePickerResults(List<Map<String, dynamic>> imageMaps) {
        return imageMaps.map((imageData) {
          final path = imageData["image"] as String?;
          final name = imageData["fileName"] as String?;

          if (path != null && name != null) {
            final file = File(path);

            final platformFile = PlatformFile(
              path: path,
              name: name,
              size: file.lengthSync(),
              bytes: file.readAsBytesSync(),
            );

            return FilePickerResult([platformFile]);
          } else {
            throw Exception("Invalid image data format.");
          }
        }).toList();
      }
      var empPhoto;
      // if (fingerprintMustUploadImage == true) {
      empPhoto = await FileAndImagePickerService.pickImage(
          type: "camera",
          cameraDevice: "rear",
          quality: 70
      );
      if(empPhoto == null){
        AlertsService.warning(
            context: context,
            message: AppStrings.pleaseTakePhotoBeforeAddingFingerprint.tr(),
            title: AppStrings.warning.tr());
        return;
      }
      // Check for Wi-Fi scan permissions

      // Start scanning for Wi-Fi networks
      await WiFiScan.instance.startScan();

      // Get the list of Wi-Fi networks
      final List<WiFiAccessPoint> wifiNetworks =
          await WiFiScan.instance.getScannedResults();

      if (wifiNetworks.isEmpty) {
        AlertsService.warning(
          context: context,
          message: AppStrings.noWiFiNetworksFound.tr(),
          title: AppStrings.warning.tr(),
        );
        return;
      }

      // Show available Wi-Fi networks in a popup or sheet
      final List<WiFiAccessPoint> filteredNetworks = wifiNetworks
          .where((net) => net.ssid != null && net.ssid.trim().isNotEmpty)
          .toList();
      final selectedNetwork = await showModalBottomSheet<WiFiAccessPoint>(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: filteredNetworks.length,
            itemBuilder: (context, index) {
              final network = filteredNetworks[index];
              return ListTile(
                title: Text(network.ssid != null && network.ssid.toString().isNotEmpty ? network.ssid : AppStrings.unknownDevice.tr()),
                onTap: () => Navigator.pop(context, network),
              );
            },
          );
        },
      );

      if (selectedNetwork == null) return;

      // Prepare the data to send to the server
      final wifiData = {'mac_address': selectedNetwork.bssid};
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
      Navigator.of(context, rootNavigator: true).pop();
      print("isConnected --> ${isConnected}");
      var result;
      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            if(isConnected){
              result = await FingerprintService.addWifiFingerprint(
                  context: context,
                  data: selectedNetwork.bssid.toString(),
                  files:  empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : []);
            }
            else{
              var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en").format(DateTime.now());
              print("[empPhoto] ${[empPhoto]}");
              await _cacheFingerprint(
                  data: base64Encode(utf8.encode("${selectedNetwork.bssid.toString()}_$date")),
                  type: "fp_wifi",
                  file: empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : []
              );
              return;
              // var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en").format(DateTime.now());
              // await _cacheFingerprint(data: base64Encode(utf8.encode("${selectedNetwork.bssid.toString()}_$date")),
              //     type: "fp_wifi", file: empPhoto != null ? [empPhoto] : []);
            }

            // Handle the server response
            if (result != null && result.success) {
              AlertsService.success(
                context: context,
                message: result.data['message'],
                title: AppStrings.success.tr(),
              );
              return;
            }
            else {
              AlertsService.error(
                context: context,
                message: result.data['message'] ?? AppStrings.noInternetConnection.tr(),
                title: AppStrings.failed.tr(),
              );
              return;
            }
          }
      );

    } catch (e) {
      debugPrint('Error Adding Wi-Fi Fingerprint: $e');
      AlertsService.error(
        context: context,
        message: AppStrings.noInternetConnection.tr(),
        title: AppStrings.failed.tr(),
      );
      return;
    }
  }
 static double? lat;
  static double? long;

  static Future<void> getCurrentLocation(context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // تأكد إن خدمة الموقع مفعلة
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('❌ خدمة الموقع غير مفعلة');
      return;
    }

    // تحقق من الصلاحيات
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('❌ صلاحيات الموقع مرفوضة');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('❌ الصلاحيات مرفوضة دائمًا');
      return;
    }

    try {
      // الحصول على الإحداثيات بدون إنترنت
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // استخدم low علشان النت مش شغال
      );

      double lat = position.latitude;
      double long = position.longitude;
      print('📍 Latitude: $lat, Longitude: $long');
      CacheHelper.setString(key: "lat", value: lat.toString());
      CacheHelper.setString(key: "long", value: long.toString());
    } catch (e) {
      print('❌ حصل خطأ أثناء تحديد الموقع: $e');
    }
  }
  // Add Fingerprint Using GPS
  static Future<void> addFingerprintUsingGPS({
    required BuildContext context,
  }) async {
    try {
      print("HEY1");
      await getCurrentLocation(context);
      print("HEY2");
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      List<FilePickerResult> convertMapListToFilePickerResults(List<Map<String, dynamic>> imageMaps) {
        return imageMaps.map((imageData) {
          final path = imageData["image"] as String?;
          final name = imageData["fileName"] as String?;

          if (path != null && name != null) {
            final file = File(path);

            final platformFile = PlatformFile(
              path: path,
              name: name,
              size: file.lengthSync(),
              bytes: file.readAsBytesSync(),
            );

            return FilePickerResult([platformFile]);
          } else {
            throw Exception("Invalid image data format.");
          }
        }).toList();
      }
      var empPhoto;
      // if (fingerprintMustUploadImage == true) {
      empPhoto = await FileAndImagePickerService.pickImage(
          type: "camera",
          cameraDevice: "rear",
          quality: 70
      );
      if(empPhoto == null){
        AlertsService.warning(
            context: context,
            message: AppStrings.pleaseTakePhotoBeforeAddingFingerprint.tr(),
            title: AppStrings.warning.tr());
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
      Navigator.of(context, rootNavigator: true).pop();
      print("isConnected --> ${isConnected}");
      var result;
      customAlertDialogWithTwoButtons(
          context,
          title: AppStrings.fingerprint.tr(),
          content: AppStrings.doYouWantToAddThisFingerprint.tr(),
          actionRightText: AppStrings.yes.tr(),
          actionLeftText: AppStrings.no.tr(),
          onLeftActionPressed: (){
            Navigator.pop(context);
          },
          onRightActionPressed: ()async{
            if(isConnected){
              result = await FingerprintService.addGPSFingerprint(
                  context: context,
                  type: 'fp_navigate',
                  lat: double.parse(CacheHelper.getString('lat')) ?? 0,
                  long: double.parse(CacheHelper.getString('long')) ?? 0,
                  files: empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : []);
            }
            else{
              print("lat is ${CacheHelper.getString('lat')}");

              await _cacheFingerprint(
                  data: '{"lat":${CacheHelper.getString('lat')},"long":${CacheHelper.getString('long')}}',
                  type: "fp_navigate",
                  file:empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : []
              );
              return;
              // List<Map<String, dynamic>>? serializableFiles;
              // serializableFiles = empPhoto!.files.map((file) {
              //   return {
              //     'name': file.name,
              //     'bytes': file.bytes != null ? base64Encode(file.bytes!) : null,
              //     'path': file.path,
              //   };
              // }).toList();
              //  await _cacheFingerprint(data: '{"lat":${lat.toString()},"long":${long.toString()}}',
              //      type: "fp_navigate", file: serializableFiles);
            }
            print("GPS DONE TWO");
            // Handle the server response
            if (result != null && result.data!['status'] == true) {
              AlertsService.success(
                  context: context,
                  message: result.data!['message'],
                  title: AppStrings.success.tr());
              return;
            }
            else {
              AlertsService.error(
                  context: context,
                  message: result.data!['message'],
                  title: AppStrings.failed.tr());
              return;
            }
          }
      );

    } catch (e) {
      debugPrint('Error Adding GPS Fingerprint: $e');
      AlertsService.error(
          context: context,
          message: AppStrings.noInternetConnection.tr(),
          title: AppStrings.failed.tr());
      return;
    }
  }

  // Add Fingerprint Using QrCode
  static Future<void> addFingerprintUsingQrCode(
      {required BuildContext context}) async {
    try {
      final bool? fingerprintMustUploadImage = (AppSettingsService.getSettings(
          settingsType: SettingsType.generalSettings,
          context: context) as GeneralSettingsModel)
          .fingerprintMustUploadImage;
      List<FilePickerResult> convertMapListToFilePickerResults(List<Map<String, dynamic>> imageMaps) {
        return imageMaps.map((imageData) {
          final path = imageData["image"] as String?;
          final name = imageData["fileName"] as String?;

          if (path != null && name != null) {
            final file = File(path);

            final platformFile = PlatformFile(
              path: path,
              name: name,
              size: file.lengthSync(),
              bytes: file.readAsBytesSync(),
            );

            return FilePickerResult([platformFile]);
          } else {
            throw Exception("Invalid image data format.");
          }
        }).toList();
      }
      final String? scanedQrCode =
      await _scanQrcodeToGetSecretKeyString(context: context);
      var empPhoto;
      // if (fingerprintMustUploadImage == true) {
      empPhoto = await FileAndImagePickerService.pickImage(
        type: "camera",
        cameraDevice: "rear",
        quality: 70
      );

      // if (fingerprintMustUploadImage == true &&
      //     (empPhoto == null || empPhoto.files.first.bytes == null)) {
      if (false) {
        AlertsService.error(
            context: context,
            message: 'Please Take Photo Before Adding Fingerprint',
            title: 'Photo Required!');
        return;
      }

      print("DONE FROM ONE");
      if (scanedQrCode == null || scanedQrCode.isEmpty) return;
      // Call Your Fingerprint Scanner API
      print("DONE FROM ONE");
      print("DONE FROM ONE");
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      final bool isConnected = await InternetConnectionChecker.createInstance().hasConnection;
      Navigator.of(context, rootNavigator: true).pop();
      print("isConnected --> ${isConnected}");
      var result;
      if(empPhoto == null){
        AlertsService.warning(
            context: context,
            message: AppStrings.pleaseTakePhotoBeforeAddingFingerprint.tr(),
            title: AppStrings.warning.tr());
        return;
      }
      customAlertDialogWithTwoButtons(
        context,
        title: AppStrings.fingerprint.tr(),
        content: AppStrings.doYouWantToAddThisFingerprint.tr(),
        actionRightText: AppStrings.yes.tr(),
        actionLeftText: AppStrings.no.tr(),
        onLeftActionPressed: (){
          Navigator.pop(context);
        },
        onRightActionPressed: ()async{
          if(isConnected){
            result = await FingerprintService.addQRCodeFingerprint(
                context: context,
                data: scanedQrCode,
                files: empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : []);
          }
          else{
            var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en").format(DateTime.now());
            await _cacheFingerprint(
            data: base64Encode(utf8.encode("${scanedQrCode}_$date")),
            type: "fp_scan",
            file: empPhoto != null ?convertMapListToFilePickerResults([empPhoto]) : [],
            );
            print("Fingerprint cached offline.");
            return;
            // var date = DateFormat('yyyy-MM-dd HH:mm:ss', "en").format(DateTime.now());
            // List<Map<String, dynamic>>? serializableFiles;
            //
            // if (empPhoto != null && empPhoto is Map<String, dynamic>) {
            //   serializableFiles = [
            //     {
            //       'image': empPhoto['image'],
            //       'fileName': empPhoto['fileName'],
            //     }
            //   ];
            // }
            //
            // await _cacheFingerprint(
            //     data: base64Encode(utf8.encode("${scanedQrCode}_$date")),
            //     type: "fp_scan",
            //     file: serializableFiles
            // );
            // await _cacheFingerprint(data: base64Encode(utf8.encode("${scanedQrCode}_$date")),
            //     type: "fp_scan", file: empPhoto != null ? convertMapListToFilePickerResults([empPhoto]) : []);
          }
          print("result.data!['status'] --> ${result.data!['status'] }");
          if (result!= null &&result.data!['status'] == true) {
            AlertsService.success(
                context: context,
                message: result.data!['message'],
                title: AppStrings.success.tr());
            return;
          }
          else {
            AlertsService.error(
                context: context,
                message: result.data!['message'],
                title: AppStrings.failed.tr());
            return;
          }
        }
      );

    } catch (e) {
      debugPrint(
          'Error Happeded While Adding Fingerprint Using Qrcode! Error :-> $e');
      AlertsService.error(
          context: context,
          message: AppStrings.noInternetConnection.tr(),
          title: AppStrings.failed.tr());
    }
  }

  static Future<String?> _scanQrcodeToGetSecretKeyString(
      {required BuildContext context}) async {
    try {
      // Request camera permission
      var cameraStatus = await permission_handler.Permission.camera.request();
      if (!cameraStatus.isGranted) {
        AlertsService.warning(
            context: context,
            message: 'Camera permission is required to scan QR codes',
            title: AppStrings.warning.tr());
        return null;
      }

      // Initialize a GlobalKey for the QRView widget
      final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
      // Use a Navigator to push a full-screen scanner widget
      final result = await Navigator.push<String?>(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScannerView(),
        ),
      );
      // If scanning was successful, return the scanned text
      return result;
    } catch (e) {
      // Handle any errors, return null in case of an error
      debugPrint('Error scanning QR code: $e');
      AlertsService.error(
          context: context,
          message: 'Error Happeded! Please try later!',
          title: AppStrings.failed.tr());
      return null;
    }
  }
}
