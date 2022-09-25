import 'package:clock_app/models/db_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

final String tableElements = 'entries';
final String columnId = 'id';
final String columnChecked = 'checked';
final String columnNotification = 'notification';
final String columnTitle = 'title';
final String columnUrl1 = 'url1';
final String columnUrl2 = 'url2';
final String columnUrl3 = 'url3';
final String columnUrlp = 'urlp';

class DBHelper {
  static Database _database;
  static DBHelper _dbHelper;

  DBHelper._createInstance();
  factory DBHelper() {
    if (_dbHelper == null) {
      _dbHelper = DBHelper._createInstance();
    }
    return _dbHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    var dir = await getDatabasesPath();
    var path = dir + "entries.db";

    var database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
          create table $tableElements ( 
          $columnId integer primary key autoincrement, 
          $columnTitle text not null,
          $columnChecked integer,
          $columnUrl1 text,
          $columnUrl2 text,
          $columnUrl3 text,
          $columnUrlp text,
          $columnNotification integer)
        ''');
      },
    );
    return database;
  }

  void insertElement(DBInfo dbInfo) async {
    var db = await this.database;
    var result = await db.insert(tableElements, dbInfo.toMap());
    print('result : $result');
  }

  Future<List<DBInfo>> getElements() async {
    List<DBInfo> _elements = [];

    var db = await this.database;
    var result = await db.query(tableElements);
    result.forEach((element) {
      var dbInfo = DBInfo.fromMap(element);
      _elements.add(dbInfo);
    });

    return _elements;
  }

  Future<int> delete(int id) async {
    var db = await this.database;
    return await db
        .delete(tableElements, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<DBInfo> update(DBInfo element) async {
    final db = await this.database;
    await db.update(tableElements, element.toMap(),
        where: columnId + " = ?", whereArgs: [element.id]);
    return element;
  }
}
