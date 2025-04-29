import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quotation.dart';
import '../models/invoice.dart';
import '../models/product.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'boutique_manager.db');

    return await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: _createDb,
      onUpgrade: _upgradeDb, // Add this line
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        stock INTEGER NOT NULL,
        reorderLevel INTEGER NOT NULL,
        lastSoldDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE quotation_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        quotationId INTEGER,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (quotationId) REFERENCES quotations(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        date TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        isPaid INTEGER NOT NULL,
        products TEXT NOT NULL -- Store serialized JSON string
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId INTEGER,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        FOREIGN KEY (invoiceId) REFERENCES invoices(id)
      )
    ''');
  }

  Future<void> _upgradeDb(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE invoices ADD COLUMN products TEXT NOT NULL DEFAULT "[]"',
      );
    }
  }

  // Insert a new quotation
  Future<int> insertQuotation(Quotation quotation) async {
    final db = await database;
    final quotationId = await db.insert('quotations', quotation.toMap());

    for (var item in quotation.items) {
      await db.insert(
        'quotation_items',
        item.toMap()..['quotationId'] = quotationId,
      );
    }
    return quotationId;
  }

  // Delete a quotation by ID
  Future<int> deleteQuotation(int id) async {
    final db = await database;
    return await db.delete('quotations', where: 'id = ?', whereArgs: [id]);
  }

  // Insert a new invoice
  Future<int> insertInvoice(Invoice invoice) async {
    final db = await database; // Products are now serialized as JSON
    final invoiceId = await db.insert('invoices', invoice.toMap());

    for (var item in invoice.items) {
      await db.insert('invoice_items', item.toMap()..['invoiceId'] = invoiceId);
    }
    return invoiceId;
  }

  // Update an existing invoice
  Future<int> updateInvoice(Invoice invoice) async {
    final db = await database;
    return await db.update(
      'invoices',
      invoice.toMap(),
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  // Delete an invoice by ID
  Future<int> deleteInvoice(int id) async {
    final db = await database;
    return await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
  }

  // Get all quotations
  Future<List<Quotation>> getAllQuotations() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('quotations');

    List<Quotation> quotations = [];
    for (var map in result) {
      final items = await _getQuotationItems(map['id']);
      quotations.add(Quotation.fromMap(map, items));
    }
    return quotations;
  }

  // Get all invoices
  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('invoices');

    List<Invoice> invoices = [];
    for (var map in result) {
      final items = await _getInvoiceItems(
        map['id'],
      ); // Fetch items for each invoice
      invoices.add(Invoice.fromMap(map, items)); // Pass both map and items
    }
    return invoices;
  }

  // Get all products
  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('products');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Insert a new product
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  // Helper method to get quotation items
  Future<List<QuotationItem>> _getQuotationItems(int quotationId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'quotation_items',
      where: 'quotationId = ?',
      whereArgs: [quotationId],
    );
    return result.map((map) => QuotationItem.fromMap(map)).toList();
  }

  // Helper method to get invoice items
  Future<List<QuotationItem>> _getInvoiceItems(int invoiceId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'invoice_items',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );
    return result.map((map) => QuotationItem.fromMap(map)).toList();
  }
}
