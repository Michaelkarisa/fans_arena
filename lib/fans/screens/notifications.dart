import 'package:fans_arena/clubs/screens/createeventpage1.dart';
import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/fans/screens/leagueviewer.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:fans_arena/joint/filming/screens/filminglayout1.dart';
import 'package:fans_arena/joint/filming/screens/filminglayout3.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/createeventpage2.dart';
import '../../joint/components/recently.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';
import '../../joint/data/screens/feed_item.dart';
import '../../joint/screens/camera.dart';
import '../components/bottomnavigationbar.dart';
import 'accountfanviewer.dart';
import 'homescreen.dart';
import 'newsfeed.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

class NotificationModel {
  final Person from;
  final Person to;
  final String time;
  final String Date;
  final String message;
  final String content;
  final Timestamp timestamp;
  NotificationModel({
    required this.from,
    required this.message,
    required this.time,
    required this.content,
    required this.to,
    required this.Date,
    required this.timestamp,
  });
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? createdAtJson = json['createdAt']??{
      "_seconds": 0,
      "_nanoseconds": 0
    };
    DateTime createdDateTime = DateTime.fromMillisecondsSinceEpoch(
        createdAtJson!['_seconds'] * 1000 + createdAtJson['_nanoseconds'] ~/ 1000000);

    DateTime now = DateTime.now();
    Duration difference = now.difference(createdDateTime);

    String formattedTime = '';
    String hours = DateFormat('HH').format(createdDateTime);
    String minutes = DateFormat('mm').format(createdDateTime);
    String t = DateFormat('a').format(createdDateTime);
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
    Timestamp timestamp = Timestamp.fromDate(createdDateTime);
    return NotificationModel(
        from: Person(name:json['from']['username']??'',
          url: json['from']['profileImage']??'',
          collectionName: json['from']['collectionName']??'',
          userId: json['from']['userId']??'',),
      to:Person(name:json['username']??'',
      url: json['to']['profileImage']??'',
      collectionName:json['to']['collectionName']??'',
      userId: json['to']['userId']??'',),
      message:json['message'],
      time:'at $hours:$minutes $t',
      content:json['content'],
      Date: formattedTime,
      timestamp: timestamp,);

  }
}

