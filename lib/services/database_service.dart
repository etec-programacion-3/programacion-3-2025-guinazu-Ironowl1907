import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workout_logger/models/models.dart';

class DatabaseService {
  Database? db;

  Future<void> initDB() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master.db");
    print("Searching for Db on: $databasePath");
    db = await openDatabase(databasePath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Creating database tables...");
    for (String query in DatabaseSchema.getAllCreateTableQueries()) {
      await db.execute(query);
      print("Executed: ${query.split('(')[0].trim()}");
    }
    print("Database tables created successfully");
  }

  Future<void> closeDatabase() async {
    if (db != null) {
      await db!.close();
      db = null;
    }
  }

  Future<void> deleteDB() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "master.db");
    await deleteDatabase(databasePath);
    db = null;
  }
}
