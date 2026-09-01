import '../data/models/approvable_details_model.dart';

abstract class ApprovableDetailsState {}

class ApprovableDetailsInitial extends ApprovableDetailsState {}

class ApprovableDetailsLoading extends ApprovableDetailsState {}

class ApprovableDetailsLoaded extends ApprovableDetailsState {
  final ApprovableDetailsModel details;
  final List<CurrentLevelApproverModel>? activeApprovers;
  final bool isLoadingApprovers;

  ApprovableDetailsLoaded({
    required this.details,
    this.activeApprovers,
    this.isLoadingApprovers = false,
  });

  ApprovableDetailsLoaded copyWith({
    ApprovableDetailsModel? details,
    List<CurrentLevelApproverModel>? activeApprovers,
    bool? isLoadingApprovers,
  }) {
    return ApprovableDetailsLoaded(
      details: details ?? this.details,
      activeApprovers: activeApprovers ?? this.activeApprovers,
      isLoadingApprovers: isLoadingApprovers ?? this.isLoadingApprovers,
    );
  }
}

class ApprovableDetailsError extends ApprovableDetailsState {
  final String message;
  ApprovableDetailsError(this.message);
}

class ApprovableActionSubmitting extends ApprovableDetailsState {}

class ApprovableActionSuccess extends ApprovableDetailsState {
  final String message;
  ApprovableActionSuccess(this.message);
}

class ApprovableActionError extends ApprovableDetailsState {
  final String message;
  ApprovableActionError(this.message);
}
