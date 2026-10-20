import 'package:flutter/material.dart';
import '../models/employee_tracking_summary.model.dart';
import '../models/tracking_point.model.dart';
import '../models/tracking_session.model.dart';
import '../models/tracking_status.enum.dart';

class TrackingDummyData {
  /// Palette of 10 distinct colors matching TeamMind's design system
  static const List<Color> palette = [
    Color(0xFF3389EE), // 0: Primary Button Blue
    Color(0xff2D6A4F), // 1: Success Green
    Color(0xffFCA652), // 2: Warning Orange
    Color(0xff9C4995), // 3: Purple
    Color(0xff3AC0E5), // 4: Light Cyan
    Color(0xff2C376C), // 5: Navy Blue
    Color(0xffc72c41), // 6: Failure Red
    Color(0xffAE702B), // 7: Golden Brown (oC2)
    Color(0xff606060), // 8: Slate Gray
    Color(0xFF00A1FF), // 9: Bright Sky Blue
  ];

  static Color getEmployeeColor(int index) {
    return palette[index % palette.length];
  }

  // =========================================================
  // Request 101 - Employee 5 (أحمد محمود / Ahmed Mahmoud)
  // =========================================================

  static final TrackingPointModel session1Start = TrackingPointModel(
    clientPointId: 'pt-1001-start',
    latitude: 30.0444,
    longitude: 31.2357,
    recordedAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    accuracy: 10.0,
    pointType: 'auto',
    label: 'بداية الجلسة الأولى',
    labelEn: 'Leg 1 Start Point',
    isStartPoint: true,
  );

  static final TrackingPointModel session1Manual1 = TrackingPointModel(
    clientPointId: 'pt-1001-m1',
    latitude: 30.0480,
    longitude: 31.2390,
    recordedAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
    accuracy: 8.0,
    pointType: 'manual',
    label: 'زيارة المعرض الرئيسي',
    labelEn: 'Main Showroom Visit',
  );

  static final TrackingPointModel session1End = TrackingPointModel(
    clientPointId: 'pt-1001-end',
    latitude: 30.0520,
    longitude: 31.2410,
    recordedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    accuracy: 12.0,
    pointType: 'auto',
    label: 'انتهاء الجلسة الأولى',
    labelEn: 'Leg 1 End Point',
    isEndPoint: true,
  );

