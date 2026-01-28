class GetOneBlogModel {
  bool? status;
  String? message;
  String? create;
  Item? item;

  GetOneBlogModel({this.status, this.message, this.create, this.item});

  GetOneBlogModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    create = json['create'];
    item = json['item'] != null ? Item.fromJson(json['item']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['create'] = create;
    if (item != null) {
      data['item'] = item!.toJson();
    }
    return data;
  }
}

class Item {
  int? id;
  String? slug;
  String? title;
  String? shortDescription;
  String? content;
  List<MainGallery>? mainGallery;
  List<MainThumbnail>? mainThumbnail;
  Category? category;
  int? categoryId;
  String? createdAt;
  Status? status;
  String? createdDate;

  Item(
      {this.id,
        this.slug,
        this.title,
        this.shortDescription,
        this.content,
        this.mainGallery,
        this.mainThumbnail,
        this.category,
        this.categoryId,
        this.createdAt,
        this.status,
        this.createdDate});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    slug = json['slug'];
    title = json['title'];
    shortDescription = json['short_description'];
    content = json['content'];
    if (json['main_gallery'] != null) {
      mainGallery = <MainGallery>[];
      json['main_gallery'].forEach((v) {
        mainGallery!.add(MainGallery.fromJson(v));
      });
    }
    if (json['main_thumbnail'] != null) {
      mainThumbnail = <MainThumbnail>[];
      json['main_thumbnail'].forEach((v) {
        mainThumbnail!.add(MainThumbnail.fromJson(v));
      });
    }
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    categoryId = json['category_id'];
    createdAt = json['created_at'];
    status =
    json['status'] != null ? Status.fromJson(json['status']) : null;
    createdDate = json['created_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['slug'] = slug;
    data['title'] = title;
    data['short_description'] = shortDescription;
    data['content'] = content;
    if (mainGallery != null) {
      data['main_gallery'] = mainGallery!.map((v) => v.toJson()).toList();
    }
    if (mainThumbnail != null) {
      data['main_thumbnail'] =
          mainThumbnail!.map((v) => v.toJson()).toList();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    data['category_id'] = categoryId;
    data['created_at'] = createdAt;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['created_date'] = createdDate;
    return data;
  }
}

class MainGallery {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;
  Sizes? sizes;

  MainGallery(
      {this.id,
        this.type,
        this.title,
        this.alt,
        this.file,
        this.thumbnail,
        this.sizes});

  MainGallery.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'];
    sizes = json['sizes'] != null ? Sizes.fromJson(json['sizes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    if (sizes != null) {
      data['sizes'] = sizes!.toJson();
    }
    return data;
  }
}
class MainThumbnailCategory {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;
  Sizes? sizes;

  MainThumbnailCategory(
      {this.id,
        this.type,
        this.title,
        this.alt,
        this.file,
        this.thumbnail,
        this.sizes});

  MainThumbnailCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'];
    sizes = json['sizes'] != null ? Sizes.fromJson(json['sizes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    if (sizes != null) {
      data['sizes'] = sizes!.toJson();
    }
    return data;
  }
}
class MainThumbnail {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;
  Sizes? sizes;

  MainThumbnail(
      {this.id,
        this.type,
        this.title,
        this.alt,
        this.file,
        this.thumbnail,
        this.sizes});

  MainThumbnail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'];
    sizes = json['sizes'] != null ? Sizes.fromJson(json['sizes']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    if (sizes != null) {
      data['sizes'] = sizes!.toJson();
    }
    return data;
  }
}

class Sizes {
  String? thumbnail;
  String? medium;
  String? large;
  String? s1200800;
  String? s8001200;
  String? s1200300;
  String? s3001200;

  Sizes(
      {this.thumbnail,
        this.medium,
        this.large,
        this.s1200800,
        this.s8001200,
        this.s1200300,
        this.s3001200});

  Sizes.fromJson(Map<String, dynamic> json) {
    thumbnail = json['thumbnail'];
    medium = json['medium'];
    large = json['large'];
    s1200800 = json['1200_800'];
    s8001200 = json['800_1200'];
    s1200300 = json['1200_300'];
    s3001200 = json['300_1200'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['thumbnail'] = thumbnail;
    data['medium'] = medium;
    data['large'] = large;
    data['1200_800'] = s1200800;
    data['800_1200'] = s8001200;
    data['1200_300'] = s1200300;
    data['300_1200'] = s3001200;
    return data;
  }
}

class Category {
  int? id;
  String? title;
  List<MainThumbnailCategory>? mainThumbnail;

  Category({this.id, this.title, this.mainThumbnail});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json['main_thumbnail'] != null) {
      mainThumbnail = <MainThumbnailCategory>[];
      json['main_thumbnail'].forEach((v) {
        mainThumbnail!.add(MainThumbnailCategory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    if (mainThumbnail != null) {
      data['main_thumbnail'] =
          mainThumbnail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Status {
  String? key;
  String? value;

  Status({this.key, this.value});

  Status.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['value'] = value;
    return data;
  }
}
