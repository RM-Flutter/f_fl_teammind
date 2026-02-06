/// Enum to identify different widget types in home screen
enum HomeWidgetType {
  myRequests('myRequests', 'My Requests'),
  myTeamRequests('myTeamRequests', 'My Team Requests'),
  otherDepartmentRequests('otherDepartmentRequests', 'Other Department Requests'),
  allCompanyRequests('allCompanyRequests', 'All Company Requests'),
  notifications('notifications', 'Notifications');

  final String id;
  final String displayName;

  const HomeWidgetType(this.id, this.displayName);

  /// Convert to string for cache
  String toJson() => id;

  /// Create from string
  static HomeWidgetType? fromJson(String? json) {
    if (json == null) return null;
    try {
      return HomeWidgetType.values.firstWhere(
        (type) => type.id == json,
        orElse: () => HomeWidgetType.myRequests,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get default order
  static List<HomeWidgetType> getDefaultOrder() {
    return [
      HomeWidgetType.myRequests,
      HomeWidgetType.myTeamRequests,
      HomeWidgetType.otherDepartmentRequests,
      HomeWidgetType.allCompanyRequests,
      HomeWidgetType.notifications,
    ];
  }
}

