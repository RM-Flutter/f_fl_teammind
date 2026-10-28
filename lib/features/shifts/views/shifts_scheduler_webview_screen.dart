import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_constants.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/routing/app_router.dart';
import 'package:app_test/core/services/app_config_service.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/webview_wrapper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShiftsSchedulerWebViewScreen extends StatefulWidget {
  const ShiftsSchedulerWebViewScreen({super.key});

  @override
  State<ShiftsSchedulerWebViewScreen> createState() =>
      _ShiftsSchedulerWebViewScreenState();
}

class _ShiftsSchedulerWebViewScreenState
    extends State<ShiftsSchedulerWebViewScreen> {
  int _reloadKey = 0;

  String _buildSchedulerUrl(BuildContext context) {
    final appConfigService =
        Provider.of<AppConfigService>(context, listen: false);
    final rawToken = appConfigService.token;
    final cleanToken = rawToken
        .replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '')
        .trim();
    final cleanBase = AppConstants.base.replaceAll(RegExp(r'/+$'), '');
    return "$cleanBase/frontend/shifts/$cleanToken/scheduler";
  }

  @override
  Widget build(BuildContext context) {
    final url = _buildSchedulerUrl(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(AppColors.secondaryButton),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(
                AppRoutes.home.name,
                pathParameters: {'lang': context.locale.languageCode},
              );
            }
          },
        ),
        title: Text(
          AppStrings.shiftsSchedule.tr(),
          style: AppStyles.heading(context).copyWith(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _reloadKey++;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: PlatformWebView(
          key: ValueKey('shifts_scheduler_$_reloadKey'),
          url: url,
          onNavigationRequest: (dynamic request) {
            try {
              final String navUrl = request.url?.toString() ?? '';
              final uri = Uri.tryParse(navUrl);
              final action = uri?.queryParameters['action'];
              if (action == 'close') {
                if (context.canPop()) {
                  context.pop(true);
                }
                return NavigationDecision.prevent;
              } else if (action == 'go_home') {
                context.goNamed(
                  AppRoutes.home.name,
                  pathParameters: {'lang': context.locale.languageCode},
                );
                return NavigationDecision.prevent;
              }
            } catch (_) {}
            return NavigationDecision.navigate;
          },
        ),
      ),
    );
  }
}
