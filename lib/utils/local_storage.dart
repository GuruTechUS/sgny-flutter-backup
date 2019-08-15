/*
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class LocalStorage{


  String dbPath = 'assets/db/local.db';
  DatabaseFactory dbFactory = databaseFactoryIo;
  Database db;
  LocalStorage() {
    dataBase();
  }

  dataBase() async {
    db = await dbFactory.openDatabase(dbPath);
    return db;
  }

  setValue(key, value) async {
    Database db = dataBase();
    await db.put(value, key);
  }

  getValue(key) async {
    Database db = dataBase();
    return await db.get(key) as String; 
  }

  deleteValue(key) async {
    Database db = dataBase();
    return await db.get(key) as String; 
  }

}
*/