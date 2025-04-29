class Quotation {
  final int? id;
  final String customerName;
  final DateTime date;
  final List<QuotationItem> items; // List of items in the quotation

  Quotation({
    this.id,
    required this.customerName,
    required this.date,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'date': date.toIso8601String(),
    };
  }

  factory Quotation.fromMap(
    Map<String, dynamic> map,
    List<QuotationItem> items,
  ) {
    return Quotation(
      id: map['id'],
      customerName: map['customerName'],
      date: DateTime.parse(map['date']),
      items: items,
    );
  }
}

class QuotationItem {
  final String productName;
  final int quantity;
  final double price;

  QuotationItem({
    required this.productName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {'productName': productName, 'quantity': quantity, 'price': price};
  }

  factory QuotationItem.fromMap(Map<String, dynamic> map) {
    return QuotationItem(
      productName: map['productName'],
      quantity: map['quantity'],
      price: map['price'],
    );
  }
}
