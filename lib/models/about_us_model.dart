// class AboutUsModel {
//   bool? status;
//   String? message;
//   Page? page;
//
//   AboutUsModel({this.status, this.message, this.page});
//
//   AboutUsModel.fromJson(Map<String, dynamic> json) {
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
//   String? type;
//   String? content;
//   String? history;
//   List<Certificates>? certificates;
//   List<Partners>? partners;
//
//   Page(
//       {this.id,
//         this.title,
//         this.slug,
//         this.type,
//         this.content,
//         this.history,
//         this.certificates,
//         this.partners});
//
//   Page.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     title = json['title'];
//     slug = json['slug'];
//     type = json['type'];
//     content = json['content'];
//     history = json['history'];
//     if (json['certificates'] != null) {
//       certificates = <Certificates>[];
//       json['certificates'].forEach((v) {
//         certificates!.add(Certificates.fromJson(v));
//       });
//     }
//     if (json['partners'] != null) {
//       partners = <Partners>[];
//       json['partners'].forEach((v) {
//         partners!.add(Partners.fromJson(v));
//       });
//     }
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['title'] = title;
//     data['slug'] = slug;
//     data['type'] = type;
//     data['content'] = content;
//     data['history'] = history;
//     if (certificates != null) {
//       data['certificates'] = certificates!.map((v) => v.toJson()).toList();
//     }
//     if (partners != null) {
//       data['partners'] = partners!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class Certificates {
//   int? id;
//   String? type;
//   String? title;
//   String? alt;
//   String? file;
//   String? thumbnail;
//   Sizes? sizes;
//
//   Certificates(
//       {this.id,
//         this.type,
//         this.title,
//         this.alt,
//         this.file,
//         this.thumbnail,
//         this.sizes});
//
//   Certificates.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     type = json['type'];
//     title = json['title'];
//     alt = json['alt'];
//     file = json['file'];
//     thumbnail = json['thumbnail'];
//     sizes = json['sizes'] != null ? Sizes.fromJson(json['sizes']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['type'] = type;
//     data['title'] = title;
//     data['alt'] = alt;
//     data['file'] = file;
//     data['thumbnail'] = thumbnail;
//     if (sizes != null) {
//       data['sizes'] = sizes!.toJson();
//     }
//     return data;
//   }
// }
// class Partners {
//   int? id;
//   String? type;
//   String? title;
//   String? alt;
//   String? file;
//   String? thumbnail;
//   Sizes? sizes;
//
//   Partners(
//       {this.id,
//         this.type,
//         this.title,
//         this.alt,
//         this.file,
//         this.thumbnail,
//         this.sizes});
//
//   Partners.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     type = json['type'];
//     title = json['title'];
//     alt = json['alt'];
//     file = json['file'];
//     thumbnail = json['thumbnail'];
//     sizes = json['sizes'] != null ? Sizes.fromJson(json['sizes']) : null;
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['type'] = type;
//     data['title'] = title;
//     data['alt'] = alt;
//     data['file'] = file;
//     data['thumbnail'] = thumbnail;
//     if (sizes != null) {
//       data['sizes'] = sizes!.toJson();
//     }
//     return data;
//   }
// }
//
// class Sizes {
//   String? thumbnail;
//   String? medium;
//   String? large;
//   String? s1200800;
//   String? s8001200;
//   String? s1200300;
//   String? s3001200;
//   String? tUV5100Webp;
//   String? madeInEgypt5100Webp;
//   String? iSO450015058Webp;
//   String? iSO90015058Webp;
//   String? iAS5056Webp;
//   String? iAF5055Webp;
//   String? eOS5054Webp;
//
//   Sizes(
//       {this.thumbnail,
//         this.medium,
//         this.large,
//         this.s1200800,
//         this.s8001200,
//         this.s1200300,
//         this.s3001200,
//         this.tUV5100Webp,
//         this.madeInEgypt5100Webp,
//         this.iSO450015058Webp,
//         this.iSO90015058Webp,
//         this.iAS5056Webp,
//         this.iAF5055Webp,
//         this.eOS5054Webp});
//
//   Sizes.fromJson(Map<String, dynamic> json) {
//     thumbnail = json['thumbnail'];
//     medium = json['medium'];
//     large = json['large'];
//     s1200800 = json['1200_800'];
//     s8001200 = json['800_1200'];
//     s1200300 = json['1200_300'];
//     s3001200 = json['300_1200'];
//     tUV5100Webp = json['TUV5100_webp'];
//     madeInEgypt5100Webp = json['Made-in-Egypt5100_webp'];
//     iSO450015058Webp = json['ISO-450015058_webp'];
//     iSO90015058Webp = json['ISO-90015058_webp'];
//     iAS5056Webp = json['IAS5056_webp'];
//     iAF5055Webp = json['IAF5055_webp'];
//     eOS5054Webp = json['EOS5054_webp'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['thumbnail'] = thumbnail;
//     data['medium'] = medium;
//     data['large'] = large;
//     data['1200_800'] = s1200800;
//     data['800_1200'] = s8001200;
//     data['1200_300'] = s1200300;
//     data['300_1200'] = s3001200;
//     data['TUV5100_webp'] = tUV5100Webp;
//     data['Made-in-Egypt5100_webp'] = madeInEgypt5100Webp;
//     data['ISO-450015058_webp'] = iSO450015058Webp;
//     data['ISO-90015058_webp'] = iSO90015058Webp;
//     data['IAS5056_webp'] = iAS5056Webp;
//     data['IAF5055_webp'] = iAF5055Webp;
//     data['EOS5054_webp'] = eOS5054Webp;
//     return data;
//   }
// }
//
// class PartnerSizes {
//   String? thumbnail;
//   String? medium;
//   String? large;
//   String? s1200800;
//   String? s8001200;
//   String? s1200300;
//   String? s3001200;
//   String? orientPartners145720Webp;
//   String? orientPartners145720PngWebp;
//   String? orientPartners135718Webp;
//   String? orientPartners135718PngWebp;
//   String? orientPartners125718Webp;
//   String? orientPartners115716Webp;
//   String? orientPartners10Webp;
//   String? orientPartners085714Webp;
//   String? orientPartners095714Webp;
//   String? orientPartners075712Webp;
//   String? orientPartners065711Webp;
//   String? orientPartners055711Webp;
//   String? orientPartners035709Webp;
//   String? orientPartners045709Webp;
//   String? orientPartners015707Webp;
//   String? orientPartners025706Webp;
//
//   PartnerSizes(
//       {this.thumbnail,
//         this.medium,
//         this.large,
//         this.s1200800,
//         this.s8001200,
//         this.s1200300,
//         this.s3001200,
//         this.orientPartners145720Webp,
//         this.orientPartners145720PngWebp,
//         this.orientPartners135718Webp,
//         this.orientPartners135718PngWebp,
//         this.orientPartners125718Webp,
//         this.orientPartners115716Webp,
//         this.orientPartners10Webp,
//         this.orientPartners085714Webp,
//         this.orientPartners095714Webp,
//         this.orientPartners075712Webp,
//         this.orientPartners065711Webp,
//         this.orientPartners055711Webp,
//         this.orientPartners035709Webp,
//         this.orientPartners045709Webp,
//         this.orientPartners015707Webp,
//         this.orientPartners025706Webp});
//
//   PartnerSizes.fromJson(Map<String, dynamic> json) {
//     thumbnail = json['thumbnail'];
//     medium = json['medium'];
//     large = json['large'];
//     s1200800 = json['1200_800'];
//     s8001200 = json['800_1200'];
//     s1200300 = json['1200_300'];
//     s3001200 = json['300_1200'];
//     orientPartners145720Webp = json['orient-partners145720_webp'];
//     orientPartners145720PngWebp = json['orient-partners145720.png_webp'];
//     orientPartners135718Webp = json['orient-partners135718_webp'];
//     orientPartners135718PngWebp = json['orient-partners135718.png_webp'];
//     orientPartners125718Webp = json['orient-partners125718_webp'];
//     orientPartners115716Webp = json['orient-partners115716_webp'];
//     orientPartners10Webp = json['orient-partners10_webp'];
//     orientPartners085714Webp = json['orient-partners085714_webp'];
//     orientPartners095714Webp = json['orient-partners095714_webp'];
//     orientPartners075712Webp = json['orient-partners075712_webp'];
//     orientPartners065711Webp = json['orient-partners065711_webp'];
//     orientPartners055711Webp = json['orient-partners055711_webp'];
//     orientPartners035709Webp = json['orient-partners035709_webp'];
//     orientPartners045709Webp = json['orient-partners045709_webp'];
//     orientPartners015707Webp = json['orient-partners015707_webp'];
//     orientPartners025706Webp = json['orient-partners025706_webp'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['thumbnail'] = thumbnail;
//     data['medium'] = medium;
//     data['large'] = large;
//     data['1200_800'] = s1200800;
//     data['800_1200'] = s8001200;
//     data['1200_300'] = s1200300;
//     data['300_1200'] = s3001200;
//     data['orient-partners145720_webp'] = orientPartners145720Webp;
//     data['orient-partners145720.png_webp'] = orientPartners145720PngWebp;
//     data['orient-partners135718_webp'] = orientPartners135718Webp;
//     data['orient-partners135718.png_webp'] = orientPartners135718PngWebp;
//     data['orient-partners125718_webp'] = orientPartners125718Webp;
//     data['orient-partners115716_webp'] = orientPartners115716Webp;
//     data['orient-partners10_webp'] = orientPartners10Webp;
//     data['orient-partners085714_webp'] = orientPartners085714Webp;
//     data['orient-partners095714_webp'] = orientPartners095714Webp;
//     data['orient-partners075712_webp'] = orientPartners075712Webp;
//     data['orient-partners065711_webp'] = orientPartners065711Webp;
//     data['orient-partners055711_webp'] = orientPartners055711Webp;
//     data['orient-partners035709_webp'] = orientPartners035709Webp;
//     data['orient-partners045709_webp'] = orientPartners045709Webp;
//     data['orient-partners015707_webp'] = orientPartners015707Webp;
//     data['orient-partners025706_webp'] = orientPartners025706Webp;
//     return data;
//   }
// }
