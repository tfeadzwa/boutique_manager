import 'dart:convert'; // Import for JSON encoding/decoding
import 'quotation.dart'; // Import Quotation model
import 'product.dart'; // Import Product model

class Invoice {
  final int? id;
  final String customerName;
  final DateTime date;
  final List<QuotationItem> items;
  final List<Product> products; // Add this field
  final double totalAmount;
  final bool isPaid;

  Invoice({
    this.id,
    required this.customerName,
    required this.date,
    required this.items,
    required this.products, // Add this parameter
    required this.totalAmount,
    required this.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'totalAmount': totalAmount,
      'isPaid': isPaid ? 1 : 0, // SQLite stores booleans as integers
      'products': jsonEncode(
        products.map((p) => p.toMap()).toList(),
      ), // Serialize products as JSON
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map, List<QuotationItem> items) {
    return Invoice(
      id: map['id'],
      customerName: map['customerName'],
      date: DateTime.parse(map['date']),
      items: items, // Use the provided items
      products:
          (jsonDecode(map['products']) as List)
              .map((p) => Product.fromMap(p))
              .toList(), // Deserialize JSON to Product list
      totalAmount: map['totalAmount'],
      isPaid: map['isPaid'] == 1,
    );
  }
}
