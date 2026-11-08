import 'package:app_test/core/services/app_toast.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'dart:html' if (dart.library.io) '../../../../../core/services/dart_html_stub.dart' as html;
import 'package:open_filex/open_filex.dart';

import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/services/date_service.dart';
import 'package:app_test/core/services/layout_service.dart';
import 'package:app_test/core/utils/modal_sheet_helper.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/core/widgets/files_carousel_dialog.dart';
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
import 'package:app_test/core/constants/app_design.dart';

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

            AppToast.showToast(
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
              AppToast.showToast(
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
        AppToast.showToast(
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
        AppToast.showToast(
          msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      if (mounted) {
        AppToast.showToast(
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

  /// Resolve a file entry (String, Map or model) into an absolute URL.
  String _resolveFileUrl(dynamic file) {
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
    fileUrl = fileUrl.trim();
    if (fileUrl.isEmpty) return '';
    if (fileUrl.startsWith('/')) {
      return '${AppConstants.base}$fileUrl';
    } else if (!fileUrl.startsWith('http')) {
      return '${AppConstants.base}/$fileUrl';
    }
    return fileUrl;
  }

  Future<void> _downloadSingleFile(String fileUrl, String fileName) async {
    final permissionGranted = await requestStoragePermission();
    if (!permissionGranted) {
      AppToast.showToast(msg: 'Storage permission is required to download files.');
      return;
    }
    try {
      await _downloadFile(fileUrl, fileName);
    } catch (e) {
      debugPrint('Error downloading file: $e');
    }
  }

  /// Show the request files in the shared files carousel dialog.
  void _showFilesDialog(List files) {
    final urls = files.map(_resolveFileUrl).where((u) => u.isNotEmpty).toList();
    showFilesCarouselDialog(
      context: context,
      urls: urls,
      onDownload: _downloadSingleFile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = Color(AppColors.buttons);

    final request = widget.request;

    return Stack(
      children: [
        Container(
          // On web the info chips fit in fewer rows, so a fixed height leaves a large
          // empty area that steals space from the tabs below. Size to content there.
          height: kIsWeb ? null : (widget.height! + 30),
          width: 1.sw,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(AppColors.secondaryButton),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(AppRadius.xl),
              bottomRight: Radius.circular(AppRadius.xl),
            ),
            image: const DecorationImage(
              image: AssetImage("assets/images/request-app-bar.png"),
              fit: BoxFit.fill,
              opacity: 1.0,
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: double.infinity
              ),
              child: Column(
                children: [
                  Builder(builder: (context) {
                    String headerTitle = AppSettingsService.getRequestTitleFromGenenralSettings(
                            context: context,
                            requestId: request.typeId.toString(),
                            fallbackTitle: (() {
                              try {
                                return (request as dynamic).typeName?.toString();
                              } catch (_) {
                                return null;
                              }
                            })()) ??
                        '';
                    if (headerTitle.isEmpty) {
                      try {
                        final appType = (request as dynamic).approvableType?.toString();
                        if (appType == 'shift_change_requests') {
                          headerTitle = 'shift_change_request'.tr();
                        } else if (appType == 'overtime' || appType == 'overtime_requests') {
                          headerTitle = AppStrings.overtimeRequests.tr();
                        } else if (appType == 'salary_advance' || appType == 'salary_advance_requests') {
                          headerTitle = 'salary_advance_request'.tr();
                        } else if (appType == 'employee_expense_claims') {
                          headerTitle = 'expense_claim_2'.tr();
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
                                  AppToast.showToast(
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
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final double availableWidth = constraints.maxWidth;
                                const double spacing = 12.0;

                                // Build list of all available detail items (no empty/dummy widgets)
                                final List<Widget> items = [];
                                // Long tile (e.g. shift swap) shown on its own full-width row so the text is not cut off.
                                Widget? fullWidthTile;
                                bool isShiftChange = false;
                                try {
                                  isShiftChange = (request as dynamic).approvableType == 'shift_change_requests';
                                } catch (_) {}

                                void openEmployee(dynamic id) {
                                  context.pushNamed(
                                    'employeeDetails',
                                    pathParameters: {
                                      'id': id.toString(),
                                      'lang': context.locale.languageCode,
                                    },
                                  );
                                }

                                // Employee info
                                if (!isShiftChange &&
                                    request.employeeName != null &&
                                    request.employeeName.toString() != 'null' &&
                                    request.employeeName.toString().trim().isNotEmpty) {
                                  items.add(
                                    InfoTileWidget(
                                      onTap: (request.employeeId != null &&
                                              request.employeeId.toString() != 'null' &&
                                              request.employeeId.toString() != '0' &&
                                              request.employeeId.toString().trim().isNotEmpty)
                                          ? () {
                                              context.pushNamed(
                                                'employeeDetails',
                                                pathParameters: {
                                                  'id': request.employeeId.toString(),
                                                  'lang': context.locale.languageCode,
                                                },
                                              );
                                            }
                                          : null,
                                      imgPath: Icons.person_2_outlined,
                                      title: request.employeeName.toString(),
                                      isHighLight: true,
                                    ),
                                  );
                                }

                                // Department info
                                if (request.departmentName != null &&
                                    request.departmentName.toString() != 'null' &&
                                    request.departmentName.toString().trim().isNotEmpty) {
                                  items.add(
                                    InfoTileWidget(
                                      imgPath: Icons.category_outlined,
                                      title: request.departmentName.toString(),
                                    ),
                                  );
                                }

                                // Request type
                                if (request.typeName != null &&
                                    request.typeName.toString() != 'null' &&
                                    request.typeName.toString().trim().isNotEmpty) {
                                  items.add(
                                    InfoTileWidget(
                                      imgPath: Icons.category_outlined,
                                      title: request.typeName.toString(),
                                    ),
                                  );
                                }

                                // Shift Change Request: requester and receiver tiles side by side,
                                // each shift under its owner, with a swap icon between the two sides.
                                try {
                                  if (isShiftChange) {
                                    final reqEmpId = request.employeeId;
                                    final recEmpId = (request as dynamic).receiverEmployeeId;
                                    final hasReqId = reqEmpId != null &&
                                        reqEmpId.toString() != 'null' &&
                                        reqEmpId.toString() != '0' &&
                                        reqEmpId.toString().trim().isNotEmpty;
                                    final reqName = request.employeeName?.toString() ?? '';
                                    final recName = (request as dynamic).receiverEmployee?.name?.toString() ?? '';
                                    final reqShift = (request as dynamic).requesterShiftName?.toString() ?? '';
                                    final recShift = (request as dynamic).receiverShiftName?.toString() ?? '';

                                    Widget pairRow(Widget start, Widget end, IconData icon) => Row(
                                          children: [
                                            Expanded(child: start),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 4),
                                              child: Icon(icon, size: 18, color: Color(AppColors.background)),
                                            ),
                                            Expanded(child: end),
                                          ],
                                        );

                                    fullWidthTile = Column(
                                      children: [
                                        pairRow(
                                          InfoTileWidget(
                                            onTap: hasReqId ? () => openEmployee(reqEmpId) : null,
                                            imgPath: Icons.person_2_outlined,
                                            title: reqName,
                                            isHighLight: true,
                                          ),
                                          InfoTileWidget(
                                            onTap: recEmpId != null ? () => openEmployee(recEmpId) : null,
                                            imgPath: Icons.person_2_outlined,
                                            title: recName,
                                            isHighLight: true,
                                          ),
                                          Icons.swap_horiz_rounded,
                                        ),
                                        if (reqShift.isNotEmpty || recShift.isNotEmpty) ...[
                                          const SizedBox(height: spacing),
                                          pairRow(
                                            InfoTileWidget(
                                              imgPath: Icons.schedule_rounded,
                                              title: reqShift.isEmpty ? '-' : reqShift,
                                            ),
                                            InfoTileWidget(
                                              imgPath: Icons.schedule_rounded,
                                              title: recShift.isEmpty ? '-' : recShift,
                                            ),
                                            Icons.swap_horiz_rounded,
                                          ),
                                        ],
                                      ],
                                    );
                                  }
                                } catch (_) {}

                                // Money value if present
                                if (request.moneyValue != null &&
                                    (double.tryParse(request.moneyValue.toString()) ?? 0) > 0) {
                                  items.add(
                                    InfoTileWidget(
                                      imgPath: Icons.attach_money_outlined,
                                      title:
                                          '${AppStrings.amount.tr()}: ${request.moneyValue} ${AppStrings.egp.tr().toUpperCase()}',
                                    ),
                                  );
                                }

                                // Download files button
                                if (request.files != null && request.files.isNotEmpty) {
                                  items.add(
                                    InfoTileWidget(
                                      onTap: () => _showFilesDialog(request.files),
                                      imgPath: Icons.file_download_outlined,
                                      title: AppStrings.downloadFile.tr(),
                                    ),
                                  );
                                }

                                // Requested to ignore (cancel request) button
                                final reqStatus = (request.status ?? '').toString().toLowerCase().trim();
                                if (request.waitingCancel == true &&
                                    reqStatus != 'canceled' &&
                                    reqStatus != 'cancelled' &&
                                    reqStatus != 'refused') {
                                  items.add(
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
                                  );
                                }

                                final int maxCols = availableWidth > 800 ? 3 : 2;
                                final List<List<Widget>> rows = [];
                                if (maxCols == 2) {
                                  for (int i = 0; i < items.length; i += 2) {
                                    if (i + 1 < items.length) {
                                      rows.add([items[i], items[i + 1]]);
                                    } else {
                                      rows.add([items[i]]);
                                    }
                                  }
                                } else {
                                  if (items.length == 4) {
                                    rows.add([items[0], items[1]]);
                                    rows.add([items[2], items[3]]);
                                  } else if (items.length == 5) {
                                    rows.add([items[0], items[1], items[2]]);
                                    rows.add([items[3], items[4]]);
                                  } else {
                                    for (int i = 0; i < items.length; i += maxCols) {
                                      final end = (i + maxCols < items.length) ? i + maxCols : items.length;
                                      rows.add(items.sublist(i, end));
                                    }
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Date tile with formatting (always full width at top)
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

                                    // Dynamic distributed rows
                                    if (fullWidthTile != null) ...[
                                      const SizedBox(height: spacing),
                                      fullWidthTile,
                                    ],
                                    for (int r = 0; r < rows.length; r++) ...[
                                      const SizedBox(height: spacing),
                                      Row(
                                        children: [
                                          for (int c = 0; c < rows[r].length; c++) ...[
                                            if (c > 0) const SizedBox(width: spacing),
                                            Expanded(child: rows[r][c]),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: kIsWeb ? 24 : 12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
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
                  borderRadius: BorderRadius.circular(AppRadius.xs),
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
    final double? tileWidth = width;

    return GestureDetector(
      onTap: onTap ?? (){},
      child: Container(
        width: tileWidth,
        constraints: const BoxConstraints(minHeight: 38),
        decoration: BoxDecoration(
            color: isHighLight == true ? _imgColor : effectiveBackground,
            borderRadius: BorderRadius.circular(AppRadius.sm)),
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
