import 'package:flutter/material.dart';

class StockMovementsPage extends StatelessWidget {
  StockMovementsPage({super.key});
  // TODO: connect this page with actual data from "stock_movements" table
  final List<Map<String, dynamic>> movements = [
    {
      'item': 'LED Lamp',
      'user': 'admin',
      'quantity': 10,
      'type': 'IN',
      'timestamp': '2025-06-19 08:30'
    },
    {
      'item': 'Office Chair',
      'user': 'riki',
      'quantity': -5,
      'type': 'OUT',
      'timestamp': '2025-06-19 09:45'
    },
    {
      'item': 'Flip Chart',
      'user': 'admin',
      'quantity': 3,
      'type': 'IN',
      'timestamp': '2025-06-18 15:10'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('User')),
          DataColumn(label: Text('Quantity')),
          DataColumn(label: Text('Type')),
          DataColumn(label: Text('Timestamp')),
        ],
        rows: movements.map((m) {
          return DataRow(
            cells: [
              DataCell(Text(m['item'])),
              DataCell(Text(m['user'])),
              DataCell(Text('${m['quantity']}')),
              DataCell(Text(m['type'])),
              DataCell(Text(m['timestamp'])),
            ],
          );
        }).toList(),
      ),
    );
  }
}
