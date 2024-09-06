import 'package:fans_arena/professionals/components/profileHeaderWidgetleague.dart';
import 'package:fans_arena/fans/screens/leaguetable.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../professionals/screens/editprofileleagues.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../components/clublist0.dart';
import 'homescreen.dart';
import 'legues.dart';
import 'newsfeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../professionals/components/leaguecomments.dart';
import '../../professionals/components/matches.dart';
import '../../professionals/components/matchfeatureprofessionals.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../professionals/screens/createeventspageleague.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
class LeagueLayout extends StatefulWidget {
  LeagueC league;
  String year;
  LeagueLayout({super.key,required this.league,required this.year});

  @override
  State<LeagueLayout> createState() => _LeagueLayoutState();
}

class _LeagueLayoutState extends State<LeagueLayout> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageurl = '';
  String username = '';
  String fromDate = '';
  String toDate = '';
  VLProvider vl = VLProvider();
  SubscribersProvider sb=SubscribersProvider();
  @override
  void initState() {
    super.initState();
    vl.getAllVisits("Leagues", widget.league.leagueId);
    sb.getAllSubscribers("Leagues", widget.league.leagueId);
    if(FirebaseAuth.instance.currentUser?.uid==widget.league.author.userId){
      setState(() {
        author=true;
      });
    }
    _startTime=DateTime.now();
    if(widget.year.isEmpty){
      setState(() {
        widget.league.leagues.first;
      });
    }
    retrieveUsername1();
  }
  String formattedTime = '';
  String formattedTime1 = '';


  Future<void> retrieveUsername1() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.league.leagueId)
        .collection('year')
        .doc(widget.year)
        .get();

    if (snapshot.exists) {
      final data=snapshot.data() as Map<String,dynamic>;
      setState(() {
        Timestamp fromDate=data['fromDate']??'';
        Timestamp toDate=data['toDate']??'';
        DateTime createdDateTime = fromDate.toDate();
        DateTime createdDateTime1 = toDate.toDate();
        formattedTime = DateFormat('d MMM').format(createdDateTime);
        formattedTime1 = DateFormat('d MMM').format(createdDateTime1);
      });
    }
  }
  String userId='';

  bool isselected = false;

  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('ViewLeagueFans',_startTime,widget.league.leagueId);
    super.dispose();
  }
  int index=0;
  double radius=23;
  bool author=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('League', style: TextStyle(color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: 2,
                        color: Colors.grey[300]!
                    )
                ),
                child: Column(
                  children: [
                    const Text("League Details", style: TextStyle(
                        color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomAvatar(imageurl: widget.league.imageurl, radius: 40),
                            const SizedBox(height: 10,),
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 2,
                                      color: Colors.grey[300]!
                                  )
                              ),
                              child:Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text('Manager ',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                    author? const Text("You",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.blue),): InkWell(
                                        onTap: (){
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AccountprofilePviewer(user:widget.league.author, index: 0)));
                                        },
                                        child: CustomAvatar(radius: 17, imageurl:widget.league.author.url)),

                                  ],
                                ),
                              ) ,
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Text(widget.league.leaguename, style: const TextStyle(
                                color: Colors.black, fontSize: 20,),),
                            ),
                            Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      width: 2,
                                      color: Colors.grey[300]!
                                  )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                     Row(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            const Text('Visits',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                            AnimatedBuilder(animation: vl, builder: (BuildContext context, Widget? child){
                                             return LikesCountWidget(totalLikes:vl.visits.length);
                                            })
                                          ],
                                        ),
                                        const SizedBox(width: 20,),
                                        Column(
                                          children: [
                                            const Text('subscribers',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                            AnimatedBuilder(animation: sb, builder: (BuildContext context, Widget? child){
                                              return LikesCountWidget(totalLikes:sb.likes.length);
                                            })
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            const Text('Genre',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                            Text(widget.league.genre)
                                          ],
                                        ),
                                        const SizedBox(width: 20,),
                                        Column(
                                          children: [
                                            const Text('Location',style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                                            Text(widget.league.location)
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10,),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              const Text("Season", style: TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 10,),
              Container(
                width: 65,
                height: 35,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        width: 2,
                        color: Colors.grey[300]!
                    )
                ),
                child: Center(
                  child: Text(
                    widget.year, style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Text("Season details", style: TextStyle(
                  color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 5,),
              formattedTime.isNotEmpty?Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('From:',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(formattedTime),
                  )
                ],
              ):const SizedBox.shrink(),
              formattedTime1.isNotEmpty? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('To:',style: TextStyle(fontSize: 14,fontWeight: FontWeight.bold),),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(formattedTime1),
                  )
                ],
              ):const SizedBox.shrink(),
              const SizedBox(height: 5,),
              InkWell(
                onTap: (){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Leaguecomments(league:widget.league,year:widget.year),
                    ),
                  );

                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.comment,size: 30,color: Colors.black,),
                    CommentsCount0(leagueId: widget.league.leagueId,year:widget.year)
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 2,
                            color: Colors.grey[300]!
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text("Table", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),),
                          const SizedBox(height: 10,),
                          const Text("Teams", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),),
                          Matchecount(leagueId:widget.league.leagueId,year:widget.year),
                          const SizedBox(height: 10,),
                          SizedBox(
                              height: 35,
                              child: TextButton(onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  if(author){
                                    return EditableTable1(leagueId: widget.league.leagueId,year:widget.year, leaguename: widget.league.leaguename, image: widget.league.imageurl,);
                                  }else{
                                    return Leaguetable(leaguename: widget.league.leaguename, image: widget.league.imageurl,leagueId: widget.league.leagueId,year:widget.year);
                                  }
                                }));
                              }, child: const Text("View Table"))),
                          author? const SizedBox(height: 10,):const SizedBox.shrink(),
                          author? SizedBox(
                            height: 35,
                            child: TextButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                if(widget.league.accountType=="Clubs"){
                                 return ClubList(leagueId: widget.league.leagueId, year:widget.year, leaguename: widget.league.leaguename,);
                                }else{
                                  return ClubList1(leagueId: widget.league.leagueId, year:widget.year, leaguename:widget.league.leaguename,);
                                }
                              }));
                            }, child: const Text("Add Member")),
                          ):const SizedBox.shrink()
                        ],
                      ),
                    ),),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 2,
                            color: Colors.grey[300]!
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text("Table", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),),
                          const SizedBox(height: 10,),
                          const Text("Top Scorers",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                          ScorersCount(leagueId: widget.league.leagueId,year:widget.year),
                          const SizedBox(height: 10,),
                          SizedBox(
                              height: 35,
                              child: TextButton(onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  if(author){
                                    return Topscorertable(leaguename: widget.league.leaguename, image: widget.league.imageurl,userId:userId, leagueId: widget.league.leagueId,year:widget.year,);
                                  }else{
                                  return TopscorerGV(leaguename: widget.league.leaguename, image: widget.league.imageurl,leagueId: widget.league.leagueId,year:widget.year);
                                  }
                                }));
                              }, child: const Text("View Table"))),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            width: 2,
                            color: Colors.grey[300]!
                        )
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Text("Matches", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),),
                          const SizedBox(height: 10,),
                          const Text("Total Matches", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),),
                          Matchecount1(leagueId:widget.league.leagueId,year:widget.year),
                          const SizedBox(height: 10,),
                          const Text("Matches Played", style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),),
                          PlayedCount(leagueId: widget.league.leagueId,year:widget.year),
                          const SizedBox(height: 10,),
                          SizedBox(
                              height: 35,
                              child: TextButton(onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>LeagueMatches(year:widget.year, leagueId:widget.league.leagueId, authorId: widget.league.author.userId,)));
                              }, child: const Text("View Matches"))),
                          author? const SizedBox(height: 10,):const SizedBox.shrink(),
                          author? SizedBox(
                            height: 35,
                            child: TextButton(onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateeventPageleague(year:widget.year, league: widget.league)));
                            }, child: const Text("Create a Match")),
                          ):const SizedBox.shrink()

                        ],
                      ),
                    ),),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


