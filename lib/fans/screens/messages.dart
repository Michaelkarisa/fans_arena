import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/screens/chatting.dart';
import 'package:fans_arena/joint/screens/choosefriends.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../appid.dart';
import '../../clubs/data/lineup.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../main.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:fans_arena/fans/screens/groupdetails.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../data/newsfeedmodel.dart';
import '../data/videocontroller.dart';
import 'accountfanviewer.dart';
import 'groupchatting.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path_provider/path_provider.dart';
import 'package:fans_arena/fans/bloc/accountchecker5.dart';
import 'package:fans_arena/fans/screens/highlights.dart';
import 'package:fans_arena/fans/screens/notifications.dart';
import 'package:fans_arena/fans/screens/results.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:fans_arena/reusablewidgets/firebaseanalytics.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:geolocator/geolocator.dart';
import '../../appid.dart';
import '../../joint/data/sportsapi/sportsapi.dart';
import 'package:uuid/uuid.dart';
import '../components/bottomnavigationbar.dart';
import 'package:fl_chart/fl_chart.dart';
class Messages extends StatefulWidget {
     List<String> userIdList;
     List<String> chatIdList;
   Messages({super.key,required this.chatIdList,required this.userIdList});

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();

  }

  Future<void> deletechat(String chatId)async{
    FirebaseFirestore.instance
        .collection('Chats')
        .where('chatId', isEqualTo:chatId )
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }
double radius=23;
  bool deletemode=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: widget.userIdList.length,
            itemBuilder: (BuildContext context, int index) {
              final user = widget.userIdList[index];
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color:deletemode?Colors.white10:Colors.white54,
                  ),
                  margin: const EdgeInsets.all(4.0),
                  child: InkWell(
                    onLongPress: (){
                      setState(() {
                        deletemode=true;
                      });
                      showDialog(context: context, builder: (context) {
                        deletemode=true;
                        return AlertDialog(
                          content:const Text('Do you want to delete this chat?') ,
                          actions: [
                            Row(
                              mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(onPressed: (){
                                  setState(() {
                                    deletemode=false;
                                  });
                                  Navigator.of(context,rootNavigator: true).pop();
                                }, child: const Text('Cancel')),
                                TextButton(onPressed: ()async{
                                  await deletechat(widget.chatIdList[index]);
                                 widget.chatIdList.clear();
                                  widget.userIdList.clear();
                                  setState(() {
                                    deletemode=false;
                                  });
                                  Navigator.of(context,rootNavigator: true).pop();
                                }, child: const Text('Delete')),
                              ],
                            )
                          ],
                        );
                      });
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chatting(
                            user:Person(name: '',
                            collectionName: '',
                            url: '',
                            userId: '',),userId:widget.userIdList[index],
                            chatId: widget.chatIdList[index],),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomAvatarM(userId: widget.userIdList[index],radius: radius,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.85,
                              child: Row(
                                mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CustomUserNameD(maxsize: 155,userId: widget.userIdList[index],
                                    style:const TextStyle(fontSize: 16,fontWeight: FontWeight.bold), height: 38, width: 185,),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: LatestTime(chatId: widget.chatIdList[index], collection: 'Chats',),
                                  ),
                                ],
                              ),
                            ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: LatestText(chatId: widget.chatIdList[index], collection: 'Chats',),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: const Alignment(0.85, 0.9),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: SizedBox(
                height: 50,
                width: 50,
                child: FloatingActionButton(
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Choosefriends()),
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class CustomUsernameD0Avatar extends StatefulWidget {
  String userId;
  double radius;
  TextStyle style;
  double maxsize;
  double height;
  double width;
  Person? user;
  bool click;
  CustomUsernameD0Avatar({super.key,
    required this.userId,
    required this.style,
    required this.radius,
    required this.maxsize,
    required this.height,
    this.user,
    this.click=false,
    required this.width,
  });

  @override
  State<CustomUsernameD0Avatar> createState() => _CustomUsernameD0AvatarState();
}

class _CustomUsernameD0AvatarState extends State<CustomUsernameD0Avatar> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    getData();
  }
  @override
  void didUpdateWidget(covariant CustomUsernameD0Avatar oldWidget) {
    if (oldWidget.userId != widget.userId) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }
  String url='';
  String name="loading....";
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        name =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: name,
              userId: widget.userId,
              location: location,
              collectionName: collectionName,
              url: url,
            )
        ));
      }
    }else{
      await getUserData();
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: widget.userId,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
    }
  }
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          name = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          name = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          name = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        InkWell(
            onTap: (){
              Navigator.push(context,MaterialPageRoute(builder: (context)=>ViewFile(urls:[{'url':'','url1':url}])));
            },
            child: CustomAvatar(imageurl: url, radius:widget.radius)),
       widget.click?InkWell(
            onTap: () {
                Navigator.push(context,  MaterialPageRoute(
                    builder: (context){
                      if(collectionName=='Club'){
                        return AccountclubViewer(user: Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                      }else if(collectionName=='Professional'){
                        return AccountprofilePviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                      }else{
                        return Accountfanviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                      }
                    }
                ),);
            },
            child: UsernameDO(username: name, width: widget.width, style: widget.style, collectionName: collectionName, maxSize: widget.maxsize, height: widget.height,)):UsernameDO(username: name, width: widget.width, style: widget.style, collectionName: collectionName, maxSize: widget.maxsize, height: widget.height,)
      ],
    );
  }
}

