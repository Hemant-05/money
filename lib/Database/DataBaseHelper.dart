import 'dart:math';

import 'package:money_tracker/Models/ExpenseModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DataBaseHelper {
  static int version = 1;
  // static Database database = getDB();

  static Future<Database> getDB() async {
    String path = join(await getDatabasesPath(), 'expense_db.db');
    Database expense_db = await openDatabase(path, onCreate: (db, v) async {
     await db.execute(
          'create table if not exists expenseTable(id integer primary key autoincrement,type text,time text,date text,expense integer,total_exp integer)');
    }, version: version);
   return expense_db;
  }

  static Future<int> insert(ExpenseModel model) async{
    Database db = await getDB();
    return db.insert('expenseTable', model.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
  }
  static Future<int> delete(int id) async{
    Database db = await getDB();
    return db.delete('expenseTable',where: 'id = ?',whereArgs: [id]);
  }
  static Future<int> update(ExpenseModel model) async{
    Database db = await getDB();
    return db.update('expenseTable', model.toMap(),where: 'id = ?', whereArgs: [model.id]);
  }

  static Future<List<ExpenseModel>> allExpenses() async{
    Database db = await getDB();
    List<Map<String,dynamic>> expeneses = await db.query('expenseTable');
    return List.generate(expeneses.length, (index) => ExpenseModel.fromjson(expeneses[index]));
  }
}
