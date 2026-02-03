class PopupModel {
  final String titleEn;
  final String titleAr;
  final String contentEn;
  final String contentAr;
  final List<String> screens;

  PopupModel({
    required this.titleEn,
    required this.titleAr,
    required this.contentEn,
    required this.contentAr,
    required this.screens,
  });

  factory PopupModel.fromJson(Map<String, dynamic> json) {
    return PopupModel(
      titleEn: json['title']['en'],
      titleAr: json['title']['ar'],
      contentEn: json['content']['en'],
      contentAr: json['content']['ar'],
      screens: List<String>.from(json['screens']),
    );
  }
}
