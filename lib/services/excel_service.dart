import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/student_model.dart';
import '../core/utils/name_helper.dart';

/// خدمة تصدير قائمة الشباب إلى ملف Excel، واستيراد قائمة من ملف Excel
class ExcelService {
  static const _uuid = Uuid();

  /// يُصدّر قائمة الشباب إلى ملف Excel ويعيد مسار الملف الناتج
  Future<String> exportStudents(List<StudentModel> students) async {
    final excel = Excel.createExcel();
    final sheet = excel['الشباب'];

    sheet.appendRow([
      TextCellValue('الاسم الثلاثي'),
      TextCellValue('الاسم الأول'),
      TextCellValue('رقم الهاتف'),
      TextCellValue('ملاحظات'),
    ]);

    for (final student in students) {
      sheet.appendRow([
        TextCellValue(student.fullName),
        TextCellValue(student.firstName),
        TextCellValue(student.phone),
        TextCellValue(student.notes),
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'students_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final path = '${dir.path}/$fileName';
    final fileBytes = excel.encode();
    final file = File(path);
    await file.writeAsBytes(fileBytes!);
    return path;
  }

  /// يستورد قائمة شباب من ملف Excel تم اختياره (المسار الكامل للملف)
  /// يتوقع نفس ترتيب الأعمدة الناتج عن exportStudents
  Future<List<StudentModel>> importStudents(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final List<StudentModel> result = [];

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table]!;
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isEmpty || row[0]?.value == null) continue;

        final fullName = row[0]?.value.toString().trim() ?? '';
        if (fullName.isEmpty) continue;

        final firstNameCell = row.length > 1 ? row[1]?.value.toString().trim() : null;
        final phone = row.length > 2 ? (row[2]?.value.toString().trim() ?? '') : '';
        final notes = row.length > 3 ? (row[3]?.value.toString().trim() ?? '') : '';

        final now = DateTime.now();
        result.add(
          StudentModel(
            id: _uuid.v4(),
            fullName: fullName,
            firstName: (firstNameCell != null && firstNameCell.isNotEmpty)
                ? firstNameCell
                : NameHelper.extractFirstName(fullName),
            phone: phone,
            notes: notes,
            createdAt: now,
            updatedAt: now,
            needsSync: true,
          ),
        );
      }
    }
    return result;
  }
}
