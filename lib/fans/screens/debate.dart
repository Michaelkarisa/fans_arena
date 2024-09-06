import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../fans/data/newsfeedmodel.dart';
import 'dart:async';
import 'accountfanviewer.dart';
import 'messages.dart';
class Debate extends StatefulWidget {
  MatchM matches;
  Debate({super.key,
    required this.matches,
  });

  @override
  State<Debate> createState() => _DebateState();
}

class _DebateState extends State<Debate> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController message = TextEditingController();
  final TextEditingController message1 = TextEditingController();
  late Stream<DocumentSnapshot> _stream1;
  String groupname='';
  String url='';
  String winner='';
  @override
  void initState(){
    super.initState();
    setState(() {
      if(widget.matches.score2>widget.matches.score1){
        winner='club2';
      }else if(widget.matches.score1>widget.matches.score2){
        winner='club1';
      }else if(widget.matches.score1==widget.matches.score2){
        winner='draw';
      }
    });
    scrollToBottom();
  }


  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  late Stream<QuerySnapshot> _stream;
  String replyto = '';
  final ScrollController _scrollController = ScrollController();
  double radius=24;
  bool value=false;
  bool value1=false;
  bool value2=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Debate & Betting',style:TextStyle(color: Colors.black),),
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back,color: Colors.black,),),
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 4),
                                            child: CustomNameM(userId: widget.matches.authorId, style: const TextStyle(fontSize: 14), maxsize: 150,),
                                          ),
                                          const Text('Match',style: TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5),
                                      child:FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: SizedBox(
                                              width: MediaQuery.of(context).size.width*0.95,
                                              child: Padding(
                                                  padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        widget.matches.league.userId.isNotEmpty? Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            CustomAvatar(imageurl:widget.matches.league.url, radius: 18),
                                                            const SizedBox(width: 5,),
                                                            CustomName(
                                                              username: widget.matches.league.name,
                                                              maxsize: 180,
                                                              style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                          ],
                                                        ):const SizedBox.shrink(),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 10,right: 10),
                                                          child: Container(
                                                            width: MediaQuery.of(context).size.width*0.85,
                                                            decoration: BoxDecoration(
                                                                color: Colors.grey[300],

                                                                borderRadius: BorderRadius.circular(10)
                                                            ),
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      InkWell(
                                                                        onTap: (){
                                                                          Navigator.push(context, MaterialPageRoute(
                                                                              builder: (context){
                                                                                if(widget.matches.club1.collectionName=='Club'){
                                                                                  return AccountclubViewer(user: widget.matches.club1, index: 0);
                                                                                }else if(widget.matches.club1.collectionName=='Professional'){
                                                                                  return AccountprofilePviewer(user: widget.matches.club1, index: 0);
                                                                                }else{
                                                                                  return Accountfanviewer(user:widget.matches.club1, index: 0);
                                                                                }
                                                                              }
                                                                          ),);
                                                                        },
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                CustomAvatar(radius: radius, imageurl: widget.matches.club1.url),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 10,right: 1),
                                                                                  child: Center(child: Text('${widget.matches.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 5,top: 5),
                                                                              child: CustomName(
                                                                                username: widget.matches.club1.name,
                                                                                maxsize: 140,
                                                                                style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width*0.3,
                                                                        height: 60,
                                                                        child: Column(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            const Padding(
                                                                              padding: EdgeInsets.only(left: 3,right: 3),
                                                                              child: Center(child: Text('VS',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 16.5),)),
                                                                            ),
                                                                            widget.matches.status == '0' ? Column(
                                                                              mainAxisAlignment: MainAxisAlignment
                                                                                  .spaceEvenly,
                                                                              children: [
                                                                                Text(widget.matches.createdat),
                                                                                Text(widget.matches.starttime),
                                                                              ],
                                                                            ):Time(matchId: widget.matches.matchId, club1Id: widget.matches.club1.userId, )

                                                                          ],
                                                                        ),
                                                                      ),

                                                                      InkWell(
                                                                        onTap: (){
                                                                          Navigator.push(context,  MaterialPageRoute(
                                                                              builder: (context){
                                                                                if(widget.matches.club2.collectionName=='Club'){
                                                                                  return AccountclubViewer(user: widget.matches.club2, index: 0);
                                                                                }else if(widget.matches.club2.collectionName=='Professional'){
                                                                                  return AccountprofilePviewer(user: widget.matches.club2, index: 0);
                                                                                }else{
                                                                                  return Accountfanviewer(user:widget.matches.club2, index: 0);
                                                                                }
                                                                              }
                                                                          ),);
                                                                        },
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 1,right: 10),
                                                                                  child: Center(child: Text('${widget.matches.score2}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                                                ),
                                                                                CustomAvatar( radius: radius, imageurl:widget.matches.club2.url),
                                                                              ],
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 5,top: 5),
                                                                              child: CustomName(
                                                                                username: widget.matches.club2.name,
                                                                                maxsize: 140,
                                                                                style:const TextStyle(color: Colors.black,fontSize: 16),),
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
                                                          height: 35,
                                                          child: Container(
                                                            height: 28,
                                                            width: MediaQuery.of(context).size.width*0.35,
                                                            decoration: BoxDecoration(
                                                              color: Colors.white70,
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),

                                                            child: winner!='draw'?Row(
                                                              children: [
                                                                const Text("Current Winner is:",style: TextStyle(color: Colors.black,fontSize: 15),),
                                                                Text( winner=='club1'?widget.matches.club1.name:widget.matches.club2.name,)
                                                              ],
                                                            ):const Center(child: Text('Draw')),
                                                          ),
                                                        ),
                                                      ])))),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: CustomNameM(userId: widget.matches.authorId==widget.matches.club1.userId?widget.matches.club2.userId:widget.matches.club1.userId, style: TextStyle(fontSize: 14), maxsize: 150,),
                                          ),
                                          const Text(' Match',style: TextStyle(fontWeight: FontWeight.bold),),
                                        ],
                                      ),
                                    ),
                                    widget.matches.matchId.isNotEmpty?FutureBuilder<QuerySnapshot>(
                                      future:FirebaseFirestore.instance
                                          .collection('Matches')
                                          .where('matchId',isEqualTo: widget.matches.match1Id)
                                          .limit(1)
                                          .get(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(child: CircularProgressIndicator()); // Display a loading indicator while fetching data
                                        } else if (snapshot.hasError) {
                                          return Center(child: Text('Error: ${snapshot.error}'));
                                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                          return const Center(child: Text('The Club have not yet posted their match')); // Handle case where there are no likes
                                        } else {
                                          final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
                                          String club1Id='';
                                          String club2Id='';
                                          String state1='';
                                          String date='';
                                          String time='';
                                          int score1=0;
                                          int score2=0;
                                          // Extract and combine all like objects into a single list
                                          for (final data in likeDocuments) {
                                            club1Id=data['club1Id']??'';
                                            club2Id=data['club2Id']??'';
                                            state1=data['state1']??'';
                                            time=data['time']??'';
                                            score1 = int.tryParse(data['score1'].toString()) ?? 0;
                                            score2 = int.tryParse(data['score2'].toString()) ?? 0;
                                            Timestamp newValue5 = data['scheduledDate'];
                                            DateTime createdDateTime5 = newValue5.toDate();
                                            date = DateFormat('d MMM').format(createdDateTime5);
                                          }
                                          String winner='';
                                          if(score2>score1){
                                            winner='club2';
                                          }else if(score1>score2){
                                            winner='club1';
                                          }else if(score1==score2){
                                            winner='draw';
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5),
                                            child:FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: SizedBox(
                                                    width: MediaQuery.of(context).size.width*0.95,
                                                    child: Padding(
                                                        padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                                        child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              widget.matches.league.userId.isNotEmpty? Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  CustomAvatar(imageurl:widget.matches.league.url, radius: 18),
                                                                  const SizedBox(width: 5,),
                                                                  CustomName(
                                                                    username: widget.matches.league.name,
                                                                    maxsize: 180,
                                                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                                ],
                                                              ):const SizedBox.shrink(),
                                                              Padding(
                                                                padding: const EdgeInsets.only(left: 10,right: 10),
                                                                child: Container(
                                                                  width: MediaQuery.of(context).size.width*0.85,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors.grey[300],

                                                                      borderRadius: BorderRadius.circular(10)
                                                                  ),
                                                                  child: Column(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    CustomAvatar( radius: radius, imageurl:widget.matches.club1.url),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 10,right: 1),
                                                                                      child: Center(child: Text('$score1',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 5,top: 5),
                                                                                  child: CustomName(
                                                                                    username: widget.matches.club1.name,
                                                                                    maxsize: 140,
                                                                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            SizedBox(
                                                                              width: MediaQuery.of(context).size.width*0.3,
                                                                              height: 60,
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                children: [
                                                                                  const Padding(
                                                                                    padding: EdgeInsets.only(left: 3,right: 3),
                                                                                    child: Center(child: Text('VS',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 16.5),)),
                                                                                  ),
                                                                                  state1 == '0' ? Column(
                                                                                    mainAxisAlignment: MainAxisAlignment
                                                                                        .spaceEvenly,
                                                                                    children: [
                                                                                      Text(date),
                                                                                      Text(time),
                                                                                    ],
                                                                                  ):Time(matchId: widget.matches.matchId, club1Id: widget.matches.club1.userId, )

                                                                                ],
                                                                              ),
                                                                            ),

                                                                            Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 1,right: 10),
                                                                                      child: Center(child: Text('$score1',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                                                                    ),
                                                                                    CustomAvatar( radius: radius, imageurl:widget.matches.club2.url),

                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 5,top: 5),
                                                                                  child: CustomName(
                                                                                    username: widget.matches.club2.name,
                                                                                    maxsize: 140,
                                                                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                                                ),
                                                                              ],
                                                                            ),

                                                                          ],
                                                                        ),
                                                                      ),

                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 35,
                                                                child: Container(
                                                                  height: 28,
                                                                  width: MediaQuery.of(context).size.width*0.35,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white70,
                                                                    borderRadius: BorderRadius.circular(10),
                                                                  ),

                                                                  child: winner!='draw'?Row(
                                                                    children: [
                                                                      const Text("Current Winner is:",style: TextStyle(color: Colors.black,fontSize: 15),),
                                                                      CustomNameM(userId: winner=='club1'?club1Id:club2Id, style: const TextStyle(fontSize: 14), maxsize: 150,),
                                                                    ],
                                                                  ):const Center(child: Text('Draw')),
                                                                ),
                                                              ),
                                                            ])))),
                                          );
                                        }
                                      },
                                    ):const Center(child: Text('Have not created a Match')),


                                  ],
                                ),


                                const Text('Place a Bet',style: TextStyle(fontWeight: FontWeight.bold),),
                                Placebet(club1Id: widget.matches.club1.userId, club2Id: widget.matches.club2.userId,),
                              ],
                            ),
                          ),
                        )
                      ]))
            ];
          }, body: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

          ],
        ),
        ),
      ),
    );
  }
}
class Time extends StatefulWidget {
  String matchId;
  String club1Id;
  Time({super.key,
    required this.matchId,
    required this.club1Id,
  });

