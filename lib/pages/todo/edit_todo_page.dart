import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/services/todo_services.dart';
import 'package:katahari/models/todo_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constant/app_colors.dart';

class EditTodoPage extends StatefulWidget {
  final Todo todo;

  const EditTodoPage({super.key, required this.todo});

  @override
  State<EditTodoPage> createState() => _EditTodoPageState();
}

class _EditTodoPageState extends State<EditTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final TodoService _service = TodoService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String selectedLabel = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isSaving = false;

  final List<Map<String, dynamic>> labelOptions = [
    {'label': 'Work', 'icon': Icons.work_outline, 'color': AppColors.button},
    {'label': 'Personal', 'icon': Icons.person_outline, 'color': Color(0xFF9C6BFF)},
    {'label': 'Shopping', 'icon': Icons.shopping_cart_outlined, 'color': AppColors.merah},
    {'label': 'Study', 'icon': Icons.school_outlined, 'color': AppColors.screen2},
    {'label': 'Health', 'icon': Icons.favorite_border, 'color': AppColors.screen1},
    {'label': 'Family', 'icon': Icons.home_outlined, 'color': AppColors.kream},
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.todo.title);
    _descriptionController = TextEditingController(text: widget.todo.description);
    selectedLabel = widget.todo.label;

    if (widget.todo.deadlineDate != null) {
      selectedDate = widget.todo.deadlineDate;

      if (widget.todo.deadlineTime.isNotEmpty) {
        try {
          final parsedTime = DateFormat.jm().parse(widget.todo.deadlineTime);
          selectedTime = TimeOfDay.fromDateTime(parsedTime);
        } catch (_) {
          selectedTime = TimeOfDay(
            hour: widget.todo.deadlineDate!.hour,
            minute: widget.todo.deadlineDate!.minute,
          );
        }
      } else {
        selectedTime = TimeOfDay(
          hour: widget.todo.deadlineDate!.hour,
          minute: widget.todo.deadlineDate!.minute,
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  TextStyle get _labelTextStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
    color: AppColors.secondary,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.secondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Task',
          style: GoogleFonts.poppins(
            color: AppColors.secondary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// CIRCLE ICON WITH STROKE
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: selectedLabel.isNotEmpty
                          ? _getLabelColor(selectedLabel).withOpacity(0.2)
                          : AppColors.secondary.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.secondary,
                        width: 2, // STROKE
                      ),
                    ),
                    child: Icon(
                      selectedLabel.isNotEmpty
                          ? _getLabelIcon(selectedLabel)
                          : Icons.task_alt_outlined,
                      size: 60,
                      color: selectedLabel.isNotEmpty
                          ? _getLabelColor(selectedLabel)
                          : AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Text('Title', style: _labelTextStyle),
                const SizedBox(height: 8),
                _roundedTextField(
                  controller: _titleController,
                  hint: 'Enter to-do',
                  validator: (v) =>
                  v == null || v.isEmpty ? 'Please enter a title' : null,
                ),

                const SizedBox(height: 20),
                Text('Label', style: _labelTextStyle),
                const SizedBox(height: 8),
                _buildLabelDropdown(),

                const SizedBox(height: 20),
                Text('Description', style: _labelTextStyle),
                const SizedBox(height: 8),
                _roundedTextField(
                  controller: _descriptionController,
                  hint: 'Enter a description',
                  maxLines: 3,
                  borderRadius: 20,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Please enter a description'
                      : null,
                ),

                const SizedBox(height: 20),
                Text('Deadline', style: _labelTextStyle),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: _roundedContainer(
                          child: Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy')
                                .format(selectedDate!)
                                : 'Date',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: _roundedContainer(
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Time',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _saveTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: AppColors.secondary, width: 2),
                      ),
                      elevation: 0,
                    ),
                    child: isSaving
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.secondary,
                      ),
                    )
                        : Text(
                      'Save',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------- widgets -----------------------------

  Widget _roundedTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
    double borderRadius = 30,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.secondary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.secondary.withOpacity(0.4),
        ),
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _roundedContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.secondary, width: 2),
      ),
      child: child,
    );
  }

  Widget _buildLabelDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedLabel.isEmpty ? null : selectedLabel,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.secondary),
      dropdownColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: 'Select a label',
        hintStyle:
        GoogleFonts.poppins(color: AppColors.secondary.withOpacity(0.4)),
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      items: labelOptions.map((label) {
        return DropdownMenuItem<String>(
          value: label['label'],
          child: Row(
            children: [
              Icon(label['icon'], color: label['color'], size: 20),
              const SizedBox(width: 10),
              Text(label['label'], style: GoogleFonts.poppins(fontSize: 14)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => setState(() => selectedLabel = value ?? ''),
      validator: (v) =>
      v == null || v.isEmpty ? 'Please select a label' : null,
    );
  }

  // ------------------------ helpers ------------------------------

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final deadlineDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await _service.updateTodo(
        widget.todo.id,
        {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'label': selectedLabel,
          'deadlineDate': Timestamp.fromDate(deadlineDateTime),
          'deadlineTime': selectedTime!.format(context),
          'status': widget.todo.status.toLowerCase(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  IconData _getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Icons.work_outline;
      case 'personal':
        return Icons.person_outline;
      case 'shopping':
        return Icons.shopping_cart_outlined;
      case 'study':
        return Icons.school_outlined;
      case 'health':
        return Icons.favorite_border;
      case 'family':
        return Icons.home_outlined;
      default:
        return Icons.task_outlined;
    }
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return AppColors.button;
      case 'personal':
        return Color(0xFF9C6BFF);
      case 'shopping':
        return AppColors.merah;
      case 'study':
        return AppColors.screen2;
      case 'health':
        return AppColors.screen1;
      case 'family':
        return AppColors.kream;
      default:
        return AppColors.secondary;
    }
  }
}
