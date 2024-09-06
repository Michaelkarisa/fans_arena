import 'package:fans_arena/fans/components/likebuttonfanstv.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/reusablewidgets/firebaseanalytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../appid.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../joint/data/screens/feed_item.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../joint/filming/screens/filmlayout.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/adstrial.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../../reusablewidgets/mpesa.dart';
import '../data/videocontroller.dart';
import 'accountfanviewer.dart';
import 'matchwatch.dart';
class Matchwatch1 extends StatefulWidget {
  EventM event;
  Matchwatch1({super.key,  required this.event});
  @override
  _Matchwatch1State createState() => _Matchwatch1State();
}

class _Matchwatch1State extends State<Matchwatch1> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _stream;
  String url='https://assets.mixkit.co/videos/preview/mixkit-group-of-friends-partying-happily-4640-large.mp4';
  String userId = '';
  String message='';
  late VideoPlayerController controller;

  final VideoControllerProvider _controller=VideoControllerProvider();
  AdProvider ad=AdProvider();
 MatchwatchProvider1 watch=MatchwatchProvider1();
  @override
  void initState() {
    super.initState();
    initializePlayer(url);
    v.getViews("Events", widget.event.eventId);
    watch.toKen(widget.event,);
    Mpesa.setConsumerKey(mConsumerKey);
    Mpesa.setConsumerSecret(mConsumerSecret);
    watch.onpause(widget.event);
    //initAgora();
    watch.goals(widget.event,context);
    watch.onpause1(widget.event,context,ad,v);
    watch.onpause0(widget.event,context);
    watch.getCurrentUser();
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
    ad=AdProvider();
    ad.createInterstitialAd();
    ad.createRewardedAd();
    ad.createRewardedInterstitialAd();
    watch.Streamconnection(widget.event,context);
    watch.checkInternetConnection(context,widget.event);
  }




  bool changed=false;
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
  bool isLoading=false;



  ViewsProvider v=ViewsProvider();

  DateTime _startTime=DateTime.now();


  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    Engagement().engagement('', _startTime, '');
    //EventLogger().screenView('Matchwatch1', 'Matchwatch1', _startTime);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    v.updateWatchhours("Events",widget.event.eventId,isnonet,_startTime);
    controller.dispose();
    watch.dispose();
    super.dispose();
  }

  bool _isPlaying=false;
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
        body: OrientationBuilder(
            builder: (context, orientation) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
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
                                        child: Row(
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
                                      SizedBox(width: 20,),
                                      SizedBox(
                                          height: 20,
                                          width: MediaQuery.of(context).size.width*0.4,
                                          child: OverflowBox(child: Text(widget.event.title,maxLines: 1,
                                            overflow: TextOverflow.ellipsis,style: const TextStyle(color: Colors.white),))),
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
                                                    watch.ispaused?const Icon(Icons.pause, size: 16,color:Colors.white):const Icon(Icons.play_arrow, size: 16,color:Colors.white),
                                                    watch.duration==0? Text("$minutesString:$secondsString",style: const TextStyle(color: Colors.white)):Text("$minutesString1:$secondsString1",style: const TextStyle(color: Colors.white)),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context).size.width*0.2,
                                              height: 20,
                                              child: OverflowBox(
                                                  child: Text(
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    widget.event.location,style: const TextStyle(color: Colors.white),)))
                                        ],
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width*0.132,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                ),
                                child: FloatingActionButton(
                                  foregroundColor:Colors.blue,
                                  backgroundColor:Colors.blue,
                                  onPressed: () async {

                                    EventLogger().logButtonPress('send a gift matchwatch1','perform send gift');
                                    var providedContact =
                                        await watch._showTextInputDialog(context,);
                                    double amount=0.0;
                                    if (providedContact != null) {
                                      if (providedContact.isNotEmpty) {
                                        watch.startCheckout(
                                            userPhone: providedContact,
                                            amount: amount, context: context);
                                      } else {
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
                                  },
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
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
                                        EventLogger().logButtonPress('reportevent', 'show dialogue more_vert');
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
                                    .width * 0.33,
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
                                        },);},
                                        icon: const Icon(Icons.mode_comment_outlined,color: Colors.white,)),
                                   MatchcommentsH(matchId: widget.event.eventId, color: Colors.white, collection: 'Events',),
                                  ],
                                ),
                              ),
                              SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.33,
                                  child: LikeButton0(matchId: widget.event.eventId, isenabled: watch.isenabled, collection: 'Events',),
                              ),
                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.33,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: (){},
                                      child: const Icon(Icons.remove_red_eye_outlined,
                                        color: Colors.blue,),
                                    ),
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
                            ],
                          )
                      )
                  ),

                ],
              );
            }
        ),

      ),
    );}
      );
  }}


class MatchwatchProvider1 extends ChangeNotifier{
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

  bool wDialog = false;
  bool available = true;







