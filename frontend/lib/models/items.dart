class Item {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final int categoryId;
  final int supplierId;
  final String categoryName;
  final String supplierName;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
    required this.categoryId,
    required this.supplierId,
    required this.categoryName,
    required this.supplierName,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      categoryId: json['category_id'],
      supplierId: json['supplier_id'],
      categoryName: json['category_name'],
      supplierName: json['supplier_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'price': price,
      'category_id': categoryId,
      'supplier_id': supplierId,
      'category_name': categoryName,
      'supplier_name': supplierName,
    };
  }
}
