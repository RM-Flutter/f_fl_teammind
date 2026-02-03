import 'dart:convert';
import 'dart:html' if (dart.library.io) '../../../../general_services/dart_html_stub.dart' as html;
import 'dart:io' if (dart.library.html) '../../../../general_services/dart_io_stub.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rmemp/constants/app_constants.dart';
import 'package:rmemp/general_services/app_config.service.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/platform/platform_is.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_strings.dart';
import '../../../../routing/app_router.dart';
import '../../../../common_modules_widgets/app_bar_with_bookmark.widget.dart';
import '../../models/premium_file.model.dart';
import '../premium_templates/view_model/viewmodel.dart';

class SelectTemplateScreen extends StatefulWidget {
  const SelectTemplateScreen({super.key});

  @override
  State<SelectTemplateScreen> createState() => _SelectTemplateScreenState();
}

class _SelectTemplateScreenState extends State<SelectTemplateScreen> {
  late PremiumFilesViewModel viewModel;
  int selectedTemplateIndex = 0;
  bool isLoadingTemplate = false;
  final Map<int, double> _downloadProgress = {};

  @override
  void initState() {
    super.initState();
    viewModel = PremiumFilesViewModel();
    // Fetch templates when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchPremiumFiles(
        context: context,
        itemsCount: 200,
      );
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  void _goBack() {
    try {
      GoRouter.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
    }
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
          title: AppStrings.selectTemplate.tr(),
          titleStyle: TextStyle(
            color: Color(AppColors.dark),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          centerTitle: true,
          routeName: AppRoutes.selectTemplateScreen.name,
        ),
        body: Consumer<PremiumFilesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      viewModel.errorMessage!,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        viewModel.fetchPremiumFiles(
                          context: context,
                          itemsCount: 200,
                        );
                      },
                      child: Text(AppStrings.retry.tr()),
                    ),
                  ],
                ),
              );
            }

            final templates = viewModel.premiumFiles ?? [];

            if (templates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.noDataFounded.tr(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                const SizedBox(height: 16),
                
                // Templates Carousel
                Expanded(
                  child: PageView.builder(
                    itemCount: templates.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectedTemplateIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return _buildTemplateCard(template, index);
                    },
                  ),
                ),
                
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(templates.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selectedTemplateIndex == index
                            ? Color(AppColors.primary)
                            : Colors.grey[400],
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 24),
                
                // Generate CV Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: isLoadingTemplate
                        ? null
                        : () => _generateCVWithTemplate(templates[selectedTemplateIndex]),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(AppColors.dark),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoadingTemplate
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Generate CV with Template',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplateCard(PremiumFileModel template, int index) {
    final imageUrl = template.imageUrl;
    final isSelected = selectedTemplateIndex == index;
    final isDownloading = _downloadProgress.containsKey(template.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: Color(AppColors.primary), width: 3)
            : Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Template Image
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
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
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.grey,
                          ),
                        ),
                ),
              ),
              
              // Template Info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (template.title != null && template.title!.isNotEmpty)
                      Text(
                        template.title!,
                        style: TextStyle(
                          color: Color(AppColors.dark),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (template.description != null && template.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        template.description!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
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
          
          // Download Progress Overlay
          if (isDownloading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress[template.id],
                        backgroundColor: Colors.white.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(AppColors.primary)),
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${((_downloadProgress[template.id] ?? 0) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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

  /// Generate CV with selected template
  Future<void> _generateCVWithTemplate(PremiumFileModel template) async {
    if (template.id == null) {
      Fluttertoast.showToast(
        msg: 'Invalid template',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      isLoadingTemplate = true;
      _downloadProgress[template.id!] = 0.0;
    });

    try {
      // Call API to generate CV with template
      // Use Dio directly to get PDF as bytes
      final dio = Dio();
      final appConfigServiceProvider = Provider.of<AppConfigService>(context, listen: false);
      final deviceUniqueId = appConfigServiceProvider.deviceInformation.deviceUniqueId;
      
      final response = await dio.get(
        "${AppConstants.baseUrl}/emp_requests/v1/cv/print",
        queryParameters: {
          'template_id': template.id,
        },
        options: Options(
          headers: {
            'Accept': 'application/pdf',
            'Authorization': 'Bearer ${appConfigServiceProvider.token}',
            'lang': CacheHelper.getString("lang") ?? "en",
            if (deviceUniqueId.isNotEmpty)
              'device-unique-id': deviceUniqueId,
          },
          responseType: ResponseType.bytes, // Get response as bytes for PDF
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Check if response is PDF (starts with %PDF) or JSON
        final data = response.data as List<int>;
        
        // Check if it's PDF by looking at first few bytes
        if (data.length >= 4 && 
            data[0] == 0x25 && // %
            data[1] == 0x50 && // P
            data[2] == 0x44 && // D
            data[3] == 0x46) { // F
          // It's a PDF, save it directly
          await _savePDFFromBytes(data, template);
        } else {
          // Try to parse as JSON
          try {
            final jsonString = utf8.decode(data);
            final jsonResponse = jsonDecode(jsonString);
            if (jsonResponse['status'] == true) {
              final pdfUrl = jsonResponse['data']?['pdf_url'] ?? jsonResponse['pdf_url'];
              if (pdfUrl != null && pdfUrl.isNotEmpty) {
                await _downloadCVPDF(pdfUrl, template);
              } else {
                throw Exception('PDF URL not found in response');
              }
            } else {
              throw Exception(jsonResponse['message'] ?? 'Failed to generate CV');
            }
          } catch (jsonError) {
            // If not JSON, assume it's PDF and save it
            await _savePDFFromBytes(data, template);
          }
        }
      } else {
        throw Exception('Failed to generate CV: Status code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error generating CV: $e');
      Fluttertoast.showToast(
        msg: 'Error generating CV: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        isLoadingTemplate = false;
        _downloadProgress.remove(template.id);
      });
    }
  }

  /// Save PDF from bytes
  Future<void> _savePDFFromBytes(List<int> pdfBytes, PremiumFileModel template) async {
    final fileName = 'CV_${template.title ?? 'template'}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (PlatformIs.web) {
      try {
        // For web, convert bytes to base64 and create data URL
        final base64String = base64Encode(pdfBytes);
        final dataUrl = 'data:application/pdf;base64,$base64String';
        
        // Create anchor element to trigger download
        final html.AnchorElement downloadAnchor = html.AnchorElement(href: dataUrl);
        downloadAnchor.download = fileName;
        downloadAnchor.style.display = 'none';
        html.document.body?.append(downloadAnchor);
        downloadAnchor.click();
        downloadAnchor.remove();

        Fluttertoast.showToast(
          msg: '✅ CV downloaded successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      } catch (e) {
        debugPrint('Error saving PDF on web: $e');
        Fluttertoast.showToast(
          msg: 'Error saving PDF: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    // Mobile platforms: save to device storage
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      
      await file.writeAsBytes(pdfBytes);
      
      await OpenFile.open(filePath);

      Fluttertoast.showToast(
        msg: '✅ CV saved successfully',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error saving PDF: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  /// Download CV PDF
  Future<void> _downloadCVPDF(String pdfUrl, PremiumFileModel template) async {
    final fileName = 'CV_${template.title ?? 'template'}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (PlatformIs.web) {
      try {
        if (kIsWeb) {
          final fetchResult = html.window.fetch(pdfUrl);
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
            debugPrint('Error downloading PDF: $e');
          });
        } else {
          final uri = Uri.parse(pdfUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }

        Fluttertoast.showToast(
          msg: '✅ CV downloaded successfully',
          backgroundColor: Colors.green,
          textColor: Colors.white,
          toastLength: Toast.LENGTH_LONG,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Error downloading PDF: $e',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
      return;
    }

    // Mobile platforms: download to device storage
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$fileName';

      final dio = Dio();
      await dio.download(
        pdfUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress[template.id!] = received / total;
            });
          }
        },
      );

      await OpenFile.open(filePath);

      Fluttertoast.showToast(
        msg: '✅ CV downloaded successfully',
        backgroundColor: Colors.green,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error downloading PDF: $e',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
