/// ثوابت عامة للتطبيق: أسماء الأنشطة، مفاتيح التخزين المحلي، إلخ
class AppConstants {
  AppConstants._();

  static const String appName = 'متابعة حضور حصة ألحان';

  /// أنشطة الحضور المتاحة
  static const List<String> activities = [
    'قداس الجمعة',
    'تسبحة الجمعة',
    'حصة الألحان الجمعة',
    'حصة الأربعاء',
    'حصة الاثنين',
  ];

  // Hive boxes
  static const String studentsBox = 'students_box';
  static const String attendanceBox = 'attendance_box';
  static const String settingsBox = 'settings_box';
  static const String pendingOpsBox = 'pending_ops_box';

  // Firestore collections
  static const String studentsCollection = 'students';
  static const String attendanceCollection = 'attendance';
  static const String usersCollection = 'users';
  static const String settingsCollection = 'app_settings';

  // SharedPreferences keys
  static const String keyDarkMode = 'dark_mode';
  static const String keyFontScale = 'font_scale';
  static const String keyWhatsappMessage = 'whatsapp_message';

  static const String defaultWhatsappMessage =
      'أهلاً يا {name} ❤️\nافتقدناك النهارده في الحصة، مستنيين نشوفك الأسبوع الجاي بإذن الله.';
}