class LikesCountWidget extends StatelessWidget {
  int totalLikes;
  LikesCountWidget({super.key, required this.totalLikes});
  @override
  Widget build(BuildContext context) {
    if (totalLikes > 999) {
      return Text('${totalLikes / 1000}K');
    } else if (totalLikes > 999999) {
      return Text('${totalLikes / 1000000}M');
    } else if (totalLikes > 999999999) {
      return Text('${totalLikes / 1000000000}B');
    } else {
      return Text(
        '$totalLikes',
      );
    }
  }
}
class Subscribers extends StatelessWidget {
  String leagueId;
  Subscribers({super.key,
    required this.leagueId,
   });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Leagues')
              .doc(leagueId)
              .collection('subscribers')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                  .docs;
              int totalLikes = 0;
              for (final likeDocument in likeDocuments) {
                final likesArray = likeDocument['subscribers'] as List<dynamic>;
                totalLikes = likesArray.length;
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


class LeagueMatches extends StatefulWidget {
  String leagueId;
  String year;
  String authorId;
  LeagueMatches({super.key,required this.year,required this.leagueId,required this.authorId});

  @override
  State<LeagueMatches> createState() => _LeagueMatchesState();
}

class _LeagueMatchesState extends State<LeagueMatches> {
  List<Map<String, dynamic>> allMatches = [];
  List<Map<String, dynamic>> allMatches2 = [];
  List<Map<String, dynamic>> matches = [];
int itemcount=0;
  Future<List<Map<String, dynamic>>>getmatches()async{
    List<Map<String, dynamic>> allMatches1 = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.leagueId)
          .collection('year')
          .doc(widget.year)
          .collection('leaguematches')
          .get();
      final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
      for (final document in likeDocuments) {
        setState(() {
          allMatches1.addAll(List.from(document['matches']));
        });
      }
      return allMatches1;
    }catch(e){
      return [];
    }
  }
  final ScrollController controller = ScrollController();
  dialog(String e){
    showDialog(context: context, builder: (context){
      return AlertDialog(
        content: Text("$e"),
      );
    });
  }
  Future<void> sort()async{
    if(ascending){
      matches.sort((a, b) {
        Timestamp adate = a['scheduledDate'];
        Timestamp bdate = b['scheduledDate'];
        return adate.compareTo(bdate);
      });
    }else{
      matches.sort((a, b) {
        Timestamp adate = a['scheduledDate'];
        Timestamp bdate = b['scheduledDate'];
        return bdate.compareTo(adate);
      });}
  }
  bool ascending=false;
  @override
  void initState(){
    super.initState();
    getNot();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        getNot1();
      }
    });
  }
  Future<void> getNot() async {
    setState(() {
      isloading = true;
      matches.clear();
      itemcount = 0;
    });
    try {
      allMatches = await getmatches();
      allMatches2.addAll(allMatches);
      allMatches.sort((a, b) {
        Timestamp adate = a['scheduledDate'];
        Timestamp bdate = b['scheduledDate'];
        return bdate.compareTo(adate);
      });
      await processNotifications();
      setState(() {
        if (allMatches.isEmpty) {
          isloading = false;
          nomoreposts = true;
        } else {
          isloading = false;
        }
      });
    }catch(e){
      showDialog(context: context, builder: (context) {
        return AlertDialog(content: Text("$e"),);
      });
    }
  }
