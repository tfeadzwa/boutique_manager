class Product {
  final int? id;
  final String productId;
  final String name;
  final String category;
  final String description;
  final String imageUrl;
  final int restockThreshold;
  final int stockQty;
  final double unitPrice;
  final String status;
  final bool discontinued;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final String createdBy;
  final DateTime updatedAt;
  final String updatedBy;
  final DateTime? lastSoldAt;
  final int totalRevenueGenerated;
  final int totalQuantitySold;

  Product({
    this.id,
    required this.productId,
    required this.name,
    required this.category,
    required this.description,
    required this.imageUrl,
    required this.restockThreshold,
    required this.stockQty,
    required this.unitPrice,
    required this.status,
    required this.discontinued,
    this.expiryDate,
    required this.createdAt,
    required this.createdBy,
    required this.updatedAt,
    required this.updatedBy,
    this.lastSoldAt,
    required this.totalRevenueGenerated,
    this.totalQuantitySold = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'restockThreshold': restockThreshold,
      'stockQty': stockQty,
      'unitPrice': unitPrice,
      'status': status,
      'discontinued': discontinued ? 1 : 0,
      'expiry_date': expiryDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedAt': updatedAt.toIso8601String(),
      'updatedBy': updatedBy,
      'lastSoldAt': lastSoldAt?.toIso8601String(),
      'totalRevenueGenerated': totalRevenueGenerated,
      'totalQuantitySold': totalQuantitySold,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      productId: map['productId'],
      name: map['name'],
      category: map['category'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      restockThreshold: map['restockThreshold'],
      stockQty: map['stockQty'],
      unitPrice:
          map['unitPrice'] is int
              ? (map['unitPrice'] as int).toDouble()
              : map['unitPrice'],
      status: map['status'],
      discontinued: map['discontinued'] == 1,
      expiryDate:
          map['expiry_date'] != null
              ? DateTime.tryParse(map['expiry_date'])
              : null,
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: map['createdBy'],
      updatedAt: DateTime.parse(map['updatedAt']),
      updatedBy: map['updatedBy'],
      lastSoldAt:
          map['lastSoldAt'] != null
              ? DateTime.tryParse(map['lastSoldAt'])
              : null,
      totalRevenueGenerated: map['totalRevenueGenerated'] ?? 0,
      totalQuantitySold: map['totalQuantitySold'] ?? 0,
    );
  }
}