class NotificationsScreen extends StatefulWidget {
  final List<NotificationModel> allnotifications;
  final bool hroute;
  const NotificationsScreen({super.key, required this.allnotifications, required this.hroute});
  static const String route = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> with AutomaticKeepAliveClientMixin {
  List<NotificationModel> notifications = [];
  List<NotificationModel> notifications1 = [];
  List<NotificationModel> allnotifications = [];
  late DateTime _startTime;
  bool nomoreposts = false;
  bool isloading = false;
  int itemcount = 0;
  final ScrollController controller = ScrollController();
  final DataFetcher news = DataFetcher();

  @override
  void initState() {
    super.initState();
    widget.allnotifications.sort((a, b){
    Timestamp latestTimestampA = a.timestamp;
    Timestamp latestTimestampB = b.timestamp;
    return latestTimestampB.compareTo(latestTimestampA);
    });
    _startTime = DateTime.now();
    if (widget.hroute) {
      getNotifications();
    } else if(!widget.hroute||widget.allnotifications.isEmpty){
      getNot();
    }
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        getNot1();
      }
    });
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> getNotifications() async {
    await resetNotifications();
    setState(() {
      isloading = true;
      allnotifications.addAll(widget.allnotifications);
    });
    await Future.delayed(const Duration(milliseconds: 10));
    await  processNotifications();
    setState(() {
      if (allnotifications.isNotEmpty) {
        isloading = false;
      } else {
        isloading = false;
        nomoreposts = true;
      }
    });
  }

  Future<void> getNot() async {
    try {
      await resetNotifications();
      setState(() {
        isloading = true;
      });
      allnotifications = await news.getNotifications();
      allnotifications.sort((a, b){
        Timestamp latestTimestampA = a.timestamp;
        Timestamp latestTimestampB = b.timestamp;
        return latestTimestampB.compareTo(latestTimestampA);
      });
      await processNotifications();
      setState(() {
        if (allnotifications.isNotEmpty) {
          isloading = false;
        } else {
          isloading = false;
          nomoreposts = true;
        }
      });
    }catch(e){
    }
  }

  Future<void> getNot1() async {
    setState(() {
      isloading = true;
      itemcount = 0;
    });
    await processNotifications();
    setState(() {
      if (allnotifications.isEmpty) {
        isloading = false;
        nomoreposts = true;
      } else {
        isloading = false;
      }
    });
  }

  Future<void> resetNotifications() async {
    setState(() {
      itemcount = 0;
      notifications.clear();
      notifications1.clear();
      allnotifications.clear();
    });
  }

  Future<void> processNotifications() async{
    for (final t in List<NotificationModel>.from(allnotifications)) {
      DateTime date = t.timestamp.toDate();
      final now = DateTime.now();
      int hours = now.difference(date).inHours;

      setState(() {
        if(hours>24){
          notifications1.add(t);
        } else {
          notifications.add(t);
        }
        allnotifications.remove(t);
        itemcount += 1;
      });
      if (itemcount >= 16||allnotifications.isEmpty) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 33),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Appbare,
          title: Text('Notifications (${allnotifications.length})', style: TextStyle(color: Textn)),
        ),
        body: RefreshIndicator(
          onRefresh: getNot,
          child: Stack(
            children: [
              ListView.builder(
                controller: controller,
                itemCount: 3,
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return buildSection('Today', notifications);
                    case 1:
                      return buildSection('Earlier', notifications1);
                    case 2:
                      return buildNoMorePostsIndicator();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
              if (isloading)
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 70),
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSection(String title, List<NotificationModel> notifications) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
              const SizedBox(width: 5,),
              Text("(${notifications.length})")
            ],
          ),
        ),
        ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: notifications.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final item = notifications[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              child: NotificationLayoutHandler(
                  from: item.from,
                  to: item.to,
                  message: item.message,
                  content: item.content,
                  time: item.time,
                  date: item.Date),
            );
          },
        ),
      ],
    );
  }

  Widget buildNoMorePostsIndicator() {
    if (nomoreposts) {
      return const SizedBox(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text('No more notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
class NotificationLayoutHandler extends StatefulWidget {
  final Person from;
  final Person to;
  final String message;
  final String content;
  final String time;
  final String date;

  const NotificationLayoutHandler({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,
  });

  @override
  State<NotificationLayoutHandler> createState() => _NotificationLayoutHandlerState();
}

class _NotificationLayoutHandlerState extends State<NotificationLayoutHandler> {
  final Map<String, Widget Function(Person, Person, String, String, String, String)> messageHandlers = {
    "liked your post": (from, to, message, content, time, date) => Message(from: from, to: to, message: message, content: content, time: time, date: date),
    "shared a story": (from, to, message, content, time, date) => Message0(from: from, to: to, message: message, content: content, time: time, date: date),
    "added a new post": (from, to, message, content, time, date) => Message1(from: from, to: to, message: message, content: content, time: time, date: date),
    "added a new video": (from, to, message, content, time, date) => Message11(from: from, to: to, message: message, content: content, time: time, date: date),
    "shared their line_up": (from, to, message, content, time, date) => Message3(from: from, to: to, message: message, content: content, time: time, date: date),
    "invited you to assist in filming their match": (from, to, message, content, time, date) => Message4(from: from, to: to, message: message, content: content, time: time, date: date),
    "messaged you": (from, to, message, content, time, date) => Message5(from: from, to: to, message: message, content: content, time: time, date: date),
    "started following you": (from, to, message, content, time, date) => Message6(from: from, to: to, message: message, content: content, time: time, date: date),
    "league has created a match for you": (from, to, message, content, time, date) => Message7(from: from, to: to, message: message, content: content, time: time, date: date),
    "commented on your post": (from, to, message, content, time, date) => Message8(from: from, to: to, message: message, content: content, time: time, date: date),
    "added you as a Club's team": (from, to, message, content, time, date) => Message9(from: from, to: to, message: message, content: content, time: time, date: date),
    "added you to the league team": (from, to, message, content, time, date) => Message10(from: from, to: to, message: message, content: content, time: time, date: date),
    "liked your FansTv video": (from, to, message, content, time, date) => Message11(from: from, to: to, message: message, content: content, time: time, date: date),
    "added a new match": (from, to, message, content, time, date) => Message12(from: from, to: to, message: message, content: content, time: time, date: date),
    "added you to their new match": (from, to, message, content, time, date) => Message13(from: from, to: to, message: message, content: content, time: time, date: date),
    "replied to your comment on this post": (from, to, message, content, time, date) => Message14(from: from, to: to, message: message, content: content, time: time, date: date),
    "invited you to assist in filming their event": (from, to, message, content, time, date) => Message15(from: from, to: to, message: message, content: content, time: time, date: date),
    "accepted your invitation to join your team": (from, to, message, content, time, date) => Message16(from: from, to: to, message: message, content: content, time: time, date: date),
    "match has started": (from, to, message, content, time, date) => Message(from: from, to: to, message: message, content: content, time: time, date: date),
    "event has started": (from, to, message, content, time, date) => Message(from: from, to: to, message: message, content: content, time: time, date: date),
    "created a match for you": (from, to, message, content, time, date) => Message7(from: from, to: to, message: message, content: content, time: time, date: date),
    "league has created a match": (from, to, message, content, time, date) => Message18(from: from, to: to, message: message, content: content, time: time, date: date),
    "you have a new fan": (from, to, message, content, time, date) => Message17(from: from, to: to, message: message, content: content, time: time, date: date),
    "subscribed to the league": (from, to, message, content, time, date) => Message19(from: from, to: to, message: message, content: content, time: time, date: date),
    "welcome back to Fans Arena": (from, to, message, content, time, date) => Message20(from: from, to: to, message: message, content: content, time: time, date: date),
    "is now your fan": (from, to, message, content, time, date) => Message17(from: from, to: to, message: message, content: content, time: time, date: date),
    "is now following you": (from, to, message, content, time, date) => Message6(from: from, to: to, message: message, content: content, time: time, date: date),
    "added a new event": (from, to, message, content, time, date) => Message12(from: from, to: to, message: message, content: content, time: time, date: date),
  };
  @override
  Widget build(BuildContext context) {
    final messageHandler = messageHandlers[widget.message];
    if (messageHandler != null) {
      return messageHandler(widget.from, widget.to, widget.message, widget.content, widget.time, widget.date);
    } else {
      return const Center(child: Text('No New notifications'));
    }
  }
}



class Message extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {

  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Row(
                  children: [
                    CustomAvatar(radius: radius,imageurl: widget.from.url,),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap:(){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context){
                                          if(widget.from.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.from, index: 0);
                                          }else if(widget.from.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.from, index: 0);
                                          }else{
                                            return Accountfanviewer(user: widget.from, index: 0);
                                          }
                                        }
                                    ),
                                  );
                                },
                                child: CustomName(maxsize: 160,username:widget.from.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: fsize,
                                    fontWeight: FontWeight.bold,),)),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 10.0,
                                maxWidth: MediaQuery.of(context).size.width*0.8,
                              ),
                              child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Post1(postId: widget.content,)));
            },
            child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child:  Post(postId: widget.content,)
            ),
          )
        ],
      ),

    );
  }
}
class Post extends StatefulWidget {
  String postId;
  Post({super.key, required this.postId});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  List<Map<String, dynamic>> url =[];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    retrieveUsername();
  }
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          url = List<Map<String, dynamic>>.from(data['captionUrl']??[]);
        });
      } else {
        setState(() {
          url=[];
        });
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: 70,
      height: 70,
      child: url.isEmpty?const Center(child: Icon(Icons.error,color: Colors.white,size: 30,)):CachedNetworkImage(
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 30,)),
        fit: BoxFit.cover,
        width:70,
        height: 70,
        imageUrl: url.isEmpty?"": url[0]['url'],
      ),
    );
  }
}
class Post1 extends StatefulWidget {
  String postId;
  Post1({super.key, required this.postId});

