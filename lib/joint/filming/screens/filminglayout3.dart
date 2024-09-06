import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../clubs/screens/accountclubviewer.dart';
import '../../../clubs/screens/eventsclubs.dart';
import '../../../fans/components/likebuttonfanstv.dart';
import '../../../fans/screens/accountfanviewer.dart';
import '../../../fans/screens/matchwatch.dart';
import '../../../fans/screens/newsfeed.dart';
import '../../../professionals/screens/accountprofilepviewer.dart';
import '../../../reusablewidgets/cirularavatar.dart';
import '../../data/screens/feed_item.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/filming0.dart';
import 'filmlayout.dart';

class FilmingLayout3 extends StatefulWidget {
  EventM event;
  FilmingLayout3({super.key, required this.event});
  @override
  _FilmingLayout3State createState() => _FilmingLayout3State();
}

class _FilmingLayout3State extends State<FilmingLayout3> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
 FilmingProvider film=FilmingProvider();
  ViewsProvider v=ViewsProvider();
  @override
  void initState() {
    super.initState();
    v.getViews("Events", widget.event.eventId);
    film.onPause2(matchId: widget.event.eventId,collection:'Events');
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
    _getCurrentUser();
  }
  String userId = '';
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });

    }
  }
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    film.engine?.disableVideo();
    film.engine?.leaveChannel();
    film.uids.clear();
    film.uidToPeerIdMap.clear();
    film.engine?.disableAudio();
    film.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }


  TextEditingController message1=TextEditingController();
  TextEditingController additionalinfo=TextEditingController();
  String url='';

  bool isstart=false;
  bool ispaused=false;
  int duration=0;

  double radius=19;
  int uid=0;
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
                            //UsermainPreview(matchId: widget.event.eventId,userId:FirebaseAuth.instance.currentUser!.uid, main: uid, collection: 'Events', engine: film.engine!,),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 45),
                              child: Align(
                                  alignment: Alignment.bottomRight,
                              child: AnimatedBuilder(animation: film, builder: (BuildContext context, Widget? child) {
                                return SizedBox(
                                      height: MediaQuery.of(context).size.height*0.5,
                                      width: MediaQuery.of(context).size.width*0.056,
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
                                        ],
                                      ),
                              );
                            }), ),
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
                                                film.ispaused?const Icon(Icons.pause, size: 16,color:Colors.white):const Icon(Icons.play_arrow, size: 16,color:Colors.white),
                                                film.duration==0? Text("$minutesString:$secondsString",style: const TextStyle(color: Colors.white)):Text("$minutesString1:$secondsString1",style: const TextStyle(color: Colors.white)),
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
                                                    child: MatchComments(matchId: widget.event.eventId, authorId:widget.event.user.userId, collection: 'Events',)),
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
                                    child:AnimatedBuilder(
                                      animation:film,
                                      builder: (BuildContext context, Widget? child) {
                                        return LikeButton0(matchId: widget.event.eventId, isenabled:film.isenabled, collection: 'Events',);
                                      },
                                    )
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
