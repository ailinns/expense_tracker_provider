//transaction_provider
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/my_transaction.dart';

class TransactionProvider with ChangeNotifier {
  static const String _dbName = 'expenses.db';
  static const String _tableName = 'transactions';
  Database? _database;
  List<MyTransaction> _transactions = [];

  List<MyTransaction> get transactions => [..._transactions];

  TransactionProvider() {
    fetchAndSetTransactions(); // โหลดข้อมูลเมื่อ Provider ถูกสร้าง
  }

  // กระบวนการที่ 2: การสร้างฐานข้อมูล
  Future<void> _initDatabase() async {
    if (_database != null) return;
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, _dbName);
      _database = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) {
          print('Creating table $_tableName...');
          return db.execute(
            'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, amount REAL, date TEXT, type TEXT)',
          );
        },
      );
      print('Database initialized at $path');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  // กระบวนการที่ 3: การ Insert
  Future<void> addMyTransaction(
    String title,
    double amount,
    DateTime date,
    TransactionType type, {
    int? id,
  }) async {
    await _initDatabase(); // ตรวจสอบว่า DB พร้อมใช้งาน
    if (_database == null) return;
    final tx = MyTransaction(
      id: id,
      title: title,
      amount: amount,
      date: date,
      type: type,
    );
    if (tx.id == null) {
      final newId = await _database!.insert(
        _tableName,
        tx.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted new transaction (id: $newId)');
    } else {
      await _database!.update(
        _tableName,
        tx.toMap(),
        where: 'id = ?',
        whereArgs: [tx.id],
      );
      print('Updated transaction (id: ${tx.id})');
    }

    await fetchAndSetTransactions(); // โหลดข้อมูลใหม่หลัง insert
  }

  // กระบวนการที่ 4: การ Read
  Future<void> fetchAndSetTransactions() async {
    await _initDatabase();
    if (_database == null) return;

    final dataList = await _database!.query(_tableName, orderBy: 'date DESC');
    _transactions = dataList
        .map((item) => MyTransaction.fromMap(item))
        .toList();
    print('Fetched ${_transactions.length} transactions.');
    notifyListeners(); // แจ้ง UI ให้วาดใหม่
  }

  // กระบวนการที่ 5: การ Update
  Future<void> updateTransaction(int id, MyTransaction newTransaction) async {
    if (_database == null) return;
    await _database!.update(
      _tableName,
      newTransaction.toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
    await fetchAndSetTransactions();
  }

  // กระบวนการที่ 6: การ Delete
  Future<void> deleteTransaction(int id) async {
    if (_database == null) return;
    await _database!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    await fetchAndSetTransactions();
  }
    Future<MyTransaction?> getById(int id) async {
    await _initDatabase();
    final result = await _database!.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return MyTransaction.fromMap(result.first);
    }
    return null;
  }
}
