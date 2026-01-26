// class FaqModel {
//   bool? status;
//   String? message;
//   Page? page;
//
//   // FaqModel({this.status, this.message, this.page});
//
//   FaqModel.fromJson(Map<String, dynamic> json) {
//     status = json['status'];
//     message = json['message'];
//     page = json['page'] != null ? Page.fromJson(json['page']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['status'] = status;
//     data['message'] = message;
//     if (page != null) {
//       data['page'] = page!.toJson();
//     }
//     return data;
//   }
// }
//
// class Page {
//   int? id;
//   String? title;
//   String? slug;
//   List<Questions>? questions;
//
//   Page({this.id, this.title, this.slug, this.questions});
//
//   Page.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     slug = json['slug'];
//     if (json['questions'] != null) {
//       questions = <Questions>[];
//       json['questions'].forEach((v) {
//         questions!.add(Questions.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['title'] = title;
//     data['slug'] = slug;
//     if (questions != null) {
//       data['questions'] = questions!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Questions {
//   String? question;
//   String? answer;
//
//   Questions({this.question, this.answer});
//
//   Questions.fromJson(Map<String, dynamic> json) {
//     question = json['question'];
//     answer = json['answer'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['question'] = question;
//     data['answer'] = answer;
//     return data;
//   }
// }
