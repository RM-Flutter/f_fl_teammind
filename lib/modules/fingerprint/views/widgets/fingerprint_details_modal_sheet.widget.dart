import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:geocoding/geocoding.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import '../../../../constants/app_images.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../general_services/layout.service.dart';
import '../../../../models/fingerprint.model.dart';

class FingerprintDetailsModalSheet extends StatelessWidget {
  final FingerPrintModel fingerprint;
  const FingerprintDetailsModalSheet({super.key, required this.fingerprint});

  @override
  Widget build(BuildContext context) {
    String? formatDateString(String? dateString) {
      if (dateString == null) return null;
      // Parse the string into a DateTime object
      DateTime dateTime = DateFormat('yyyy-MM-dd',"en").parse(dateString);

      // Format the DateTime object into the desired format
      String formattedDate = DateFormat('EEEE, dd MMM yyyy', LocalizationService.isArabic(context: context) ? "ar" : "en").format(dateTime);

      return formattedDate;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       // gapH20,
        if (formatDateString(fingerprint.fingerDay) != null) ...[
          gapH12,
          Container(
            padding: const EdgeInsets.all(AppSizes.s12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.s10),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Center(
              child: Text(
                formatDateString(fingerprint.fingerDay) ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: AppSizes.s14),
              ),
            ),
          ),
        ],
        gapH12,
        if (fingerprint.fingerDateTime != null &&
            fingerprint.fingerDateTime?.isNotEmpty == true)
          ...fingerprint.fingerDateTime!
              .map((fingerprintDatetime) => FingerprintDatetimeCardWidget(
            fingerprintDatetime: fingerprintDatetime,
            isIn: (fingerprint.fingerDateTime
                ?.indexOf(fingerprintDatetime) ??
                0) %
                2 ==
                0,
          ))
      ],
    );
  }
}

class FingerprintDatetimeCardWidget extends StatefulWidget {
  final FingerDateTime fingerprintDatetime;
  final bool? isIn;

  const FingerprintDatetimeCardWidget({
    super.key,
    required this.fingerprintDatetime,
    this.isIn = true,
  });

  @override
  State<FingerprintDatetimeCardWidget> createState() =>
      _FingerprintDatetimeCardWidgetState();
}

class _FingerprintDatetimeCardWidgetState
    extends State<FingerprintDatetimeCardWidget> {
  String? branchName;

  @override
  void initState() {
    super.initState();
    loadBranchName();
  }

  Future<void> loadBranchName() async {
    final branch = widget.fingerprintDatetime.branchId;
    if (branch != null && branch.contains("lat")) {
      final decoded = jsonDecode(branch);
      final lat = decoded["lat"];
      final lng = decoded["long"];
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        setState(() {
          branchName = [
            place.street,
            place.subLocality,
            place.locality,
            place.administrativeArea,
            place.country
          ].where((e) => e != null && e!.trim().isNotEmpty).join(', ');
        });
      }
    } else {
      setState(() {
        branchName = branch;
      });
    }
  }

  String getFingerprintImageDependsOnType(String fingerprintType) {
    switch (fingerprintType.trim().toLowerCase()) {
      case 'fp_machine':
        return AppImages.fingetprintFloatingActionButtonIcon;
      case 'fp_scan':
        return AppImages.fingerprintQrcode;
      case 'fp_navigate':
        return AppImages.fingerprintGps;
      case 'custom_fp_navigate':
        return AppImages.fingerprintGps;
      case 'fp_bluetooth':
        return AppImages.fingerprintBlutooth;
        case 'fp_wifi':
        return "assets/images/png/wifi_online.png";
      default:
        return AppImages.fingetprintFloatingActionButtonIcon;
    }
  }

  String? getFingerprintTime(String? time, bool? isIn) {
    if (time == null || time.isEmpty) return null;

    try {
      final dateTime = DateFormat("HH:mm:ss", "en").parse(time);
      final formattedTime = DateFormat('h:mm a',
          LocalizationService.isArabic(context: context) ? "ar" : "en")
          .format(dateTime);
      return "${isIn ?? true ? AppStrings.ins.tr() : AppStrings.out.tr()} $formattedTime";
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: LayoutService.getWidth(context),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.s16, vertical: AppSizes.s12),
      margin: const EdgeInsets.symmetric(vertical: AppSizes.s8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppSizes.s10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  margin:
                  const EdgeInsets.symmetric(horizontal: AppSizes.s8),
                  width: AppSizes.s36,
                  height: AppSizes.s36,
                  child: Image.asset(
                    widget.isIn == true
                        ? AppImages.fingerprintIn
                        : AppImages.fingerprintOut,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (getFingerprintTime(
                        widget.fingerprintDatetime.time, widget.isIn) !=
                        null)
                      AutoSizeText(
                        getFingerprintTime(
                            widget.fingerprintDatetime.time, widget.isIn)!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppSizes.s14,
                          color: Colors.black,
                        ),
                      ),
                    if (branchName != null)
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.5,
                        child: AutoSizeText(
                          branchName!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.s6),
            width: AppSizes.s26,
            height: AppSizes.s26,
            child: Image.asset(
              getFingerprintImageDependsOnType(
                  widget.fingerprintDatetime.type ?? ''),
              color: Colors.black,
            ),
          ),
          if (widget.fingerprintDatetime.isOffline == true)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSizes.s6),
              width: AppSizes.s26,
              height: AppSizes.s26,
              child: Image.asset(
                AppImages.fingerprintOffline,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}
