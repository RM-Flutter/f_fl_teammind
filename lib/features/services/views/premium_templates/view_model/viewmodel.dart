import 'package:app_test/core/services/crud_operation.dart';
import 'package:flutter/material.dart';
import '../../../models/premium_file.model.dart';

class PremiumFilesViewModel extends ChangeNotifier {
  List<PremiumFileModel>? premiumFiles; // Filtered files (displayed)
  List<PremiumFileModel>? _allFiles; // All files from API (cached)
  List<PremiumFileTypeModel>? fileTypes;
  bool isLoading = false;
  bool isLoadingTypes = false;
  String? errorMessage;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  void updateLoadingStatus({required bool loadingValue}) {
    isLoading = loadingValue;
    notifyListeners();
  }

  /// Fetch premium files from API (only once, without filter)
  Future<void> fetchPremiumFiles({
    required BuildContext context,
    int? itemsCount,
    String? fileType, // This parameter is kept for compatibility but not used
  }) async {
    if (_disposed) return;
    
    // If we already have cached data, don't fetch again
    if (_allFiles != null && _allFiles!.isNotEmpty) {
      premiumFiles = List.from(_allFiles!);
      notifyListeners();
      return;
    }
    
    updateLoadingStatus(loadingValue: true);
    errorMessage = null;

    try {
      // Build query parameters (always fetch all files without filter)
      Map<String, dynamic> queryParams = {};
      
      if (itemsCount != null) {
        queryParams['itemsCount'] = itemsCount;
      }
      
      queryParams['with'] = 'type_id';

      // Call API using CrudOperationService
      final result = await CrudOperationService.readEntities(
        context: context,
        slug: 'files-center-files',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (_disposed) return;

      if (result.success && result.data != null) {
        final data = result.data;
        
        if (data != null && data['data'] != null) {
          final List<dynamic> filesList = data['data'] as List<dynamic>;
          
          // Save all files to cache
          _allFiles = filesList
              .map((item) => PremiumFileModel.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // Set premiumFiles to all files initially
          premiumFiles = List.from(_allFiles!);
          
          updateLoadingStatus(loadingValue: false);
          notifyListeners();
          return;
        }
      }

      // Handle error
      errorMessage = result.message ?? 'Failed to load premium files';
      updateLoadingStatus(loadingValue: false);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      errorMessage = 'Error loading premium files: ${e.toString()}';
      updateLoadingStatus(loadingValue: false);
      notifyListeners();
    }
  }

  /// Apply filter locally (without API call)
  void applyLocalFilter({String? typeId, String? searchText}) {
    if (_allFiles == null || _allFiles!.isEmpty) {
      premiumFiles = [];
      notifyListeners();
      return;
    }

    List<PremiumFileModel> filtered = List.from(_allFiles!);

    // Apply type filter
    if (typeId != null && typeId.isNotEmpty && typeId != 'All') {
      filtered = filtered.where((file) {
        return file.typeId?.toString() == typeId;
      }).toList();
    }

    // Apply search filter
    if (searchText != null && searchText.isNotEmpty) {
      final searchLower = searchText.toLowerCase();
      filtered = filtered.where((file) {
        return (file.title?.toLowerCase().contains(searchLower) ?? false) ||
               (file.description?.toLowerCase().contains(searchLower) ?? false);
      }).toList();
    }

    premiumFiles = filtered;
    notifyListeners();
  }

  /// Fetch file types from API
  Future<void> fetchFileTypes({
    required BuildContext context,
    int? itemsCount,
  }) async {
    if (_disposed) return;
    
    isLoadingTypes = true;
    notifyListeners();

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {};
      
      if (itemsCount != null) {
        queryParams['itemsCount'] = itemsCount;
      }

      // Call API using CrudOperationService
      final result = await CrudOperationService.readEntities(
        context: context,
        slug: 'files-center-types',
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      if (_disposed) return;

      if (result.success && result.data != null) {
        final data = result.data;
        
        if (data != null && data['data'] != null) {
          final List<dynamic> typesList = data['data'] as List<dynamic>;
          
          fileTypes = typesList
              .map((item) => PremiumFileTypeModel.fromJson(item as Map<String, dynamic>))
              .toList();
          
          isLoadingTypes = false;
          notifyListeners();
          return;
        }
      }

      // Handle error
      isLoadingTypes = false;
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      isLoadingTypes = false;
      notifyListeners();
    }
  }
}