class CustomNameM extends StatefulWidget {
  String userId;
  TextStyle style;
  double maxsize;
  Person? user;
  bool click;
  CustomNameM({super.key,
    required this.userId,
    required this.style,
    required this.maxsize,
    this.user,
    this.click=false,
  });

  @override
  State<CustomNameM> createState() => _CustomNameMState();
}

class _CustomNameMState extends State<CustomNameM> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    getData();
  }
  @override
  void didUpdateWidget(covariant CustomNameM oldWidget) {
    if (oldWidget.userId != widget.userId) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }
  String url='';
  String name="loading....";
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        name =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: name,
              userId: widget.userId,
              location: location,
              collectionName: collectionName,
              url: url,
            )
        ));
      }
    }else{
      await getUserData();
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: widget.userId,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
    }
  }
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          name = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          name = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          name = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.click) {
      return InkWell(
        onTap: () {
            Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  if (collectionName == 'Club') {
                    return AccountclubViewer(user: Person(name: name,
                        url: url,
                        collectionName: collectionName,
                        userId: widget.userId), index: 0);
                  } else if (collectionName == 'Professional') {
                    return AccountprofilePviewer(user: Person(name: name,
                        url: url,
                        collectionName: collectionName,
                        userId: widget.userId), index: 0);
                  } else {
                    return Accountfanviewer(user: Person(name: name,
                        url: url,
                        collectionName: collectionName,
                        userId: widget.userId), index: 0);
                  }
                }
            ),);
        },
        child: CustomName(
          username: name, style: widget.style, maxsize: widget.maxsize,),
      );
    }else{
      return CustomName(
        username: name, style: widget.style, maxsize: widget.maxsize,);
    }
    }
}
class CustomUserNameD extends StatefulWidget {
  String userId;
  TextStyle style;
  double maxsize;
  double height;
  double width;
  Person? user;
  bool click;
  CustomUserNameD({super.key,
    required this.userId,
    required this.style,
    required this.maxsize,
    required this.height,
    this.user,
    this.click=false,
    required this.width,
  });

  @override
  State<CustomUserNameD> createState() => _CustomUserNameDState();
}

class _CustomUserNameDState extends State<CustomUserNameD> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    getData();
  }
  @override
  void didUpdateWidget(covariant CustomUserNameD oldWidget) {
    if (oldWidget.userId != widget.userId) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }
  String url='';
  String name="loading....";
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        name =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: name,
              userId: widget.userId,
              location: location,
              collectionName: collectionName,
              url: url,
            )
        ));
      }
    }else{
      await getUserData();
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: widget.userId,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
    }
  }
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          name = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          name = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          name = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.click){
    return InkWell(
      onTap: () {
          Navigator.push(context,  MaterialPageRoute(
              builder: (context){
                if(collectionName=='Club'){
                  return AccountclubViewer(user: Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                }else if(collectionName=='Professional'){
                  return AccountprofilePviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                }else{
                  return Accountfanviewer(user:Person(name: name, url: url, collectionName: collectionName, userId: widget.userId), index: 0);
                }
              }
          ),);
      },
      child: UsernameDO(username: name,
          collectionName: collectionName,
          maxSize: widget.maxsize,
          width: widget.width,
          height: widget.height),
    );
  }else{
      return UsernameDO(username: name,
          collectionName: collectionName,
          maxSize: widget.maxsize,
          width: widget.width,
          height: widget.height);
    }
    }
}

class CustomAvatarM extends StatefulWidget {
  String userId;
  Person? user;
  bool click;
  double radius;
  CustomAvatarM({super.key,
    required this.userId,
    this.user,
    this.click=false,
    required this.radius,
  });

  @override
  State<CustomAvatarM> createState() => _CustomAvatarMState();
}

class _CustomAvatarMState extends State<CustomAvatarM> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    getData();
  }
  @override
  void didUpdateWidget(covariant CustomAvatarM oldWidget) {
    if (oldWidget.userId != widget.userId) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }
  String url='';
  String name="loading....";
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        name =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: name,
              userId: widget.userId,
              location: location,
              collectionName: collectionName,
              url: url,
            )
        ));
      }
    }else{
      await getUserData();
      await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
          user: Person(
            name: name,
            userId: widget.userId,
            location: location,
            collectionName: collectionName,
            url: url,
          )
      ));
    }
  }
  Future<void>getUserData()async{
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: widget.userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          name = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          name = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          name = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return CustomAvatar(imageurl: url, radius:widget.radius);
  }
}

class LatestText extends StatefulWidget {
  String chatId;
  String collection;
  LatestText({super.key,
    required this.chatId,
    required this.collection});

  @override
  State<LatestText> createState() => _LatestTextState();
}

