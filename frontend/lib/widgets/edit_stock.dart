import 'package:flutter/material.dart';
import 'package:frontend/models/stocks.dart';

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
        // TODO: Implement edit stock logic
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Edit Stock Movement'),
              content: const Text('Edit functionality coming soon...'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
