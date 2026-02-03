import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rmemp/constants/app_colors.dart';
import 'package:rmemp/constants/app_strings.dart';
import 'package:rmemp/general_services/alert_service/alerts.service.dart';
import 'package:rmemp/general_services/bookmark.service.dart';
import 'package:rmemp/models/bookmark.model.dart';
import '../../../../constants/app_sizes.dart';
import '../../../../general_services/backend_services/api_service/dio_api_service/shared.dart';

class BookmarkListWidget extends StatefulWidget {
  const BookmarkListWidget({super.key});

  @override
  State<BookmarkListWidget> createState() => _BookmarkListWidgetState();
}

class _BookmarkListWidgetState extends State<BookmarkListWidget> {
  List<BookmarkModel> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  void _loadBookmarks() {
    setState(() {
      _bookmarks = BookmarkService.getAllBookmarks();
    });
  }

  void _navigateToBookmark(BookmarkModel bookmark) {
    final lang = context.locale.languageCode;
    
    // Extract pathParameters from stateData (like 'id' for details screens)
    final pathParams = <String, String>{'lang': lang};
    if (bookmark.stateData != null) {
      // Filter parameters that should NOT be in pathParameters
      final filterParams = ['reqId', 'empId', 'depId', 'selectStatus', 'from', 'to'];
      
      // Add all stateData entries that are not filter parameters to pathParameters
      bookmark.stateData!.forEach((key, value) {
        if (!filterParams.contains(key) && value != null) {
          pathParams[key] = value.toString();
        }
      });
    }
    
    // Restore filter state for requests screen
    if (bookmark.routeName.contains('requests') || bookmark.routePath?.contains('requests') == true) {
      if (bookmark.stateData != null) {
        // Restore filter data to CacheHelper
        if (bookmark.stateData!['reqId'] != null) {
          CacheHelper.setString(key: "reqId", value: bookmark.stateData!['reqId'].toString());
        }
        if (bookmark.stateData!['empId'] != null) {
          CacheHelper.setString(key: "empId", value: bookmark.stateData!['empId'].toString());
        }
        if (bookmark.stateData!['depId'] != null) {
          CacheHelper.setString(key: "depId", value: bookmark.stateData!['depId'].toString());
        }
        if (bookmark.stateData!['selectStatus'] != null) {
          CacheHelper.setString(key: "selectStatus", value: bookmark.stateData!['selectStatus'].toString());
        }
        if (bookmark.stateData!['from'] != null) {
          CacheHelper.setString(key: "from", value: bookmark.stateData!['from'].toString());
        }
        if (bookmark.stateData!['to'] != null) {
          CacheHelper.setString(key: "to", value: bookmark.stateData!['to'].toString());
        }
      }
    }
    
    // Navigate to the route with saved state
    try {
      context.pushNamed(
        bookmark.routeName,
        pathParameters: pathParams,
        extra: bookmark.stateData,
      );
    } catch (e) {
      // If named route fails, try using path
      if (bookmark.routePath != null) {
        context.push(bookmark.routePath!);
      }
    }
  }

  Future<void> _deleteBookmark(BookmarkModel bookmark) async {
    final confirmed = await AlertsService.confirmMessage(
      context,
      AppStrings.deleteBookmark.tr(),
      message: AppStrings.areYouSureDeleteBookmark.tr(),
    );

    if (confirmed == true) {
      await BookmarkService.deleteBookmark(bookmark.id);
      _loadBookmarks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.bookmarkDeleted.tr()),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  IconData _getIconForRoute(String routeName) {
    // Map route names to icons
    if (routeName.contains('request')) {
      return Icons.request_quote;
    } else if (routeName.contains('task')) {
      return Icons.task;
    } else if (routeName.contains('notification')) {
      return Icons.notifications;
    } else if (routeName.contains('profile') || routeName.contains('employee')) {
      return Icons.person;
    } else if (routeName.contains('payroll')) {
      return Icons.payment;
    } else if (routeName.contains('complain')) {
      return Icons.report_problem;
    } else if (routeName.contains('evaluation')) {
      return Icons.star;
    } else {
      return Icons.bookmark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bookmarks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSizes.s12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s24),
            child: Text(
              AppStrings.myBookmarks.tr(),
              style: TextStyle(
                fontSize: AppSizes.s19,
                fontWeight: FontWeight.w700,
                color: Color(AppColors.dark),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12),
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _bookmarks[index];
                return _buildBookmarkItem(bookmark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkItem(BookmarkModel bookmark) {
    return GestureDetector(
      onTap: () => _navigateToBookmark(bookmark),
      onLongPress: () => _deleteBookmark(bookmark),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.s8),
        padding: const EdgeInsets.all(AppSizes.s12),
        decoration: BoxDecoration(
          color: Color(AppColors.dark),
          borderRadius: BorderRadius.circular(AppSizes.s12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              bookmark.iconName != null
                  ? _getIconByName(bookmark.iconName!)
                  : _getIconForRoute(bookmark.routeName),
              size: 32,
              color: Color(AppColors.white),
            ),
            const SizedBox(height: AppSizes.s8),
            Flexible(
              child: Text(
                bookmark.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconByName(String iconName) {
    // Map icon names to IconData
    switch (iconName.toLowerCase()) {
      case 'request':
      case 'requests':
        return Icons.request_quote;
      case 'task':
      case 'tasks':
        return Icons.task;
      case 'notification':
      case 'notifications':
        return Icons.notifications;
      case 'profile':
      case 'employee':
        return Icons.person;
      case 'payroll':
        return Icons.payment;
      case 'complain':
        return Icons.report_problem;
      case 'evaluation':
        return Icons.star;
      default:
        return Icons.bookmark;
    }
  }
}

