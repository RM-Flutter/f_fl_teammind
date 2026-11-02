import 'package:app_test/features/assistant/data/repos/user_data_repo.dart';
import 'package:flutter_test/flutter_test.dart';

// شكل مختصر لما يرسله start_app (EmpUserSettings و EmpUserTwoSettings في الباك اند).
final us1 = <String, dynamic>{
  'name': 'Abanob Magdy',
  'job_title': 'Flutter Developer',
  'email': 'a@example.com',
  'email_verified_at': '2024-01-01T10:00:00Z',
  'phone': '+201000000000',
  'phone_verified_at': null,
  'hire_date': '2023-03-15',
  'birthday': '1995-07-20',
  'role': ['employee', 'manager'],
  'department_id': 4,
  'department_info': {'id': 4, 'title': 'Mobile Team'},
  'departments': {
    '4': {'en': 'Mobile Team', 'ar': 'فريق الموبايل'},
    '7': {'en': 'QA', 'ar': 'الجودة'},
  },
  'is_manager_in': [7],
  'is_teamleader_in': [],
  'is_hr': false,
  'top_management': false,
  'insurance_number': {'title': {}, 'value': '123456', 'type': 'string'},
  'asset': {'title': {}, 'value': [{'name': 'MacBook Pro'}, {'name': 'iPhone 15'}], 'type': 'map'},
  'new_notification_count': 3,
};
final us2 = <String, dynamic>{
  'balance': {
    '1': {'title': {'en': 'Annual leave', 'ar': 'إجازة سنوية'}, 'take': 6, 'max': 21, 'available': 15},
    '2': {'title': {'en': 'Permission', 'ar': 'إذن'}, 'take': 2.5, 'max': -1, 'available': -1},
  },
  'worktime': {
    'working_hours_type': 'fixed_hours',
    'working_hours_from': '09:00:00',
    'working_hours_to': '17:00:00',
    'allowed_delay_minutes': '15',
  },
  'weekend': ['friday', 'saturday'],
  'holidays': [
    {'name': 'Old', 'from': '2026-01-01', 'to': '2026-01-01'},
    {'name': 'Revolution Day', 'from': '2026-11-20', 'to': '2026-11-21'},
    {'name': 'New Year', 'from': '2027-01-01', 'to': '2027-01-01'},
  ],
};
final now = DateTime(2026, 11, 2);

void main() {
  test('english values', () {
    final v = UserDataRepo.valuesFrom(us1, us2, 'en', now);
    expect(v['department'], 'Mobile Team');
    expect(v['managed_departments'], 'QA');
    expect(v['email_status'], 'verified');
    expect(v['phone_status'], 'not verified');
    expect(v['service_length'], '3 years, 7 months');
    expect(v['work_hours'], '09:00 to 17:00');
    expect(v['allowed_delay'], '15');
    expect(v['weekend'], 'Friday, Saturday');
    expect(v['next_holiday'], 'Revolution Day (2026-11-20 → 2026-11-21)');
    expect(v['balance'], contains('Annual leave: 15 of 21 left (used 6)'));
    expect(v['balance'], contains('Permission: unlimited (used 2.5)'));
    expect(v['insurance_number'], '123456');
    expect(v['assets'], '• MacBook Pro\n• iPhone 15');
    expect(v.containsKey('led_departments'), isFalse);
  });

  test('arabic values', () {
    final v = UserDataRepo.valuesFrom(us1, us2, 'ar', now);
    expect(v['managed_departments'], 'الجودة');
    expect(v['weekend'], 'الجمعة، السبت');
    expect(v['work_hours'], 'من 09:00 لـ 17:00');
    expect(v['balance'], contains('إجازة سنوية: فاضلك 15 من 21 (خدت 6)'));
    expect(v['balance'], contains('إذن: مفتوح'));
    expect(v['service_length'], '3 سنين و7 شهور');
  });

  test('department falls back to departments map, and translations win', () {
    final noInfo = {...us1}..remove('department_info');
    expect(UserDataRepo.valuesFrom(noInfo, us2, 'ar', now)['department'], 'فريق الموبايل');
    final withTr = {
      ...us1,
      'department_info': {
        'title': 'Mobile Team',
        'translations': [
          {'key': 'title.ar', 'value': 'فريق التطبيقات'}
        ]
      }
    };
    expect(UserDataRepo.valuesFrom(withTr, us2, 'ar', now)['department'], 'فريق التطبيقات');
  });

  test('fill drops lines with missing values', () {
    final v = UserDataRepo.valuesFrom(us1, us2, 'en', now);
    final out = UserDataRepo.fill(
        'Roles: {roles}.\nYou manage: {managed_departments}.\nTeam leader in: {led_departments}.', v);
    expect(out, 'Roles: employee, manager.\nYou manage: QA.');
    expect(UserDataRepo.fill('Leader: {led_departments}', v), isNull);
    expect(UserDataRepo.fill('no placeholders', v), 'no placeholders');
  });

  test('empty caches give only the clock values', () {
    expect(UserDataRepo.valuesFrom(const {}, const {}, 'en', now).keys.toSet(), {'time', 'today'});
  });

  test('clock and first name', () {
    final at = DateTime(2026, 11, 2, 15, 5);
    final en = UserDataRepo.valuesFrom(us1, us2, 'en', at);
    expect(en['time'], '3:05 PM');
    expect(en['today'], 'Monday, 2 November 2026');
    expect(en['first_name'], 'Abanob');
    final ar = UserDataRepo.valuesFrom(us1, us2, 'ar', at);
    expect(ar['time'], '3:05 العصر');
    expect(ar['today'], 'الاثنين 2 نوفمبر 2026');
    expect(UserDataRepo.valuesFrom(us1, us2, 'ar', DateTime(2026, 1, 1, 9))['time'], '9:00 الصبح');
  });
}
