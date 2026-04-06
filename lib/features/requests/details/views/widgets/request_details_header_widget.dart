import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' if (dart.library.html) 'directory_stub.dart' as io;
import 'dart:html' if (dart.library.io) '../../../../../core/services/dart_html_stub.dart' as html;
import 'package:open_filex/open_filex.dart';

import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/requests/details/views/widgets/management_response_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/services/requests_services.dart';
import 'package:app_test/core/services/settings_service.dart';

class RequestDetailsHeaderWidget extends StatefulWidget {
  final double? height;
  final dynamic request;
  final dynamic uId;
  final dynamic rId;

  const RequestDetailsHeaderWidget({
    super.key,
    required this.request,
    required this.height,
    this.rId,
    this.uId,
  });

  @override
  State<RequestDetailsHeaderWidget> createState() =>
      _RequestDetailsHeaderWidgetState();
}

class _RequestDetailsHeaderWidgetState extends State<RequestDetailsHeaderWidget> {
  double _downloadProgress = 0.0;
  String? _downloadingFileName;

  /// No permission needed: we save to app directory (getApplicationDocumentsDirectory).
  Future<bool> requestStoragePermission() async {
    return true;
  }


  /// Get download directory. Uses app-specific directory so no storage permission needed.
  Future<dynamic> _getDownloadDirectory() async {
    if (kIsWeb || PlatformIs.web) {
      throw UnsupportedError("Download directory not available on web");
    }
    if (!kIsWeb) {
      // App documents dir: no permission needed on Android/iOS, file can be opened with OpenFile
      return await getApplicationDocumentsDirectory();
    }
    throw UnsupportedError("Download directory not available on web");
  }

  /// Download a single file and update progress
  Future<void> _downloadFile(String url, String fileName) async {
    // On web, download the file and open it in a new tab
    if (PlatformIs.web) {
      try {
        if (kIsWeb) {
          // Use dart:html for web download and open in new tab
          try {
            // 1. First, trigger download using fetch API to avoid navigation
            if (kIsWeb) {
              // Use dynamic typing to work with dart:html types
              final fetchResult = html.window.fetch(url);
              fetchResult.then((response) {
                // response is html.Response on web
                return (response as dynamic).blob();
              }).then((blob) {
                // blob is html.Blob on web
                final blobUrl = html.Url.createObjectUrlFromBlob(blob as dynamic);
                final html.AnchorElement downloadAnchor = html.AnchorElement(href: blobUrl);
                downloadAnchor.download = fileName;
                downloadAnchor.style.display = 'none';
                html.document.body?.append(downloadAnchor);
                downloadAnchor.click();
                downloadAnchor.remove();
                html.Url.revokeObjectUrl(blobUrl);
              }).catchError((e) {
                debugPrint('Error downloading file with fetch: $e');
              });
            }

            // 2. Open file in new tab using url_launcher (this won't close the app)
            await Future.delayed(const Duration(milliseconds: 200));
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }

            Fluttertoast.showToast(
              msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
              backgroundColor: Colors.green,
              textColor: Colors.white,
              toastLength: Toast.LENGTH_LONG,
              timeInSecForIosWeb: 3,
            );
          } catch (e) {
            debugPrint('Error downloading/opening file: $e');
            // Fallback: just open in new tab
            try {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            } catch (e2) {
              Fluttertoast.showToast(
                msg: 'Error opening file: $e2',
                backgroundColor: Colors.red,
                textColor: Colors.white,
                toastLength: Toast.LENGTH_LONG,
                timeInSecForIosWeb: 3,
              );
            }
          }
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error downloading file: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
        );
      }
      return;
    }

    // Mobile platforms: download to device storage
    final dio = Dio();
    final progressNotifier = ValueNotifier<double>(0.0);

