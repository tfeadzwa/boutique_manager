import 'dart:convert';

class InvoiceItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'total': total,
  };

  factory InvoiceItem.fromMap(Map<String, dynamic> map) => InvoiceItem(
    productId: map['productId'],
    productName: map['productName'],
    quantity: map['quantity'],
    unitPrice:
        map['unitPrice'] is int
            ? (map['unitPrice'] as int).toDouble()
            : map['unitPrice'],
    total:
        map['total'] is int ? (map['total'] as int).toDouble() : map['total'],
  );
}

class Invoice {
  final int? id;
  final String invoiceId;
  final String cashier;
  final String customerName;
  final double discount;
  final double grandTotal;
  final List<InvoiceItem> items;
  final String notes;
  final String paymentMethod;
  final String soldBy;
  final String status;
  final double tax;
  final DateTime timestamp;
  final double totalAmount;
  final int totalQuantity;

  Invoice({
    this.id,
    required this.invoiceId,
    required this.cashier,
    required this.customerName,
    required this.discount,
    required this.grandTotal,
    required this.items,
    required this.notes,
    required this.paymentMethod,
    required this.soldBy,
    required this.status,
    required this.tax,
    required this.timestamp,
    required this.totalAmount,
    required this.totalQuantity,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'invoiceId': invoiceId,
    'cashier': cashier,
    'customerName': customerName,
    'discount': discount,
    'grandTotal': grandTotal,
    'items': jsonEncode(items.map((e) => e.toMap()).toList()),
    'notes': notes,
    'paymentMethod': paymentMethod,
    'soldBy': soldBy,
    'status': status,
    'tax': tax,
    'timestamp': timestamp.toIso8601String(),
    'totalAmount': totalAmount,
    'totalQuantity': totalQuantity,
  };

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
    id: map['id'],
    invoiceId: map['invoiceId'],
    cashier: map['cashier'],
    customerName: map['customerName'],
    discount:
        map['discount'] is int
            ? (map['discount'] as int).toDouble()
            : map['discount'],
    grandTotal:
        map['grandTotal'] is int
            ? (map['grandTotal'] as int).toDouble()
            : map['grandTotal'],
    items:
        (jsonDecode(map['items']) as List)
            .map((e) => InvoiceItem.fromMap(e))
            .toList(),
    notes: map['notes'],
    paymentMethod: map['paymentMethod'],
    soldBy: map['soldBy'],
    status: map['status'],
    tax: map['tax'] is int ? (map['tax'] as int).toDouble() : map['tax'],
    timestamp: DateTime.parse(map['timestamp']),
    totalAmount:
        map['totalAmount'] is int
            ? (map['totalAmount'] as int).toDouble()
            : map['totalAmount'],
    totalQuantity: map['totalQuantity'],
  );
}
