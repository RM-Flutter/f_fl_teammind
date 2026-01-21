class GetRequestCommentModel {
  bool? status;
  String? message;
  List<Comments>? comments;

  GetRequestCommentModel({this.status, this.message, this.comments});

  GetRequestCommentModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['comments'] != null) {
      comments = <Comments>[];
      json['comments'].forEach((v) {
        comments!.add(Comments.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (comments != null) {
      data['comments'] = comments!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Comments {
  int? id;
  User? user;
  String? content;
  List<Images>? images;
  List<Sounds>? sounds;
  String? createdAt;
  String? updatedAt;

  Comments(
      {this.id,
        this.user,
        this.content,
        this.images,
        this.sounds,
        this.createdAt,
        this.updatedAt});

  Comments.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    content = json['content'];
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    if (json['sounds'] != null) {
      sounds = <Sounds>[];
      json['sounds'].forEach((v) {
        sounds!.add(Sounds.fromJson(v));
      });
    }
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['content'] = content;
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (sounds != null) {
      data['sounds'] = sounds!.map((v) => v.toJson()).toList();
    }
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class User {
  int? id;
  String? name;
  String? avatar;

  User({this.id, this.name, this.avatar});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['avatar'] = avatar;
    return data;
  }
}

class Images {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;

  Images(
      {this.id,
        this.type,
        this.title,
        this.alt,
        this.file,
        this.thumbnail,
      });

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
class Sounds {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;

  Sounds(
      {this.id,
        this.type,
        this.title,
        this.alt,
        this.file,
        this.thumbnail,
      });

  Sounds.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    title = json['title'];
    alt = json['alt'];
    file = json['file'];
    thumbnail = json['thumbnail'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['alt'] = alt;
    data['file'] = file;
    data['thumbnail'] = thumbnail;
    return data;
  }
}
