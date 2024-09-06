import 'package:fans_arena/clubs/screens/lineupcreation.dart';
import 'package:flutter/material.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../fans/bloc/usernamedisplay.dart';
import '../../fans/components/likebutton.dart';
import '../../fans/components/likebuttonfanstv.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/debate.dart';
import '../../fans/screens/newsfeed.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../data/screens/feed_item.dart';

class RLayout extends StatefulWidget {
  MatchM matches;
  RLayout({super.key,required this.matches});

  @override
  State<RLayout> createState() => _RLayoutState();
}

class _RLayoutState extends State<RLayout> {
  double radius=24;
  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10,left: 10,top: 5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.95,
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    color: Colors.white60,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                color: Colors.white,
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
                          child: Padding(
                            padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                          CustomAvatar( radius: radius, imageurl:widget.matches.club1.url),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10,right: 1),
                                            child: Center(child: Text('${widget.matches.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5,top: 5),
                                        child:  CustomName(
                                          username: widget.matches.club1.name,
                                          maxsize: 90,
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
                                      widget.matches
                                          .status != '0'||widget.matches.duration!=0 ?Time(matchId: widget.matches.matchId, club1Id: widget.matches.club1.userId, ): Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .spaceEvenly,
                                        children: [
                                          Text(widget.matches
                                              .createdat),
                                          Text(widget.matches
                                              .starttime),
                                        ],
                                      ),
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
                                        padding: const EdgeInsets.only(left: 5,top:5),
                                        child: CustomName(
                                          username: widget.matches.club2.name,
                                          maxsize: 90,
                                          style:const TextStyle(color: Colors.black,fontSize: 16),),
                                      ),
                                    ],
                                  ),
                                ),

                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              height: 28,
                              width: MediaQuery.of(context).size.width*0.35,
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 3, right: 2),
                                    child: Icon(Icons.location_on_outlined,color: Colors.black,),
                                  ),
                                  SizedBox(
                                      width: 120,
                                      height: 20,
                                      child: OverflowBox(
                                          child: Text(
                                            overflow: TextOverflow.ellipsis,
                                            maxLines:1,
                                            widget.matches.location,style: const TextStyle(color: Colors.black,fontSize: 15),))),
                                ],
                              ),
                            ),
                            TextButton(onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Stats( matches: widget.matches,)));
                            } , child: const Text('Stats'),),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

      ],
    );

  }
}


class Stats extends StatefulWidget {
  final MatchM matches;
  Stats({super.key, required this.matches});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  double duration = 0;
  ViewsProvider v = ViewsProvider();
  late LikingProvider liking = LikingProvider();

  @override
  void initState() {
    super.initState();
    retrieveUserData0();
    v.getViews("Matches", widget.matches.matchId);
    liking.getAllikes("Matches", widget.matches.matchId);
    pauseTime(matchId: widget.matches.matchId);
    pauseTime1(matchId: widget.matches.matchId);
  }