  @override
  State<Post1> createState() => _Post1State();
}

class _Post1State extends State<Post1> {
  late Posts post;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    getPost();
  }
  void getPost()async{
    post=await retrieveUsername();
    setState(() {
      isloading=false;
    });
  }
  bool isloading=true;
  Future<Posts> retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('posts')
          .doc(widget.postId)
          .get();

      if (documentSnapshot.exists) {
        var doc = documentSnapshot.data() as Map<String, dynamic>;
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
        Person p =await Newsfeedservice().getPerson(userId: doc['authorId']);
        return Posts(
          postid: documentSnapshot.id,
          location: doc['location'] ?? '',
          time: formattedTime,
          genre: doc['genre'] ?? '',
          captionUrl: captionUrl,
          timestamp: doc['createdAt'],
          time1: 'at $hours:$minutes $t',
          user:p,
        );

      } else {
        return Posts(
          postid: '',
          location: '',
          time: '',
          genre:  '',
          captionUrl: [],
          timestamp:Timestamp.now(),
          time1: '',
          user:Person(
              name: '',
              userId:'',
              url: '',
              collectionName:''
          ),
        );

      }
    } catch (e) {
      return Posts(
        postid: '',
        location: '',
        time: '',
        genre:  '',
        captionUrl: [],
        timestamp:Timestamp.now(),
        time1: '',
        user:Person(
            name: '',
            userId:'',
            url: '',
            collectionName:''
        ),
      );
    }
  }
  final double radius=23;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('View Post',style: TextStyle(color: Colors.black),),
      ),
      body: isloading?const Center(child: CircularProgressIndicator()):PostLayout(post: post,),
    );
  }
}


class Message0 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message0({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message0> createState() => _Message0State();
}

class _Message0State extends State<Message0> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: radius, imageurl: widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name,style: TextStyle(fontSize: fsize), maxsize: 160 ,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}


class Message1 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message1({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message1> createState() => _Message1State();
}

class _Message1State extends State<Message1> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: radius, imageurl: widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name, style: TextStyle(fontSize: fsize) ,maxsize: 160,),
                  const SizedBox(width: 8,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}


class Message2 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message2({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message2> createState() => _Message2State();
}

class _Message2State extends State<Message2> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: radius, imageurl: widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize) ,maxsize: 160,),
                  const SizedBox(width: 7,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}


class Message3 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message3({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message3> createState() => _Message3State();
}

class _Message3State extends State<Message3> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: radius, imageurl:widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name, style: TextStyle(fontSize: fsize) ,maxsize: 160,),
                  const SizedBox(width: 7,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}


