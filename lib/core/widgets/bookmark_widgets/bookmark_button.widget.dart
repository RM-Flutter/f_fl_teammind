import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../models/book_mark_model.dart';
import '../../services/backend_services/api_service/dio_api_service/shared.dart';
import '../../services/bookmark_service.dart';

class BookmarkButton extends StatefulWidget {
  final String routeName;
  final String? routePath;
  final String defaultTitle;
  final String? iconName;
  final Map<String, dynamic>? stateData;
  final VoidCallback? onBookmarkSaved;
  final Color? iconColor;

  const BookmarkButton({
    super.key,
    required this.routeName,
    this.routePath,
    required this.defaultTitle,
    this.iconName,
    this.stateData,
    this.onBookmarkSaved,
    this.iconColor,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic>? _getCurrentStateData() {
    // Start with provided stateData
    Map<String, dynamic>? finalStateData = widget.stateData;
    
    // Get current route state to access pathParameters
    final routerState = GoRouterState.of(context);
    final pathParams = routerState.pathParameters;
    
    // Collect pathParameters (like 'id') for details screens
    if (pathParams.isNotEmpty) {
      finalStateData ??= {};
      // Add all pathParameters to stateData
      pathParams.forEach((key, value) {
        if (value.isNotEmpty) {
          finalStateData![key] = value;
        }
      });
    }
    
    // Collect filter state for requests screen
    if (widget.routeName.contains('requests') || widget.routePath?.contains('requests') == true) {
      finalStateData ??= {};
      // Collect filter data from CacheHelper
      final reqId = CacheHelper.getString("reqId");
      final empId = CacheHelper.getString("empId");
      final depId = CacheHelper.getString("depId");
      final selectStatus = CacheHelper.getString("selectStatus");
      final from = CacheHelper.getString("from");
      final to = CacheHelper.getString("to");
      
      if (reqId.isNotEmpty) finalStateData['reqId'] = reqId;
      if (empId.isNotEmpty) finalStateData['empId'] = empId;
      if (depId.isNotEmpty) finalStateData['depId'] = depId;
      if (selectStatus.isNotEmpty) finalStateData['selectStatus'] = selectStatus;
      if (from.isNotEmpty) finalStateData['from'] = from;
      if (to.isNotEmpty) finalStateData['to'] = to;
      
      debugPrint('🔖 BookmarkButton - Route: ${widget.routeName}, Filter State: $finalStateData');
    }
    
    debugPrint('🔖 BookmarkButton - Route: ${widget.routeName}, PathParams: $pathParams, Final State: $finalStateData');
    return finalStateData;
  }


  Future<void> _showBookmarkDialog() async {
    final controller = TextEditingController(text: widget.defaultTitle);
    final finalStateData = _getCurrentStateData();
    final isBookmarked = BookmarkService.bookmarkExists(
      widget.routeName,
      finalStateData,
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          isBookmarked
              ? AppStrings.editBookmark.tr()
              : AppStrings.addBookmark.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(AppColors.titleText),
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppStrings.bookmarkNameHint.tr(),
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          if (isBookmarked)
            TextButton(
              onPressed: () async {
                // Delete bookmark
                final finalStateData = _getCurrentStateData();
                final bookmark = BookmarkService.getAllBookmarks().firstWhere(
                  (b) =>
                      b.routeName == widget.routeName &&
                      _compareStateData(b.stateData, finalStateData),
                );
                await BookmarkService.deleteBookmark(bookmark.id);
                if (context.mounted) {
                  Navigator.of(ctx).pop(false);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppStrings.bookmarkDeleted.tr()),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                AppStrings.deleteBookmark.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: Text(AppStrings.cancel.tr(), style: TextStyle(color: Color(AppColors.secondaryButton), fontSize: 16),),
          ),
          TextButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                Navigator.of(ctx).pop(true);
              }
            },
            child: Text(
              AppStrings.confirm.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      await _saveBookmark(controller.text.trim());
    }
  }

  Future<void> _saveBookmark(String title) async {
    // Collect filter state for requests screen at save time
    final finalStateData = _getCurrentStateData();
    final isCurrentlyBookmarked = BookmarkService.bookmarkExists(
      widget.routeName,
      finalStateData,
    );
    
    final bookmark = BookmarkModel(
      id: isCurrentlyBookmarked
          ? BookmarkService.getAllBookmarks()
              .firstWhere((b) =>
                  b.routeName == widget.routeName &&
                  _compareStateData(b.stateData, finalStateData))
              .id
          : BookmarkService.generateId(),
      routeName: widget.routeName,
      routePath: widget.routePath ?? GoRouterState.of(context).uri.toString(),
      title: title.isEmpty ? widget.defaultTitle : title,
      iconName: widget.iconName,
      stateData: finalStateData,
      createdAt: isCurrentlyBookmarked
          ? BookmarkService.getAllBookmarks()
              .firstWhere((b) =>
                  b.routeName == widget.routeName &&
                  _compareStateData(b.stateData, finalStateData))
              .createdAt
          : DateTime.now(),
    );

    final success = await BookmarkService.saveBookmark(bookmark);
    if (mounted) {
      if (success) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.bookmarkSaved.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onBookmarkSaved?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.bookmarkSaveError.tr()),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recheck bookmark status in build to reflect current filter state
    final finalStateData = _getCurrentStateData();
    final isCurrentlyBookmarked = BookmarkService.bookmarkExists(
      widget.routeName,
      finalStateData,
    );
    
    debugPrint('🔖 BookmarkButton - Route: ${widget.routeName}, IsBookmarked: $isCurrentlyBookmarked, StateData: $finalStateData');
    
    // Use custom icon color if provided, otherwise use default colors
    final defaultColor = isCurrentlyBookmarked
        ? Color(AppColors.buttons)
        : Color(AppColors.titleText);
    final iconColorToUse = widget.iconColor ?? defaultColor;
    
    return IconButton(
      icon: Icon(
        isCurrentlyBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: iconColorToUse,
      ),
      onPressed: _showBookmarkDialog,
      tooltip: isCurrentlyBookmarked
          ? AppStrings.editBookmark.tr()
          : AppStrings.addBookmark.tr(),
    );
  }

  bool _compareStateData(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return jsonEncode(a) == jsonEncode(b);
  }
}

