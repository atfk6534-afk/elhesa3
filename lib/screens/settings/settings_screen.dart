import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../services/excel_service.dart';
import '../../services/backup_service.dart';
import '../../services/local_db_service.dart';
import '../../core/constants/app_colors.dart';
import 'manage_servants_screen.dart';

/// شاشة الإعدادات: رسالة واتساب، تصدير/استيراد Excel، نسخ احتياطي، مظهر التطبيق
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _excelService = ExcelService();
  bool _isBusy = false;

  Future<void> _editWhatsappMessage() async {
    final settings = context.read<SettingsProvider>();
    final controller = TextEditingController(text: settings.whatsappMessage);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل رسالة واتساب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('استخدم {name} ليتم استبدالها باسم الشاب الأول', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 10),
            TextField(controller: controller, maxLines: 4),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      await settings.updateWhatsappMessage(result.trim());
    }
  }

  Future<void> _exportExcel() async {
    setState(() => _isBusy = true);
    try {
      final students = context.read<StudentProvider>().allStudents;
      final path = await _excelService.exportStudents(students);
      await Share.shareXFiles([XFile(path)], text: 'تصدير بيانات الشباب');
    } catch (e) {
      _showError('فشل التصدير: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _importExcel() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result == null || result.files.single.path == null) return;
    setState(() => _isBusy = true);
    try {
      final imported = await _excelService.importStudents(result.files.single.path!);
      final provider = context.read<StudentProvider>();
      for (final student in imported) {
        await provider.addStudent(
          fullName: student.fullName,
          phone: student.phone,
          notes: student.notes,
          customFirstName: student.firstName,
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('تم استيراد ${imported.length} شاب بنجاح')));
      }
    } catch (e) {
      _showError('فشل الاستيراد: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isBusy = true);
    try {
      final backupService = BackupService(LocalDbService());
      final path = await backupService.createBackup();
      await Share.shareXFiles([XFile(path)], text: 'نسخة احتياطية');
    } catch (e) {
      _showError('فشل إنشاء النسخة الاحتياطية: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة نسخة احتياطية'),
        content: const Text('سيتم استبدال جميع البيانات الحالية بالبيانات الموجودة في النسخة الاحتياطية. هل تريد المتابعة؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('متابعة')),
        ],
      ),
    );
    if (confirmed != true) return;

    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result == null || result.files.single.path == null) return;

    setState(() => _isBusy = true);
    try {
      final backupService = BackupService(LocalDbService());
      await backupService.restoreBackup(result.files.single.path!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم استعادة النسخة الاحتياطية بنجاح')));
      }
    } catch (e) {
      _showError('فشل الاستعادة: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: AppColors.absent));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: AbsorbPointer(
        absorbing: _isBusy,
        child: Opacity(
          opacity: _isBusy ? 0.6 : 1,
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (isAdmin) ...[
                _sectionTitle('عام'),
                ListTile(
                  leading: const Icon(Icons.message_outlined),
                  title: const Text('تعديل رسالة واتساب'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: _editWhatsappMessage,
                ),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined),
                  title: const Text('إدارة الخدام'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ManageServantsScreen()),
                  ),
                ),
                const Divider(),
                _sectionTitle('البيانات'),
                ListTile(
                  leading: const Icon(Icons.file_upload_outlined),
                  title: const Text('تصدير Excel'),
                  onTap: _exportExcel,
                ),
                ListTile(
                  leading: const Icon(Icons.file_download_outlined),
                  title: const Text('استيراد Excel'),
                  onTap: _importExcel,
                ),
                ListTile(
                  leading: const Icon(Icons.backup_outlined),
                  title: const Text('إنشاء نسخة احتياطية'),
                  onTap: _createBackup,
                ),
                ListTile(
                  leading: const Icon(Icons.restore_outlined),
                  title: const Text('استعادة النسخة الاحتياطية'),
                  onTap: _restoreBackup,
                ),
                const Divider(),
              ],
              _sectionTitle('المظهر'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('الوضع الليلي'),
                value: settings.isDarkMode,
                onChanged: settings.toggleDarkMode,
              ),
              ListTile(
                leading: const Icon(Icons.text_fields_rounded),
                title: const Text('حجم الخط'),
                subtitle: Slider(
                  value: settings.fontScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: settings.fontScale.toStringAsFixed(1),
                  onChanged: settings.setFontScale,
                ),
              ),
              if (_isBusy) const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }
}
