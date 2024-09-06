import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/fans/screens/messages.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/filming/screens/filmlayout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/screens/clubteamtable.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Stream1 extends StatefulWidget {
  final MatchM match;
  Stream1({super.key, required this.match});

  @override
  State<Stream1> createState() => _Stream1State();
}

class _Stream1State extends State<Stream1> {
  Set<String> allLikes1 = {};
  String message4 = 'invited you to assist in filming their match';
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  Future<void> postNotifications(List<String> selectedStreamerIds) async {
    try {
      for (final teamId in selectedStreamerIds) {
        await Sendnotification(
          message: message4,
          from: FirebaseAuth.instance.currentUser!.uid,
          to: teamId,
          content: widget.match.matchId,
          collection: "Professional",
        ).sendnotification();
      }
    } catch (e) {
      print('Error posting notifications: $e');
    }
  }

  int uid = 0;
  String accepted = '';
  String time = '';

  Future<void> addStreamer() async {
    try {
      CollectionReference streamersRef = FirebaseFirestore.instance.collection('Matches').doc(widget.match.matchId).collection('streamers');
      DocumentSnapshot documentSnapshot = await streamersRef.doc(FirebaseAuth.instance.currentUser!.uid).get();
      if (!documentSnapshot.exists) {
        Timestamp timestamp = Timestamp.now();
        await streamersRef.doc(FirebaseAuth.instance.currentUser!.uid).set({
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'uid': uid,
          'createdAt': timestamp,
          'timestamp': time,
        });
      }
    } catch (e) {
      print('Error adding streamer: $e');
    }
  }

  double radius = 23;

  Future<void> addStreamers() async {
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
                const Text('Uploading streamers...'),
              ],
            ),
          ),
        );
      },
    );
    try {
      Timestamp timestamp = Timestamp.now();
      List<String> addedStreamerIds = [];
      for (final teamId in allLikes1) {
        await FirebaseFirestore.instance.collection('Matches').doc(widget.match.matchId).collection('streamers').doc(teamId).set({
          'userId': teamId,
          'uid': uid,
          'accepted': accepted,
          'createdAt': timestamp,
          'timestamp': time,
        });
        setState(() {
          addedStreamerIds.add(teamId);
        });
      }
      if (addedStreamerIds.isNotEmpty) {
        await postNotifications(addedStreamerIds);
        await NotifyFirebase().sendStreamingInvite(addedStreamerIds, FirebaseAuth.instance.currentUser!.uid, 'match',widget.match.matchId);
      }
      await addStreamer();
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
                  SizedBox(height: 20),
                  const Text('Streamers uploaded successfully!'),
                ],
              ),
            ),
          );
        },
      );
      await Future.delayed(const Duration(milliseconds: 1000));
      Navigator.of(context,rootNavigator: true).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AcceptedStreamers(match: widget.match),
        ),
      );
    } catch (e) {
      print('Error adding streamers: $e');
    }
  }

  late String collectionName;
  bool isLoading = true;
  Future<void> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collectionName = prefs.getString('cname') ?? '';
      if (collectionName == "Club") {
        setState(() {
          subCollection="clubsteam";
        });
        data = FirebaseFirestore.instance.collection('Clubs').doc(FirebaseAuth.instance.currentUser!.uid).collection('clubsteam').get();
      } else {
        setState(() {
          subCollection="trustedaccounts";
        });
        data = FirebaseFirestore.instance.collection('Professionals').doc(FirebaseAuth.instance.currentUser!.uid).collection('trustedaccounts').get();
      }
  }

  late Future<QuerySnapshot> data;

  @override
  void initState() {
    super.initState();
    gData();
  }
  void gData()async{
    await _getUserData();
    setState(() {
     isLoading=false;
    });
  }
