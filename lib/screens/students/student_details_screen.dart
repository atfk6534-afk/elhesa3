import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import '../../widgets/stat_card.dart';

/// شاشة تفاصيل شاب: بياناته، إحصائياته، وسجل الحضور الكامل
class StudentDetailsScreen extends StatelessWidget {
  final String studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    final studentProvider = context.watch<StudentProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final student = studentProvider.getById(studentId);

    if (student == null) {
      return const Scaffold(body: Center(child: Text('هذا الشاب غير موجود')));
    }

    final stats = attendanceProvider.studentStats(studentId);
    final records = attendanceProvider.getAttendanceForStudent(studentId);

    // تجميع السجلات حسب التاريخ لعرضها كقائمة يومية
    final Map<String, List<dynamic>> byDate = {};
    for (final r in records) {
      byDate.putIfAbsent(r.dateKey, () => []).add(r);
    }
    final sortedDates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: Text(student.firstName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(student.phone, style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                  if (student.notes.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('ملاحظات: ${student.notes}', style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              StatCard(
                title: 'مرات الحضور',
                value: '${stats.present}',
                icon: Icons.check_circle,
                color: AppColors.present,
              ),
              StatCard(
                title: 'مرات الغياب',
                value: '${stats.absent}',
                icon: Icons.cancel,
                color: AppColors.absent,
              ),
              StatCard(
                title: 'نسبة الالتزام',
                value: '${stats.percentage.toStringAsFixed(0)}%',
                icon: Icons.percent,
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('سجل الحضور', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (sortedDates.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('لا يوجد سجل حضور بعد')),
            )
          else
            ...sortedDates.map((dateKey) {
              final dayRecords = byDate[dateKey]!;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateHelper.displayDateWithDay(DateHelper.fromKey(dateKey)),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...dayRecords.map((r) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Icon(
                                r.isPresent ? Icons.check_circle : Icons.cancel,
                                size: 18,
                                color: r.isPresent ? AppColors.present : AppColors.absent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${r.isPresent ? "حضر" : "غاب"} ${r.activity}',
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
