import 'package:fans_arena/fans/data/usermodel.dart';
import 'package:fans_arena/fans/screens/leagueviewer.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../appid.dart';
import '../../joint/components/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/newsfeedmodel.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'homescreen.dart';
import 'newsfeed.dart';
class Legues extends StatefulWidget {
  const Legues({super.key});

  @override
  State<Legues> createState() => _LeguesState();
}

class _LeguesState extends State<Legues> {
  final TextEditingController _controller = TextEditingController();
  bool _showCloseIcon = false;

  late DateTime _startTime;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
  }
  String ex="Failed host lookup: 'us-central1-fans-arena.cloudfunctions.net'";

  @override
  void dispose(){
    Engagement().engagement('LeagueFans',_startTime,'');
    super.dispose();
  }
  final TextEditingController error = TextEditingController();
  String y='';
  SearchService3 search2=SearchService3();
  String _searchQuery = '';
  bool issearch=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          title: issearch? Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 3,right: 10),
            child: SizedBox(
              height: 40,
              width:MediaQuery.of(context).size.width * 0.8,
              child: TextFormField(
                scrollPadding: const EdgeInsets.only(left: 10),
                textAlign: TextAlign.justify,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: Colors.black,
                controller: _controller,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _showCloseIcon = value.isNotEmpty;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(left: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                  ),
                  focusedBorder:  OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(width: 1, color: Colors.black),
                  ),
                  filled: true,
                  hintStyle: const TextStyle(color: Colors.black,
                    fontSize: 20, fontWeight: FontWeight.normal,),
                  fillColor: Colors.white70,
                  suffixIcon: _showCloseIcon ? IconButton(
                    icon: const Icon(Icons.close,color: Colors.black,),
                    onPressed: () {
                      setState(() {
                        _controller.clear();
                        _searchQuery=y;
                        _showCloseIcon = false;
                      });
                    },
                  ) : null,
                  hintText: 'Search',
                ),
              ),
            ),
          ):Text('Leagues', style: TextStyle(color: Textn),),
          backgroundColor: Appbare,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(onPressed: (){
                setState(() {
                  issearch=!issearch;
                  _searchQuery=y;
                });
              }, icon: Icon(issearch?Icons.arrow_drop_down:Icons.search_rounded,size: 25,color: Colors.black,)),
            ),
          ],
        ),
      body:_searchQuery.isEmpty? FutureBuilder<List<LeagueC>>(
        future: DataFetcher().getLeaguesForUser(FirebaseAuth.instance.currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else if (snapshot.hasError) {
            if(snapshot.error.toString()==ex){
              return Center(child: Text('No Internet'));
            }else{
              return Center(child: Text('${snapshot.error}'));
            }
          }else if(snapshot.data!.isEmpty){
            return const Center(child: Text('No Leagues',style: TextStyle(color: Colors.white)));
          }
          final posts = snapshot.data ?? [];
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post=posts[index];
              return LLayout(leagues: post);
            },
          );
        },

      ) :StreamBuilder<Set<Leagues>>(
        stream: search2.getUser(_searchQuery),
        builder: (context, snapshot) {
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()),);
          }else if(snapshot.data!.isEmpty){
            return const Center(
              child: Text('No Leagues'),
            );
          }
      Set<Leagues> userList1 = snapshot.data!;
         List<Leagues> userList = userList1.toList();
      return ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
      Leagues league = userList[index];
      return League(league: LeagueC(author: Person(
          name: '',
          url: '',
          collectionName:"Professional",
          userId: league.authorId),
          leagueId: league.leagueId,
          leaguename: league.leaguename,
          imageurl: league.imageurl,
          genre: league.genre,
          location: league.location,
          timestamp: league.timestamp,
          leagues: [],accountType: league.accountType),);
        },
      );
        },
      ),
      ),
    );
  }
}
class League extends StatefulWidget {
  LeagueC league;
   League({super.key, required this.league});

  @override
  State<League> createState() => _LeagueState();
}

