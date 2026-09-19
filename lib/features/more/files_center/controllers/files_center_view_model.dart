import 'package:app_test/features/more/files_center/data/models/files_center_model.dart';
import 'package:app_test/features/more/files_center/data/repos/files_center_repo.dart';
import 'package:flutter/material.dart';

class FilesCenterViewModel extends ChangeNotifier {
  List<FilesCenterModel> _allFiles = [];
  List<FilesCenterModel> _filteredFiles = [];
  List<FilesCenterModel> displayedFiles = [];
  
  List<FilesCenterTypeModel> fileTypes = [];
  
  bool isLoading = false;
  bool isLoadingMore = false;
  bool isLoadingTypes = false;
  String? errorMessage;
  
  // Pagination
  int _currentPage = 1;
  final int _perPage = 10;
  bool hasMore = true;

  // Filters
  String searchQuery = '';
  FilesCenterTypeModel? selectedType;
  String? selectedStatus;

  // Available statuses
  final List<String> availableStatuses = ['free', 'premium', 'private'];

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

  Future<void> initData(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    
    await Future.wait([
      _fetchTypes(context),
      _fetchFiles(context),
    ]);
    
    applyFilters();
    
    isLoading = false;
    notifyListeners();
  }
  
  Future<void> refresh(BuildContext context) async {
    _currentPage = 1;
    await initData(context);
  }

  Future<void> _fetchTypes(BuildContext context) async {
    try {
      final result = await FilesCenterRepo.getTypes(context: context);
      if (result.success && result.data != null) {
        final data = result.data!['types'];
        if (data is List) {
          fileTypes = data
              .map((e) => FilesCenterTypeModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Error fetching files center types: $e");
    }
  }

  Future<void> _fetchFiles(BuildContext context) async {
    try {
      final result = await FilesCenterRepo.getFiles(context: context);
      if (result.success && result.data != null) {
        final data = result.data!['files'];
        if (data is List) {
          _allFiles = data
              .map((e) => FilesCenterModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } else {
        errorMessage = result.message;
      }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("Error fetching files center files: $e");
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query.toLowerCase();
    applyFilters();
  }

  void setTypeFilter(FilesCenterTypeModel? type) {
    selectedType = type;
    applyFilters();
  }

  void setStatusFilter(String? status) {
    selectedStatus = status;
    applyFilters();
  }

  void clearFilters() {
    searchQuery = '';
    selectedType = null;
    selectedStatus = null;
    applyFilters();
  }

  void applyFilters() {
    _filteredFiles = _allFiles.where((file) {
      // 1. Filter by search query (name/description)
      final titleMatch = file.title?.toLowerCase().contains(searchQuery) ?? false;
      final descMatch = file.description?.toLowerCase().contains(searchQuery) ?? false;
      final matchesSearch = searchQuery.isEmpty || titleMatch || descMatch;

      // 2. Filter by type
      final matchesType = selectedType == null || file.typeId == selectedType!.id;

      // 3. Filter by status
      final matchesStatus = selectedStatus == null || file.status == selectedStatus;

      return matchesSearch && matchesType && matchesStatus;
    }).toList();

    // Reset pagination
    _currentPage = 1;
    _paginate();
    notifyListeners();
  }

  void _paginate() {
    final startIndex = 0;
    final endIndex = (_currentPage * _perPage).clamp(0, _filteredFiles.length);
    
    displayedFiles = _filteredFiles.sublist(startIndex, endIndex);
    hasMore = displayedFiles.length < _filteredFiles.length;
  }

  void loadMore() {
    if (isLoadingMore || !hasMore) return;
    
    isLoadingMore = true;
    notifyListeners();

    // Simulate small network delay for smooth UX
    Future.delayed(const Duration(milliseconds: 300), () {
      _currentPage++;
      _paginate();
      isLoadingMore = false;
      notifyListeners();
    });
  }
}
