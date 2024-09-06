import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/components/likebuttonfanstv.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/messages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../clubs/screens/accountclubviewer.dart';
import '../../../clubs/screens/eventsclubs.dart';
import '../../../clubs/screens/lineupcreation.dart';
import '../../../fans/screens/accountfanviewer.dart';
import '../../../fans/screens/matchwatch.dart';
import '../../../fans/screens/newsfeed.dart';
import '../../../professionals/screens/accountprofilepviewer.dart';
import '../../../reusablewidgets/cirularavatar.dart';
import '../../../reusablewidgets/firebaseanalytics.dart';
import '../../data/screens/feed_item.dart';
import '../data/filming0.dart';
import 'filmlayout2.dart';
class FilmingLayout extends StatefulWidget {
  MatchM match;
  FilmingLayout({super.key,
    required this.match,});
  @override
  _FilmingLayoutState createState() => _FilmingLayoutState();
}

class _FilmingLayoutState extends State<FilmingLayout> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FilmingProvider film=FilmingProvider();
   String collectionName='';
  bool isLoading = true;

  Newsfeedservice news = Newsfeedservice();
  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collectionName = prefs.getString('cname')?? '';
    collectionName = prefs.getString('cname')?? '';
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      isLoading=false;
      if (user != null) {
        userId = user.uid;
      }
    });
  }
   LineUpProvider lineup=LineUpProvider();
  ViewsProvider v=ViewsProvider();
  @override
  void initState() {
    super.initState();
    v.getViews("Matches", widget.match.matchId);
    retrieveUsername1();
    lineup.retrieveCPlayers(matchId: widget.match.matchId,userId: FirebaseAuth.instance.currentUser!.uid);
    _getCurrentUser();
    setState(() {
      score=widget.match.score1;
      scor=widget.match.score2;
    });
    onpause0(matchId: widget.match.matchId);
    pauseTime(matchId: widget.match.matchId);
    pauseTime1(matchId: widget.match.matchId);
    pauseTime2(matchId: widget.match.matchId);
    pauseTime3(matchId: widget.match.matchId);
    pauseTime4(matchId: widget.match.matchId);
    stopTime(matchId: widget.match.matchId);
    film.onPause2(matchId:widget.match.matchId, collection: 'Matches');
    film.onPause0(matchId:widget.match.matchId, collection: 'Matches');
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
String match1Id='';
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<void> postresults() async {

  }

  String authorId='';



  void postMatch1() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("${widget.match.club1.collectionName}s")
          .doc(userId)
          .collection('matchestreamed')
          .where('matchId', isEqualTo: widget.match.matchId)
          .limit(1)
          .get();
      if (querySnapshot.docs.isEmpty) {
        Timestamp createdAt = Timestamp.now();
        FirebaseFirestore.instance
            .collection('Clubs')
            .doc(userId)
            .collection('matchestreamed')
            .add({
          'matchId': widget.match.matchId,
          'authorId': userId,
          'createdAt': createdAt,
        });
        postresults();
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  late Stream<DocumentSnapshot> _stream1;
  void pauseTime({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue = (snapshot.data() as Map<String, dynamic>)['pausetime'];
      setState(() {
        DateTime createdDateTime = newValue.toDate();
        pausetime = DateFormat('d MMM').format(createdDateTime);
      });
    });}
  void pauseTime1({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue0 = (snapshot.data() as Map<String, dynamic>)['pausetime1'];
      setState(() {
        DateTime createdDateTime1 = newValue0.toDate();
        pausetime1 = DateFormat('d MMM').format(createdDateTime1);
      });

    });}
  void pauseTime2({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue2 = (snapshot.data() as Map<String, dynamic>)['pausetime2'];
      setState(() {
        DateTime createdDateTime2 = newValue2.toDate();
        pausetime2 = DateFormat('d MMM').format(createdDateTime2);
      });
    });}
  void pauseTime3({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue3 = (snapshot.data() as Map<String, dynamic>)['pausetime3'];
      setState(() {
        DateTime createdDateTime3 = newValue3.toDate();
        pausetime3 = DateFormat('d MMM').format(createdDateTime3);
      });
    });}
  void pauseTime4({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue4 = (snapshot.data() as Map<String, dynamic>)['pausetime4'];
      setState(() {
        DateTime createdDateTime4 = newValue4.toDate();
        pausetime4 = DateFormat('d MMM').format(createdDateTime4);
      });
    });}
  void stopTime({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue5 = (snapshot.data() as Map<String, dynamic>)['stoptime'];
      setState(() {
        DateTime createdDateTime5 = newValue5.toDate();
        stoptime = DateFormat('d MMM').format(createdDateTime5);
      });

    });}
  void onpause0({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['duration'];
      setState(() {
        duration=newValue1 ?? 0;
      });

    });
  }
  List<String>years=[];
  Future<void> retrieveUsername1() async {
    QuerySnapshot querysnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.match.league.userId)
        .collection('year')
        .orderBy('timestamp',descending: true)
        .get();

    if (querysnapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot>documents=querysnapshot.docs;
      for(final document in documents){
        years.add(document.id);
      }
    }
  }
  Future<void> saveDataToFirestore1(String state) async {
    try {
      CollectionReference collection = FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.match.league.userId)
          .collection('year')
          .doc(years.first)
          .collection('leaguematches');
      QuerySnapshot querySnapshot = await collection.get();
      for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
        List<dynamic> clubsteam = documentSnapshot['matches'];
        int indexToUpdate = -1;
        for (int i = 0; i < clubsteam.length; i++) {
          if (clubsteam[i]['matchId'] == leaguematchId) {
            indexToUpdate = i;
            break;
          }
        }
        if (indexToUpdate != -1) {
            clubsteam[indexToUpdate]['status'] =state;
          await documentSnapshot.reference.update({'matches': clubsteam});
          break;
        }
      }
    } catch (e) {
      print('Error updating role: $e');
    }
  }
  String pausetime='';
  String pausetime1='';
  String pausetime2='';
  String pausetime3='';
  String pausetime4='';
  String resumetime='';
  int seconds=0;
  int duration=0;
  String stoptime='';
  Future<void> updateScores() async {
    try {
      int newScore1 = int.tryParse(score1.text) ?? 0;
      int newScore2 = int.tryParse(score2.text) ?? 0;
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
          .get();

      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (score1.text.isNotEmpty && newScore1 != oldData['score1']) {
          newData['score1'] = newScore1;
          setState(() {
            score = newScore1;
          });
        }
        if (score2.text.isNotEmpty && newScore2 != oldData['score2']) {
          newData['score2'] = newScore2;
          setState(() {
            scor = newScore2;
          });
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          score1.clear();
          score2.clear();
          if(FirebaseAuth.instance.currentUser!.uid==widget.match.club1.userId) {
            await getPlayers();
          }else if(FirebaseAuth.instance.currentUser!.uid==widget.match.club2.userId){
            await getPlayers();
          }
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

  Future<void> addScorer(String postId, String userId, int time,int goal) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Matches')
        .doc(postId)
        .collection('scorers');
    final like = {'userId': userId, 'time': time,'goal':goal};
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          final DocumentSnapshot latestDoc = documents.first;
          final List<Map<String, dynamic>>? chats = (latestDoc['scorers'] as List?)
              ?.cast<Map<String, dynamic>>();
          if (chats != null) {
            if (chats.length < 12000) {
              chats.add(like);
              transaction.update(latestDoc.reference, {'scorers': chats});
            } else {
              likesCollection.add({'scorers': [like]});
            }
          }
        } else {
          likesCollection.add({'scorers': [like]});
        }
      });
  }
