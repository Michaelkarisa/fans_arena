import 'package:fans_arena/joint/components/storyviewers.dart';
import 'package:fans_arena/joint/data/screens/feed_item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:story_view/story_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bloc/usernamedisplay.dart';
import 'newsfeed.dart';


class YourStoryViewScreen extends StatefulWidget {
  String userId;
  List<Map<String, dynamic>> story;
  Story s;
  YourStoryViewScreen({super.key,
    required this.userId,
    required this.story,
    required this.s
  });

  @override
  _YourStoryViewScreenState createState() => _YourStoryViewScreenState();
}

class _YourStoryViewScreenState extends State<YourStoryViewScreen> {
  SViewsProvider v= SViewsProvider();
  final storyItems=<StoryItem>[];
  final StoryController _storyController = StoryController();
  void addStory() async {
    try {
      for (final story in widget.story) {
        String image=story['url1'];
        String video=story['url'];
        String cap = story['caption'];
        captions.add(cap);
        if(image.isEmpty) {
          int duration = story['duration'];
          storyItems.add(StoryItem.pageVideo(
            video,
            duration: Duration(seconds: duration),
            controller: _storyController,
          ));
        }else{
          storyItems.add(StoryItem.pageImage(
            duration: const Duration(seconds: 6),
            controller: _storyController,
            url: image,
          ));
        }
      }
      setState(() {
        isloading = false;
      });
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(e.toString()),
        );
      });
      print("Error adding story: $e");
    }finally{
      setState(() {
        isloading = false;
      });
    }
  }

  bool isloading=true;
  @override
  void initState() {
    super.initState();
    Timestamp time=widget.story[0]['timestamp'];
    String hours = DateFormat('HH').format(time.toDate());
    String minutes = DateFormat('mm').format(time.toDate());
    String t = DateFormat('a').format(time.toDate());
    String d=date1(time);
    date="$d at $hours:$minutes $t";
    addStory();
  }
  @override
  void dispose(){
    _storyController.dispose();
    super.dispose();
  }
  int currentIndex = 0;
  String date1(Timestamp createdAt){
    DateTime createdDateTime = createdAt.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdDateTime);
    if (difference.inSeconds == 1) {
      return 'now';
    } else if (difference.inSeconds < 60) {
      return  '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes == 1) {
      return  '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      return  '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      return  '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return  '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      return  '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      return  '${difference.inDays ~/ 7} weeks ago';
    } else {
      return  DateFormat('d MMM').format(createdDateTime);
    }
  }
  String date='';
  List<String> captions=[];
  String caption='';
  void update(List<Map<String, dynamic>> data)async{
    int index=currentIndex;
    QuerySnapshot querySnapshot=await FirebaseFirestore.instance.collection('Story').where('authorId',isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
    final List<QueryDocumentSnapshot> likeDocuments = querySnapshot.docs;
    DocumentSnapshot doc=likeDocuments.first;
    for (final document in likeDocuments) {
      final List<dynamic> likesArray = document['story'];
      if(likesArray.any((element) => element['storyId']==data[index]['storyId'])){
        doc=document;
      }
    }
    data.removeWhere((element) => element['storyId']==data[index]['storyId']);
    showDialog(context: context, builder: (context)=>AlertDialog(content: Text("Deleting"),));
    await doc.reference.update({ 'story':data,});
    Navigator.of(context,rootNavigator: true).pop();
    await Future.delayed(Duration(seconds: 1));
    showDialog(context: context, builder: (context)=>AlertDialog(content: Text("Deleted"),));
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context,rootNavigator: true).pop();
    _storyController.play();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        body: Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              isloading? const Center(child: SizedBox(
                  width: 55,
                  height: 55,
                  child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3,))):GestureDetector(
                onLongPressStart: (d){
                  _storyController.pause();
                },onLongPressEnd: (d){
                _storyController.play();
              },
                child: StoryView(
                  progressPosition: ProgressPosition.top,
                  controller: _storyController,
                  storyItems:storyItems,
                  repeat: false,
                  onStoryShow: (s,index) {
                    v.getViews(widget.s.StoryId,widget.story[index]['storyId'],);
                    setState(() {
                      currentIndex=index;
                      if(index>0){
                        setState(() {
                          Timestamp time=widget.story[index]['timestamp'];
                          String hours = DateFormat('HH').format(time.toDate());
                          String minutes = DateFormat('mm').format(time.toDate());
                          String t = DateFormat('a').format(time.toDate());
                          String d=date1(time);
                          date="$d at $hours:$minutes $t";
                        });}
                    });
                  },
                  onComplete: (){
                    Navigator.pop(context);
                  },
                ),
              ),
              Align(
                alignment: const Alignment(0.0,0.82),
                child: Text(captions[currentIndex],style: TextStyle(color: Colors.white),),
              ),
              Align(
                alignment: const Alignment(0.0,0.97),
                child: SizedBox(
                  height: 45,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height*0.065,
                    child: AnimatedBuilder(
                        animation: v,
                        builder: (BuildContext context, Widget? child) {
                          return IconButton(onPressed: (){
                            showModalBottomSheet(
                              isScrollControlled: true,
                              isDismissible: true,
                              backgroundColor: Colors.transparent,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                              context: context,
                              builder: (BuildContext context) {
                                return Storyviewers(data:v.views);
                              },
                            );
                          }, icon: Column(
                            children: [
                              const Icon(Icons.remove_red_eye,color: Colors.white,),
                              ViewsCount(totalLikes: v.views.length),
                            ],
                          ));
                        }
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child:  FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 15),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close,color: Colors.white,size: 30,),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        CustomAvatar(radius: 22, imageurl: widget.s.user.url),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width*0.75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    UsernameDO(
                                      username: widget.s.user.name,
                                      collectionName: widget.s.user.collectionName,
                                      maxSize:140,
                                      width: 160,
                                      height: 38,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(date,style: const TextStyle(fontSize: 13,color: Colors.white),)
                                  ],
                                ),
                                SizedBox(
                                  width: 30,
                                  child: PopupMenuButton<String>(
                                    color: Colors.white,
                                    onOpened:()=>_storyController.pause(),
                                    onCanceled:()=>_storyController.play(),
                                    iconColor: Colors.white,
                                    position: PopupMenuPosition.under,
                                    onSelected: (value) {
                                      if(value=="1"){
                                        _storyController.pause();
                                        update(widget.story);
                                      }else{
                                        //update(widget.story);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        const PopupMenuItem<String>(
                                          value: '1',
                                          child: Text('Delete story'),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SViewsProvider extends ChangeNotifier {
  List<Map<String, dynamic>>views = [];
  bool viewed = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  List<QueryDocumentSnapshot> alldocs =[];
  Future<void> getViews(String StoryId,String storyId) async {
    try {
      stream = _firestore
          .collection('Story')
          .doc(StoryId)
          .collection('views')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
          List<Map<String, dynamic>> allViews = [];
          for (final document in likeDocuments) {
            final List<dynamic> repliesArray = document['views'];
            for (final item in repliesArray) {
              final storyId = item['storyId'] as String;
              if (storyId == storyId) {
                allViews.add(item as Map<String, dynamic>);
              }
            }
          }
          alldocs=likeDocuments;
          views = allViews;
          viewed = views.any((element) => element['userId'] ==
              FirebaseAuth.instance.currentUser!.uid&&element['storyId']==storyId);
          notifyListeners();
        } else {
          notifyListeners();
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }

  void addView(String StoryId,String storyId, DateTime startime,bool isnonet) async {
    final timeSpentInSeconds = DateTime
        .now()
        .difference(startime)
        .inSeconds;
    final newHoursSpent = timeSpentInSeconds / 3600.0;
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Story')
        .doc(StoryId)
        .collection('views');
    final bool userLiked = views.any((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like['storyId']==storyId);
    if (userLiked) {
      updateWatchhours(StoryId,storyId,isnonet,startime);
    } else {
      final Timestamp timestamp = Timestamp.now();
      var like = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': timestamp,
        'watchhours': newHoursSpent,
        'storyId': storyId
      };

      viewed = true;
      notifyListeners();
      if (isnonet) {
        try {
          final List<QueryDocumentSnapshot> documents = alldocs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['views'];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({'views': chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({'views': [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({'views': [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          print('Error sending message: $e');
        }
        notifyListeners();
      } else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final List<QueryDocumentSnapshot> documents = alldocs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            final List<
                Map<String, dynamic>>? chats = (latestDoc['views'] as List?)
                ?.cast<Map<String, dynamic>>();
            if (chats != null) {
              if (chats.length < 16000) {
                chats.add(like);
                transaction.update(latestDoc.reference, {'views': chats});
              } else {
                likesCollection.add({'views': [like]});
              }
            }
          } else {
            likesCollection.add({'views': [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
    }
    notifyListeners();
  }

  Future<void> updateWatchhours(String StoryId,String storyId, bool isnonet,
      DateTime startime) async {
    final timeSpentInSeconds = DateTime
        .now()
        .difference(startime)
        .inSeconds;
    final newHoursSpent = timeSpentInSeconds / 3600.0;
    try {
      final bool userLiked = views.any((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like['storyId']==storyId);
      if (!userLiked) {
        return;
      }
      for (var document in alldocs) {
        List<Map<String, dynamic>>viewsArray = List.from(document['views']);
        final data = viewsArray.firstWhere((element) =>
        element["userId"] == FirebaseAuth.instance.currentUser!.uid&&element['storyId']==storyId);
        viewsArray.remove(data);
        final newdata = {
          'userId': data['userId'],
          'timestamp': data['timestamp'],
          'watchhours': data['watchhours'] + newHoursSpent,
          'storyId': storyId
        };
        viewsArray.add(newdata);
        if (isnonet) {
          await document.reference.update({'views': viewsArray});
        } else {
          await FirebaseFirestore.instance.runTransaction((transaction) async {
            transaction.update(document.reference, {'views': viewsArray});
          });
        }
      }
    } catch (e) {
      print('Error updating watchhours: $e');
    }
  }
}