bool isloading=true;
  bool nomoreposts=false;
  Future<void> getNot1() async {
    setState(() {
      isloading = true;
      itemcount = 0;
    });
    await processNotifications();
    setState(() {
      if (allMatches.isEmpty) {
        isloading = false;
        nomoreposts = true;
      } else {
        isloading = false;
      }
    });
  }

  Future<void> resetNotifications() async {
    setState(() {
      itemcount = 0;
      matches.clear();
      allMatches.clear();
    });
  }

  Future<void> processNotifications() async{
    for (final t in List.from(allMatches)) {
      setState(() {
        matches.add(t);
        itemcount += 1;
        allMatches.remove(t);
      });
      if (itemcount > 10) break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("League Matches", style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>FilterLM(getdata: (List<Map<String, dynamic>> fmatches) {
                setState(() {
                  matches=fmatches;
                });
              }, matches: allMatches2,)));
            },
            icon: const Icon(Icons.filter_alt, color: Colors.black),
          ),
          const SizedBox(width: 5),
          PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            icon: const Icon(Icons.sort, color: Colors.black),
            onSelected: (value) {
              setState(() {
                ascending = value == "A";
                sort();
              });
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: "A",
                  child: Text('Sort Ascending', style: TextStyle(color: ascending ? Colors.blue : Colors.black)),
                ),
                PopupMenuItem<String>(
                  value: "D",
                  child: Text("Sort Descending", style: TextStyle(color: ascending ? Colors.black : Colors.blue)),
                ),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
          onRefresh: getNot,
          child: buildSection()),
    );
  }

  Widget buildSection() {
    if (isloading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (!isloading && matches.isEmpty) {
      return const Center(child: Text("No Matches"));
    } else {
      return ListView.builder(
        itemCount: matches.length + (isloading || nomoreposts ? 1 : 0),
        controller: controller,
        itemBuilder: (context, index) {
          if (index == matches.length) {
            if (isloading) {
              return const Column(
                children: [
                  Center(child: CircularProgressIndicator()),
                  SizedBox(height: 60),
                ],
              );
            } else if (nomoreposts) {
              return const SizedBox(
                height: 40,
                child: Center(
                  child: Text('No more matches'),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          } else {
            final data = matches[index];
            return LeagueMatch(
              data: data,
              authorId: widget.authorId,
              year: widget.year,
              leagueId: widget.leagueId,
            );
          }
        },
      );
    }
  }
}

class LeagueMatch extends StatefulWidget {
  Map<String,dynamic>data;
  String leagueId;
  String year;
  String authorId;
  LeagueMatch({super.key,
    required this.year,
    required this.leagueId,
    required this.authorId,
    required this.data});
  @override
  State<LeagueMatch> createState() => _LeagueMatchState();
}

class _LeagueMatchState extends State<LeagueMatch> {
  Timestamp timestamp=Timestamp.now();
  bool isNotExpanded = false;
  int maxTextLength = 7;
  String location='';
  @override
  void initState() {
    super.initState();
    timestamp=widget.data['scheduledDate'];
    DateTime createdDateTime1 = timestamp.toDate();
    formattedTime1 = DateFormat('d MMM').format(createdDateTime1);
    if(FirebaseAuth.instance.currentUser?.uid==widget.authorId){
      setState(() {
        author=true;
      });
    }   setState(() {
      location = _truncateText(widget.data['location'].toString());
    });
  }
  String _truncateText(String text) {
    if (text.length < maxTextLength) {
     return text = text.padRight(maxTextLength-text.length);
    }else if (text.length == maxTextLength) {
      return text;
    } else if (text.length > maxTextLength && !isNotExpanded) {
      return "${text.substring(0, 4)}...";
    } else {
      return text;
    }
  }

  String formattedTime1 = '';

  Future<void> deletematch() async {
    dialog1();
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('leaguematches');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['matches'];
      final index = likesArray.indexWhere((like) => like['matchId'] == widget.data['matchId'].toString());
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'matches': likesArray});
        Navigator.pop(context);
        dialog();
        return;
      }
    }

  }
  void dialog1(){
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
                const Text('deleting match...'),
              ],
            ),
          ),
        );
      },
    );
  }
  void dialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return  AlertDialog(
          content: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('Match deleted'),
          ),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: const Text("Ok"))
          ],
        );
      },
    );
  }
  bool author=false;
  double radius=18.0;
  @override
  void didUpdateWidget(covariant LeagueMatch oldWidget) {
    if (oldWidget.data['matchId'] != widget.data['matchId']) {
      setState(() {
        timestamp=widget.data['scheduledDate'];
        DateTime createdDateTime1 = timestamp.toDate();
        formattedTime1 = DateFormat('d MMM').format(createdDateTime1);
        if(FirebaseAuth.instance.currentUser?.uid==widget.authorId){
            author=true;
        }
          location = _truncateText(widget.data['location'].toString());
      });
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              width: 2,
              color: Colors.grey[300]!
          )
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomNameAvatar(userId: widget.data['club1Id'],radius: radius, style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ), maxsize: 120,),
                    const SizedBox(height: 10,),
                    CustomNameAvatar(userId: widget.data['club2Id'],radius: radius, style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
                    ), maxsize: 120,)
                  ],
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Text(widget.data['score1'].toString()),
                            const Text("VS"),
                            Text(widget.data['score1'].toString())
                          ],
                        ),
                      ),
                      Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: 100,
                        color: Colors.grey[300],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Date: $formattedTime1"),
                          Text("Time: ${widget.data['time'].toString()}"),
                          Text("Location: $location"),
                          Row(
                            children: [
                              const Text("Status: "),
                              Status(timestamp:timestamp,status:widget.data['status'].toString() , )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              thickness: 2,
              color: Colors.grey[300],
            ),
            SizedBox(
              height: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  author?TextButton(onPressed: (){
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
                        return Drag1(matchId:widget.data['matchId'].toString(),leagueId: widget.leagueId, year: widget.year,);
                      },
                    );
                  }, child: const Text("Edit Match")):const SizedBox.shrink(),
                  TextButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Matchess(match2Id:widget.data['match2Id'].toString(),leagueId:widget.leagueId, match1Id: widget.data['match1Id'].toString(), year:widget.year,),
                      ),
                    );
                  }, child: const Text("Watch Match")),
                  author?TextButton(onPressed: (){
                    showDialog(context: context, builder: (context){
                      return AlertDialog(
                        title: const Text("Delete Match"),
                        content: const Text("Do you want to delete match?"),
                        actions: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child: const Text("dismiss")),
                              TextButton(onPressed: (){
                                deletematch();
                                Navigator.pop(context);
                              }, child: const Text("delete"))
                            ],
                          )
                        ],
                      );
                    });
                  }, child: const Text("Delete Match")):const SizedBox.shrink()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}





