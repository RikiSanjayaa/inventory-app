import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/data_table_widget.dart';
import 'package:frontend/widgets/edit_item.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/models/items.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<Item> items = [];
  bool isLoading = true;
  int _sortColumnIndex = 0;
  bool _isAscending = true;

  List<Item> allItems = [];
  List<Item> filteredItems = [];

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> suppliers = [];

  String? selectedCategory;
  String? selectedSupplier;

  Future<void> fetchItems() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/items/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      setState(() {
        items = jsonList.map((json) => Item.fromJson(json)).toList();
        isLoading = false;
        allItems = items;
        filteredItems = List.from(allItems);
      });
    } else {
      throw Exception('Failed to load items: ${response.statusCode}');
    }
  }

  Future<void> fetchDropdownOptions() async {
    final token = await AuthService.getToken();
    final catResponse = await http.get(
      Uri.parse("http://127.0.0.1:8000/categories/"),
      headers: {'Authorization': 'Bearer $token'},
    );
    final supResponse = await http.get(
      Uri.parse("http://127.0.0.1:8000/suppliers/"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (catResponse.statusCode == 200 && supResponse.statusCode == 200) {
      final List<dynamic> catJson = jsonDecode(catResponse.body);
      final List<dynamic> supJson = jsonDecode(supResponse.body);
      setState(() {
        categories = catJson
            .map((cat) => {
                  'id': cat['id'],
                  'name': cat['name'],
                })
            .toList();
        suppliers = supJson
            .map((sup) => {
                  'id': sup['id'],
                  'name': sup['name'],
                })
            .toList();
      });
    }
  }

  void _applyFilters() {
    setState(() {
      filteredItems = allItems.where((item) {
        final matchesCategory =
            selectedCategory == null || item.categoryName == selectedCategory;
        final matchesSupplier =
            selectedSupplier == null || item.supplierName == selectedSupplier;
        return matchesCategory && matchesSupplier;
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDropdownOptions();
    fetchItems();
    // TODO: create item button
  }

  int _compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  int _compareNum<T extends num>(bool ascending, T value1, T value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);

  @override
  Widget build(BuildContext context) {
    final filtersList = [
      {
        'type': 'dropdown',
        'hint': 'Category',
        'key': 'category',
        'items': categories,
      },
      {
        'type': 'dropdown',
        'hint': 'Supplier',
        'key': 'supplier',
        'items': suppliers,
      },
    ];

    return DataTableWidget(
      filters: filtersList,
      selectedFilters: {
        'category': selectedCategory,
        'supplier': selectedSupplier,
      },
      onFilterChanged: (key, value) {
        setState(() {
          if (key == 'category') {
            selectedCategory = value;
          } else if (key == 'supplier') {
            selectedSupplier = value;
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
              filteredItems
                  .sort((a, b) => _compareString(ascending, a.name, b.name));
            case 1:
              filteredItems.sort(
                  (a, b) => _compareNum(ascending, a.quantity, b.quantity));
            case 2:
              filteredItems
                  .sort((a, b) => _compareNum(ascending, a.price, b.price));
            case 3:
              filteredItems.sort((a, b) =>
                  _compareString(ascending, a.categoryName, b.categoryName));
            case 4:
              filteredItems.sort((a, b) =>
                  _compareString(ascending, a.supplierName, b.supplierName));
          }
        });
      },
      columns: const [
        DataColumn(
          label: Text('Name',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Quantity',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Price',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Category',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Supplier',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        DataColumn(
          label: Text('Actions',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      ],
      rows: filteredItems.map((item) {
        return DataRow(
          cells: [
            DataCell(Text(item.name)),
            DataCell(Text(item.quantity.toString())),
            DataCell(Text('\$${item.price}')),
            DataCell(Text(item.categoryName)),
            DataCell(Text(item.supplierName)),
            DataCell(EditItemBtn(
              item: item,
              fetchItems: fetchItems,
              categories: categories,
              suppliers: suppliers,
            )),
          ],
        );
      }).toList(),
    );
  }
}
