import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  const FilterDropdown({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final String? value;
  final List<Map<String, dynamic>> items;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(hint),
      value: value,
      items: [
        DropdownMenuItem(value: null, child: Text('All $hint')),
        ...items.map((item) => DropdownMenuItem(
              value: item['name'].toString(),
              child: Text(item['name'].toString()),
            )),
      ],
      onChanged: onChanged,
    );
  }
}
