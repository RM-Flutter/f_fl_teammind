import 'package:app_test/core/constants/app_sizes.dart';
import 'package:app_test/core/constants/app_colors.dart';
import 'package:app_test/core/constants/app_design.dart';
import 'package:app_test/core/utils/app_styles.dart';
import 'package:app_test/core/widgets/app_status_badge.widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_test/core/services/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cv_hub_models.dart';

// Content of the three interview details tabs. The tab title already names the section,
// so the cards have no title of their own.

bool _has(String? v) => v != null && v.trim().isNotEmpty && v != 'null';

String _number(num? v) {
  if (v == null) return '';
  return NumberFormat.decimalPattern().format(v);
}

/// White card with the app's card radius, border and shadow.
class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const _Card({required this.child, this.padding = AppSpacing.cardPadding});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: AppBorders.card,
          boxShadow: AppShadows.card,
        ),
        child: child,
      );
}

/// Icon in a tinted circle, the leading of every row and tile here.
class _IconCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  const _IconCircle(this.icon, {this.size = 40});

  @override
  Widget build(BuildContext context) {
    final c = Color(AppColors.buttons);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: c, size: size * 0.5),
    );
  }
}

// ─── Candidate Info ─────────────────────────────────────────────────────────

/// Opens the mail / phone app. Where no app can open it (a simulator, a desktop browser without a
/// mail client) the value is copied instead and a short message says so, so the tap never does
/// nothing.
Future<void> _openContact(Uri uri, String value) async {
  var opened = false;
  try {
    opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    opened = false;
  }
  if (opened) return;
  await Clipboard.setData(ClipboardData(text: value));
  AppToast.showToast(msg: 'cannot_open_app_copied'.tr());
}

class CandidateInfoTab extends StatelessWidget {
  final CandidateModel? candidate;
  const CandidateInfoTab({super.key, required this.candidate});

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    final contacts = <Widget>[
      if (_has(c?.email))
        _ContactRow(
          icon: Icons.mail_outline_rounded,
          label: 'Email'.tr(),
          value: c!.email!,
          actionIcon: Icons.send_rounded,
          onTap: () => _openContact(Uri(scheme: 'mailto', path: c.email), c.email!),
        ),
      if (_has(c?.phone))
        _ContactRow(
          icon: Icons.phone_outlined,
          label: 'Phone'.tr(),
          value: c!.phone!,
          actionIcon: Icons.call_rounded,
          onTap: () => _openContact(
              Uri(scheme: 'tel', path: c.phone!.replaceAll(RegExp(r'[^0-9+]'), '')), c.phone!),
        ),
    ];

    final stats = <Widget>[
      if (c?.expectedSalary != null)
        _StatTile(
          icon: Icons.payments_outlined,
          label: 'Expected Salary'.tr(),
          value: _number(c!.expectedSalary),
        ),
      if (c?.yearsExperience != null)
        _StatTile(
          icon: Icons.timeline_rounded,
          label: 'Years of Experience'.tr(),
          value: _number(c!.yearsExperience),
        ),
      if (_has(c?.educationLevel))
        _StatTile(
          icon: Icons.school_outlined,
          label: 'Education'.tr(),
          value: c!.educationLevel!,
        ),
      if (_has(c?.employmentType))
        _StatTile(
          icon: Icons.badge_outlined,
          label: 'Employment Type'.tr(),
          value: c!.employmentType!,
        ),
    ];

    final statRows = <Widget>[];
    for (int i = 0; i < stats.length; i += 2) {
      if (statRows.isNotEmpty) statRows.add(const SizedBox(height: AppSpacing.cardGap));
      statRows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: stats[i]),
            const SizedBox(width: AppSpacing.cardGap),
            Expanded(child: i + 1 < stats.length ? stats[i + 1] : const SizedBox()),
          ],
        ),
      ));
    }

    return Column(
      children: [
        if (contacts.isNotEmpty)
          _Card(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.s14, vertical: AppSizes.s4),
            child: Column(
              children: [
                for (int i = 0; i < contacts.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  contacts[i],
                ],
              ],
            ),
          ),
        if (contacts.isNotEmpty && statRows.isNotEmpty)
          const SizedBox(height: AppSpacing.cardGap),
        ...statRows,
      ],
    );
  }
}

