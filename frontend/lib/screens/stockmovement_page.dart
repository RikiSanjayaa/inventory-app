import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/stocks.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class StockMovementsPage extends StatefulWidget {
  const StockMovementsPage({super.key});

  @override
  State<StockMovementsPage> createState() => _StockMovementsPageState();
}

class _StockMovementsPageState extends State<StockMovementsPage> {
  List<Stock> stocks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
    // TODO: create stock movement, delete stock movement
  }

  Future<void> fetchItems() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/stock/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        stocks = jsonList.map((json) => Stock.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text(
            'Item',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
          DataColumn(
              label: Text(
            'User',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
          DataColumn(
              label: Text(
            'Quantity',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
          DataColumn(
              label: Text(
            'Type',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
          DataColumn(
              label: Text(
            'Timestamp',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          )),
        ],
        rows: stocks.map((stock) {
          return DataRow(
            // TODO: Filter by everything (user dropdown)
            cells: [
              DataCell(Text(stock.itemName)),
              DataCell(Text(stock.username)),
              DataCell(Text('${stock.quantity}')),
              DataCell(Icon(
                stock.movementType.toLowerCase() == 'in'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: stock.movementType.toLowerCase() == 'in'
                    ? Colors.green
                    : Colors.red,
              )),
              DataCell(
                Text(
                  DateFormat('MMM d, y HH:mm').format(stock.timestamp),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
