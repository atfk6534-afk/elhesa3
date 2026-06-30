import 'package:hive/hive.dart';

/// نموذج سجل حضور واحد: شاب معين، في تاريخ معين، لنشاط معين
class AttendanceRecord {
  final String id; // studentId_dateKey_activity
  final String studentId;
  final String dateKey; // yyyy-MM-dd
  final String activity;
  bool isPresent;
  DateTime updatedAt;
  bool needsSync;
  bool isDeleted;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.dateKey,
    required this.activity,
    required this.isPresent,
    required this.updatedAt,
    this.needsSync = true,
    this.isDeleted = false,
  });

  static String buildId(String studentId, String dateKey, String activity) {
    return '${studentId}_${dateKey}_$activity';
  }

  AttendanceRecord copyWith({
    bool? isPresent,
    DateTime? updatedAt,
    bool? needsSync,
    bool? isDeleted,
  }) {
    return AttendanceRecord(
      id: id,
      studentId: studentId,
      dateKey: dateKey,
      activity: activity,
      isPresent: isPresent ?? this.isPresent,
      updatedAt: updatedAt ?? this.updatedAt,
      needsSync: needsSync ?? this.needsSync,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'dateKey': dateKey,
      'activity': activity,
      'isPresent': isPresent,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      dateKey: map['dateKey'] as String,
      activity: map['activity'] as String,
      isPresent: (map['isPresent'] as bool?) ?? false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      needsSync: false,
    );
  }
}

/// Hive TypeAdapter يدوي
class AttendanceRecordAdapter extends TypeAdapter<AttendanceRecord> {
  @override
  final int typeId = 1;

  @override
  AttendanceRecord read(BinaryReader reader) {
    final map = reader.readMap();
    return AttendanceRecord(
      id: map['id'] as String,
      studentId: map['studentId'] as String,
      dateKey: map['dateKey'] as String,
      activity: map['activity'] as String,
      isPresent: (map['isPresent'] as bool?) ?? false,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      needsSync: (map['needsSync'] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceRecord obj) {
    writer.writeMap({
      'id': obj.id,
      'studentId': obj.studentId,
      'dateKey': obj.dateKey,
      'activity': obj.activity,
      'isPresent': obj.isPresent,
      'updatedAt': obj.updatedAt.millisecondsSinceEpoch,
      'isDeleted': obj.isDeleted,
      'needsSync': obj.needsSync,
    });
  }
}
