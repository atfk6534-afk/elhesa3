import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_helper.dart';
import 'attendance_activity_screen.dart';

/// شاشة اختيار التاريخ، ثم اختيار النشاط لتسجيل أو عرض الحضور
class AttendanceDateScreen extends StatefulWidget {
  const AttendanceDateScreen({super.key});

  @override
  State<AttendanceDateScreen> createState() => _AttendanceDateScreenState();
}

class _AttendanceDateScreenState extends State<AttendanceDateScreen> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  static const _activityIcons = {
    'قداس الجمعة': Icons.church_rounded,
    'تسبحة الجمعة': Icons.music_note_rounded,
    'حصة الألحان الجمعة': Icons.library_music_rounded,
    'حصة الأربعاء': Icons.event_rounded,
    'حصة الاثنين': Icons.event_note_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الحضور')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          DateHelper.displayDateWithDay(_selectedDate),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Icon(Icons.edit_calendar_outlined, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('اختر النشاط', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: AppConstants.activities.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final activity = AppConstants.activities[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          child: Icon(
                            _activityIcons[activity] ?? Icons.event,
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(activity, style: const TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AttendanceActivityScreen(
                                date: _selectedDate,
                                activity: activity,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
