import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('scan_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';
    // const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE history ( 
  id $idType, 
  barcode $textType,
  productName $textType,
  isSafe $boolType,
  scanDate $textType
  )
''');
  }

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
