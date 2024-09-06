import 'package:fans_arena/fans/components/likebuttonfanstv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../clubs/screens/accountclubviewer.dart';
import '../../../clubs/screens/eventsclubs.dart';
import '../../../fans/screens/accountfanviewer.dart';
import '../../../fans/screens/matchwatch.dart';
import '../../../fans/screens/messages.dart';
import '../../../fans/screens/newsfeed.dart';
import '../../../professionals/screens/accountprofilepviewer.dart';
import '../../../reusablewidgets/cirularavatar.dart';
import '../../data/screens/feed_item.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/filming0.dart';
import 'filmlayout.dart';

class FilmingLayout2 extends StatefulWidget {
  EventM event;
  FilmingLayout2({super.key, required this.event});
  @override
  State<FilmingLayout2> createState() => _FilmingLayout2State();
}

class _FilmingLayout2State extends State<FilmingLayout2> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FilmingProvider film=FilmingProvider();
  ViewsProvider v=ViewsProvider();
  @override
  void initState() {
    super.initState();
    v.getViews("Events", widget.event.eventId);
    film.onPause2(matchId: widget.event.eventId,collection:'Events');
    _getCurrentUser();
    film.initAgora(userId: FirebaseAuth.instance.currentUser!.uid, matchId: widget.event.eventId,collection:'Events');
    film.onPause0(matchId: widget.event.eventId,collection:'Events');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (event.x > 7) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
      } else if (event.x < -7) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
        SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
      }
    });
  }
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    film.engine?.disableVideo();
    film.engine?.leaveChannel();
    film.uids.clear();
    film.uidToPeerIdMap.clear();
    film.engine?.disableAudio();
    film.dispose();
    super.dispose();
  }




  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });

    }
  }

  void postEvent() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("${widget.event.user.collectionName}s")
          .doc(userId)
          .collection('eventstreamed')
          .where('eventId', isEqualTo: widget.event.eventId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        Timestamp createdAt = Timestamp.now();
        FirebaseFirestore.instance
            .collection('Clubs')
            .doc(userId)
            .collection('eventstreamed')
            .add({
          'eventId': widget.event.eventId,
          'authorId': userId,
          'createdAt': createdAt,
        });
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  void resumeEvent() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.event.eventId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        Timestamp createdAt = Timestamp.now();
        if ("1" != oldData['state2']) {
          newData['state2'] = "1";
        }
        if ( film.pausetime.isNotEmpty&&createdAt != oldData['resumetime']) {
          newData['resumetime'] = createdAt;
        }
        if ( film.pausetime1.isNotEmpty&&createdAt != oldData['resumetime1']) {
          newData['resumetime1'] = createdAt;
        }
        if ( film.pausetime2.isNotEmpty&&createdAt != oldData['resumetime2']) {
          newData['resumetime2'] = createdAt;
        }
        if ( film.pausetime3.isNotEmpty&&createdAt != oldData['resumetime3']) {
          newData['resumetime3'] = createdAt;
        }
        if ( film.pausetime4.isNotEmpty&&createdAt != oldData['resumetime4']) {
          newData['resumetime4'] = createdAt;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  void pauseEvent() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.event.eventId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        Timestamp createdAt = Timestamp.now();
        if ("0" != oldData['state2']) {
          newData['state2'] = "0";
        }
        if (message1.text.isNotEmpty && message1.text != oldData['message']) {
          newData['message'] = message1.text;
        }
        if (additionalinfo.text.isNotEmpty && additionalinfo.text != oldData['additionalinfo']) {
          newData['additionalinfo'] = additionalinfo.text;
        }
        if ( film.pausetime.isEmpty&&createdAt != oldData['pausetime']) {
          newData['pausetime'] = createdAt;
        }
        if (film.pausetime.isNotEmpty&& createdAt != oldData['pausetime1']) {
          newData['pausetime1'] = createdAt;
        }
        if (film.pausetime1.isNotEmpty&& createdAt != oldData['pausetime2']) {
          newData['pausetime2'] = createdAt;
        }
        if (film.pausetime2.isNotEmpty&& createdAt != oldData['pausetime3']) {
          newData['pausetime3'] = createdAt;
        }
        if (film.pausetime3.isNotEmpty&& createdAt != oldData['pausetime4']) {
          newData['pausetime4'] = createdAt;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  Future<void> startEvent() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.event.eventId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        Timestamp createdAt = Timestamp.now();
        if ("1" != oldData['state1']) {
          newData['state1'] = "1";
        }
        if ("1" != oldData['state2']) {
          newData['state2'] = "1";
        }
        if ( createdAt != oldData['starttime']) {
          newData['starttime'] = createdAt;
        }
        if (newData.isNotEmpty) {
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Starting event")
                ],),
            ),
          ));
          await documentSnapshot.reference.update(newData);
          await film.updateUrls(matchId: widget.event.eventId,collection: "Events");
          await film.streamToSocialMedia(widget.event.eventId,"Events",FirebaseAuth.instance.currentUser!.uid);
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(Duration(seconds: 1));
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: Text("Event started")),
            ),
          ));
          await Future.delayed(Duration(seconds: 1));
          Navigator.of(context,rootNavigator: true).pop();
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<void> stopEvent() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.event.eventId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};
        Timestamp createdAt = Timestamp.now();
        if (message1.text.isNotEmpty && message1.text != oldData['message']) {
          newData['message'] = message1.text;
        }
        if (additionalinfo.text.isNotEmpty && additionalinfo.text != oldData['additionalinfo']) {
          newData['additionalinfo'] = additionalinfo.text;
        }
        if ("0" != oldData['state1']) {
          newData['state1'] = "0";
        }
        if ("0" != oldData['state2']) {
          newData['state2'] = "0";
        }
        if ( createdAt != oldData['stoptime']) {
          newData['stoptime'] = createdAt;
        }
        if (newData.isNotEmpty) {
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Stopping event")
                ],),
            ),
          ));
          await documentSnapshot.reference.update(newData);
          await film.deleteRtmpConverter();
          postEvent();
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(Duration(seconds: 1));
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: Text("Event stopped")),
            ),
          ));
          await Future.delayed(Duration(seconds: 1));
          Navigator.of(context,rootNavigator: true).pop();
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }


  TextEditingController message1=TextEditingController();
  TextEditingController additionalinfo=TextEditingController();
  String time = '';
  String createdAt = '';
  String userId = '';
  String pausetime='';
  String matchurl='';
  bool isstart=false;
  bool ispaused=false;
  int duration=0;
  void post2(){
    pauseEvent();
    Navigator.of(context).pop();
  }

  int uid=0;
  double radius=19;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: OrientationBuilder(
          builder: (context, orientation) {
            return Row(
              children: [
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    UsermainPreview(matchId: widget.event.eventId,userId:userId, collection: 'Events', authorId:widget.event.user.userId,),
                    SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width*0.68,
                        height:  MediaQuery
                            .of(context)
                            .size.height,
                        child: Center(child: Stack(
                          children: [
                           // UsermainPreview(matchId: widget.event.eventId,userId:userId, main: uid, collection: 'Events', engine: film.engine!,),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 45),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child:
                                AnimatedBuilder(animation: film,
                                  builder: (BuildContext context, Widget? child) {
                                    return  SizedBox(
                                      width: MediaQuery.of(context).size.width*0.056,
                                      height: MediaQuery.of(context).size.height*0.7,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:Colors.grey,
                                                    width: 3,
                                                  )
                                              ),
                                              child:Center(child: Text('${film.index}',style:const TextStyle(color:Colors.white,fontSize: 16)))
                                          ),
                                          SizedBox(
                                            height: 45,
                                            child: IconButton(onPressed: (){
                                              film.engine?.switchCamera();}, icon: const Icon(Icons.camera_alt,color: Colors.white,size: 30,)),
                                          ),

                                          SizedBox(
                                              height: 45,
                                              child: film.isstart? IconButton(onPressed: (){
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text('Quit Event streaming'),
                                                      content: const Text('Do you want to quit event streaming'),
                                                      actions: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            TextButton(
                                                              child: const Text('No'),
                                                              onPressed: () {
                                                                Navigator.pop(context); // Dismiss the dialog
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: const Text('Yes'),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                                showModalBottomSheet(
                                                                    isScrollControlled: true,
                                                                    isDismissible: true,
                                                                    backgroundColor: Colors.transparent,
                                                                    shape: const RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.only(
                                                                            topLeft: Radius.circular(10),
                                                                            topRight: Radius.circular(10))),
                                                                    context: context,
                                                                    builder: (BuildContext context) {
                                                                      return Align(
                                                                        alignment: const Alignment(0.0,-0.8),
                                                                        child: ClipRRect(
                                                                          borderRadius: BorderRadius.circular(10),
                                                                          child: Container(
                                                                            color: Colors.white,
                                                                            height: MediaQuery.of(context).size.height*0.5,
                                                                            width: MediaQuery.of(context).size.width*0.31,
                                                                            child: Padding(
                                                                              padding: const EdgeInsets.only(top: 20),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  const Text('Stop action reasons',style: TextStyle(fontWeight: FontWeight.bold),),
                                                                                  SizedBox(
                                                                                    height: 35,
                                                                                    width: MediaQuery.of(context).size.width*0.24,
                                                                                    child: TextFormField(
                                                                                      controller: message1,
                                                                                      decoration: const InputDecoration(
                                                                                          hintText: 'eg.fulltime',
                                                                                          fillColor: Colors.white,
                                                                                          filled: true,
                                                                                          hintStyle: TextStyle(color: Colors.black)
                                                                                      ),),
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: MediaQuery.of(context).size.width*0.24,
                                                                                    height: 35,
                                                                                    child: TextFormField(
                                                                                      controller: additionalinfo,
                                                                                      decoration: const InputDecoration(
                                                                                          hintText: 'additional info',
                                                                                          fillColor: Colors.white,
                                                                                          filled: true,
                                                                                          hintStyle: TextStyle(color: Colors.black)
                                                                                      ),),
                                                                                  ),
                                                                                  TextButton(onPressed: (){
                                                                                    Navigator.pop(context);
                                                                                    stopEvent();}
                                                                                    , child: const Text('post'))
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),

                                                                      );});
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              }, icon: const Icon(Icons.stop,color: Colors.white,size: 35,)):IconButton(
                                                onPressed:()=>startEvent(),
                                                icon: const Icon(Icons.fiber_manual_record,
                                                  color: Colors.white,size: 35,),)),
                                          SizedBox(
                                            height: 45,
                                            child: film.ispaused?IconButton(onPressed:(){
                                              showModalBottomSheet(
                                                  isScrollControlled: true,
                                                  isDismissible: true,
                                                  backgroundColor: Colors.transparent,
                                                  shape: const RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.only(
                                                          topLeft: Radius.circular(10),
                                                          topRight: Radius.circular(10))),
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return Align(
                                                      alignment: const Alignment(0.0,-0.8),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Container(
                                                          color: Colors.white,
                                                          height: 200,
                                                          width: MediaQuery.of(context).size.width*0.31,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 20),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                const Text('Pause action reasons',style: TextStyle(fontWeight: FontWeight.bold),),
                                                                SizedBox(
                                                                  height: 35,
                                                                  width: MediaQuery.of(context).size.width*0.21,
                                                                  child: TextFormField(
                                                                    controller: message1,
                                                                    decoration: const InputDecoration(
                                                                        hintText: 'eg.halftime',
                                                                        fillColor: Colors.white,
                                                                        filled: true,
                                                                        hintStyle: TextStyle(color: Colors.black)
                                                                    ),),
                                                                ),
                                                                SizedBox(
                                                                  height: 35,
                                                                  width: MediaQuery.of(context).size.width*0.21,
                                                                  child: TextFormField(
                                                                    controller: additionalinfo,
                                                                    decoration: const InputDecoration(
                                                                        hintText: 'additional info',
                                                                        fillColor: Colors.white,
                                                                        filled: true,
                                                                        hintStyle: TextStyle(color: Colors.black)
                                                                    ),),
                                                                ),
                                                                TextButton(onPressed: post2, child: const Text('post'))
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                    );});
                                            }, icon: const Icon(Icons.pause,color: Colors.white,size: 35,)):IconButton(onPressed:resumeEvent,icon:const Icon(Icons.play_arrow,color: Colors.white,size: 35,)),
                                          ),

                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ))),
                    Align(
                        alignment: Alignment.topCenter,
                        child:Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width*0.68,
                            height: 42,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.067,
                                  child: IconButton(onPressed: () {
                                    Navigator.of(context).pop();
                                  }, icon: const Icon(Icons.arrow_back,color: Colors.white,size: 30,)),
                                ),
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.182,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomAvatar(radius: 19,imageurl: widget.event.user.url,),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Column(
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  Navigator.push(context,  MaterialPageRoute(
                                                      builder: (context){
                                                        if(widget.event.user.collectionName=='Club'){
                                                          return AccountclubViewer(user: widget.event.user, index: 0);
                                                        }else if(widget.event.user.collectionName=='Professional'){
                                                          return AccountprofilePviewer(user: widget.event.user, index: 0);
                                                        }else{
                                                          return Accountfanviewer(user:widget.event.user, index: 0);
                                                        }
                                                      }
                                                  ),);
                                                },
                                                child:CustomName(
                                                  username: widget.event.user.name,
                                                  maxsize: MediaQuery.of(context).size.width*0.189,
                                                  style:const TextStyle(color: Colors.white,fontSize: 14),)),
                                            InkWell(
                                                onTap: () {},
                                                child:   CustomName(
                                                  username: widget.event.user.location,
                                                  maxsize: MediaQuery.of(context).size.width*0.189,
                                                  style:const TextStyle(color: Colors.white,fontSize: 14),))
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),



                                SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.182,
                                    height: 25,
                                    child:Text(widget.event.title,style: const TextStyle(color: Colors.white),)
                                ),


                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.1333,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      AnimatedBuilder(
                                        animation: film,
                                        builder: (BuildContext context, Widget? child) {
                                          int minutes1 = film.duration ~/ 60;
                                          int remainingSeconds1 = film.duration % 60;

                                          String minutesString1 = minutes1.toString().padLeft(2, '0');
                                          String secondsString1 = remainingSeconds1.toString().padLeft(2, '0');
                                          int minutes = film.seconds ~/ 60;
                                          int remainingSeconds = film.seconds % 60;

                                          String minutesString = minutes.toString().padLeft(2, '0');
                                          String secondsString = remainingSeconds.toString().padLeft(2, '0');
                                          return  SizedBox(
                                            height: 20,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                film.ispaused?const Icon(Icons.pause, size: 16,color:Colors.white):Icon(Icons.play_arrow, size: 16,color:Colors.white),
                                                film.duration==0? Text("$minutesString:$secondsString",style: TextStyle(color: Colors.white)):Text("$minutesString1:$secondsString1",style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                      SizedBox(
                                          height: 20,
                                          child: Text(widget.event.location,style: const TextStyle(color: Colors.white)))
                                    ],
                                  ),
                                ),
                              ],
                            )
                        )
                    ),

                    Align(
                        alignment: Alignment.bottomCenter,
                        child:
                        Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width*0.68,
                            height: 40,
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.12,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(onPressed: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          isDismissible: true,
                                          backgroundColor: Colors.transparent,
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight: Radius.circular(10))),
                                          context: context,
                                          builder: ( context) {
                                            return Row(
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.1,
                                                  height: MediaQuery.of(context).size.height,
                                                ),
                                                SizedBox(
                                                    width: MediaQuery.of(context).size.width*0.5,
                                                    height: MediaQuery.of(context).size.height,
                                                    child:  MatchComments(matchId: widget.event.eventId, authorId:widget.event.user.userId, collection: 'Events',)),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.4,
                                                  height: MediaQuery.of(context).size.height,
                                                ),
                                              ],
                                            );
                                          },);
                                      },
                                          icon: const Icon(Icons.mode_comment_outlined,color:Colors.white)),
                                      MatchcommentsH(matchId: widget.event.eventId, color: Colors.white, collection: 'Events',),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.12,
                                  child:   SizedBox(
                                    width: MediaQuery.of(context).size.width*0.089,
                                    child:LikeButton0(
                                      matchId:widget.event.eventId, isenabled: false, collection: 'Events',),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.12,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.remove_red_eye_outlined,
                                        color: Colors.blue,),
                                      AnimatedBuilder(
                                          animation: v,
                                          builder: (BuildContext context, Widget? child) {
                                            return
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                                child: LikesCountWidget1(totalLikes: v.views.length,),
                                              );}),
                                    ],
                                  ),
                                ),
                                //download
                              ],
                            )
                        )
                    ),


                  ],
                ),
              ],
            );
          }
      ),

    );
  }}



