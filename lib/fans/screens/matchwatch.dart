import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/filming/screens/filmlayout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../joint/data/screens/feed_item.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/adstrial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/screens/lineupcreation.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:intl/intl.dart';
import '../../reusablewidgets/firebaseanalytics.dart';
import '../../reusablewidgets/mpesa.dart';
import '../components/likebutton.dart';
import '../components/likebuttonfanstv.dart';
import '../data/videocontroller.dart';
import 'accountfanviewer.dart';
import 'homescreen.dart';
import 'messages.dart';

class Matchwatch extends StatefulWidget {
  MatchM match;

  Matchwatch({super.key,
    required this.match,});
  @override
  _MatchwatchState createState() => _MatchwatchState();
}

class _MatchwatchState extends State<Matchwatch> {
  MatchwatchProvider watch = MatchwatchProvider();
  AdProvider ad = AdProvider();
  ViewsProvider v = ViewsProvider();
  ViewsProvider v1 = ViewsProvider();
  bool active = true;
  String author1Id = '';
  @override
  void initState() {
    super.initState();
    setState(() {
      if(widget.match.authorId==widget.match.club1.userId){
        active =true;
        author1Id=widget.match.club2.userId;
      }else if(widget.match.authorId==widget.match.club2.userId){
        active=false;
        author1Id=widget.match.club1.userId;
      }
    });
    initializePlayer(url);
    v.getViews("Matches", widget.match.matchId);
    watch.otherMatchData(widget.match,);
    watch.toKen(widget.match,);
    watch.retrieveSubstitutes(widget.match,context);
    watch.retrieveSubstitutesAway(widget.match,context);
    Mpesa.setConsumerKey(mConsumerKey);
    Mpesa.setConsumerSecret(mConsumerSecret);
    watch.onpause(widget.match);
    //initAgora();
    watch.goals(widget.match,context);
    watch.onpause1(widget.match,context,ad,v);
    watch.onpause0(widget.match,context);
    watch._getCurrentUser();
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
    watch.Streamconnection(widget.match,context);
    watch.checkInternetConnection(context,widget.match);
  }
  String url1='';
  final VideoControllerProvider _controller = VideoControllerProvider();
  bool _isPlaying = false;
  String url = 'https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
  void switchMatchurl() async {
    if (watch.othermatchstate1 == "1") {
      setState(() {
        url1 =
        'https://res.cloudinary.com/dtwfhkkhm/video/upload/f_auto:video,q_auto/v1/videos/494c34c1-5cad-4ef7-8037-0830ce28e5f1.mp4';
      });
      initializePlayer(url1);
      v.updateWatchhours(
          "Matches", widget.match.matchId, isnonet, _startTime);
      _startTime = DateTime.now();
      v.addView("Matches", widget.match.match1Id, isnonet, _startTime);
    } else {
      setState(() {
      url1 = 'https://res.cloudinary.com/dtwfhkkhm/video/upload/f_auto:video,q_auto/v1/videos/494c34c1-5cad-4ef7-8037-0830ce28e5f1.mp4';
      });
      initializePlayer(url1);
    }
  }
  bool changed=false;
  bool isLoading=true;
  void initializePlayer(String url) async {
    _controller.initialize(url);
    _controller.controller.initialize().then((value) {
      setState(() {
        _controller.controller.play();
        _controller.controller.setVolume(100.0);
        changed = true;
        _isPlaying = true;
        isLoading = false;
      });
    });
    _controller.controller.addListener(() {
      if(_controller.controller.value.isInitialized){
        setState(() {
          if (_controller.controller.value.isBuffering) {
            isLoading=true;
          }else{
            isLoading = false;
          }
        });
        List<DurationRange> buffered=_controller.controller.value.buffered;
      }else{
        setState(() {
          isLoading=true;
        });
      }
      if(_controller.controller.value.isCompleted){

      }
    });
  }


