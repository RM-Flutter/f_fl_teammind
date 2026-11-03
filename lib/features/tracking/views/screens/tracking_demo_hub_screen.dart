import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/app_styles.dart';
import '../../data/dummy/tracking_dummy_data.dart';
import '../../data/models/tracking_status.enum.dart';
import '../widgets/add_manual_point_modal.dart';
import '../widgets/cancel_tracking_modal.dart';
import '../widgets/tracking_filter_chips.dart';
import '../widgets/tracking_map_view_dialog.dart';
import '../widgets/tracking_section_employee.dart';
import '../widgets/tracking_section_manager.dart';
import '../widgets/tracking_status_badge.dart';
import 'live_group_map_screen.dart';
import 'package:app_test/core/constants/app_design.dart';

class TrackingDemoHubScreen extends StatefulWidget {
  const TrackingDemoHubScreen({super.key});

  @override
  State<TrackingDemoHubScreen> createState() => _TrackingDemoHubScreenState();
}

class _TrackingDemoHubScreenState extends State<TrackingDemoHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TrackingFilterOption _selectedFilter = TrackingFilterOption.hasTracking;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(AppColors.scaffoldBackGround),
      body: Column(
        children: [
          // Curved Header AppBar matching TeamMind
          Container(
            decoration: BoxDecoration(
              color: Color(AppColors.secondaryButton), // 0xFF090B60
              image: const DecorationImage(
                image: AssetImage('assets/images/request-app-bar.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('tracking_system_design_preview'.tr(),
                                style: AppStyles.whiteHeading(context).copyWith(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text('employee_manager_group_map_screens_dummy_data'.tr(),
                                style: AppStyles.whiteContent(context).copyWith(
                                  fontSize: 11,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'group_live_map'.tr(),
                          icon: const Icon(Icons.map_outlined, color: Colors.white, size: 22),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const LiveGroupMapScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // TabBar
                  Container(
                    margin: const EdgeInsets.only(left: 14, right: 14, bottom: 14, top: 4),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
                      labelPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                        color: Color(AppColors.buttons),
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(text: 'employee_view'.tr()),
                        Tab(text: 'manager_view'.tr()),
                        Tab(text: 'design_system'.tr()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Employee View
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 12, bottom: 30),
                  child: Column(
                    children: [
                      _DemoInfoBanner(
                        title: 'employee_mode'.tr(),
                        subtitle: 'employee_can_start_stop_multiple_legs_record'.tr(),
                        actionLabel: 'open_full_map'.tr(),
                        onAction: () => TrackingMapViewDialog.show(
                          context,
                          title: 'task_route_map'.tr(),
                          titleEn: 'Task Route Map',
                          sessions: [
                            TrackingDummyData.session1,
                            TrackingDummyData.activeSession,
                          ],
                        ),
                      ),
                      TrackingSectionEmployee(
                        request: {'id': 101, 'type_id': 1},
                        isDateMatched: true,
                      ),
                    ],
                  ),
                ),

                // 2. Manager View
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 12, bottom: 30),
                  child: Column(
                    children: [
                      _DemoInfoBanner(
                        title: 'manager_hr_mode'.tr(),
                        subtitle: 'displays_actual_active_hours_leg_count_route'.tr(),
                        actionLabel: 'group_live_map_2'.tr(),
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LiveGroupMapScreen()),
                          );
                        },
                      ),
                      TrackingSectionManager(
                        request: {'id': 101, 'type_id': 1},
                        isAdmin: true,
                      ),
                    ],
                  ),
                ),

                // 3. Design System & Components Gallery
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Direct Screen Navigators
                      Text('full_screens'.tr(),
                        style: AppStyles.heading(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.titleText),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(AppColors.buttons),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const LiveGroupMapScreen()),
                          );
                        },
                        icon: const Icon(Icons.map, color: Colors.white),
                        label: Text('open_field_team_live_group_map'.tr(),
                          style: AppStyles.whiteContent(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Status Badges Gallery
                      Text('tracking_status_badges_gallery'.tr(),
                        style: AppStyles.heading(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.titleText),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Color(AppColors.border)),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: RequestTrackingStatus.values
                              .where((s) => s != RequestTrackingStatus.notRequired)
                              .map((s) => TrackingStatusBadge(status: s))
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Filter Chips Demo
                      Text('request_filter_chips'.tr(),
                        style: AppStyles.heading(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.titleText),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(color: Color(AppColors.border)),
                        ),
                        child: TrackingFilterChips(
                          selected: _selectedFilter,
                          onSelected: (val) => setState(() => _selectedFilter = val),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Modals & Dialogs Triggers
                      Text('modals_dialogs'.tr(),
                        style: AppStyles.heading(context).copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(AppColors.titleText),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                                side: BorderSide(color: Color(AppColors.buttons)),
                              ),
                              onPressed: () {
                                AddManualPointModal.show(
                                  context,
                                  onSubmit: (lbl) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('point_recorded'.tr(namedArgs: {'lbl': '$lbl'}),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                              label: Text('manual_point_modal'.tr(),
                                style: const TextStyle(fontSize: 11.5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                                side: BorderSide(color: Color(AppColors.failureRed)),
                              ),
                              onPressed: () {
                                CancelTrackingModal.show(
                                  context,
                                  onConfirm: (scope) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('cancellation_confirmed'.tr(namedArgs: {'scope': '$scope'}),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.cancel_outlined, size: 18, color: Color(AppColors.failureRed)),
                              label: Text('cancel_modal'.tr(),
                                style: TextStyle(fontSize: 11.5, color: Color(AppColors.failureRed)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          side: BorderSide(color: Color(AppColors.secondaryButton)),
                        ),
                        onPressed: () {
                          TrackingMapViewDialog.show(
                            context,
                            title: 'field_mission_route_map'.tr(),
                            titleEn: 'Field Mission Route Map',
                            sessions: [
                              TrackingDummyData.session1,
                              TrackingDummyData.activeSession,
                            ],
                          );
                        },
                        icon: const Icon(Icons.route_outlined, size: 18),
                        label: Text('open_single_request_route_map_dialog'.tr(),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoInfoBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  const _DemoInfoBanner({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(AppColors.buttons).withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Color(AppColors.buttons).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Color(AppColors.buttons),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.info_outline, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.content(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: Color(AppColors.titleText),
                  ),
                ),
                Text(
                  subtitle,
                  style: AppStyles.subtitleContent(context).copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              backgroundColor: Color(AppColors.buttons),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