Future<void>getPlayers()async{
  showDialog(context: context, builder: (context){
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)),
      title: const Text('Players list'),
      content:AnimatedBuilder(
          animation: lineup,
          builder: (BuildContext context, Widget? child) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: lineup.players.where((p)=>p.appusage.card=="0"||p.appusage.card==Colors.yellow.value.toString()).map<Widget>((player){
                return Padding(
                  padding: const EdgeInsets.only(top:5,bottom: 5),
                  child: InkWell(
                    onTap:(){
                      addScorer(widget.match.matchId, player.appusage.userId, film.seconds, 1);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomAvatar(imageurl: player.url, radius: 16,),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: TexT(name:player.name),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(player.appusage.identity),
                        )
                      ],
                    ),
                  ),
                );
              }).toList() ,
            ),
          );
        }
      ) ,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: const Text('dismiss'))
          ],
        )
      ],
    );
  });
}
  void resumeMatch() async {
    try {
     DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
          .get();

      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        Timestamp createdAt = Timestamp.now();
        if ("1" != oldData['state2']) {
          newData['state2'] = "1";
        }
        if ( pausetime.isNotEmpty&&createdAt != oldData['resumetime']) {
          newData['resumetime'] = createdAt;
        }
        if ( pausetime1.isNotEmpty&&createdAt != oldData['resumetime1']) {
          newData['resumetime1'] = createdAt;
        }
        if ( pausetime2.isNotEmpty&&createdAt != oldData['resumetime2']) {
          newData['resumetime2'] = createdAt;
        }
        if ( pausetime3.isNotEmpty&&createdAt != oldData['resumetime3']) {
          newData['resumetime3'] = createdAt;
        }
        if ( pausetime4.isNotEmpty&&createdAt != oldData['resumetime4']) {
          newData['resumetime4'] = createdAt;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
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
  void pauseMatch() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
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
        if ( pausetime.isEmpty&&createdAt != oldData['pausetime']) {
          newData['pausetime'] = createdAt;
        }
        if (pausetime.isNotEmpty&& createdAt != oldData['pausetime1']) {
          newData['pausetime1'] = createdAt;
        }
        if (pausetime1.isNotEmpty&& createdAt != oldData['pausetime2']) {
          newData['pausetime2'] = createdAt;
        }
        if (pausetime2.isNotEmpty&& createdAt != oldData['pausetime3']) {
          newData['pausetime3'] = createdAt;
        }
        if (pausetime3.isNotEmpty&& createdAt != oldData['pausetime4']) {
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
  Future<void> startMatch() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
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
                  Text("Starting match")
              ],),
            ),
          ));
          await documentSnapshot.reference.update(newData);
          await film.updateUrls(matchId: widget.match.matchId,collection: "Matches");
          await film.streamToSocialMedia(widget.match.matchId,"Matches",FirebaseAuth.instance.currentUser!.uid);
          saveDataToFirestore1('1');
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(Duration(seconds: 1));
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: Text("Match started")),
            ),
          ));
          await Future.delayed(Duration(seconds: 1));
          Navigator.of(context,rootNavigator: true).pop();
        } else {
        }
      } else {
      }
    } catch (e) {
      //print('Error saving data: $e');
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(e.toString()),
        );
      });
    }
  }


  Future<void> stopMatch() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
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
        if ( film.seconds != oldData['duration']) {
          newData['duration'] = film.seconds;
        }
        if (newData.isNotEmpty) {
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text("Stopping match")
                ],),
            ),
          ));
          await documentSnapshot.reference.update(newData);
          await film.deleteRtmpConverter();
          saveDataToFirestore1('0');
          postMatch1();
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(Duration(seconds: 1));
          showDialog(context: context, builder: (context)=>AlertDialog(
            content: SizedBox(
              height: 80,
              child: Center(child: Text("Match stopped")),
            ),
          ));
          await Future.delayed(Duration(seconds: 1));
          Navigator.of(context,rootNavigator: true).pop();
        } else {
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(e.toString()),
        );
      });
    }
  }



  TextEditingController score1=TextEditingController();
  TextEditingController message1=TextEditingController();
  TextEditingController score2=TextEditingController();
  TextEditingController additionalinfo=TextEditingController();
  String url='';
  int score=0;
  int scor=0;
  String leaguematchId='';
  String status='0';
  String userId = '';
  String message= '';
  void ad()async{
    setState(() {
      updateScores();
      Navigator.pop(context);
    });
  }
  void ad1()async{
    setState(() {
      updateScores();
      Navigator.pop(context);
    });
  }

  void post2(){
    pauseMatch();
    Navigator.of(context).pop();
  }

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

                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: SizedBox(
                                  height: MediaQuery.of(context).size.height*0.7,
                                  width: MediaQuery.of(context).size.width*0.25,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: (){
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
                                                return Padding(
                                                  padding: const EdgeInsets.only(left: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Container(
                                                        color: Colors.white,
                                                        height: 35,
                                                        width: MediaQuery.of(context).size.width*0.2,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              height: 35,
                                                              width: MediaQuery.of(context).size.width*0.122,
                                                              child: TextFormField(
                                                                controller: score1,
                                                                keyboardType: TextInputType.number,
                                                                decoration: const InputDecoration(
                                                                    hintText: 'home score',
                                                                    fillColor: Colors.white,
                                                                    filled: true,
                                                                    hintStyle: TextStyle(color: Colors.black)
                                                                ),),
                                                            ),
                                                            TextButton(onPressed: ad, child: const Text('post'))
                                                          ],),
                                                      ),
                                                    ),

                                                  ),
                                                );});
                                        },
                                        child: SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                  width: 45,
                                                  child: Text('Home',style: TextStyle(color: Colors.white),)),
                                              Text('$score',style: const TextStyle(color: Colors.white),)
                                            ],
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: (){
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
                                                return Padding(
                                                  padding: const EdgeInsets.only(left: 20),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Container(
                                                        color: Colors.white,
                                                        height: 35,
                                                        width: MediaQuery.of(context).size.width*0.2,
                                                        child: Row(
                                                          children: [
                                                            SizedBox(
                                                              height: 35,
                                                              width: MediaQuery.of(context).size.width*0.122,
                                                              child: TextFormField(
                                                                controller: score2,
                                                                keyboardType: TextInputType.number,
                                                                decoration: const InputDecoration(
                                                                    hintText: 'Away score',
                                                                    fillColor: Colors.white,
                                                                    filled: true,
                                                                    hintStyle: TextStyle(color: Colors.black)
                                                                ),),
                                                            ),
                                                            TextButton(onPressed: ad1, child: const Text('post'))
                                                          ],),
                                                      ),
                                                    ),

                                                  ),
                                                );});
                                        },
                                        child: SizedBox(
                                          height: 30,
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                  width: 45,
                                                  child: Text('Away',style: TextStyle(color: Colors.white),)),
                                              Text('$scor',style: const TextStyle(color: Colors.white),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                                                      title: const Text('Quit Match streaming'),
                                                      content: const Text('Do you want to quit match streaming'),
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
                                                                                          hintText: 'eg.full time',
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
                                                                                    stopMatch();
                                                                                  }
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
                                              }, icon: const Icon(Icons.stop,color: Colors.white,size: 35,)):IconButton(onPressed:()=>startMatch(),icon: const Icon(Icons.fiber_manual_record,color: Colors.white,size: 35,),)),

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
                                            }, icon: const Icon(Icons.pause,color: Colors.white,size: 35,)):IconButton(onPressed:resumeMatch,icon:const Icon(Icons.play_arrow,color: Colors.white,size: 35,)),
                                          ),

                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                        )
                    ),
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
                                                    child: MatchComments(matchId: widget.match.matchId, authorId:authorId, collection: 'Matches',)),
                                                SizedBox(
                                                  width: MediaQuery.of(context).size.width*0.4,
                                                  height: MediaQuery.of(context).size.height,
                                                ),
                                              ],
                                            );
                                          },);
                                      },
                                          icon: const Icon(Icons.mode_comment_outlined,color:Colors.white)),
                                      MatchcommentsH(matchId: widget.match.matchId, color: Colors.white, collection: 'Matches',),
                                    ],
                                  ),
                                ),

                                SizedBox(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.12,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width*0.089,
                                      child: LikeButton0(
                                        matchId:widget.match.matchId, isenabled: false, collection: 'Matches',),
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
                                AnimatedBuilder(
                                  animation: film,
                                  builder: (BuildContext context, Widget? child) {
                                    return  LayoutBuilder(builder: (context,BuildContext) {
                                      if(isLoading){
                                        return SizedBox(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.12,
                                        );
                                      }else if (collectionName =='Fan') {
                                        return const SizedBox(width: 0,height: 0,);
                                      }else if(collectionName =='Professional'){
                                        return TextButton(onPressed: (){}, child: const Text('Stats'));
                                      }else if(collectionName =='Club'){
                                        return TextButton(onPressed: () {
                                          EventLogger().logButtonPress('filmlayout lineup', 'show  lineup bottomsheet');
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
                                                child: Lineup(seconds:film.seconds,match: widget.match,state1: film.state1,),
                                              ),
                                            );
                                          });
                                        }, child: const Text('Line up'));
                                      }
                                      else{
                                        return const SizedBox(width: 0,height: 0,);}}  );
                                  },
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