  void _onPlayButtonPressed()async {

    if (_controller.controller.value.isPlaying) {
      setState(() {
        changed =false;
        _controller.controller.pause();
      });
      await  Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _controller.controller.play();
        _isPlaying = true;
        changed =true;
      });
    }
  }
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    if(watch.state1=="1"||watch.othermatchstate1=="1") {
      v.updateWatchhours(
          "Matches", watch.ismatch2 ? widget.match.match1Id : widget.match.matchId,
          isnonet, _startTime);
    }
    _controller.controller.pause();
    _controller.dispose();
    _controller.controller.dispose();
    watch.dispose();
    ad.dispose();
    //EventLogger().screenView('Matchwatch', 'Matchwatch', _startTime!);
    Engagement().engagement('Matchwatch',_startTime,'');
    super.dispose();
  }
  DateTime _startTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return    AnimatedBuilder(
        animation: watch,
        builder: (BuildContext context, Widget? child) {
        return WillPopScope(
          onWillPop: () async {
            if(watch.wDialog) {
              watch.pop(context);
              setState(() {
                watch.wDialog = false;
                watch.available=true;
              });
              return true;
            }else{
              return false;
            }
          },
          child: Scaffold(
                backgroundColor: Colors.black,
                resizeToAvoidBottomInset: false,
                body: OrientationBuilder(
                builder: (context, orientation) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                    // SizedBox(
                    //   height: 0,
                    //   width: 0,
                    //   child: activeuser!=0? AgoraVideoView(
                    //      controller: VideoViewController(
                     //       rtcEngine: _engine,
                      //      canvas:VideoCanvas(uid: activeuser),
                      //    ),
                     //   ):const Center(child: CircularProgressIndicator(color:Colors.white),),
                    // ),
                      AnimatedBuilder(
                        animation:_controller,
                        builder: (BuildContext context, Widget? child) {
                          return  Container(
                            color: Colors.transparent,
                            height: MediaQuery.of(context).size.height,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ((_controller.controller==null)
                                    ? const SizedBox.shrink(): AspectRatio(
                                  aspectRatio: _controller.controller.value.aspectRatio,
                                  child: GestureDetector(
                                    onTap: _onPlayButtonPressed,
                                    child: VideoPlayer(_controller.controller),
                                  ),
                                )

                                ),
                               isLoading||_controller.controller==null? const Center(
                                    child: CircularProgressIndicator(color: Colors.white)):const SizedBox.shrink(),
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    opacity: changed ? 0.0 : 1.0,
                                    duration: const Duration(milliseconds: 500),
                                    child: Align(
                                      alignment: const Alignment(0.0,0.0),
                                      child: IconButton(
                                        icon:_isPlaying ? const Icon(Icons.pause, size: 50,color: Colors.white,): const Icon(Icons.play_arrow, size: 50,color: Colors.white,),
                                        onPressed: _onPlayButtonPressed,
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          );
                        },
                      ),
                      Align(
                          alignment: Alignment.topCenter,
                          child:
                          Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              height: 42,
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(onPressed: () {
                                    Navigator.of(context).pop();
                                  }, icon: const Icon(Icons.arrow_back,color: Colors.white,size:30)),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: SizedBox(
                                      height: 42,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: SizedBox(
                                              child: Row(
                                                children: [
                                                  CustomAvatar( radius:19, imageurl:widget.match.club1.url),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left:5),
                                                    child: SizedBox(
                                                      width: MediaQuery.of(context).size.width*0.21,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                Navigator.push(context,  MaterialPageRoute(
                                                                    builder: (context){
                                                                      if(widget.match.club1.collectionName=='Club'){
                                                                        return AccountclubViewer(user: widget.match.club1, fromMatch: true,index: 0);
                                                                      }else if(widget.match.club1.collectionName=='Professional'){
                                                                        return AccountprofilePviewer(user: widget.match.club1, fromMatch: true,index: 0);
                                                                      }else{
                                                                        return Accountfanviewer(user:widget.match.club1, index: 0);
                                                                      }
                                                                    }
                                                                ),);
                                                              },
                                                              child:  CustomName(
                                                                username: widget.match.club1.name,
                                                                maxsize: MediaQuery.of(context).size.width*0.21,
                                                                style:const TextStyle(color: Colors.white,fontSize: 14),),),
                                                          InkWell(
                                                              onTap: () {},
                                                              child: CustomName(
                                                                username: widget.match.club1.location,
                                                                maxsize: MediaQuery.of(context).size.width*0.21,
                                                                style:const TextStyle(color: Colors.white,fontSize: 14),),)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),

                                          AnimatedBuilder(animation: watch,
                                            builder: (BuildContext context, Widget? child) {
                                              return  FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: SizedBox(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: InkWell(
                                                            onTap: (){
                                                             watch.scorersD(widget.match,context);
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius
                                                                      .circular(5),
                                                                  border: Border.all(
                                                                      width: 1,
                                                                      color: Colors.black
                                                                  )
                                                              ),
                                                              child: Center(child: Padding(
                                                                padding: const EdgeInsets.only(left: 6,right: 6),
                                                                child: Text('${watch.score1}',style: const TextStyle(color: Colors.black),),
                                                              )),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 2,right: 2),
                                                          child: Container(
                                                            width: 30,
                                                            height: 35,
                                                            decoration: BoxDecoration(
                                                                color: Colors.white,
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
                                                        FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: InkWell(
                                                            onTap: (){
                                                              watch.scorersD(widget.match,context);
                                                            },
                                                            child: Container(
                                                              height: 30,
                                                              decoration: BoxDecoration(
                                                                  color: Colors.white,
                                                                  borderRadius: BorderRadius
                                                                      .circular(5),
                                                                  border: Border.all(
                                                                      width: 1,
                                                                      color: Colors.black
                                                                  )
                                                              ),
                                                              child: Center(child: Padding(
                                                                padding: const EdgeInsets.only(left: 6,right: 6),
                                                                child: Text('${watch.score2}',style: const TextStyle(color: Colors.black),),
                                                              )),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                              );
                                            },),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: SizedBox(
                                                child: Row(
                                                  children: [
                                                    CustomAvatar( radius: 19, imageurl:widget.match.club2.url),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left:5),
                                                      child: SizedBox(
                                                        width: MediaQuery.of(context).size.width*0.21,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                Navigator.push(context,  MaterialPageRoute(
                                                                    builder: (context){
                                                                      if(widget.match.club2.collectionName=='Club'){
                                                                        return AccountclubViewer(user: widget.match.club2, fromMatch: true,index: 0);
                                                                      }else if(widget.match.club2.collectionName=='Professional'){
                                                                        return AccountprofilePviewer(user: widget.match.club2, fromMatch: true,index: 0);
                                                                      }else{
                                                                        return Accountfanviewer(user:widget.match.club2, index: 0);
                                                                      }
                                                                    }
                                                                ),);
                                                              },
                                                              child:  CustomName(
                                                                username: widget.match.club2.name,
                                                                maxsize: MediaQuery.of(context).size.width*0.21,
                                                                style:const TextStyle(color: Colors.white,fontSize: 14),),),
                                                            InkWell(
                                                              onTap: () {},
                                                              child: CustomName(
                                                                username: widget.match.club2.location,
                                                                maxsize: MediaQuery.of(context).size.width*0.21,
                                                                style:const TextStyle(color: Colors.white,fontSize: 14),),)
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),


                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              AnimatedBuilder(
                                                animation: watch,
                                                builder: (BuildContext context, Widget? child) {
                                                  int minutes1 = watch.duration ~/ 60;
                                                  int remainingSeconds1 = watch.duration % 60;

                                                  String minutesString1 = minutes1.toString().padLeft(2, '0');
                                                  String secondsString1 = remainingSeconds1.toString().padLeft(2, '0');
                                                  int minutes = watch.seconds ~/ 60;
                                                  int remainingSeconds = watch.seconds % 60;

                                                  String minutesString = minutes.toString().padLeft(2, '0');
                                                  String secondsString = remainingSeconds.toString().padLeft(2, '0');
                                                  return  SizedBox(
                                                    height: 20,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        watch.ispaused?const Icon(Icons.play_arrow, size: 16,color:Colors.white):const Icon(Icons.pause, size: 16,color:Colors.white),
                                                        watch.duration==0? Text("$minutesString:$secondsString",style: const TextStyle(color: Colors.white)):Text("$minutesString1:$secondsString1",style: const TextStyle(color: Colors.white)),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.18,
                                                height: 20,
                                                child: OverflowBox(
                                                    child: Text(
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      widget.match.location,style: const TextStyle(color: Colors.white),)))
                                            ],
                                          ),

                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 35,
                                  width: MediaQuery.of(context).size.width*0.13,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      shape: BoxShape.rectangle,
                                    ),
                                    child: FloatingActionButton(
                                      foregroundColor:Colors.blue,
                                      backgroundColor:Colors.blue,
                                      onPressed: ()async {

                                        EventLogger().logButtonPress('send a gift matchwatch','perform send gift');
                                        var providedContact =
                                        await watch._showTextInputDialog(context,);
                                              double amount=0.0;
                                        if (providedContact != null) {
                                          if (providedContact.isNotEmpty) {
                                            watch.startCheckout(
                                                userPhone: providedContact,
                                                amount: amount, context: context);
                                          } else {
                                            watch.alert(context);
                                          }
                                        }

                                      },
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10.0), // Adjust the value to control the button's oval shape
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Send a Gift',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 35,
                                    width: MediaQuery.of(context).size.width*0.06,
                                    child: Center(
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                          onPressed: (){
                                          EventLogger().logButtonPress('reportmatch', 'show dialogue more_vert');
                                          watch.reportmatch(context);
                                      }, icon: const Icon(Icons.more_vert,color: Colors.white,)),
                                    ),
                                  )
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
                                  .width,
                              height: 40,
                              color: Colors.transparent,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(onPressed: () {
                                          EventLogger().logButtonPress('matchwatchcommet', 'open comment bottomsheet');
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
                                                      child:watch.ismatch2?MatchComments(
                                                        matchId: widget.match.match1Id,
                                                        authorId: author1Id, collection: 'Matches',): MatchComments(
                                                        matchId: widget.match.matchId,
                                                        authorId: widget.match.authorId, collection: 'Matches',)),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width*0.4,
                                                    height: MediaQuery.of(context).size.height,
                                                  ),
                                                ],
                                              );
                                            },);
                                        },
                                            icon: const Icon(Icons.mode_comment_outlined,color: Colors.white,)),
                                        MatchcommentsH(matchId: watch.ismatch2?widget.match.match1Id:widget.match.matchId, color: Colors.white, collection: 'Matches',)
                                      ],
                                    ),
                                  ),

                                  SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.2,
                                    child:Center(
                                      child:  LikeButton0(collection: 'Matches',
                                        matchId:watch.ismatch2?widget.match.match1Id:widget.match.matchId, isenabled: watch.isenabled,)
                                    )
                                  ),
                                  SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.remove_red_eye_outlined,
                                          color: Colors.blue,),
                                        watch.ismatch2? AnimatedBuilder(
                                            animation: v1,
                                            builder: (BuildContext context, Widget? child) {
                                              return
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                                                  child: LikesCountWidget(totalLikes: v1.views.length,),
                                                );}): AnimatedBuilder(
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
                                  PopupMenuButton<String>(
                                    padding:  const EdgeInsets.only(left:6,right: 6),
                                    position: PopupMenuPosition.over,
                                    icon: const Icon(Icons.arrow_drop_up,color: Colors.white,size: 38,),
                                    onSelected: (value) async {
                                      if(_controller.controller.value.isPlaying) {
                                        _controller.controller.pause();
                                      }
                                      if(value==widget.match.authorId){
                                        if(watch.state1=="1") {
                                          await v.updateWatchhours("Matches",widget.match.match1Id,isnonet,_startTime!);
                                         _startTime = DateTime.now();
                                        }
                                        initializePlayer(url);
                                        if(widget.match.club1.userId==value){
                                          setState(() {
                                            watch.ismatch2=false;
                                            active =true;
                                          });
                                        }else{
                                          setState(() {
                                            watch.ismatch2=false;
                                            active =false;
                                          });
                                        }
                                      }else {
                                        if(widget.match.club1.userId==value){
                                          setState(() {
                                            watch.ismatch2=true;
                                            active =true;
                                          });
                                        }else{
                                          setState(() {
                                            watch.ismatch2=true;
                                            active =false;
                                          });
                                        }
                                        v1.getViews("Matches", widget.match.match1Id);
                                        switchMatchurl();
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                         PopupMenuItem<String>(
                                          value:widget.match.club1.userId,
                                          child: Text('Home',style: TextStyle(color: active?Colors.blue:Colors.black),),
                                        ),
                                        PopupMenuItem<String>(
                                          value:widget.match.club2.userId,
                                          child:  Text('Away',style: TextStyle(color: active?Colors.black:Colors.blue),),
                                        ),
                                      ];
                                    },
                                  ),
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.2,
                                      child: Center(child: TextButton(onPressed: (){
                                        watch.scorersD(widget.match,context);}, child: Text('Scorers',style:TextStyle(color: Colors.white))))),
                                  SizedBox(
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.2,
                                      child: Center(child:LineUPBTN(match: widget.match,)))
                                ],
                              )
                          )
                      ),
                    ],
                  );
                }),
            ),
        );
      }
    );
}}