  void retrieveUserData0() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Matches')
          .doc(widget.matches.matchId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        int d = 0;
        setState(() {
          d = data['duration'] ?? 0;
          duration = d / 60;
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  String date = '';
  String hour1 = '';
  String hour2 = '';
  String minute1 = '';
  String minute2 = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _stream1;

  void pauseTime({required String matchId}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue = (snapshot.data() as Map<String, dynamic>)['starttime'];
      setState(() {
        DateTime starttime = newValue.toDate();
        date = DateFormat('d MMM').format(starttime);
        int hour = starttime.hour;
        int minute = starttime.minute;
        hour1 = hour.toString().padLeft(2, '0');
        minute1 = minute.toString().padLeft(2, '0');
      });
    });
  }

  void pauseTime1({required String matchId}) {
    _stream1 = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue0 = (snapshot.data() as Map<String, dynamic>)['stoptime'];
      setState(() {
        DateTime stoptime = newValue0.toDate();
        int hour = stoptime.hour;
        int minute = stoptime.minute;
        hour2 = hour.toString().padLeft(2, '0');
        minute2 = minute.toString().padLeft(2, '0');
      });
    });
  }

  double radius = 26;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Match Stats',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 250,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) {
                                                    if (widget.matches.club1.collectionName == 'Club') {
                                                      return AccountclubViewer(user: widget.matches.club1, index: 0);
                                                    } else if (widget.matches.club1.collectionName == 'Professional') {
                                                      return AccountprofilePviewer(user: widget.matches.club1, index: 0);
                                                    } else {
                                                      return Accountfanviewer(user: widget.matches.club1, index: 0);
                                                    }
                                                  },
                                                ));
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  CustomAvatar(radius: radius, imageurl: widget.matches.club1.url),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: CustomName(
                                                      username: widget.matches.club1.name,
                                                      maxsize: 90,
                                                      style: const TextStyle(color: Colors.black, fontSize: 15),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 35,
                                              child: widget.matches.club1.collectionName!="Club"?SizedBox.shrink():TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LineUpA(match: widget.matches)));
                                                },
                                                child: const Text('LineUp'),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  '${widget.matches.score1} VS ${widget.matches.score2}',
                                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              const SizedBox(height: 27),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                Navigator.push(context, MaterialPageRoute(
                                                  builder: (context) {
                                                    if (widget.matches.club2.collectionName == 'Club') {
                                                      return AccountclubViewer(user: widget.matches.club2, index: 0);
                                                    } else if (widget.matches.club2.collectionName == 'Professional') {
                                                      return AccountprofilePviewer(user: widget.matches.club2, index: 0);
                                                    } else {
                                                      return Accountfanviewer(user: widget.matches.club2, index: 0);
                                                    }
                                                  },
                                                ));
                                              },
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  CustomAvatar(radius: radius, imageurl: widget.matches.club2.url),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: CustomName(
                                                      username: widget.matches.club2.name,
                                                      maxsize: 90,
                                                      style: const TextStyle(color: Colors.black, fontSize: 15),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 35,
                                              child: widget.matches.club1.collectionName!="Club"?SizedBox.shrink():TextButton(
                                                onPressed: () {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => LineUpB(match: widget.matches)));
                                                },
                                                child: const Text('LineUp'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 35,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => MatchComments(matchId: widget.matches.matchId, authorId: widget.matches.authorId)));
                                      },
                                      child: Column(
                                        children: [
                                          const Text('Match Comments'),
                                          MatchcommentsH1(matchId: widget.matches.matchId),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        const Text('Match Likes'),
                                        AnimatedBuilder(
                                          animation: liking,
                                          builder: (BuildContext context, Widget? child) {
                                            if(liking.likes.isEmpty){
                                              return const Text('0');
                                            }else{
                                            return LikesCountWidget1(totalLikes: liking.likes.length);
                                          }},
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              date.isNotEmpty
                                  ? SizedBox(
                                height: 40,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('Started At: $hour1:$minute1'),
                                    Text('Date: $date'),
                                    Text('Ended At: $hour2:$minute2'),
                                  ],
                                ),
                              )
                                  : const Text(''),
                              SizedBox(
                                height: 35,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        const Text('Match Views'),
                                        AnimatedBuilder(
                                          animation: v,
                                          builder: (BuildContext context, Widget? child) {
                                            if(v.views.isEmpty){
                                              return const Text('0');}else{
                                              return ViewsCount(totalLikes: v.views.length, color: Colors.black);
                                            }},
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        const Text('Duration'),
                                        Text('$duration Min'),
                                      ],
                                    ),
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
              ),
            ];
          },
          body: Scorers(matchId: widget.matches.matchId),
        ),
      ),
    );
  }
}

class MatchcommentsH1 extends StatelessWidget {
  final String matchId;

  const MatchcommentsH1({super.key, required this.matchId});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Matches')
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
                allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                totalLikes=allLikes.length;
              }
              if(totalLikes>999){
                return Text('${totalLikes/1000}K');
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M');
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B');
              } else {
                return Text(
                  '$totalLikes',
                );
              }
            }
          }),
    );
  }
}
class MatchComments extends StatefulWidget {
  String matchId;
  String authorId;
  MatchComments({super.key,
    required this.matchId,
    required this.authorId});

  @override
  State<MatchComments> createState() => _MatchCommentsState();
}