class _LatestTextState extends State<LatestText> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(widget.collection)
          .doc(widget.chatId)
          .collection('chat')
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text(''); // Handle case where there are no likes
        } else {
          final List<QueryDocumentSnapshot> likeDocuments = snapshot
              .data!.docs;
          List<Map<String, dynamic>> allLikes = [];
          for (final document in likeDocuments) {
            final List<dynamic> likesArray = document['chats'];
            allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
          }
          if (allLikes.isNotEmpty) {
          allLikes.sort((b, a) {
            Timestamp time1 = a['timestamp'];
            Timestamp time2 = b['timestamp'];
            DateTime date = time1.toDate();
            DateTime date1 = time2.toDate();
            DateTime adate = DateTime(date.year, date.month, date.day, date.hour, date.minute, date.second, date.millisecond, date.microsecond);
            DateTime bdate = DateTime(date1.year, date1.month, date1.day, date1.hour, date1.minute, date1.second, date1.millisecond, date1.microsecond);
            return adate.compareTo(bdate);
          });
          List<Map<String,dynamic>> urls = List<Map<String,dynamic>>.from(allLikes[0]['urls']);
          final user = allLikes[0]['sender'];
          final message = allLikes[0]['message'];
          if(user==FirebaseAuth.instance.currentUser!.uid){
          if(urls.isNotEmpty) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.remove_red_eye,color: Colors.grey,),
                const SizedBox(width: 5,),
                const Icon(Icons.image),
                const SizedBox(width: 5,),
                SizedBox(
                  height: 15,
                  width: MediaQuery.of(context).size.width*0.655,
                  child: OverflowBox(
                    child: Text(maxLines:1,
                      overflow:TextOverflow.ellipsis,
                      "$message",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(child: Text("${allLikes.length}",style: const TextStyle(color: Colors.white),)),
                ),
              ],
            );
          }else{
            return  Row(
              children: [
                const Icon(Icons.remove_red_eye,color: Colors.grey,),
                const SizedBox(width: 5,),
                SizedBox(
                  height: 15,
                  width: MediaQuery.of(context).size.width*0.73,
                  child: OverflowBox(
                    child: Text(maxLines:1,
                      overflow:TextOverflow.ellipsis,
                      "$message",
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(child: Text("${allLikes.length}",style: const TextStyle(color: Colors.white),)),
                ),
              ],
            );
          }}else{
            if(urls.isNotEmpty) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(Icons.image),
                  const SizedBox(width: 5,),
                  SizedBox(
                    height: 15,
                    width: MediaQuery.of(context).size.width*0.73,
                    child: OverflowBox(
                      child: Text(maxLines:1,
                        overflow:TextOverflow.ellipsis,
                        "$message",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Center(child: Text("${allLikes.length}",style: const TextStyle(color: Colors.white),)),
                  ),
                ],
              );
            }else{
              return  Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 15,
                    width: MediaQuery.of(context).size.width*0.8,
                    child: OverflowBox(
                      child: Text(maxLines:1,
                        overflow:TextOverflow.ellipsis,
                        "$message",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(15)
                    ),
                    child: Center(child: Text("${allLikes.length}",style: const TextStyle(color: Colors.white),)),
                  ),
                ],
              );
            }
          }
          } else  {
            return const Text('');
          }
        }
      },
    );
  }
}


class ClubChat extends StatefulWidget {
   ClubChat({super.key});

  @override
  State<ClubChat> createState() => _ClubChatState();
}

class _ClubChatState extends State<ClubChat> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController message = TextEditingController();
  late Stream<QuerySnapshot> _stream;
  MessageProvider m=MessageProvider();
  String groupname='';
  String url='';
  String groupId='';
  VideoControllerProvider v=VideoControllerProvider();
  @override
  void initState() {
    super.initState();
    v=VideoControllerProvider();
    m.retrieveChats(collection: 'Groups', docId: FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      groupId=FirebaseAuth.instance.currentUser!.uid;
    });
    groups();
  }
  List<Map<String, dynamic>> allLikes = [];
