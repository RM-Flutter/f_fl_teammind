import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rmemp/general_services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:rmemp/models/bookmark.model.dart';
import 'package:uuid/uuid.dart';

class BookmarkService {
  static const String _bookmarksCacheKey = "saved_bookmarks";
  static const _uuid = Uuid();

  /// Get all bookmarks
  static List<BookmarkModel> getAllBookmarks() {
    final bookmarksJson = CacheHelper.getString(_bookmarksCacheKey);
    if (bookmarksJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> bookmarksList = jsonDecode(bookmarksJson);
      return bookmarksList
          .map((e) => BookmarkModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      return [];
    }
  }

  /// Save bookmark
  static Future<bool> saveBookmark(BookmarkModel bookmark) async {
    try {
      final bookmarks = getAllBookmarks();
      
      // Check if bookmark with same route and state already exists
      final existingIndex = bookmarks.indexWhere((b) => 
        b.routeName == bookmark.routeName &&
        compareStateData(b.stateData, bookmark.stateData)
      );
      
      if (existingIndex != -1) {
        // Update existing bookmark
        bookmarks[existingIndex] = bookmark;
      } else {
        // Add new bookmark
        bookmarks.add(bookmark);
      }

      final bookmarksJson = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
      await CacheHelper.setString(key: _bookmarksCacheKey, value: bookmarksJson);
      return true;
    } catch (e) {
      debugPrint('Error saving bookmark: $e');
      return false;
    }
  }

  /// Delete bookmark
  static Future<bool> deleteBookmark(String bookmarkId) async {
    try {
      final bookmarks = getAllBookmarks();
      bookmarks.removeWhere((b) => b.id == bookmarkId);
      
      final bookmarksJson = jsonEncode(bookmarks.map((b) => b.toJson()).toList());
      await CacheHelper.setString(key: _bookmarksCacheKey, value: bookmarksJson);
      return true;
    } catch (e) {
      debugPrint('Error deleting bookmark: $e');
      return false;
    }
  }

  /// Check if bookmark exists for current route and state
  static bool bookmarkExists(String routeName, Map<String, dynamic>? stateData) {
    final bookmarks = getAllBookmarks();
    return bookmarks.any((b) => 
      b.routeName == routeName &&
      compareStateData(b.stateData, stateData)
    );
  }

  /// Get bookmark by ID
  static BookmarkModel? getBookmarkById(String bookmarkId) {
    final bookmarks = getAllBookmarks();
    try {
      return bookmarks.firstWhere((b) => b.id == bookmarkId);
    } catch (e) {
      return null;
    }
  }

  /// Generate unique ID
  static String generateId() => _uuid.v4();

  /// Compare state data
  static bool compareStateData(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    
    // Simple comparison - can be enhanced for deep comparison
    return jsonEncode(a) == jsonEncode(b);
  }
}