class _MatchCommentsState extends State<MatchComments> {
  bool ascending=true;
  late Future<List<Comment>>data;
  @override
  void initState() {
    super.initState();
    data=DataFetcher().getcommentdata(docId: widget.matchId, collection: 'Matches', subcollection: 'comments');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Match Comments',style: TextStyle(color: Colors.black),),
        elevation: 1,
          actions: [
      SizedBox(
      width: MediaQuery.of(context).size.width*0.35,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(onPressed: (){
            setState(() {
              data=DataFetcher().getcommentdata(docId: widget.matchId, collection: 'Matches', subcollection: 'comments');
            });
          }, icon: const Icon(Icons.refresh,size: 30,color: Colors.black,)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort,color: Colors.black,),
            onSelected: (value) {
              if(value=='1'){

              }else if (value=='2'){
                setState(() {
                  ascending=!ascending;
                });
              }
              // Do something when a menu item is selected
              print('You selected "$value"');
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: '1',
                  child: Text('Top most comment'),
                ),
                PopupMenuItem<String>(
                  value: '2',
                  child: Text(ascending?'Latest comment':'Oldest comment'),
                ),
              ];
            },
          ),
        ],
      ),
    )]
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: FutureBuilder<List<Comment>>(
            future: data,
            builder: (context, snapshot){
              if(snapshot.connectionState==ConnectionState.waiting){
                return const CommentShimmer();
              }else if(snapshot.hasError){
                return Text('${snapshot.error}');
              }else if(!snapshot.hasData||snapshot.data!.isEmpty){
                return const Center(child: Text("No Comments"),);
              }else if(snapshot.hasData){
                List<Comment>matches=snapshot.data!;
                if(ascending){
                  matches .sort((a, b) {
                    Timestamp adate = a.timestamp;
                    Timestamp bdate = b.timestamp;
                    return adate.compareTo(bdate);
                  });
                }else{
                  matches .sort((a, b) {
                    Timestamp adate = a.timestamp;
                    Timestamp bdate = b.timestamp;
                    return bdate.compareTo(adate);
                  });}
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
                      formattedTime = DateFormat('d MMM').format(createdDateTime); // Format the date as desired
                    }
                    String hours = DateFormat('HH').format(createdDateTime);
                    String minutes = DateFormat('mm').format(createdDateTime);
                    String t = DateFormat('a').format(createdDateTime); // AM/PM
                    return Padding(
                      padding: const EdgeInsets.only(top:3 ,bottom: 3),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
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
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: CustomAvatar(radius: 16, imageurl: comments.user.url),
                                    ),
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context){
                                                  if(comments.user.collectionName=='Club'){
                                                    return AccountclubViewer(user: comments.user, index: 0);
                                                  }else if(comments.user.collectionName=='Professional'){
                                                    return AccountprofilePviewer(user: comments.user, index: 0);
                                                  }else{
                                                    return Accountfanviewer(user: comments.user, index: 0);
                                                  }
                                                }
                                            ),
                                          );
                                        },
                                        child: CustomName(username:comments.user.name,style: const TextStyle(color: Colors.black,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,), maxsize: 140,)
                                    ),
                                    comments.user.userId==widget.matchId?const Row(
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
                                      child: Text(formattedTime,style: const TextStyle(fontSize: 14),),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 40,right: 5),
                                  child: InkWell(
                                      onTap: (){

                                      },
                                      child: Text(comments.comment)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }else{
                return const SizedBox.shrink();
              }
    }),
      ),
    );
  }
}
class Scorers extends StatefulWidget {
  String matchId;
  Scorers({super.key,required this.matchId});

  @override
  State<Scorers> createState() => _ScorersState();
}

class _ScorersState extends State<Scorers> {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('Matches')
            .doc(widget.matchId).
        collection('scorers')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Scorers'));
          } else {
            final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!.docs;
            List<Map<String, dynamic>> allLikes = [];
            for (final document in likeDocuments) {
              final List<dynamic> likesArray = document['scorers'];
              allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
            }
            return Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('match scorers'),
                    DataTable(
                      columnSpacing: MediaQuery.of(context).size.width*0.03,
                      columns: const [
                        DataColumn(label: Text('Rank')),
                        DataColumn(label: Text("Player")),
                        DataColumn(label: Text('Time')),
                        DataColumn(label: Text('Goals')),
                        // Add more DataColumn widgets for additional fields
                      ],
                      rows: allLikes.map((data) {
                        int index = allLikes.indexOf(data);
                       int time = data['time'] ?? 0;
                        int goal = data['goal'] ?? 0;
                        int minutes = time ~/ 60;
                        int remainingSeconds = time % 60;
                        String minutesString = minutes.toString().padLeft(2, '0');
                        String secondsString = remainingSeconds.toString().padLeft(2, '0');
                        return DataRow(cells: [
                          DataCell(Center(child: Text('${index +1}'))),
                          DataCell(CustomNameAvatar(userId:data['userId'], style:const TextStyle(color: Colors.black), radius: 16, maxsize: 120,click: true,)),
                          DataCell(Center(child: Text("$minutesString:$secondsString"))),
                          DataCell(Center(child: Text('$goal'))),
                          // Add more DataCell widgets for additional fields
                        ]);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }
        },
    );
  }
}

class LineUpA extends StatefulWidget {
MatchM match;
  LineUpA({super.key,
    required this.match,
   });

  @override
  State<LineUpA> createState() => _LineUpAState();
}

