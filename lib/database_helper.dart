import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tlaxcala_world/business_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<List<String>> getUniqueBusinessTypes() async {
    final db =
        await database; // Assuming `database` is a method returning the db instance
    final result =
        await db.rawQuery('SELECT DISTINCT businessType FROM businesses');
    return result.map((row) => row['businessType'] as String).toList();
  }

  Future<void> updateBusiness(Business business) async {
    final db = await database;

    await db.update(
      'businesses',
      business.toMap(),
      where: 'id = ?',
      whereArgs: [business.id],
    );
  }

  Future<List<String>> getCategoriesForType(String businessType) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM businesses WHERE businessType = ?',
      [businessType],
    );
    return result.map((row) => row['category'] as String).toList();
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'app_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT UNIQUE,
          password TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE businesses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      businessType TEXT,
      category TEXT,
      review TEXT,
      imagePaths TEXT,
      phone TEXT,
      address TEXT,
      services TEXT,
      addedValue TEXT,
      opinions TEXT,
      whatsapp TEXT,
      promotions TEXT,
      photos TEXT,
      locationLink TEXT,
      eventDate TEXT,
      openingHours TEXT,
      prices TEXT
    )
      ''');
      },
      version: 1,
    );
  }

  Future<List<Map<String, dynamic>>> getBusinessesByCategory(
      String category) async {
    final db = await database;
    return await db.query(
      'businesses', // Replace with your actual table name
      where: 'category = ?', // Query businesses by category
      whereArgs: [category],
    );
  }

  Future<void> addBusiness(Business business) async {
    final db = await database;
    await db.insert(
      'businesses',
      business.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBusiness(int id) async {
    final db = await database;

    await db.delete(
      'businesses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getBusinesses() async {
    final db = await database;
    return await db.query('businesses');
  }

  Future<void> registerUser(String username, String password) async {
    final db = await database;
    await db.insert('users', {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Map<String, dynamic>?> getUser(
      String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> createBusinessesTable(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS businesses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      businessType TEXT,
      category TEXT,
      review TEXT,
      phone TEXT,
      address TEXT,
      services TEXT,
      addedValue TEXT,
      opinions TEXT,
      whatsapp TEXT,
      promotions TEXT,
      photos TEXT,
      locationLink TEXT,
      eventDate TEXT,
      openingHours TEXT,
      prices TEXT
    )
  ''');
  }
}
