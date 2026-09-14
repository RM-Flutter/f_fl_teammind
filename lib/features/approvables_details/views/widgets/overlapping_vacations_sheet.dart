import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/features/approvables_details/data/models/approvable_details_model.dart';
import 'package:app_test/features/approvables_details/data/services/approvables_details_service.dart';

/// Shows a bottom sheet with the list of overlapping vacations
/// for a given approvable request id.
Future<void> showOverlappingVacationsSheet({
  required BuildContext context,
  required String approvableId,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OverlappingVacationsSheet(
      approvableId: approvableId,
      parentContext: context,
    ),
  );
}

class _OverlappingVacationsSheet extends StatefulWidget {
  final String approvableId;
  final BuildContext parentContext;
  const _OverlappingVacationsSheet({
    required this.approvableId,
    required this.parentContext,
  });

  @override
  State<_OverlappingVacationsSheet> createState() =>
      _OverlappingVacationsSheetState();
}

class _OverlappingVacationsSheetState
    extends State<_OverlappingVacationsSheet> {
  bool _loading = true;
  String? _error;
  List<OverlappingVacationModel> _items = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final result = await ApprovablesDetailsService.getOverlappingVacations(
      context: widget.parentContext,
      id: widget.approvableId,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.success) {
        _items = result.data ?? [];
      } else {
        _error = result.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle bar
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(AppColors.warningYellow).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.people_alt_rounded,
                      color: Color(AppColors.warningYellow),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'overlapping_vacations'.tr(),
                          style: AppStyles.heading(context).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!_loading && _items.isNotEmpty)
                          Text(
                            '${_items.length} ${'overlapping_found'.tr()}',
                            style: AppStyles.greyContent(context)
                                .copyWith(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _ErrorState(error: _error!)
                      : _items.isEmpty
                          ? _EmptyState()
                          : ListView.separated(
                              controller: controller,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _items.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (_, i) =>
                                  _VacationCard(item: _items[i]),
                            ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Vacation card ─────────────────────────────────────────────────────────────
class _VacationCard extends StatelessWidget {
  final OverlappingVacationModel item;
  const _VacationCard({required this.item});

  Color get _statusColor {
    switch (item.status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF2D6A4F);
      case 'pending':
      case 'waiting':
        return const Color(0xFFFCA652);
      case 'refused':
      case 'rejected':
        return const Color(0xFFC72C41);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: _statusColor.withOpacity(0.2)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Color strip
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee row
                    Row(
                      children: [
                        // Avatar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: item.employeeAvatar?.isNotEmpty == true
                              ? CachedNetworkImage(
                                  imageUrl: item.employeeAvatar!,
                                  width: 36,
                                  height: 36,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) =>
                                      _AvatarPlaceholder(name: item.employeeName),
                                )
                              : _AvatarPlaceholder(name: item.employeeName),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.employeeName ?? '',
                                style: AppStyles.blackContent(context).copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              if (item.jobTitle?.isNotEmpty == true)
                                Text(
                                  item.jobTitle!,
                                  style: AppStyles.greyContent(context)
                                      .copyWith(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (item.status ?? '').tr().toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 10),

                    // Details row
                    Wrap(
                      spacing: 16,
                      runSpacing: 6,
                      children: [
                        // Type
                        if (item.typeName?.isNotEmpty == true)
                          _InfoChip(
                            icon: Icons.beach_access_rounded,
                            label: item.typeName!,
                          ),
                        // Duration
                        if (item.duration != null)
                          _InfoChip(
                            icon: Icons.timelapse_rounded,
                            label: '${item.duration} ${item.unit?.tr() ?? ''}',
                          ),
                        // Department
                        if (item.departmentName?.isNotEmpty == true)
                          _InfoChip(
                            icon: Icons.apartment_rounded,
                            label: item.departmentName!,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Date range
                    if (item.dateFrom?.isNotEmpty == true)
                      Row(
                        children: [
                          Icon(Icons.date_range_rounded,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(
                            '${_fmt(item.dateFrom)}  →  ${_fmt(item.dateTo)}',
                            style: AppStyles.greyContent(context)
                                .copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                    // Reason
                    if (item.reason?.isNotEmpty == true) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.notes_rounded,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              item.reason!,
                              style: AppStyles.greyContent(context)
                                  .copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }
}

// ── Info chip ──────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppStyles.greyContent(context)
              .copyWith(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

// ── Avatar placeholder ─────────────────────────────────────────────────────────
class _AvatarPlaceholder extends StatelessWidget {
  final String? name;
  const _AvatarPlaceholder({this.name});

  @override
  Widget build(BuildContext context) {
    final initial = (name?.isNotEmpty == true) ? name![0].toUpperCase() : '?';
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.buttons),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_available_rounded,
              size: 52, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'no_overlapping_vacations'.tr(),
            style: AppStyles.greyContent(context).copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String error;
  const _ErrorState({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(error,
                textAlign: TextAlign.center,
                style: AppStyles.greyContent(context).copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
