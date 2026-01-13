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

    return await openDatabase(path, version: 4, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // History Table with backendId for syncing with backend
    await db.execute('''
CREATE TABLE history ( 
  id $idType, 
  userId $integerType,
  backendId INTEGER,
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
    if (oldVersion < 3) {
       // Recreate history to add userId column
       await db.execute('DROP TABLE IF EXISTS history');
       
       const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
       const textType = 'TEXT NOT NULL';
       const boolType = 'INTEGER NOT NULL';
       const integerType = 'INTEGER NOT NULL';
       
      await db.execute('''
CREATE TABLE history ( 
  id $idType, 
  userId $integerType,
  backendId INTEGER,
  barcode $textType,
  productName $textType,
  isSafe $boolType,
  scanDate $textType
  )
''');
    }
    
    if (oldVersion < 4) {
      // Add backendId column for existing databases
      await db.execute('ALTER TABLE history ADD COLUMN backendId INTEGER');
    }
    
    // Ensure Users and Allergens tables exist (for v1->v2->v3 path)
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

  /// Get user by email only (for hashed password verification)
  Future<User?> getUserByEmail(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'email', 'password'],
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    } else {
      return null;
    }
  }
  
  /// Check if email already exists
  Future<bool> emailExists(String email) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
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
  Future<int> create(ScanItem item, int userId) async {
    final db = await instance.database;
    final json = item.toJson();
    json['userId'] = userId;
    return await db.insert('history', json);
  }

  Future<List<ScanItem>> readAllHistory(int userId) async {
    final db = await instance.database;
    const orderBy = 'scanDate DESC';
    final result = await db.query(
      'history', 
      where: 'userId = ?', 
      whereArgs: [userId], 
      orderBy: orderBy
    );
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

  /// Update the backend ID for a local history entry after syncing with backend
  Future<int> updateBackendId(int localId, int backendId) async {
    final db = await instance.database;
    return await db.update(
      'history',
      {'backendId': backendId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

class ScanItem {
  final int? id;           // Local SQLite ID
  final int? backendId;    // Backend ID for syncing
  final String barcode;
  final String productName;
  final bool isSafe;
  final DateTime scanDate;

  ScanItem({
    this.id,
    this.backendId,
    required this.barcode,
    required this.productName,
    required this.isSafe,
    required this.scanDate,
  });

  ScanItem copyWith({
    int? id,
    int? backendId,
    String? barcode,
    String? productName,
    bool? isSafe,
    DateTime? scanDate,
  }) =>
      ScanItem(
        id: id ?? this.id,
        backendId: backendId ?? this.backendId,
        barcode: barcode ?? this.barcode,
        productName: productName ?? this.productName,
        isSafe: isSafe ?? this.isSafe,
        scanDate: scanDate ?? this.scanDate,
      );

  static ScanItem fromJson(Map<String, Object?> json) {
    var isSafeVal = json['isSafe'];
    bool safe;
    if (isSafeVal is int) {
      safe = isSafeVal == 1;
    } else if (isSafeVal is bool) {
      safe = isSafeVal;
    } else {
      safe = false; // Fallback
    }

    return ScanItem(
      id: json['id'] as int?,
      backendId: json['backendId'] as int?,
      barcode: json['barcode'] as String,
      productName: json['productName'] as String,
      isSafe: safe,
      scanDate: DateTime.parse(json['scanDate'] as String),
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'backendId': backendId,
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