  @override
  State<Time> createState() => _TimeState();
}

class _TimeState extends State<Time> {
  @override
  void initState(){
    super.initState();
    news = Newsfeedservice();
    onpause2(matchId: widget.matchId);
    onpause0(matchId: widget.matchId);
    pauseTime(matchId: widget.matchId);
    pauseTime1(matchId: widget.matchId);
    pauseTime2(matchId: widget.matchId);
    pauseTime3(matchId: widget.matchId);
    pauseTime4(matchId: widget.matchId);
    stopTime(matchId: widget.matchId);
    startTime(matchId: widget.matchId);
    _getUserData();
  }
  Newsfeedservice news = Newsfeedservice();
  @override
  void didUpdateWidget(covariant Time imageurl2){
    if (widget.matchId!=imageurl2.matchId) {
      onpause2(matchId: widget.matchId);
      onpause0(matchId: widget.matchId);
      pauseTime(matchId: widget.matchId);
      pauseTime1(matchId: widget.matchId);
      pauseTime2(matchId: widget.matchId);
      pauseTime3(matchId: widget.matchId);
      pauseTime4(matchId: widget.matchId);
      stopTime(matchId: widget.matchId);
      startTime(matchId: widget.matchId);
      _getUserData();
    }
    if (widget.matchId==imageurl2.matchId) {
      onpause2(matchId: widget.matchId);
      onpause0(matchId: widget.matchId);
      pauseTime(matchId: widget.matchId);
      pauseTime1(matchId: widget.matchId);
      pauseTime2(matchId: widget.matchId);
      pauseTime3(matchId: widget.matchId);
      pauseTime4(matchId: widget.matchId);
      stopTime(matchId: widget.matchId);
      startTime(matchId: widget.matchId);
      _getUserData();
    }
    if (widget.matchId.isEmpty) {
      onpause2(matchId: widget.matchId);
      onpause0(matchId: widget.matchId);
      pauseTime(matchId: widget.matchId);
      pauseTime1(matchId: widget.matchId);
      pauseTime2(matchId: widget.matchId);
      pauseTime3(matchId: widget.matchId);
      pauseTime4(matchId: widget.matchId);
      stopTime(matchId: widget.matchId);
      startTime(matchId: widget.matchId);
      _getUserData();
    }
    super.didUpdateWidget(imageurl2);
  }
  String collectionName='';
  bool isLoading = true;


