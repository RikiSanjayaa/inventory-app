import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/models/stocks.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/data_table_widget.dart';
import 'package:frontend/widgets/edit_stock.dart';
import 'package:frontend/widgets/stock_form.dart';
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
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  List<Stock> allStocks = [];
  List<Stock> filteredStocks = [];

  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> items = [];

  String? selectedUser;
  String? selectedItem;
  String? selectedMovementType;

  Future<void> fetchDropdownOptions() async {
    final token = await AuthService.getToken();
    final itemsResponse = await http.get(
      Uri.parse("http://127.0.0.1:8000/items/"),
      headers: {'Authorization': 'Bearer $token'},
    );
    final usersResponse = await http.get(
      Uri.parse("http://127.0.0.1:8000/users/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (itemsResponse.statusCode == 200 && usersResponse.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(usersResponse.body);
      final List<dynamic> itemsJson = jsonDecode(itemsResponse.body);
      setState(() {
        users = usersJson
            .map((user) => {
                  'id': user['id'],
                  'name': user['username'],
                })
            .toList();
        items = itemsJson
            .map((item) => {
                  'id': item['id'],
                  'name': item['name'],
                })
            .toList();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredStocks = allStocks.where((stock) {
        final matchesUser =
            selectedUser == null || stock.username == selectedUser;
        final matchesItem =
            selectedItem == null || stock.itemName == selectedItem;
        final matchesType = selectedMovementType == null ||
            stock.movementType.toLowerCase() == selectedMovementType;
        return matchesUser && matchesItem && matchesType;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
    fetchDropdownOptions();
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
        allStocks = stocks;
        filteredStocks = List.from(allStocks);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  Future<int?> getCurrentUserId() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/user'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      return userData['User']['id'];
    }
    return null;
  }

  int _compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  int _compareNum<T extends num>(bool ascending, T value1, T value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  int _compareDateTime(bool ascending, DateTime value1, DateTime value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  @override
  Widget build(BuildContext context) {
    final filtersList = [
      {
        'type': 'dropdown',
        'hint': 'Item',
        'key': 'item',
        'items': items,
      },
      {
        'type': 'dropdown',
        'hint': 'User',
        'key': 'user',
        'items': users,
      },
      {
        'type': 'custom',
        'widget': DropdownButton<String>(
          hint: const Text('Movement Type'),
          value: selectedMovementType,
          items: const [
            DropdownMenuItem(value: null, child: Text('All Types')),
            DropdownMenuItem(value: 'in', child: Text('In')),
            DropdownMenuItem(value: 'out', child: Text('Out')),
          ],
          onChanged: (value) {
            setState(() {
              selectedMovementType = value;
              _applyFilters();
            });
          },
        ),
      },
    ];

    return DataTableWidget(
      filters: filtersList,
      selectedFilters: {
        'item': selectedItem,
        'user': selectedUser,
      },
      addButtonLabel: 'Add Stock Movement',
      onAdd: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: 400,
                  child: StockForm(
                    items: items,
                    onSubmit: (formData) async {
                      final userId = await getCurrentUserId();
                      if (userId == null) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to get user information'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }

                      final completeFormData = {
                        ...formData,
                        'user_id': userId,
                        'timestamp': DateTime.now().toIso8601String(),
                      };

                      final token = await AuthService.getToken();
                      final response = await http.post(
                        Uri.parse('http://127.0.0.1:8000/stock/'),
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode(completeFormData),
                      );

                      if (response.statusCode == 201) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Stock movement created successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                          fetchItems();
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Failed to create stock movement: ${response.statusCode}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              );
            });
      },
      onFilterChanged: (key, value) {
        setState(() {
          if (key == 'item') {
            selectedItem = value;
          } else if (key == 'user') {
            selectedUser = value;
          }
          _applyFilters();
        });
      },
      sortColumnIndex: _sortColumnIndex,
      sortAscending: _isAscending,
      onSort: (columnIndex, ascending) {
        setState(() {
          _sortColumnIndex = columnIndex;
          _isAscending = ascending;
          switch (columnIndex) {
            case 0:
              filteredStocks.sort(
                  (a, b) => _compareString(ascending, a.itemName, b.itemName));
            case 1:
              filteredStocks.sort(
                  (a, b) => _compareString(ascending, a.username, b.username));
            case 2:
              filteredStocks.sort(
                  (a, b) => _compareNum(ascending, a.quantity, b.quantity));
            case 3:
              filteredStocks.sort((a, b) =>
                  _compareString(ascending, a.movementType, b.movementType));
            case 4:
              filteredStocks.sort((a, b) =>
                  _compareDateTime(ascending, a.timestamp, b.timestamp));
          }
        });
      },
      columns: const [
        DataColumn(
          label: Text('Item',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('CreatedBy',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Quantity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Type',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Timestamp',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ],
      rows: filteredStocks.map((stock) {
        return DataRow(
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
            DataCell(EditStockBtn(
              stock: stock,
              fetchStocks: fetchItems,
              items: items,
            )),
          ],
        );
      }).toList(),
    );
  }
}
