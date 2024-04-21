import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'main.dart'; // This imports Chore from main.dart

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path + "chores.db";
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    print("Database initialized at $path");
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE Chores(id TEXT PRIMARY KEY, name TEXT, status TEXT, points INTEGER)",
    );
    print("Table created");
  }

  Future<int> saveChore(Chore chore) async {
    var dbClient = await db;
    int res = await dbClient.insert("Chores", chore.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    print("Chore saved: ${chore.name}");
    return res;
  }

  Future<int> updateChore(Chore chore) async {
    var dbClient = await db;
    int res = await dbClient.update("Chores", chore.toMap(), where: "id = ?", whereArgs: [chore.id]);
    print("Chore updated: ${chore.name}, Status: ${chore.status}");
    return res;
  }

  Future<List<Chore>> getChores() async {
    var dbClient = await db;
    List<Map> list = await dbClient.rawQuery('SELECT * FROM Chores');
    List<Chore> chores = [];
    for (int i = 0; i < list.length; i++) {
      chores.add(Chore.fromMap(list[i].cast<String, dynamic>()));
    }
    print("Chores loaded: ${chores.length}");
    return chores;
  }

  Future<int> deleteChore(String id) async {
    var dbClient = await db;
    int res = await dbClient.delete("Chores", where: "id = ?", whereArgs: [id]);
    print("Chore deleted: ID $id");
    return res;
  }

}
