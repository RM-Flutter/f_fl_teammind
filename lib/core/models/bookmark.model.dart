import 'dart:convert';

class BookmarkModel {
  final String id;
  final String routeName;
  final String? routePath;
  final String title;
  final String? iconName;
  final Map<String, dynamic>? stateData; // Filters, scroll position, etc.
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.routeName,
    this.routePath,
    required this.title,
    this.iconName,
    this.stateData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeName': routeName,
      'routePath': routePath,
      'title': title,
      'iconName': iconName,
      'stateData': stateData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      routeName: json['routeName'] as String,
      routePath: json['routePath'] as String?,
      title: json['title'] as String,
      iconName: json['iconName'] as String?,
      stateData: json['stateData'] != null
          ? Map<String, dynamic>.from(json['stateData'] as Map)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory BookmarkModel.fromJsonString(String jsonString) {
    return BookmarkModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }
}

