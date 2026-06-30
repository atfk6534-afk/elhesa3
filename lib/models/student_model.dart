import 'package:hive/hive.dart';

/// نموذج بيانات الشاب
/// يحتوي على جميع الحقول المطلوبة + حقول المزامنة (needsSync, isDeleted, updatedAt)
class StudentModel {
  final String id;
  String fullName;
  String firstName;
  String phone;
  String notes;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isDeleted;
  bool needsSync;

  StudentModel({
    required this.id,
    required this.fullName,
    required this.firstName,
    required this.phone,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.needsSync = true,
  });

  StudentModel copyWith({
    String? fullName,
    String? firstName,
    String? phone,
    String? notes,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? needsSync,
  }) {
    return StudentModel(
      id: id,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'firstName': firstName,
      'phone': phone,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'isDeleted': isDeleted,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      firstName: map['firstName'] as String,
      phone: map['phone'] as String,
      notes: (map['notes'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      needsSync: false,
    );
  }
}

/// Hive TypeAdapter يدوي (بدون الحاجة لـ build_runner)
class StudentModelAdapter extends TypeAdapter<StudentModel> {
  @override
  final int typeId = 0;

  @override
  StudentModel read(BinaryReader reader) {
    final map = reader.readMap();
    return StudentModel(
      id: map['id'] as String,
      fullName: map['fullName'] as String,
      firstName: map['firstName'] as String,
      phone: map['phone'] as String,
      notes: (map['notes'] as String?) ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      isDeleted: (map['isDeleted'] as bool?) ?? false,
      needsSync: (map['needsSync'] as bool?) ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, StudentModel obj) {
    writer.writeMap({
      'id': obj.id,
      'fullName': obj.fullName,
      'firstName': obj.firstName,
      'phone': obj.phone,
      'notes': obj.notes,
      'createdAt': obj.createdAt.millisecondsSinceEpoch,
      'updatedAt': obj.updatedAt.millisecondsSinceEpoch,
      'isDeleted': obj.isDeleted,
      'needsSync': obj.needsSync,
    });
  }
}