bool isdelete=false;


  @override
  void dispose() {

    super.dispose();
  }

  String replyto = '';

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }
  Future<void> creategroup() async {
    if (iscreate) {
      sendMessage();
    } else {
      final CollectionReference likesCollection =
      FirebaseFirestore.instance.collection('Groups');
      final List<Map<String, dynamic>> membersWithTimestamps = [];
      final Timestamp timestamp = Timestamp.now();
      final like = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': timestamp
      };

      for (var userId in selectedUserIds) {
        if (!selectedUserIds1.any((element) => element['userId'] == userId['teamId'] || selectedUserIds1.isEmpty)) {
          membersWithTimestamps.add({
            'userId': userId['teamId'],
            'timestamp': timestamp
          });
        }
      }
      final DocumentSnapshot documentSnapshot = await likesCollection.doc(groupId).get();
      if (documentSnapshot.exists) {
        await likesCollection.doc(groupId).update({
          'members': FieldValue.arrayUnion(membersWithTimestamps),
        });
        sendMessage();
      } else {
        membersWithTimestamps.add(like);
        await likesCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
          'groupId': groupId,
          'admins': [like],
          'profileimage': '',
          'groupname': '',
          'members': membersWithTimestamps,
          'createdAt': timestamp,
        });
      }

    }
  }



  Future<List<Map<String, dynamic>>> retrieveAllM() async {
    List<Map<String, dynamic>> allLikes = [];
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Clubs');
    final QuerySnapshot querySnapshot = await likesCollection.doc(groupId)
        .collection('clubsteam').get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> likeDocuments = querySnapshot.docs;
        for (final document in likeDocuments) {
          final List<dynamic> likesArray = document['clubsteam'];
            allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
        }
        }
    return allLikes;
  }
  Future<List<Map<String, dynamic>>> retrieveAllM1() async {
    List<Map<String, dynamic>> allLikes = [];
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Groups');
    final DocumentSnapshot documentSnapshot = await likesCollection.doc(groupId).get();
    if (documentSnapshot.exists) {
      var data=documentSnapshot.data()as Map<String,dynamic>;
        final List<dynamic> likesArray = data['members'];
        allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    return allLikes;
  }
  bool iscreate=false;
   List<Map<String, dynamic>> selectedUserIds =[];
   List<Map<String, dynamic>> selectedUserIds1 =[];
  Future<void> groups() async {
     selectedUserIds = await retrieveAllM();
     selectedUserIds1 = await retrieveAllM1();
     if(selectedUserIds1.length==selectedUserIds.length){
        setState(() {
          iscreate=true;
        });
        creategroup();
    }
  }
  void sendMessage() async {

  }

  Future<void> _loadVideos() async {
    final List<XFile> videos = await ImagePicker().pickMultiImage(requestFullMetadata: true);
    if (videos != null) {
      for(final video in videos){
        final File loadedVideo = File(video.path);
        setState(() {
          images.add({
            'url': loadedVideo.path,
            'url1': '',
          });
        });
      }}
  }


  List<Map<String,dynamic>>images=[];
  bool _showCloseIcon = false;
  double radius=15;
  double progress=0.0;
  bool replying=false;
  String  replyId='';
  String message1='';
  Map<String, dynamic>reply={};
  String  urlR='';
  String userId="";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[400],
        appBar: AppBar(
          leadingWidth:MediaQuery.of(context).size.width*0.1,
          leading: SizedBox(
            width: MediaQuery.of(context).size.width*0.1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 5,),
            CustomAvatarM(userId: groupId, radius: 21,),
            ],
          ),),
          title:InkWell(
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>  Groupdetails(groupId: groupId, username: '',),
                  ),
                );
              },
              child: CustomNameM(userId:groupId, style:const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18), maxsize:180,)) ,
          backgroundColor: Colors.blueGrey,
          elevation: 1,
         automaticallyImplyLeading: false,
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<String>(
                    position:PopupMenuPosition.under,
                    onSelected: (value) {
                      if(value=='1'){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context)=>  Groupdetails(groupId: groupId, username: '',),
                          ),
                        );
                      }else if(value=='3'){

                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: '1',
                          child: Text('Group details'),
                        ),
                        const PopupMenuItem<String>(
                          value: '3',
                          child: Text('Mute notifications'),
                        ),
                      ];
                    },
                  ),

                ],
              ),
            )
          ],

        ),
        body:Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedBuilder(
                    animation: m,
                    builder: (BuildContext context, Widget? child) {
                        return Align(
                          alignment: Alignment.topCenter,
                          child:GroupedListView<Chat, String>(
                            controller: m.scrollController,
                            reverse: false,
                            elements:m.messages,
                            groupBy: (element) {
                              DateTime date = element.timestamp.toDate();
                              return DateTime(date.year, date.month, date.day,).toString();
                            },
                            groupHeaderBuilder: (Chat message) {
                              DateTime date = message.timestamp.toDate();
                              final now = DateTime.now();
                              if (date.year < now.year) {
                                final m=month(date);
                                return Center(child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.grey
                                          )
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                        child: Text('${date.day} $m ${date.year}'),
                                      )),
                                ));
                              } else if (date.year == now.year && date.month < now.month || date.month == now.month&& date.day < now.day - 7) {
                                final m=month(date);
                                return Center(
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey
                                                )
                                            ),
                                            child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                                child: Text('${date.day} $m ${date.year}')))));
                              } else if (date.year == now.year && date.month == now.month && date.day < now.day - 1) {
                                final weekday=weekDay(date);
                                return Center(  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                            )
                                        ),
                                        child: Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                            child:Text(weekday)))));
                              } else if (date.year == now.year && date.month == now.month && date.day < now.day) {
                                return Center(
                                    child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 1,
                                                    color: Colors.grey
                                                )
                                            ),
                                            child: const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                                child: Text('yesterday')))));
                              } else
                              if (date.year == now.year && date.month==now.month && date.day == now.day) {
                                return Center(  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                            )
                                        ),
                                        child: const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                            child: Text('today')))));
                              } else {
                                return const Center(  child: Text(''));
                              }
                            },
                            groupSeparatorBuilder: (String value) {
                              return Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    value,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemBuilder: (context, Chat chat) {
                              Chat chat1=Chat(
                                timestamp: Timestamp.now(),
                                message: '',
                                reply:{},
                                urls: [],
                                messageId:'',
                                senderId:'',
                              );
                              if(chat.reply["messageId"].toString().isNotEmpty){
                                chat1=m.messages.firstWhere((element) => element.messageId==chat.reply['messageId']);
                              }
                              if (chat.senderId == FirebaseAuth.instance.currentUser!.uid) {
                                return InkWell(
                                  onLongPress: (){
                                    showDialog(context: context, builder:(context){
                                      return AlertDialog(content: const SizedBox(
                                        height: 50,
                                        child: Column(
                                          children: [
                                            Text('Do you wish to delete this message?'),
                                            Text('By deleting this message, the message will no longer be available to you or the other user.')
                                          ],
                                        ),
                                      ),actions: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            TextButton(onPressed: (){
                                              Navigator.pop(context);
                                            }, child: const Text('cancel')),
                                            TextButton(onPressed: (){
                                              m.deleteChat(collection:'Groups', docId:FirebaseAuth.instance.currentUser!.uid, message: chat,);
                                              Navigator.pop(context);}, child: const Text('delete'))
                                          ],
                                        )
                                      ],);
                                    });},
                                  child: MessageWidget(message:chat,
                                    docId: FirebaseAuth.instance.currentUser!.uid,
                                    group: true, color:Colors.teal,
                                    set: (){
                                      int  index=m.messages.indexWhere((element) => element.messageId==chat1.messageId);
                                      m.scrollController.animateTo(
                                        m.scrollController.position.maxScrollExtent*((index/m.messages.length)+0.09),
                                        duration: const Duration(milliseconds: 200),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                    reply: (String userId1) {
                                      setState(() {
                                        userId=userId1;
                                        replying = true;
                                        replyId = chat.messageId;
                                        message1 = chat.message;
                                        for (final item in m.messages) {
                                          if (item.messageId == chat.messageId) {
                                            List<Map<String,dynamic>> urlss = List<Map<String,dynamic>>.from(item.urls);
                                            if(urlss.isNotEmpty){
                                              urlR=urlss.first['url1'];
                                            }else{
                                              urlR='';
                                            }
                                          }
                                        }
                                      });
                                    },
                                    message1: chat1, color1: Colors.blueGrey,),
                                );
                              } else if (chat.senderId!=FirebaseAuth.instance.currentUser!.uid) {
                                return MessageWidget(message:chat,
                                  docId: FirebaseAuth.instance.currentUser!.uid,
                                  group: true, color:Colors.blueGrey,
                                  reply: (String userId1) {
                                  setState(() {
                                    userId=userId1;
                                    replying = true;
                                    replyId = chat.messageId;
                                    message1 = chat.message;
                                    for (final item in m.messages) {
                                      if (item.messageId == chat.messageId) {
                                        List<Map<String,dynamic>> urlss = List<Map<String,dynamic>>.from(item.urls);
                                        if(urlss.isNotEmpty){
                                          urlR=urlss.first['url1'];
                                        }else{
                                          urlR='';
                                        }
                                      }
                                    }
                                  });
                                }, message1: chat1, color1: Colors.teal, set: () {
                                    int  index=m.messages.indexWhere((element) => element.messageId==chat1.messageId);
                                    m.scrollController.animateTo(
                                      m.scrollController.position.maxScrollExtent*((index/m.messages.length)+0.09),
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                    );
                                  },);}
                              return Container();
                            },
                            order: GroupedListOrder.ASC,
                          ),
                        );}
                      ),
              ),
              FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    color: Colors.transparent,
                    margin:const EdgeInsets.only(bottom: 8,right: 8,left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    images.isNotEmpty?ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                      child: Container(
                      height: 100,
                        decoration: const BoxDecoration(
                            color: Colors.teal,
                        ),
                        width:images.length<4?106*images.length.toDouble(): MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: images.map<Widget>((url) => Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: SizedBox(
                                  height: 100,
                                  width: 100,
                                  child:Stack(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              bool urlExists = images.any((element) => element['url'] == url['url']);
                                              if (urlExists) {
                                                message.text = images.firstWhere((element) => element['url'] == url['url'])['message'];
                                              } else {
                                                images.map((p) {
                                                  if (p['url'] == url['url']) {
                                                    return {
                                                      ...p,
                                                     'message':message.text,
                                                    };
                                                  }
                                                  return p;
                                                }).toList();
                                                message.clear();
                                              }
                                            });
                                          },
                                          child: Image.file(
                                            File(url['url']),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: InkWell(
                                          onTap: (){
                                            setState((){
                                              images.removeWhere((element) =>
                                              element['url'] == url['url']);
                                              images.removeWhere((element) =>
                                              element['url'] == url['url']);
                                            });
                                          },
                                          child: const SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Icon(Icons.clear),
                                          ),
                                        ),
                                      ),

                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: images.any((element) => element['url']==url['url'])? InkWell(
                                          onTap: (){
                                            setState((){
                                              images.removeWhere((element) =>
                                              element['url'] == url['url']);
                                            });
                                          },
                                          child: const SizedBox(
                                            height: 30,
                                            width: 30,
                                            child: Icon(Icons.check,color: Colors.blue,),
                                          ),
                                        ):const SizedBox.shrink(),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            ).toList(),
                          ),
                        ),
                      ),
                    ):const SizedBox.shrink(),
                        replying?SizedBox(
                          width: MediaQuery.of(context).size.width*0.92,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width*0.88,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.blueGrey[300]!,
                                    border: Border.all(
                                      width: 10,
                                      color: Colors.blueGrey[700]!,
                                    )
                                ),
                                child: InkWell(
                                    onTap: (){
                                     // int index=m.messages.indexOf(chat);
                                      //m._scrollController.jumpTo(1/index);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10, right: 5),
                                                child:userId==FirebaseAuth.instance.currentUser!.uid?const Text(' You',
                                                  style: TextStyle(color: Colors.blue,fontSize: 15,fontWeight: FontWeight.bold),): CustomNameM(
                                                  userId: userId,
                                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                                  maxsize: 160,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.65,
                                                  child: ReplyW(text: message1,color: Colors.white,)),

                                            ],
                                          ),
                                          SizedBox(
                                            width: 55,
                                            height: 55,
                                            child: urlR.isNotEmpty? Padding(
                                              padding: const EdgeInsets.only(right: 0.5),
                                              child: ClipRRect(
                                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                                child: ImageVideo(url: urlR,),
                                              ),
                                            ):const SizedBox.shrink(),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                    onTap: (){
                                      setState(() {
                                        replying=false;
                                        message1="";
                                        replyId="";
                                        urlR="";
                                      });
                                    },
                                    child: Container(
                                      height: 23,
                                        width: 23,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(15),
                                            color: Colors.blueGrey[700]!,
                                        ),
                                        child: const Icon(Icons.close,color: Colors.white,))),
                              ),
                            ],
                          ),
                        ):const SizedBox.shrink(),
                                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8,right: 3),
                      child: Container(
                        width: MediaQuery.of(context).size.width*0.7375,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          scrollPadding: const EdgeInsets.only(bottom: 1),
                          scrollPhysics: const ScrollPhysics(),
                          expands: false,
                          maxLines: 6,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          cursorColor: Colors.black,
                          controller: message,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(bottom: 0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.grey),
                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.grey),
                            ),
                            filled: true,
                            hintStyle: const TextStyle(color: Colors.black,
                              fontSize: 16, fontWeight: FontWeight.normal,),
                            fillColor: Colors.white70,
                            prefixIcon: IconButton(onPressed: (){
                              _loadVideos();
                            },icon: const Icon(Icons.image)),
                            suffixIcon: const Icon(Icons.emoji_emotions),
                            hintText: 'Type your message',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _showCloseIcon = value.isNotEmpty;
                            });
                          },
                          onSubmitted: (String text) {

                          },
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child:  ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: _showCloseIcon||images.isNotEmpty ? FloatingActionButton(
                              backgroundColor: Colors.blueGrey,
                              onPressed: () {
                                final chat=Chat(timestamp: Timestamp.now(), message: message.text, reply:{
                                  "messageId":replyId,
                                  "message":message1,
                                }, urls: images,
                                    messageId:'',
                                    senderId: FirebaseAuth.instance.currentUser!.uid);
                                m.sendMessage(collection: 'Groups', docId: FirebaseAuth.instance.currentUser!.uid, message: chat,);
                                setState(() {
                                  replying=false;
                                  _showCloseIcon=false;
                                  message.clear();
                                  images.clear();
                                });
                              },
                              child: const Icon(Icons.send),
                            ) : FloatingActionButton(
                              backgroundColor: Colors.blueGrey,
                              onPressed: () {

                              },
                              child: const Icon(Icons.mic),
                            ),
                          ),
                        )
                    ),

                                  ],),
                      ]),
                  ),
                ),]
          ),
        ),
      ),
    );
  }
  String month(DateTime date){
    if(date.month==DateTime.january){
      return 'january';
    }else if(date.month==DateTime.february){
      return 'February';
    }else if(date.month==DateTime.march){
      return 'March';
    }else if(date.month==DateTime.april){
      return 'April';
    }else if(date.month==DateTime.may){
      return 'May';
    }else if(date.month==DateTime.june){
      return 'June';
    }else if(date.month==DateTime.july){
      return 'July';
    }else if(date.month==DateTime.august){
      return 'August';
    }else if(date.month==DateTime.september){
      return 'September';
    }else if(date.month==DateTime.october){
      return 'October';
    }else if(date.month==DateTime.november){
      return 'November';
    }else if(date.month==DateTime.december){
      return 'December';
    }else{
      return'';
    }}
  String weekDay(DateTime date){
    if(date.weekday==DateTime.monday){
      return 'Monday';
    }else if(date.weekday==DateTime.tuesday){
      return 'Tuesday';
    }else if(date.weekday==DateTime.wednesday){
      return 'Wednesday';
    }else if(date.weekday==DateTime.thursday){
      return 'Thursday';
    }else if(date.weekday==DateTime.friday){
      return 'Friday';
    }else if(date.weekday==DateTime.saturday){
      return 'Saturday';
    }else if(date.weekday==DateTime.sunday){
      return 'Sunday';
    }else{
      return'';
    }
  }

}


