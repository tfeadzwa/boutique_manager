class Product {
  final int? id;
  String _name; // Changed to private field
  final int stock;
  final int reorderLevel;
  final DateTime lastSoldDate;
  int quantity; // Added property
  double price; // Added property

  Product({
    this.id,
    required String name,
    required this.stock,
    required this.reorderLevel,
    required this.lastSoldDate,
    this.quantity = 0, // Default value
    this.price = 0.0, // Default value
  }) : _name = name;

  // Getter for name
  String get name => _name;

  // Setter for name
  set name(String value) {
    _name = value;
  }

  // Convert to Map (for SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': _name,
      'stock': stock,
      'reorderLevel': reorderLevel,
      'lastSoldDate': lastSoldDate.toIso8601String(),
      'quantity': quantity,
      'price': price,
    };
  }

  // Convert from Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      stock: map['stock'],
      reorderLevel: map['reorderLevel'],
      lastSoldDate: DateTime.parse(map['lastSoldDate']),
      quantity: map['quantity'] ?? 0,
      price: map['price'] ?? 0.0,
    );
  }
}
