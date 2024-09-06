import 'package:fans_arena/fans/components/likebuttonfanstv.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/filming/data/filming0.dart';
import 'package:fans_arena/joint/filming/screens/filmlayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../clubs/screens/accountclubviewer.dart';
import '../../../clubs/screens/eventsclubs.dart';
import '../../../clubs/screens/lineupcreation.dart';
import '../../../fans/screens/accountfanviewer.dart';
import '../../../fans/screens/matchwatch.dart';
import '../../../professionals/screens/accountprofilepviewer.dart';
import '../../../reusablewidgets/cirularavatar.dart';
import '../../data/screens/feed_item.dart';
import 'package:sensors_plus/sensors_plus.dart';

class FilmingLayout1 extends StatefulWidget {
  MatchM match;
  FilmingLayout1({super.key, required this.match});
  @override
  _FilmingLayout1State createState() => _FilmingLayout1State();
}

class _FilmingLayout1State extends State<FilmingLayout1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late FilmingProvider film=FilmingProvider();
  LineUpProvider lineup=LineUpProvider();
  ViewsProvider v=ViewsProvider();
  @override
  void initState() {
    super.initState();
    v.getViews("Matches", widget.match.matchId);
    film=FilmingProvider();
    film.uids.clear();
    film.initAgora(userId: FirebaseAuth.instance.currentUser!.uid, matchId: widget.match.matchId, collection: 'Matches');
    film.onPause2(matchId:widget.match.matchId, collection: 'Matches');
    film.onPause0(matchId:widget.match.matchId, collection: 'Matches');
    film.goals(matchId: widget.match.matchId);
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
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  String userId="";
bool en =false;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    film.uidToPeerIdMap.clear();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    film.engine?.disableVideo();
    film.engine?.disableAudio();
    film.uids.clear();
    film.engine?.leaveChannel();
    film.dispose();
    super.dispose();
  }


String match1Id='';

  String authorId='';

  bool isenabled=false;

  String url='';

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
                    UsermainPreview(matchId: widget.match.matchId,userId:userId, collection: 'Matches', authorId:widget.match.authorId,),
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
                            //UsermainPreview(matchId: widget.match.matchId, userId:FirebaseAuth.instance.currentUser!.uid, main: uid, collection: 'Matches', engine: film.engine!,),
                            Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedBuilder(animation: film, builder: (BuildContext context, Widget? child) {
                                return  Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height*0.7,
                                    width: MediaQuery.of(context).size.width*0.25,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                  width: 45,
                                                  child: Text('Home',style: TextStyle(color: Colors.white),)),
                                              Text('${film.score}',style: const TextStyle(color: Colors.white),)
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                  width: 45,
                                                  child: Text('Away',style: TextStyle(color: Colors.white),)),
                                              Text('${film.scor}',style: const TextStyle(color: Colors.white),)
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },  ),
                            ),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 45),
                              child: Align(
                                  alignment: Alignment.bottomRight,
                              child: AnimatedBuilder(animation: film,
                                  builder: (BuildContext context, Widget? child) {
                                return  SizedBox(
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
                            }),  ),
                            ),

                          ],
                        ))),
                    Align(
                        alignment: Alignment.topCenter,
                        child:
                        Container(
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
                                  }, icon: const Icon(Icons.arrow_back,color:Colors.white,size:30)),
                                ),
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.182,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomAvatar( radius:19, imageurl:widget.match.club1.url),
                                      Padding(
                                        padding: const EdgeInsets.only(left:5),
                                        child: SizedBox(
                                          width:MediaQuery.of(context).size.width*0.115,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(context,  MaterialPageRoute(
                                                      builder: (context){
                                                        if(widget.match.club1.collectionName=='Club'){
                                                          return AccountclubViewer(user: widget.match.club1, index: 0);
                                                        }else if(widget.match.club1.collectionName=='Professional'){
                                                          return AccountprofilePviewer(user: widget.match.club1, index: 0);
                                                        }else{
                                                          return Accountfanviewer(user:widget.match.club1, index: 0);
                                                        }
                                                      }
                                                  ),);
                                                },
                                                child:  CustomName(
                                                  username: widget.match.club1.name,
                                                  maxsize: MediaQuery.of(context).size.width*0.115,
                                                  style:const TextStyle(color: Colors.white,fontSize: 14),),),
                                              InkWell(
                                                onTap: () {},
                                                child: CustomName(
                                                  username: widget.match.club1.location,
                                                  maxsize: MediaQuery.of(context).size.width*0.115,
                                                  style:const TextStyle(color: Colors.white,fontSize: 14),),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),


                                Padding(
                                  padding: const EdgeInsets.only(left: 6,right: 6),
                                  child: Container(
                                    width: 30,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color:Colors.white,
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
                                SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.182,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CustomAvatar( radius: 19, imageurl:widget.match.club2.url),
                                      Padding(
                                        padding: const EdgeInsets.only(left:5),
                                        child: SizedBox(
                                          width: MediaQuery.of(context).size.width*0.115,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(context,  MaterialPageRoute(
                                                      builder: (context){
                                                        if(widget.match.club2.collectionName=='Club'){
                                                          return AccountclubViewer(user: widget.match.club2, index: 0);
                                                        }else if(widget.match.club2.collectionName=='Professional'){
                                                          return AccountprofilePviewer(user: widget.match.club2, index: 0);
                                                        }else{
                                                          return Accountfanviewer(user:widget.match.club2, index: 0);
                                                        }
                                                      }
                                                  ),);
                                                },
                                                child:  CustomName(
                                                  username: widget.match.club2.name,
                                                  maxsize: MediaQuery.of(context).size.width*0.115,
                                                  style:const TextStyle(color: Colors.white,fontSize: 14),),),
                                              InkWell(
                                                onTap: () {},
                                                child: CustomName(
                                                  username: widget.match.club2.location,
                                                  maxsize: MediaQuery.of(context).size.width*0.115,
                                                  style:const TextStyle(color: Colors.white,fontSize: 14),),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),


                                SizedBox(
                                  width: MediaQuery.of(context).size.width*0.133,
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
                                          child: Text(widget.match.location,style: const TextStyle(color: Colors.white)))
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
                                                    child: MatchComments(matchId: widget.match.matchId, authorId: authorId,collection:"Matches")),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.4,
                                                  height: MediaQuery.of(context).size.height,
                                                ),
                                              ],
                                            );
                                          },);
                                      },
                                          icon: const Icon(Icons.mode_comment_outlined,color:Colors.white)),
                                      MatchcommentsH(matchId: widget.match.matchId, color: Colors.white,collection:"Matches"),
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
                                        return LikeButton0(matchId: widget.match.matchId, isenabled: film.isenabled, collection: 'Matches',);
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
                                LineUPBTN(match: widget.match,),
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
  }
}