class _LeagueState extends State<League> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  VLProvider vl=VLProvider();
  String formattedTime = '';
  String formattedTime1 = '';
  @override
  void initState() {
    super.initState();
    retrieveUsername1();
    retrieveUsername2();
  }
  String year='';
  void retrieveUsername1() async {
      QuerySnapshot querysnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .doc(widget.league.leagueId)
          .collection('year')
          .orderBy('timestamp',descending: true)
          .get();

      if (querysnapshot.docs.isNotEmpty) {
        setState(() {
          year=querysnapshot.docs.first.id;
        });
      }
  }
  List<String>years=[];
  Future<void> retrieveUsername2() async {
    QuerySnapshot querysnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.league.leagueId)
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
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconnB(leagueId: widget.league.leagueId,authorId: widget.league.author.userId,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black,
                              child: CachedNetworkImage(
                                imageUrl:
                                widget.league.imageurl,
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 20,
                                  backgroundImage: imageProvider,
                                ),
                                placeholder: (context, url) => const Text('L',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                                errorWidget: (context, url, error) => const Text('L',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                    constraints: const BoxConstraints(
                                        minWidth: 10,
                                        maxWidth: 130
                                    ),
                                    height: 20,
                                    child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        widget.league.leaguename)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(child: Text('L',style: TextStyle(color: Colors.white),)),),
                            ),
                          ],
                        ),
                      ),
                      Center(child: SizedBox(
                          height:25,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Season: $year'),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                position: PopupMenuPosition.under,
                                icon: const Icon(Icons.arrow_drop_down),
                                onSelected: (value) {
                                  setState(() {
                                    year = value; // Assuming the value directly represents the selected year
                                  });
                                  // Do something when a menu item is selected
                                  print('You selected "$value"');
                                },
                                itemBuilder: (BuildContext context) {
                                  return years.map<PopupMenuEntry<String>>((item) {
                                    return PopupMenuItem<String>(
                                      value: item.toString(),
                                      child: Text(item.toString()),
                                    );
                                  }).toList();
                                },
                              ),

                            ],
                          ))),
                      Center(child: SizedBox(
                          height:25,
                          child: Text('Genre: ${widget.league.genre}'))),
                      Center(child: SizedBox(
                          height:25,
                          child: Text('Location: ${widget.league.location}'))),

                    ],
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(
                            width: 1,
                            color: Colors.grey
                        ),
                        shape: BoxShape.circle
                    ),
                    child: IconButton(
                        constraints:const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ) ,
                        padding:EdgeInsets.zero,
                        onPressed: (){
                          vl.addVisit('Leagues', widget.league.leagueId, true);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LeagueLayout(league: widget.league, year: year,),
                            ),
                          );
                        }, icon: const Icon(Icons.arrow_forward)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class LLayout extends StatefulWidget {
  LeagueC leagues;
  LLayout({super.key,required this.leagues});

  @override
  State<LLayout> createState() => _LLayoutState();
}

