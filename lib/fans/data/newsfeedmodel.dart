import 'dart:async';
import 'package:fans_arena/main.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../joint/data/screens/feed_item.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../fans/screens/newsfeed.dart';
import 'package:fans_arena/clubs/screens/accountclubviewer.dart';
import 'package:fans_arena/fans/screens/accountfanviewer.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiver/iterables.dart';
import 'package:intl/intl.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/components/likebutton.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../screens/viewstory.dart';

class Person{
  String userId;
  String url;
  String name;
  String collectionName;
  String location;
  Timestamp? timestamp;
  String motto;
  String genre;
  Person({required this.name,
    required this.url,
    required this.collectionName,
    required this.userId,
    this.location='',
    this.timestamp,
    this.motto='',
    this.genre='',
  });
  Map<String, dynamic> toMap() {
    return {
     'name':name,
      'url':url,
      'collection':collectionName,
      'userId':userId,
      'location':location,
      'genre': genre,
    };
  }

  factory Person.fromJson(Map<String, dynamic> map) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    return Person(
        name: map['name'],
        url:map['url'],
        collectionName: map['collection'],
        userId: map['userId'],
      location: map['location'],
        genre: map['genre'],
      timestamp: convertToTimestamp(map['createdAt'])
    );
  }
}

class Users{
  String collectionName;
  String userId;
  Timestamp timestamp;
  String name;
  String url;
  int iden;
  Users({
    required this.userId,
    required this.timestamp,
    required this.url,
    required this.name,
    required this.iden,
    required this.collectionName
  });
}

class PostModel {
  String location;
  String time;
  String genre;
  String postid;
  List<Map<String, dynamic>> captionUrl;
  Timestamp timestamp;
  String time1;
  Person user;
  bool commenting;
  bool likes;
  PostModel({
    required this.postid,
    required this.location,
    required this.time,
    required this.genre,
    required this.captionUrl,
    required this.timestamp,
    required this.time1,
    required this.user,
    this.commenting=true,
    this.likes=true,
  });
}

class PostModel1{
  String location;
  String time;
  String caption;
  String genre;
  String url;
  String postid;
  Timestamp timestamp;
  String time1;
  Person user;
  bool commenting;
  bool likes;
  PostModel1({
    required this.postid,
    required this.caption,
    required this.location,
    required this.time,
    required this.genre,
    required this.url,
    required this.timestamp,
    required this.time1,
    required this.user,
    this.commenting=true,
    this.likes=true,
  });
}

class Events{
  int duration;
  String location;
  String status;
  String starttime;
  String matchId;
  String createdat;
  Timestamp timestamp;
  String tittle;
  Person user;
  Timestamp? startime;
  Timestamp? stoptime;
  Events({
    required this.matchId,
    required this.timestamp,
    required this.location,
    required this.status,
    required this.starttime,
    required this.createdat,
    required this.tittle,
    required this.user,
    this.startime,
    this.stoptime,
    this.duration=0,
  });
}

class Matches{
  int duration;
  Person club1;
  Person club2;
  Person league;
  String authorId;
  int score1;
  int score2;
  String location;
  String status;
  String starttime;
  String matchId;
  String createdat;
  String leaguematchId;
  Timestamp timestamp;
  String tittle;
  String match1Id;
  String status1;
  Timestamp? startime;
  Timestamp? stoptime;
  Matches({
    required this.matchId,
    required this.timestamp,
    required this.score1,
    required this.score2,
    required this.location,
    required this.status,
    required this.starttime,
    required this.createdat,
    required this.tittle,
    required this.leaguematchId,
    required this.match1Id,
    required this.status1,
    required this.authorId,
    required this.club1,
    required this.club2,
    required this.league,
    this.startime,
    this.stoptime,
    this.duration=0,
  });
}

class Leagues {
  String leagueId;
  String authorId;
  String leaguename;
  String imageurl;
  String location;
  String genre;
  Timestamp timestamp;
  String accountType;
  Leagues({
    required this.accountType,
    required this.authorId,
    required this.leagueId,
    required this.leaguename,
    required this.imageurl,
    required this.genre,
    required this.location,
    required this.timestamp,
  });
}

class Stories{
  Person user;
  List<Map<String, dynamic>> story;
  String time;
  Timestamp timestamp;
  Stories({
    required this.user,
    required this.story,
    required this.time,required this.timestamp});
}