    try {
      final dir = await _getDownloadDirectory();
      final filePath = '${dir.path}/$fileName';

      setState(() {
        _downloadingFileName = fileName;
        _downloadProgress = 0.0;
      });

      if (mounted) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => _DownloadProgressDialog(
            fileName: fileName,
            progressNotifier: progressNotifier,
          ),
        );
      }

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && total > 0) {
            final p = received / total;
            progressNotifier.value = p;
            if (mounted) setState(() => _downloadProgress = p);
          }
        },
      );
      if (mounted) Navigator.of(context).pop();
      await OpenFilex.open(filePath);
      if (mounted) {
        Fluttertoast.showToast(
          msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        Fluttertoast.showToast(
          msg: '$e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } finally {
      progressNotifier.dispose();
      if (mounted) {
        setState(() {
          _downloadProgress = 0.0;
          _downloadingFileName = null;
        });
      }
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
    final mainColor = Theme.of(context).colorScheme.primary;

    final request = widget.request;

    return Stack(
      children: [
        Container(
          height: (widget.height! + 30.h) ,
          width: 1.sw,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(AppColors.dark),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28.r),
              bottomRight: Radius.circular(28.r),
            ),
            image: const DecorationImage(
              image: AssetImage("assets/images/request-app-bar.png"),
              fit: BoxFit.fill,
              opacity: 1.0,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: kIsWeb ? 1100.w : 1.sw
              ),
              child: Column(
                children: [
                  AppBarWithBookmark(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    routeName: AppRoutes.requestDetails.name,
                    defaultTitle: AppSettingsService.getRequestTitleFromGenenralSettings(
                        context: context, requestId: request.typeId.toString()) ??
                        '',
                    title: AppSettingsService.getRequestTitleFromGenenralSettings(
                        context: context, requestId: request.typeId.toString()) ??
                        '',
                    titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 20.sp),
                    bookmarkIconColor: Colors.white,
                    leading: Padding(
                      padding: EdgeInsets.all(10.r),
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
                          child: Icon(
                            Icons.arrow_back_sharp,
                            color: Colors.white,
                            size: 18.r,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
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
                                        : Color(AppColors.darkGrey),
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 5,
                                  );
                                },
                                child: Container(
                                  width: 65.w,
                                  height: 85.h,
                                  decoration: BoxDecoration(
                                    color: mainColor.withOpacity(.3),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Center(
                                    child: RequestsServices.getRequestsStatusIcon(
                                      context: context,
                                      status: request.status,
                                      iconSize: 30.r,
                                      iconColor: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(width: 8.w),

                          // Info tiles
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: 12.w,
                                runSpacing: 12.h,
                                children: [
                                  // Date tile with formatting
                                  InfoTileWidget(
                                    imagePath: 'assets/images/new-cale.png',
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
                                        width: 100.w,
                                        background: const Color(AppColors.black).withOpacity(0.08),
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
                                  if (request.moneyValue != null && (double.tryParse(request.moneyValue.toString()) ?? 0) > 0)
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
                                            height: 0.5.sh,
                                          );
                                        }
                                      },
                                      imgPath: Icons.clear,
                                      background: const Color(AppColors.darkRed),
                                      imgColor: Color(AppColors.white),
                                      title: AppStrings.requestedToIgnore.tr().toUpperCase(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
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
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.white, size: 24.r),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        _downloadingFileName!,
                        style: AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        color: Colors.lightGreenAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                      style: AppStyles.whiteContent(context).copyWith(fontSize: 12.sp),
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

/// Dialog shown while a file is downloading (with progress).
class _DownloadProgressDialog extends StatelessWidget {
  final String fileName;
  final ValueNotifier<double> progressNotifier;

  const _DownloadProgressDialog({
    required this.fileName,
    required this.progressNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            SizedBox(
              width: 28.r,
              height: 28.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                AppStrings.downloadFile.tr(),
                style: AppStyles.darkHeading(context).copyWith(fontSize: 18.sp),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, value, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  fileName,
                  style: AppStyles.greyContent(context).copyWith(
                    fontSize: 13.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 16.h),
                LinearProgressIndicator(
                  value: value > 0 ? value : null,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.blue)),
                  minHeight: 8.h,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                SizedBox(height: 8.h),
                Text(
                  value > 0 ? '${(value * 100).toStringAsFixed(0)}%' : '0%',
                  style: AppStyles.darkContent(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class InfoTileWidget extends StatelessWidget {
  final IconData? imgPath;
  final String? imagePath;
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
        this.imgPath,
        this.imagePath,
        this.width,
        this.onTap,
        required this.title,
        this.background = const Color(AppColors.navyBlue),
        this.trailing,
        this.imgColor});

  Color get _imgColor => imgColor ?? Color(AppColors.blue);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? (){},
      child: Container(
        width: width != null ? width : isFullRow == false
            ? (1.sw - 116.w) / 2
            : 1.sw - 97.w,
        decoration: BoxDecoration(
            color: isHighLight == true ? _imgColor : background,
            borderRadius: BorderRadius.circular(10.r)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 6.w, vertical: 6.h),
                child: Row(
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        imagePath!,
                        width: 14.r,
                        height: 14.r,
                        color: isHighLight == true ? Color(AppColors.white) : _imgColor,
                      )
                    else if (imgPath != null)
                      Icon(
                        imgPath,
                        size: 20.r,
                        color: isHighLight == true ? Color(AppColors.white) : _imgColor,
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AutoSizeText(
                        title,
                        style: AppStyles.whiteContent(context).copyWith(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700),
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