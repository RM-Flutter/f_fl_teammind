/// Model for Premium File File Object
class PremiumFileFile {
  final int? id;
  final String? type;
  final String? title;
  final String? alt;
  final String? file;
  final String? thumbnail;
  final Map<String, String>? sizes;

  PremiumFileFile({
    this.id,
    this.type,
    this.title,
    this.alt,
    this.file,
    this.thumbnail,
    this.sizes,
  });

  factory PremiumFileFile.fromJson(Map<String, dynamic> json) {
    return PremiumFileFile(
      id: json['id'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      alt: json['alt'] as String?,
      file: json['file'] as String?,
      thumbnail: json['thumbnail'] as String?,
      sizes: json['sizes'] != null
          ? Map<String, String>.from(
              (json['sizes'] as Map).map((key, value) => MapEntry(key.toString(), value.toString())))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'alt': alt,
      'file': file,
      'thumbnail': thumbnail,
      'sizes': sizes,
    };
  }
}

/// Model for Premium File Type
class PremiumFileType {
  final int? id;
  final String? title;

  PremiumFileType({
    this.id,
    this.title,
  });

  factory PremiumFileType.fromJson(Map<String, dynamic> json) {
    return PremiumFileType(
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

/// Model for Premium File Status
class PremiumFileStatus {
  final String? key;
  final String? value;

  PremiumFileStatus({
    this.key,
    this.value,
  });

  factory PremiumFileStatus.fromJson(Map<String, dynamic> json) {
    return PremiumFileStatus(
      key: json['key'] as String?,
      value: json['value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}

/// Model for Premium File Type (from types endpoint)
class PremiumFileTypeModel {
  final int? id;
  final String? title;

  PremiumFileTypeModel({
    this.id,
    this.title,
  });

  factory PremiumFileTypeModel.fromJson(Map<String, dynamic> json) {
    return PremiumFileTypeModel(
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

/// Main Premium File Model
class PremiumFileModel {
  final int? id;
  final String? title;
  final String? description;
  final List<PremiumFileFile>? file;
  final PremiumFileType? type;
  final int? typeId;
  final PremiumFileStatus? status;

  PremiumFileModel({
    this.id,
    this.title,
    this.description,
    this.file,
    this.type,
    this.typeId,
    this.status,
  });

  factory PremiumFileModel.fromJson(Map<String, dynamic> json) {
    return PremiumFileModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      file: (json['file'] as List<dynamic>?)
          ?.map((e) => PremiumFileFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      type: json['type'] != null
          ? PremiumFileType.fromJson(json['type'] as Map<String, dynamic>)
          : null,
      typeId: json['type_id'] as int?,
      status: json['status'] != null
          ? PremiumFileStatus.fromJson(json['status'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'file': file?.map((e) => e.toJson()).toList(),
      'type': type?.toJson(),
      'type_id': typeId,
      'status': status?.toJson(),
    };
  }

  /// Get the first file URL for display
  String? get imageUrl {
    if (file != null && file!.isNotEmpty) {
      return file![0].file;
    }
    return null;
  }

  /// Get the file type from the first file
  String? get fileType {
    if (file != null && file!.isNotEmpty) {
      return file![0].type?.toLowerCase();
    }
    return null;
  }

  /// Check if the file is an image
  bool get isImage {
    final type = fileType;
    if (type == null) return false;
    
    final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg', 'image'];
    return imageTypes.contains(type);
  }

  /// Get the first file object
  PremiumFileFile? get firstFile {
    if (file != null && file!.isNotEmpty) {
      return file![0];
    }
    return null;
  }

  /// Get the file URL for download
  String? get fileUrl {
    return firstFile?.file;
  }
}

