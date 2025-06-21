import 'package:flutter/material.dart';
import 'package:frontend/models/items.dart';

class ItemForm extends StatefulWidget {
  const ItemForm({
    super.key,
    this.item,
    required this.onSubmit,
    required this.categories,
    required this.suppliers,
  });

  final Item? item; // null for create, non-null for edit
  final Function(Map<String, dynamic>) onSubmit;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> suppliers;

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  late TextEditingController _priceController;
  int? _selectedCategoryId;
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing values if editing
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.item?.description ?? '');
    _quantityController =
        TextEditingController(text: widget.item?.quantity.toString() ?? '0');
    _priceController =
        TextEditingController(text: widget.item?.price.toString() ?? '0.0');
    _selectedCategoryId = widget.item?.categoryId;
    _selectedSupplierId = widget.item?.supplierId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 2,
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
              return null;
            },
          ),
          TextFormField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a price';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          DropdownButtonFormField<int>(
            value: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'Category'),
            items: widget.categories
                .map((category) => DropdownMenuItem(
                      value: category['id'] as int,
                      child: Text(category['name'] as String),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a category';
              }
              return null;
            },
          ),
          DropdownButtonFormField<int>(
            value: _selectedSupplierId,
            decoration: const InputDecoration(labelText: 'Supplier'),
            items: widget.suppliers
                .map((supplier) => DropdownMenuItem(
                      value: supplier['id'] as int,
                      child: Text(supplier['name'] as String),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSupplierId = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a supplier';
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
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                      'quantity': int.parse(_quantityController.text),
                      'price': double.parse(_priceController.text),
                      'category_id': _selectedCategoryId,
                      'supplier_id': _selectedSupplierId,
                    };
                    widget.onSubmit(formData);
                  }
                },
                child: Text(widget.item == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
