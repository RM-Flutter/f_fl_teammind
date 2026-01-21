class GetOneRequestModel {
  bool? status;
  String? message;
  String? create;
  Item? item;

  GetOneRequestModel({this.status, this.message, this.create, this.item});

  GetOneRequestModel.fromJson(Map<String, dynamic> json) {
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
  String? title;
  List<Voice>? voice;
  Pfor? pfor;
  List<PforValue>? pforValue;
  List<MainThum>? mainThum;
  Pfor? pstatus;
  PType? pType;
  String? content;
  String? createdAt;
  Pfor? status;
  CommentStatus? commentStatus;
  TicketPriority? ticketPriority;
  String? scheduleDate;

  Item(
      {this.id,
        this.title,
        this.pType,
        this.voice,
        this.pfor,
        this.pforValue,
        this.mainThum,
        this.pstatus,
        this.content,
        this.commentStatus,
        this.ticketPriority,
        this.createdAt,
        this.status,
        this.scheduleDate});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    if (json['voice'] != null) {
      voice = <Voice>[];
      json['voice'].forEach((v) {
        voice!.add(Voice.fromJson(v));
      });
    }
    pfor = json['pfor'] != null ? Pfor.fromJson(json['pfor']) : null;
    if (json['pfor_value'] != null) {
      pforValue = <PforValue>[];
      json['pfor_value'].forEach((v) {
        pforValue!.add(PforValue.fromJson(v));
      });
    } if (json['main_thumbnail'] != null) {
      mainThum = <MainThum>[];
      json['main_thumbnail'].forEach((v) {
        mainThum!.add(MainThum.fromJson(v));
      });
    }
    commentStatus = json['comment_status'] != null ? CommentStatus.fromJson(json['comment_status']) : null;
    ticketPriority = json['ticket_priority'] != null ? TicketPriority.fromJson(json['ticket_priority']) : null;
    pstatus =
    json['pstatus'] != null ? Pfor.fromJson(json['pstatus']) : null;
    pType =
    json['ptype'] != null ? PType.fromJson(json['ptype']) : null;
    content = json['content'];
    createdAt = json['created_at'];
    status = json['status'] != null ? Pfor.fromJson(json['status']) : null;
    scheduleDate = json['schedule_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    if (voice != null) {
      data['voice'] = voice!.map((v) => v.toJson()).toList();
    }
    if (pfor != null) {
      data['pfor'] = pfor!.toJson();
    }
    if (pforValue != null) {
      data['pfor_value'] = pforValue!.map((v) => v.toJson()).toList();
    }
    if (pstatus != null) {
      data['pstatus'] = pstatus!.toJson();
    }
    data['content'] = content;
    data['created_at'] = createdAt;
    if (status != null) {
      data['status'] = status!.toJson();
    }
    data['schedule_date'] = scheduleDate;
    return data;
  }
}

class Voice {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;

  Voice({this.id, this.type, this.title, this.alt, this.file, this.thumbnail});

  Voice.fromJson(Map<String, dynamic> json) {
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
class MainThum {
  int? id;
  String? type;
  String? title;
  String? alt;
  String? file;
  String? thumbnail;

  MainThum({this.id, this.type, this.title, this.alt, this.file, this.thumbnail});

  MainThum.fromJson(Map<String, dynamic> json) {
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

class Pfor {
  String? key;
  String? value;

  Pfor({this.key, this.value});

  Pfor.fromJson(Map<String, dynamic> json) {
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
class TicketPriority {
  String? key;
  String? value;

  TicketPriority({this.key, this.value});

  TicketPriority.fromJson(Map<String, dynamic> json) {
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
class PType {
  int? id;
  String? title;

  PType({this.id, this.title});

  PType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    return data;
  }
}
class CommentStatus {
  String? key;
  String? value;

  CommentStatus({this.key, this.value});

  CommentStatus.fromJson(Map<String, dynamic> json) {
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

class PforValue {
  String? label;
  String? value;

  PforValue({this.label, this.value});

  PforValue.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    return data;
  }
}