class MatchComments extends StatefulWidget {
  final String matchId;
  final String authorId;
  final String collection;
  const MatchComments({super.key,
    required this.matchId,
    required this.authorId,
    required this.collection});

  @override
  State<MatchComments> createState() => _MatchCommentsState();
}

class _MatchCommentsState extends State<MatchComments> {
  @override
  void initState() {
    super.initState();
    onpause1();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _stream;
  bool isstart=false;
  void onpause1() {
    _stream = _firestore.collection(widget.collection).doc(widget.matchId).snapshots();
    _stream.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['state1'];
      setState((){
      if (newValue == "0" ) {
        isstart=false;
      } else if (newValue == "1") {
        isstart=true;
      }});
    });
  }


  TextEditingController comment =TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> _commentPost() async {
    await SendComments().commentPost(docId: widget.matchId,
        authorId: widget.authorId,
        message: "",
        comment: comment,
        collection:widget.collection);
    setState(() {
      comment.clear();
    });
  }


  double radius=19;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (BuildContext context, ScrollController ) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(topLeft:Radius.circular(15),topRight: Radius.circular(15)),
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Comments',style: TextStyle(color: Colors.black),),
                  Padding(
                    padding: const EdgeInsets.only(left: 5,top: 5),
                    child: MatchcommentsH(matchId: widget.matchId, color: Colors.black, collection: widget.collection,),
                  )
                ],
              ),
              automaticallyImplyLeading: false,
              leading: IconButton(onPressed: (){
                Navigator.pop(context);
              }, icon: const Icon(Icons.close,color: Colors.black,)),
            ),
            body: Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Comment>>(
                      future:DataFetcher().getcommentdata(docId: widget.matchId, collection:widget.collection, subcollection: 'comments'),
                      builder: (context, snapshot){
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('No comments')); // Handle case where there are no likes
                        } else {
                          List<Comment>matches=snapshot.data!;
                            matches .sort((a, b) {
                              Timestamp adate = a.timestamp;
                              Timestamp bdate = b.timestamp;
                              return adate.compareTo(bdate);
                            });
                          return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: matches.length,
                            itemBuilder: (BuildContext context, int index) {
                              final comments=matches[index];
                              DateTime createdDateTime = comments.timestamp.toDate();
                              DateTime now = DateTime.now();
                              Duration difference = now.difference(createdDateTime);
                              String formattedTime = '';
                              if (difference.inSeconds == 1) {
                                formattedTime = 'now';
                              } else if (difference.inSeconds < 60) {
                                formattedTime = 'now';
                              } else if (difference.inMinutes ==1) {
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
                                formattedTime = '${difference.inDays ~/ 7} week ago';
                              } else {
                                formattedTime = DateFormat('d MMM').format(createdDateTime);
                              }
                              String hours = DateFormat('HH').format(createdDateTime);
                              String minutes = DateFormat('mm').format(createdDateTime);
                              String t = DateFormat('a').format(createdDateTime);
                              return Padding(
                                padding: const EdgeInsets.only(top:3 ,bottom: 3),
                                child: Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white70,
                                      border: Border.symmetric(horizontal: BorderSide(
                                        width: 1,
                                        color: Colors.white24,
                                      ))
                                  ),
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top:4),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                        CustomUsernameD0Avatar(userId: comments.user.userId,
                                            style:const TextStyle(fontSize: 13),
                                            radius: radius,
                                            maxsize: 150,
                                            click: true,
                                            height: 25,
                                            width: 185),
                                            comments.user.userId==widget.authorId?const Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(left: 5,right: 2),
                                                  child: Icon(Icons.star,color: Colors.grey,size: 15,),
                                                ),
                                                Text('Author',style: TextStyle(fontWeight: FontWeight.bold),),
                                              ],
                                            ):const Text(''),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Text(formattedTime),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40,right: 5),
                                          child: Text(comments.comment),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              TextButton(onPressed: (){

                                              }, child: const Text('reply'),

                                              )],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                            },

                          );

                        }}),
                ),
                Container(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.black,
                          child: CachedNetworkImage(
                            imageUrl:
                            profileimage,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 18,
                              backgroundImage: imageProvider,
                            ),

                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: SizedBox(
                              width:MediaQuery.of(context).size.width*0.35,
                              child: TextFormField(
                                controller: comment,
                                scrollPhysics: const ScrollPhysics(),
                                expands: false,
                                maxLines: 4,
                                minLines: 1,
                                textInputAction: TextInputAction.newline,
                                cursorColor: Colors.black,
                                decoration: InputDecoration(
                                  filled: true,
                                  focusColor: Colors.grey,
                                  hoverColor: Colors.grey,
                                  fillColor: Colors.white,
                                  hintText:isstart? 'write a comment':'commenting Not allowed',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                            width: MediaQuery.of(context).size.width*0.08,
                            child:isstart? TextButton(onPressed: _commentPost,
                                child: const Text('Post',style: TextStyle(color: Colors.blue),)):const Text('Post',style: TextStyle(color: Colors.black)))
                      ],
                    ),
                  ),

                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MatchcommentsH extends StatelessWidget {
  final String matchId;
  final Color color;
  final String collection;
  const MatchcommentsH({super.key,
    required this.matchId,
    required this.color,
    required this.collection});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(collection)
              .doc(matchId)
              .collection('comments')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
              List<Map<String, dynamic>> allLikes = [];
              int totalLikes=0;
              // Extract and combine all like objects into a single list
              for (final document in likeDocuments) {
                final List<dynamic> likesArray = document['comments'];
                // Explicitly cast likesArray to Iterable<Map<String, dynamic>>
                allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                totalLikes=allLikes.length;
              }
              if (totalLikes < 1) {
                return const SizedBox(height: 0, width: 0,);
              }else if(totalLikes>9999){
                return Text('${totalLikes/1000}K',style: TextStyle(color: color),);
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M',style: TextStyle(color:color),);
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B',style:TextStyle(color: color),);
              } else {
                return Text(
                  '$totalLikes',style: TextStyle(color:color),
                );
              }
            }
          }),
    );
  }
}