class AvatarsStreaming extends StatefulWidget {
  final int uid;
  final String matchId;
  final String collection;

  AvatarsStreaming({
    super.key,
    required this.uid,
    required this.matchId,
    required this.collection,
  });

  @override
  State<AvatarsStreaming> createState() => _AvatarsStreamingState();
}

class _AvatarsStreamingState extends State<AvatarsStreaming> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    int n = 100;
    int runtime = 0;
    for (int i = 0; i < n; i++) {
      runtime++;
      if (widget.uid != 0) {
        n = runtime;
        await retrieveUserIdAndProfileImage();
        break;
      }
    }
  }

  Future<void> retrieveUserIdAndProfileImage() async {
    try {
      QuerySnapshot querySnapshotA = await firestore
          .collection(widget.collection)
          .doc(widget.matchId)
          .collection('streamers')
          .where('uid', isEqualTo: widget.uid)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        String userId = data['userId'];
        DocumentSnapshot clubDoc = await firestore.collection('Clubs').doc(userId).get();
        if (clubDoc.exists && clubDoc.data() != null) {
          setState(() {
            profileImageUrl = clubDoc['profileimage'];
          });
        } else {
          DocumentSnapshot proDoc = await firestore.collection('Professionals').doc(userId).get();
          if (proDoc.exists && proDoc.data() != null) {
            setState(() {
              profileImageUrl = proDoc['profileimage'];
            });
          }
        }
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profileImageUrl == null) {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: CustomAvatar(imageurl: '', radius: 14),
      ); // Loading or placeholder avatar
    } else {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: CustomAvatar(imageurl: profileImageUrl!,radius: 14,),
      );
    }
  }
}

