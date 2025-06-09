import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/quotation.dart';
import '../models/invoice.dart';
import '../models/product.dart';
import '../models/user.dart';

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
      version: 9, // Bump version to force migration for totalQuantitySold
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        imageUrl TEXT,
        restockThreshold INTEGER,
        stockQty INTEGER,
        unitPrice REAL,
        status TEXT,
        discontinued INTEGER,
        expiry_date TEXT,
        createdAt TEXT NOT NULL,
        createdBy TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        updatedBy TEXT NOT NULL,
        lastSoldAt TEXT,
        totalRevenueGenerated INTEGER,
        totalQuantitySold INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        email TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS quotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        date TEXT NOT NULL,
        userId INTEGER,
        FOREIGN KEY (userId) REFERENCES users(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceId TEXT NOT NULL,
        cashier TEXT,
        customerName TEXT NOT NULL,
        discount REAL,
        grandTotal REAL,
        items TEXT NOT NULL,
        notes TEXT,
        paymentMethod TEXT,
        soldBy TEXT,
        status TEXT,
        tax REAL,
        timestamp TEXT,
        totalAmount REAL,
        totalQuantity INTEGER
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
    if (oldVersion < 3) {
      // Upgrade logic for version 3 if needed
    }
    if (oldVersion < 4) {
      // Ensure users table exists on upgrade
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT,
          role TEXT,
          email TEXT
        )
      ''');
    }
    if (oldVersion < 5) {
      // Add email column if not exists
      await db.execute('ALTER TABLE users ADD COLUMN email TEXT');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE quotations ADD COLUMN userId INTEGER');
      await db.execute('ALTER TABLE invoices ADD COLUMN userId INTEGER');
    }
    if (oldVersion < 7) {
      // Add new columns for the new product schema if they do not exist
      await db.execute('ALTER TABLE products ADD COLUMN productId TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN imageUrl TEXT');
      await db.execute(
        'ALTER TABLE products ADD COLUMN restockThreshold INTEGER',
      );
      await db.execute('ALTER TABLE products ADD COLUMN stockQty INTEGER');
      await db.execute('ALTER TABLE products ADD COLUMN unitPrice REAL');
      await db.execute('ALTER TABLE products ADD COLUMN status TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN discontinued INTEGER');
      await db.execute('ALTER TABLE products ADD COLUMN expiry_date TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN createdAt TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN createdBy TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN updatedBy TEXT');
      await db.execute('ALTER TABLE products ADD COLUMN lastSoldAt TEXT');
      await db.execute(
        'ALTER TABLE products ADD COLUMN totalRevenueGenerated INTEGER',
      );
    }
    if (oldVersion < 8) {
      await db.execute('ALTER TABLE invoices ADD COLUMN invoiceId TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN cashier TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN discount REAL');
      await db.execute('ALTER TABLE invoices ADD COLUMN grandTotal REAL');
      await db.execute('ALTER TABLE invoices ADD COLUMN items TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN notes TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN paymentMethod TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN soldBy TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN status TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN tax REAL');
      await db.execute('ALTER TABLE invoices ADD COLUMN timestamp TEXT');
      await db.execute('ALTER TABLE invoices ADD COLUMN totalQuantity INTEGER');
      await db.execute('ALTER TABLE invoices ADD COLUMN grandTotal REAL');
    }
    if (oldVersion < 9) {
      // Add totalQuantitySold column if not exists
      await db.execute(
        'ALTER TABLE products ADD COLUMN totalQuantitySold INTEGER DEFAULT 0',
      );
    }
  }

  // Insert a new quotation, now with userId
  Future<int> insertQuotation(Quotation quotation, {int? userId}) async {
    final db = await database;
    final data = quotation.toMap();
    if (userId != null) data['userId'] = userId;
    final quotationId = await db.insert('quotations', data);

    for (var item in quotation.items) {
      await db.insert(
        'quotation_items',
        item.toMap()..['quotationId'] = quotationId,
      );
    }
    return quotationId;
  }

  // Update an existing quotation
  Future<int> updateQuotation(Quotation quotation) async {
    final db = await instance.database;

    // Update the quotation in the database
    return await db.update(
      'quotations', // Table name
      quotation.toMap(), // Convert the quotation to a map
      where: 'id = ?', // Specify the row to update
      whereArgs: [quotation.id], // Pass the ID as an argument
    );
  }

  // Delete a quotation by ID
  Future<int> deleteQuotation(int id) async {
    final db = await database;
    return await db.delete('quotations', where: 'id = ?', whereArgs: [id]);
  }

  // Insert a new invoice, now with userId
  // Also decrease product stock for each product in the invoice
  Future<int> insertInvoice(Invoice invoice, {int? userId}) async {
    final db = await database;
    final data = invoice.toMap();
    if (userId != null) data['userId'] = userId;
    final invoiceId = await db.insert('invoices', data);

    // Decrease product stock for each product in the invoice items
    for (var item in invoice.items) {
      final List<Map<String, dynamic>> result = await db.query(
        'products',
        where: 'productId = ?',
        whereArgs: [item.productId],
      );
      if (result.isNotEmpty) {
        final currentStock = result.first['stockQty'] as int;
        final newStock = currentStock - item.quantity;
        // Increment totalRevenueGenerated and totalQuantitySold
        final currentRevenue =
            (result.first['totalRevenueGenerated'] ?? 0) as num;
        final newRevenue = currentRevenue + (item.unitPrice * item.quantity);
        final currentQtySold = (result.first['totalQuantitySold'] ?? 0) as int;
        final newQtySold = currentQtySold + item.quantity;
        await db.update(
          'products',
          {
            'stockQty': newStock,
            'totalRevenueGenerated': newRevenue,
            'totalQuantitySold': newQtySold,
            'lastSoldAt': DateTime.now().toIso8601String(),
          },
          where: 'productId = ?',
          whereArgs: [item.productId],
        );
      }
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
    return result.map((map) => Invoice.fromMap(map)).toList();
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

  // USER TABLE LOGIC
  Future<void> createUserTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        role TEXT,
        email TEXT
      )
    ''');
  }

  Future<int> insertUser(User user) async {
    final db = await instance.database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await instance.database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  Future<int> updateUser(User user) async {
    final db = await instance.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Get all quotations for a user (admin can get all)
  Future<List<Quotation>> getQuotationsByUser(int? userId) async {
    final db = await database;
    List<Map<String, dynamic>> result;
    if (userId != null) {
      result = await db.query(
        'quotations',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } else {
      result = await db.query('quotations');
    }
    List<Quotation> quotations = [];
    for (var map in result) {
      final items = await _getQuotationItems(map['id']);
      quotations.add(Quotation.fromMap(map, items));
    }
    return quotations;
  }

  // Get all invoices for a user (admin can get all)
  Future<List<Invoice>> getInvoicesByUser(int? userId) async {
    final db = await database;
    List<Map<String, dynamic>> result;
    if (userId != null) {
      result = await db.query(
        'invoices',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    } else {
      result = await db.query('invoices');
    }
    return result.map((map) => Invoice.fromMap(map)).toList();
  }

  // Get products with stock less than a threshold (default 5)
  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'products',
      where: 'stockQty < ?',
      whereArgs: [threshold],
    );
    return result.map((map) => Product.fromMap(map)).toList();
  }

  // Update an existing product
  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // Delete a product by ID
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