/// Email / phone row: icon, label over value, and a round action (mail / call) at the end.
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final IconData actionIcon;
  final VoidCallback onTap;

  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.actionIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.s12),
        child: Row(
          children: [
            _IconCircle(icon),
            const SizedBox(width: AppSizes.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                  const SizedBox(height: AppSizes.s2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.heading(context)
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.s8),
            Container(
              padding: const EdgeInsets.all(AppSizes.s8),
              decoration: BoxDecoration(
                color: Color(AppColors.buttons),
                shape: BoxShape.circle,
              ),
              child: Icon(actionIcon, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small card for one fact (salary, experience, ...): icon, label, value.
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(AppSizes.s14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconCircle(icon, size: 36),
          const SizedBox(height: AppSizes.s10),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
          const SizedBox(height: AppSizes.s2),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.heading(context).copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(AppColors.secondaryButton),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skills ─────────────────────────────────────────────────────────────────

class SkillsTab extends StatelessWidget {
  final List<SkillModel> skills;
  const SkillsTab({super.key, required this.skills});

  @override
  Widget build(BuildContext context) {
    final accent = Color(AppColors.buttons);
    return _Card(
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: [
          for (final s in skills)
            if (_has(s.name))
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.s12, vertical: AppSizes.s8),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: accent.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: accent),
                    const SizedBox(width: AppSizes.s6),
                    Text(
                      s.name!,
                      style: TextStyle(
                          color: Color(AppColors.secondaryButton),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ─── My Evaluation ──────────────────────────────────────────────────────────

class MyEvaluationTab extends StatelessWidget {
  final EvaluationModel? evaluation;
  const MyEvaluationTab({super.key, required this.evaluation});

  static Color _scoreColor(num? v) {
    final s = (v ?? 0).toDouble();
    if (s >= 75) return Color(AppColors.successGreen);
    if (s >= 50) return Color(AppColors.warningYellow);
    return Color(AppColors.failureRed);
  }

  static Color _recommendationColor(String? r) {
    final v = (r ?? '').toLowerCase();
    if (v.contains('accept')) return Color(AppColors.successGreen);
    if (v.contains('reject')) return Color(AppColors.failureRed);
    return Color(AppColors.warningYellow);
  }

  @override
  Widget build(BuildContext context) {
    final e = evaluation;
    if (e == null) {
      return _Card(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.s16, vertical: AppSizes.s32),
        child: Column(
          children: [
            _IconCircle(Icons.fact_check_outlined, size: 64),
            const SizedBox(height: AppSizes.s12),
            Text(
              'No evaluation submitted yet.'.tr(),
              textAlign: TextAlign.center,
              style: AppStyles.greyContent(context).copyWith(fontSize: 14),
            ),
          ],
        ),
      );
    }

    final overall = (e.overallScore ?? 0).toDouble();
    return Column(
      children: [
        // Overall score + recommendation.
        _Card(
          child: Row(
            children: [
              SizedBox(
                width: 84,
                height: 84,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: (overall / 100).clamp(0.0, 1.0),
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: _scoreColor(overall).withOpacity(0.12),
                        color: _scoreColor(overall),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _number(e.overallScore),
                          style: AppStyles.heading(context).copyWith(
                              fontSize: 22, fontWeight: FontWeight.bold, height: 1),
                        ),
                        Text('/100',
                            style: AppStyles.greyContent(context).copyWith(fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.s16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall Score'.tr(),
                        style: AppStyles.heading(context)
                            .copyWith(fontSize: 15, fontWeight: FontWeight.bold)),
                    if (_has(e.recommendation)) ...[
                      const SizedBox(height: AppSizes.s8),
                      Text('Recommendation'.tr(),
                          style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                      const SizedBox(height: AppSizes.s4),
                      AppStatusBadge(
                        label: e.recommendation!.tr(),
                        color: _recommendationColor(e.recommendation),
                        icon: Icons.thumb_up_alt_outlined,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.cardGap),
        // Technical / soft skills bars.
        _Card(
          child: Column(
            children: [
              _ScoreBar(label: 'Technical Score'.tr(), score: e.technicalScore, color: _scoreColor(e.technicalScore)),
              const SizedBox(height: AppSizes.s16),
              _ScoreBar(label: 'Soft Skills Score'.tr(), score: e.softSkillsScore, color: _scoreColor(e.softSkillsScore)),
            ],
          ),
        ),
        if (_has(e.notes)) ...[
          const SizedBox(height: AppSpacing.cardGap),
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _IconCircle(Icons.format_quote_rounded, size: 36),
                const SizedBox(width: AppSizes.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes'.tr(),
                          style: AppStyles.greyContent(context).copyWith(fontSize: 12)),
                      const SizedBox(height: AppSizes.s4),
                      Text(e.notes!,
                          style: AppStyles.heading(context)
                              .copyWith(fontSize: 14, fontWeight: FontWeight.w500, height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final num? score;
  final Color color;
  const _ScoreBar({required this.label, required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final v = (score ?? 0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label,
                  style: AppStyles.heading(context)
                      .copyWith(fontSize: 13.5, fontWeight: FontWeight.w600)),
            ),
            Text(
              '${_number(score)}/100',
              style: AppStyles.heading(context)
                  .copyWith(fontSize: 13.5, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.s8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: (v / 100).clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: color.withOpacity(0.12),
            color: color,
          ),
        ),
      ],
    );
  }
}
