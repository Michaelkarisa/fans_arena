import 'package:fans_arena/clubs/data/lineup.dart';
import 'package:fans_arena/clubs/screens/clubteamtable.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../fans/bloc/usernamedisplay.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/matchwatch.dart';
import '../../fans/screens/messages.dart';
import '../../fans/screens/newsfeed.dart';
import '../../joint/filming/data/filming0.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/firebaseanalytics.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'accountclubviewer.dart';
import 'eventsclubs.dart';


class Lineup1 extends StatefulWidget {
 MatchM match;
  Lineup1({super.key,
    required this.match,
   });

  @override
  State<Lineup1> createState() => _Lineup1State();
}

class _Lineup1State extends State<Lineup1> {
  String userId='';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late  LineUpProvider lineup;
  @override
  void initState() {
    super.initState();
    lineup=LineUpProvider();
    lineup.retrievePlayers(match: widget.match);
    lineup.retrievePlayers1(match: widget.match);
    retrieveUserData1();
    retrieveUserData0();
  }
  String formation1='';
  String formation='';
  double deviceH=1.0;
  double deviceW=1.0;
  double deviceH1=1.0;
  double deviceW1=1.0;
  void retrieveUserData1() async {
  final awaymatch = widget.match.authorId==widget.match.club2.userId? widget.match.matchId:widget.match.match1Id;
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Matches')
          .doc(awaymatch)
          .collection('Players')
          .doc(widget.match.club2.userId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          formation1 = data['formation'];
          image1 = data['image'];
          deviceH1=data['height'];
          deviceW1=data['width'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  void retrieveUserData0() async {
    final homematch = widget.match.authorId==widget.match.club1.userId? widget.match.matchId:widget.match.match1Id;
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Matches')
          .doc(homematch)
          .collection('Players')
          .doc(widget.match.club1.userId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          formation = data['formation'];
          image = data['image'];
          deviceH=data['height'];
          deviceW=data['width'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  List<Map<String, dynamic>> playersData = [];


  bool ishome=true;
  void hmatch(){
    EventLogger().logButtonPress('matchwatch lineup home', 'show home club lineup');
    setState(() {
      ishome=true;
    });
  }
  void amatch(){
    EventLogger().logButtonPress('matchwatch lineup away', 'show away club lineup');
    setState(() {
      ishome=false;
    });
  }
  String image='assets/fb.jpeg';
  String image1='assets/fb.jpeg';
  double radius=19;
  double radius1=16;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:3,right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: SizedBox(
                  height: 30,
                  width: MediaQuery.of(context).size.width*0.3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: 30,
                        width: MediaQuery.of(context).size.width*0.13,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          onPressed:hmatch,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: ishome?const Text(
                              "Home",
                              style: TextStyle(color: Colors.blue),
                            ):const Text(
                              "Home",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: 30,
                        width: MediaQuery.of(context).size.width*0.13,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 30),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          onPressed:amatch,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: ishome?const Text(
                              "Away",
                              style: TextStyle(color: Colors.black),
                            ):const Text(
                              "Away",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ishome?Column(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountclubViewer(
                          user:widget.match.club1,fromMatch: true, index: 0)));
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomAvatar(radius: radius, imageurl: widget.match.club1.url),
                        UsernameDO(
                          username: widget.match.club1.name,
                          collectionName: widget.match.club1.collectionName,
                          width: 160,
                          height: 38,
                          maxSize: 140,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.3,
                      height: MediaQuery.of(context).size.height*0.785,
                      child:  AnimatedBuilder(animation: lineup,
                          builder: (BuildContext context, Widget? child) {
                        return  Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Center(child: Text('Sub Players', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                    DataTable(
                                      columnSpacing: MediaQuery.of(context).size.width * 0.01,
                                      columns: const [
                                        DataColumn(label: Text('Player')),
                                        DataColumn(label: Text('P.no')),
                                        DataColumn(
                                          label: Text(
                                            'time',
                                          ),
                                        ),
                                      ],
                                      rows: lineup.subs.map(
                                              (player) { return DataRow(cells: [
                                            DataCell(
                                              InkWell(
                                                onTap:(){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountprofilePviewer(
                                                      user: Person(name:player.name,
                                                      url: player.url, collectionName:'Professional',
                                                          userId: player.appusage.userId),fromMatch: true, index: 0)));
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    CustomAvatar(imageurl: player.url, radius: 16,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: TexT(name: player.name,),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(Center(child: Text(player.appusage.identity))),
                                            DataCell(Center(child: Text(player.appusage.time))),
                                          ]);}
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  ),
                ],
              ): Column(
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountclubViewer(
                          user:widget.match.club2,fromMatch: true, index: 0)));
                    },
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomAvatar(radius: radius, imageurl: widget.match.club2.url),
                        UsernameDO(
                          username: widget.match.club2.name,
                          collectionName: widget.match.club2.collectionName,
                          width: 160,
                          height: 38,
                          maxSize: 140,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.3,
                      height: MediaQuery.of(context).size.height*0.785,
                      child:  AnimatedBuilder(animation: lineup,
                          builder: (BuildContext context, Widget? child) {
                        return  Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Center(child: Text('Sub Players', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                    DataTable(
                                      columnSpacing: MediaQuery.of(context).size.width * 0.01,
                                      columns: const [
                                        DataColumn(label: Text('Player')),
                                        DataColumn(label: Text('P.no')),
                                        DataColumn(
                                          label: Text(
                                            'time',
                                          ),
                                        ),
                                      ],
                                      rows: lineup.subs2.map(
                                              (player) { return DataRow(cells: [
                                            DataCell(
                                              InkWell(
                                                onTap:(){
                                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountprofilePviewer(
                                                      user: Person(name:player.name,
                                                          url: player.url, collectionName:'Professional',
                                                          userId: player.appusage.userId), fromMatch: true,index: 0)));
                                                },
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    CustomAvatar(imageurl: player.url, radius: 16,),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: TexT(name: player.name),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            DataCell(Center(child: Text(player.appusage.identity))),
                                            DataCell(Center(child: Text(player.appusage.time))),
                                          ]);}
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                      )
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.54,
                    height: 40,
                    child: ishome?Center(child: Text(formation.isNotEmpty?'formation:$formation':'')):Center(child: Text(formation1.isNotEmpty?'formation:$formation1':'')),
                  ),
                  SizedBox(
                    height: 30,
                    width: MediaQuery.of(context).size.width*0.06,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                        side: const BorderSide(
                          color: Colors.grey,
                        ),
                      ),
                      onPressed:(){
                        Navigator.pop(context);
                      },
                      child: const Center(child: Icon(Icons.close)),
                    ),
                  ),
                ],
              ),
              ishome? Container(
                  width: MediaQuery.of(context).size.width*0.645,
                  height: MediaQuery.of(context).size.height*0.85,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child:AnimatedBuilder(
                    animation: lineup,
                    builder: (BuildContext context, Widget? child) {
                    return Stack(
                          children: lineup.players.map<Widget>((player) {
                            Color card =Colors.transparent;
                            if(player.appusage.card!="0"){
                              card=Color(int.parse(player.appusage.card));
                            }
                            double currentdH=MediaQuery.of(context).size.height;
                            double currentdW=MediaQuery.of(context).size.width;
                            double x=player.appusage.x;
                            double y=player.appusage.y;
                            double dy=(currentdH*y)/deviceH;
                            double dx=(currentdW*x)/deviceW;
                            return Positioned(
                              left:dx,
                              top:dy-6,
                              child: InkWell(
                                onTap:(){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountprofilePviewer(
                                      user: Person(name:player.name,
                                          url: player.url, collectionName:'Professional',
                                          userId: player.appusage.userId), fromMatch: true,index: 0)));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: 45,
                                      child: Stack(
                                        children: [
                                          CustomAvatar(imageurl: player.url, radius: 18),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height: 23,
                                              width: 23,
                                              decoration: BoxDecoration(
                                                color: lineup.color,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Center(child: Text(player.appusage.identity,style:TextStyle(color: lineup.tcolor))),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right:5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color:card,
                                                    borderRadius: BorderRadius.circular(3.5)
                                                ),
                                                width: 20,
                                                height: 10,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 2,),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color:lineup.color,
                                      ),
                                      child: TexT(name:player.name ?? '',color:lineup.tcolor),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                  )): Container(
                  width: MediaQuery.of(context).size.width*0.645,
                  height: MediaQuery.of(context).size.height*0.85,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(image1),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child:AnimatedBuilder(
                      animation: lineup,
                      builder: (BuildContext context, Widget? child) {
                    return Stack(
                          children: lineup.players2.map<Widget>((player) {
                            Color card =Colors.transparent;
                            if(player.appusage.card!="0"){
                              card=Color(int.parse(player.appusage.card));
                            }
                            double currentdH=MediaQuery.of(context).size.height;
                            double currentdW=MediaQuery.of(context).size.width;
                            double x=player.appusage.x;
                            double y=player.appusage.y;
                            double dy=(currentdH*y)/deviceH1;
                            double dx=(currentdW*x)/deviceW1;
                            return Positioned(
                              left:dx,
                              top:dy-6,
                              child: InkWell(
                                onTap:(){
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountprofilePviewer(
                                      user: Person(name:player.name,
                                          url: player.url, collectionName:'Professional',
                                          userId: player.appusage.userId), fromMatch: true,index: 0)));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 45,
                                      width: 45,
                                      child: Stack(
                                        children: [
                                          CustomAvatar(imageurl: player.url, radius: 18),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height: 23,
                                              width: 23,
                                              decoration: BoxDecoration(
                                                color: lineup.color1,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(2.0),
                                                child: Center(child: Text(player.appusage.identity,style: TextStyle(color: lineup.tcolor1),)),
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(right:5),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color:card,
                                                    borderRadius: BorderRadius.circular(3.5)
                                                ),
                                                width: 20,
                                                height: 10,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 2,),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: lineup.color1,
                                      ),
                                      child: TexT(name:player.name,color: lineup.tcolor1),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

class Lineup extends StatefulWidget {
  MatchM match;
  int seconds;
  String state1;
  Lineup({super.key,
    required this.match,
    required this.seconds,
    required this.state1,
   });

  @override
  State<Lineup> createState() => _LineupState();
}

class _LineupState extends State<Lineup> {
  List<Map<String,dynamic>>items1=[];

  Future<void> fetchAndPostToFirestore() async {
    showToastMessage('Updating lineup...');
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> dataList2 = [];
    DocumentSnapshot documentSnapshot = await firestore.collection('Matches')
        .doc(widget.match.matchId).collection('Players').doc(userId)
        .get();
    final data = documentSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      dataList2 = List<Map<String, dynamic>>.from(data['players']);
      for (var newItem in items1) {
        for (var existingItem in dataList2) {
          if (existingItem['userId'] == newItem['userId']){
            existingItem['x'] = newItem['x'];
            existingItem['y'] = newItem['y'];
            break;
          }
        }
      }
      await firestore.collection('Matches').doc(widget.match.matchId).collection(
          'Players').doc(userId).update({
        'players': dataList2,
      });
      showToastMessage('lineup updated');
    }
  }

  Future<void> offerCard(String card,String playerId) async {
    if(card=="0"){
      showToastMessage('removing card...');
    }else {
      showToastMessage('offering card...');
    }
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> dataList2 = [];
    DocumentSnapshot documentSnapshot = await firestore.collection('Matches')
        .doc(widget.match.matchId).collection('Players').doc(userId)
        .get();
    final data = documentSnapshot.data() as Map<String, dynamic>?;
    if (data != null) {
      dataList2 = List<Map<String, dynamic>>.from(data['players']);
        for (var existingItem in dataList2) {
          if (existingItem['userId'] == playerId){
            existingItem['card'] = card;
            break;
          }
        }
      await firestore.collection('Matches').doc(widget.match.matchId).collection(
          'Players').doc(userId).update({
        'players': dataList2,
      });
      if(card=="0"){
        showToastMessage('card removed');
      }else {
        showToastMessage('card offered');
      }
    }
  }

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
  String userId='';
  String matchId='';
  String image='assets/fb.jpeg';
  FilmingProvider  film=FilmingProvider();
  LineUpProvider  lineup=LineUpProvider();
  MatchwatchProvider watch = MatchwatchProvider();
  @override
  void initState() {
    super.initState();
   film.onPause2(matchId: widget.match.matchId, collection: 'Matches');
    lineup.retrieveCPlayers(matchId: widget.match.matchId, userId:FirebaseAuth.instance.currentUser!.uid );
    _getCurrentUser1();
  }

  Color tcolor=Colors.black;
  @override
  void dispose() {
    lineup.dispose();
    film.dispose();
    super.dispose();

  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void _getCurrentUser1() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        matchId=widget.match.matchId;
      });
      retrieveUserData0();
    }
  }
  TextEditingController formation=TextEditingController();
  void retrieveUserData0() async {

    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Matches')
          .doc(widget.match.matchId)
          .collection('Players')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          formation.text = data['formation'];
          image = data['image'];
          deviceH=data['height'];
          deviceW=data['width'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  bool isAssetsPath(String input) {
    return input.startsWith('assets');
  }
Color color=Colors.blue;
  Future<void> updateFormation() async {
    showToastMessage('updating formation, color...');

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
          .collection('Players')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (formation.text.isNotEmpty && formation.text != oldData['formation']) {
          newData['formation'] = formation.text;
        }
        if (color.value.toString().isNotEmpty && color.value.toString() != oldData['color']) {
          newData['color'] = color.value.toString();
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          showToastMessage('changes updated');
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

  DateTime scheduledDate = DateTime.now();
  Future<void> swapPlayer({
    required Sub sub,
    required int seconds,
    required Player player,
    required List<Map<String, dynamic>> players,
    required List<Map<String, dynamic>> subs,
  }) async {
    showToastMessage('substituting player...');
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    String minutesString = minutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');
    if (players.isNotEmpty && subs.isNotEmpty) {
      List<Map<String, dynamic>> players1 = List.from(players);
      List<Map<String, dynamic>> subs1 = List.from(subs);
      List<Map<String, dynamic>> allPlayers = players1.map((p) {
        if (p['userId'] == player.appusage.userId) {
          return {
            ...p,
            'userId': sub.appusage.userId,
            'card': sub.appusage.card,
            'identity':sub.appusage.identity,
            'time': "$minutesString:$secondsString",
          };
        }
        return p;
      }).toList();
      List<Map<String, dynamic>> allSubs = subs1.map((p) {
        if (p['userId'] == sub.appusage.userId) {
          return {
            ...p,
            'userId': player.appusage.userId,
            'card': player.appusage.card,
            'identity':player.appusage.identity,
            'time': "$minutesString:$secondsString",
          };
        }
        return p;
      }).toList();
      await FirebaseFirestore.instance
          .collection('Matches')
          .doc(widget.match.matchId)
          .collection('Players')
          .doc(userId)
          .update({
        'players': allPlayers,
        'subs': allSubs,
      });
      showToastMessage('player substituted');
    } else {
      print('One or both documents not found');
    }
  }

  List<Color> colors = [
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.red,
    Colors.white,
    Colors.green,
    Colors.indigo,
    Colors.orange,
    Colors.blueGrey,
    Colors.green,
    Colors.grey,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.yellow,
    Colors.lime
  ];
  double deviceH=1.0;
  double deviceW=1.0;
  double radius=23;
  double radius1=16;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top:3,right: 5),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width*0.635,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.06,
                        height: 25,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 30),
                            side: const BorderSide(
                              color: Colors.grey,
                            ),
                          ),
                          onPressed:(){
                            Navigator.pop(context);
                          }
                          ,
                          child: const Center(child: Icon(Icons.close)),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                        width: MediaQuery.of(context).size.width*0.56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 35,
                              width: MediaQuery.of(context).size.width*0.2,
                              child: TextFormField(
                                controller: formation,
                                decoration: InputDecoration(
                                  labelText: 'Formation',
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors
                                            .grey),
                                    borderRadius: BorderRadius
                                        .circular(8),
                                  ),
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              padding: const EdgeInsets.only(left:6,right: 6),
                              position: PopupMenuPosition.under,
                              icon: const Icon(Icons.color_lens_outlined),
                              onSelected: (value) {
                                setState(() {
                                  lineup.color=Color(int.parse(value));
                                  color =Color(int.parse(value));
                                  if(value==Colors.black.value.toString()){
                                    tcolor=Colors.white;
                                    lineup.tcolor=Colors.white;
                                  }else{
                                    lineup.tcolor=Colors.black;
                                    tcolor=Colors.black;
                                  }
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return colors.map<PopupMenuEntry<String>>((item) {
                                  return PopupMenuItem<String>(
                                    value: item.value.toString(),
                                    child: Center(
                                      child: Container(
                                        height: 25,
                                        width: 40,
                                        color: item,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            TextButton(
                              onPressed: ()async{
                                updateFormation();
                                await fetchAndPostToFirestore();
                              },child: const Text('Upload changes'),
                            ),
                            TextButton(
                              onPressed: ()async{
                                for(final item in items1){
                                  await DatabaseHelper2.instance.updateAppUsage(AppUsage(
                                    userId:item['userId'],
                                    identity:item['identity'],
                                    time:item['time'],
                                    y:item['y'],
                                    x: item['x'],
                                    card: item['card']??"",
                                  ));
                                }
                                await DatabaseHelper.instance.updateAppUsage(AppUsage2(
                                  image: image, formation:formation.text, color: color.value.toString(),
                                ));
                                showToastMessage('changes saved');
                              },child: const Text('save changes'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    width: MediaQuery.of(context).size.width*0.645,
                    height: MediaQuery.of(context).size.height*0.85,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      image:isAssetsPath(image)? DecorationImage(
                        image: AssetImage(image),
                        fit: BoxFit.cover,
                      ):DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: AnimatedBuilder(
                            animation: lineup,
                            builder: (BuildContext context, Widget? child) {
                              return Stack(
                                children: lineup.players.map<Widget>((player) {
                                  color=lineup.color;
                                  tcolor=lineup.tcolor;
                                  Color card =Colors.transparent;
                                  if(player.appusage.card!="0"){
                                    card=Color(int.parse(player.appusage.card));
                                  }
                                  double currentdH=MediaQuery.of(context).size.height;
                                  double currentdW=MediaQuery.of(context).size.width;
                                  double x=player.appusage.x;
                                  double y=player.appusage.y;
                                  items1.add({
                                    'userId': player.appusage.userId,
                                    'y': y,
                                    'x': x,
                                    'identity': player.appusage.identity,
                                    'time': player.appusage.time,
                                    'card': player.appusage.card,
                                  });
                                  double dy=(currentdH*y)/deviceH;
                                  double dx=(currentdW*x)/deviceW;
                                  return Positioned(
                                    left: dx,
                                    top: dy-4,
                                    child: Draggable(
                                      feedback: const SizedBox.shrink(),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap:(){
                                              showDialog(context: context, builder: (context){
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0)),
                                                  title: SizedBox(
                                                    height: 90,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        const Text('Card'),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            InkWell(
                                                              onTap:(){
                                                                offerCard(Colors.red.value.toString(), player.appusage.userId);
                                                                Navigator.pop(context);
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors.red,
                                                                    borderRadius: BorderRadius.circular(5)
                                                                ),
                                                                width: 60,
                                                                height: 40,
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap:(){
                                                                offerCard("0", player.appusage.userId);
                                                                Navigator.pop(context);
                                                              },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Colors.white70,
                                                                    borderRadius: BorderRadius.circular(5)
                                                                ),
                                                                width: 60,
                                                                height: 40,
                                                                child: const Center(child: Icon(Icons.close,color: Colors.black,size: 25,)),
                                                              ),
                                                            ),
                                                            InkWell(
                                                                onTap:(){
                                                                  offerCard(Colors.yellow.value.toString(), player.appusage.userId);
                                                                  Navigator.pop(context);
                                                                },
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors.yellow,
                                                                  borderRadius: BorderRadius.circular(5)
                                                                ),
                                                                width: 60,
                                                                height: 40,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const Text('Substitute list'),
                                                      ],
                                                    ),
                                                  ),
                                                  alignment: Alignment.topCenter,
                                                  content:SingleChildScrollView(
                                                    scrollDirection: Axis.vertical,
                                                    child: Column(
                                                      children: lineup.subs.map<Widget>((sub){
                                                        return Padding(
                                                          padding: const EdgeInsets.only(top:5,bottom: 5),
                                                          child: AnimatedBuilder(
                                                            animation: film,
                                                              builder: (BuildContext context, Widget? child) {
                                                              return InkWell(
                                                                onTap:(){
                                                                  swapPlayer(sub: sub, player:player, players:lineup.dataCList, subs:lineup.dataCList2, seconds: film.seconds);
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  children: [
                                                                    CustomAvatar(imageurl: sub.url, radius: 16),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 5),
                                                                      child: TexT(name:sub.name),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(left: 10),
                                                                      child: Text(sub.appusage.identity),
                                                                    )
                                                                  ],
                                                                ),
                                                              );
                                                            }
                                                          ),
                                                        );
                                                      }).toList() ,
                                                    ),
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
                                            },
                                            child: SizedBox(
                                              height: 45,
                                              width: 55,
                                              child: Stack(
                                                children: [
                                                  CustomAvatar(imageurl: player.url, radius: 18),
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: Container(
                                                      height: 23,
                                                      width: 23,
                                                      decoration:  BoxDecoration(
                                                        color: lineup.color,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(2.0),
                                                        child: Center(child: Text(player.appusage.identity,style: TextStyle(color: lineup.tcolor),)),
                                                      ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topLeft,
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(right:5),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color:card,
                                                            borderRadius: BorderRadius.circular(2.5)
                                                        ),
                                                        width: 20,
                                                        height: 10,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 2,),
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              color: lineup.color,
                                            ),
                                            child: TexT(name:player.name,color: lineup.tcolor,),
                                          ),
                                        ],
                                      ),
                                      onDragUpdate: (details)  {
                                        double y = player.appusage.y + details.delta.dy * 0.8;
                                        double x = player.appusage.x + details.delta.dx * 0.8;
                                        setState(() {
                                          player.appusage.y = y;
                                          player.appusage.x = x;
                                          int existingIndex = items1.indexWhere((item) => item['userId'] == player.appusage.userId);
                                          if (existingIndex != -1) {
                                            items1[existingIndex]['y'] = y;
                                            items1[existingIndex]['x'] = x;
                                          } else {
                                            items1.add({
                                              'userId': player.appusage.userId,
                                              'y': y,
                                              'x': x,
                                              'identity': player.appusage.identity,
                                              'time': player.appusage.time,
                                              'card':player.appusage.card,
                                            });
                                          }
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
            ),]),
            Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                 CustomAvatar( radius: 18, imageurl:widget.match.club1.userId==widget.match.authorId?widget.match.club1.url:widget.match.club2.url),
                   const SizedBox(width: 5,),
                    CustomName(
                      username: widget.match.authorId==widget.match.club1.userId?widget.match.club1.name:widget.match.club2.name,
                      maxsize: 120,
                      style:const TextStyle(color: Colors.black,fontSize: 14),),
                  ],
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width*0.288,
                    height: MediaQuery.of(context).size.height*0.8,
                    child:  AnimatedBuilder(
                            animation: lineup,
                            builder: (BuildContext context, Widget? child) {
                              return  Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: SingleChildScrollView(scrollDirection: Axis.vertical,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const Center(child: Text('Sub Players', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                                      DataTable(
                                        columnSpacing: MediaQuery.of(context).size.width * 0.01,
                                        columns: const [
                                          DataColumn(label: Text('Player')),
                                          DataColumn(label: Text('P.no')),
                                          DataColumn(
                                            label: Text('time',),
                                          ),
                                        ],
                                        rows: lineup.subs.map((sub) {
                                          return DataRow(cells: [
                                              DataCell(
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    CustomAvatar(imageurl:sub.url, radius: 16),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child:TexT(name:sub.name,)),
                                                  ],
                                                ),
                                              ),
                                              DataCell(Center(child: Text(sub.appusage.identity))),
                                              DataCell(Center(child: Text(sub.appusage.time))),
                                            ]);}
                                        ).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ) ],
            )
          ]),
    );
  }
}
class TexT extends StatelessWidget {
  String name;
  Color color;
   TexT({super.key,required this.name,this.color=Colors.black});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username = 'loading...';
  String name1(String name) {
    if (name.length > 7) {
      return "${name.substring(0, 7)}...";
    }else{
      return name;
    }
  }
  @override
  Widget build(BuildContext context) {
    username=name1(name);
    return Text(username,style: TextStyle(color:color),);
  }
}

class Lineupcreation extends StatefulWidget {
  String matchId;
  String club1Id;
  String club2Id;
  Lineupcreation({super.key,required this.matchId, required this.club1Id, required this.club2Id});

  @override
  State<Lineupcreation> createState() => _LineupcreationState();
}

class _LineupcreationState extends State<Lineupcreation> {

  String userId='';
  String Id='';
  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
  }

  int rank1=1;
  int rank2=1;
  bool status=false;
  TextEditingController lineup =TextEditingController();
  Future<void> fetchAndPostToFirestore() async {
    File imageFile = File(image);
    if (image.isNotEmpty&&!isAssetsPath(image)&&imageFile.existsSync()) {
        String? imageUrl = await uploadImageToStorage(image);
        setState(() {
          image = imageUrl;
        });
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        List<Map<String, dynamic>> dataList2 = [];
        DocumentSnapshot documentSnapshot = await firestore .collection("Clubs")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("fields")
            .doc("fields").get();
        DocumentSnapshot documentSnapshot1 = await firestore .collection("Clubs")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();
        final data = documentSnapshot.data() as Map<String, dynamic>?;
        final data2 = documentSnapshot1.data() as Map<String, dynamic>?;
          if(documentSnapshot.exists){
            dataList2 = List<Map<String, dynamic>>.from(data?['fields']);
            final data1=dataList2.last;
            dataList2.add({
              "id": data1['id']+1,
              "image": imageUrl,
              "fieldname":"${data2?['Clubname']}${data1['id']+1}",
            });
          await firestore.collection("Clubs")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("fields")
              .doc("fields").update({
            'fields': dataList2,
          });
            await DatabaseHelper1.instance.insertAppUsage(AppUsage3(
              image: imageUrl, fieldname:"${data2?['Clubname']}${data1['id']+1}",
            ));
          }else{
            dataList2.add({
              "id": 1,
              "image": imageUrl,
              "fieldname":"${data2?['Clubname']}${1}",
            });
            await firestore.collection("Clubs")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("fields")
                .doc("fields").set({
              'fields': dataList2,
            });
            await DatabaseHelper1.instance.insertAppUsage(AppUsage3(
              image: imageUrl, fieldname:"${data2?['Clubname']}${1}",
            ));
          }
          imagesf = await DatabaseHelper1.instance.getAppUsages();
          for (final item in imagesf) {
            if(!imagefdata.any((element) => element["id"]==item.id)){
            imagefdata.add({
              "id": item.id,
              "image": item.image,
              "fieldname": item.fieldname,
            });
          }}
        Navigator.of(context,rootNavigator: true).pop();
      await fetchAndPostToFirestore0();
    }else{
      await fetchAndPostToFirestore0();
    }

  }

  Future<void> fetchAndPostToFirestore0() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02222),
                const Text('Uploading lineup...'),
              ],
            ),
          ),
        );
      },
    );
    try {
      showToastMessage('Lineup start saving...');
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DatabaseHelper2 dbHelper = DatabaseHelper2.instance;
      List<AppUsage> playersList = await dbHelper.getAppUsages();
      showToastMessage('playersList...');
      DatabaseHelper3 dbHelper1 = DatabaseHelper3.instance;
      List<AppUsage1> subList = await dbHelper1.getAppUsages();
      showToastMessage('SubList...');
      List<Map<String, dynamic>> playersData = playersList.map((player) => player.toMap()).toList();
      List<Map<String, dynamic>> subsData = subList.map((player) => player.toMap()).toList();
      showToastMessage('to List map...');
      await firestore.collection('Matches')
          .doc(widget.matchId)
          .collection('Players')
          .doc(userId)
          .set({
        'players': playersData,
        'subs': subsData,
        'formation': lineup.text,
        'color': color,
        'image': image,
        'width': MediaQuery.of(context).size.width,
        'height': MediaQuery.of(context).size.height,
      });
      showToastMessage('Lineup saving to firestore');
      NotifyFirebase().sendmatchlineupNotifications(userId, widget.matchId);
      showToastMessage('notification sent');
      Navigator.of(context,rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 500));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 50),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02222),
                  const Text('Lineup uploaded successfully!'),
                ],
              ),
            ),
          );
        },
      );
      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.of(context,rootNavigator: true).pop();
    } catch (e) {
      Navigator.of(context,rootNavigator: true).pop();
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('An error occurred while uploading the lineup. Please try again.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      );
    }
  }
  String message3='shared their line_up';
  String time='00:00';
  double radius=16;
  double radius1=18;
  int s=0;

  List<Color> colors = [
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.red,
    Colors.white,
    Colors.green,
    Colors.indigo,
    Colors.orange,
    Colors.blueGrey,
    Colors.green,
    Colors.grey,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.yellow,
    Colors.lime
  ];
  String color=Colors.blue.value.toString();
  Color tcolor=Colors.black;
  late Future<QuerySnapshot>data;
  @override
  void initState(){
    super.initState();
    data=FirebaseFirestore.instance
        .collection('Clubs')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('clubsteam').get();
    getdata(true);
    getdata(false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations( [DeviceOrientation.landscapeLeft]);
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
  Future<String> uploadImageToStorage(String image) async {
    File imageFile = File(image);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Matches')
          .child('images')
          .child('$fileName.jpg');

      final uploadTask = ref.putFile(imageFile);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: null,
                ),
                SizedBox(height: 16.0),
                Text('Uploading field image...'),
              ],
            ),
          );
        },
      );
      uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                  ),
                  Text('Uploading field image... ${(progress * 100).toStringAsFixed(2)}%'),
                ],
              ),
            );
          },
        );
      });
      final snapshot = await uploadTask.whenComplete(() {});
      if (snapshot.state == firebase_storage.TaskState.success) {
        String imageURL = await ref.getDownloadURL();
        return imageURL;
      } else {
        dialog1('');
        return '';
      }
    } catch (e) {
   dialog1(e.toString());
      return '';
    }
  }
  void dialog1(String e){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: MediaQuery.of(context).size.height*0.02222),
                Text('Image upload task failed:$e'),
              ],
            ),
          ),
        );
      },
    );
  }
  bool isAssetsPath(String input) {
    return input.startsWith('assets');
  }
  bool isNetwork(String input){
    return input.startsWith('https');
  }
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
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    super.dispose();
  }
  List<AppUsage3> imagesf=[];
  Set<Map<String, dynamic>>imagefdata={};