class Message4 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message4({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message4> createState() => _Message4State();
}

class _Message4State extends State<Message4> {
  double radius=21.0;
  double fsize=16.0;
  String accepted='1';
  String accepted1='';
  @override
  void initState(){
    super.initState();
    updateStreamer(true,'');
  }
  Future<void> updateStreamer(bool fetch,String d) async {
    if(fetch){
      setState(() {
        isloading=false;
      });
    }else{
      setState(() {
        isloading=true;
      });
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.content)
          .collection('streamers')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        if(fetch){
            setState(() {
              accepted1=oldData['accepted'];
            });}else{
        Map<String, dynamic> newData = {};
        Timestamp createdAt = Timestamp.now();
        if (d.isNotEmpty && d != oldData['accepted']) {
          newData['accepted'] = d;
        }
        if ( createdAt != oldData['timestamp']) {
          newData['timestamp'] = createdAt;
        }
        if (newData.isNotEmpty&!fetch) {
          await documentSnapshot.reference.update(newData);
          setState(() {
            accepted1=d;
          });
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }}
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  late MatchM match;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isloading=false;
  Future<void> retrieveUsername() async {
    try{
      match=await DataFetcher().getMatch(widget.content);
      setState(() {
        isloading=false;
      });
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => FilmingLayout1(match: match)));
    } catch (e) {
      dialog2();
    }
  }
  void dialog2(){
    showDialog(
        context: context,
        builder: (context)=>const AlertDialog(
          content: Text('error in fetching match'),));
  }
  void dialog(){
    showDialog(
        context: context,
        builder: (context)=>const AlertDialog(
          content: Text('match is null'),));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl:widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomName(username:widget.from.name, style:TextStyle(fontSize: fsize) ,maxsize: 160,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

        accepted1.isEmpty?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isloading? CircularProgressIndicator():TextButton(onPressed: ()async{await updateStreamer(false,'0');}, child: const Text('Decline',style: TextStyle(fontSize: 14,),)),
              const SizedBox(width: 200,),
             isloading? CircularProgressIndicator():TextButton(onPressed: ()async{
                await updateStreamer(false,'1');
                 await retrieveUsername();
              }, child: const Text('Accept',style: TextStyle(fontSize: 14),)),
            ],
          ):Center(child: Text(accepted1=="1"?"You Accepted":"You Declined",style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
      ),

    );
  }
}

class Message5 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message5({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message5> createState() => _Message5State();
}

class _Message5State extends State<Message5> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: radius, imageurl:widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name, style:TextStyle(fontSize: fsize) ,maxsize: 160,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}

class Message6 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message6({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message6> createState() => _Message6State();
}

class _Message6State extends State<Message6> {
  double radius=20;
  double fsize=16;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Row(
                  children: [
                    CustomAvatar(radius: radius, imageurl: widget.from.url),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap:(){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context){
                                          if(widget.from.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.from, index: 0);
                                          }else if(widget.from.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.from, index: 0);
                                          }else{
                                            return Accountfanviewer(user: widget.from, index: 0);
                                          }
                                        }
                                    ),
                                  );
                                },
                                child: CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize),maxsize: 160,)),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: 10.0,
                                    maxWidth: MediaQuery.of(context).size.width*0.75,
                                  ),
                                  child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,),
                                ),
                              ),
                              const SizedBox(width: 30,),
                              Accountchecker11(user: widget.from),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
        ],
      ),

    );
  }
}

class Message7 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message7({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message7> createState() => _Message7State();
}

class _Message7State extends State<Message7> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width*0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl:widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap:(){
                              Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context){
                                      if(widget.from.collectionName=='Club'){
                                        return AccountclubViewer(user: widget.from, index: 0);
                                      }else if(widget.from.collectionName=='Professional'){
                                        return AccountprofilePviewer(user: widget.from, index: 0);
                                      }else{
                                        return Accountfanviewer(user: widget.from, index: 0);
                                      }
                                    }
                                ),
                              );
                            },
                            child: CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize),maxsize: 160,)),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width*0.8,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){Navigator .push(context, MaterialPageRoute(builder: (context)=>CreateEventPage1(leaguematchId: widget.content, leagueId: widget.from.userId, )));}, child: const Text('Create Event')),
            ],),
          const SizedBox(height: 5,)
        ],
      ),
    );
  }
}



class Message8 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message8({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message8> createState() => _Message8State();
}

class _Message8State extends State<Message8> {
  double radius=20;
  double fsize=16;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Row(
                  children: [
                    CustomAvatar(radius: radius, imageurl: widget.from.url),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap:(){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context){
                                          if(widget.from.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.from, index: 0);
                                          }else if(widget.from.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.from, index: 0);
                                          }else{
                                            return Accountfanviewer(user: widget.from, index: 0);
                                          }
                                        }
                                    ),
                                  );
                                },
                                child: CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize),maxsize: 160,)),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 10.0,
                                maxWidth: MediaQuery.of(context).size.width*0.8,
                              ),
                              child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Post1(postId: widget.content,)));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Post(postId: widget.content,),
            ),
          )
        ],
      ),

    );
  }
}



