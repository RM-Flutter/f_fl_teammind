import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/models/settings/user_settings.model.dart';
import 'package:app_test/core/services/backend_services/api_service/dio_api_service/shared.dart';
import 'package:app_test/core/services/localization_service.dart';
import 'package:app_test/core/widgets/details_loading/details_loading.widget.dart';
import 'package:app_test/features/requests/details/views/widgets/request_details_header_widget.dart';
import '../cubit/approvable_details_cubit.dart';
import '../cubit/approvable_details_state.dart';
import '../data/models/approvable_details_model.dart';
import 'widgets/custom_tabbar_view_approvable_details.dart';
import 'widgets/approvable_bottom_action_bar.dart';
import 'widgets/manager_take_action_modal.dart';

/// Controls which bottom sheet to auto-open when arriving from a swipe action.
enum AutoOpenAction { none, takeAction, takeActionAsSomeoneElse }

class ApprovableDetailsScreen extends StatefulWidget {
  final String type;
  final String id;
  final AutoOpenAction autoOpenAction;

  const ApprovableDetailsScreen({
    super.key,
    required this.type,
    required this.id,
    this.autoOpenAction = AutoOpenAction.none,
  });

  @override
  State<ApprovableDetailsScreen> createState() =>
      _ApprovableDetailsScreenState();
}

class _ApprovableDetailsScreenState extends State<ApprovableDetailsScreen> {
  bool _modalOpened = false; // guard: open modal only once

  void _tryOpenModal(BuildContext context, ApprovableDetailsCubit cubit,
      ApprovableDetailsModel details) {
    if (_modalOpened || widget.autoOpenAction == AutoOpenAction.none) return;
    _modalOpened = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: ManagerTakeActionModal(
            details: details,
            parentContext: context,
            isAsSomeoneElse:
                widget.autoOpenAction == AutoOpenAction.takeActionAsSomeoneElse,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = LocalizationService.isArabic(context: context);

    UserSettingsModel? userSettings;
    final jsonString = CacheHelper.getString("US1");
    if (jsonString != null && jsonString.isNotEmpty && jsonString != "") {
      try {
        final gCache = json.decode(jsonString) as Map<String, dynamic>;
        userSettings = UserSettingsModel.fromJson(gCache);
      } catch (_) {}
    }

    return Scaffold(
      body: BlocProvider<ApprovableDetailsCubit>(
        create: (context) => ApprovableDetailsCubit()
          ..fetchDetails(context: context, type: widget.type, id: widget.id),
        child: BlocConsumer<ApprovableDetailsCubit, ApprovableDetailsState>(
          listenWhen: (previous, current) {
            // Only trigger listener when we're going FROM loading → loaded
            // or on action states; ignore the isLoadingApprovers copyWith noise
            if (current is ApprovableDetailsLoaded &&
                previous is ApprovableDetailsLoaded) {
              // suppress repeated loads (e.g., isLoadingApprovers toggle)
              return false;
            }
            return true;
          },
          listener: (context, state) {
            if (state is ApprovableActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(AppColors.successGreen),
                ),
              );
            } else if (state is ApprovableActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Color(AppColors.failureRed),
                ),
              );
            } else if (state is ApprovableDetailsError) {
              final msg = state.message.toLowerCase();
              if (msg.contains('something went wrong') ||
                  msg.contains('حدث خطأ')) {
                context.goNamed(
                  AppRoutes.home.name,
                  pathParameters: {'lang': isArabic ? 'ar' : 'en'},
                );
              }
            } else if (state is ApprovableDetailsLoaded &&
                widget.autoOpenAction != AutoOpenAction.none) {
              final cubit = context.read<ApprovableDetailsCubit>();
              _tryOpenModal(context, cubit, state.details);
            }
          },
          builder: (context, state) {
            if (state is ApprovableDetailsLoading ||
                state is ApprovableDetailsInitial) {
              return const DetailsLoadingWidget();
            }

            if (state is ApprovableDetailsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ApprovableDetailsCubit>().fetchDetails(
                                context: context,
                                type: widget.type,
                                id: widget.id,
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.buttons),
                        ),
                        child:
                            Text(isArabic ? 'إعادة المحاولة' : 'Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final cubit = context.read<ApprovableDetailsCubit>();
            final details = cubit.detailsModel;

            if (details == null) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                RequestDetailsHeaderWidget(
                  uId: userSettings?.empId,
                  rId: details.employeeId,
                  height: kIsWeb ? 320 : 340,
                  request: details,
                ),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: kIsWeb ? 1100 : 1.sw,
                      ),
                      child:
                          CustomTabbarViewApprovableDetails(details: details),
                    ),
                  ),
                ),
                if (kIsWeb) const SizedBox(height: 20),
                ApprovableBottomActionBar(
                  details: details,
                  type: widget.type,
                  id: widget.id,
                  userSettings: userSettings,
                  cubit: cubit,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
