class FilesCenterTypeModel {
  final int? id;
  final String? title;

  FilesCenterTypeModel({
    this.id,
    this.title,
  });

  factory FilesCenterTypeModel.fromJson(Map<String, dynamic> json) {
    return FilesCenterTypeModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
    };
  }
}

class FilesCenterModel {
  final int? id;
  final String? title;
  final String? description;
  final String? displayName;
  final String? previewImage;
  final String? fileUrl;
  final String? downloadUrl;
  final String? typeTitle;
  final int? typeId;
  final String? status;

  FilesCenterModel({
    this.id,
    this.title,
    this.description,
    this.displayName,
    this.previewImage,
    this.fileUrl,
    this.downloadUrl,
    this.typeTitle,
    this.typeId,
    this.status,
  });

  factory FilesCenterModel.fromJson(Map<String, dynamic> json) {
    return FilesCenterModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      displayName: json['display_name'] as String?,
      previewImage: json['preview_image'] as String?,
      fileUrl: json['file_url'] as String?,
      downloadUrl: json['download_url'] as String?,
      typeTitle: json['type'] as String?,
      typeId: json['type_id'] as int?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'display_name': displayName,
      'preview_image': previewImage,
      'file_url': fileUrl,
      'download_url': downloadUrl,
      'type': typeTitle,
      'type_id': typeId,
      'status': status,
    };
  }

  String? get imageUrl {
    return previewImage;
  }

  String? get fileType {
    if (fileUrl != null && fileUrl!.contains('.')) {
      return fileUrl!.split('.').last.toLowerCase();
    }
    return null;
  }

  bool get isImage {
    final type = fileType;
    if (type == null) return false;
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg', 'image'];
    return imageTypes.contains(type);
  }
}
