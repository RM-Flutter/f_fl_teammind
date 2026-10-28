import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

import '../../../../../core/constants/app_constants.dart';

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
  Future<void> _downloadFile(String rawUrl, String rawFileName) async {
    final String url = Uri.encodeFull(rawUrl.trim());
    final String fileName = rawFileName.trim();
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
        String fileUrl = '';
        if (file is String) {
          fileUrl = file;
        } else if (file is Map) {
          fileUrl = file['file']?.toString() ?? file['url']?.toString() ?? '';
        } else {
          try {
            fileUrl = (file as dynamic).file?.toString() ?? '';
          } catch (_) {}
        }
        if (fileUrl.isEmpty) continue;
        
        fileUrl = fileUrl.trim();
        if (fileUrl.startsWith('/')) {
          fileUrl = '${AppConstants.base}$fileUrl';
        } else if (!fileUrl.startsWith('http')) {
          fileUrl = '${AppConstants.base}/$fileUrl';
        }
        
        final String fileName = fileUrl.split('/').last;
        await _downloadFile(fileUrl, fileName);
      } catch (e) {
        debugPrint('Error downloading file: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(AppColors.buttons);

    final request = widget.request;

    return Stack(
      children: [
        Container(
          height: (widget.height! + 30) ,
          width: 1.sw,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(AppColors.secondaryButton),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
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
                  maxWidth: kIsWeb ? 1100 : 1.sw
              ),
              child: Column(
                children: [
                  Builder(builder: (context) {
                    String headerTitle = AppSettingsService.getRequestTitleFromGenenralSettings(
                            context: context, requestId: request.typeId.toString()) ??
                        '';
                    if (headerTitle.isEmpty) {
                      try {
                        final appType = (request as dynamic).approvableType?.toString();
                        final isAr = LocalizationService.isArabic(context: context);
                        if (appType == 'shift_change_requests') {
                          headerTitle = isAr ? 'طلب تبديل شيفت' : 'Shift Change Request';
                        } else if (appType == 'overtime' || appType == 'overtime_requests') {
                          headerTitle = AppStrings.overtimeRequests.tr();
                        } else if (appType == 'salary_advance' || appType == 'salary_advance_requests') {
                          headerTitle = isAr ? 'طلب سلفة' : 'Salary Advance Request';
                        } else if (appType == 'employee_expense_claims') {
                          headerTitle = isAr ? 'مطالبة مصروفات' : 'Expense Claim';
                        }
                      } catch (_) {}
                    }
                    return AppBarWithBookmark(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      centerTitle: true,
                      routeName: AppRoutes.requestDetails.name,
                      defaultTitle: headerTitle,
                      title: headerTitle,
                      titleStyle: AppStyles.whiteHeading(context).copyWith(fontSize: 20),
                      bookmarkIconColor: Colors.white,
                      leading: Padding(
                        padding: EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop(); // هيرجع لورا
                            } else {
                              context.goNamed(AppRoutes.home.name,
                                  pathParameters: {
                                    'lang': context.locale.languageCode,
                                  });
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
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
                                        : Color(0xff606060),
                                    textColor: Colors.white,
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.TOP,
                                    timeInSecForIosWeb: 5,
                                  );
                                },
                                child: Builder(builder: (context) {
                                    Color getIconColor(String? status) {
                                      if (status == null) return Colors.white;
                                      switch (status.toLowerCase().trim()) {
                                        case 'approved':
                                          return Colors.green;
                                        case 'refused':
                                        case 'rejected':
                                        case 'canceled':
                                          return Colors.red;
                                        default:
                                          return Colors.white;
                                      }
                                    }
                                    return Container(
                                      width: 65,
                                      height: 85,
                                      decoration: BoxDecoration(
                                        color: mainColor.withOpacity(.3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: RequestsServices.getRequestsStatusIcon(
                                          context: context,
                                          status: request.status,
                                          iconSize: 30,
                                          iconColor: getIconColor(request.status?.toString()),
                                        ),
                                      ),
                                    );
                                  }),
                              )
                            ],
                          ),
                          SizedBox(width: 8),

                          // Info tiles
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  // Date tile with formatting
                                  InfoTileWidget(
                                    background: Color(AppColors.secondaryButton),
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
                                    trailing: (widget.request.duration != null && widget.request.duration.toString() != 'null')
                                        ? InfoTileWidget(
                                            width: 100,
                                            background: Color(AppColors.secondaryButton),
                                            imgPath: Icons.access_time,
                                            title: '${widget.request.duration} ${widget.request.durationType != null && widget.request.durationType.toString() != 'null' ? widget.request.durationType.toString().tr() : ''}'.trim(),
                                          )
                                        : null,
                                  ),

                                  // Employee info if different user
                                  if (widget.uId?.toString() != widget.rId?.toString()) ...[
                                    if (request.employeeName != null &&
                                        request.employeeName.toString() != 'null' &&
                                        request.employeeName.toString().trim().isNotEmpty)
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
                                        title: request.employeeName.toString(),
                                        isHighLight: true,
                                      ),
                                    if (request.departmentName != null &&
                                        request.departmentName.toString() != 'null' &&
                                        request.departmentName.toString().trim().isNotEmpty)
                                      InfoTileWidget(
                                        imgPath: Icons.category_outlined,
                                        title: request.departmentName.toString(),
                                      ),
                                  ],

                                  // Request type
                                  if (request.typeName != null &&
                                      request.typeName.toString() != 'null' &&
                                      request.typeName.toString().trim().isNotEmpty)
                                    InfoTileWidget(
                                      imgPath: Icons.category_outlined,
                                      title: request.typeName.toString(),
                                    ),

                                  // Shift Change Request specific two-party info tiles
                                  Builder(builder: (context) {
                                    try {
                                      if ((request as dynamic).approvableType == 'shift_change_requests') {
                                        final reqShift = (request as dynamic).requesterShiftName?.toString() ?? '';
                                        final recShift = (request as dynamic).receiverShiftName?.toString() ?? '';
                                        final recEmpName = (request as dynamic).receiverEmployee?.name?.toString() ?? '';
                                        final recEmpId = (request as dynamic).receiverEmployeeId;
                                        return Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: [
                                            if (recEmpName.isNotEmpty)
                                              InfoTileWidget(
                                                onTap: recEmpId != null
                                                    ? () {
                                                        context.pushNamed(
                                                          'employeeDetails',
                                                          pathParameters: {
                                                            'id': recEmpId.toString(),
                                                            'lang': context.locale.languageCode,
                                                          },
                                                        );
                                                      }
                                                    : null,
                                                imgPath: Icons.swap_horiz_rounded,
                                                title: recEmpName,
                                                isHighLight: true,
                                              ),
                                            if (reqShift.isNotEmpty)
                                              InfoTileWidget(
                                                imgPath: Icons.schedule_rounded,
                                                title: ((request as dynamic).receiverShiftAssignmentId != null && recShift.isNotEmpty)
                                                    ? '$reqShift ↔ $recShift'
                                                    : reqShift,
                                              ),
                                          ],
                                        );
                                      }
                                    } catch (_) {}
                                    return const SizedBox.shrink();
                                  }),

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
                                      imgColor: Color(AppColors.background),
                                      title: AppStrings.requestedToIgnore.tr().toUpperCase(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 12),
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
                EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.file_download, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _downloadingFileName!,
                        style: AppStyles.whiteContent(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        color: Colors.lightGreenAccent,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "${(_downloadProgress * 100).toStringAsFixed(0)}%",
                      style: AppStyles.whiteContent(context).copyWith(fontSize: 12),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(AppColors.buttons)),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                AppStrings.downloadFile.tr(),
                style: AppStyles.heading(context).copyWith(fontSize: 18, color: Colors.black),
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
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: value > 0 ? value : null,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                SizedBox(height: 8),
                Text(
                  value > 0 ? '${(value * 100).toStringAsFixed(0)}%' : '0%',
                  style: AppStyles.blackContent(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
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
  final double? width;
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
        this.background,
        this.trailing,
        this.imgColor});

  Color get _imgColor => imgColor ?? Color(AppColors.buttons);

  @override
  Widget build(BuildContext context) {
    Color effectiveBackground = background ?? const Color(AppColors.navyBlue);
    final double? tileWidth = width ??
        (isFullRow == true
            ? null
            : (kIsWeb ? 240.0 : ((1.sw - 116) / 2)));

    return GestureDetector(
      onTap: onTap ?? (){},
      child: Container(
        width: tileWidth,
        decoration: BoxDecoration(
            color: isHighLight == true ? _imgColor : effectiveBackground,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 6, vertical: 6),
                child: Row(
                  children: [
                    if (imagePath != null)
                      Image.asset(
                        imagePath!,
                        width: 14,
                        height: 14,
                        color: isHighLight == true ? Color(AppColors.background) : _imgColor,
                      )
                    else if (imgPath != null)
                      Icon(
                        imgPath,
                        size: 20,
                        color: isHighLight == true ? Color(AppColors.background) : _imgColor,
                      ),
                    SizedBox(width: 12),
                    Expanded(
                      child: AutoSizeText(
                        title,
                        style: AppStyles.whiteContent(context).copyWith(
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