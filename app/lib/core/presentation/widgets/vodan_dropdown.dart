import 'package:flutter/material.dart';

class VodanDropdown extends StatelessWidget {
  const VodanDropdown({
    super.key,
    required this.initialValue,
    required this.labelText,
    required this.icon,
    required this.items,
    required this.onChanged
  });

  final String initialValue;
  final String labelText;
  final IconData icon;
  final List<DropdownMenuItem<String>>? items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: initialValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon)
      ),
      items: items,
      onChanged: onChanged,
    );
  }
}

