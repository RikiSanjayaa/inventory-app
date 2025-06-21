import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/stocks.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/stock_form.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class EditStockBtn extends StatelessWidget {
  const EditStockBtn({
    super.key,
    required this.stock,
    required this.fetchStocks,
    required this.items,
  });

  final Stock stock;
  final Function() fetchStocks;
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Stock Movement Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${stock.id}'),
                  Text('Item: ${stock.itemName}'),
                  Text('User: ${stock.username}'),
                  Text('Quantity: ${stock.quantity}'),
                  Text('Type: ${stock.movementType}'),
                  Text(
                      'Timestamp: ${DateFormat('MMM d, y HH:mm').format(stock.timestamp)}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            width: 400,
                            child: StockForm(
                              stock: stock,
                              items: items,
                              onSubmit: (formData) async {
                                final token = await AuthService.getToken();
                                final response = await http.put(
                                  Uri.parse(
                                      'http://127.0.0.1:8000/stock/${stock.id}'),
                                  headers: {
                                    'Authorization': 'Bearer $token',
                                    'Content-Type': 'application/json',
                                  },
                                  body: jsonEncode({
                                    ...formData,
                                    'user_id': stock.userId,
                                    'timestamp':
                                        stock.timestamp.toIso8601String(),
                                  }),
                                );

                                if (response.statusCode == 200) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Stock movement updated successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(context);
                                    fetchStocks();
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to update stock movement: ${response.statusCode}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Edit'),
                ),
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                              'Are you sure you want to delete this stock movement?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () async {
                                final token = await AuthService.getToken();
                                final response = await http.delete(
                                  Uri.parse(
                                      'http://127.0.0.1:8000/stock/${stock.id}'),
                                  headers: {
                                    'accept': '*/*',
                                    'Authorization': 'Bearer $token'
                                  },
                                );

                                if (response.statusCode == 204) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Stock movement deleted successfully'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    await fetchStocks();
                                  }
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to delete stock movement: ${response.statusCode}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                                if (context.mounted) {
                                  Navigator.of(context)
                                      .pop(); // Close confirmation dialog
                                  Navigator.of(context)
                                      .pop(); // Close details dialog
                                }
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