class ScorerDialog extends StatefulWidget {
  String home;
  String away;
  String homeclub;
  String awayclub;
  List<Map<String, dynamic>> hscorers;
  List<Map<String, dynamic>> ascorers;
  void Function() setavailable;
  ScorerDialog({super.key,
    required this.away,
    required this.home,
    required this.homeclub,
    required this.awayclub,
    required this.ascorers,
    required this.hscorers,required this.setavailable});

  @override
  State<ScorerDialog> createState() => _ScorerDialogState();
}

class _ScorerDialogState extends State<ScorerDialog> {
  bool isHome=true;
  @override
  Widget build(BuildContext context){
      return AlertDialog(
        alignment: Alignment.center,
        title:  Center(child: Text('${isHome?widget.homeclub:widget.awayclub} Match Scorers')),
        content:isHome?Container(
          child: widget.hscorers.isEmpty?const SizedBox(
              height: 60,
              child: Center(child: Text('No Scorers'))): DataTable(
            columnSpacing: MediaQuery.of(context).size.width*0.03,
            columns: const [
              DataColumn(label: Text('Rank')),
              DataColumn(label: Text("Player")),
              DataColumn(label: Text('Time')),
              DataColumn(label: Text('Goals')),
              // Add more DataColumn widgets for additional fields
            ],
            rows: widget.hscorers.map((data) {
              int index = widget.hscorers.indexOf(data);
              int time = data['time'] ?? 0;
              int goal = data['goal'] ?? 0;
              int minutes = time ~/ 60;
              int remainingSeconds = time % 60;
              String minutesString = minutes.toString().padLeft(2, '0');
              String secondsString = remainingSeconds.toString().padLeft(2, '0');
              return DataRow(cells: [
                DataCell(Center(child: Text('${index +1}'))),
                DataCell(CustomNameAvatar(userId:data['userId'], style: const TextStyle(color:Colors.black), radius: 18, maxsize: 120,)),
                DataCell(Center(child: Text("$minutesString:$secondsString"))),
                DataCell(Center(child: Text('$goal'))),
                // Add more DataCell widgets for additional fields
              ]);
            }).toList(),
          ),
        ):Container( child: widget.ascorers.isEmpty?const SizedBox(
            height: 60,
            child: Center(child: Text('No Scorers'))): DataTable(
          columnSpacing: MediaQuery.of(context).size.width*0.03,
          columns: const [
            DataColumn(label: Text('Rank')),
            DataColumn(label: Text("Player")),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Goals')),
            // Add more DataColumn widgets for additional fields
          ],
          rows: widget.ascorers.map((data) {
            int index = widget.ascorers.indexOf(data);
            int time = data['time'] ?? 0;
            int goal = data['goal'] ?? 0;
            int minutes = time ~/ 60;
            int remainingSeconds = time % 60;
            String minutesString = minutes.toString().padLeft(2, '0');
            String secondsString = remainingSeconds.toString().padLeft(2, '0');
            return DataRow(cells: [
              DataCell(Center(child: Text('${index +1}'))),
              DataCell(CustomNameAvatar(userId:data['userId'], style: const TextStyle(color:Colors.black), radius: 18, maxsize: 120,)),
              DataCell(Center(child: Text("$minutesString:$secondsString"))),
              DataCell(Center(child: Text('$goal'))),
              // Add more DataCell widgets for additional fields
            ]);
          }).toList(),
        )),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed:(){
                setState(() {
                  isHome=true;
                });
              }
              , child: const Text('home')),
              TextButton(onPressed:widget.setavailable
                  , child: const Text('dismis')),
              TextButton(onPressed:(){
                setState(() {
                  isHome=false;
                });
              }
              , child: const Text('away'))
            ],
          )
        ],
      );
  }
}




class LikeButton0 extends StatefulWidget {
  String matchId;
  bool isenabled;
  String collection;
  LikeButton0({super.key,
    required this.matchId,
  required this.isenabled,
    required this.collection});

  @override
  _LikeButton0State createState() => _LikeButton0State();
}

class _LikeButton0State extends State<LikeButton0> {
  late LikingProvider liking=LikingProvider();
  @override
  void initState() {
    super.initState();
    liking.getAllikes(widget.collection, widget.matchId);
  }

