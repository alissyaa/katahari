import 'package:flutter/material.dart';
import 'package:katahari/services/todo_services.dart';
import 'package:intl/intl.dart';

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
    {'label': 'Work', 'icon': Icons.work_outline, 'color': Colors.blue},
    {'label': 'Personal', 'icon': Icons.person_outline, 'color': Colors.purple},
    {'label': 'Shopping', 'icon': Icons.shopping_cart_outlined, 'color': Colors.pink},
    {'label': 'Study', 'icon': Icons.school_outlined, 'color': Colors.orange},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Task',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
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
                // Icon Label Besar
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: selectedLabel.isNotEmpty
                          ? _getLabelColor(selectedLabel).withOpacity(0.2)
                          : Color(0xFFB3D9FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      selectedLabel.isNotEmpty
                          ? _getLabelIcon(selectedLabel)
                          : Icons.task_outlined,
                      size: 60,
                      color: selectedLabel.isNotEmpty
                          ? _getLabelColor(selectedLabel)
                          : Color(0xFF6BA6FF),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                const Text(
                  'Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter to-do',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Poppins',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: Color(0xFF6BA6FF), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Label
                const Text(
                  'Label',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                _buildLabelDropdown(),
                const SizedBox(height: 20),

                // Description
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter a description',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Poppins',
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Color(0xFF6BA6FF), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Deadline
                const Text(
                  'Deadline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Text(
                            selectedDate != null
                                ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                : 'Date',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedDate != null ? Colors.black : Colors.grey[400],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : 'Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: selectedTime != null ? Colors.black : Colors.grey[400],
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isCreating ? null : _createTodo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6BA6FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: isCreating
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Create',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Poppins',
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

  Widget _buildLabelDropdown() {
    return DropdownButtonFormField<String>(
      value: selectedLabel.isEmpty ? null : selectedLabel,
      decoration: InputDecoration(
        hintText: 'Select a label',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Color(0xFF6BA6FF), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      items: labelOptions.map((label) {
        return DropdownMenuItem<String>(
          value: label['label'],
          child: Row(
            children: [
              Icon(label['icon'], color: label['color'], size: 20),
              const SizedBox(width: 10),
              Text(
                label['label'],
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedLabel = value ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a label';
        }
        return null;
      },
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
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Future<void> _createTodo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both date and time')),
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task created successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
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
      default:
        return Icons.task_outlined;
    }
  }

  Color _getLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'work':
        return Colors.blue;
      case 'personal':
        return Colors.purple;
      case 'shopping':
        return Colors.pink;
      case 'study':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}