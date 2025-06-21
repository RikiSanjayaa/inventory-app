import 'package:flutter/material.dart';
import 'package:frontend/models/stocks.dart';

class StockForm extends StatefulWidget {
  const StockForm({
    super.key,
    this.stock,
    required this.onSubmit,
    required this.items,
  });

  final Stock? stock;
  final Function(Map<String, dynamic>) onSubmit;
  final List<Map<String, dynamic>> items;

  @override
  State<StockForm> createState() => _StockFormState();
}

class _StockFormState extends State<StockForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  int? _selectedItemId;
  String? _selectedMovementType;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.stock?.quantity.toString() ?? '0');
    _selectedItemId = widget.stock?.itemId;
    _selectedMovementType = widget.stock?.movementType.toLowerCase();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<int>(
            value: _selectedItemId,
            decoration: const InputDecoration(labelText: 'Item'),
            items: widget.items
                .map((item) => DropdownMenuItem(
                      value: item['id'] as int,
                      child: Text(item['name'] as String),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedItemId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select an item';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a quantity';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (int.parse(value) <= 0) {
                return 'Quantity must be greater than 0';
              }
              return null;
            },
          ),
          DropdownButtonFormField<String>(
            value: _selectedMovementType,
            decoration: const InputDecoration(labelText: 'Movement Type'),
            items: const [
              DropdownMenuItem(value: 'in', child: Text('In')),
              DropdownMenuItem(value: 'out', child: Text('Out')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedMovementType = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a movement type';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final formData = {
                      'item_id': _selectedItemId,
                      'quantity': int.parse(_quantityController.text),
                      'movement_type': _selectedMovementType,
                    };
                    widget.onSubmit(formData);
                  }
                },
                child: Text(widget.stock == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