class Message9 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message9({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message9> createState() => _Message9State();
}

class _Message9State extends State<Message9> {
  double radius=21.0;
  double fsize=16.0;
  String status='';

  void addclub(){
    final matchesCollection = FirebaseFirestore.instance.collection('Professionals').doc(widget.to.userId).collection('club');
    try {
      Timestamp createdAt = Timestamp.now();
      matchesCollection
          .doc(widget.from.userId)
          .set({
        'clubId':widget.from,
        'createdAt':createdAt
        // Add more fields as needed
      }).then((_) {
        setState(() {
          isloading=false;
        });
      }).catchError((error) {

      });
    }catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  @override
  void initState(){
    super.initState();
    updateMember(true,'');
  }
  bool isloading=false;
  Future<void> updateMember(bool fetch,String accept) async {
     if(fetch){
       setState(() {
         isloading=false;
       });
     }else{
       setState(() {
         isloading=true;
       });
     }
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Clubs')
          .doc(widget.from.userId)
          .collection('clubsteam');
      QuerySnapshot querySnapshot = await collection.get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubsteam'];
        final List<Map<String,dynamic>> tableColumns = List<Map<String,dynamic>>.from(documentSnapshot['clubsTeamTable']);
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i][tableColumns[1]['fn']] == FirebaseAuth.instance.currentUser!.uid) {
            indexToUpdate = i;
            status=clubsteam[i]['status'];
            break;
          }
        }
        if (indexToUpdate != -1&&!fetch) {
          clubsteam[indexToUpdate]['status'] = accept;
          await documentSnapshot.reference.update({'clubsteam': clubsteam});
          setState(() {
            status=accept;
          });
          addclub();
          await Sendnotification(from: widget.to.userId, to: widget.from.userId, message: message16, content: '').sendnotification();
          print('Role updated successfully');
          break; // Exit the loop once the update is done
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  String message16='accepted your invitation to join your team';
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl: widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomName(username:widget.from.name, style: TextStyle(fontSize: fsize),maxsize: 160,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          status.isEmpty?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isloading? CircularProgressIndicator():TextButton(onPressed: ()async{
                await updateMember(false,"0");
              }, child: const Text('Decline',style: TextStyle(fontSize: 14,),)),
              const SizedBox(width: 200,),
             isloading? CircularProgressIndicator():TextButton(onPressed: (){
                updateMember(false,"1").then((value) => Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context){
                        if(widget.from.collectionName=='Club'){
                          return AccountclubViewer(user: widget.from, index: 0);
                        }else if(widget.from.collectionName=='Professional'){
                          return AccountprofilePviewer(user: widget.from, index: 0);
                        }else{
                          return Accountfanviewer(user: widget.from, index: 0);
                        }
                      }
                  ),
                ));

              }, child: const Text('Accept',style: TextStyle(fontSize: 14),)),
            ],
          ):Center(child: Text(status=="1"?"You Accepted":"You Declined",style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
      ),

    );
  }
}



class Message10 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message10({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message10> createState() => _Message10State();
}

class _Message10State extends State<Message10> {
  double radius=21.0;
  double fsize=16.0;
  String accepted='1';
  String decline='0';
  @override
  void initState() {
    super.initState();
    getFnData();
    updateMember(true,'');
  }
  bool isloading=false;
  void getFnData()async{
    DocumentSnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.from.userId)
        .collection('year')
        .doc(year).get();
    var document= snapshot.data() as Map<String,dynamic>;
    List<Map<String, dynamic>> allLikes = [];
    final List<dynamic> likesArray = document['leagueTable'];
    allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    setState(() {
      tableColumns=allLikes;
    });
  }

  List<Map<String, dynamic>> tableColumns = [
    {'fn':'Rank'},
    {'fn':'Club'},
  ];
  String status="";
  Future<void> updateMember(bool fetch,String accept) async {
    if(fetch){
      setState(() {
        isloading=false;
      });
    }else{
      setState(() {
        isloading=true;
      });
    }
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.from.userId)
          .collection('year')
          .doc(year)
          .collection('clubs');
      QuerySnapshot querySnapshot = await collection.get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['clubs'];
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i][tableColumns[1]['fn']] == FirebaseAuth.instance.currentUser!.uid) {
            indexToUpdate = i;
            status=clubsteam[i]['status'];
            break;
          }
        }
        if (indexToUpdate != -1&&!fetch) {
          clubsteam[indexToUpdate]['status'] = accept;
          await documentSnapshot.reference.update({'clubs': clubsteam});
          setState(() {
            status=accept;
          });
          print('Role updated successfully');
          break;
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  String year='';

  late LeagueC league;
  Future<void> retrieveUsername3() async {
    try {
      league = await DataFetcher().getLeague(widget.from.userId);
      setState(() {
        year = league.leagues.first;
        isloading=false;
      });
    Navigator.push(context, MaterialPageRoute(builder: (context)=>LeagueLayout(league:league,year: year ,)));
    }catch(e){

    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(imageurl:widget.from.url, radius: radius,),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomName(username:widget.from.name,
                          style: TextStyle(fontSize: fsize,color: Colors.black), maxsize: 160,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
           status.isNotEmpty?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isloading? CircularProgressIndicator():TextButton(onPressed: ()async{
                await updateMember(false,'0');
              }, child: const Text('Decline',style: TextStyle(fontSize: 14,),)),
              const SizedBox(width: 200,),
              isloading?CircularProgressIndicator():TextButton(onPressed: ()async{
                await updateMember(false,"1");
                await retrieveUsername3();
              }, child: const Text('Accept',style: TextStyle(fontSize: 14),)),
            ],
          ):Center(child: Text(status=="1"?"You Accepted":"You Declined",style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
      ),

    );
  }
}

class Message11 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message11({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message11> createState() => _Message11State();
}

class _Message11State extends State<Message11> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomAvatar(radius: radius, imageurl: widget.from.url),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap:(){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context){
                                          if(widget.from.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.from, index: 0);
                                          }else if(widget.from.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.from, index: 0);
                                          }else{
                                            return Accountfanviewer(user: widget.from, index: 0);
                                          }
                                        }
                                    ),
                                  );
                                },
                                child: CustomName(username:widget.from.name, style: TextStyle(fontSize: fsize),maxsize: 160,)),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 10.0,
                                maxWidth: MediaQuery.of(context).size.width*0.8,
                              ),
                              child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewTv(postId: widget.content,)));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                  height: 70,
                  width: 70,
                  child: Post5(postId: widget.content,)),
            ),
          )
        ],
      ),
    );
  }
}

