/// Model for CV template image item (from res-cv-templates API image[].file)
class CvTemplateImageItem {
  final int? id;
  final String? type;
  final String? title;
  final String? alt;
  final String? file;
  final String? thumbnail;
  final Map<String, String>? sizes;

  CvTemplateImageItem({
    this.id,
    this.type,
    this.title,
    this.alt,
    this.file,
    this.thumbnail,
    this.sizes,
  });

  factory CvTemplateImageItem.fromJson(Map<String, dynamic> json) {
    return CvTemplateImageItem(
      id: json['id'] as int?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      alt: json['alt'] as String?,
      file: json['file'] as String?,
      thumbnail: json['thumbnail'] as String?,
      sizes: json['sizes'] != null
          ? Map<String, String>.from(
              (json['sizes'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())))
          : null,
    );
  }
}

/// CV Template from res-cv-templates/entities-operations (display image from image[].file)
class CvTemplateModel {
  final int? id;
  final String? slug;
  final List<CvTemplateImageItem>? image;

  CvTemplateModel({
    this.id,
    this.slug,
    this.image,
  });

  factory CvTemplateModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateModel(
      id: json['id'] as int?,
      slug: json['slug'] as String?,
      image: (json['image'] as List<dynamic>?)
          ?.map((e) => CvTemplateImageItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Display URL from API: image[0].file
  String? get imageUrl {
    if (image != null && image!.isNotEmpty && image![0].file != null && image![0].file!.isNotEmpty) {
      return image![0].file;
    }
    return null;
  }
}
