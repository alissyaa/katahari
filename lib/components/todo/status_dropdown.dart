import 'package:flutter/material.dart';

class StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;

  const StatusDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> statuses = ["Ongoing", "Completed", "Missed"];

    return DropdownButton<String>(
      value: statuses.contains(value) ? value : statuses.first,
      isExpanded: true,
      items: statuses.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}