import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/student_model.dart';
import '../../providers/student_provider.dart';
import '../../core/utils/name_helper.dart';

/// شاشة موحّدة لإضافة شاب جديد أو تعديل بيانات شاب موجود
class AddEditStudentScreen extends StatefulWidget {
  final StudentModel? student;

  const AddEditStudentScreen({super.key, this.student});

  bool get isEditing => student != null;

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _firstNameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  bool _firstNameEdited = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _fullNameController = TextEditingController(text: s?.fullName ?? '');
    _firstNameController = TextEditingController(text: s?.firstName ?? '');
    _phoneController = TextEditingController(text: s?.phone ?? '');
    _notesController = TextEditingController(text: s?.notes ?? '');
    _firstNameEdited = widget.isEditing;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFullNameChanged(String value) {
    if (!_firstNameEdited) {
      _firstNameController.text = NameHelper.extractFirstName(value);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<StudentProvider>();

    if (widget.isEditing) {
      final updated = widget.student!.copyWith(
        fullName: _fullNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
      );
      await provider.updateStudent(updated);
    } else {
      await provider.addStudent(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        notes: _notesController.text.trim(),
        customFirstName: _firstNameController.text.trim(),
      );
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.isEditing ? 'تعديل بيانات شاب' : 'إضافة شاب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'الاسم الثلاثي *'),
                  onChanged: _onFullNameChanged,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'الاسم الثلاثي مطلوب' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'الاسم الأول (يمكن تعديله)',
                    helperText: 'يُستخرج تلقائيًا من الاسم الثلاثي، ويمكن تغييره',
                  ),
                  onChanged: (_) => _firstNameEdited = true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف *'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'رقم الهاتف مطلوب';
                    if (v.trim().length < 8) return 'رقم الهاتف غير صحيح';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(widget.isEditing ? 'حفظ التعديلات' : 'إضافة الشاب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
