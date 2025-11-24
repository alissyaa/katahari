import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class LabelDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;

  LabelDropdown({
    required this.value,
    required this.onChanged,
  });

  final List<String> labels = [
    'Daily',
    'Errands',
    'Study',
    'Work',
    'Health',
    'Finance',
    'Cleaning',
    'Social',
    'Hobby',
    'Entertainment',
  ];

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        value: value,
        items: labels
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        ))
            .toList(),
        onChanged: onChanged,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 12),
          height: 45,
        ),
        dropdownStyleData: const DropdownStyleData(
          maxHeight: 200,
        ),
      ),
    );
  }
}
