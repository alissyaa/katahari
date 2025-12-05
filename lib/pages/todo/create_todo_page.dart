import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:katahari/services/todo_services.dart';
import 'package:katahari/components/todo/custom_date_time_picker.dart';
import '../../constant/app_colors.dart';

class CreateTodoPage extends StatefulWidget {
  const CreateTodoPage({super.key});

  @override
  State<CreateTodoPage> createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final _formKey = GlobalKey<FormState>();
  final TodoService _service = TodoService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedLabel = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isCreating = false;

  final List<Map<String, dynamic>> labelOptions = [
    {'label': 'Work', 'icon': Icons.work_outline, 'color': AppColors.secondary},
    {'label': 'Personal', 'icon': Icons.person_outline, 'color': AppColors.purple},
    {'label': 'Shopping', 'icon': Icons.shopping_cart_outlined, 'color': AppColors.merah},
    {'label': 'Study', 'icon': Icons.school_outlined, 'color': AppColors.screen2},
    {'label': 'Health', 'icon': Icons.favorite_border, 'color': AppColors.screen1},
    {'label': 'Family', 'icon': Icons.home_outlined, 'color': AppColors.button},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  TextStyle get _labelTextStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic,
  );

  @override
  Widget build(BuildContext context) {
    const Color mainBlue = AppColors.button;

    return Theme(
      data: Theme.of(context).copyWith(
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: AppColors.secondary,
          onPrimary: AppColors.primary,
          onSurface: AppColors.secondary,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.secondary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Task',
            style: GoogleFonts.poppins(
              color: AppColors.secondary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: selectedLabel.isNotEmpty
                            ? _getLabelColor(selectedLabel).withValues(alpha: 0.25)
                            : AppColors.button,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        selectedLabel.isNotEmpty
                            ? _getLabelIcon(selectedLabel)
                            : Icons.task_alt_outlined,
                        size: 60,
                        color: selectedLabel.isNotEmpty
                            ? _getLabelColor(selectedLabel)
                            : mainBlue,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text('Title', style: _labelTextStyle),
                  const SizedBox(height: 8),
                  _roundedTextField(
                    controller: _titleController,
                    hint: 'Enter to-do',
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a title'
                        : null,
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
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter a description'
                        : null,
                  ),
                  const SizedBox(height: 20),

                  Text('Deadline', style: _labelTextStyle),
                  const SizedBox(height: 8),

                  CustomDateTimePicker(
                    selectedDate: selectedDate,
                    selectedTime: selectedTime,
                    onPickDate: _pickDate,
                    onPickTime: _pickTime,
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isCreating ? null : _createTodo,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.button,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: AppColors.secondary,
                            width: 2,
                          ),
                        ),
                        elevation: 0,
                      ),
                      child: isCreating
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                          : Text(
                        'Create',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
      ),
    );
  }

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
          color: AppColors.abumuda,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildLabelDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedLabel.isEmpty ? null : selectedLabel,
      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.secondary),
      dropdownColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: 'Select a label',
        hintStyle: GoogleFonts.poppins(
          color: AppColors.abumuda,
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.primary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded,
          color: AppColors.secondary),
      items: labelOptions.map((label) {
        return DropdownMenuItem<String>(
          value: label['label'],
          child: Row(
            children: [
              Icon(label['icon'], color: label['color'], size: 20),
              const SizedBox(width: 10),
              Text(label['label']),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedLabel = value ?? '');
      },
      validator: (value) =>
      value == null || value.isEmpty ? 'Please select a label' : null,
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _createTodo() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    setState(() => isCreating = true);

    try {
      final deadlineDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await _service.createTodo(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        label: selectedLabel,
        deadlineDate: deadlineDateTime,
        deadlineTime: selectedTime!.format(context),
        status: 'ongoing',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCreating = false);
      }
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
    final item = labelOptions.firstWhere(
          (e) => e['label'] == label,
      orElse: () => {},
    );
    return item.isNotEmpty ? item['color'] : AppColors.abumuda;
  }
}