class FilterLM extends StatefulWidget {
  void Function(List<Map<String,dynamic>>fmatches) getdata;
  List<Map<String,dynamic>>matches;
  FilterLM({super.key,required this.getdata,required this.matches});

  @override
  State<FilterLM> createState() => _FilterLMState();
}

class _FilterLMState extends State<FilterLM> {
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  TextEditingController location=TextEditingController();
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate1 ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.utc(2050),

    );

    if (picked != null && picked != _selectedDate1) {
      setState(() {
        _selectedDate1 = picked;
      });
    }
  }
  List<Map<String,dynamic>>matches=[];
  String b="Date";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 1,
        leading: IconButton(onPressed: (){Navigator.pop(context);}, icon: const Icon(Icons.arrow_back)),
        backgroundColor: Colors.white,
        title: const Text('Filter',style: TextStyle(color: Colors.black),),),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height:MediaQuery.of(context).size.width ,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(b),
                  PopupMenuButton<String>(
                    padding:  const EdgeInsets.only(left:6,right: 6),
                    position: PopupMenuPosition.over,
                    icon: const Icon(Icons.arrow_drop_down,color: Colors.black,size: 38,),
                    onSelected: (value) {
                     setState(() {
                       b=value;
                     });
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value:"Location",
                          child: Text('Location',style: TextStyle(color:Colors.black),),
                        ),
                        const PopupMenuItem<String>(
                          value:"Date",
                          child:  Text('Date',style: TextStyle(color:Colors.black),),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
            b=="Date"?Column(
              children: [
                const Text("From:"),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
                  height: 38,
                  child: TextFormField(
                      onTap: () {
                        _selectDate(context);
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _selectedDate != null
                            ? "${_selectedDate!.toLocal()}".split(' ')[0]
                            : '',
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors
                                  .grey),
                          borderRadius: BorderRadius
                              .circular(8),
                        ),
                        hintText: 'fromDate',
                        labelText: 'fromDate',
                      )),
                ),
                const SizedBox(
                  height: 5,
                ),
                const Text("To:"),
                const SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.6,
                  height: 38,
                  child: TextFormField(
                      onTap: () {
                        _selectDate1(context);
                      },
                      readOnly: true,
                      controller: TextEditingController(
                        text: _selectedDate1 != null
                            ? "${_selectedDate1!.toLocal()}".split(' ')[0]
                            : '',
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Colors
                                  .grey),
                          borderRadius: BorderRadius
                              .circular(8),
                        ),
                        hintText: 'toDate',
                        labelText: 'toDate',
                      )),
                ),
              ],
            ): SizedBox(
              width: MediaQuery.of(context).size.width*0.6,
              height: 38,
              child: TextFormField(
                  controller: location,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                          color: Colors.grey),
                      borderRadius: BorderRadius
                          .circular(8),
                    ),
                    hintText: 'Location',
                    labelText: 'Location',
                  )),
            ),
            const SizedBox(height: 5,),
            OutlinedButton(onPressed: (){
              if(b=="Location"){
               for(var data in widget.matches){
                 if(data['location'].toString().contains(location.text)){
                   matches.add(data);
                 }
               }
               widget.getdata(matches);
               Navigator.pop(context);
              }else{
                for(var data in widget.matches){
                 Timestamp timestamp=data['scheduledDate'];
                  DateTime createdDateTime1 = timestamp.toDate();
                  if(createdDateTime1.isAfter(_selectedDate!)
                      &&createdDateTime1.isBefore(_selectedDate1!)
                      ||createdDateTime1.isAtSameMomentAs(_selectedDate1!)
                      ||createdDateTime1.isAtSameMomentAs(_selectedDate!)){
                    matches.add(data);
                  }
                }
                widget.getdata(matches);
                Navigator.pop(context);
              }
            }, child: const Text('  filter  ')),
          ],
        ),
      ),
    );
  }
}

class VLProvider extends ChangeNotifier{
  List<Map<String,dynamic>>visits=[];
  Future<void> getAllVisits(String collection,String postId)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('visits');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> docs = querySnapshot.docs;
    List<Map<String, dynamic>> allViews = [];
    for (final doc in docs) {
      final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['visits']);
      allViews.addAll(chats);
    }
    visits=allViews;
    notifyListeners();
  }

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }
  void addVisit(String collection,String postId,bool isnonet)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('visits');
      String visitId = generateUniqueNotificationId();
      final Timestamp timestamp = Timestamp.now();
      final like = {'visitId':visitId,'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp};
      visits.add(like);
      notifyListeners();
      if(isnonet){
        try {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['visits'];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({'visits': chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({'visits': [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({'visits': [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          print('Error sending message: $e');
        }
        notifyListeners();
      }else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            final List<Map<String, dynamic>>? chats = (latestDoc['visits'] as List?)
                ?.cast<Map<String, dynamic>>();
            if (chats != null) {
              if (chats.length < 16000) {
                chats.add(like);
                transaction.update(latestDoc.reference, {'visits': chats});
              } else {
                likesCollection.add({'visits': [like]});
              }
            }
          } else {
            likesCollection.add({'visits': [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
  }
}