class ViewTv extends StatefulWidget {
  String postId;
  ViewTv({super.key,required this.postId});

  @override
  State<ViewTv> createState() => _ViewTvState();
}

class _ViewTvState extends State<ViewTv> {
  Newsfeedservice news = Newsfeedservice();
  TextEditingController t=TextEditingController();
  void getIndex()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('index', 2);

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
            children: [
              FutureBuilder<FansTv>(
        future: news.getFansTv0(postId: widget.postId),
        builder: (context, snapshot) {
    if(snapshot.connectionState==ConnectionState.waiting){
    return const Center(child: CircularProgressIndicator(color: Colors.white,),);
    }else{
          final post = snapshot.data!;
          return  Container(
              color: Colors.transparent,
              height: MediaQuery.of(context).size.height,
              child: FeedItem(ftv: post,opt1: true,completed: () {
              },index:0 ,posts: [post],));
        }},
      ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:  [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,color: Colors.white,size: 35,),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },//to next page},
                    ),
                    const Text(
                      'Fans_Tv',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,color: Colors.white
                      ),
                    ),
                    InkWell(
                        onTap: (){
                          Bottomnavbar.setCamera(context);
                          Camera.setCamera(context);
                          getIndex();
                          Navigator.of(context).pop();
                        },
                        child: const Icon(Icons.camera_alt,size: 30,color: Colors.white,)),
                  ],
                ),
              ),
            ]))
    );
  }
}


class Post5 extends StatefulWidget {
  final String postId;
  Post5({super.key, required this.postId});

  @override
  State<Post5> createState() => _Post5State();
}

class _Post5State extends State<Post5> {
  late VideoPlayerController _controller;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final BaseCacheManager cacheManager = DefaultCacheManager();

  String thumbnailUrl = '';
  File? thumbnailFile;

  @override
  void initState() {
    super.initState();
    initializeImage();
  }

  Future<String> retrieveUrl() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('FansTv')
          .doc(widget.postId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return data['url'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxWidth: 70,
        maxHeight: 70,
        quality: 25,
        timeMs: 1500,
      );
      return thumbnailData;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  void initializeImage() async {
    String videoUrl = await retrieveUrl();
    if (videoUrl.isEmpty) return;

    final cacheKey = '${widget.postId}_thumbnail';
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: 70,
      height: 70,
      child: thumbnailFile == null
          ? const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      )
          : Image.file(thumbnailFile!),
    );
  }
}




class Message12 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message12({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message12> createState() => _Message12State();
}

class _Message12State extends State<Message12> {
  double radius=21.0;
  double fsize=15.0;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: radius, imageurl:widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize) ,maxsize: 160,),
                  const SizedBox(width: 7,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}


class Message13 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message13({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message13> createState() => _Message13State();
}

class _Message13State extends State<Message13> {
  double radius=21.0;
  double fsize=15.0;
  late MatchM match;
  bool isloading=false;
  void retrieveUsername() async {
    setState(() {
      isloading=true;
    });
    try{
      match=await DataFetcher().getMatch(widget.content);
      setState(() {
        isloading=false;
      });
    } catch (e) {
      dialoge('Error retrieving username: $e');
      setState(() {
        isloading=false;
      });
    }
  }
  void dialoge(String e){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text(e),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl:widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                            onTap:(){
                              Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context){
                                      if(widget.from.collectionName=='Club'){
                                        return AccountclubViewer(user: widget.from, index: 0);
                                      }else if(widget.from.collectionName=='Professional'){
                                        return AccountprofilePviewer(user: widget.from, index: 0);
                                      }else{
                                        return Accountfanviewer(user: widget.from, index: 0);
                                      }
                                    }
                                ),
                              );
                            },
                            child: CustomName(username:widget.from.name, style: TextStyle(fontSize: fsize),maxsize: 160,)),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          Row( mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: (){Navigator .push(context, MaterialPageRoute(builder: (context)=>CreateEventPage2(matchId:widget.content, )));}, child: const Text('View Match')),
              TextButton(onPressed: (){}, child: const Text('Ignore')),
            ],),
          const SizedBox(height: 30,)
        ],
      ),

    );
  }
}
class ViewMatch extends StatefulWidget {
  String matchId;
  String club1Id;
  String club2Id;
  ViewMatch({super.key,required this.matchId,required this.club1Id,required this.club2Id});

  @override
  State<ViewMatch> createState() => _ViewMatchState();
}