class UsermainPreview extends StatefulWidget {
  String userId;
  String collection;
  String matchId;
  String authorId;
  UsermainPreview({super.key,
    required this.matchId,
    required this.userId,
    required this.collection,
    required this.authorId,
  });

  @override
  State<UsermainPreview> createState() => _UsermainPreviewState();
}

class _UsermainPreviewState extends State<UsermainPreview> {

  FilmingProvider film=FilmingProvider();
  late Stream<DocumentSnapshot> _stream1;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    film.initAgora(userId: widget.userId, matchId: widget.matchId, collection: widget.collection);
    if(FirebaseAuth.instance.currentUser!.uid!=widget.authorId){
      onpause();
    }
  }
  int activeuser=0;
  void onpause() {
    _stream1 = _firestore.collection(widget.collection).doc(widget.matchId).snapshots();
    _stream1.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['activeuser'];
      setState(() {
        activeuser = newValue??0;
      });
    });
  }
  @override
  void dispose() {
    film.engine?.disableVideo();
    film.engine?.leaveChannel();
    film.uids.clear();
    film.engine?.disableAudio();
    film.uidToPeerIdMap.clear();
    film.dispose();
    super.dispose();
  }
  int uid=0;
  TextEditingController text=TextEditingController();
  double radius=14;
  double currentZoomValue = 1.0;
  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(
      animation: film,
      builder: (BuildContext context, Widget? child) {
        return  Row(
          children: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width*0.68,
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                      child:film.engine==null?Center(child:CircularProgressIndicator(color: Colors.white,)):AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine:film.engine!,
                          canvas:  VideoCanvas(uid: uid, ),
                        ),
                      )
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        height: 180,
                        width: 35,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey,
                            width: 3,
                          ),
                        ),
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            double delta = details.primaryDelta ?? 0.0;
                            if (delta > 0) {
                              currentZoomValue -= 0.1;
                            } else if (delta < 0) {
                              currentZoomValue += 0.1;
                            }
                            currentZoomValue = currentZoomValue.clamp(0.0, 10.0);
                            film.setZoom(zoom:currentZoomValue);
                          },
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            reverse: true,
                            child: SizedBox(
                              height: 30,
                              width: 35,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 50),
                                height: 30,
                                width: 35,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                transform: Matrix4.translationValues(0.1, 16.5 * (0.0 - currentZoomValue), 0.0),
                                child: Center(
                                  child: Text(
                                    currentZoomValue.toStringAsFixed(1),
                                    style: const TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                ),
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
            Container(
              height: MediaQuery.of(context).size.height*0.992,
              color: Colors.transparent,
              child: Center(
                child: Card(
                  elevation: 5,
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height*0.99,
                      width: MediaQuery.of(context).size.width*0.301,
                      child:RefreshIndicator(
                        onRefresh: ()async{
                          await film.initAgora(userId: widget.userId, matchId: widget.matchId, collection:widget.collection);
                        },
                        child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.301,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                              child:film.uidToPeerIdMap.isEmpty||film.engine==null? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 150,
                                    width: 150,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 8.0,
                                            value: film.v,
                                            backgroundColor: Colors.grey,
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "${(film.v*100).toStringAsFixed(1)}%",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15,),
                                  Text("Loading Assets...",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                                ],
                              ) : GridView.builder(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: film.token1.isEmpty||film.seconds1>7200||film.token.isEmpty?1:2,
                                  crossAxisSpacing: 2,
                                  mainAxisSpacing: 3,
                                  childAspectRatio: 1.0,
                                ),
                                itemCount: film.uidToPeerIdMap.length,
                                itemBuilder: (context, index) {
                                  final uids =film.uidToPeerIdMap.keys.toList();
                                  if(film.token1.isEmpty||film.seconds1>7200||film.token.isEmpty){
                                    return const Center(child: Text('Some essential data is missing pull down this area to add the data',style: TextStyle(fontWeight: FontWeight.bold),));
                                  }else{
                                    return InkWell(
                                      onTap: () async {
                                        if(FirebaseAuth.instance.currentUser!.uid==widget.authorId){
                                          if (uids[index] == 0) {
                                            film.setActive(active: uids[index]);
                                            film.updateUser1(uids[index], widget.matchId,widget.collection);
                                            film.upDate(widget.matchId,uids[index]);
                                            await film.engine?.setRemoteVideoStreamType(uid: uids[index], streamType: VideoStreamType.videoStreamHigh);
                                          } else if (uids[index] > 0) {
                                            await film.engine?.muteRemoteVideoStream(
                                                uid: uids[index], mute: false);
                                            film.setActive(active: uids[index]);
                                            film.updateUser1(uids[index], widget.matchId,widget.collection);
                                            film.upDate(widget.matchId,uids[index]);
                                            await film.engine?.setRemoteVideoStreamType(uid: uids[index], streamType: VideoStreamType.videoStreamHigh);
                                          }}
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          color: Colors.black,
                                          child: Stack(
                                            children: [
                                              film.localUserJoined ? AgoraVideoView(
                                                controller: VideoViewController(
                                                  rtcEngine: film.engine!,
                                                  canvas: VideoCanvas(uid: uids[index]),
                                                ),
                                              )
                                                  : const Center(
                                                child: SizedBox(
                                                  height: 35,
                                                  width: 35,
                                                  child: CircularProgressIndicator(),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: SizedBox(
                                                    height: 35,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceBetween,
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        AvatarsStreaming(uid:uids[index], matchId: widget.matchId, collection: widget.collection,),
                                                        InkWell(
                                                          onTap: (){
                                                            setState(() {
                                                              film.uidToPeerIdMap.removeWhere((key, value) =>
                                                              key == uids[index]);
                                                            });
                                                          },
                                                          child: const Icon(Icons.close, size: 15,
                                                              color: Colors.white),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Align(
                                                  alignment: Alignment.bottomLeft,
                                                  child: film.activeuid == uids[index] ? Container(
                                                    height: 15,
                                                    width: 15,
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  )
                                                      : const SizedBox.shrink(),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.bottomRight,
                                                child: InkWell(
                                                  onTap: () {
                                                    //await film.engine?.muteAllRemoteVideoStreams(true);
                                                    //await film.engine?.muteRemoteVideoStream(uid: uids[index], mute: false);
                                                    setState(() {
                                                      if(uids[index]==film.uid1){
                                                        uid=0;
                                                        film.index=index+1;
                                                      }else{
                                                        uid=uids[index];
                                                        film.index=index+1;
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                        color: Colors.transparent,
                                                        borderRadius: const BorderRadius.only(
                                                            topLeft: Radius.circular(10),
                                                            bottomLeft: Radius.circular(10),
                                                            bottomRight: Radius.circular(8)),
                                                        border: Border.all(
                                                          color: Colors.grey,
                                                          width: 2,
                                                        )
                                                    ),
                                                    child: Center(
                                                      child: Container(
                                                        width: 15,
                                                        height: 15,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: Colors.black,
                                                        ),

                                                        child: Center(
                                                          child: Text(
                                                            '${index + 1}',
                                                            style: const TextStyle(color: Colors.white,
                                                                fontSize: 12),
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
                                    );
                                  }},
                              ),
                            )
                        ),
                      )
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