class MessageWidget extends StatefulWidget {
  final Chat message;
  final String docId;
  final bool group;
  final Color color;
  final Color color1;
  final void Function(String userId) reply;
  final Chat message1;
  final void Function() set;
  MessageWidget({
    super.key,
    required this.message,
    required this.docId,
    required this.group,
    required this.color,
    required this.color1,
    required this.reply,
    required this.message1,
    required this.set,
  });

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  double currentZoomValue = 0.0;
  double currentZoomValue1 = 0.0;
  double width=0.0;
  @override
  void initState() {
    super.initState();
    setState(() {
      width=messageWidth();
    });
  }
  double messageWidth(){
    double nameWidth=170.0;
    double width=calculateTextWidth(widget.message.message);
    double width1=calculateTextWidth(widget.message1.message);
    double width2=MediaQuery.of(context).size.width * 0.7125;
    double time =MediaQuery.of(context).size.width * 0.18;
    if(width>=width2||widget.message.urls.isNotEmpty||width1>=width2) {
      return width2;
    }else if(width<=nameWidth&&widget.group&&widget.message.senderId != FirebaseAuth.instance.currentUser!.uid||width1<=nameWidth&&widget.group&&widget.message.senderId != FirebaseAuth.instance.currentUser!.uid) {
      return nameWidth;
    }else if(width+30>width2||width1+30>width2){
      return width2;
    }else if(width<time){
      return time+10.0;
    }else{
      return width+30.0;
    }
  }
  double calculateTextWidth(String text) {
    double totalWidth = 0.0;
    for (int i = 0; i < text.length; i++) {
      totalWidth += _calculateCharacterWidth(text[i]);
    }

    return totalWidth;
  }