class _ViewMatchState extends State<ViewMatch> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    if(widget.matchId.isEmpty){
      dialoge("MatchId is empty");
    }
    retrieveUsername();
    setState(() {
      match=MatchM(
        startime: Timestamp.now(),
        stoptime: Timestamp.now(),
        duration: 0,
        matchId: '',
        timestamp:Timestamp.now(),
        score1: 0,
        score2: 0,
        location: '',
        status: '',
        starttime: '',
        createdat: '',
        tittle: '',
        leaguematchId: '',
        match1Id: '',
        status1: '',
        authorId:'',
        club1: Person(name:'',
          url: '',
          collectionName: '',
          userId: '',),
        club2: Person(name:'',
          url: '',
          collectionName: '',
          userId: '',),
        league: Person(name:'',
          url: '',
          collectionName: '',
          userId: '',),);
    });
  }
  late MatchM match;
  double radius=23;
  double radius1=16;
  bool isloading=true;
  void retrieveUsername() async {
    try{
      match=await DataFetcher().getMatch(widget.matchId);
    } catch (e) {
      dialoge('Error retrieving username: $e');
    }
  }
  void dialoge(String e){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text(e),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Match',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 370,
            height: 140,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.only(left: 5,right: 5,top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text('Match'),
                    SizedBox(
                      height: 45,
                      width: 360,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomAvatar(radius: 18, imageurl:match.club1.url),
                         CustomName(username:match.club1.name, maxsize: 120, style: const TextStyle(color: Colors.black)),
                          Padding(
                            padding: const EdgeInsets.only(left: 2,right: 3),
                            child: Container(
                              width: 25,
                              height: 30,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius
                                      .circular(5),
                                  border: Border.all(
                                      width: 1,
                                      color: Colors.black
                                  )
                              ),
                              child: const Center(child: Text('VS')),
                            ),
                          ),
                          CustomAvatar(radius: 18, imageurl:match.club2.url),
                          CustomName(username:match.club2.name, maxsize: 120, style: const TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children:[
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUpA(match: match)));
                          }, child: const Text('Lineup')),
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUpB(match:match)));
                          }, child: const Text('Lineup'))
                        ]
                    )
                  ],
                ),
              ),
            ),
          ),
          match.league.userId.isNotEmpty? SizedBox(
            width: 370,
            height: 100,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('League'),
                    SizedBox(
                      height: 50,
                      width: 250,
                      child: Row(
                        children: [
                          CustomAvatar(radius: 18, imageurl:match.league.url),
                         CustomName(username: match.league.name, maxsize: 150, style:const TextStyle(color: Colors.black))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ):const Text(''),
          SizedBox(
            width: 250,
            height: 200,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Other neccesary information'),
                  SizedBox(
                      width: 250,
                      height: 30,
                      child: Text('Location: ${match.location}')),
                  SizedBox(
                      width: 250,
                      height: 30,
                      child: Text('Date: ${match.createdat}' )),
                  SizedBox(
                      width: 250,
                      height: 30,
                      child: Text('Time: ${match.starttime}')
                  ),

                ],
              ),
            ),
          ),
          TextButton(onPressed: (){Navigator .push(context, MaterialPageRoute(builder: (context)=>CreateEventPage2(matchId:widget.matchId,)));}, child: const Text('Create Event')),
        ],
      ),
    );
  }
}


class Message14 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message14({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message14> createState() => _Message14State();
}

class _Message14State extends State<Message14> {
  double radius=20;
  double fsize=16;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Row(
                  children: [
                    CustomAvatar(radius: radius, imageurl:widget.from.url),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap:(){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context){
                                          if(widget.from.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.from, index: 0);
                                          }else if(widget.from.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.from, index: 0);
                                          }else{
                                            return Accountfanviewer(user: widget.from, index: 0);
                                          }
                                        }
                                    ),
                                  );
                                },
                                child: CustomName(username:widget.from.name, style: TextStyle(fontSize: fsize),maxsize: 160,)),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                              constraints: BoxConstraints(
                                minWidth: 10.0,
                                maxWidth: MediaQuery.of(context).size.width*0.8,
                              ),
                              child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,),
                            ),
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Post1(postId: widget.content,)));
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Post(postId: widget.content,),
            ),
          )
        ],
      ),

    );
  }
}
class Message15 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message15({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message15> createState() => _Message15State();
}

class _Message15State extends State<Message15> {
  double radius=21.0;
  double fsize=16.0;
  String accepted='1';
  String accepted1='';
  @override
  void initState(){
    super.initState();
    updateStreamer(true,'');
  }
  Future<void> updateStreamer(bool fetch,String d) async {
    if(fetch){
      setState(() {
        isloading=false;
      });
    }else{
      setState(() {
        isloading=true;
      });
    }
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.content)
          .collection('streamers')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        if(fetch){
          setState(() {
            accepted1=oldData['accepted'];
          });}else{
          Map<String, dynamic> newData = {};
          Timestamp createdAt = Timestamp.now();
          if (d.isNotEmpty && d != oldData['accepted']) {
            newData['accepted'] = d;
          }
          if ( createdAt != oldData['timestamp']) {
            newData['timestamp'] = createdAt;
          }
          if (newData.isNotEmpty&!fetch) {
            await documentSnapshot.reference.update(newData);
            setState(() {
              accepted1=d;
            });
            print('Data saved successfully');
          } else {
            print('No changes to update');
          }}
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  late EventM event;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isloading=false;
  Future<void> retrieveUsername() async {
    try{
      event=await DataFetcher().getEvent(widget.content);
      setState(() {
        isloading=false;
      });
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => FilmingLayout3(event: event)));
    } catch (e) {
      dialog2();
      setState(() {
        isloading=false;
      });
    }
  }
  void dialog2(){
    showDialog(
        context: context,
        builder: (context)=>const AlertDialog(
          content: Text('error in fetching event'),));
  }
  void dialog(){
    showDialog(
        context: context,
        builder: (context)=>const AlertDialog(
          content: Text('event is null'),));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl:widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomName(username:widget.from.name, style:TextStyle(fontSize: fsize) ,maxsize: 160,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          accepted1.isEmpty?Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isloading? CircularProgressIndicator():TextButton(onPressed: ()async{await updateStreamer(false,'0');}, child: const Text('Decline',style: TextStyle(fontSize: 14,),)),
              const SizedBox(width: 200,),
              isloading? CircularProgressIndicator():TextButton(onPressed: ()async{
                await updateStreamer(false,'1');
                if(event==null){
                  dialog();
                }else {
                  await retrieveUsername();
                }
              }, child: const Text('Accept',style: TextStyle(fontSize: 14),)),
            ],
          ):Center(child: Text(accepted1=="1"?"You Accepted":"You Declined",style: TextStyle(fontWeight: FontWeight.bold),)),
        ],
      ),

    );
  }
}