  @override
  void didUpdateWidget(covariant LikeButton0 oldWidget) {
    if (oldWidget.matchId != widget.matchId) {
      liking.getAllikes(widget.collection, widget.matchId);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    liking.likes.clear();
    super.dispose();
  }
  void d(){
    
}
  @override
  Widget build(BuildContext context) {
      return AnimatedBuilder(animation: liking,
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
        width: MediaQuery.of(context).size.width*0.089,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                if(widget.isenabled) {
                  setState(() {
                    liking.liked = !liking.liked;
                  });
                  if (liking.liked) {
                    liking.addlike(widget.collection, widget.matchId,);
                  } else {
                    liking.removelike(widget.collection, widget.matchId,);
                  }
                }
              },
              icon: liking.liked
                  ? const Icon(
                Icons.thumb_up_off_alt_rounded,
                color: Colors.blue,
                size: 25,
              )
                  : const Icon(
                Icons.thumb_up_off_alt,
                size: 25,
                color: Colors.white,
              ),
            ),
            LikesCountWidget1(totalLikes:liking.likes.length,)
          ],
        ),
      );});
  }
}


class LineUPBTN extends StatefulWidget {
 MatchM match;
  LineUPBTN({super.key,
    required this.match,
 });

  @override
  State<LineUPBTN> createState() => _LineUPBTNState();
}

class _LineUPBTNState extends State<LineUPBTN> {

  @override
  Widget build(BuildContext context) {
      if (widget.match.club1.collectionName =='Fan') {
        return const SizedBox(width: 0,height: 0,);
      }else if(widget.match.club1.collectionName =='Professional'){
        return TextButton(onPressed: (){}, child: const Text('Stats'));
      }else if(widget.match.club1.collectionName =='Club'){
        return TextButton(onPressed: () {
          EventLogger().logButtonPress('matchwatch lineup', 'show  lineup bottomsheet');
          showCupertinoModalPopup(
              barrierDismissible: false,
              context: context, builder: (context){
            return Material(
              color: Colors.transparent,
              child: Container(
                width:MediaQuery.of(context).size.width*0.952,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                height:MediaQuery.of(context).size.height*0.976,
                child: Lineup1(match:widget.match),
              ),
            );
          });
        }, child: const Padding(
          padding: EdgeInsets.only(right: 10),
          child: Text('Line up'),
        ));
      }
      else{
        return const SizedBox(width: 0,height: 0,);
      }
  }
}

class MatchwatchProvider extends ChangeNotifier {
  String url = 'https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
  int seconds = 0;
  bool ispaused = false;
  bool isstart = false;
  bool isenabled = false;
  bool isanimation = false;
  int score1 = 0;
  int score2 = 0;
  String time = '';
  String message = '';
  String resumetime = '';
  String pausetime = '';
  int duration = 0;
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  void startTimerFromTimestamp(int timestampDifference) {
    stopwatch.start();
    timer = Timer.periodic(const Duration(microseconds: 1), (_) {
      seconds = stopwatch.elapsed.inSeconds + timestampDifference;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> fetchTimestampAndStartTimer(
      {required String matchId, required String pausetime, required String pausetime1, required String pausetime2, required String pausetime3, required String pausetime4}) async {
    DocumentSnapshot timestampSnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .doc(matchId)
        .get();

    if (timestampSnapshot.exists && pausetime.isEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(startTime);
      int timestampDifference = difference.inSeconds;
      seconds = timestampDifference;
      startTimerFromTimestamp(timestampDifference);
      print('$timestampDifference');
      notifyListeners();
    } else if (timestampSnapshot.exists && pausetime.isNotEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      Duration difference = startTime1.difference(startTime);
      int timestampDifference = difference.inSeconds;
      DateTime currentTime = DateTime.now();
      Duration difference1 = currentTime.difference(startTime2);
      int timestampDifference1 = difference1.inSeconds;
      int t = timestampDifference + timestampDifference1;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    } else if (timestampSnapshot.exists && pausetime1.isNotEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      DateTime currentTime = DateTime.now();
      Duration difference2 = currentTime.difference(startTime4);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int t = timestampDifference + timestampDifference1 + timestampDifference2;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    } else if (timestampSnapshot.exists && pausetime2.isNotEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      Timestamp timestampFromFirebase5 = timestampSnapshot['pausetime2'] as Timestamp;
      Timestamp timestampFromFirebase6 = timestampSnapshot['resumetime2'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      DateTime startTime5 = timestampFromFirebase5.toDate();
      DateTime startTime6 = timestampFromFirebase6.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      Duration difference2 = startTime5.difference(startTime4);
      DateTime currentTime = DateTime.now();
      Duration difference3 = currentTime.difference(startTime6);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int timestampDifference3 = difference3.inSeconds;
      int t = timestampDifference + timestampDifference1 +
          timestampDifference2 + timestampDifference3;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    } else if (timestampSnapshot.exists && pausetime3.isNotEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      Timestamp timestampFromFirebase5 = timestampSnapshot['pausetime2'] as Timestamp;
      Timestamp timestampFromFirebase6 = timestampSnapshot['resumetime2'] as Timestamp;
      Timestamp timestampFromFirebase7 = timestampSnapshot['pausetime3'] as Timestamp;
      Timestamp timestampFromFirebase8 = timestampSnapshot['resumetime3'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      DateTime startTime5 = timestampFromFirebase5.toDate();
      DateTime startTime6 = timestampFromFirebase6.toDate();
      DateTime startTime7 = timestampFromFirebase7.toDate();
      DateTime startTime8 = timestampFromFirebase8.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      Duration difference2 = startTime5.difference(startTime4);
      Duration difference3 = startTime7.difference(startTime6);
      DateTime currentTime = DateTime.now();
      Duration difference4 = currentTime.difference(startTime8);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int timestampDifference3 = difference3.inSeconds;
      int timestampDifference4 = difference4.inSeconds;
      int t = timestampDifference + timestampDifference1 +
          timestampDifference2 + timestampDifference3 + timestampDifference4;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    } else if (timestampSnapshot.exists && pausetime4.isNotEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      Timestamp timestampFromFirebase5 = timestampSnapshot['pausetime2'] as Timestamp;
      Timestamp timestampFromFirebase6 = timestampSnapshot['resumetime2'] as Timestamp;
      Timestamp timestampFromFirebase7 = timestampSnapshot['pausetime3'] as Timestamp;
      Timestamp timestampFromFirebase8 = timestampSnapshot['resumetime3'] as Timestamp;
      Timestamp timestampFromFirebase9 = timestampSnapshot['pausetime4'] as Timestamp;
      Timestamp timestampFromFirebase10 = timestampSnapshot['resumetime4'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      DateTime startTime5 = timestampFromFirebase5.toDate();
      DateTime startTime6 = timestampFromFirebase6.toDate();
      DateTime startTime7 = timestampFromFirebase7.toDate();
      DateTime startTime8 = timestampFromFirebase8.toDate();
      DateTime startTime9 = timestampFromFirebase9.toDate();
      DateTime startTime10 = timestampFromFirebase10.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      Duration difference2 = startTime5.difference(startTime4);
      Duration difference3 = startTime7.difference(startTime6);
      Duration difference4 = startTime9.difference(startTime8);
      DateTime currentTime = DateTime.now();
      Duration difference5 = currentTime.difference(startTime10);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int timestampDifference3 = difference3.inSeconds;
      int timestampDifference4 = difference4.inSeconds;
      int timestampDifference5 = difference5.inSeconds;
      int t = timestampDifference + timestampDifference1 +
          timestampDifference2 + timestampDifference3 + timestampDifference4 +
          timestampDifference5;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    }
    notifyListeners();
  }


 bool subDialog = false;
  bool wDialog = false;
  bool available = true;
  bool scoreDialog= false;
  void dialog2(List<Map<String, dynamic>> players, bool home,BuildContext context,MatchM match) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          subDialog = true;
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              title: Center(child: Text(home
                  ? 'Substitute ${match.club1.name}'
                  : 'Substitute ${match.club2.name}')),
              content: SizedBox(
                  height: 150,
                  child: ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        if (player['sub'] == 'in') {
                          final teamId = player['userId'];
                          final identity = player['identity'];
                          final time = player['time'];
                          return Column(
                              children: [
                                const Center(child: Text('In', style: TextStyle(
                                    fontWeight: FontWeight.bold),)),
                                Row(
                                  children: [
                                    CustomAvatarM(userId: teamId,
                                      radius: radius1,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: CustomNameM(userId: teamId,
                                          style: const TextStyle(fontSize: 14),
                                          maxsize: 70),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text('Identity: $identity'),
                                    Text('Time: $time'),
                                  ],
                                ),
                              ]);
                        } else if (player['sub'] == 'out') {
                          final teamId = player['userId'];
                          final identity = player['identity'];
                          final time = player['time'];
                          return Column(
                              children: [
                                const Center(
                                    child: Text('Out', style: TextStyle(
                                        fontWeight: FontWeight.bold),)),
                                Row(
                                  children: [
                                    CustomAvatarM(
                                      userId: teamId, radius: radius1,),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: CustomNameM(userId: teamId,
                                          style: const TextStyle(fontSize: 14),
                                          maxsize: 70),
                                    ),
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Text('Identity: $identity'),
                                    Text('Time: $time'),
                                  ],
                                ),
                              ]);
                        }
                      })
              ))
          ;
        }
    );
  }


