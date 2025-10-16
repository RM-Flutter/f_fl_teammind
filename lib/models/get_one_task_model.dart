class GetOneTaskModel {
  bool? status;
  String? message;
  Task? task;

  GetOneTaskModel({this.status, this.message, this.task});

  GetOneTaskModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    task = json['task'] != null ? new Task.fromJson(json['task']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.task != null) {
      data['task'] = this.task!.toJson();
    }
    return data;
  }
}

class Task {
  int? id;
  var progress;
  String? title;
  String? content;
  String? icon;
  List<AssignTo>? assignTo;
  List<SubTasks>? subTasks;
  String? dueDate;
  String? createAt;
  String? status;

  Task(
      {this.id,
        this.title,
        this.progress,
        this.content,
        this.icon,
        this.assignTo,
        this.subTasks,
        this.createAt,
        this.dueDate,
        this.status});

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    progress = json['progress'];
    title = json['title'];
    content = json['content'];
    icon = json['icon'];
    if (json['assignTo'] != null) {
      assignTo = <AssignTo>[];
      json['assignTo'].forEach((v) {
        assignTo!.add(new AssignTo.fromJson(v));
      });
    }
    if (json['subTasks'] != null) {
      subTasks = <SubTasks>[];
      json['subTasks'].forEach((v) {
        subTasks!.add(new SubTasks.fromJson(v));
      });
    }
    dueDate = json['dueDate'];
    createAt = json['createdAt'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['content'] = this.content;
    data['icon'] = this.icon;
    if (this.assignTo != null) {
      data['assignTo'] = this.assignTo!.map((v) => v.toJson()).toList();
    }
    if (this.subTasks != null) {
      data['subTasks'] = this.subTasks!.map((v) => v.toJson()).toList();
    }
    data['dueDate'] = this.dueDate;
    data['status'] = this.status;
    return data;
  }
}

class AssignTo {
  int? id;
  String? name;

  AssignTo({this.id, this.name});

  AssignTo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class SubTasks {
  String? name;
  bool? status;

  SubTasks({this.name, this.status});

  SubTasks.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['status'] = this.status;
    return data;
  }
}
