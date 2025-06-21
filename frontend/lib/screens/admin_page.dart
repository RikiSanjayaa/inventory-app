import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> suppliers = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactInfoController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final token = await AuthService.getToken();

    final catResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/categories/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final supResponse = await http.get(
      Uri.parse('http://127.0.0.1:8000/suppliers/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (catResponse.statusCode == 200 && supResponse.statusCode == 200) {
      setState(() {
        categories =
            List<Map<String, dynamic>>.from(jsonDecode(catResponse.body));
        suppliers =
            List<Map<String, dynamic>>.from(jsonDecode(supResponse.body));
        isLoading = false;
      });
    }
  }

  Future<void> addItem(String type, Map<String, dynamic> data) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/${type.toLowerCase()}/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      _nameController.clear();
      _descriptionController.clear();
      _contactInfoController.clear();
      fetchData();
    }
  }

  Future<void> deleteItem(String type, int id) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/${type.toLowerCase()}/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      fetchData();
    }
  }

  void showAddDialog(String type) {
    _nameController.clear();
    _descriptionController.clear();
    _contactInfoController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $type'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: '$type Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (type == 'Categories')
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                )
              else
                TextFormField(
                  controller: _contactInfoController,
                  decoration: const InputDecoration(labelText: 'Contact Info'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final data = type == 'Categories'
                    ? {
                        'name': _nameController.text,
                        'description': _descriptionController.text,
                      }
                    : {
                        'name': _nameController.text,
                        'contact_info': _contactInfoController.text,
                      };
                addItem(type, data);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categories',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () => showAddDialog('Categories'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Category'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return ListTile(
                          title: Text(category['name']),
                          subtitle: Text(
                            category['description'] ?? 'No description',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                deleteItem('categories', category['id']),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Suppliers',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () => showAddDialog('Suppliers'),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Supplier'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = suppliers[index];
                        return ListTile(
                          title: Text(supplier['name']),
                          subtitle: Text(
                            supplier['contact_info'] ?? 'No contact info',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                deleteItem('suppliers', supplier['id']),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
