import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('scanme.db'); // Renamed DB
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Increment version to trigger schema update if needed, but since we are dev, we can just handle onCreate 
    // strictly speaking if the app is already installed with version 1, we should handle onUpgrade. 
    // For simplicity in this dev session, I'll assume clean install or increment version and handle upgrade.
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // History Table
    await db.execute('''
CREATE TABLE history ( 
  id $idType, 
  barcode $textType,
  productName $textType,
  isSafe $boolType,
  scanDate $textType
  )
''');

    // Users Table
    await db.execute('''
CREATE TABLE users (
  id $idType,
  email $textType,
  password $textType
)
''');

    // User Allergens Table
    await db.execute('''
CREATE TABLE user_allergens (
  id $idType,
  userId $integerType,
  allergen $textType
)
''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const integerType = 'INTEGER NOT NULL';

      await db.execute('''
CREATE TABLE users (
  id $idType,
  email $textType,
  password $textType
)
''');

      await db.execute('''
CREATE TABLE user_allergens (
  id $idType,
  userId $integerType,
  allergen $textType
)
''');
    }
  }

  // --- User CRUD ---
  Future<int> createUser(User user) async {
    final db = await instance.database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUser(String email, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'email', 'password'],
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }
  
  // --- Allergen CRUD ---
  Future<int> addUserAllergen(int userId, String allergen) async {
    final db = await instance.database;
    return await db.insert('user_allergens', {
      'userId': userId,
      'allergen': allergen,
    });
  }

  Future<int> removeUserAllergen(int userId, String allergen) async {
    final db = await instance.database;
    return await db.delete(
      'user_allergens',
      where: 'userId = ? AND allergen = ?',
      whereArgs: [userId, allergen],
    );
  }

  Future<List<String>> getUserAllergens(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      'user_allergens',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((json) => json['allergen'] as String).toList();
  }

  // --- History CRUD ---
  Future<int> create(ScanItem item) async {
    final db = await instance.database;
    return await db.insert('history', item.toJson());
  }

  Future<List<ScanItem>> readAllHistory() async {
    final db = await instance.database;
    const orderBy = 'scanDate DESC';
    final result = await db.query('history', orderBy: orderBy);
    return result.map((json) => ScanItem.fromJson(json)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class ScanItem {
  final int? id;
  final String barcode;
  final String productName;
  final bool isSafe;
  final DateTime scanDate;

  ScanItem({
    this.id,
    required this.barcode,
    required this.productName,
    required this.isSafe,
    required this.scanDate,
  });

  ScanItem copyWith({
    int? id,
    String? barcode,
    String? productName,
    bool? isSafe,
    DateTime? scanDate,
  }) =>
      ScanItem(
        id: id ?? this.id,
        barcode: barcode ?? this.barcode,
        productName: productName ?? this.productName,
        isSafe: isSafe ?? this.isSafe,
        scanDate: scanDate ?? this.scanDate,
      );

  static ScanItem fromJson(Map<String, Object?> json) => ScanItem(
        id: json['id'] as int?,
        barcode: json['barcode'] as String,
        productName: json['productName'] as String,
        isSafe: (json['isSafe'] as int) == 1,
        scanDate: DateTime.parse(json['scanDate'] as String),
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'barcode': barcode,
        'productName': productName,
        'isSafe': isSafe ? 1 : 0,
        'scanDate': scanDate.toIso8601String(),
      };
}

class User {
  final int? id;
  final String email;
  final String password;

  User({this.id, required this.email, required this.password});

  static User fromJson(Map<String, Object?> json) => User(
        id: json['id'] as int?,
        email: json['email'] as String,
        password: json['password'] as String,
      );

  Map<String, Object?> toJson() => {
        'id': id,
        'email': email,
        'password': password,
      };
}