String imageurl='';
  void getdata(bool load)async{
    try {
      if(load){
        imagefdata.add({
          "id":100,
          "image":"action",
          "fieldname":"choose field from gallery",
        });
      imagesf = await DatabaseHelper1.instance.getAppUsages();
      if(imagesf.isNotEmpty){
      for (final item in imagesf) {
        imagefdata.add({
          "id": item.id,
          "image": item.image,
          "fieldname": item.fieldname,
        });
      }}else{
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection("Clubs")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("fields")
            .doc("fields").get();
        if(documentSnapshot.exists){
          var data = documentSnapshot.data() as Map<String,dynamic>;
          List<Map<String, dynamic>>data1=List.from(data['fields']);
          imagefdata.addAll(data1.toSet());
        }
      }
      }
    }catch(e){
      imagefdata.clear();
      imagefdata.add({
        "id":100,
        "image":"action",
        "fieldname":"choose field from gallery",
      });
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection("Clubs")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("fields")
        .doc("fields").get();
    if(documentSnapshot.exists){
      var data = documentSnapshot.data() as Map<String,dynamic>;
      List<Map<String, dynamic>>data1=List.from(data['fields']);
      imagefdata.addAll(data1.toSet());
    }
    }
    await DatabaseHelper2.instance.data();
    await DatabaseHelper3.instance.data();
    await displayImage();
  }

  Future<void> displayImage() async {
    AppUsage2? appUsage = await DatabaseHelper.instance.getAppUsage();
    if (appUsage != null) {
      setState(() {
        image=appUsage.image;
       lineup.text =appUsage.formation;
       color=appUsage.color;
        if(appUsage.color==Colors.black.value.toString()){
          tcolor=Colors.white;
        }else{
          tcolor=Colors.black;
        }
      });
    }
  }
  List<Map<String, dynamic>> images = [
    {'genre': 'Football', 'image':'assets/fb.jpeg'},
    {'genre': 'Basketball', 'image':'assets/bkb.jpg'},
    {'genre': 'Handball', 'image':'assets/handball.png'},
    {'genre': 'Rugby', 'image':'assets/rby.jpg'},
    {'genre': 'Volleyball', 'image':'assets/vb.jpg'},
    {'genre': 'Hockey', 'image':'assets/hockey.jpg'},
    {'genre': 'American Football', 'image':'assets/americanfootball.png'},
  ];
  String image='assets/fb.jpeg';

  List<Map<String,dynamic>>items1=[];
  List<Map<String,dynamic>>subs1=[];
  List<Widget>widgets=[SizedBox(
    width: 80, // Width of the shirt
    height: 90, // Height of the shirt
    child: Stack(
      fit: StackFit.expand,
      children: [
        // Shirt shape
        CustomPaint(
          painter: ShirtPainter(color: Colors.brown),
        ),
        Align(
          alignment: const Alignment(0.0,-0.5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                const Text(
                  'My Shirt',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  '7',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 25, // Width of the image container
                  height: 25, // Height of the image container
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage("https://firebasestorage.googleapis.com/v0/b/fans-arena.appspot.com/o/Profilefans%2Fimages%2F1718367152255.jpg?alt=media&token=8f2375fc-3155-4ae3-a453-b0ac1499fea2"), // Replace with your image asset
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  ),];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back,color: Colors.black,)),
        elevation: 1,
        title: const Text('LineUp',style: TextStyle(color: Colors.black),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 40,
              width: MediaQuery.of(context).size.width*0.3,
              child: TextFormField(
                controller: lineup,
                decoration: InputDecoration(
                  labelText: 'Formation,...Optional',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                        color: Colors
                            .grey),
                    borderRadius: BorderRadius
                        .circular(8),
                  ),
                ),
              ),
            ),
          ),
          PopupMenuButton<String>(
            padding:  const EdgeInsets.only(left:6,right: 6),
            position: PopupMenuPosition.under,
            icon: const Icon(Icons.add,color: Colors.black,),
            onSelected: (value) async {
              if(value=='action'){
                FilePickerResult? result =
                await FilePicker.platform.pickFiles(type: FileType.image);
                if (result != null && result.files.isNotEmpty) {
                  File imageFile = File(result.files.single.path!);
                  setState(() {
                    image = imageFile.path;
                  });
                }}else{
                setState(() {
                  image=value;
                });
              }
            },
            itemBuilder: (BuildContext context) {
              return imagefdata.map((d) =>
                 PopupMenuItem<String>(
                  value:d['image'],
                  child: Text(d['fieldname']),
                ),
              ).toList();
            },
          ),
          PopupMenuButton<String>(
            padding: const EdgeInsets.only(left:6,right: 6),
            position: PopupMenuPosition.under,
            icon: const Icon(Icons.color_lens_outlined),
            onSelected: (value) {
              setState(() {
                color = value;
                if(value==Colors.black.value.toString()){
                  tcolor=Colors.white;
                }else{
                  tcolor=Colors.black;
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return colors.map<PopupMenuEntry<String>>((item) {
                return PopupMenuItem<String>(
                  value: item.value.toString(),
                  child: Center(
                    child: Container(
                      height: 25,
                      width: 40,
                      color: item,
                    ),
                  ),
                );
              }).toList();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left:6,right: 6),
            child: IconButton(onPressed: ()async{
              showToastMessage('Saving Lineup on the device...');
              for(final item in items1){
                await DatabaseHelper2.instance.updateAppUsage(AppUsage(
                  userId:item['userId'],
                  identity:item['identity'],
                  time:item['time'],
                  y:item['y'],
                  x: item['x'],
                  card:"0",
                ));
              }
              await DatabaseHelper.instance.deleteAllAppUsage();
              await DatabaseHelper.instance.insertAppUsage(AppUsage2(
                  image: image, formation:lineup.text,color:color,
              ));
              for(final item in subs1){
                await DatabaseHelper3.instance.updateAppUsage(AppUsage1(
                  userId:item['userId'],
                  identity:item['identity'],
                  time:item['time'],
                  y:item['y'],
                  x: item['x'],
                  card:"0",
                ));
              }
              getdata(false);
              showToastMessage('Lineup saved on the device');
            }, icon: const Icon(Icons.save,color: Colors.black,)),
          ),
          Padding(
            padding: const EdgeInsets.only(left:6,right: 6),
            child: IconButton(onPressed: ()async{
              showToastMessage('Saving Lineup on the device...');
              EventLogger().logButtonPress('post lineup', 'post lineup');
              for(final item in items1){
                await DatabaseHelper2.instance.updateAppUsage(AppUsage(
                  userId:item['userId'],
                  identity:item['identity'],
                  time:item['time'],
                  y:item['y'],
                  x: item['x'],
                  card: "0",
                ));
              }
              await DatabaseHelper.instance.deleteAllAppUsage();
              await DatabaseHelper.instance.insertAppUsage(AppUsage2(
                image: image, formation:lineup.text,color:color,
              ));
              for(final item in subs1){
                await DatabaseHelper3.instance.updateAppUsage(AppUsage1(
                  userId:item['userId'],
                  identity:item['identity'],
                  time:item['time'],
                  y:item['y'],
                  x: item['x'],
                  card: "0",
                ));
              }
              showToastMessage('Lineup saved on the device');
              await fetchAndPostToFirestore();
              getdata(false);
            }, icon: const Icon(Icons.upload,color: Colors.black,)),
          ),
          Padding(
            padding: const EdgeInsets.only(left:6,right: 6),
            child: IconButton(onPressed: ()async{
              showDialog(context: context, builder: (context){
                return AlertDialog(
                  title: const Text('Delete all line-up data'),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('cancel')),
                        TextButton(onPressed: ()async{
                          showToastMessage('Deleting Lineup on the device...');
                          await DatabaseHelper2.instance.deleteAllAppUsage();
                          await DatabaseHelper3.instance.deleteAllAppUsage();
                          await DatabaseHelper.instance.deleteAllAppUsage();
                          getdata(false);
                          showToastMessage('Lineup  deleted on the device...');
                          Navigator.pop(context);
                        }, child: const Text('delete'))
                      ],
                    )
                  ],
                );
              });
            }, icon: const Icon(Icons.delete,color: Colors.black,)),
          ),
          Padding(
            padding: const EdgeInsets.only(left:6,right: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Fields',style: TextStyle(color: Colors.black),),
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  position: PopupMenuPosition.under,
                  icon: const Icon(Icons.arrow_drop_down,color: Colors.black,),
                  onSelected: (value) {
                    setState(() {
                      image = value;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return images.map<PopupMenuEntry<String>>((item) {
                      return PopupMenuItem<String>(
                        value: item['image'],
                        child: Text(item['genre']),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          )
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              child: Column(
                children: [
                  Container(
                    height: 20,
                    color: Colors.blue,
                    child: const Center(child: Text('All players',style: TextStyle(fontWeight: FontWeight.bold),)),
                  ),
                  Expanded(
                    child: FutureBuilder<QuerySnapshot>(
                      future:data,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text('Members not yet added')); // Handle case where there are no likes
                        } else {
                          final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
                          List<Map<String, dynamic>> allLikes = [];
                          List<Map<String, dynamic>> tableColumns = [];
                          for (final document in likeDocuments) {
                            final List<dynamic> likesArray = document['clubsteam'];
                            final List<dynamic> likesArray1 = document['clubsTeamTable'];
                            allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                            tableColumns.addAll(likesArray1.cast<Map<String, dynamic>>());
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: allLikes.length,
                            itemBuilder: (context, index) {
                              final data=allLikes[index];
                              return ListTile(
                                onTap: (){
                                  showDialog(context: context, builder: (context){
                                    return AlertDialog(
                                      content:const Text('choose player options'),
                                      actions: [
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children:[
                                              TextButton(onPressed: ()async{
                                                await DatabaseHelper2.instance.insertAppUsage(
                                                    AppUsage(
                                                      userId: data[tableColumns[1]['fn']],
                                                      identity:data[tableColumns[3]['fn']] ,
                                                      y: 0.0,
                                                      x: 0.0,
                                                      time:"",
                                                      card: "0",
                                                     )
                                                );
                                                Navigator.pop(context);
                                              }, child:const Text('start')),
                                              TextButton(onPressed: () async {
                                                setState(() {
                                                  subs1.add(allLikes[index]);
                                                });
                                                await DatabaseHelper3.instance.insertAppUsage(
                                                    AppUsage1(
                                                      userId: data[tableColumns[1]['fn']],
                                                      identity:data[tableColumns[3]['fn']] ,
                                                      y: 0.0,
                                                      x: 0.0,
                                                      time: "",
                                                      card:"0",)
                                                );
                                                Navigator.pop(context);
                                              }, child:const Text('sub')),])
                                      ],
                                    );
                                  });
                                },
                                title:CustomNameAvatarL(userId: data[tableColumns[1]['fn']],radius: 14, style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.normal,
                                ), maxsize: 70,), // Use null-aware operator
                                subtitle: Center(child: data[tableColumns[3]['fn']].toString().isEmpty?const Text('-',style: TextStyle(fontSize: 18),): Text(data[tableColumns[3]['fn']].toString()),),
                                trailing:FittedBox(fit: BoxFit.scaleDown,
                                    child: SizedBox(child: Status1(status:data['status'].toString() ,),)) ,// Use null-aware operator
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

      Container(
        width: MediaQuery.of(context).size.width * 0.635,
        decoration: BoxDecoration(
          image: isAssetsPath(image)
              ? DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
          )
              : isNetwork(image)
              ? DecorationImage(
            image: NetworkImage(image),
            fit: BoxFit.cover,
          )
              : DecorationImage(
            image: FileImage(File(image)),
            fit: BoxFit.cover,
          ),
        ),
      child: StreamBuilder<List<AppUsage>>(
                  stream: DatabaseHelper2.instance.appUsageStream,
                  builder: (BuildContext context, AsyncSnapshot<List<AppUsage>> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      List<AppUsage> players = snapshot.data ?? [];
                      return Stack(
                        children: players.map<Widget>((player) {
                          return Positioned(
                            left: player.x,
                            top: player.y,
                            child: Draggable(
                              feedback: const Material(
                                child: SizedBox.shrink(),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap:(){
                                      showDialog(context: context, builder: (context){
                                        return AlertDialog(
                                          title: const Text('Remove Player'),
                                         actions: [
                                           Row(
                                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                             children: [
                                               TextButton(onPressed: ()async{
                                                 setState(() {
                                                   players.remove(player);
                                                   items1.removeWhere((element) => element["userId"]==player.userId);
                                                 });
                                                 await  DatabaseHelper2.instance.remove(player.userId);
                                                 await DatabaseHelper2.instance.data();
                                                 Navigator.pop(context);
                                               }, child: const Text('remove')),
                                               TextButton(onPressed: (){
                                                 Navigator.pop(context);
                                                 }, child: const Text('cancel')),
                                             ],
                                           )
                                         ],
                                        );
                                      });
                                    },
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: Stack(
                                        children: [
                                          CustomAvatarM(userId: player.userId, radius: 18),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              height: 22,
                                              width: 22,
                                              decoration:  BoxDecoration(
                                                color: Color(int.parse(color)),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(child: Text(player.identity.toString() ?? '',style: TextStyle(color: tcolor),)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 2,),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(int.parse(color)),
                                    ),
                                    child: TexTW1(userId:player.userId,color: tcolor,),
                                  ),
                                ],
                              ),
                              onDragUpdate: (details)  {
                                double y = player.y + details.delta.dy * 0.8;
                                double x = player.x + details.delta.dx * 0.8;
                                setState(() {
                                  player.y = y;
                                  player.x = x;
                                  int existingIndex = items1.indexWhere((item) => item['userId'] == player.userId);
                                  if (existingIndex != -1) {
                                    items1[existingIndex]['y'] = y;
                                    items1[existingIndex]['x'] = x;
                                  } else {
                                    items1.add({
                                      'userId': player.userId,
                                      'y': y,
                                      'x': x,
                                      'identity': player.identity,
                                      'time': player.time,
                                      'card':player.card,
                                    });
                                  }
                                });
                              },

                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                )
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.18,
              child: Column(
                children: [
                  Container(
                    height: 20,
                    color: Colors.blue,
                    child: const Center(child: Text('Sub players',style: TextStyle(fontWeight: FontWeight.bold),)),
                  ),
                  Expanded(
                    child: StreamBuilder<List<AppUsage1>>(
                        stream: DatabaseHelper3.instance.appUsageStream,
                        builder: (BuildContext context, AsyncSnapshot<List<AppUsage1>> snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          } else {
                            List<AppUsage1> subs = snapshot.data ?? [];
                            return ListView.builder(
                              itemCount: subs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: (){
                                    showDialog(context: context, builder: (context){
                                      return AlertDialog(
                                        title: const Text('Remove sub Player'),
                                        actions: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TextButton(onPressed: ()async{
                                                await  DatabaseHelper3.instance.remove(subs[index].userId);
                                                getdata(false);
                                                setState(() {});
                                                Navigator.pop(context);
                                              }, child: const Text('remove')),
                                              TextButton(onPressed: (){
                                                Navigator.pop(context);}, child: const Text('cancel')),
                                            ],
                                          )
                                        ],
                                      );
                                    });
                                  },
                                  title: CustomNameAvatarL(userId: subs[index].userId,radius: 14, style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.normal,
                                  ), maxsize: 70,), // Use null-aware operator
                                  subtitle: Text(subs[index].identity ?? ''), // Use null-aware operator
                                );
                              },
                            );
                          }}),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class CustomNameAvatarL extends StatefulWidget {
  String userId;
  double radius;
  TextStyle style;
  double maxsize;
  Person? user;
  bool click;
  CustomNameAvatarL({super.key,
    required this.userId,
    required this.style,
    required this.radius,
    required this.maxsize,
    this.user,
    this.click=false,
  });

  @override
  State<CustomNameAvatarL> createState() => _CustomNameAvatarLState();
}

class _CustomNameAvatarLState extends State<CustomNameAvatarL> {
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState(){
    super.initState();
    getData();
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomAvatar(imageurl: url, radius:widget.radius),
            CustomName(username: name, maxsize: widget.maxsize, style: widget.style)
          ],
        ),
      );
    }else{
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomAvatar(imageurl: url, radius:widget.radius),
          CustomName(username: name, maxsize: widget.maxsize, style: widget.style)
        ],
      );
    }
  }
}
//TextWidget
class TexTW extends StatefulWidget {
  String userId;
  Color? color;
   TexTW({super.key,required this.userId,this.color});

  @override
  State<TexTW> createState() => _TexTWState();
}

class _TexTWState extends State<TexTW> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username = 'loading...';

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  void didUpdateWidget(covariant TexTW oldWidget) {
    if (oldWidget.userId != widget.userId) {
      getData();
    }
    if (oldWidget.userId == widget.userId) {
      getData();
    }
    if (widget.userId.isEmpty) {
      getData();
    }
    super.didUpdateWidget(oldWidget);
  }
  String url='';
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        username =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: username,
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
            name: username,
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
      QuerySnapshot querySnapshotD = await firestore
          .collection('Leagues')
          .where('leagueId', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          username = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          username = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          username = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      }else if (querySnapshotD.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotD.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username = name(data['leaguename']);
        });

      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  String name(String name) {
    if (name.length > 7) {
      return "${name.substring(0, 7)}...";
    }else{
      return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(username,style: TextStyle(color: widget.color ?? Colors.black),);
  }
}
class TexTW1 extends StatefulWidget {
  String userId;
  Color? color;
  TexTW1({super.key,required this.userId,this.color});

  @override
  State<TexTW1> createState() => _TexTW1State();
}

class _TexTW1State extends State<TexTW1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String username = 'loading...';

  @override
  void initState() {
    super.initState();
    getData();
  }
  String url='';
  String collectionName='';
  String location="";
  void getData()async{
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        url=appUsage.user.url;
        username =appUsage.user.name;
        collectionName=appUsage.user.collectionName;
        location=appUsage.user.location;
      });
      if(url.isEmpty){
        await getUserData();
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: Person(
              name: username,
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
            name: username,
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
      QuerySnapshot querySnapshotD = await firestore
          .collection('Leagues')
          .where('leagueId', isEqualTo: widget.userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Fan';
          username = data['username'];
          url= data['profileimage'];
          location=data['location'];
        });
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Professional';
          username = data['Stagename'];
          url= data['profileimage'];
          location=data['Location'];
        });
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          collectionName='Club';
          username = data['Clubname'];
          url= data['profileimage'];
          location=data['Location'];
        });
      }else if (querySnapshotD.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotD.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username = name(data['leaguename']);
        });

      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  String name(String name) {
    if (name.length > 7) {
      return "${name.substring(0, 7)}...";
    }else{
      return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(username,style: TextStyle(color: widget.color ?? Colors.black),);
  }
}

