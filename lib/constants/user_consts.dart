import 'package:rmemp/models/all_company_request.model.dart';
import 'package:rmemp/models/myteam_request.model.dart';
import 'package:rmemp/models/other_department_request.model.dart';
import 'package:rmemp/models/request.model.dart';
import 'package:rmemp/models/settings/general_settings.model.dart';
import 'package:rmemp/models/settings/user_settings.model.dart';
import 'package:rmemp/models/settings/user_settings_2.model.dart';

class UserSettingConst{
  static UserSettingsModel? userSettings;
  static UserSettings2Model? userSettings2;
  static GeneralSettingsModel? generalSettingsModel;
  static MyTeamRequestModel? myTeamRequestModel;
  static RequestModel? requestModel;
  static OtherDepartmentRequestModel? otherDepartmentRequestModel;
  static AllCompanyRequestModel? allCompanyRequestModel;
}