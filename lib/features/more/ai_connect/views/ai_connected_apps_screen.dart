import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/constants/app_strings.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/more/ai_connect/controllers/ai_connect_controller.dart';
import 'package:app_test/features/more/ai_connect/views/ai_connect_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// More → Connect ChatGPT / Claude → "Connected apps": the AI assistants
/// linked to this account, with a disconnect button for each.
class AiConnectedAppsScreen extends StatelessWidget {
  const AiConnectedAppsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AiConnectController(),
      child: const _ConnectedAppsView(),
    );
  }
}

class _ConnectedAppsView extends StatefulWidget {
  const _ConnectedAppsView();

  @override
  State<_ConnectedAppsView> createState() => _ConnectedAppsViewState();
}

class _ConnectedAppsViewState extends State<_ConnectedAppsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AiConnectController>().loadConnections(context);
    });
  }

  Future<void> _confirmDisconnect(AiConnectController c, AiConnection connection) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text(AppStrings.aiDisconnectTitle.tr()),
        content: Text(AppStrings.aiDisconnectConfirm.tr(namedArgs: {'app': connection.clientName})),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: Color(AppColors.failureRed)),
            child: Text(AppStrings.aiDisconnect.tr()),
          ),
        ],
      ),
    );
    if (yes == true && mounted) {
      await c.disconnect(context, connection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AiConnectController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AiConnectHeader(title: AppStrings.aiConnectedApps.tr()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => c.loadConnections(context),
                child: _body(c),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(AiConnectController c) {
    if (c.isConnectionsLoading && c.connections.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
      ]);
    }

    if (c.connections.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.link_off_rounded, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            c.errorMessage ?? AppStrings.aiNoConnections.tr(),
            textAlign: TextAlign.center,
            style: AppStyles.darkContent(context).copyWith(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: c.connections.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final connection = c.connections[i];
        final busy = c.disconnectingId == connection.id;
        return Container(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 8, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(AppColors.border)),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Color(AppColors.buttons).withValues(alpha: 0.1),
                child: Icon(Icons.smart_toy_outlined, color: Color(AppColors.buttons)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(connection.clientName,
                        style: AppStyles.darkContent(context).copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    _AccessBadge(canAct: connection.canAct),
                    const SizedBox(height: 6),
                    if (connection.connectedAt != null)
                      Text('${AppStrings.aiConnectedOn.tr()} ${connection.connectedAt}',
                          style: AppStyles.darkContent(context).copyWith(fontSize: 11, color: Colors.grey.shade600)),
                    Text(
                      '${AppStrings.aiLastUsed.tr()} ${connection.lastUsedAt ?? AppStrings.aiNeverUsed.tr()}',
                      style: AppStyles.darkContent(context).copyWith(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              busy
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : TextButton(
                      onPressed: c.disconnectingId == null ? () => _confirmDisconnect(c, connection) : null,
                      style: TextButton.styleFrom(foregroundColor: Color(AppColors.failureRed)),
                      child: Text(AppStrings.aiDisconnect.tr()),
                    ),
            ],
          ),
        );
      },
    );
  }
}

class _AccessBadge extends StatelessWidget {
  final bool canAct;
  const _AccessBadge({required this.canAct});

  @override
  Widget build(BuildContext context) {
    final color = canAct ? Color(AppColors.warningYellow) : Color(AppColors.successGreen);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        canAct ? AppStrings.aiAccessReadAct.tr() : AppStrings.aiAccessReadOnly.tr(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