  Future<void> _getUserData() async {
    collectionName=await news.getAccount(widget.club1Id);
    setState(() {
      isLoading=false;
    });
  }
  int duration=0;
  String stoptime='';
  String state1='1';
  String state2='1';
  String state3='';
  bool isstart=false;
  bool ispaused=false;
  bool isenabled=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _stream;
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
  void startTime({required String matchId,}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue5 = (snapshot.data() as Map<String, dynamic>)['starttime'];
      setState(() {
        DateTime createdDateTime5 = newValue5.toDate();
        starttime = DateFormat('d MMM').format(createdDateTime5);
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
  void onpause2({required String matchId,}){
    _stream = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['state1'];
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['state2'];
      if ( newValue == state1 && newValue1 == state2) {
        setState(() {
          isstart = true;
          ispaused = true;
          isenabled=true;
          state3=newValue1;
        });
        fetchTimestampAndStartTimer(matchId: widget.matchId,
            pausetime:pausetime, pausetime1: pausetime1);
      }else if(newValue == state1 &&newValue1 != state2){
        setState(() {
          isstart = true;
          ispaused = false;
          isenabled=true;
          state3=newValue1;
        });
        fetchTimestampAndStartTimer(matchId: widget.matchId,
            pausetime:pausetime, pausetime1: pausetime1).then((value) =>stopwatch.stop());
      }else {
        setState(() {
          isstart=false;
          ispaused=false;
          isenabled=false;
          state3=newValue1;
        });
        stopwatch.stop();
      }
    });
  }
  String starttime='';
  String pausetime='';
  String pausetime1='';
  String pausetime2='';
  String pausetime3='';
  String pausetime4='';
  String resumetime='';
  int seconds=0;
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  void startTimerFromTimestamp(int timestampDifference) {
    // Start the stopwatch
    stopwatch.start();

    // Start the timer to update the seconds
    timer = Timer.periodic(const Duration(microseconds: 1), (_) {
      setState(() {
        seconds = stopwatch.elapsed.inSeconds + timestampDifference;
      });

    });
  }
  Future<void> fetchTimestampAndStartTimer({required String matchId,required String pausetime,required String pausetime1}) async {
    DocumentSnapshot timestampSnapshot = await FirebaseFirestore.instance
        .collection('Matches')
        .doc(matchId)
        .get();

    if (timestampSnapshot.exists&&pausetime.isEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(startTime);
      int timestampDifference = difference.inSeconds;
      seconds = timestampDifference;
      startTimerFromTimestamp(timestampDifference);
      print('$timestampDifference');

    }else if(timestampSnapshot.exists&&pausetime.isNotEmpty){
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
      setState(() {
        seconds = t;
      });
      startTimerFromTimestamp(t);
      print('$timestampDifference');
    }else if(timestampSnapshot.exists&&pausetime1.isNotEmpty) {
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
      setState(() {
        seconds = t;
      });
      startTimerFromTimestamp(t);
      print('$timestampDifference');
    }
  }
  @override
  Widget build(BuildContext context) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');
    int minutes1 = duration ~/ 60;
    int remainingSeconds1 = duration % 60;

    String minutesString1 = minutes1.toString().padLeft(2, '0');
    String secondsString1 = remainingSeconds1.toString().padLeft(2, '0');
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          LayoutBuilder(builder: (context, BuildContext){
            if(isLoading){
              return const SizedBox(height:25,width:25,child: CircularProgressIndicator());
            }else if(stoptime.isNotEmpty) {
              return const Text('Full-Time');
            }else if(state3=='0'){
              return const Text('Half-Time');
            }else if(pausetime.isEmpty&&pausetime1.isEmpty&&pausetime2.isEmpty&&pausetime3.isEmpty&&pausetime4.isEmpty){
              if(collectionName=='Club'){
                return const Text('1H');
              }else{
                return const Text('1R');
              }
            }else if(pausetime.isNotEmpty&&pausetime1.isEmpty&&pausetime2.isEmpty&&pausetime3.isEmpty&&pausetime4.isEmpty){
              if(collectionName=='Club'){
                return const Text('2H');
              }else{
                return const Text('2R');
              }
            }else if(pausetime.isNotEmpty&&pausetime1.isNotEmpty&&pausetime2.isEmpty&&pausetime3.isEmpty&&pausetime4.isEmpty) {
              if(collectionName=='Club'){
                return const Text('3H');
              }else{
                return const Text('3R');
              }
            }else if(pausetime.isNotEmpty&&pausetime1.isNotEmpty&&pausetime2.isNotEmpty&&pausetime3.isEmpty&&pausetime4.isEmpty){
              if(collectionName=='Club'){
                return const Text('4H');
              }else{
                return const Text('4R');
              }
            }else if(pausetime.isNotEmpty&&pausetime1.isNotEmpty&&pausetime2.isNotEmpty&&pausetime3.isNotEmpty&&pausetime4.isEmpty){
              if(collectionName=='Club'){
                return const Text('5H');
              }else{
                return const Text('5R');
              }
            }else if(pausetime.isNotEmpty&&pausetime1.isNotEmpty&&pausetime2.isNotEmpty&&pausetime3.isNotEmpty&&pausetime4.isNotEmpty){
              if(collectionName=='Club'){
                return const Text('6H');
              }else{
                return const Text('6R');
              }
            }else{
              return const Text('Unkwown');
            }
          }),
          stoptime.isNotEmpty?Text("$minutesString1 min",style: const TextStyle(color: Colors.black)):Text("$minutesString:$secondsString",style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}

class CheckClub extends StatefulWidget {
  Matches matches;
  CheckClub({super.key,required this.matches});

  @override
  State<CheckClub> createState() => _CheckClubState();
}

class _CheckClubState extends State<CheckClub> {

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Betting extends StatefulWidget {
  const Betting({super.key});

  @override
  State<Betting> createState() => _BettingState();
}

class _BettingState extends State<Betting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Betting',style: TextStyle(color: Colors.black),),
        leading: IconButton(
          onPressed: (){Navigator.pop(context);},icon:const Icon(Icons.arrow_back,color: Colors.black,),
        ),
      ),
      body: const Center(child: Text("Service current Unavailable")),
    );
  }
}