class LineUpProvider extends ChangeNotifier{
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> dataList1 = [];
  List<Map<String, dynamic>> dataList = [];
  Color color=Colors.blue;
  Color tcolor=Colors.black;
  late Stream<DocumentSnapshot> _stream4;
  List<Player> players=[];
  List<Sub> subs=[];
  List<Player> players2=[];
  List<Sub> subs2=[];
 void trigger(List<Player>ps)async{
   showToastMessage("loading player Assets...");
   List<Player> players1=[];
   for(final p in ps) {
     UsersData? person = await DatabaseHelper2Users.instance.getUser(p.appusage.userId);
     if (person != null) {
       players1.add(Player(url: person.user.url,
           name: person.user.name, appusage: p.appusage));
       notifyListeners();
     } else {
       Person person = await getUserData(p.appusage.userId);
       players1.add(Player(url: person.url,
           name: person.name, appusage: p.appusage));
       await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
           user: person
       ));
       notifyListeners();
     }
   }
   players=players1;
   showToastMessage("loading player Assets complete");
   notifyListeners();
 }
  void trigger1(List<Sub>ps)async{
    showToastMessage("loading sub Assets...");
    List<Sub> subs1=[];
    for(final p in ps) {
      UsersData? person = await DatabaseHelper2Users.instance.getUser(p.appusage.userId);
      if (person != null) {
        subs1.add(Sub(url: person.user.url,
            name: person.user.name, appusage: p.appusage));
        notifyListeners();
      } else {
        Person person = await getUserData(p.appusage.userId);
        subs1.add(Sub(url: person.url,
            name: person.name, appusage: p.appusage));
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: person
        ));
        notifyListeners();
      }
    }
    subs=subs1;
    showToastMessage("loading sub Assets complete");
    notifyListeners();
  }
  void trigger2(List<Player>ps)async{
    showToastMessage("loading Assets...");
    List<Player> players1=[];
    for(final p in ps) {
      UsersData? person = await DatabaseHelper2Users.instance.getUser(p.appusage.userId);
      if (person != null) {
        players1.add(Player(url: person.user.url,
            name: person.user.name, appusage: p.appusage));
        notifyListeners();
      } else {
        Person person = await getUserData(p.appusage.userId);
        players1.add(Player(url: person.url,
            name: person.name, appusage: p.appusage));
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: person
        ));
        notifyListeners();
      }
    }
    players2=players1;
    showToastMessage("loading Assets complete");
    notifyListeners();
  }
  void trigger3(List<Sub>ps)async{
    List<Sub> subs1=[];
    for(final p in ps) {
      UsersData? person = await DatabaseHelper2Users.instance.getUser(p.appusage.userId);
      if (person != null) {
        subs1.add(Sub(url: person.user.url,
            name: person.user.name, appusage: p.appusage));
        notifyListeners();
      } else {
        Person person = await getUserData(p.appusage.userId);
        subs1.add(Sub(url: person.url,
            name: person.name, appusage: p.appusage));
        await DatabaseHelper2Users.instance.insertAppUsage(UsersData(
            user: person
        ));
        notifyListeners();
      }
    }
    subs2=subs1;
    notifyListeners();
  }
  Future<Person>getUserData(String userId)async{
    try {
      QuerySnapshot querySnapshotA = await _firestore
          .collection('Fans')
          .where('Fanid', isEqualTo: userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotB = await _firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: userId)
          .limit(1)
          .get();
      QuerySnapshot querySnapshotC = await _firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshotA.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotA.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return Person(
            name: data['username'],
            url: data['profileimage'],
            collectionName:'Fan',
            userId: userId

        );
      } else if (querySnapshotB.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotB.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return Person(
            name: data['Stagename'],
            url: data['profileimage'],
            collectionName:'Professional',
            userId: userId

        );
      } else if (querySnapshotC.docs.isNotEmpty) {
        var documentSnapshot = querySnapshotC.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        return Person(
            name: data['Clubname'],
            url: data['profileimage'],
            collectionName:'Club',
            userId: userId

        );
      } else {
        return Person(
            name: '',
            url: '',
            collectionName:'',
            userId:'No such user',
        );
      }
    } catch (e) {
      return Person(
          name: '',
          url: '',
          collectionName:'',
          userId: '$e',
      );
    }
  }
  Future<void> retrievePlayers({required MatchM match}) async {
    final homematch= match.authorId==match.club1.userId?match.matchId:match.match1Id; // if false so match1Id
    _stream4 = _firestore
        .collection('Matches')
        .doc(homematch)
        .collection('Players')
        .doc(match.club1.userId)
        .snapshots();
    _stream4.listen((snapshot){
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<Player> p1=[];
          color=Color(int.parse(data['color']));
          dataList = List<Map<String, dynamic>>.from(data['players']);
          p1= dataList.map((d) => Player(
              url: '',
              name: '',
              appusage: AppUsage(
                  userId: d['userId'],
                  identity:d['identity'],
                  y: d['y'],
                  x: d['x'],
                  time: d['time'],
                  card: d['card']??"0"))).toList();
          List<Sub> p2=[];
          dataList1 = List<Map<String, dynamic>>.from(data['subs']);
          p2= dataList1.map((d) => Sub(
              url: '',
              name: '',
              appusage: AppUsage(
                  userId: d['userId'],
                  identity:d['identity'],
                  y: d['y'],
                  x: d['x'],
                  time: d['time'],
                  card: d['card']??"0"))).toList();
          trigger1(p2);
          notifyListeners();
          trigger(p1);
          if(color==Colors.black){
            tcolor=Colors.white;
          }else{
            tcolor=Colors.black;
          }
          notifyListeners();
      }}
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> dataList3 = [];
  List<Map<String, dynamic>> dataList2 = [];
  Color color1=Colors.blue;
  Color tcolor1=Colors.black;
  Future<void> retrievePlayers1({required MatchM match}) async {
    final awaymatch= match.authorId==match.club2.userId? match.matchId:match.match1Id;
    _stream4 = _firestore
        .collection('Matches')
        .doc(awaymatch)
        .collection('Players')
        .doc(match.club2.userId)
        .snapshots();
    _stream4.listen((snapshot){
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          List<Player> p1=[];
          color1=Color(int.parse(data['color']));
          dataList2 = List<Map<String, dynamic>>.from(data['players']);
          p1= dataList2.map((d) => Player(
              url: '',
              name: '',
              appusage: AppUsage(
                  userId: d['userId'],
                  identity:d['identity'],
                  y: d['y'],
                  x: d['x'],
                  time: d['time'],
                  card:d['card']??"0"))).toList();
          List<Sub> p2=[];
          dataList3 = List<Map<String, dynamic>>.from(data['subs']);
          p2= dataList3.map((d) => Sub(
              url: '',
              name: '',
              appusage: AppUsage(
                  userId: d['userId'],
                  identity:d['identity'],
                  y: d['y'],
                  x: d['x'],
                  time: d['time'],
                  card: d['card']??"0"))).toList();
          trigger3(p2);
          notifyListeners();
          trigger2(p1);
          if(color1==Colors.black){
            tcolor1=Colors.white;
          }else{
            tcolor1=Colors.black;
          }
          notifyListeners();
        }}
    });
    notifyListeners();
  }

  List<Map<String, dynamic>> dataCList = [];
  List<Map<String, dynamic>> dataCList2 = [];

  Future<void> retrieveCPlayers({required String matchId,required String userId}) async {
    _stream4 = _firestore
        .collection('Matches')
        .doc(matchId)
        .collection('Players')
        .doc(userId)
        .snapshots();
    _stream4.listen((snapshot){
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        List<Player> p1=[];
        List<Sub> p2 = [];
        if (data != null) {
          color=Color(int.parse(data['color']));
          dataCList = List<Map<String, dynamic>>.from(data['players']);
          dataCList2 = List<Map<String, dynamic>>.from(data['subs']);
          p1= dataCList.map((d) => Player(
              url: '',
              name: '',
              appusage: AppUsage(
                  userId: d['userId'],
                  identity:d['identity'],
                  y: d['y'],
                  x: d['x'],
                  time: d['time'],
                  card:d['card']??"0"))).toList();
          p2 = dataCList2.map((d) => Sub(
              url: '',
              name: '',
              appusage: AppUsage(
                  userId: d['userId'],
                  identity: d['identity'],
                  y: d['y'],
                  x: d['x'],
                  time: d['time'],
                  card: d['card']??"0"))).toList();
          trigger1(p2);
          trigger(p1);
          notifyListeners();
          if(color==Colors.black){
            tcolor=Colors.white;
          }else{
            tcolor=Colors.black;
          }
          notifyListeners();
        }}
    });
    notifyListeners();
  }

}
class Player{
  AppUsage appusage;
  String name;
  String  url;
  Player({required this.url,required this.name,required this.appusage});
}
class Sub{
  AppUsage appusage;
  String name;
  String  url;
  Sub({required this.url,required this.name,required this.appusage});
}


