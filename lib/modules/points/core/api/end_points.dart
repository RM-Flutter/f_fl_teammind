import 'package:inv/constants/app_constants.dart';
import 'package:inv/general_services/app_config.service.dart';
import 'package:provider/provider.dart';

class EndPoints {
  String postId = '';
  ///replace with token after login
  ///replace with deviceId after login
  static const String getHistory = '${AppConstants.baseUrl}/rm_pointsys/v1/history';
  static const String getPrize = '${AppConstants.baseUrl}/prizes/entities-operations';
  static const String coupoun = '${AppConstants.baseUrl}/rm_pointsys/v1/redeem_gift_card';
  static const String conditions = '${AppConstants.baseUrl}/rm_page/v1/show?slug=points-terms-and-conditions';
  static const String postGroups = '${AppConstants.baseUrl}/social-groups/entities-operations';
  static const String postPrize = '${AppConstants.baseUrl}/redeem-requests/entities-operations/store';
  static  String addComment = '${AppConstants.baseUrl}/social-posts/entities-operations/:id/comments';
  static const String postsInGroup= '${AppConstants.baseUrl}/social-posts/entities-operations?with=social_group_id,user_id';
}
