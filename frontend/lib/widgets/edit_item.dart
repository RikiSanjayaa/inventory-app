import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/models/items.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/widgets/item_form.dart';
import 'package:http/http.dart' as http;

class EditItemBtn extends StatelessWidget {
  const EditItemBtn({
    super.key,
    required this.item,
    required this.fetchItems,
    required this.categories,
    required this.suppliers,
  });

  final Item item;
  final Function() fetchItems;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> suppliers;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Item Details'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${item.id}'),
                      Text('Name: ${item.name}'),
                      Text('Description: ${item.description}'),
                      Text('Quantity: ${item.quantity}'),
                      Text('Price: \$${item.price}'),
                      Text('Category: ${item.categoryName}'),
                      Text('Supplier: ${item.supplierName}'),
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
                                child: ItemForm(
                                  item: item,
                                  categories:
                                      categories, // Pass your categories list
                                  suppliers:
                                      suppliers, // Pass your suppliers list
                                  onSubmit: (formData) async {
                                    final token = await AuthService.getToken();
                                    final response = await http.put(
                                      Uri.parse(
                                          'http://127.0.0.1:8000/items/${item.id}'),
                                      headers: {
                                        'Authorization': 'Bearer $token',
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode(formData),
                                    );

                                    if (response.statusCode == 200) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Item updated successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        Navigator.pop(context);
                                        fetchItems();
                                      }
                                    } else {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to update item: ${response.statusCode}'),
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
                        // Add delete confirmation
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Delete'),
                              content: const Text(
                                  'Are you sure you want to delete this item?'),
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
                                          'http://127.0.0.1:8000/items/${item.id}'),
                                      headers: {
                                        'accept': '*/*',
                                        'Authorization': 'Bearer $token'
                                      },
                                    );

                                    if (response.statusCode == 204) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Item deleted successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                        // Refresh the items list
                                        await fetchItems();
                                      } // Show success snackbar
                                    } else {
                                      if (context.mounted) {
                                        // Show error snackbar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Failed to delete item: ${response.statusCode}'),
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
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              });
        },
        icon: const Icon(Icons.edit));
  }
}
