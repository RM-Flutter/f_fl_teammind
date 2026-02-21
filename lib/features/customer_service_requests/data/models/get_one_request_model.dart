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
    item = json['item'] != null ? new Item.fromJson(json['item']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['create'] = this.create;
    if (this.item != null) {
      data['item'] = this.item!.toJson();
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
        voice!.add(new Voice.fromJson(v));
      });
    }
    pfor = json['pfor'] != null ? new Pfor.fromJson(json['pfor']) : null;
    if (json['pfor_value'] != null) {
      pforValue = <PforValue>[];
      json['pfor_value'].forEach((v) {
        pforValue!.add(new PforValue.fromJson(v));
      });
    } if (json['main_thumbnail'] != null) {
      mainThum = <MainThum>[];
      json['main_thumbnail'].forEach((v) {
        mainThum!.add(new MainThum.fromJson(v));
      });
    }
    commentStatus = json['comment_status'] != null ? new CommentStatus.fromJson(json['comment_status']) : null;
    ticketPriority = json['ticket_priority'] != null ? new TicketPriority.fromJson(json['ticket_priority']) : null;
    pstatus =
    json['pstatus'] != null ? new Pfor.fromJson(json['pstatus']) : null;
    pType =
    json['ptype'] != null ? new PType.fromJson(json['ptype']) : null;
    content = json['content'];
    createdAt = json['created_at'];
    status = json['status'] != null ? new Pfor.fromJson(json['status']) : null;
    scheduleDate = json['schedule_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    if (this.voice != null) {
      data['voice'] = this.voice!.map((v) => v.toJson()).toList();
    }
    if (this.pfor != null) {
      data['pfor'] = this.pfor!.toJson();
    }
    if (this.pforValue != null) {
      data['pfor_value'] = this.pforValue!.map((v) => v.toJson()).toList();
    }
    if (this.pstatus != null) {
      data['pstatus'] = this.pstatus!.toJson();
    }
    data['content'] = this.content;
    data['created_at'] = this.createdAt;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    data['schedule_date'] = this.scheduleDate;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['title'] = this.title;
    data['alt'] = this.alt;
    data['file'] = this.file;
    data['thumbnail'] = this.thumbnail;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['title'] = this.title;
    data['alt'] = this.alt;
    data['file'] = this.file;
    data['thumbnail'] = this.thumbnail;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['label'] = this.label;
    data['value'] = this.value;
    return data;
  }
}
