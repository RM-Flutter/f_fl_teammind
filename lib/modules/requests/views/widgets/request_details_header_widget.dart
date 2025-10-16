import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/localization.service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/app_sizes.dart';
import '../../../../general_services/date.service.dart';
import '../../../../general_services/layout.service.dart';
import '../../../../general_services/settings.service.dart';
import '../../../../modules/requests/views/widgets/modals/management_response.modal.dart';
import '../../../../routing/app_router.dart';
import '../../../../services/requests.services.dart';
import '../../../../utils/modal_sheet_helper.dart';

class RequestDetailsHeaderWidget extends StatefulWidget {
  final double? height;
  final dynamic request;
  final dynamic uId;
  final dynamic rId;

  const RequestDetailsHeaderWidget({
    Key? key,
    required this.request,
    required this.height,
    this.rId,
    this.uId,
  }) : super(key: key);

  @override
  State<RequestDetailsHeaderWidget> createState() =>
      _RequestDetailsHeaderWidgetState();
}

class _RequestDetailsHeaderWidgetState extends State<RequestDetailsHeaderWidget> {
  double _downloadProgress = 0.0;
  String? _downloadingFileName;

  /// Request storage permission based on Android version
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        // Android 11+ needs MANAGE_EXTERNAL_STORAGE permission, user must enable manually
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            await openAppSettings();
            return false;
          }
        }
        return true;
      } else if (sdkInt >= 23) {
        // Android 6 to 10: request storage permission normally
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) return false;
        }
        return true;
      } else {
        // Android versions before 6 automatically grant permissions on install
        return true;
      }
    }
    return true; // iOS and others
  }


  /// Get appropriate download directory (Android / iOS)
  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // getExternalStoragePublicDirectory is deprecated in Android 29+,
      // but still works for now, or you can manually build path:
      final Directory? directory = Directory('/storage/emulated/0/Download');
      if (await directory!.exists()) {
        return directory;
      } else {
        throw Exception("Download directory not found");
      }
    } else if (Platform.isIOS) {
      // iOS has no downloads folder, use Documents instead
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  /// Download a single file and update progress
  Future<void> _downloadFile(String url, String fileName) async {
    final dio = Dio();

    try {
      final dir = await _getDownloadDirectory();
      final filePath = '${dir.path}/$fileName';

      setState(() {
        _downloadingFileName = fileName;
        _downloadProgress = 0.0;
      });

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      await OpenFile.open(filePath);
      Fluttertoast.showToast(
        msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() {
        _downloadProgress = 0.0;
        _downloadingFileName = null;
      });
    }
  }

  /// Download all files (looping)
  Future<void> _downloadAllFiles(List files) async {
    if (files.isEmpty) return;

    final permissionGranted = await requestStoragePermission();
    if (!permissionGranted) {
      Fluttertoast.showToast(msg: 'Storage permission is required to download files.');
      return;
    }

    for (var file in files) {
      try {
        final String fileUrl = file.file;
        final String fileName = fileUrl.split('/').last;
        await _downloadFile(fileUrl, fileName);
      } catch (e) {
        debugPrint('Error downloading file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = const Color(0xff3489EF);

    final request = widget.request;

    return Stack(
      children: [
        Container(
          height: widget.height,
          width: LayoutService.getWidth(context),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppSizes.s28),
              bottomRight: Radius.circular(AppSizes.s28),
            ),
            image: const DecorationImage(
              image: AssetImage("assets/images/png/single_request_back.png"),
              fit: BoxFit.fill,
              opacity: 0.4,
            ),
          ),
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  AppSettingsService.getRequestTitleFromGenenralSettings(
                      context: context, requestId: request.typeId.toString()) ??
                      '',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                leading: Padding(
                  padding: const EdgeInsets.all(AppSizes.s10),
                  child: InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop(); // هيرجع لورا
                      } else {
                        context.goNamed(AppRoutes.home.name,
                            pathParameters: {'lang': context.locale.languageCode,});
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.white,
                        size: AppSizes.s18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status box
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Fluttertoast.showToast(
                                msg: request.status.toString().tr(),
                                backgroundColor: request.status == "canceled" || request.status == "refused"
                                    ? Colors.red
                                    : request.status == "approved"
                                    ? Colors.green
                                    : const Color(0xff606060),
                                textColor: Colors.white,
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP,
                                timeInSecForIosWeb: 5,
                              );
                            },
                            child: Container(
                              width: AppSizes.s50,
                              height: AppSizes.s80,
                              decoration: BoxDecoration(
                                color: mainColor,
                                borderRadius: BorderRadius.circular(AppSizes.s10),
                              ),
                              child: Center(
                                child: RequestsServices.getRequestsStatusIcon(
                                  context: context,
                                  status: request.status,
                                  iconSize: AppSizes.s30,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(width: 8),

                      // Info tiles
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                            spacing: AppSizes.s5,
                            runSpacing: AppSizes.s5,
                            children: [
                              // Date tile with formatting
                              InfoTileWidget(
                                imgPath: Icons.calendar_month,
                                title: DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'dd MMM yyyy') ==
                                    DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'dd MMM yyyy')?
                                DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'hh:mm a') !=
                                    DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'hh:mm a')?
                                "${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'hh:mm a')} : ${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'hh:mm a')} ${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'dd MMM yyyy')}"
                                    : "${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'dd MMM yyyy')}"
                                    : DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'yyyy') ==
                                    DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'yyyy')?
                                "${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'dd MMM')} : ${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'dd MMM')} ${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'yyyy')}":
                                "${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.from, format: 'dd MMM yyyy')} : ${DateService.formatDate(LocalizationService.isArabic(context: context) ?"ar" : "en",context,widget.request.to, format: 'dd MMM yyyy')}",
                                isFullRow: true,
                                trailing: InfoTileWidget(
                                    width: MediaQuery.sizeOf(context).width * 0.25,
                                    background: const Color(0xff000000).withOpacity(0.08),
                                    imgPath: Icons.access_time,
                                    title: '${widget.request.duration} ${widget.request.durationType.toString().tr()}'),
                              ),

                              // Employee info if different user
                              if (widget.uId != widget.rId) ...[
                                InfoTileWidget(
                                  onTap: () {
                                    context.pushNamed(
                                      'employeeDetails',
                                      pathParameters: {
                                        'id': request.employeeId.toString(),
                                        'lang': context.locale.languageCode,
                                      },
                                    );
                                  },
                                  imgPath: Icons.person_2_outlined,
                                  title: request.employeeName ?? '-',
                                  isHighLight: true,
                                ),
                                InfoTileWidget(
                                  imgPath: Icons.category_outlined,
                                  title: request.departmentName.toString(),
                                ),
                              ],

                              // Request type
                              InfoTileWidget(
                                imgPath: Icons.category_outlined,
                                title: request.typeName.toString(),
                              ),

                              // Money value if present
                              if (request.moneyValue != null && request.moneyValue > 0)
                                InfoTileWidget(
                                  imgPath: Icons.attach_money_outlined,
                                  title:
                                  '${AppStrings.amount.tr()}: ${request.moneyValue} ${AppStrings.egp.tr().toUpperCase()}',
                                ),

                              // Download files button
                              if (request.files != null && request.files.isNotEmpty)
                                InfoTileWidget(
                                  onTap: () => _downloadAllFiles(request.files),
                                  imgPath: Icons.file_download_outlined,
                                  title: AppStrings.downloadFile.tr(),
                                ),

                              // Requested to ignore (cancel request) button
                              if ((request.status == "waiting_seen" ||
                                  request.status == "waiting") &&
                                  request.waitingCancel == true)
                                InfoTileWidget(
                                  onTap: () async {
                                    if (widget.uId == widget.rId) {
                                      debugPrint("TAPPED!");
                                    } else {
                                      await ModalSheetHelper.showModalSheet(
                                        context: context,viewProfile: false,
                                        modalContent: ManagementResponseModal(
                                            requestId: request.id.toString()),
                                        title: AppStrings.managementResponse.tr(),
                                        height: LayoutService.getHeight(context) * 0.5,
                                      );
                                    }
                                  },
                                  imgPath: Icons.clear,
                                  background: const Color(0xff851919),
                                  imgColor: Colors.white,
                                  title: AppStrings.requestedToIgnore.tr().toUpperCase(),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),

        // Download progress overlay
        if (_downloadProgress > 0 && _downloadingFileName != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 6,
              color: Colors.black87,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.file_download, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _downloadingFileName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        color: Colors.lightGreenAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _downloadProgress = 0.0;
                          _downloadingFileName = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Helper to format date range string
}

class InfoTileWidget extends StatelessWidget {
  final IconData imgPath;
  final Color? background;
  final Color? imgColor;
  final String title;
  var width;
  var onTap;
  final bool? isFullRow;
  final bool? isHighLight;
  final Widget? trailing;
  InfoTileWidget(
      {super.key,
        this.isHighLight = false,
        this.isFullRow = false,
        required this.imgPath,
        this.width,
        this.onTap,
        required this.title,
        this.background = const Color(0xff2C376C),
        this.trailing,
        this.imgColor = const Color(0xff3489EF)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? (){},
      child: Container(
        width: width != null ? width : isFullRow == false
            ? (LayoutService.getWidth(context) - AppSizes.s88) / 2
            : null,
        decoration: BoxDecoration(
            color: isHighLight == true ? imgColor : background,
            borderRadius: BorderRadius.circular(AppSizes.s6)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.s6, vertical: AppSizes.s6),
                child: Row(
                  children: [
                    Icon(
                      imgPath,
                      color: isHighLight == true ? Colors.white : imgColor,
                    ),
                    gapW12,
                    Expanded(
                      child: AutoSizeText(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.s10,
                            fontWeight: FontWeight.w400),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isFullRow == true && trailing != null) trailing!
          ],
        ),
      ),
    );
  }
}