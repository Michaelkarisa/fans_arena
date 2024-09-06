import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

import '../../fans/data/newsfeedmodel.dart';


//database
class UsersData{
  Person user;
  UsersData({
    required this.user,
});
  Map<String, dynamic> toMap() {
    return {
      'userId':user.userId,
      'url':user.url,
      'collectionName':user.collectionName,
      'name':user.name,
      'location':user.location,
    };
  }

  factory UsersData.fromMap(Map<String, dynamic> map) {
    return UsersData(
      user: Person(
          name: map['name'],
          location: map['location'],
          url: map['url'],
          collectionName: map['collectionName'],
          userId: map['userId'])
    );
  }
}

class DatabaseHelper2Users {
  static final DatabaseHelper2Users instance = DatabaseHelper2Users._();
  static Database? _database;

  DatabaseHelper2Users._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
    userId TEXT PRIMARY KEY,
    url TEXT,
    collectionName TEXT,
    location TEXT,
    name TEXT
      )
    ''');
  }
  final _appUsageController = StreamController<List<UsersData>>.broadcast();

  Stream<List<UsersData>> get appUsageStream => _appUsageController.stream;

  Future<void> insertAppUsage(UsersData appUsage) async {
    final db = await database;
    await db?.insert('users', appUsage.toMap());
    _appUsageController.add(await getAppUsages());
  }

  Future<void> updateAppUsage(UsersData appUsage) async {
    final db = await database;
    final existingEntry = await db?.query(
      'users',
      where: 'userId = ?',
      whereArgs: [appUsage.user.userId],
    );

    if (existingEntry != null && existingEntry.isNotEmpty) {
      // Get the existing hoursSpent value
      // Calculate the updated hoursSpent value
      final updatedy =  appUsage.user.name;
      final updatedx =  appUsage.user.url;

      // Update the existing entry with the updated hoursSpent value
      await db?.update(
        'users',
        {
          'url': updatedx,
          'name': updatedy,
        },
        where: 'userId = ?',
        whereArgs: [appUsage.user.userId],
      );
    } else {
      // Insert a new entry
      await db?.insert('users', appUsage.toMap());
    }
    _appUsageController.add(await getAppUsages());
  }

  Future<void>data()async{
    _appUsageController.add(await getAppUsages());
  }
  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('users');
  }
  Future<UsersData?> getUser(String userId) async {
    final db = await database;
    final List<Map<String, Object?>>? result = await db?.query(
      'users',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (result != null && result.isNotEmpty) {
      return UsersData.fromMap(result[0]);
    } else {
      return null; // Return null if no records are found
    }
  }


  Future<List<UsersData>> getAppUsages() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('users');
    return List.generate(maps!.length, (i) {
      return UsersData.fromMap(maps[i]);
    });
  }
  Future<int?>remove(String userId)async{
    final db = await database;
    return await db?.delete('users',where:'userId=?',whereArgs: [userId]);
  }
}
class AppUsage {
  String userId;
  double y;
  double x;
  String identity;
  String time;
  String card;
  AppUsage({
    required this.userId,
    required this.identity,
    required this.y,
    required this.x,
    required this.time,required this.card});

  Map<String, dynamic> toMap() {
    return {
      'userId':userId,
      'identity':identity,
      'y':y,
      'x':x,
      'time':time,
      'card':card,
    };
  }

  factory AppUsage.fromMap(Map<String, dynamic> map) {
    return AppUsage(
      userId: map['userId'],
      identity: map['identity'],
      x: map['x'],
      y: map['y'],
      time: map['time'],
      card: map['card'],
    );
  }
}

class DatabaseHelper2 {
  static final DatabaseHelper2 instance = DatabaseHelper2._();
  static Database? _database;

  DatabaseHelper2._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'match.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE match(
    userId TEXT PRIMARY KEY,
    identity TEXT,
    y REAL,
     x REAL,
    time TEXT,
    card TEXT
      )
    ''');
  }
  final _appUsageController = StreamController<List<AppUsage>>.broadcast();

  Stream<List<AppUsage>> get appUsageStream => _appUsageController.stream;

  Future<void> insertAppUsage(AppUsage appUsage) async {
    final db = await database;
    await db?.insert('match', appUsage.toMap());
    _appUsageController.add(await getAppUsages());
  }

  Future<void> updateAppUsage(AppUsage appUsage) async {
    final db = await database;
    final existingEntry = await db?.query(
      'match',
      where: 'userId = ?',
      whereArgs: [appUsage.userId],
    );

    if (existingEntry != null && existingEntry.isNotEmpty) {
      // Get the existing hoursSpent value
      // Calculate the updated hoursSpent value
      final updatedy =  appUsage.y;
      final updatedx =  appUsage.x;

      // Update the existing entry with the updated hoursSpent value
      await db?.update(
        'match',
        {
          'y': updatedy,
          'x': updatedx,
        },
        where: 'userId = ?',
        whereArgs: [appUsage.userId],
      );
    } else {
      // Insert a new entry
      await db?.insert('match', appUsage.toMap());
    }
    _appUsageController.add(await getAppUsages());
  }

  Future<void>data()async{
    _appUsageController.add(await getAppUsages());
  }
  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('match');
  }
  Future<AppUsage?> getUserByIdentity(String identity) async {
    final db = await database;
    final List<Map<String, Object?>>? result = await db?.query(
      'match',
      where: 'identity = ?',
      whereArgs: [identity],
    );

    if (result != null && result.isNotEmpty) {
      return AppUsage.fromMap(result[0]);
    } else {
      return null; // Return null if no records are found
    }
  }


  Future<List<AppUsage>> getAppUsages() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('match');
    return List.generate(maps!.length, (i) {
      return AppUsage.fromMap(maps[i]);
    });
  }
  Future<int?>remove(String userId)async{
    final db = await database;
    return await db?.delete('match',where:'userId=?',whereArgs: [userId]);
  }
}

