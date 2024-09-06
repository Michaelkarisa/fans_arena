import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';


// Check for cache

class stories{
  String userId;
  String caption;
  String media;
  String time;
  stories({required this.userId,required this.caption,required this.media,required this.time});
  factory stories.fromMap(Map<String,dynamic>json)=>stories(
    userId: json['userId'], caption:json['caption'], media: json['media'], time:  json['time'],
  );
  Map<String, dynamic> toMap(){
    return{
      'userId':userId,
      'caption':caption,
      'media':media,
      'time':time,
    };
  }
}
class DatabaseHelper{
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance= DatabaseHelper._privateConstructor();
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  static Database? _database;
  Future<Database> get database async=>_database ??=await _initDatabase();
  Future<Database>_initDatabase()async{
    Directory documentsDirectory= await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path,'stories.db');
    return await openDatabase(path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  Future _onCreate(Database db, int version)async{
    await db.execute('''
    CREATE TABLE stories(
    userId TEXT PRIMARY KEY,
    message TEXT,
    time TEXT
    )
    ''');
  }
  Future<List<stories>>getPlayer()async {
    Database db=await instance.database;
    var players = await db.query('stories',orderBy: 'time');
    List<stories>playersList=players.isNotEmpty? players.map((c) => stories.fromMap(c)).toList():[];
    return playersList;
  }
  Future<int>add(stories player)async{
    Database db = await instance.database;
    return await db.insert('stories', player.toMap());
  }
  Future<int>remove(String userId)async{
    Database db= await instance.database;
    return await db.delete('stories',where:'userId=?',whereArgs: [userId]);
  }
  Future<int>delete()async{
    Database db=await instance.database;
    return await db.delete('stories');
  }
  void initializePlayer(String url) async {
    final fileInfo = await checkCacheFor(url);
    if (fileInfo == null) {
      _controller = VideoPlayerController.network(url);
      _controller!.initialize().then((value) {
        cachedForUrl(url);
          _controller!.setLooping(true);
          _controller!.play();
          _controller!.setVolume(0.0); // Unmute the video
          _isPlaying = true;

      });
    } else {
      final file = fileInfo.file;
      _controller = VideoPlayerController.file(file);

      _controller!.initialize().then((value) {
          _controller!.setLooping(true);
          _controller!.play();
          _controller!.setVolume(0.0); // Unmute the video
          _isPlaying = true;
      });
    }
  }
  Future<FileInfo?> checkCacheFor(String url) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
    return value;
  }

// Cache Url Data
  void cachedForUrl(String url) async {
    await DefaultCacheManager().getSingleFile(url).then((value) {
      print('downloaded successfully done for $url');
    });
  }
}

class StoryModel{
  String time;
  String caption;
  String userId;
  String Iurl;
  String Vurl;
  String storyId;

  StoryModel({
    required this.storyId,
    required this.caption,
    required this.time,
    required this.Iurl,
    required this.userId,
    required this.Vurl,
  });
}