String subCollection="";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('Invite Streamers', style: TextStyle(color: Colors.black)),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.25,
              height: 35,
              child: Center(
                child: TextButton(
                  onPressed: ()async{
                   await addStreamers();
                  },
                  child: const Text('Next', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
        body:FutureBuilder<QuerySnapshot>(
          future: data,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LFShimmer();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Members not yet added'));
            } else if(snapshot.hasData) {
              if(subCollection=="clubsteam") {
                final List<QueryDocumentSnapshot> likeDocuments = snapshot
                    .data!.docs;
                List<Map<String, dynamic>> allLikes = [];
                List<Map<String, dynamic>> tableColumns = [];
                for (final document in likeDocuments) {
                  final List<dynamic> likesArray = document[subCollection];
                    final List<dynamic> likesArray1 = document['clubsTeamTable'];
                    tableColumns.addAll(likesArray1.cast<Map<String,dynamic>>());
                  allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                }
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: allLikes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final data=allLikes[index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.98,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomNameAvatar(
                                    userId: data[tableColumns[1]['fn']] ??
                                        data['userId'],
                                    radius: radius,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxsize: 200,
                                  ),
                                  const SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                        data[tableColumns[2]['fn']] ?? ''),
                                  ),
                                  const SizedBox(height: 3),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                        data[tableColumns[3]['fn']] ?? ''),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Checkbox(
                                  value: allLikes1.contains(
                                      data[tableColumns[1]['fn']] ??
                                          data['userId']),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        allLikes1.add(
                                            data[tableColumns[1]['fn']] ??
                                                data['userId']);
                                      } else {
                                        allLikes1.remove(
                                            data[tableColumns[1]['fn']] ??
                                                data['userId']);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );
              }else{
                final List<QueryDocumentSnapshot> likeDocuments = snapshot
                    .data!.docs;
                List<Map<String, dynamic>> allLikes = [];
                for (final document in likeDocuments) {
                  final List<dynamic> likesArray = document["accounts"];
                  allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
                }
                return ListView.builder(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: allLikes.length,
                    itemBuilder: (BuildContext context, int index) {
                      final data=allLikes[index];
                    return Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.98,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomNameAvatar(
                                    userId: data['userId'],
                                    radius: radius,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxsize: 200,
                                  ),
                                  const SizedBox(height: 3),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: Checkbox(
                                  value: allLikes1.contains(data['userId']),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        allLikes1.add(data['userId']);
                                      } else {
                                        allLikes1.remove(data['userId']);
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                );
              }
            }else{
              return const LFShimmer();
            }
          },
        ),
      ),
    );
  }
}

class Streamers{
  String userId;
  String accepted;
  Streamers({required this.userId,required this.accepted});
}
class
AcceptedStreamers extends StatefulWidget {
  MatchM match;
  AcceptedStreamers({super.key,
    required this.match,
  });

  @override
  State<AcceptedStreamers> createState() => _AcceptedStreamersState();
}

class _AcceptedStreamersState extends State<AcceptedStreamers> {
  String accepted='1';
  String notaccepted='0';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Start streaming',style: TextStyle(color:Colors.black ),),
        actions: [
          SizedBox(
            width: MediaQuery.of(context).size.width *0.25,
            height: 35,
            child: TextButton(onPressed: (){
              Navigator.push(context,
                MaterialPageRoute(builder: (context) => FilmingLayout(match:widget.match ,),
                ),
              );
            }, child: const Text('film',style: TextStyle(fontSize: 18),)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Matches').doc(widget.match.matchId).collection('streamers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator()); // Loading indicator
          }
          List<Streamers> notifications = snapshot.data!.docs
              .map(
                (doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return Streamers(
                userId: data['userId'] ?? '',
                accepted: data['accepted'] ?? '',
              );
            },
          ).where((streamer) => streamer.userId != FirebaseAuth.instance.currentUser?.uid) // Filter out the current user
              .toList();

          return ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if(index==notifications.length){
                return const SizedBox(height: 60,);
              }
              final streamers = notifications[index];
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Container(
                    height: 50,
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomAvatarM(userId: notifications[index].userId, radius: 20.0,),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: CustomNameM(userId: notifications[index].userId, style: const TextStyle(fontSize: 15), maxsize: 160),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 100,
                          child: Builder(builder: (context){
                            if(streamers.accepted==accepted){
                              return const Text('Accepted');
                            }else if(streamers.accepted==notaccepted){
                              return const Text('Declined');
                            }else{
                              return const Text('Pending');
                            }
                          }),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(height: 2);
            },
            itemCount: notifications.length+1,
          );
        },
      ),
    );
  }
}