class Newsfeedservice {
  Set<PostModel> _postListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      List<dynamic> captionUrlList = doc['captionUrl'] ?? [];
      List<Map<String, dynamic>>captionUrl=[];
      captionUrl.addAll(captionUrlList.cast<Map<String, dynamic>>());
      Timestamp createdAt = doc['createdAt'] ?? Timestamp.now();
      DateTime createdDateTime = createdAt.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(createdDateTime);
      String formattedTime = '';
      String hours = DateFormat('HH').format(createdDateTime);
      String minutes = DateFormat('mm').format(createdDateTime);
      String t = DateFormat('a').format(createdDateTime); // AM/PM
      if (difference.inSeconds == 1) {
        formattedTime = 'now';
      } else if (difference.inSeconds < 60) {
        formattedTime = 'now';
      } else if (difference.inMinutes == 1) {
        formattedTime = '${difference.inMinutes} minute ago';
      } else if (difference.inMinutes < 60) {
        formattedTime = '${difference.inMinutes} minutes ago';
      } else if (difference.inHours == 1) {
        formattedTime = '${difference.inHours} hour ago';
      } else if (difference.inHours < 24) {
        formattedTime = '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        formattedTime = '${difference.inDays} day ago';
      } else if (difference.inDays < 7) {
        formattedTime = '${difference.inDays} days ago';
      } else if (difference.inDays ==7) {
        formattedTime = '${difference.inDays ~/ 7} weeks ago';
      } else {
        formattedTime = DateFormat('d MMM').format(createdDateTime);
      }
      String name='';
      String url='';
      String cName='';
      FirebaseFirestore.instance.collection('Clubs').doc(doc['authorId']).get().then((data){
        if(data.exists){
          name=data['Clubname']??'';
          cName="Club";
          url=data['profileimage']??'';
        }else{
          FirebaseFirestore.instance.collection('Professionals').doc(doc['authorId']).get().then((data1){
            if(data.exists){
              name=data1['Stagename']??'';
              cName="Professional";
              url=data1['profileimage']??'';
            }else{
              FirebaseFirestore.instance.collection('Fans').doc(doc['authorId']).get().then((data2){
                if(data2.exists) {
                  name = data2['username'] ?? '';
                  cName = "Fan";
                  url = data2['profileimage'] ?? '';
                }
              });
            }
          } );
        }
      } );
      return PostModel(
        user: Person(
          name: name,
          url: url,
          collectionName:cName,
          userId: doc['authorId'] ?? '',
        ),
        postid: doc.id,
        location: doc['location'] ?? '',
        time: formattedTime,
        genre: doc['genre'] ?? '',
        captionUrl: captionUrl,
        timestamp: doc['createdAt'],
        time1: 'at $hours:$minutes $t',
        commenting: doc.data().toString().contains('commenting')?doc['commenting']:true,
        likes: doc.data().toString().contains('likes')?doc['likes']:true,
      );
    }).toSet();
  }

  List<PostModel1> _postListFromSnapshot0(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {

      Timestamp createdAt = doc['createdAt'] ?? Timestamp.now();
      DateTime createdDateTime = createdAt.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(createdDateTime);
      String formattedTime = '';
      String hours = DateFormat('HH').format(createdDateTime);
      String minutes = DateFormat('mm').format(createdDateTime);
      String t = DateFormat('a').format(createdDateTime); // AM/PM
      if (difference.inSeconds == 1) {
        formattedTime = 'now';
      } else if (difference.inSeconds < 60) {
        formattedTime = 'now';
      } else if (difference.inMinutes == 1) {
        formattedTime = '${difference.inMinutes} minute ago';
      } else if (difference.inMinutes < 60) {
        formattedTime = '${difference.inMinutes} minutes ago';
      } else if (difference.inHours == 1) {
        formattedTime = '${difference.inHours} hour ago';
      } else if (difference.inHours < 24) {
        formattedTime = '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        formattedTime = '${difference.inDays} day ago';
      } else if (difference.inDays < 7) {
        formattedTime = '${difference.inDays} days ago';
      } else if (difference.inDays ==7) {
        formattedTime = '${difference.inDays ~/ 7} weeks ago';
      } else {
        formattedTime = DateFormat('d MMM').format(createdDateTime);
      }
      String name='';
      String url='';
      String cName='';
      FirebaseFirestore.instance.collection('Clubs').doc(doc['authorId']).get().then((data){
        if(data.exists){
          name=data['Clubname']??'';
          cName="Club";
          url=data['profileimage']??'';
        }else{
          FirebaseFirestore.instance.collection('Professionals').doc(doc['authorId']).get().then((data1){
            if(data.exists){
              name=data1['Stagename']??'';
              cName="Professional";
              url=data1['profileimage']??'';
            }else{
              FirebaseFirestore.instance.collection('Fans').doc(doc['authorId']).get().then((data2){
                if(data2.exists) {
                  name = data2['username'] ?? '';
                  cName = "Fan";
                  url = data2['profileimage'] ?? '';
                }
              });
            }
          } );
        }
      } );
      return PostModel1(
        postid: doc.id,
        caption: doc['caption'] ?? '',
        location: doc['location'] ?? '',
        time: formattedTime,
        genre: doc['genre'] ?? '',
        url: doc['url'] ?? '',
        timestamp: doc['createdAt'],
        time1: 'at $hours:$minutes $t',
        user: Person(
          name: name,
          url: url,
          collectionName: cName,
          userId: doc['authorId'] ?? '',
        ),
        commenting: doc.data().toString().contains('commenting')?doc['commenting']:true,
        likes: doc.data().toString().contains('likes')?doc['likes']:true,
      );
    }).toList();
  }
  List<Stories> _postListFromSnapshot2(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      List<dynamic> story = doc['story'] ?? [];
      List<Map<String, dynamic>>storyy=[];
      storyy.addAll(story.cast<Map<String, dynamic>>());
      Timestamp createdAt = doc['createdAt'] ?? Timestamp.now();
      DateTime createdDateTime = createdAt.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(createdDateTime);
      String formattedTime = '';
      if (difference.inSeconds == 1) {
        formattedTime = 'now';
      } else if (difference.inSeconds < 60) {
        formattedTime = 'now';
      } else if (difference.inMinutes == 1) {
        formattedTime = '${difference.inMinutes} minute ago';
      } else if (difference.inMinutes < 60) {
        formattedTime = '${difference.inMinutes} minutes ago';
      } else if (difference.inHours == 1) {
        formattedTime = '${difference.inHours} hour ago';
      } else if (difference.inHours < 24) {
        formattedTime = '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        formattedTime = '${difference.inDays} day ago';
      } else if (difference.inDays < 7) {
        formattedTime = '${difference.inDays} days ago';
      } else if (difference.inDays ==7) {
        formattedTime = '${difference.inDays ~/ 7} weeks ago';
      } else {
        formattedTime = DateFormat('d MMM').format(createdDateTime);
      }
      String name='';
      String url='';
      String cName='';
      FirebaseFirestore.instance.collection('Clubs').doc(doc['authorId']).get().then((data){
        if(data.exists){
          name=data['Clubname']??'';
          cName="Club";
          url=data['profileimage']??'';
        }else{
          FirebaseFirestore.instance.collection('Professionals').doc(doc['authorId']).get().then((data1){
            if(data.exists){
              name=data1['Stagename']??'';
              cName="Professional";
              url=data1['profileimage']??'';
            }else{
              FirebaseFirestore.instance.collection('Fans').doc(doc['authorId']).get().then((data2){
                if(data2.exists) {
                  name = data2['username'] ?? '';
                  cName = "Fan";
                  url = data2['profileimage'] ?? '';
                }
              });
            }
          } );
        }
      } );
      return Stories(
        user:Person(
          name: name,
          url: url,
          userId: doc['authorId']??'',
          collectionName: cName,
        ),
        story: storyy,
        time: formattedTime,
        timestamp: doc['createdAt'],
      );
    }).toList();
  }

  List<Leagues> _postListFromSnapshot4(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Leagues(
        leagueId: doc.id,
        genre: doc['genre'] ?? '',
        imageurl: doc['profileimage'] ?? '',
        authorId: doc['authorId'] ?? '',
        leaguename: doc['leaguename']??'',
        location:doc['location']??'',
        timestamp: doc['createdAt'],
        accountType: doc['accountType']??'',
      );
    }).toList();
  }

  Future<List<String>> getuserfollowing(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Fans')
        .doc(userId)
        .collection('following')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsArray = doc['following'];
      for (var club in clubsArray) {
        String clubUserId = club['userId'];
        userIds.add(clubUserId);
      }
    }
    return userIds;
  }

  Future<List<String>> getuserfollowing1(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Fans')
        .doc(userId)
        .collection('clubs')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsArray = doc['clubs'];
      for (var club in clubsArray) {
        String clubUserId = club['userId'];
        userIds.add(clubUserId);
      }
    }
    return userIds;
  }

  Future<List<String>> getuserfollowing2(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Fans')
        .doc(userId)
        .collection('professionals')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsArray = doc['professionals'];
      for (var club in clubsArray) {
        String clubUserId = club['userId'];
        userIds.add(clubUserId);
      }
    }
    return userIds;
  }


  Future<List<MatchM>> getallMatches({required String userId}) async {
    List<MatchM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .where('authorId',isEqualTo: userId)
        .orderBy('createdAt',descending: true)
        .limit(10)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      MatchM match=await getmatch(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<MatchM>getmatch(DocumentSnapshot doc)async{
    final club1=await getPerson(userId:doc['club1Id']==""||doc['club1Id']==null?'xxxxx':doc['club1Id']);
    final club2=await getPerson(userId: doc['club2Id']==""||doc['club2Id']==null?'xxxxx':doc['club2Id']);
    final league=await getPerson(userId: doc['leagueId']==""||doc['leagueId']==null?'xxxxx':doc['leagueId']);
    Timestamp createdAt = doc['scheduledDate'] ?? Timestamp.now();
    DateTime createdDateTime = createdAt.toDate();
    String formattedTime = '';
    formattedTime = DateFormat('d MMM').format(createdDateTime);
    return MatchM(
        startime: doc['starttime']==""||doc['starttime']==null?Timestamp.now():doc["starttime"],
        stoptime: doc["stoptime"]==""||doc['stoptime']==null?Timestamp.now():doc["stoptime"],
        duration: doc["duration"]==0||doc['duration']==null?0:doc["duration"],
        matchId: doc.id,
        timestamp: doc['scheduledDate'],
        score1: doc['score1'],
        score2: doc['score2'],
        location: doc['location'],
        status: doc['state1'],
        starttime: doc['time'],
        createdat: formattedTime,
        tittle: doc['title'],
        leaguematchId: doc['leaguematchId'],
        match1Id: doc['match1Id'],
        status1: doc['state2'],
        authorId:doc['authorId'],
        club1: club1,
        club2: club2,
        league:league);
  }
  Future<List<MatchM>> getallMatches1({required MatchM lastmatch,required String userId}) async {
    List<MatchM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .where('authorId',isEqualTo: userId)
        .orderBy('createdAt',descending: true)
        .startAfter([lastmatch.timestamp])
        .limit(5)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      MatchM match=await getmatch(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getmatches() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    List<MatchM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('scheduledDate', isGreaterThanOrEqualTo: startOfWeek, isLessThan: endOfWeek)
        .orderBy('scheduledDate', descending: true)
        .limit(20)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      MatchM match=await getmatch(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getmatchesM({required Matches last}) async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    List<MatchM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('scheduledDate', isGreaterThanOrEqualTo: startOfWeek, isLessThan: endOfWeek)
        .orderBy('scheduledDate', descending: true)
        .startAfter([last.timestamp])
        .limit(1)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      MatchM match=await getmatch(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getmatchesP() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    List<String> userClub = await getuserclub(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [ ...userClub,];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<MatchM> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isGreaterThanOrEqualTo: startOfWeek,
          isLessThan: endOfWeek)
          .orderBy('scheduledDate', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        MatchM match=await getmatch(doc);
        feedlist.add(match);
      }
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getmatches1() async {
    final now = DateTime.now();
    final yesterday=DateTime(now.year,now.month,now.day-1);
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final endTimestamp = Timestamp.fromDate(yesterday); // Current time
    final startTimestamp = Timestamp.fromDate(sevenDaysAgo);
    List<String> userClubs = await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe = await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs, ...userProfe, FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<MatchM> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('scheduledDate', isLessThanOrEqualTo: endTimestamp)
          .orderBy('scheduledDate', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        MatchM match=await getmatch(doc);
        feedlist.add(match);
      }
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getfiltermatches({required DateTime from,required DateTime to,required String userId}) async {
    List<MatchM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .where('authorId',isEqualTo: userId)
        .where('scheduledDate', isGreaterThanOrEqualTo: from)
        .where('scheduledDate', isLessThanOrEqualTo: to)
        .orderBy('scheduledDate', descending: true)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      MatchM match=await getmatch(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getmatches2() async {
    final now = DateTime.now();
    final today=DateTime(now.year,now.month,now.day);
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
    final endOfWeek = startOfWeek.add(const Duration(days: 7,));
    List<String> userClubs =
    await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe =
    await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs, ...userProfe, FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<MatchM> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isGreaterThan: Timestamp.fromDate(today))
          .where('scheduledDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
          .orderBy('scheduledDate', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        MatchM match=await getmatch(doc);
        feedlist.add(match);
      }
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<MatchM>> getMatches2() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<String> userClubs = await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe = await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs, ...userProfe, FirebaseAuth.instance.currentUser!.uid];
    List<List<String>> splitCombinedList = partition<String>(combinedList, 2).toList();
    List<MatchM> feedList = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isEqualTo: today)
          .orderBy('createdAt', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        MatchM match=await getmatch(doc);
        feedList.add(match);
      }
    }
    feedList.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });

    return feedList;
  }


  Future<List<EventM>> getallEvents({required String userId}) async {
    List<EventM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('authorId',isEqualTo: userId)
        .orderBy('createdAt',descending: true)
        .limit(10)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      EventM match=await getevent(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<EventM>getevent(DocumentSnapshot doc)async{
    final author=await getPerson(userId:doc['authorId']==""||doc['authorId']==null?'xxxxx':doc['authorId']);
    Timestamp createdAt = doc['scheduledDate'] ?? Timestamp.now();
    DateTime createdDateTime = createdAt.toDate();
    String formattedTime = '';
    formattedTime = DateFormat('d MMM').format(createdDateTime);
    return EventM(
        startime: doc['starttime']==""||doc['starttime']==null?Timestamp.now():doc["starttime"],
        stoptime: doc["stoptime"]==""||doc['stoptime']==null?Timestamp.now():doc["stoptime"],
        duration: doc["duration"]==0||doc['duration']==null?0:doc["duration"],
        eventId: doc.id,
        timestamp: doc['scheduledDate'],
        location: doc['location'],
        status: doc['state1'],
        starttime: doc['time'],
        createdat: formattedTime,
        title: doc['title'],
        status1: doc['state2'],
        user:author
    );
  }

  Future<List<EventM>> getfilterevents({required DateTime from,required DateTime to,required String userId}) async {
    List<EventM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('authorId',isEqualTo: userId)
        .where('scheduledDate', isGreaterThanOrEqualTo: from)
        .where('scheduledDate', isLessThanOrEqualTo: to)
        .orderBy('scheduledDate', descending: true)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      EventM match=await getevent(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<EventM>> getallEvents1({required EventM lastevent,required String userId}) async {
    List<EventM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('authorId',isEqualTo: userId)
        .orderBy('createdAt',descending: true)
        .startAfter([lastevent.timestamp])
        .limit(5)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      EventM match=await getevent(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<EventM>> getevents() async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    List<EventM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('scheduledDate', isGreaterThanOrEqualTo: startOfWeek, isLessThan: endOfWeek)
        .orderBy('scheduledDate', descending: true)
        .limit(20)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      EventM match=await getevent(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<EventM>> geteventsM({required Events last}) async {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    List<EventM> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Events')
        .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('scheduledDate', isGreaterThanOrEqualTo: startOfWeek, isLessThan: endOfWeek)
        .orderBy('scheduledDate', descending: true)
        .startAfter([last.timestamp])
        .limit(1)
        .get();
    List<DocumentSnapshot> docs=querySnapshot.docs;
    for(var doc in docs){
      EventM match=await getevent(doc);
      feedlist.add(match);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<EventM>> getevents1() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final yesterday=DateTime(now.year,now.month,now.day-1);
    final endTimestamp = Timestamp.fromDate(yesterday); // Current time
    final startTimestamp = Timestamp.fromDate(sevenDaysAgo);
    List<String> userClubs =
    await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe =
    await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [ ...userClubs, ...userProfe, FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<EventM> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isGreaterThanOrEqualTo: startTimestamp)
          .where('scheduledDate', isLessThanOrEqualTo: endTimestamp)
          .orderBy('scheduledDate', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        EventM match=await getevent(doc);
        feedlist.add(match);
      }
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<EventM>> getevents2() async {
    final now = DateTime.now();
    final today=DateTime(now.year,now.month,now.day);
    final startOfWeek = DateTime(now.year, now.month, now.day - now.weekday);
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    List<String> userClubs =
    await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe =
    await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs, ...userProfe, FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<EventM> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isGreaterThan: Timestamp.fromDate(today))
          .where('scheduledDate', isLessThanOrEqualTo: endOfWeek)
          .orderBy('scheduledDate', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        EventM match=await getevent(doc);
        feedlist.add(match);
      }
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<EventM>> getEvents2() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<String> userClubs = await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe = await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs, ...userProfe, FirebaseAuth.instance.currentUser!.uid];
    List<List<String>> splitCombinedList = partition<String>(combinedList, 2).toList();
    List<EventM> feedList = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .where('authorId', whereIn: splitCombinedList[i])
          .where('scheduledDate', isEqualTo: today)
          .orderBy('createdAt', descending: true)
          .get();
      List<DocumentSnapshot> docs=querySnapshot.docs;
      for(var doc in docs){
        EventM match=await getevent(doc);
        feedList.add(match);
      }
    }
    feedList.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedList;
  }


  Future<List<PostModel>> getfeed1({required List<String>postIds}) async {
    List<String> combinedList = [...postIds];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('postId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      feedlist.addAll(_postListFromSnapshot(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel>> getfeed({required String userId}) async {
    List<String> combinedList = [userId];
    List<List> splitCombinedList = partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      Set<PostModel> posts = _postListFromSnapshot(querySnapshot);
      feedlist.addAll(posts);
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }


  Future<List<PostModel>> getfeed5() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .get();
    return _postListFromSnapshot(querySnapshot).toList();
  }


  Future<List<Stories>> getStories() async {
    List<String> userfollowing = await getuserfollowing(FirebaseAuth.instance.currentUser!.uid);
    List<String> userClubs = await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userProfe = await getuserfollowing2(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userfollowing, ...userClubs,...userProfe];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<Stories> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Story')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot2(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<Stories>> getStories1() async {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    List<String> userClub = await getuserteam(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClub,];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<Stories> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Story')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot2(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<Stories>> getStories2() async {
    List<String> userClub = await getuserclub(FirebaseAuth.instance.currentUser!.uid);
    List<String>userTaccounts = await getuserTaccounts(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClub,...userTaccounts];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<Stories> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Story')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot2(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<String>> getuserfans(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Professionals')
        .doc(userId)
        .collection('fans')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsArray = doc['fans'];
      for (var club in clubsArray) {
        String clubUserId = club['userId'];
        userIds.add(clubUserId);
      }
    }
    return userIds;
  }

  Future<List<String>> getuserTaccounts(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Professionals')
        .doc(userId)
        .collection('trustedaccounts')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsArray = doc['accounts'];
      for (var club in clubsArray) {
        String clubUserId = club['userId'];
        userIds.add(clubUserId);
      }
    }
    return userIds;
  }

  Future<List<String>> getuserclub(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Professionals')
        .doc(userId)
        .collection('club')
        .get();
    final clubs = querySnapshot.docs.map((doc) => doc.id).toList();
    return clubs;
  }

  Future<List<String>> getleagues() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .get();
    final clubs = querySnapshot.docs.map((doc) => doc.id).toList();
    return clubs;
  }

  Future<List<String>> getleague({required String userId}) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Leagues').where('authorId',isEqualTo: userId)
        .get();
    final clubs = querySnapshot.docs.map((doc) => doc.id).toList();
    return clubs;
  }

  Future<Set<String>> getleagues1({required String userId}) async {
    List<String> userClubs = await getleagues();
    List<String> userClubs1 = await getuserfollowing1(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs];
    List<List<String>> splitCombinedList = partition<String>(combinedList, 2).toList();
    Set<String> leagues = <String>{};
    for (int i1 = 0; i1 < splitCombinedList.length; i1++) {
      List<String> leagueIds = splitCombinedList[i1];
      for (String leagueId in leagueIds) {
        QuerySnapshot yearSnapshot = await FirebaseFirestore.instance
            .collection('Leagues')
            .doc(leagueId)
            .collection('year')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        if (yearSnapshot.docs.isNotEmpty) {
          String latestYearDocId = yearSnapshot.docs.first.id;
          QuerySnapshot clubSnapshot = await FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(latestYearDocId)
              .collection('clubs')
              .get();
          final List<QueryDocumentSnapshot> likeDocuments = clubSnapshot.docs;
          for (final document in likeDocuments) {
            final List<dynamic> likesArray = document['clubs'];
            for (final item in likesArray) {
              final clubId = item['clubId'];
              for (int i = 0; i < userClubs1.length; i++) {
                if (clubId == userClubs1[i]) {
                  leagues.add(leagueId);
                }
              }
            }}
        }
      }
    }
    return leagues;
  }

  Future<Set<String>> getleagues2({required String userId}) async {
    List<String> userClubs = await getleagues();
    List<String> combinedList = [...userClubs];
    List<List<String>> splitCombinedList = partition<String>(combinedList, 2).toList();
    Set<String> leagues = <String>{};
    for (int i1 = 0; i1 < splitCombinedList.length; i1++) {
      List<String> leagueIds = splitCombinedList[i1];
      for (String leagueId in leagueIds) {
        QuerySnapshot yearSnapshot = await FirebaseFirestore.instance
            .collection('Leagues')
            .doc(leagueId)
            .collection('year')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        if (yearSnapshot.docs.isNotEmpty) {
          String latestYearDocId = yearSnapshot.docs.first.id;
          QuerySnapshot clubSnapshot = await FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(latestYearDocId)
              .collection('clubs')
              .get();
          final List<QueryDocumentSnapshot> likeDocuments = clubSnapshot.docs;
          for (final document in likeDocuments) {
            final List<dynamic> likesArray = document['clubs'];
            for (final item in likesArray) {
              final clubId = item['clubId'];
              if (clubId == userId) {
                leagues.add(leagueId);
              }
            }
          }}
      }
    }
    return leagues;
  }

  Future<Set<String>> getleagues3({required String userId}) async {
    List<String> userClubs1 = await getuserclub(FirebaseAuth.instance.currentUser!.uid);
    List<String> userClubs = await getleagues();
    List<String> combinedList = [...userClubs];
    List<List<String>> splitCombinedList = partition<String>(combinedList, 2).toList();
    Set<String> leagues = <String>{};
    for (int i1 = 0; i1 < splitCombinedList.length; i1++) {
      List<String> leagueIds = splitCombinedList[i1];
      for (String leagueId in leagueIds) {
        QuerySnapshot yearSnapshot = await FirebaseFirestore.instance
            .collection('Leagues')
            .doc(leagueId)
            .collection('year')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        if (yearSnapshot.docs.isNotEmpty) {
          String latestYearDocId = yearSnapshot.docs.first.id;
          QuerySnapshot clubSnapshot = await FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('year')
              .doc(latestYearDocId)
              .collection('clubs')
              .get();
          final List<QueryDocumentSnapshot> likeDocuments = clubSnapshot.docs;
          for (final document in likeDocuments) {
            final List<dynamic> likesArray = document['clubs'];
            for (final item in likesArray) {
              final clubId = item['clubId'];
              for (int i = 0; i < userClubs1.length; i++) {
                if (clubId == userClubs1[i]) {
                  leagues.add(leagueId);
                }
              }
            }}
        }
      }
    }
    return leagues;
  }

  Future<Set<String>> getSubleagues({required String userId}) async {
    List<String> userClubs = await getleagues();
    List<String> combinedList = [...userClubs];
    List<List<String>> splitCombinedList = partition<String>(combinedList, 2).toList();
    Set<String> leagues = <String>{};
    for (int i1 = 0; i1 < splitCombinedList.length; i1++) {
      List<String> leagueIds = splitCombinedList[i1];
      for (String leagueId in leagueIds) {
        QuerySnapshot subsriberssnapshot = await FirebaseFirestore.instance
            .collection('Leagues')
            .doc(leagueId)
            .collection('subscribers')
            .get();
        final List<QueryDocumentSnapshot> likeDocuments = subsriberssnapshot.docs;
        for (final document in likeDocuments) {
          final List<dynamic> likesArray = document['subscribers'];
          for (final item in likesArray) {
            final clubId = item['userId'];
            if (clubId == userId) {
              leagues.add(leagueId);
            }
          }
        }
      }
    }
    return leagues;
  }

  Future<List<Leagues>> getusersleagues2({required String userId}) async {
    Set<String> userLeagues1 = await getSubleagues(userId: userId);
    Set<String> userLeagues = await getleagues3(userId:userId);
    Set<String> userLeagues2 = await getleague(userId:userId).then((value) => value.toSet());
    Set<String>leagues={};
    leagues.addAll(userLeagues);
    Future.delayed(const Duration(milliseconds: 1));
    leagues.addAll(userLeagues1);
    Future.delayed(const Duration(milliseconds: 1));
    leagues.addAll(userLeagues2);
    List<String> combinedList = [...leagues];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<Leagues> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('leagueId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot4(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<Leagues>> getusersleagues1({required String userId}) async {
    Set<String> userLeagues1 = await getSubleagues(userId: userId);
    Set<String> userLeagues = await getleagues2(userId:userId);
    Set<String>leagues={};
    leagues.addAll(userLeagues);
    leagues.addAll(userLeagues1);
    List<String> combinedList = [...leagues];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<Leagues> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('leagueId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot4(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<Leagues>> getusersleagues({required String userId}) async {
    Set<String> userLeagues1 = await getSubleagues(userId: userId);
    Set<String> userLeagues = await getleagues1(userId:userId);
    Set<String>leagues={};
    leagues.addAll(userLeagues);
    leagues.addAll(userLeagues1);
    List<String> combinedList = [...leagues];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<Leagues> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('leagueId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot4(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel>> getPost1() async {
    List<String> userClubs = await getuserfans(FirebaseAuth.instance.currentUser!.uid);
    List<String> userClub = await getuserclub(FirebaseAuth.instance.currentUser!.uid);
    List<String>userTaccounts = await getuserTaccounts(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs,...userClub,...userTaccounts,FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();
      feedlist.addAll(_postListFromSnapshot(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }
  Future<List<String>> getuserfans1(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Clubs')
        .doc(userId)
        .collection('fans')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsArray = doc['fans'];
      for (var club in clubsArray) {
        String clubUserId = club['userId'];
        userIds.add(clubUserId);
      }
    }
    return userIds;
  }

  Future<List<String>> getuserteam(String userId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Clubs')
        .doc(userId)
        .collection('clubsteam')
        .get();
    List<String> userIds = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      List<dynamic> clubsteam = doc['clubsteam'];
      for (var club in clubsteam) {
        String teamId = club['teamId'];
        userIds.add(teamId);
      }
    }
    return userIds;
  }

  Future<List<PostModel>> getfeed2() async {
    List<String> userClubs = await getuserfans1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userClub = await getuserteam(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs,...userClub,FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      feedlist.addAll(_postListFromSnapshot(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel>> getMyfeed({required String userId}) async {
    List<String> combinedList = [userId];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .limit(15)
          .get();
      feedlist.addAll(_postListFromSnapshot(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel>> getMyfeed1({required PostModel startpost,required String userId}) async {
    List<String> combinedList = [userId];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .startAfter([startpost.timestamp])
          .limit(6)
          .get();
      feedlist.addAll(_postListFromSnapshot(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel>> getPost2() async {
    List<String> userClubs = await getuserfans1(FirebaseAuth.instance.currentUser!.uid);
    List<String> userClub = await getuserteam(FirebaseAuth.instance.currentUser!.uid);
    List<String> combinedList = [...userClubs,...userClub,FirebaseAuth.instance.currentUser!.uid];
    List<List> splitCombinedList =
    partition<dynamic>(combinedList, 2).toList();
    List<PostModel> feedlist = [];
    for (int i = 0; i < splitCombinedList.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', whereIn: splitCombinedList[i])
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();
      feedlist.addAll(_postListFromSnapshot(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel1>> getfeed3() async {
    List<String> userClubs = await getuserfans1(FirebaseAuth.instance.currentUser!.uid);
    List<List> splitUserClubs = partition<dynamic>(userClubs, 10).toList();
    List<PostModel1> feedlist = [];
    for (int i = 0; i < splitUserClubs.length; i++) {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('FansTv')
          .where('authorId', whereIn: splitUserClubs[i])
          .orderBy('createdAt', descending: true)
          .get();
      feedlist.addAll(_postListFromSnapshot0(querySnapshot));
    }
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel1>> getFansTv() async {
    List<PostModel1> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('FansTv')
        .orderBy('createdAt', descending: true)
        .limit(4)
        .get();
    feedlist.addAll(_postListFromSnapshot0(querySnapshot));
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<FansTv>getFansTv0({required String postId})async{
    DocumentSnapshot doc=await FirebaseFirestore.instance.collection('FansTv').doc(postId).get();
    if(doc.exists) {
      Timestamp timestamp = doc['createdAt'];
      DateTime createdDateTime = timestamp.toDate();
      DateTime now = DateTime.now();
      Duration difference = now.difference(createdDateTime);
      String formattedTime = '';
      String hours = DateFormat('HH').format(createdDateTime);
      String minutes = DateFormat('mm').format(createdDateTime);
      String t = DateFormat('a').format(createdDateTime); // AM/PM
      if (difference.inSeconds == 1) {
        formattedTime = 'now';
      } else if (difference.inSeconds < 60) {
        formattedTime = 'now';
      } else if (difference.inMinutes == 1) {
        formattedTime = '${difference.inMinutes} minute ago';
      } else if (difference.inMinutes < 60) {
        formattedTime = '${difference.inMinutes} minutes ago';
      } else if (difference.inHours == 1) {
        formattedTime = '${difference.inHours} hour ago';
      } else if (difference.inHours < 24) {
        formattedTime = '${difference.inHours} hours ago';
      } else if (difference.inDays == 1) {
        formattedTime = '${difference.inDays} day ago';
      } else if (difference.inDays < 7) {
        formattedTime = '${difference.inDays} days ago';
      } else if (difference.inDays == 7) {
        formattedTime = '${difference.inDays ~/ 7} weeks ago';
      } else {
        formattedTime = DateFormat('d MMM').format(createdDateTime);
      }
      Person p=await getPerson(userId: doc['authorId']);
      return FansTv(
          user: p,
          postid:doc.id,
          timestamp: timestamp,
          time: formattedTime,
          caption: doc['caption']??'',
          url: doc['url']??'',
          location: doc['location']??'',
          genre:doc['genre'],
          time1: ''
      );
    }else{
      return FansTv(
          user: Person(name:'',
            url: '',
            collectionName: '',
            userId: '',),
          postid:doc.id,
          timestamp:Timestamp.now(),
          time: '',
          caption: '',
          url: '',
          location: '',
          genre:'',
          time1: ''
      );
    }
  }

  Future<List<PostModel1>> getFansTvv({required String userId}) async {
    List<PostModel1> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('FansTv')
        .where('authorId',isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(15)
        .get();
    feedlist.addAll(_postListFromSnapshot0(querySnapshot));
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<List<PostModel1>> getFansTvv1({required PostModel1 startat,required String userId}) async {
    List<PostModel1> feedlist = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('FansTv')
        .where('authorId',isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .startAfter([startat.timestamp])
        .limit(6)
        .get();
    feedlist.addAll(_postListFromSnapshot0(querySnapshot));
    feedlist.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });
    return feedlist;
  }

  Future<Person> getPerson({required String userId}) async {
    final collections = ['Fans', 'Professionals', 'Clubs', 'Leagues'];
    final fieldNames = ['username', 'Stagename', 'Clubname', 'leaguename'];
    for (int i = 0; i < collections.length; i++) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collections[i])
          .doc(userId)
          .get();
      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return Person(
          name: data[fieldNames[i]],
          url: data['profileimage'],
          collectionName: collections[i].substring(0, collections[i].length - 1),
          userId: documentSnapshot.id,
          genre: data['genre']??'',
        );
      }
    }
    return Person(
      name: '',
      url: '',
      collectionName: '',
      userId: '',
    );
  }

  Future<List<Users>> retrieveUserData2() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Fans').orderBy('createdAt',descending: true).limit(5).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Users> uFans = [];
        for (var documentSnapshot in querySnapshot.docs) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          Users users=Users(
              userId:documentSnapshot.id,
              name:data['username']??'',
              url:data['profileimage']??'',
              timestamp: data['createdAt'],
              iden:0, collectionName: 'Fan');
          uFans.add(users);
        }
        return uFans;
      } else {
        return [];
      }
    } catch (e) {
      return [];

    }
  }

  Future<List<Users>> retrieveUserData1() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Clubs').orderBy('createdAt',descending: true).limit(5).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Users> uFans = [];
        for (var documentSnapshot in querySnapshot.docs) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          Users users=Users(
              userId: documentSnapshot.id,
              name:data['Clubname']??'',
              url:data['profileimage']??'',
              timestamp: data['createdAt'],
              iden:2, collectionName: 'Club');
          uFans.add(users);
        }
        return uFans;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Users>> retrieveUserData3() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Professionals').orderBy('createdAt',descending: true).limit(5).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Users> uFans = [];
        for (var documentSnapshot in querySnapshot.docs) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          Users users=Users(
              userId: documentSnapshot.id,
              name:data['Stagename']??'',
              url:data['profileimage']??'',
              timestamp: data['createdAt'],
              iden:1, collectionName: 'Professional');
          uFans.add(users);
        }
        return uFans;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Users>> retrieveUserDataM2({required Users last}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Fans').orderBy('createdAt',descending: true)
          .startAfter([last.timestamp])
          .limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Users> uFans = [];
        for (var documentSnapshot in querySnapshot.docs) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          Users users=Users(
              userId:documentSnapshot.id,
              name:data['username']??'',
              url:data['profileimage']??'',
              timestamp: data['createdAt'],
              iden:0, collectionName: 'Fan');
          uFans.add(users);
        }
        return uFans;
      } else {
        return [];
      }
    } catch (e) {
      return [];

    }
  }

  Future<List<Users>> retrieveUserDataM1({required Users last}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Clubs').orderBy('createdAt',descending: true)
          .startAfter([last.timestamp])
          .limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Users> uFans = [];
        for (var documentSnapshot in querySnapshot.docs) {
          var data = documentSnapshot.data() as Map<String, dynamic>;

          Users users=Users(
              userId: documentSnapshot.id,
              name:data['Clubname']??'',
              url:data['profileimage']??'',
              timestamp: data['createdAt'],
              iden:2, collectionName: 'Club');
          uFans.add(users);
        }
        return uFans;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Users>> retrieveUserDataM3({required Users last}) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Professionals').orderBy('createdAt',descending: true)
          .startAfter([last.timestamp])
          .limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        List<Users> uFans = [];
        for (var documentSnapshot in querySnapshot.docs) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          Users users=Users(
              userId: documentSnapshot.id,
              name:data['Stagename']??'',
              url:data['profileimage']??'',
              timestamp: data['createdAt'],
              iden:1, collectionName: 'Professional');
          uFans.add(users);
        }
        return uFans;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<String> getAccount(String userId) async {
    String collectionName='';
    try {
      QuerySnapshot querySnapshotA = await FirebaseFirestore.instance
          .collection('Fans')
          .where('Fanid', isEqualTo: userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await FirebaseFirestore.instance
          .collection('Professionals')
          .where('profeid', isEqualTo: userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await FirebaseFirestore.instance
          .collection('Clubs')
          .where('Clubid', isEqualTo: userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotD = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('leagueId', isEqualTo: userId)
          .limit(1)
          .get();
      if (querySnapshotA.docs.isNotEmpty) {
        collectionName = 'Fan';
      } else if (querySnapshotB.docs.isNotEmpty) {
        collectionName = 'Professional';
      } else if (querySnapshotC.docs.isNotEmpty) {
        collectionName = 'Club';
      } else if (querySnapshotD.docs.isNotEmpty) {
        collectionName = 'League';
      } else {
        return collectionName;
      }
      return collectionName;
    } catch (e) {
      return collectionName;
    }
  }


}


class PostLayout extends StatefulWidget {
  final Posts post;
  PostLayout({super.key, required this.post});
  @override
  State<PostLayout> createState() => _PostLayoutState();
}

class _PostLayoutState extends State<PostLayout> {
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();
  bool isNotExpanded = false;
  int maxTextLength = 100;
  String location = '';
  int ind = 0;
  double radius = 23;
  late Future<Size> data;
  @override
  void initState() {
    super.initState();
    _pageController1.addListener(_onPageChanged);
    setState(() {
      aspectRatio=widget.post.captionUrl[ind]['width']/widget.post.captionUrl[ind]['height'];
      location = _truncateText(widget.post.location);
    });
  }
  String _truncateText(String text) {
    if (text.length <= maxTextLength) {
      return text;
    } else if (text.length > maxTextLength && !isNotExpanded) {
      return "${text.substring(0, maxTextLength - 5)}...";
    } else {
      return "$text ";
    }
  }

  void _onPageChanged()async{
    if (_pageController1.page != _pageController2.page) {
      setState(() {
        aspectRatio=widget.post.captionUrl[ind]['width']/widget.post.captionUrl[ind]['height'];
      });
      _pageController2.jumpToPage(_pageController1.page!.toInt());
    }
  }
  List<String>hashes=["mine","Fans Arena","Sports","Ganze","Football","Basketball","NBAkenya","FiFA","UEFA","FKF","VolleyballKenya"];

  @override
  void dispose() {
    _pageController1.removeListener(_onPageChanged);
    _pageController1.dispose();
    _pageController2.dispose();
    super.dispose();
  }
  double aspectRatio=1.0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.003333,
          child: Divider(
            thickness: 2,
            color: Colors.grey[300],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.975,
            height: 55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomAvatar(radius: radius, imageurl: widget.post.user.url),
                SizedBox(
                  height: 55,
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.0333,
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      if (widget.post.user.collectionName == 'Club') {
                                        return AccountclubViewer(user: widget.post.user, index: 0);
                                      } else if (widget.post.user.collectionName == 'Professional') {
                                        return AccountprofilePviewer(user: widget.post.user, index: 0);
                                      } else {
                                        return Accountfanviewer(user: widget.post.user, index: 0);
                                      }
                                    },
                                  ),
                                );
                              },
                              child: UsernameDO(
                                username: widget.post.user.name,
                                collectionName: widget.post.user.collectionName,
                                width: 160,
                                height: 38,
                                maxSize: 140,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                              height: 32,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    isDismissible: true,
                                    backgroundColor: Colors.transparent,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                                    ),
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FirebaseAuth.instance.currentUser!.uid==widget.post.user.userId? Optionposts(post: widget.post, collection: 'posts',):OptionPosts1(
                                        postId: widget.post.postid,
                                        collection: 'posts',
                                        authorId: widget.post.user.userId, url: widget.post.captionUrl[ind]['url'],
                                      );
                                    },
                                  );
                                },
                                child: const Icon(Icons.more_vert),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.87,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              location,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  widget.post.time,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  widget.post.time1,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.003333,
          child: Divider(
            thickness: 2,
            color: Colors.grey[300],
          ),
        ),
        AspectRatio(
          aspectRatio:aspectRatio ,
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.post.captionUrl.length,
                  controller: _pageController1,
                  itemBuilder: (context, index) {
                    final captionUrl = widget.post.captionUrl[index];
                    return CachedNetworkImage(
                      imageUrl: captionUrl['url']!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 40),
                      ),
                    );
                  },
                  onPageChanged: (int index){
                   // final imagesize=await _getImageDimensions(widget.post.captionUrl[index]['url']);
                    setState(() {
                   //   aspectRatio=imagesize.width / imagesize.height;
                      ind = index;
                    });
                  },
                ),
                if (widget.post.captionUrl.length > 1)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxHeight: 20,
                              maxWidth: 50,
                              minHeight: 0,
                              minWidth: 0,
                            ),
                            decoration: const BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.black,
                            ),
                            child: Center(
                              child: Text(
                                '${ind + 1}/${widget.post.captionUrl.length}',
                                style: const TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        LikeArea(post: widget.post),
        Padding(
          padding: const EdgeInsets.only(left: 5,top:5),
          child: widget.post.captionUrl.isNotEmpty
              ?   SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Wrap(
              children: [
                Wrap(
                  children: hashes.map((h)=> Text('#$h', style: const TextStyle(color: Colors.blue)),
                  ).toList(),
                ),
                Readmore1(text:"${widget.post.captionUrl[ind]['caption']}")
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.003333,
          child: Divider(
            thickness: 2,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
  Future<Size> _getImageDimensions(String imageUrl) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.network(imageUrl);

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );

    return completer.future;
  }
}





class OtherUsers extends StatefulWidget {
  Story story;
  List<Story> stories;
  OtherUsers({super.key,required this.stories,required this.story});

  @override
  State<OtherUsers> createState() => _OtherUsersState();
}

class _OtherUsersState extends State<OtherUsers> {
  @override
  void initState() {
    super.initState();
    widget.story.story.sort((a, b){
      Timestamp latestTimestampA = b['timestamp'];
      Timestamp latestTimestampB = a['timestamp'];
      return latestTimestampB.compareTo(latestTimestampA);
    });
    if( widget.story.story.last['url'].toString().isNotEmpty) {
      initializeImage(widget.story.story.last['url'].toString());
    }
  }
  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
          video: videoUrl,
          imageFormat: ImageFormat.PNG,
          maxHeight: 240,
          maxWidth: 150,
          quality: 25,
          timeMs: 1500
      );
      return thumbnailData;
    } catch (e) {
      return null;
    }
  }

  final BaseCacheManager cacheManager = DefaultCacheManager();

  String thumbnailUrl = '';
  File? thumbnailFile;


  void initializeImage(String videoUrl) async {
    if (videoUrl.isEmpty) return;
    final cacheKey = '${widget.story.StoryId}_thumbnail';
    FileInfo? cachedFile = await cacheManager.getFileFromCache(cacheKey);
    if (cachedFile != null) {
      setState(() {
        thumbnailFile = cachedFile.file;
      });
    } else {
      Uint8List? thumbnailData = await generateThumbnail(videoUrl);
      if (thumbnailData != null) {
        File file = await cacheManager.putFile(
          cacheKey,
          thumbnailData,
          fileExtension: 'png',
        );
        setState(() {
          thumbnailFile = file;
        });
      }
    }
  }



  // Dispose

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(
                      builder: (context) => StoryPage(story: widget.story, stories:widget.stories,),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.2,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.28,
                  child: thumbnailFile!=null?ClipRRect(borderRadius: BorderRadius.circular(10),child: Image.file(thumbnailFile!)):ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:CachedNetworkImage(
                      imageUrl: widget.story.story.last['url1'],
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
                    ),
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(widget.story.user.name)
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0,  left: 5),
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.248,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAvatar(radius: 20, imageurl: widget.story.user.url),
                  Container(
                    width:13 ,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(child: Text('${widget.story.story.length}',style: const TextStyle(color: Colors.white,fontSize: 10),)),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}