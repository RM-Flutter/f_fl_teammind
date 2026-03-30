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
import 'package:app_test/core/constants/app_sizes.dart';
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
    final mainColor = Color(AppColors.blue);

    final request = widget.request;

    return Stack(
      children: [
        Container(
          height: (widget.height! + 40) ,
          width: LayoutService.getWidth(context),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(AppColors.dark),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(AppSizes.s28),
              bottomRight: Radius.circular(AppSizes.s28),
            ),
            image: const DecorationImage(
              image: AssetImage("assets/images/profile-app-bar.png"),
              fit: BoxFit.fill,
              opacity: 1.0,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: kIsWeb ? 1100 : double.infinity
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
                    titleStyle: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.white),
                    bookmarkIconColor: Colors.white,
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
                  const SizedBox(height: 10),
                  Padding(
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
                                        : Color(AppColors.darkGrey),
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 5,
                                  );
                                },
                                child: Container(
                                  width: 65,
                                  height: 85,
                                  decoration: BoxDecoration(
                                    color: mainColor,
                                    borderRadius: BorderRadius.circular(AppSizes.s10),
                                  ),
                                  child: Center(
                                    child: RequestsServices.getRequestsStatusIcon(
                                      context: context,
                                      status: request.status,
                                      iconSize: AppSizes.s30,
                                      iconColor: Colors.white,
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
                                spacing: 8.0,
                                runSpacing: 8.0,
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
                                        width: AppSizes.s100,
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
                                            height: LayoutService.getHeight(context) * 0.5,
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
                  const SizedBox(height: 12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AppStrings.downloadFile.tr(),
                style: const TextStyle(fontSize: 18),
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
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: value > 0 ? value : null,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.blue)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  value > 0 ? '${(value * 100).toStringAsFixed(0)}%' : '0%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
            ? (LayoutService.getWidth(context) - 110) / 2
            : LayoutService.getWidth(context) - 97,
        decoration: BoxDecoration(
            color: isHighLight == true ? _imgColor : background,
            borderRadius: BorderRadius.circular(AppSizes.s10)),
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
                    if (imagePath != null)
                      Image.asset(
                        imagePath!,
                        width: AppSizes.s14,
                        height: AppSizes.s14,
                        color: isHighLight == true ? Color(AppColors.white) : _imgColor,
                      )
                    else if (imgPath != null)
                      Icon(
                        imgPath,
                        color: isHighLight == true ? Color(AppColors.white) : _imgColor,
                      ),
                    gapW12,
                    Expanded(
                      child: AutoSizeText(
                        title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
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