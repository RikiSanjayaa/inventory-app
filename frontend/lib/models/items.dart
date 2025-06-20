class Item {
  final int id;
  final String name;
  final String description;
  final int quantity;
  final double price;
  final String categoryName;
  final String supplierName;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.quantity,
    required this.price,
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
      categoryName: json['category_name'],
      supplierName: json['supplier_name'],
    );
  }
}
