import 'package:flutter/material.dart';
import 'package:frontend/widgets/filter.dart';

class DataTableWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filters;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Map<String, String?> selectedFilters;
  final Function(String, String?) onFilterChanged;
  final int? sortColumnIndex;
  final bool? sortAscending;
  final Function(int, bool) onSort;
  final String addButtonLabel;
  final VoidCallback onAdd;

  const DataTableWidget({
    super.key,
    required this.filters,
    required this.columns,
    required this.rows,
    required this.selectedFilters,
    required this.onFilterChanged,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.addButtonLabel,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth > 750) {
              // Desktop layout - horizontal filters
              return Row(
                children: [
                  const Text("Filters:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 60),
                  ...filters.map((filter) {
                    if (filter['type'] == 'dropdown') {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FilterDropdown(
                          hint: filter['hint'],
                          value: selectedFilters[filter['key']],
                          items: filter['items'],
                          onChanged: (value) {
                            onFilterChanged(filter['key'], value);
                          },
                        ),
                      );
                    } else {
                      // Custom filter type (like movement type)
                      return filter['widget'];
                    }
                  }),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: onAdd,
                    label: Text(addButtonLabel),
                    icon: const Icon(Icons.add),
                  )
                ],
              );
            } else {
              // Mobile layout - vertical filters
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Filters:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: onAdd,
                        label: Text(addButtonLabel),
                        icon: const Icon(Icons.add),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...filters.map((filter) {
                    if (filter['type'] == 'dropdown') {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FilterDropdown(
                          hint: filter['hint'],
                          value: selectedFilters[filter['key']],
                          items: filter['items'],
                          onChanged: (value) {
                            onFilterChanged(filter['key'], value);
                          },
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: filter['widget'],
                      );
                    }
                  }),
                ],
              );
            }
          }),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LayoutBuilder(builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  sortColumnIndex: sortColumnIndex,
                  sortAscending: sortAscending ?? true,
                  columns: columns.asMap().entries.map((entry) {
                    final int idx = entry.key;
                    final DataColumn column = entry.value;
                    return DataColumn(
                      label: column.label,
                      onSort: idx == columns.length - 1
                          ? null
                          : (columnIndex, ascending) {
                              onSort(columnIndex, ascending);
                            },
                    );
                  }).toList(),
                  rows: rows,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