  double _calculateCharacterWidth(String character) {
    if (character == ' ') {
      return 4.0;
    }else {
      final TextPainter textPainter = TextPainter(
        text: TextSpan(text: character, style: TextStyle()),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(minWidth: 0, maxWidth: double.infinity);
      return textPainter.width;
    }
  }
double setter=0.0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Align(
          alignment:widget.message.senderId==FirebaseAuth.instance.currentUser!.uid? Alignment(-0.8+currentZoomValue1,0.0):Alignment(-1.0+currentZoomValue1,0.0),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: currentZoomValue>0.1 ?60 :0,
              height:  currentZoomValue>0.1 ?30 :0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
              ),
              child:  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                child: Text(currentZoomValue>0.1?"Reply":"",style: const TextStyle(color: Colors.white),),
              )),
        ),
        Align(
          alignment:widget.message.senderId==FirebaseAuth.instance.currentUser!.uid? Alignment(1.0+currentZoomValue,0.0):Alignment(-1.0+currentZoomValue,0.0),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              double delta = details.primaryDelta ?? 0.0;
              if (delta > 0&&currentZoomValue<3.5) {
                setState(() {
                  currentZoomValue= currentZoomValue+(details.delta.dx*0.02);
                  setter=setter+(details.delta.dx*0.02);
                  if(currentZoomValue>1.5) {
                    currentZoomValue1 =
                        currentZoomValue1 + (details.delta.dx * 0.005);
                  }
                });
              }else if(delta < 0&&currentZoomValue>0){
                setState(() {
                  currentZoomValue= currentZoomValue+(details.delta.dx*0.02);
                  setter=setter+(details.delta.dx*0.02);
                  if(currentZoomValue>1.5) {
                    currentZoomValue1 =
                        currentZoomValue1 + (details.delta.dx * 0.005);
                  }else{
                    currentZoomValue1 =0.0;
                  }
                });
              }
            },
            onHorizontalDragEnd:(details){
              if(setter>=1) {
                widget.reply(widget.message.senderId);
                setState(() {
                  setter=0.0;
                  currentZoomValue= 0.0;
                  currentZoomValue1= 0.0;
                });
              }else{
                setState(() {
                  setter=0.0;
                  currentZoomValue= 0.0;
                  currentZoomValue1= 0.0;
                });
              }
            } ,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                width:width,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.senderId != FirebaseAuth.instance.currentUser!.uid && widget.group)
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 5),
                        child: CustomUsernameD0Avatar(
                          userId: widget.message.senderId,
                          click: true,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          radius: 14,
                          maxsize: 100,
                          height: 38,
                          width: 125,
                        ),
                      ),
                    if (widget.message.urls.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 5),
                        child: ImageVideoUp(
                          urls: widget.message.urls,
                          senderId: widget.message.senderId,
                          chatId: widget.docId,
                          messageId: widget.message.messageId,
                          group: widget.group,
                        ),
                      ),
                    if (widget.message1.messageId.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap:widget.set,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            decoration: BoxDecoration(
                              color: widget.color1,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10, right: 5),
                                      child:widget.message1.senderId==FirebaseAuth.instance.currentUser!.uid?const Text(' You',
                                        style: TextStyle(color: Colors.blue,fontSize: 15,fontWeight: FontWeight.bold),): CustomNameM(
                                        userId: widget.message1.senderId,
                                        style: const TextStyle(fontSize: 14, color: Colors.black),
                                        maxsize: 160,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: SizedBox(
                                        width: widget.message1.urls.isNotEmpty
                                            ? MediaQuery.of(context).size.width * 0.5
                                            : MediaQuery.of(context).size.width * 0.65,
                                        child: ReplyW(text: widget.message1.message, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.message1.urls.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 1.0),
                                    child: ClipRRect(
                                      child: ImageVideo(url: widget.message1.urls.first['url1']),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ReadMore0(text:"${widget.message.message}",color:Colors.white),
                    ),
                    Row(
                     mainAxisAlignment:MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.height * 0.038,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              MessageTime(time:widget.message.timestamp),
                              if (widget.message.senderId == FirebaseAuth.instance.currentUser!.uid)
                                const Icon(Icons.remove_red_eye_outlined, color: Colors.lightBlue, size: 15),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Chat{
  String messageId;
  String senderId;
  String message;
  Timestamp timestamp;
  List<Map<String,dynamic>>urls;
  Map<String,dynamic>reply;
  Chat({
    required this.timestamp,
    required this.message,
    required this.reply,
    required this.urls,
    required this.messageId,
    required this.senderId,
  });
}
class MessageProvider with ChangeNotifier{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Chat> messages=[];
  final ScrollController scrollController = ScrollController();
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
  void scrollToBottom()async {
    await Future.delayed(const Duration(milliseconds: 100), () {});
    scrollController.animateTo(
      scrollController.position.maxScrollExtent*1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }
  List<QueryDocumentSnapshot> allDocs =[];
  Future<void> retrieveChats({required String collection, required String docId}) async {
    showToastMessage('Retrieving messages...');
    try {
      stream = _firestore
          .collection(collection)
          .doc(docId)
          .collection('chat')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          allDocs=snapshot.docs;
          List<Map<String, dynamic>> allMessages = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['chats']);
            allMessages.addAll(chats);
          }
          messages= allMessages.map((d) => Chat(
            timestamp: d['timestamp'],
            message: d['message'],
            reply: d['replyto']==null?{}:Map<String,dynamic>.from(d['replyto']),
            urls: d['urls']==null?[]:List<Map<String,dynamic>>.from(d['urls']),
            messageId: d['messageId'],
            senderId: d['sender'],
          )).toList();
          messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          showToastMessage('Retrieved successfully');
          showToastMessage('Number of messages: ${messages.length}');
          notifyListeners();
        } else {
          showToastMessage('No messages');
        }
        scrollToBottom();
        notifyListeners();
      });
    } catch (e) {
      showToastMessage('Error retrieving messages: $e');
      notifyListeners();
    }
  }

  late Stream<QuerySnapshot> stream;

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }
  bool showCloseIcon=false;
  void sendMessage({
    required String collection,
    required String docId,
    required Chat message,}) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .collection('chat');
    String messageId = generateUniqueNotificationId();
    final Timestamp timestamp = Timestamp.now();
    final like = {
      'sender': FirebaseAuth.instance.currentUser!.uid,
      'messageId': messageId,
      'timestamp': timestamp,
      'message': message.message,
      'replyto': {
        'message':message.reply['message'],
        'messageId':message.reply['messageId'],
      },
      'urls': message.urls,
    };
    if (message.message.isEmpty&&message.urls.isEmpty) {
      return;
    }else if(message.urls.isNotEmpty||message.message.isNotEmpty) {
      if (isnonet) {
      try {
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          final DocumentSnapshot latestDoc = documents.first;
          List<dynamic> chatsArray = latestDoc['chats'];
          notifyListeners();
          if (chatsArray.length < 10000) {
              chatsArray.add(like);
              notifyListeners();
            latestDoc.reference.update({'chats': chatsArray});
            showCloseIcon = false;
            notifyListeners();
          } else {
            List<Map<String, dynamic>> chat = [];
            chat.add(like);
            likesCollection.add({'chats': chat});
            showCloseIcon = false;
            notifyListeners();
          }
        } else {
          List<Map<String, dynamic>> chat = [];
          chat.add(like);
          likesCollection.add({'chats': chat});
          showCloseIcon = false;
          notifyListeners();
        }
        notifyListeners();
      } catch (e) {
        showToastMessage('Error sending message: $e');
      }}else {
        final data = {
          'sender': FirebaseAuth.instance.currentUser!.uid,
          'messageId': messageId,
          'message': message.message,
          'replyto': {
            'message': message.reply['message'],
            'messageId': message.reply['messageId'],
          },
          'urls': message.urls,
        };
        await SendDatatoFunction().addData(data: Data(collection:collection,docId: docId,subcollection: "chat",data: data, subdocId: ''));
      }
    }
  }
  Future<void> deleteChat({
    required String collection,
    required String docId,
    required Chat message,}) async {
    messages.remove(message);
    notifyListeners();
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .collection('chat');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['chats'];
      final index = likesArray.indexWhere((like) => like['messageId'] ==message.messageId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'chats': likesArray});
        return;
      }
    }
    notifyListeners();
  }
  File? originalImage;
  String? compressedImageString;
  String? compressedImageSize;
  double compressionProgress = 0.0;
  int targetWidth = 720;
  int targetHeight = 1280;
  String? originalImageSize;

  Future<String> pickAndCompressImage(String file) async {
    String image='';
    final originalFile = File(file);
    final originalFileSize = (originalFile.lengthSync() / 1024).toStringAsFixed(2);
    originalImage = originalFile;
    originalImageSize = originalFileSize;
    compressedImageString = null;
    compressedImageSize = null;
    compressionProgress = 0.0;
    await Future.delayed(Duration.zero);
    final compressedBytes = await compressImage(originalFile);
    if (compressedBytes != null) {
      final compressedBase64 = base64Encode(compressedBytes);
      final compressedSizeKB = (compressedBytes.lengthInBytes / 1024).toStringAsFixed(2);
      compressedImageString = compressedBase64;
      compressedImageSize = compressedSizeKB;
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File('${tempDir.path}/compressed_image.jpg').writeAsBytes(compressedBytes);
      image=tempFile.path;
      //await GallerySaver.saveImage(tempFile.path);
      notifyListeners();
    }
    return image;
  }

  Future<Uint8List?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 85,
      minHeight: targetHeight,
      minWidth: targetWidth,
    );
    return result;
  }
  double progress=0.0;
  Future<String?> uploadImagesToStorage( String? imagePaths) async {
    try {
        String image=await pickAndCompressImage(imagePaths!);
        File imageFile = File(image);
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
            .ref()
            .child('chats')
            .child('images')
            .child('$fileName.jpg');
        final uploadTask = ref.putFile(imageFile);
        uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
          progress = snapshot.bytesTransferred / snapshot.totalBytes;
          notifyListeners();
        });
        final snapshot = await uploadTask.whenComplete(() {});
        if (snapshot.state == firebase_storage.TaskState.success) {
          String imageURL = await ref.getDownloadURL();
          return imageURL;
        } else {
          notifyListeners();
        }
        notifyListeners();
      return '';
    } catch (e) {
      return e.toString();
    }
  }
  Future<void> addUrl({
    required String messageId,
    required String url,
    required String chatId,
    required String collection
  }) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(chatId)
        .collection('chat');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    showToastMessage("sending initialized");
    if (url.isNotEmpty) {
      showToastMessage("url is not empty");
        for (var document in documents) {
          final List<dynamic> chats = document['chats'];
          final index = chats.indexWhere((chat) =>
          chat['messageId'] == messageId);
          if (index != -1) {
            showToastMessage("got the message Id");
            List<Map<String, dynamic>> urls = List<Map<String, dynamic>>.from(
                chats[index]['urls']);
            final urlIndex = urls.indexWhere((urlMap) => urlMap['url'] == url);
            if (urlIndex != -1) {
              try {
                showToastMessage("url data uploading");
                String? uploadedUrls = await uploadImagesToStorage(url);
                showToastMessage("url data uploaded: $uploadedUrls");
                urls[urlIndex]['url1'] = uploadedUrls;
                urls[urlIndex]['timestamp'] = Timestamp.now();
                await document.reference.update({'chats': chats});
                showToastMessage("chats list updated ");
              } catch (e) {
                print("Error updating Firestore document: $e");
              }
              notifyListeners();
              return;
            }
          }
        }
    }
    notifyListeners();
  }


}