  static final TrackingSessionModel session1 = TrackingSessionModel(
    id: 1001,
    requestId: 101,
    employeeId: 5,
    startedAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    endedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 45)),
    status: TrackingSessionStatus.completed,
    stopSource: 'manual',
    pointsCount: 85,
    manualPointsCount: 1,
    durationMinutes: 105,
    points: [
      session1Start,
      TrackingPointModel(
        clientPointId: 'pt-1001-2',
        latitude: 30.0460,
        longitude: 31.2370,
        recordedAt: DateTime.now().subtract(const Duration(hours: 4)),
        accuracy: 9.0,
      ),
      session1Manual1,
      TrackingPointModel(
        clientPointId: 'pt-1001-3',
        latitude: 30.0500,
        longitude: 31.2400,
        recordedAt: DateTime.now().subtract(const Duration(hours: 3, minutes: 15)),
        accuracy: 11.0,
      ),
      session1End,
    ],
  );

  static final TrackingPointModel session2Start = TrackingPointModel(
    clientPointId: 'pt-1002-start',
    latitude: 30.0530,
    longitude: 31.2420,
    recordedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    accuracy: 8.5,
    pointType: 'auto',
    label: 'بداية الجلسة الثانية',
    labelEn: 'Leg 2 Start Point',
    isStartPoint: true,
  );

  static final TrackingPointModel session2Manual1 = TrackingPointModel(
    clientPointId: 'pt-1002-m1',
    latitude: 30.0560,
    longitude: 31.2440,
    recordedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
    accuracy: 7.0,
    pointType: 'manual',
    label: 'وصلت عند العميل 📍',
    labelEn: 'Arrived at Client 📍',
  );

  static final TrackingPointModel session2Manual2 = TrackingPointModel(
    clientPointId: 'pt-1002-m2',
    latitude: 30.0595,
    longitude: 31.2465,
    recordedAt: DateTime.now().subtract(const Duration(minutes: 10)),
    accuracy: 9.0,
    pointType: 'manual',
    label: 'انتهاء الاجتماع وتسليم العقد 📌',
    labelEn: 'Meeting Ended & Contract Delivered 📌',
  );

  static final TrackingSessionModel activeSession = TrackingSessionModel(
    id: 1002,
    requestId: 101,
    employeeId: 5,
    startedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
    status: TrackingSessionStatus.active,
    lastPointAt: DateTime.now().subtract(const Duration(minutes: 2)),
    pointsCount: 42,
    manualPointsCount: 2,
    durationMinutes: 80,
    points: [
      session2Start,
      TrackingPointModel(
        clientPointId: 'pt-1002-1',
        latitude: 30.0545,
        longitude: 31.2430,
        recordedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 18)),
        accuracy: 9.0,
      ),
      session2Manual1,
      TrackingPointModel(
        clientPointId: 'pt-1002-2',
        latitude: 30.0580,
        longitude: 31.2450,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 30)),
        accuracy: 8.0,
      ),
      session2Manual2,
      TrackingPointModel(
        clientPointId: 'pt-1002-current',
        latitude: 30.0610,
        longitude: 31.2480,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        accuracy: 6.5,
      ),
    ],
  );

  // =========================================================
  // Group of 10 Employees for Live Group Map (Bilingual)
  // =========================================================

  static final List<EmployeeTrackingSummaryModel> dummyEmployees = [
    EmployeeTrackingSummaryModel(
      employeeId: 5,
      employeeName: 'أحمد محمود',
      employeeNameEn: 'Ahmed Mahmoud',
      departmentName: 'المبيعات الميدانية',
      departmentNameEn: 'Field Sales',
      colorIndex: 0,
      status: 'active',
      activeSession: activeSession,
      lastPoint: session2Manual2,
      lastUpdatedAgoSeconds: 120, // 2 minutes ago
      sessions: [session1, activeSession],
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 7,
      employeeName: 'سارة علي',
      employeeNameEn: 'Sara Ali',
      departmentName: 'خدمة العملاء والدعم',
      departmentNameEn: 'Customer Support',
      colorIndex: 1,
      status: 'completed',
      activeSession: null,
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-sara-last',
        latitude: 30.0250,
        longitude: 31.2100,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        accuracy: 10.0,
        label: 'تسليم شحنة الدعم',
        labelEn: 'Support Shipment Handover',
      ),
      lastUpdatedAgoSeconds: 2700,
      sessions: [
        TrackingSessionModel(
          id: 1005,
          requestId: 106,
          employeeId: 7,
          startedAt: DateTime.now().subtract(const Duration(hours: 3)),
          endedAt: DateTime.now().subtract(const Duration(minutes: 45)),
          status: TrackingSessionStatus.completed,
          durationMinutes: 135,
          pointsCount: 90,
          manualPointsCount: 2,
        ),
      ],
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 9,
      employeeName: 'محمد خالد',
      employeeNameEn: 'Mohamed Khaled',
      departmentName: 'الصيانة الميدانية',
      departmentNameEn: 'Field Maintenance',
      colorIndex: 2,
      status: 'active',
      activeSession: TrackingSessionModel(
        id: 1008,
        requestId: 108,
        employeeId: 9,
        startedAt: DateTime.now().subtract(const Duration(minutes: 50)),
        status: TrackingSessionStatus.active,
        durationMinutes: 50,
        pointsCount: 28,
        manualPointsCount: 1,
      ),
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-khaled-m1',
        latitude: 30.0700,
        longitude: 31.2800,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        accuracy: 8.0,
        pointType: 'manual',
        label: 'بدء صيانة خادم العميل',
        labelEn: 'Started Client Server Repair',
      ),
      lastUpdatedAgoSeconds: 300,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 12,
      employeeName: 'فاطمة حسن',
      employeeNameEn: 'Fatma Hassan',
      departmentName: 'التسويق الخارجي',
      departmentNameEn: 'Outdoor Marketing',
      colorIndex: 3,
      status: 'offline',
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-fatma-last',
        latitude: 30.0100,
        longitude: 31.2050,
        recordedAt: DateTime.now().subtract(const Duration(hours: 2)),
        accuracy: 25.0,
        label: 'زيارة موقع الحملة',
        labelEn: 'Campaign Site Visit',
      ),
      lastUpdatedAgoSeconds: 7200,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 15,
      employeeName: 'عمر يوسف',
      employeeNameEn: 'Omar Youssef',
      departmentName: 'فني شبكات',
      departmentNameEn: 'Network Technician',
      colorIndex: 4,
      status: 'active',
      activeSession: TrackingSessionModel(
        id: 1010,
        requestId: 110,
        employeeId: 15,
        startedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 10)),
        status: TrackingSessionStatus.active,
        durationMinutes: 130,
        pointsCount: 65,
        manualPointsCount: 1,
      ),
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-omar-m1',
        latitude: 30.0820,
        longitude: 31.3200,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 1)),
        accuracy: 5.0,
        pointType: 'manual',
        label: 'فحص الكابينة الرئيسية 📡',
        labelEn: 'Main Cabinet Check 📡',
      ),
      lastUpdatedAgoSeconds: 60,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 18,
      employeeName: 'ريم عبد الله',
      employeeNameEn: 'Reem Abdullah',
      departmentName: 'استشارات قانونية',
      departmentNameEn: 'Legal Advisory',
      colorIndex: 5,
      status: 'completed',
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-reem-last',
        latitude: 30.0380,
        longitude: 31.2210,
        recordedAt: DateTime.now().subtract(const Duration(hours: 1)),
        accuracy: 12.0,
        label: 'مجمع المحاكم',
        labelEn: 'Courts Complex',
      ),
      lastUpdatedAgoSeconds: 3600,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 21,
      employeeName: 'طارق إبراهيم',
      employeeNameEn: 'Tarek Ibrahim',
      departmentName: 'اللوجستيات والنقل',
      departmentNameEn: 'Logistics & Transport',
      colorIndex: 6,
      status: 'active',
      activeSession: TrackingSessionModel(
        id: 1014,
        requestId: 114,
        employeeId: 21,
        startedAt: DateTime.now().subtract(const Duration(minutes: 35)),
        status: TrackingSessionStatus.active,
        durationMinutes: 35,
        pointsCount: 20,
      ),
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-tarek-m',
        latitude: 30.0650,
        longitude: 31.2600,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        accuracy: 10.0,
        label: 'نقطة التحميل 📦',
        labelEn: 'Loading Station 📦',
      ),
      lastUpdatedAgoSeconds: 180,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 24,
      employeeName: 'منى السيد',
      employeeNameEn: 'Mona El-Sayed',
      departmentName: 'المبيعات الخارجية',
      departmentNameEn: 'External Sales',
      colorIndex: 7,
      status: 'no_active_tracking',
      lastUpdatedAgoSeconds: null,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 27,
      employeeName: 'حسام مصطفى',
      employeeNameEn: 'Hossam Mostafa',
      departmentName: 'فريق التوزيع',
      departmentNameEn: 'Distribution Team',
      colorIndex: 8,
      status: 'active',
      activeSession: TrackingSessionModel(
        id: 1018,
        requestId: 118,
        employeeId: 27,
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: TrackingSessionStatus.active,
        durationMinutes: 60,
        pointsCount: 38,
      ),
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-hossam-m',
        latitude: 30.0400,
        longitude: 31.2750,
        recordedAt: DateTime.now().subtract(const Duration(minutes: 8)),
        accuracy: 11.0,
        label: 'تسليم الطلب رقم #4501',
        labelEn: 'Order Handover #4501',
      ),
      lastUpdatedAgoSeconds: 480,
    ),
    EmployeeTrackingSummaryModel(
      employeeId: 30,
      employeeName: 'نورا عادل',
      employeeNameEn: 'Noura Adel',
      departmentName: 'مراقبة الجودة',
      departmentNameEn: 'Quality Control',
      colorIndex: 9,
      status: 'completed',
      lastPoint: TrackingPointModel(
        clientPointId: 'pt-noura-last',
        latitude: 30.0510,
        longitude: 31.2180,
        recordedAt: DateTime.now().subtract(const Duration(hours: 3)),
        accuracy: 14.0,
        label: 'فحص الفرع الخامس',
        labelEn: 'Branch 5 Inspection',
      ),
      lastUpdatedAgoSeconds: 10800,
    ),
  ];
}
