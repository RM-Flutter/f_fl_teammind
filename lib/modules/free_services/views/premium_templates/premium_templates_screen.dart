import 'dart:io' if (dart.library.html) 'directory_stub.dart' as io;
import 'dart:html' if (dart.library.io) 'dart_html_stub.dart' as html;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_images.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../models/premium_file.model.dart';
import 'view_model/viewmodel.dart';
import 'widgets/premium_templates_loading.widget.dart';

class PremiumTemplatesScreen extends StatefulWidget {
  const PremiumTemplatesScreen({super.key});

  @override
  State<PremiumTemplatesScreen> createState() => _PremiumTemplatesScreenState();
}

class _PremiumTemplatesScreenState extends State<PremiumTemplatesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedFileType;
  late PremiumFilesViewModel viewModel;
  // Track download progress for each file (fileId -> progress 0.0 to 1.0)
  final Map<int, double> _downloadProgress = {};
  final Map<int, String> _downloadingFileNames = {};


  @override
  void initState() {
    super.initState();
    viewModel = PremiumFilesViewModel();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch file types first
      viewModel.fetchFileTypes(
        context: context,
        itemsCount: 200,
      );
      // Then fetch premium files
      viewModel.fetchPremiumFiles(
        context: context,
        itemsCount: 200,
      );
    });
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Build dropdown items using viewModel directly
            List<DropdownMenuItem<String>> items = [
              const DropdownMenuItem(
                value: 'All',
                child: Text('All', style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400)),
              ),
            ];
            
            if (viewModel.fileTypes != null && viewModel.fileTypes!.isNotEmpty) {
              items.addAll(
                viewModel.fileTypes!.map((type) {
                  return DropdownMenuItem(
                    value: type.title ?? '',
                    child: Text(
                      type.title ?? '',
                      style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                    ),
                  );
                }).toList(),
              );
            }
            
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  Text(
                    AppStrings.filter.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff09051C),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // File Type Dropdown
                  SizedBox(
                    height: 50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: Text(
                            AppStrings.fileType.tr(),
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                          value: selectedFileType,
                          items: items,
                          onChanged: (value) {
                            setModalState(() {
                              selectedFileType = value;
                            });
                            setState(() {
                              selectedFileType = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Filter Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _applyFilter();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.dark),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(150, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(AppStrings.filter.tr(), style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _applyFilter() {
    // Apply filter locally (without API call)
    // Convert selected type title to type_id if needed
    String? typeId;
    if (selectedFileType != null && selectedFileType != 'All' && viewModel.fileTypes != null) {
      try {
        final selectedType = viewModel.fileTypes!.firstWhere(
          (type) => type.title == selectedFileType,
        );
        typeId = selectedType.id?.toString();
      } catch (e) {
        // Type not found, use null to show all
        typeId = null;
      }
    }
    
    // Apply local filter with type and search
    viewModel.applyLocalFilter(
      typeId: typeId,
      searchText: _searchController.text,
    );
  }

  void _onSearchChanged(String value) {
    // Apply local filter when search text changes
    String? typeId;
    if (selectedFileType != null && selectedFileType != 'All' && viewModel.fileTypes != null) {
      try {
        final selectedType = viewModel.fileTypes!.firstWhere(
          (type) => type.title == selectedFileType,
        );
        typeId = selectedType.id?.toString();
      } catch (e) {
        typeId = null;
      }
    }
    
    viewModel.applyLocalFilter(
      typeId: typeId,
      searchText: value,
    );
  }

  List<PremiumFileModel> _getFilteredFiles() {
    // Return the already filtered files from viewModel
    if (viewModel.premiumFiles == null) return [];
    return viewModel.premiumFiles!;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PremiumFilesViewModel>.value(
      value: viewModel,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarWithBookmark(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(AppColors.dark),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: _goBack,
          ),
          title: AppStrings.premiumTemplates2.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.dark),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: AppRoutes.premiumTemplatesScreen.name,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: AppStrings.searchByName.tr(),
                          fillColor:
                          Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: (){
                                _searchController.clear();
                                _onSearchChanged('');
                              }
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(AppSizes.s8)),
                    ),
                  ),

                  IconButton(
                    icon: Image.asset(
                      AppImages.profileFilter,
                      width: AppSizes.s22,
                      height: AppSizes.s22,
                      fit: BoxFit.cover,
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                ],
              ),
            ),
            
            // Templates List
            Expanded(
              child: Consumer<PremiumFilesViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const PremiumTemplatesLoadingWidget();
                  }

                  if (viewModel.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.errorMessage!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              viewModel.fetchPremiumFiles(
                                context: context,
                                itemsCount: 200,
                                fileType: selectedFileType,
                              );
                            },
                            child: Text(AppStrings.retry.tr()),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredFiles = _getFilteredFiles();

                  if (filteredFiles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noDataFounded.tr(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      return _buildTemplateCard(filteredFiles[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(PremiumFileModel file) {
    final imageUrl = file.imageUrl;
    final fileType = file.fileType;
    final isImage = file.isImage;
    final fileId = file.id ?? 0;
    final isDownloading = _downloadProgress.containsKey(fileId);
    final progress = _downloadProgress[fileId] ?? 0.0;
    
    return InkWell(
      onTap: isDownloading ? null : () => _downloadFile(file),
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Template Image/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Color(AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isImage && imageUrl != null && imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Color(AppColors.primary),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Color(AppColors.primary),
                              child: const Icon(
                                Icons.image,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          )
                        : Container(
                            color: Color(AppColors.primary),
                            child: _getFileTypeIcon(fileType),
                          ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Template Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Type
                      if (file.type?.title != null) ...[
                        Text(
                          file.type!.title!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Title
                      if (file.title != null && file.title!.isNotEmpty) ...[
                        Text(
                          file.title!,
                          style: TextStyle(
                            color: Color(AppColors.dark),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      // Description
                      if (file.description != null && file.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          file.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Download Progress Overlay
          if (isDownloading)
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.primary)),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_downloadingFileNames.containsKey(fileId)) ...[
                        const SizedBox(height: 4),
                        Text(
                          _downloadingFileNames[fileId]!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getFileTypeIcon(String? fileType) {
    if (fileType == null) {
      return const Icon(
        Icons.insert_drive_file,
        color: Colors.white,
        size: 30,
      );
    }

    final type = fileType.toLowerCase();
    
    if (type == 'pdf') {
      return const Icon(
        Icons.picture_as_pdf,
        color: Colors.white,
        size: 30,
      );
    } else if (type == 'doc' || type == 'docx') {
      return const Icon(
        Icons.description,
        color: Colors.white,
        size: 30,
      );
    } else if (type == 'xls' || type == 'xlsx') {
      return const Icon(
        Icons.table_chart,
        color: Colors.white,
        size: 30,
      );
    } else if (type == 'ppt' || type == 'pptx') {
      return const Icon(
        Icons.slideshow,
        color: Colors.white,
        size: 30,
      );
    } else if (type == 'zip' || type == 'rar') {
      return const Icon(
        Icons.folder_zip,
        color: Colors.white,
        size: 30,
      );
    } else {
      return const Icon(
        Icons.insert_drive_file,
        color: Colors.white,
        size: 30,
      );
    }
  }

  /// Request storage permission based on Android version
  Future<bool> _requestStoragePermission() async {
    if (PlatformIs.web) {
      return true;
    }
    
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
      } else {
        return true;
      }
    }
    return true;
  }

  /// Get appropriate download directory
  Future<dynamic> _getDownloadDirectory() async {
    if (kIsWeb || PlatformIs.web) {
      throw UnsupportedError("Download directory not available on web");
    }
    
    if (!kIsWeb) {
      if (PlatformIs.android) {
        final io.Directory directory = io.Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory;
        } else {
          throw Exception("Download directory not found");
        }
      } else if (PlatformIs.iOS) {
        return await getApplicationDocumentsDirectory();
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
    throw UnsupportedError("Download directory not available on web");
  }

  /// Download file
  Future<void> _downloadFile(PremiumFileModel file) async {
    final fileUrl = file.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) {
      Fluttertoast.showToast(
        msg: AppStrings.noDataFounded.tr(),
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final fileName = fileUrl.split('/').last;
    if (fileName.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Invalid file name',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final fileId = file.id ?? 0;
    
    // Initialize download progress
    setState(() {
      _downloadProgress[fileId] = 0.0;
      _downloadingFileNames[fileId] = fileName;
    });

    // On web, download the file
    if (PlatformIs.web) {
      try {
        if (kIsWeb) {
          final fetchResult = html.window.fetch(fileUrl);
          fetchResult.then((response) {
            return (response as dynamic).blob();
          }).then((blob) {
            final blobUrl = html.Url.createObjectUrlFromBlob(blob as dynamic);
            final html.AnchorElement downloadAnchor = html.AnchorElement(href: blobUrl);
            downloadAnchor.download = fileName;
            downloadAnchor.style.display = 'none';
            html.document.body?.append(downloadAnchor);
            downloadAnchor.click();
            downloadAnchor.remove();
            html.Url.revokeObjectUrl(blobUrl);
          }).catchError((e) {
            debugPrint('Error downloading file: $e');
          });
        } else {
          // For non-web platforms, just open the URL
          final uri = Uri.parse(fileUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        
        await Future.delayed(const Duration(milliseconds: 200));
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        
        setState(() {
          _downloadProgress.remove(fileId);
          _downloadingFileNames.remove(fileId);
        });
        
        Fluttertoast.showToast(
          msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 3,
        );
      } catch (e) {
        setState(() {
          _downloadProgress.remove(fileId);
          _downloadingFileNames.remove(fileId);
        });
        Fluttertoast.showToast(
          msg: 'Error downloading file: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      }
      return;
    }

    // Mobile platforms: download to device storage
    final permissionGranted = await _requestStoragePermission();
    if (!permissionGranted) {
      setState(() {
        _downloadProgress.remove(fileId);
        _downloadingFileNames.remove(fileId);
      });
      Fluttertoast.showToast(
        msg: 'Storage permission is required to download files.',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    final dio = Dio();

    try {
      final dir = await _getDownloadDirectory();
      final filePath = '${dir.path}/$fileName';

      await dio.download(
        fileUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress[fileId] = received / total;
            });
          }
        },
      );
      
      await OpenFile.open(filePath);
      
      setState(() {
        _downloadProgress.remove(fileId);
        _downloadingFileNames.remove(fileId);
      });
      
      Fluttertoast.showToast(
        msg: '✅ ${AppStrings.downloaded.tr()}: $fileName',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      setState(() {
        _downloadProgress.remove(fileId);
        _downloadingFileNames.remove(fileId);
      });
      Fluttertoast.showToast(
        msg: 'Error downloading file: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}