class Message16 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message16({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message16> createState() => _Message16State();
}

class _Message16State extends State<Message16> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(radius: 18, imageurl:widget.from.url),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:widget.from.name,style: const TextStyle(fontSize: 14) ,maxsize: 160,),
                  const SizedBox(width: 7,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}
class Message17 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message17({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message17> createState() => _Message17State();
}

class _Message17State extends State<Message17> {
  double radius=20;
  double fsize=16;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width*0.8,
                child: Row(
                  children: [
                    CustomAvatar(radius: radius, imageurl: widget.from.url),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                                onTap:(){
                                  Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context){
                                          if(widget.from.collectionName=='Club'){
                                            return AccountclubViewer(user: widget.from, index: 0);
                                          }else if(widget.from.collectionName=='Professional'){
                                            return AccountprofilePviewer(user: widget.from, index: 0);
                                          }else{
                                            return Accountfanviewer(user: widget.from, index: 0);
                                          }
                                        }
                                    ),
                                  );
                                },
                                child: CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize),maxsize: 160,)),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Row(
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  constraints: BoxConstraints(
                                    minWidth: 10.0,
                                    maxWidth: MediaQuery.of(context).size.width*0.75,
                                  ),
                                  child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 30,)
            ],
          ),
        ],
      ),

    );
  }
}

class Message18 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message18({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message18> createState() => _Message18State();
}

class _Message18State extends State<Message18> {
  double radius=20;
  double fsize=16;
  bool isloading=true;
  late LeagueC league;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    setState(() {
      league=LeagueC(
        leagues: [],
        leagueId:'',
        genre: '',
        imageurl: '',
        author: Person(
            name: '',
            url: '',
            collectionName: '',
            userId:''
        ),
        leaguename: '',
        location:'',
        timestamp: Timestamp.now(), accountType: '',
      );
    });
    userData();
  }
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('LeagueP',_startTime,'');
    super.dispose();
  }
  void userData()async{
    league= await DataFetcher().getLeague(widget.content);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl:widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize),maxsize: 160,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LeagueLayout(league: league, year: league.leagues.first)));

              }, child: const Text('View match',style: TextStyle(fontSize: 14),)),
            ],
          )
        ],
      ),

    );
  }
}

class Message19 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message19({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message19> createState() => _Message19State();
}

class _Message19State extends State<Message19> {
  double radius=20;
  double fsize=16;
  bool isloading=true;
  late LeagueC league;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    setState(() {
      league=LeagueC(
        leagues: [],
        leagueId:'',
        genre: '',
        imageurl: '',
        author: Person(
            name: '',
            url: '',
            collectionName: '',
            userId:''
        ),
        leaguename: '',
        location:'',
        timestamp: Timestamp.now(),
        accountType: '',
      );
    });
    userData();
  }
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('LeagueP',_startTime,'');
    super.dispose();
  }
  void userData()async{
    league= await DataFetcher().getLeague(widget.content);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CustomAvatar(radius: radius, imageurl:widget.from.url),
                Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomName(username:widget.from.name,style:TextStyle(fontSize: fsize),maxsize: 160,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Text('${widget.date} ${widget.time}',style: const TextStyle(fontSize: 14,color: Colors.black),),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: MediaQuery.of(context).size.width,
                          ),
                          child: Text(widget.message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400,color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,),
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LeagueLayout(league: league, year: league.leagues.first)));

              }, child: const Text('View League',style: TextStyle(fontSize: 14),)),
            ],
          )
        ],
      ),

    );
  }
}

class Message20 extends StatefulWidget {
  Person from;
  Person to;
  String message;
  String content;
  String time;
  String date;
  Message20({
    super.key,
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    required this.time,
    required this.date,});

  @override
  State<Message20> createState() => _Message20State();
}

class _Message20State extends State<Message20> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: CircleAvatar(
              radius: 18,
              child:Image.asset("assets/images/applogo.jpg"),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomName(username:"Fans Arena",style: const TextStyle(fontSize: 14) ,maxsize: 160,),
                  const SizedBox(width: 7,),
                  Text(widget.message),
                ],
              ),
              Text('${widget.date} at ${widget.time}')
            ],
          )
        ],
      ),

    );
  }
}