class _LLayoutState extends State<LLayout> {
  VLProvider vl=VLProvider();
  @override
  void initState() {
    super.initState();
   setState(() {
     year=widget.leagues.leagues.first;
   });
  }
  String year='';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
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
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconnB(leagueId: widget.leagues.leagueId,authorId: widget.leagues.author.userId,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width*0.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.black,
                              child: CachedNetworkImage(
                                imageUrl:
                                widget.leagues.imageurl,
                                imageBuilder: (context, imageProvider) => CircleAvatar(
                                  radius: 20,
                                  backgroundImage: imageProvider,
                                ),
                                placeholder: (context, url) => const Text('L',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                                errorWidget: (context, url, error) => const Text('L',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                    constraints: const BoxConstraints(
                                        minWidth: 10,
                                        maxWidth: 130
                                    ),
                                    height: 20,
                                    child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        widget.leagues.leaguename)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Center(child: Text('L',style: TextStyle(color: Colors.white),)),),
                            ),
                          ],
                        ),
                      ),
                      Center(child: SizedBox(
                          height:25,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Season: $year'),
                              PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                position: PopupMenuPosition.under,
                                icon: const Icon(Icons.arrow_drop_down),
                                onSelected: (value) {
                                  setState(() {
                                    year = value; // Assuming the value directly represents the selected year
                                  });
                                  // Do something when a menu item is selected
                                  print('You selected "$value"');
                                },
                                itemBuilder: (BuildContext context) {
                                  return widget.leagues.leagues.map<PopupMenuEntry<String>>((item) {
                                    return PopupMenuItem<String>(
                                      value: item.toString(),
                                      child: Text(item.toString()),
                                    );
                                  }).toList();
                                },
                              ),

                            ],
                          ))),
                      Center(child: SizedBox(
                          height:25,
                          child: Text('Genre: ${widget.leagues.genre}'))),
                      Center(child: SizedBox(
                          height:25,
                          child: Text('Location: ${widget.leagues.location}'))),

                    ],
                  ),
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(
                        width: 1,
                        color: Colors.grey
                      ),
                      shape: BoxShape.circle
                    ),
                    child: IconButton(
                        constraints:const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ) ,
                      padding:EdgeInsets.zero,
                        onPressed: (){
                          vl.addVisit('Leagues', widget.leagues.leagueId, true);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeagueLayout(league: widget.leagues, year: year,),
                        ),
                      );
                    }, icon: const Icon(Icons.arrow_forward)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class IconnB extends StatefulWidget {
  String leagueId;
  String authorId;
   IconnB({super.key,required this.leagueId,required this.authorId});

  @override
  State<IconnB> createState() => _IconnBState();
}

class _IconnBState extends State<IconnB> {
  SubscribersProvider liking=SubscribersProvider();
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }




  void checkIfUserLikedPost() async {
    await liking.getAllSubscribers('Leagues', widget.leagueId);
  }

  @override
  void dispose() {
    liking.likes.clear();
    super.dispose();
  }
  String message='subscribed to the League';
  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(animation: liking,
    builder: (BuildContext context, Widget? child) {
          return IconButton(
            icon: Icon(liking.liked ? Icons.notifications: Icons.notifications_off_outlined , color: Colors.black,size: 35,),
           onPressed: () {
            setState(() {
              liking.liked=!liking.liked;
            });
            if (liking.liked) {
              liking.addSubscriber('Leagues', widget.leagueId, isnonet);
              Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: widget.leagueId).sendnotification();
            } else {
              liking.removelike('Leagues', widget.leagueId, isnonet);
              Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: widget.leagueId).Deletenotification();
            }
          },
          );
        }
      );
  }
}

class SubscribersProvider extends ChangeNotifier{
  List<Map<String,dynamic>>likes=[];
  bool liked=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  Future<void> getAllSubscribers(String collection,String postId)async{
    try {
      stream = _firestore
          .collection(collection)
          .doc(postId)
          .collection('subscribers')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> alllikes = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['subscribers']);
            alllikes.addAll(chats);
          }
          likes=alllikes;
          liked=likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
          notifyListeners();
        } else {
        }
        notifyListeners();
      });
    } catch (e) {
      notifyListeners();
    }
  }
  void addSubscriber(String collection,String postId,bool isnonet)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('subscribers');

    final bool userLiked = likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
    if (userLiked) {
    }else{
      final Timestamp timestamp = Timestamp.now();
      final like = {'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp};
      likes.add(like);
      liked=true;
      notifyListeners();
      if(isnonet){
        try {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['subscribers'];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({'subscribers': chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({'subscribers': [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({'subscribers': [like]});
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
            final List<Map<String, dynamic>>? chats = (latestDoc['subscribers'] as List?)
                ?.cast<Map<String, dynamic>>();

            if (chats != null) {
              if (chats.length < 16000) {
                chats.add(like);
                transaction.update(latestDoc.reference, {'subscribers': chats});
              } else {
                likesCollection.add({'subscribers': [like]});
              }
            }
          } else {
            likesCollection.add({'subscribers': [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
    }
    notifyListeners();
  }

  void removelike(String collection,String postId,bool isnonet)async{
    final index1 = likes.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
    if(index1 != -1) {
      likes.removeAt(index1);
      liked=false;
      notifyListeners();
    }
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('subscribers');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['subscribers'];
      final index = likesArray.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'subscribers': likesArray});
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }

}