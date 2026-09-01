import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/approvable_details_model.dart';
import '../data/services/approvables_details_service.dart';
import 'approvable_details_state.dart';

class ApprovableDetailsCubit extends Cubit<ApprovableDetailsState> {
  ApprovableDetailsCubit() : super(ApprovableDetailsInitial());

  String? currentType;
  String? currentId;
  ApprovableDetailsModel? detailsModel;

  Future<void> fetchDetails({
    required BuildContext context,
    required String type,
    required String id,
  }) async {
    currentType = type;
    currentId = id;
    emit(ApprovableDetailsLoading());

    final result = await ApprovablesDetailsService.getApprovableDetails(
      context: context,
      type: type,
      id: id,
    );

    if (result.success && result.data != null) {
      detailsModel = result.data;
      emit(ApprovableDetailsLoaded(details: detailsModel!));

      // If user can take action as someone else, pre-fetch current level approvers
      if (detailsModel?.canTakeActionAsSomeoneElse == true) {
        fetchCurrentLevelApprovers(context: context);
      }
    } else {
      emit(ApprovableDetailsError(result.message ?? 'Failed to load details'));
    }
  }

  Future<void> fetchCurrentLevelApprovers({required BuildContext context}) async {
    if (currentType == null || currentId == null || detailsModel == null) return;
    if (state is ApprovableDetailsLoaded) {
      final currentState = state as ApprovableDetailsLoaded;
      emit(currentState.copyWith(isLoadingApprovers: true));

      final result = await ApprovablesDetailsService.getCurrentLevelApprovers(
        context: context,
        type: currentType!,
        id: currentId!,
      );

      if (result.success && result.data != null) {
        emit(currentState.copyWith(
          activeApprovers: result.data,
          isLoadingApprovers: false,
        ));
      } else {
        emit(currentState.copyWith(isLoadingApprovers: false));
      }
    }
  }

  Future<void> askRemember({required BuildContext context}) async {
    if (currentType == null || currentId == null) return;
    emit(ApprovableActionSubmitting());

    final result = await ApprovablesDetailsService.askRemember(
      context: context,
      type: currentType!,
      id: currentId!,
    );

    if (result.success) {
      emit(ApprovableActionSuccess(result.message ?? 'Remember sent'));
      fetchDetails(context: context, type: currentType!, id: currentId!);
    } else {
      emit(ApprovableActionError(result.message ?? 'Failed to send remember'));
      if (detailsModel != null) {
        emit(ApprovableDetailsLoaded(details: detailsModel!));
      }
    }
  }

  Future<void> askIgnore({required BuildContext context}) async {
    if (currentType == null || currentId == null) return;
    emit(ApprovableActionSubmitting());

    final result = await ApprovablesDetailsService.askIgnore(
      context: context,
      type: currentType!,
      id: currentId!,
    );

    if (result.success) {
      emit(ApprovableActionSuccess(result.message ?? 'Ask ignore sent'));
      fetchDetails(context: context, type: currentType!, id: currentId!);
    } else {
      emit(ApprovableActionError(result.message ?? 'Failed to send ask ignore'));
      if (detailsModel != null) {
        emit(ApprovableDetailsLoaded(details: detailsModel!));
      }
    }
  }

  Future<void> submitTakeAction({
    required BuildContext context,
    required String approvableId,
    required String action, // approve | refuse
    String? reply,
    File? file,
  }) async {
    if (currentType == null || currentId == null) return;
    emit(ApprovableActionSubmitting());

    final result = await ApprovablesDetailsService.takeAction(
      context: context,
      type: currentType!,
      approvableId: approvableId,
      action: action,
      reply: reply,
      file: file,
    );

    if (result.success) {
      emit(ApprovableActionSuccess(result.message ?? 'Action taken successfully'));
      fetchDetails(context: context, type: currentType!, id: currentId!);
    } else {
      emit(ApprovableActionError(result.message ?? 'Failed to submit action'));
      if (detailsModel != null) {
        emit(ApprovableDetailsLoaded(details: detailsModel!));
      }
    }
  }

  Future<void> submitTakeActionAsSomeoneElse({
    required BuildContext context,
    required String approvableId,
    required String action, // approve | refuse
    required String employeeId,
    String? reply,
    File? file,
  }) async {
    if (currentType == null || currentId == null) return;
    emit(ApprovableActionSubmitting());

    final result = await ApprovablesDetailsService.takeActionAsSomeoneElse(
      context: context,
      type: currentType!,
      approvableId: approvableId,
      action: action,
      employeeId: employeeId,
      reply: reply,
      file: file,
    );

    if (result.success) {
      emit(ApprovableActionSuccess(result.message ?? 'Action taken successfully'));
      fetchDetails(context: context, type: currentType!, id: currentId!);
    } else {
      emit(ApprovableActionError(result.message ?? 'Failed to submit action'));
      if (detailsModel != null) {
        emit(ApprovableDetailsLoaded(details: detailsModel!));
      }
    }
  }
}