class ShirtPainter extends CustomPainter {
  Color color;
  ShirtPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    Path path = Path();
    double w = size.width;
    double h = size.height*0.7;
    // Define height proportions for the shirt
    double upperHeight = h * 1/3; // 1/3 of the height for the upper side
    double lowerHeight = h * 2/3; // 2/3 of the height for the bottom
    // Adjustment to reduce the distance from the top to the center
    double adjustment = 5; // Amount to reduce (additional reduction)
    // Calculate new top shoulder and sleeve positions
    double adjustedUpperHeight = upperHeight - adjustment;
    double sleeveHeight = upperHeight + (lowerHeight * 0.25) - adjustment;
    // Start at the top left of the collar
    path.moveTo(w * 0.35, h * 0.05);
    // Draw left shoulder with adjusted height
    path.lineTo(w * 0.1, h * (adjustedUpperHeight / h));
    // Draw left sleeve
    path.lineTo(0, h * (sleeveHeight / h)); // Left sleeve bottom
    path.lineTo(w * 0.2, h * (sleeveHeight / h)); // Flat transition to the armpit
    // Draw left side of the shirt
    path.lineTo(w * 0.2, h * (upperHeight + lowerHeight) / h);
    // Draw smoother curved bottom of the shirt
    path.quadraticBezierTo(w * 0.5, h, w * 0.8, h);
    // Draw right side of the shirt
    path.lineTo(w * 0.8, h * (sleeveHeight / h));
    // Draw right sleeve
    path.lineTo(w, h * (sleeveHeight / h)); // Right sleeve bottom
    path.lineTo(w * 0.9, h * (adjustedUpperHeight / h)); // Adjusted shoulder point
    // Draw right shoulder with adjusted height
    path.lineTo(w * 0.65, h * 0.05);
    // Draw the flat top collar
    path.lineTo(w * 0.35, h * 0.05); // Closing the top collar path
    // Close the path to form the shirt shape
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
