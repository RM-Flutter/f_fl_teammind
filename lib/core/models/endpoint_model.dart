enum EndpointsNames {
  startApp,
  getEmployeeBalance,
  createAuthentication,
  authentication,
  registration,
  device,
  updateInfo,
  registrationFields,
  forgetPassword,
  logOut,
  getDeviceToken,
  generalSettings,
  userSettings,
  updateDeviceInfo,
  updatePassword,
  updateNotification,
  home,
  pointsHistory,
  taxonomy,
  addNew,
  getPosts,
  getPost,
  myProject,
  newRequest,
  getComments,
  addComments,
  pages,
  notificationStatus,
  deviceSys,
  taxonomyPosts,
  fingerprint,
  fingerprints,
  getCalendar,
  empAddRequest,
  getRequests,
  getRequest,
  askIgnore,
  managerAction,
  askRemember,
  getFingerprints,
  getFingerprint,
  new_,
  empGetPosts,
  empTasks,
  empAddTasks,
  tasksUsers,
  empStatistics,
  companyStructure,
  postActions,
  payGetPosts,
  payGetPost,
  addNewNotification,
  getUsers,
  getDepartments,
  updateTasks,
  resend,
  oauth,
  removeAccount,
  empEvaluation,
  summaryReport,
  activateTfa, myStores, myOrdersOdoo, myOrders, avaialbleProducts, calculateOrder, completeOrder, showTeam, topRated, team, teamJoin, teamApproveRequest, leaveTeam, deleteMember
}

class EndPoint {
  final EndpointsNames name;
//  final String method;
  final String url;

  EndPoint({required this.name, required this.url});

  EndPoint copyWith({
    EndpointsNames? name,
    String? method,
    String? url,
  }) {
    return EndPoint(
      name: name ?? this.name,
      //method: method ?? this.method,
      url: url?.trim() ?? this.url.trim(),
    );
  }

  @override
  bool operator ==(covariant EndPoint other) {
    if (identical(this, other)) return true;

    return other.name == name && other.url == url;
  }

  @override
  int get hashCode => name.hashCode ^ url.hashCode;

  @override
  String toString() => 'EndPoint(name: $name, url: $url)';
}