  void dialog(EventM event,BuildContext context,String message) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        wDialog = true;
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)),
          title: Center(child: isnonet?const Text('No internet Event paused'):Text(message,style: const TextStyle(color: Colors.black),)),
          actionsAlignment: MainAxisAlignment.center,
          alignment: Alignment.center,
          content: Padding(
            padding: const EdgeInsets.only(right: 7),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: MediaQuery.of(context).size.width*0.24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomAvatar(radius: 19,imageurl: event.user.url,),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Column(
                        children: [
                          InkWell(
                              onTap: () {
                                Navigator.push(context,  MaterialPageRoute(
                                    builder: (context){
                                      if(event.user.collectionName=='Club'){
                                        return AccountclubViewer(user: event.user, fromMatch: true,index: 0);
                                      }else if(event.user.collectionName=='Professional'){
                                        return AccountprofilePviewer(user:event.user,fromMatch: true, index: 0);
                                      }else{
                                        return Accountfanviewer(user:event.user, index: 0);
                                      }
                                    }
                                ),);
                              },
                              child:CustomName(
                                username:event.user.name,
                                maxsize: MediaQuery.of(context).size.width*0.1,
                                style:const TextStyle(color: Colors.black,fontSize: 14),)),
                          InkWell(
                              onTap: () {},
                              child:   CustomName(
                                username: event.user.location,
                                maxsize: MediaQuery.of(context).size.width*0.1,
                                style:const TextStyle(color: Colors.black,fontSize: 14),))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Builder(
                  builder: (BuildContext context) {
                    int minutes = seconds ~/ 60;
                    int remainingSeconds = seconds % 60;
                    String minutesString = minutes.toString().padLeft(2, '0');
                    String secondsString = remainingSeconds.toString().padLeft(2, '0');
                    return SizedBox(
                      height: 20,
                      width: MediaQuery.of(context).size.width*0.2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ispaused?const Icon(Icons.pause, size: 16,):const Icon(Icons.play_arrow, size: 16,),
                          Text("$minutesString:$secondsString"),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    height: 20,
                    child: OverflowBox(
                        child: Center(
                          child: Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              event.location),
                        ))),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.2,
                  height: 35,
                  child: Center(
                    child: TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        wDialog=false;
                        Navigator.pop(context); // Dismiss the dialog
                      },
                    ),
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

  Future<void> getCurrentUser() async {
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

  Future<void> Streamconnection(EventM match,BuildContext context)async{
    Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none && !wDialog) {
        isnonet=true;
        if(available) {
          dialog(match,context,'No internet Event paused');
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
        dty(context,match,'No internet Event paused');
        notifyListeners();
      }else if (result!= ConnectivityResult.none && wDialog) {
        wDialog = false;
        isnonet = false;
        available=true;
        if(state1=="1"&&state2=="1") {
          ispaused = false;
          stopwatch.start();
          fetchTimestampAndStartTimer( matchId:match.eventId,
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
          fetchTimestampAndStartTimer( matchId:match.eventId,
            pausetime:pausetime,
            pausetime1:pausetime1,
            pausetime2:pausetime2,
            pausetime3:pausetime3,
            pausetime4:pausetime4,);
        }
      }
    });
  }


  void dty(BuildContext context,EventM match,String message)async{
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
  Future<void> checkInternetConnection(BuildContext context,EventM match) async {
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
        fetchTimestampAndStartTimer( matchId:match.eventId,
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
        fetchTimestampAndStartTimer( matchId:match.eventId,
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
  void onpause0(EventM match,BuildContext context) {
    _stream1 = _firestore.collection('Events').doc(match.eventId).snapshots();
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

  void onpause1(EventM match,BuildContext context, AdProvider ad,ViewsProvider v) async{
    _stream = _firestore.collection('Events').doc(match.eventId).snapshots();
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
          matchId:match.eventId,
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
          matchId:match.eventId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,
        );
        v.addView("Events",match.eventId,isnonet,_startTime);
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
          matchId:match.eventId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,
        );
        v.addView("Events",match.eventId,isnonet,_startTime);
        notifyListeners();
      }else if (newValue=="1"){
        isenabled = true;
        state1=newValue ?? '';
        state2=newValue1 ?? '';
        notifyListeners();
        fetchTimestampAndStartTimer(
          matchId:match.eventId,
          pausetime:pausetime,
          pausetime1:pausetime1,
          pausetime2:pausetime2,
          pausetime3:pausetime3,
          pausetime4:pausetime4,);
        v.addView("Events",match.eventId,isnonet,_startTime);
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
  void toKen(EventM match)async {
    _stream5 = _firestore.collection('Events').doc(match.eventId).snapshots();
    _stream5.listen((snapshot){
      final newValue = (snapshot.data() as Map<String, dynamic>)['token1'];
      token=newValue??'';
      if(newValue.toString().isNotEmpty){

      }
      notifyListeners();
    });}
  void goals(EventM match,BuildContext context)async {
    _stream2 = _firestore.collection('Events').doc(match.eventId).snapshots();
    _stream2.listen((snapshot) async {
      final newValue2 = (snapshot.data() as Map<String, dynamic>)['message'];
      final newValue3 = (snapshot.data() as Map<String, dynamic>)['eventUrl'];
      message = newValue2??'';
      url = newValue3 ??'';
      url1=newValue3??'';
      //initializePlayer(url1);
      notifyListeners();
    });

  }




  void pop(BuildContext context){
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }







  int activeuser=0;
  void onpause(EventM match) {
    _stream6 = _firestore.collection('Events').doc(match.eventId).snapshots();
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