class _LineUpAState extends State<LineUpA> with SingleTickerProviderStateMixin{
  String image='assets/fb.jpeg';
  late  LineUpProvider lineup;
  String formation='';
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations( [DeviceOrientation.landscapeLeft]);
    lineup=LineUpProvider();
    lineup.retrievePlayers(match:widget.match);
    retrieveUserData0();
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
    lineup.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    super.dispose();

  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
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
          // other fields from the Fans collection
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
  double radius=23;
  double radius1=16;
  double deviceH=1.0;
  double deviceW=1.0;
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
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:3,left: 5,right: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  formation.isNotEmpty?Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('formation: $formation'),
                  )):const SizedBox(height: 0,),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
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

                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.26,
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
                                  columnSpacing: MediaQuery.of(context).size.width * 0.03,
                                  columns: const [
                                    DataColumn(label: Text('Player')),
                                    DataColumn(label: Text('P.no')),
                                    DataColumn(
                                      label: Text('time',),
                                    ),
                                    // Add more DataColumn widgets for additional fields
                                  ],
                                  rows: lineup.subs.map((player) {
                                            return DataRow(cells: [
                                             DataCell(
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CustomAvatar(imageurl: player.url, radius: 16,),
                                              Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child:TexT(name: player.name)),
                                            ],
                                          ),
                                        ),
                                        DataCell(Center(child: Text(player.appusage.identity))),
                                        DataCell(Center(child: Text(player.appusage.time))),
                                        // Add more DataCell widgets for additional fields
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
              ),
              Container(
                width: MediaQuery.of(context).size.width*0.635,
                height: MediaQuery.of(context).size.height*0.85,
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
                          left: dx,
                          top: dy-4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 45,
                                width: 55,
                                child: Stack(
                                  children: [
                                    CustomAvatar(imageurl: player.url, radius: 18,),
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
                                          child: Center(child: Text(player.appusage.identity,style:TextStyle(color:lineup.tcolor))),
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
                                    ),
                                  ],
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
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

            ]),
      ),
    );
  }
}
class LineUpB extends StatefulWidget {
MatchM match;
   LineUpB({super.key,
     required this.match,
     });

  @override
  State<LineUpB> createState() => _LineUpBState();
}

class _LineUpBState extends State<LineUpB> with SingleTickerProviderStateMixin{
  String image='assets/fb.jpeg';
  late  LineUpProvider lineup;
  String formation='';
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations( [DeviceOrientation.landscapeLeft]);
    lineup=LineUpProvider();
    lineup.retrievePlayers1(match:widget.match);
    retrieveUserData0();
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
    lineup.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    super.dispose();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void retrieveUserData0() async {
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
          formation = data['formation'];
          image = data['image'];
          deviceH=data['height'];
          deviceW=data['width'];
          // other fields from the Fans collection
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
  double radius=23;
  double radius1=16;
  double deviceH=1.0;
  double deviceW=1.0;
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
      ),
      body: Padding(
        padding: const EdgeInsets.only(top:3,left: 5,right: 5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  formation.isNotEmpty?Center(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('formation: $formation'),
                  )):const SizedBox(height: 0,),
                  Row(mainAxisAlignment: MainAxisAlignment.center,
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

                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.26,
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
                                  columnSpacing: MediaQuery.of(context).size.width * 0.03,
                                  columns: const [
                                    DataColumn(label: Text('Player')),
                                    DataColumn(label: Text('P.no')),
                                    DataColumn(
                                      label: Text('time',),
                                    ),
                                    // Add more DataColumn widgets for additional fields
                                  ],
                                  rows: lineup.subs2.map(
                                          (player) { return DataRow(cells: [
                                        DataCell(
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CustomAvatar(imageurl: player.url, radius: 16),
                                              Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child:TexT(name: player.name)),
                                            ],
                                          ),
                                        ),
                                        DataCell(Center(child: Text(player.appusage.identity))),
                                        DataCell(Center(child: Text(player.appusage.time))),
                                        // Add more DataCell widgets for additional fields
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
              ),
              Container(
                width: MediaQuery.of(context).size.width*0.635,
                height: MediaQuery.of(context).size.height*0.85,
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
                      children: lineup.players2.map<Widget>((player) {
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
                          left: dx,
                          top: dy-4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 45,
                                width: 55,
                                child: Stack(
                                  children: [
                                    CustomAvatar(imageurl: player.url, radius: 18,),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Container(
                                        height: 23,
                                        width: 23,
                                        decoration:  BoxDecoration(
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
                                              borderRadius: BorderRadius.circular(2.5)
                                          ),
                                          width: 20,
                                          height: 10,
                                        ),
                                      ),
                                    ),
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
                                child: TexT(name:player.name,color: lineup.tcolor1,),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),

            ]),
      ),
    );
  }
}