class Placebet extends StatefulWidget {
  String club1Id;
  String club2Id;
  Placebet({super.key,required this.club1Id,required this.club2Id});

  @override
  State<Placebet> createState() => _PlacebetState();
}

class _PlacebetState extends State<Placebet> {
  bool value=false;
  bool value1=false;
  bool value2=false;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Checkbox(
                  value: value,
                  onChanged: (bool? valu) {
                    setState(() {
                      value=!value;
                      value2=false;
                      value1=false;
                    });
                  },
                ),),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: Row(
                    children: [
                      const Text('Win',maxLines: 1,),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: CustomNameM(userId: widget.club1Id, style: const TextStyle(fontSize: 14), maxsize: 150,),
                      ),
                    ],
                  )),

            ],
          ),
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Checkbox(
                  value: value2,
                  onChanged: (bool? valu) {
                    setState(() {
                      value2=!value2;
                      value=false;
                      value1=false;
                    });
                  },
                ),),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: const Text('Draw',maxLines: 1,))
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: 40,
                width: 40,
                child: Checkbox(
                  value: value1,
                  onChanged: (bool? valu) {
                    setState(() {
                      value1=!value1;
                      value=false;
                      value2=false;
                    });
                  },
                ),),
              SizedBox(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: Row(
                    children: [
                      const Text('Win',maxLines: 1,),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: CustomNameM(userId: widget.club2Id, style: const TextStyle(fontSize: 14), maxsize: 150,),
                      )
                    ],
                  ))
            ],
          ),
        ],
      ),
    );
  }
}