  void scorersD(MatchM match, BuildContext context) async {
    if (!available) {
      return;
    } else {
      if (match.match1Id.isEmpty) {
          match.match1Id = 'N';
        notifyListeners();
      }
      List<Map<String, dynamic>> hscorers = [];
      List<Map<String, dynamic>> ascorers = [];
      final home = match.authorId == match.club1.userId ? match.matchId :match.match1Id;
      final away = match.authorId == match.club2.userId ? match.matchId : match.match1Id;
      QuerySnapshot querySnapshot = await firestore
          .collection('Matches')
          .doc(home)
          .collection('scorers').get();
      List<QueryDocumentSnapshot>documents = querySnapshot.docs;
      for (final document in documents) {
        List<Map<String, dynamic>> scorers1 = List<Map<String, dynamic>>.from(
            document['scorers']);
        hscorers.addAll(scorers1);
      }
      QuerySnapshot querySnapshot1 = await firestore
          .collection('Matches')
          .doc(away)
          .collection('scorers').get();
      List<QueryDocumentSnapshot>documents1 = querySnapshot1.docs;
      for (final document in documents1) {
        List<Map<String, dynamic>> scorers1 = List<Map<String, dynamic>>.from(
            document['scorers']);
        ascorers.addAll(scorers1);
      }
      scorersDialog(
          away: away,
          home: home,
          ascorers: ascorers,
          hscorers: hscorers, context: context, match: match);
    }
    notifyListeners();
  }

  void scorersDialog({
    required String away,
    required String home,
    required List<Map<String, dynamic>> ascorers,
    required List<Map<String, dynamic>> hscorers,
    required BuildContext context,
    required MatchM match
  }) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        available = false;
        return ScorerDialog(
          away: away,
          home: home,
          homeclub: match.club1.name,
          awayclub: match.club2.name,
          ascorers: ascorers,
          hscorers: hscorers,
          setavailable: () {
            Navigator.pop(context);
              available = true;
            notifyListeners();
          },
        );
      },
    );
  }

  void dialog1(MatchM match,BuildContext context,String score1,String score2) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            content: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      child: Row(
                        children: [
                          CustomAvatar(radius: 19, imageurl:match.club1
                              .url,),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                CustomName(
                                  username: match.club1.name,
                                  maxsize: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.1,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),),
                                CustomName(
                                  username: match.club1.location,
                                  maxsize: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.1,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Builder(
                    builder: (BuildContext context,) {
                      return SizedBox(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment
                                .spaceEvenly,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius
                                          .circular(5),
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                      )
                                  ),
                                  child: Center(child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, right: 6),
                                    child: Text('$score1'),
                                  )),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 2, right: 2),
                                child: Container(
                                  width: 30,
                                  height: 35,
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
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius
                                          .circular(5),
                                      border: Border.all(
                                          width: 1,
                                          color: Colors.black
                                      )
                                  ),
                                  child: Center(child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 6, right: 6),
                                    child: Text('$score2'),
                                  )),
                                ),
                              ),
                            ],
                          ));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 7),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      child: Row(
                        children: [
                          CustomAvatar(radius: 19, imageurl:match.club2.url,),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                CustomName(
                                  username: match.club2.name,
                                  maxsize: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.1,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),),
                                CustomName(
                                  username: match.club2.location,
                                  maxsize: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.1,
                                  style: const TextStyle(
                                      color: Colors.black, fontSize: 14),),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  void dialog(MatchM match,BuildContext context,String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        wDialog = true;
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          title: Center(
              child:  Text(
                message, style: const TextStyle(color: Colors.black),)),
          actionsAlignment: MainAxisAlignment.center,
          alignment: Alignment.center,
          content: Builder(
            builder: (BuildContext context) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        children: [
                          CustomAvatar(
                            radius: 19, imageurl: match.club1.url,),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(
                                          builder: (context) {
                                            if (match.club1
                                                .collectionName == 'Club') {
                                              return AccountclubViewer(
                                                  user: match.club1,
                                                  index: 0);
                                            } else if (match.club1
                                                .collectionName ==
                                                'Professional') {
                                              return AccountprofilePviewer(
                                                  user: match.club1,
                                                  index: 0);
                                            } else {
                                              return Accountfanviewer(
                                                  user: match.club1,
                                                  index: 0);
                                            }
                                          }
                                      ),);
                                    },
                                    child: CustomName(
                                      username: match.club1.name,
                                      maxsize: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.1,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),)),
                                InkWell(
                                    onTap: () {},
                                    child: CustomName(
                                      username: match.club1.location,
                                      maxsize: MediaQuery
                                          .of(context)
                                          .size
                                          .width * 0.1,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 14),))
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceEvenly,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius
                                        .circular(5),
                                    border: Border.all(
                                        width: 1,
                                        color: Colors.black
                                    )
                                ),
                                child: Center(child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6),
                                  child: Text('$score1'),
                                )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 2),
                              child: Container(
                                width: 30,
                                height: 35,
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
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius
                                        .circular(5),
                                    border: Border.all(
                                        width: 1,
                                        color: Colors.black
                                    )
                                ),
                                child: Center(child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6),
                                  child: Text('$score2'),
                                )),
                              ),
                            ),
                          ],
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        child: Row(
                          children: [
                            CustomAvatar(
                              radius: 19, imageurl: match.club2.url,),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context, MaterialPageRoute(
                                            builder: (context) {
                                              if (match.club2
                                                  .collectionName == 'Club') {
                                                return AccountclubViewer(
                                                    user: match.club2,
                                                    index: 0);
                                              } else if (match.club2
                                                  .collectionName ==
                                                  'Professional') {
                                                return AccountprofilePviewer(
                                                    user: match.club2,
                                                    index: 0);
                                              } else {
                                                return Accountfanviewer(
                                                    user: match.club2,
                                                    index: 0);
                                              }
                                            }
                                        ),);
                                      },
                                      child: CustomName(
                                        username: match.club2.name,
                                        maxsize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.1,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14),)),
                                  InkWell(
                                      onTap: () {},
                                      child: CustomName(
                                        username: match.club2.location,
                                        maxsize: MediaQuery
                                            .of(context)
                                            .size
                                            .width * 0.1,
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14),))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              );
            },
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ispaused
                          ? const Icon(Icons.play_arrow, size: 16,)
                          : const Icon(Icons.pause, size: 16,),
                      Builder(
                        builder: (BuildContext context) {
                          int minutes = seconds ~/ 60;
                          int remainingSeconds = seconds % 60;
                          String minutesString = minutes.toString().padLeft(2,
                              '0');
                          String secondsString = remainingSeconds.toString()
                              .padLeft(2, '0');
                          return Text("$minutesString:$secondsString");
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.2,
                    height: 20,
                    child: OverflowBox(
                        child: Center(
                          child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              match.location),
                        ))),
                SizedBox(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.2,
                  height: 35,
                  child: Center(
                    child:LineUPBTN(match:match,)
                  ),
                ),
              ],
            )

          ],
        );
      },
    );
  }


  DateTime _startTime = DateTime.now();
  String url1 = '';
  String userId = '';
  String match1Id = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
        userId = user.uid;
        notifyListeners();
    }
  }

  double radius1 = 15;
  bool ismatch2 = false;
  String authorId = '';
  String token = '';

  String othermatchstate1 = "0";

  void otherMatchData(MatchM match) async {
    _stream7 =
        _firestore.collection('Matches').doc(match.match1Id).snapshots();
    _stream7.listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
          othermatchstate1 = data['state1'] ?? "0";
          url1 = data['matchUrl'] ??
              'https://res.cloudinary.com/dtwfhkkhm/video/upload/f_auto:video,q_auto/v1/videos/494c34c1-5cad-4ef7-8037-0830ce28e5f1.mp4';
       notifyListeners();
      }
    });
  }

