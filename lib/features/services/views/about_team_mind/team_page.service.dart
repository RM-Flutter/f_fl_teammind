import 'package:flutter/material.dart';

import '../../../../core/services/backend_services/api_service/dio_api_service/dio.dart';

/// Response from GET /rm_page/v1/show?slug=get-team-page
class TeamPageResponse {
  final bool status;
  final String? message;
  final TeamPage? page;

  TeamPageResponse({
    required this.status,
    this.message,
    this.page,
  });

  factory TeamPageResponse.fromJson(Map<String, dynamic> json) {
    return TeamPageResponse(
      status: json['status'] == true,
      message: json['message']?.toString(),
      page: json['page'] != null
          ? TeamPage.fromJson(Map<String, dynamic>.from(json['page'] as Map))
          : null,
    );
  }
}

class TeamPage {
  final int? id;
  final String? title;
  final String? content;
  final String? type;
  final List<TeamPageImage> images;
  final String? videoUrl;

  TeamPage({
    this.id,
    this.title,
    this.content,
    this.type,
    required this.images,
    this.videoUrl,
  });

  factory TeamPage.fromJson(Map<String, dynamic> json) {
    final imagesList = json['images'] as List<dynamic>?;
    return TeamPage(
      id: json['id'] as int?,
      title: json['title']?.toString(),
      content: json['content']?.toString(),
      type: json['type']?.toString(),
      images: imagesList != null
          ? imagesList
              .map((e) => TeamPageImage.fromJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList()
          : [],
      videoUrl: json['video_url']?.toString(),
    );
  }
}

class TeamPageImage {
  final int? id;
  final String? type;
  final String? title;
  final String? alt;
  final String? file;
  final String? thumbnail;

  TeamPageImage({
    this.id,
    this.type,
    this.title,
    this.alt,
    this.file,
    this.thumbnail,
  });

  factory TeamPageImage.fromJson(Map<String, dynamic> json) {
    return TeamPageImage(
      id: json['id'] as int?,
      type: json['type']?.toString(),
      title: json['title']?.toString(),
      alt: json['alt']?.toString(),
      file: json['file']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}

class TeamPageService {
  static const String _path = '/rm_page/v1/show';

  static Future<TeamPageResponse> getTeamPage(BuildContext context) async {
    final response = await DioHelper.getData(
      url: _path,
      context: context,
      query: {'slug': 'get-team-page'},
    );
    final data = response.data is Map
        ? Map<String, dynamic>.from(response.data as Map)
        : <String, dynamic>{};
    return TeamPageResponse.fromJson(data);
  }
}