class AppUsage1 {
  String userId;
  double y;
  double x;
  String identity;
  String time;
  String card;
  AppUsage1({
    required this.userId,
    required this.identity,
    required this.y,
    required this.x,
    required this.time,
    required this.card});

  Map<String, dynamic> toMap() {
    return {
      'userId':userId,
      'identity':identity,
      'y':y,
      'x':x,
      'time':time,
      'card':card,
    };
  }

  factory AppUsage1.fromMap(Map<String, dynamic> map) {
    return AppUsage1(
      userId: map['userId'],
      identity: map['identity'],
      x: map['x'],
      y: map['y'],
      time: map['time'],
      card: map['card'],
    );
  }
}

class DatabaseHelper3 {
  static final DatabaseHelper3 instance = DatabaseHelper3._();
  static Database? _database;

  DatabaseHelper3._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sub1.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sub1(
     userId TEXT PRIMARY KEY,
    identity TEXT,
    y REAL,
     x REAL,
    time TEXT,
    card TEXT
      )
    ''');
  }
  final _appUsageController = StreamController<List<AppUsage1>>.broadcast();

  Stream<List<AppUsage1>> get appUsageStream => _appUsageController.stream;
  Future<void>data()async{
    _appUsageController.add(await getAppUsages());
  }
  Future<void> insertAppUsage(AppUsage1 appUsage) async {
    final db = await database;
    await db?.insert('sub1', appUsage.toMap());
    _appUsageController.add(await getAppUsages());
  }
  Future<void> updateAppUsage(AppUsage1 appUsage) async {
    final db = await database;
    await db?.update(
      'sub1',
      {
        'y': appUsage.y,
        'x': appUsage.x,
      },
      where: 'userId=?',
      whereArgs: [appUsage.userId],
    );
    _appUsageController.add(await getAppUsages());
  }
  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('sub1');
  }

  Future<List<AppUsage1>> getAppUsages() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('sub1');
    return List.generate(maps!.length, (i) {
      return AppUsage1.fromMap(maps[i]);
    });
  }
  Future<int?>remove(String userId)async{
    final db = await database;
    return await db?.delete('sub1',where:'userId=?',whereArgs: [userId]);

  }
}

class AppUsage2 {
  String image;
  String formation;
  int? id;
  String color;
  AppUsage2({required this.image,required this.formation,this.id,required this.color});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image':image,
      'formation':formation,
      'color':color
    };
  }

  factory AppUsage2.fromMap(Map<String, dynamic> map) {
    return AppUsage2(
      id: map['id'],
      image: map['image'],
      formation: map['formation'],
      color: map['color']
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gdata.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE gdata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image TEXT,
    color TEXT,
    formation TEXT
  )
    ''');
  }

  Future<void> insertAppUsage(AppUsage2 appUsage) async {
    final db = await database;
    await db?.insert('gdata', appUsage.toMap());
  }
  Future<void> updateAppUsage(AppUsage2 appUsage) async {
    final db = await database;
    await db?.update(
      'gdata',
      {
        'formation': appUsage.formation,
      },
      where: 'image=?',
      whereArgs: [appUsage.image],
    );
  }
  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('gdata');
  }

  Future<AppUsage2?> getAppUsage() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('gdata');

    if (maps != null && maps.isNotEmpty) {
      return AppUsage2.fromMap(maps[0]);
    } else {
      return null; // Return null if no records are found
    }
  }

  Future<int?>remove(String userId)async{
    final db = await database;
    return await db?.delete('gdata',where:'image=?',whereArgs: [userId]);
  }
}

class AppUsage3 {
  String image;
  String fieldname;
  int? id;
  AppUsage3({required this.image,this.id,required this.fieldname});

  Map<String, dynamic> toMap() {
    return {
      'fieldname':fieldname,
      'id': id,
      'image':image,
    };
  }

  factory AppUsage3.fromMap(Map<String, dynamic> map) {
    return AppUsage3(
        fieldname: map['fieldname'],
        id: map['id'],
        image: map['image'],
    );
  }
}

class DatabaseHelper1 {
  static final DatabaseHelper1 instance = DatabaseHelper1._();
  static Database? _database;

  DatabaseHelper1._();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'idata.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE idata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image TEXT,
    fieldname TEXT
  )
    ''');
  }

  Future<void> insertAppUsage(AppUsage3 appUsage) async {
    final db = await database;
    await db?.insert('idata', appUsage.toMap());
  }
  Future<void> updateAppUsage(AppUsage3 appUsage) async {
    final db = await database;
    await db?.update(
      'idata',
      {
        'image': appUsage.image,
      },
      where: 'image=?',
      whereArgs: [appUsage.image],
    );
  }
  Future<void> deleteAllAppUsage() async {
    final db = await database;
    await db?.delete('idata');
  }

  Future<List<AppUsage3>> getAppUsages() async {
    final db = await database;
    final List<Map<String, Object?>>? maps = await db?.query('idata');
    return List.generate(maps!.length, (i) {
      return AppUsage3.fromMap(maps[i]);
    });
  }

  Future<int?>remove(String userId)async{
   final db = await database;
    return await db?.delete('idata',where:'image=?',whereArgs: [userId]);
  }
}


