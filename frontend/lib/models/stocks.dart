class Stock {
  final int id;
  final int itemId;
  final int userId;
  final int quantity;
  final String movementType;
  final DateTime timestamp;
  final String username;
  final String itemName;

  Stock({
    required this.id,
    required this.itemId,
    required this.userId,
    required this.quantity,
    required this.movementType,
    required this.timestamp,
    required this.username,
    required this.itemName,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      id: json['id'],
      itemId: json['item_id'],
      userId: json['user_id'],
      quantity: json['quantity'],
      movementType: json['movement_type'],
      timestamp: DateTime.parse(json['timestamp']),
      username: json['username'],
      itemName: json['item_name'],
    );
  }
}