Future<void> Streamconnection(MatchM match,BuildContext context)async{
  Connectivity().onConnectivityChanged.listen((result) {
  if (result == ConnectivityResult.none && !wDialog) {
  isnonet=true;
  if(available) {
  dialog(match,context,'No internet Match paused');
  available=false;
  }
  if(state1=="1"&&state2=="1") {
  ispaused=true;
  stopwatch.stop();
  }
  notifyListeners();
  }else if (result==ConnectivityResult.none && wDialog) {
  wDialog = true;
  isnonet = true;
  available=true;
  dty(context,match,'No internet Match paused');
  notifyListeners();
  }else if (result!= ConnectivityResult.none && wDialog) {
  wDialog = false;
  isnonet = false;
  available=true;
  if(state1=="1"&&state2=="1") {
  ispaused = false;
  stopwatch.start();
  fetchTimestampAndStartTimer( matchId:match.matchId,
  pausetime:pausetime,
  pausetime1:pausetime1,
  pausetime2:pausetime2,
  pausetime3:pausetime3,
  pausetime4:pausetime4,);
  pop(context);
  }else {
  dty(context,match,message);
  }
  }else if (result!= ConnectivityResult.none&&!wDialog) {
  isnonet = false;
  if(state1=="1"&&state2=="1") {
  ispaused = false;
  stopwatch.start();
  fetchTimestampAndStartTimer( matchId:match.matchId,
  pausetime:pausetime,
  pausetime1:pausetime1,
  pausetime2:pausetime2,
  pausetime3:pausetime3,
  pausetime4:pausetime4,);
  }
  }
  });
}


  void dty(BuildContext context,MatchM match,String message)async{
    pop(context);
    await Future.delayed(const Duration(seconds: 1),(){});
    if(available) {
      dialog(match,context,message);
        available=false;
        wDialog=true;
      notifyListeners();
    }
    notifyListeners();
  }



  bool isnonet=false;
  List<ConnectivityResult> result=[];
  Future<void> checkInternetConnection(BuildContext context,MatchM match) async {
    final cResult = await Connectivity().checkConnectivity();
    result = cResult;
    if (result == ConnectivityResult.none && !wDialog) {
        isnonet=true;
      if(available) {
        dialog(match,context,'No internet Match paused');
          available=false;
        notifyListeners();
      }
        notifyListeners();
      if(state1=="1"&&state2=="1") {
          ispaused=true;
       stopwatch.stop();
          notifyListeners();
      }
    }else if (result!= ConnectivityResult.none && wDialog) {
        wDialog = false;
        isnonet = false;
        available=true;
      if(state1=="1"&&state2=="1") {
          ispaused = false;
        stopwatch.start();
        fetchTimestampAndStartTimer( matchId:match.matchId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,);
        pop(context);
          notifyListeners();
      }else {
        dty(context,match,message);
        notifyListeners();
      }
        notifyListeners();
    } else if (result!= ConnectivityResult.none&&!wDialog) {
        isnonet = false;
      if(state1=="1"&&state2=="1") {
          ispaused = false;
        stopwatch.start();
       fetchTimestampAndStartTimer( matchId:match.matchId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,);
          notifyListeners();
      }
    }
    notifyListeners();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _stream;
  late Stream<DocumentSnapshot> _stream1;
  late Stream<DocumentSnapshot> _stream2;
  late Stream<DocumentSnapshot> _stream5;
  late Stream<DocumentSnapshot> _stream6;
  late Stream<DocumentSnapshot> _stream7;
  String state1='';
  String state2='';
  String pausetime1='';
  String pausetime2='';
  String pausetime3='';
  String pausetime4='';
  String stoptime='';
  void onpause0(MatchM match,BuildContext context) {
    _stream1 = _firestore.collection('Matches').doc(match.matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue = (snapshot.data() as Map<String, dynamic>)['pausetime'] as Timestamp;
      Timestamp newValue0 = (snapshot.data() as Map<String, dynamic>)['pausetime1']as Timestamp;
      Timestamp newValue2 = (snapshot.data() as Map<String, dynamic>)['pausetime2']as Timestamp;
      Timestamp newValue3 = (snapshot.data() as Map<String, dynamic>)['pausetime3']as Timestamp;
      Timestamp newValue4 = (snapshot.data() as Map<String, dynamic>)['pausetime4']as Timestamp;
      Timestamp newValue5 = (snapshot.data() as Map<String, dynamic>)['stoptime']as Timestamp;
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['duration'];
        DateTime createdDateTime = newValue.toDate();
        pausetime = DateFormat('d MMM').format(createdDateTime);
        DateTime createdDateTime1 = newValue0.toDate();
        pausetime1 = DateFormat('d MMM').format(createdDateTime1);
        DateTime createdDateTime2 = newValue2.toDate();
        pausetime2 = DateFormat('d MMM').format(createdDateTime2);
        DateTime createdDateTime3 = newValue3.toDate();
        pausetime3 = DateFormat('d MMM').format(createdDateTime3);
        DateTime createdDateTime4 = newValue4.toDate();
        pausetime4 = DateFormat('d MMM').format(createdDateTime4);
        DateTime createdDateTime5 = newValue5.toDate();
        stoptime = DateFormat('d MMM').format(createdDateTime5);
        duration=newValue1 ?? 0;
      notifyListeners();
    } );

  }
  bool isdialog=false;

  void onpause1(MatchM match,BuildContext context, AdProvider ad,ViewsProvider v) async{
    _stream = _firestore.collection('Matches').doc(match.matchId).snapshots();
    _stream.listen((snapshot) async {
      final newValue = (snapshot.data() as Map<String, dynamic>)['state1'];
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['state2'];
      final newValue2 = (snapshot.data() as Map<String, dynamic>)['message'];
      if (newValue == "0" && newValue1 =="0" && !wDialog) {
        if(available) {
          dialog(match,context,newValue2??'');
            available=false;
          notifyListeners();
        }
          ispaused=true;
          isenabled=false;
          wDialog = true;
          state1=newValue ?? '';
          state2=newValue1 ?? '';
       stopwatch.stop();
        notifyListeners();
      } else if (newValue == "1" && newValue1 =="0" && !wDialog) {
        _startTime = DateTime.now();
        if(available) {
          dialog(match,context,newValue2??'');
            available=false;
          notifyListeners();
        }
        ad.showInterstitialAd();
          isenabled=true;
          ispaused=true;
          wDialog = true;
          state1=newValue ?? '';
          state2=newValue1 ?? '';
        fetchTimestampAndStartTimer(
          matchId:match.matchId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,
        ).then((value) => stopwatch.stop());
        notifyListeners();
        await Future.delayed(const Duration(microseconds: 100),(){});
        stopwatch.stop();
        notifyListeners();
      } else if (newValue == "1" &&newValue1=="1" &&wDialog) {
          available=true;
          ispaused = false;
          isenabled = true;
          wDialog = false;
          state1=newValue ?? '';
          state2=newValue1 ?? '';
          notifyListeners();
        _startTime = DateTime.now();
        fetchTimestampAndStartTimer(
          matchId:match.matchId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,
        );
        v.addView("Matches",match.matchId,isnonet,_startTime);
        pop(context);
          notifyListeners();
      }else if (newValue=="1"&&newValue1=="1"){
          ispaused = false;
          isenabled = true;
          state1=newValue ?? '';
          state2=newValue1 ?? '';
          notifyListeners();
        _startTime = DateTime.now();
        fetchTimestampAndStartTimer(
          matchId:match.matchId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,
        );
        v.addView("Matches",match.matchId,isnonet,_startTime);
          notifyListeners();
      }else if (newValue=="1"){
          isenabled = true;
          state1=newValue ?? '';
          state2=newValue1 ?? '';
          notifyListeners();
      fetchTimestampAndStartTimer(
          matchId:match.matchId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,);
        v.addView("Matches",match.matchId,isnonet,_startTime);
          notifyListeners();
      }else{
          ispaused=true;
          isenabled=false;
          wDialog = false;
          state1=newValue ?? '';
          state2=newValue1 ?? '';
          notifyListeners();
      }
      notifyListeners();
    });
    notifyListeners();
  }
  void toKen(MatchM match)async {
    _stream5 = _firestore.collection('Matches').doc(match.matchId).snapshots();
    _stream5.listen((snapshot){
      final newValue = (snapshot.data() as Map<String, dynamic>)['token1'];
        token=newValue??'';
      if(newValue.toString().isNotEmpty){

      }
      notifyListeners();
    });}
  void goals(MatchM match,BuildContext context)async {
    _stream2 = _firestore.collection('Matches').doc(match.matchId).snapshots();
    _stream2.listen((snapshot) async {
      final newValue = (snapshot.data() as Map<String, dynamic>)['score1'];
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['score2'];
      final newValue2 = (snapshot.data() as Map<String, dynamic>)['message'];
      final newValue3 = (snapshot.data() as Map<String, dynamic>)['matchUrl'];
      if(score1==0&&score2==0){
        score1 = newValue ?? 0;
        score2 = newValue1 ?? 0;
      }else{
      if ( score1 != newValue||score2 != newValue1) {
          score1 = newValue ?? 0;
          score2 = newValue1 ?? 0;
        if(available) {
          dialog1(match,context,score1.toString(),score2.toString());
            available = false;
          await Future.delayed(const Duration(seconds: 4), () {});
            available = true;
          pop(context);
          notifyListeners();
        }
      }}
        message = newValue2??'';
        url = newValue3 ??'';
        url1=newValue3??'';
        //initializePlayer(url1);
      notifyListeners();
    });

  }

  List<Map<String, dynamic>> allHomePlayers = [];
  List<Map<String, dynamic>> allHomeSubs= [];
  List<Map<String, dynamic>> allAwayPlayers = [];
  List<Map<String, dynamic>> allAwaySubs = [];
  late Stream<DocumentSnapshot> _stream3;
  late Stream<DocumentSnapshot> _stream4;

  void retrieveSubstitutes(MatchM match, BuildContext context) {
    final home = match.authorId == match.club1.userId ? match.matchId : match.match1Id;
    _stream4 = _firestore
        .collection('Matches')
        .doc(home)
        .collection('Players')
        .doc(match.club1.userId)
        .snapshots();
    _stream4.listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(data['players']);
          List<Map<String, dynamic>> dataList1 = List<Map<String, dynamic>>.from(data['subs']);
          if (allHomePlayers.isNotEmpty && allHomeSubs.isNotEmpty) {
            List<Map<String, dynamic>> subin = [];
            List<Map<String, dynamic>> subout = [];
            for (var item in dataList) {
              final userId = item['userId'];
              bool existsInAllHomePlayers = allHomePlayers.any((element) => element['userId'] == userId);
              if (!existsInAllHomePlayers) {
                subin.add({
                  'userId': item['userId'],
                  'identity': item['identity'],
                  'time': item['time'],
                  'sub': 'in',
                });
              }
            }
            notifyListeners();
            for (var item in dataList1) {
              final userId = item['userId'];
              bool existsInAllHomeSubs = allHomeSubs.any((element) => element['userId'] == userId);
              if (!existsInAllHomeSubs) {
                await Future.delayed(const Duration(milliseconds: 10));
                subout.add({
                  'userId': item['userId'],
                  'identity': item['identity'],
                  'time': item['time'],
                  'sub': 'out',
                });
              }
            }
            notifyListeners();
            if(subin.isNotEmpty&&subout.isNotEmpty) {
              if(available) {
                available=false;
                dialog2([...subin, ...subout], true, context, match);
                await Future.delayed(const Duration(seconds: 5));
                pop(context);
                available = true;
                notifyListeners();
              }
              allHomePlayers = List<Map<String, dynamic>>.from(data['players']);
              allHomeSubs = List<Map<String, dynamic>>.from(data['subs']);
              notifyListeners();
            }
            notifyListeners();
          }else{
           allHomePlayers = List<Map<String, dynamic>>.from(data['players']);
            allHomeSubs = List<Map<String, dynamic>>.from(data['subs']);
            notifyListeners();
          }
        }
      }
    });
  }

  void pop(BuildContext context){
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }


  void retrieveSubstitutesAway(MatchM match,BuildContext context) {
    final away =match.authorId==match.club2.userId?match.matchId:match.match1Id;
    _stream3 = _firestore
        .collection('Matches')
        .doc(away)
        .collection('Players')
        .doc(match.club2.userId)
        .snapshots();
    _stream3.listen((snapshot) async {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<Map<String, dynamic>> dataList = List<Map<String, dynamic>>.from(data['players']);
          List<Map<String, dynamic>> dataList1 = List<Map<String, dynamic>>.from(data['subs']);
          if (allAwayPlayers.isNotEmpty && allAwaySubs.isNotEmpty) {
            List<Map<String, dynamic>> subin = [];
            List<Map<String, dynamic>> subout = [];
            for (var item in dataList) {
              final userId = item['userId'];
              bool existsInAllHomePlayers = allAwayPlayers.any((element) => element['userId'] == userId);
              if (!existsInAllHomePlayers) {
                subin.add({
                  'userId': item['userId'],
                  'identity': item['identity'],
                  'time': item['time'],
                  'sub': 'in',
                });
              }
            }
            notifyListeners();
            for (var item in dataList1) {
              final userId = item['userId'];
              bool existsInAllHomeSubs = allAwaySubs.any((element) => element['userId'] == userId);
              if (!existsInAllHomeSubs) {
                await Future.delayed(const Duration(milliseconds: 10));
                subout.add({
                  'userId': item['userId'],
                  'identity': item['identity'],
                  'time': item['time'],
                  'sub': 'out',
                });
              }
            }
            notifyListeners();
            if(subin.isNotEmpty&&subout.isNotEmpty) {
              if(available) {
                available=false;
                dialog2([...subin, ...subout], true, context, match);
                await Future.delayed(const Duration(seconds: 5));
                pop(context);
                available = true;
                notifyListeners();
              }
              allAwayPlayers = List<Map<String, dynamic>>.from(data['players']);
              allAwaySubs = List<Map<String, dynamic>>.from(data['subs']);
              notifyListeners();
            }
            notifyListeners();
          }else{
            allAwayPlayers = List<Map<String, dynamic>>.from(data['players']);
            allAwaySubs = List<Map<String, dynamic>>.from(data['subs']);
            notifyListeners();
          }
        }
      }
    });
  }




  int activeuser=0;
  void onpause(MatchM match) {
    _stream6 = _firestore.collection('Matches').doc(match.matchId).snapshots();
    _stream6.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['activeuser'];
        activeuser = newValue??0;
      notifyListeners();
    });
  }

  TextEditingController message1=TextEditingController();

  String mPasskey = 'bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919';

  Future<void> startCheckout(
      {required String userPhone, required double amount,required BuildContext context}) async {
    dynamic transactionInitialisation;
    try {
      transactionInitialisation =
      await Mpesa.initializeMpesaSTKPush(
          businessShortCode: "174379",
          transactionType: TransactionType.CustomerBuyGoodsOnline,
          amount: amount,
          partyA: userPhone,
          partyB: "174379",
          callBackURL: Uri(
              scheme: "https", host: "1234.1234.co.ke", path: "/1234.php"),
          accountReference: "shoe",
          phoneNumber: userPhone,
          baseUri: Uri(scheme: "https", host: "sandbox.safaricom.co.ke"),
          transactionDesc: "purchase",
          passKey: mPasskey);
      print("TRANSACTION RESULT: $transactionInitialisation");
      //You can check sample parsing here -> https://github.com/keronei/Mobile-Demos/blob/mpesa-flutter-client-app/lib/main.dart
      return transactionInitialisation;
    } catch (e) {
      dialoge(e.toString(),context);
    }
  }
  void dialoge(String e,BuildContext context){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text('an error occured:$e'),
      );
    });
  }
  List<Map<String, dynamic>> itemsOnSale = [
    {
      "image": "image/shoe.jpg",
      "itemName": "Breathable Oxford Casual Shoes",
      "price": 800.0
    }
  ];
  final _textFieldController = TextEditingController();
  final _textFieldController1 = TextEditingController();
  bool done=false;
  bool done1=false;
  bool lab1=false;
  bool lab=false;
  int val=0;
  int val1=0;
  Future<String?> _showTextInputDialog(BuildContext context,) async {
    return showModalBottomSheet(
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return  Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: Colors.white,
                        height:MediaQuery.of(context).size.height*0.65 ,
                        width: MediaQuery.of(context).size.width*0.45,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('Send a Gift',style:  TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                              const Text('The amount you will contribute will help to sustain the clubs motivation.'),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: _textFieldController,
                                  decoration:  InputDecoration(labelText: 'Enter phone number',
                                      labelStyle: TextStyle(color: lab?Colors.red:Colors.black),
                                      suffix:done?const Icon(Icons.done,color: Colors.green,):Text('$val/10',style: const TextStyle(fontSize: 10),)),
                                  onChanged: (value){
                                    if(value.length>9){
                                        done=true;
                                        val=value.length;
                                     notifyListeners();
                                    }else if(value.length<9){
                                        done=false;
                                        val=value.length;
                                        notifyListeners();
                                    }
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  focusNode: FocusNode(),
                                  keyboardType: TextInputType.number,
                                  controller: _textFieldController1,
                                  decoration:  InputDecoration(labelText: 'Enter Amount',
                                      labelStyle: TextStyle(color: lab1?Colors.red:Colors.black),
                                      suffix:done1?const Icon(Icons.close,color: Colors.red,):const Text('',style: TextStyle(fontSize: 10),)),
                                  onChanged: (value){
                                    double amount =double.tryParse(_textFieldController1.text)??0.0;
                                    if(amount==0.0){
                                        done1=true;
                                        val1=value.length;
                                        notifyListeners();
                                    }else if(amount>0.0){
                                        done1=false;
                                        notifyListeners();
                                    }
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    child: const Text("Cancel"),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  const SizedBox(width: 50,),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(_textFieldController.text.isEmpty&&_textFieldController1.text.isEmpty?Colors.white24:Colors.blue),
                                    ),
                                    child: const Text('Proceed'),
                                    onPressed: () async {
                                      double amount =double.tryParse(_textFieldController1.text)??0;
                                      String userPhone = _textFieldController.text;
                                      if (userPhone.startsWith('0')) {
                                        userPhone = '254${userPhone.substring(1)}';
                                      }
                                      if(_textFieldController1.text.isEmpty&_textFieldController.text.isEmpty) {
                                          lab=true;
                                          lab1=true;
                                          notifyListeners();
                                      }else if(_textFieldController1.text.isEmpty){
                                          lab1=true;
                                          notifyListeners();
                                      }else if(_textFieldController.text.isEmpty){
                                          lab=true;
                                          notifyListeners();
                                      }else{
                                          lab=false;
                                          lab1=false;
                                          notifyListeners();
                                        await startCheckout(
                                            userPhone: userPhone, amount: amount, context: context);
                                      }

                                    },
                                  ),
                                ],
                              ),

                            ],
                          ),
                        ),)
                  )
              )
          );
        });
  }
  void reportmatch(BuildContext context){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Report match'),
            content: const Text(
                "Report match for any misconduct ie. integrity, honesty and any unethical behaviour against societal norms."),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: const Text("Cancel"),
                    onPressed: () =>
                        Navigator.pop(context),
                  ),
                  ElevatedButton(
                    child: const Text("Proceed"),
                    onPressed: () =>
                        Navigator.pop(context),
                  ),
                ],
              ),
            ],
          );
        });
  }
  void alert(BuildContext context){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Empty Number!'),
            content: const Text(
                "You did not provide a number to be charged."),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () =>
                    Navigator.pop(context),
              ),
            ],
          );
        });
  }

}
