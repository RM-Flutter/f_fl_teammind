import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_images.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/platform/platform_is.dart';
import 'package:app_test/core/widgets/app_bar_with_bookmark.widget.dart';
import 'package:app_test/features/more/files_center/controllers/files_center_view_model.dart';
import 'package:app_test/features/more/files_center/data/models/files_center_model.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_sizes.dart';

class FilesCenterScreen extends StatefulWidget {
  const FilesCenterScreen({super.key});

  @override
  State<FilesCenterScreen> createState() => _FilesCenterScreenState();
}

class _FilesCenterScreenState extends State<FilesCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  late FilesCenterViewModel viewModel;
  
  final Map<int, double> _downloadProgress = {};
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    viewModel = FilesCenterViewModel();
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        viewModel.loadMore();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.initData(context);
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    String? tempSelectedStatus = viewModel.selectedStatus;
    FilesCenterTypeModel? tempSelectedType = viewModel.selectedType;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            List<DropdownMenuItem<String>> typeItems = [
              DropdownMenuItem(
                value: 'All',
                child: Text(AppStrings.all.tr(), style: const TextStyle(color: Colors.black, fontSize: 14)),
              ),
            ];
            
            if (viewModel.fileTypes.isNotEmpty) {
              typeItems.addAll(
                viewModel.fileTypes.map((type) {
                  return DropdownMenuItem(
                    value: type.id.toString(),
                    child: Text((type.title ?? '').tr(), style: const TextStyle(color: Colors.black, fontSize: 14)),
                  );
                }),
              );
            }

            List<DropdownMenuItem<String>> statusItems = [
              DropdownMenuItem(
                value: 'All',
                child: Text(AppStrings.all.tr(), style: const TextStyle(color: Colors.black, fontSize: 14)),
              ),
              ...viewModel.availableStatuses.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.tr().toUpperCase(), style: const TextStyle(color: Colors.black, fontSize: 14)),
              ))
            ];

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                  Text(AppStrings.filter.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Status Filter
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text("status".tr(), style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: tempSelectedStatus ?? 'All',
                        items: statusItems,
                        onChanged: (value) {
                          setModalState(() {
                            tempSelectedStatus = value == 'All' ? null : value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Type Filter
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(AppStrings.type.tr(), style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: tempSelectedType?.id.toString() ?? 'All',
                        items: typeItems,
                        onChanged: (value) {
                          setModalState(() {
                            if (value == 'All') {
                              tempSelectedType = null;
                            } else {
                              tempSelectedType = viewModel.fileTypes.firstWhere((t) => t.id.toString() == value);
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(AppColors.buttons),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        viewModel.selectedStatus = tempSelectedStatus;
                        viewModel.selectedType = tempSelectedType;
                        viewModel.applyFilters();
                        Navigator.pop(context);
                      },
                      child: Text(AppStrings.applied.tr(), style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _downloadFile(FilesCenterModel file) async {
    final fileUrl = file.fileUrl;
    if (fileUrl == null || fileUrl.isEmpty) {
      Fluttertoast.showToast(msg: "No file URL available");
      return;
    }

    if (PlatformIs.web) {
      try {
        final uri = Uri.parse(fileUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          Fluttertoast.showToast(msg: "Could not open file URL");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error opening file: $e");
      }
      return;
    }

    try {
      final fileId = file.id ?? 0;
      setState(() {
        _downloadProgress[fileId] = 0.0;
      });

      bool hasPermission = false;
      if (PlatformIs.android) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          hasPermission = true;
        } else {
          final status = await Permission.storage.request();
          hasPermission = status.isGranted;
        }
      } else if (PlatformIs.iOS) {
        hasPermission = true;
      }

      if (!hasPermission) {
        Fluttertoast.showToast(msg: "Storage permission required");
        setState(() { _downloadProgress.remove(fileId); });
        return;
      }

      final fileName = file.title ?? 'file_${DateTime.now().millisecondsSinceEpoch}';
      final fileTypeStr = file.fileType ?? 'pdf';
      final fullFileName = '$fileName.$fileTypeStr';

      dynamic directory;
      if (PlatformIs.android) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception("Could not access local storage");
      }

      final savePath = '${directory.path}/$fullFileName';
      
      final dio = Dio();
      await dio.download(
        fileUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress[fileId] = received / total;
            });
          }
        },
      );

      Fluttertoast.showToast(msg: "File downloaded to $savePath");
      await OpenFilex.open(savePath);

    } catch (e) {
      Fluttertoast.showToast(msg: "Error downloading file: $e");
    } finally {
      if (mounted) {
        setState(() {
          _downloadProgress.remove(file.id ?? 0);
        });
      }
    }
  }

  Widget _getFileTypeIcon(String? type) {
    final color = Color(AppColors.buttons);
    if (type == null) return Icon(Icons.insert_drive_file, color: color, size: 30);
    
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: color, size: 30);
      case 'doc':
      case 'docx':
        return Icon(Icons.description, color: color, size: 30);
      case 'xls':
      case 'xlsx':
        return Icon(Icons.table_chart, color: color, size: 30);
      case 'ppt':
      case 'pptx':
        return Icon(Icons.slideshow, color: color, size: 30);
      case 'zip':
      case 'rar':
        return Icon(Icons.folder_zip, color: color, size: 30);
      default:
        return Icon(Icons.insert_drive_file, color: color, size: 30);
    }
  }

  Widget _buildFileCard(FilesCenterModel file) {
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
                // Image/Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: isImage && imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[100],
                              child: Icon(Icons.broken_image, color: Colors.grey[400], size: 30),
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Color(AppColors.buttons)),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Color(AppColors.buttons).withValues(alpha: 0.1),
                            child: _getFileTypeIcon(fileType),
                          ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status Badge
                      if (file.status != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: file.status == 'premium' 
                                ? Colors.amber.withValues(alpha: 0.2) 
                                : file.status == 'private' 
                                  ? Colors.red.withValues(alpha: 0.1) 
                                  : Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            file.status!.tr().toUpperCase(),
                            style: TextStyle(
                              color: file.status == 'premium' 
                                  ? Colors.amber[800] 
                                  : file.status == 'private' 
                                    ? Colors.red 
                                    : Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      // Title
                      if (file.title != null && file.title!.isNotEmpty) ...[
                        Text(
                          file.title!,
                          style: TextStyle(
                            color: Color(AppColors.secondaryButton),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      // Description
                      if (file.description != null && file.description!.isNotEmpty) ...[
                        Text(
                          file.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Download icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Color(AppColors.buttons).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    color: Color(AppColors.buttons),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          if (isDownloading)
            Positioned.fill(
              bottom: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          value: progress > 0 ? progress : null,
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.buttons)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: Color(AppColors.buttons),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<FilesCenterViewModel>.value(
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
                color: Color(AppColors.secondaryButton),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: 'files_center'.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.secondaryButton),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: 'filesCenter',
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: viewModel.setSearchQuery,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: AppStrings.searchByName.tr(),
                          fillColor: Color(AppColors.buttons).withValues(alpha: 0.05),
                          suffixIcon: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchController.clear();
                                viewModel.setSearchQuery('');
                              }
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(AppSizes.s8)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _showFilterBottomSheet,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Image.asset(
                        AppImages.profileFilter,
                        width: AppSizes.s22,
                        height: AppSizes.s22,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      _searchController.clear();
                      viewModel.clearFilters();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Text(
                        AppStrings.clear.tr(),
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Consumer<FilesCenterViewModel>(
                builder: (context, vm, child) {
                  if (vm.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (vm.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            vm.errorMessage!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => vm.refresh(context),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (vm.displayedFiles.isEmpty) {
                    return Center(
                      child: Text(
                        AppStrings.noDataFounded.tr(),
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => vm.refresh(context),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vm.displayedFiles.length + (vm.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == vm.displayedFiles.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return _buildFileCard(vm.displayedFiles[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
