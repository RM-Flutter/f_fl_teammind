import 'dart:io' if (dart.library.html) 'directory_stub.dart' as io;
import 'dart:html' if (dart.library.io) 'dart_html_stub.dart' as html;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../general_services/layout.service.dart';
import '../../../../platform/platform_is.dart';
import '../../../../constants/app_strings.dart';

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

  Future<bool> requestStoragePermission() async {
    if (PlatformIs.web) return true;

    if (PlatformIs.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
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
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
          if (!status.isGranted) return false;
        }
        return true;
      }
      return true;
    }
    return true; // iOS
  }

  Future<dynamic> _getDownloadDirectory() async {
    if (kIsWeb || PlatformIs.web) {
      throw UnsupportedError("Download directory not available on Web");
    }

    if (PlatformIs.android) {
      final io.Directory directory = io.Directory('/storage/emulated/0/Download');
      if (await directory.exists()) return directory;
      throw Exception("Download directory not found");
    } else if (PlatformIs.iOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  Future<void> _downloadFile(String url, String fileName) async {
    if (PlatformIs.web) {
      try {
        final anchor = html.AnchorElement(href: url)
          ..download = fileName
          ..click();
        Fluttertoast.showToast(
          msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error downloading file: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    final dio = Dio();
    try {
      final dir = await _getDownloadDirectory();
      final filePath = '${dir.path}/$fileName';

      setState(() {
        _downloadingFileName = fileName;
        _downloadProgress = 0.0;
      });

      await dio.download(url, filePath, onReceiveProgress: (received, total) {
        if (total != -1) {
          setState(() => _downloadProgress = received / total);
        }
      });

      await OpenFilex.open(filePath);

      Fluttertoast.showToast(
        msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: '$e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _downloadProgress = 0.0;
        _downloadingFileName = null;
      });
    }
  }

  Future<void> _downloadAllFiles(List files) async {
    if (files.isEmpty) return;

    final granted = await requestStoragePermission();
    if (!granted) {
      Fluttertoast.showToast(msg: 'Storage permission is required.');
      return;
    }

    for (var file in files) {
      final fileUrl = file.file;
      final fileName = fileUrl.split('/').last;
      await _downloadFile(fileUrl, fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final mainColor = Color(AppColors.blue);

    return Stack(
      children: [
        // Main header container (with AppBar & tiles)
        Container(
          height: widget.height,
          width: LayoutService.getWidth(context),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Color(AppColors.dark),
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: kIsWeb ? 1100 : double.infinity),
              child: Column(
                children: [
                  AppBarWithBookmark(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    routeName: '',
                    defaultTitle: '',
                    title: '',
                    titleStyle: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(color: Colors.white),
                    bookmarkIconColor: Colors.white,
                    leading: Padding(
                      padding: const EdgeInsets.all(AppSizes.s10),
                      child: InkWell(
                        onTap: () {
                          if (context.canPop()) context.pop();
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
                  // Info tiles row
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
                      child: Wrap(
                        spacing: AppSizes.s5,
                        runSpacing: AppSizes.s5,
                        children: [
                          if (request.files != null && request.files.isNotEmpty)
                            InfoTileWidget(
                              onTap: () => _downloadAllFiles(request.files),
                              imgPath: Icons.file_download_outlined,
                              title: AppStrings.downloadFile.tr(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Download progress overlay (only shows on Mobile)
        if (_downloadProgress > 0 && _downloadingFileName != null && !kIsWeb)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 6,
              color: Colors.black87,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
}

// InfoTileWidget كما هو، بدون تعديل
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

  InfoTileWidget({
    super.key,
    this.isHighLight = false,
    this.isFullRow = false,
    required this.imgPath,
    this.width,
    this.onTap,
    required this.title,
    this.background = const Color(AppColors.navyBlue),
    this.trailing,
    this.imgColor,
  });

  Color get _imgColor => imgColor ?? Color(AppColors.blue);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: width != null
            ? width
            : isFullRow == false
            ? (LayoutService.getWidth(context) - AppSizes.s88) / 2
            : null,
        decoration: BoxDecoration(
            color: isHighLight == true ? _imgColor : background,
            borderRadius: BorderRadius.circular(AppSizes.s6)),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: AppSizes.s6, vertical: AppSizes.s6),
                child: Row(
                  children: [
                    Icon(imgPath, color: isHighLight == true ? Color(AppColors.white) : _imgColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AutoSizeText(
                        title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: AppSizes.s10, fontWeight: FontWeight.w400),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isFullRow == true && trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
