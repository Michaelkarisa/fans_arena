import 'package:fans_arena/appid.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../fans/components/likebutton.dart';
import '../../fans/data/notificationsmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/newsfeed.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../screens/accountprofilepviewer.dart';
import 'leaguecommentsreplies.dart';
import 'package:uuid/uuid.dart';
class Leaguecomments extends StatefulWidget {
  LeagueC league;
  String year;
  Leaguecomments({super.key, required this.league,required this.year});

  @override
  State<Leaguecomments> createState() => _LeaguecommentsState();
}

class _LeaguecommentsState extends State<Leaguecomments> {
  TextEditingController comment =TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<List<Comment>>data;
  @override
  void initState() {
    super.initState();
    data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
  }


  @override
  void dispose() {
    super.dispose();
  }

  String generateUniqueNotificationId() {
    // You can use a library like uuid or generate IDs based on a timestamp
    // Here, I'm using the uuid package to generate a unique ID
    final String uniqueId = const Uuid().v4(); // You need to import the uuid package

    return uniqueId;
  }
  String message8='has commented on your post';
  Future<void> _commentPost() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues') // Change to your collection name
        .doc(widget.league.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('comments');

    // Check if the user has already liked the post

    String commentId = generateUniqueNotificationId();
    if (comment.text.isEmpty) {
      // User has already liked the post, handle this case accordingly

      return;
    }

    final Timestamp timestamp = Timestamp.now();
    final like = {
      'commentId': commentId,
      'createdAt': timestamp,
      'comment':comment.text,
      'userId':FirebaseAuth.instance.currentUser!.uid,
    };

    if(isnonet){
      try {
        // Query the Chat subcollection to retrieve existing documents
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

        if (documents.isNotEmpty) {
          // There are existing documents, get the latest one
          final DocumentSnapshot latestDoc = documents.first;
          List<dynamic> likesArray = latestDoc['comments'];

          // Check if adding the like to the latest document exceeds the limit
          if (likesArray.length < 1000) {
            // Add the like to the latest document
            likesArray.add(like);
            setState(() {
              comment.clear();
            });
            await latestDoc.reference.update({'comments': likesArray});
            setState(() {
              data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
            });
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: '',
                message: message8,
                content: widget.league.leagueId).sendnotification();
          } else {
            setState(() {
              comment.clear();
            });
            // The latest document has reached the limit, create a new document for likes
            await likesCollection.add({'comments': [like]});
            setState(() {
              data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
            });
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: '',
                message: message8,
                content: widget.league.leagueId).sendnotification();
          }
        } else {
          setState(() {
            comment.clear();
          });
          // No previous documents, create a new one with the initial like
          await likesCollection.add({'comments': [like]});
          setState(() {
            data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
          });
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: '',
              message: message8,
              content: widget.league.leagueId).sendnotification();
        }
      } catch (e) {
        print('Error sending message: $e');
        // Handle the error (e.g., show an error message to the user)
      }
    }else {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Query the Likes subcollection to retrieve existing documents
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

        if (documents.isNotEmpty) {
          // There are existing documents, get the latest one
          final DocumentSnapshot latestDoc = documents.first;

          final List<Map<String, dynamic>>? chats = (latestDoc['comments'] as List?)
              ?.cast<Map<String, dynamic>>();

          // Check if 'chats' is not null
          if (chats != null) {
            // Check if adding the message to the latest document exceeds the limit
            if (chats.length < 1000) {
              // Add the message to the latest document
              chats.add(like);
              setState(() {
                comment.clear();
              });
              transaction.update(latestDoc.reference, {'comments': chats});
              setState(() {
                data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
              });
              await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                  to: '',
                  message: message8,
                  content: widget.league.leagueId).sendnotification();
            } else {
              setState(() {
                comment.clear();
              });
              // The latest document has reached the limit, create a new document for messages
              transaction.set(likesCollection.doc(), {'comments': [like]});
              setState(() {
                data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
              });
              await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                  to: '',
                  message: message8,
                  content: widget.league.leagueId).sendnotification();
            }
          }
        } else {
          setState(() {
            comment.clear();
          });
          // No previous documents, create a new one with the initial message
          transaction.set(likesCollection.doc(), {'comments': [like]});
          setState(() {
            data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
          });
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: '',
              message: message8,
              content: widget.league.leagueId).sendnotification();
        }
      });
    }
  }
  double radius=19;
  bool ascending=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('League Comments',style: TextStyle(color: Colors.black),),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      data=DataFetcher().getLeaguecommentdata(docId: widget.league.leagueId, year: widget.year,);
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
            )
          ],
        ),
        body: NestedScrollView(

          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 8, bottom: 8),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(15),
                                ),

                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 40,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                radius: 25,
                                                backgroundColor: Colors.black,
                                                child: CachedNetworkImage(
                                                  alignment: Alignment.topCenter,
                                                  imageUrl:widget.league.imageurl,
                                                  imageBuilder: (context,
                                                      imageProvider) =>
                                                      CircleAvatar(
                                                        radius: 25,
                                                        backgroundImage: imageProvider,
                                                      ),

                                                ),
                                              ),
                                              Container(
                                                color: Colors.transparent,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Container(
                                                    constraints: const BoxConstraints(
                                                      minWidth: 10.0,
                                                      maxWidth: 140.0,
                                                    ),
                                                    child: Text(
                                                      widget.league.leaguename,
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              // Adjust the spacing between the OverflowBox and Aligned container
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5),
                                                child: Align(
                                                  alignment: AlignmentDirectional.centerStart,
                                                  child:  Container(width:20,height:20,decoration: BoxDecoration(
                                                    color: Colors.blueGrey,
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                    child: const Center(child: Text('L',style: TextStyle(color: Colors.white),)),),
                                                ),)
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40,right: 5),
                                          child: Text(widget.league.genre),
                                        ),

                                      ],
                                    ),
                                  ),
                                )
                            ),
                          ),
                        ),

                      ])
              )
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Comment>>(
                    future:data ,
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
                            // Get the Timestamp object
                            DateTime createdDateTime = comments.timestamp.toDate();

                            // Get the current device time
                            DateTime now = DateTime.now();

                            // Calculate the difference between the two times
                            Duration difference = now.difference(createdDateTime);
                            // Convert the Timestamp to a formatted String
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
                                            comments.user.userId==widget.league.author.userId?const Row(
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
                                            Padding(
                                              padding: const EdgeInsets.only(left: 4),
                                              child: Text('at $hours:$minutes $t',style: const TextStyle(fontSize: 14),),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40,right: 5),
                                          child:InkWell(
                                              onTap: (){
                                                Navigator.push(context,
                                                  MaterialPageRoute(builder: (context)=>  LeagueCommentsReplies(comment: comments, league: widget.league,year:widget.year),
                                                  ),
                                                );
                                              },
                                              child: Text(comments.comment)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              TextButton(onPressed: (){
                                                Navigator.push(context,
                                                  MaterialPageRoute(builder: (context)=>  LeagueCommentsReplies(comment: comments, league: widget.league,year:widget.year),
                                                  ),
                                                );
                                              }, child: RepliesdataL(commentId: comments.commentId, postId: widget.league.leagueId, year:widget.year,),),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: CommentLikeButtonL(leagueId:widget.league.leagueId ,commentId: comments.commentId,year:widget.year),
                                              )
                                            ],
                                          ),
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
                            width:MediaQuery.of(context).size.width*0.65,
                            child: TextFormField(
                              controller: comment,
                              scrollPhysics: const ScrollPhysics(),
                              expands: false,
                              maxLines: 4,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              cursorColor: Colors.black,
                              decoration: const InputDecoration(
                                filled: true,
                                focusColor: Colors.grey,
                                hoverColor: Colors.grey,
                                fillColor: Colors.white,
                                hintText: 'write a comment',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                          width: MediaQuery.of(context).size.width*0.15,
                          child: TextButton(onPressed: _commentPost,
                              child: const Text('Post',style: TextStyle(color: Colors.blue),)))
                    ],
                  ),
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }
}
class RepliesdataL extends StatefulWidget {
  String postId;
  String commentId;
  String year;
  RepliesdataL({super.key,
    required this.commentId,
    required this.postId,required this.year});

  @override
  State<RepliesdataL> createState() => _RepliesdataLState();
}

class _RepliesdataLState extends State<RepliesdataL> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('Leagues') // Change to your collection name
            .doc(widget.postId)
            .collection('year')
            .doc(widget.year)
            .collection('replies')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
         if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('Reply',style: TextStyle(color: Colors.blue)); // Handle case where there are no likes
          } else {
            final List<QueryDocumentSnapshot> replyDocuments = snapshot.data!.docs;
            List<Map<String, dynamic>> allReplies = [];
            int repliesCount=0;
            for (final document in replyDocuments) {
              final List<dynamic> repliesArray = document['replies'];

              for (final item in repliesArray) {
                final commentId = item['commentId'] as String;

                if (commentId == widget.commentId) {
                  allReplies.add(item as Map<String, dynamic>);
                  repliesCount=allReplies.length;
                }
              }
            }
            if (repliesCount==1) {
              return Text('$repliesCount Reply',style: const TextStyle(color: Colors.blue),);
            }else if(repliesCount>999){
              return Text('${repliesCount/1000}K Replies',style: const TextStyle(color: Colors.blue),);
            }else if(repliesCount>999999){
              return Text('${repliesCount/1000000}M Replies',style: const TextStyle(color: Colors.blue),);
            }else if(repliesCount>999999999){
              return Text('${repliesCount/1000000000}B Replies',style: const TextStyle(color: Colors.blue),);
            }else if(repliesCount<1){
              return const Text('Reply',style: TextStyle(color: Colors.blue),);
            } else {
              return Text(
                '$repliesCount Replies',style: const TextStyle(color: Colors.blue),
              );
            }
          }
        }
    );
  }
}
class CommentLikeButtonL extends StatefulWidget {
  String commentId;
  String leagueId;
  String year;
  CommentLikeButtonL({super.key, required this.commentId,required this.leagueId,required this.year});

  @override
  _CommentLikeButtonLState createState() => _CommentLikeButtonLState();
}

class _CommentLikeButtonLState extends State<CommentLikeButtonL> {
  late LCLikingProvider liking=LCLikingProvider();
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }


  String message='liked your comment';

  void checkIfUserLikedPost() async {
    await liking.getAllikes("Leagues", widget.leagueId,widget.year,widget.commentId);
  }

  @override
  void dispose() {
    super.dispose();
    liking.likes.clear();
  }
  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(animation: liking,
        builder: (BuildContext context, Widget? child) {
          return  SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      liking.liked=!liking.liked;
                    });
                    if (liking.liked) {
                      liking.addlike("Leagues", widget.leagueId,isnonet,widget.year,widget.commentId);
                      //Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: widget.postId).sendnotification();
                    } else {
                      liking.removelike("Leagues", widget.leagueId,isnonet,widget.year,widget.commentId);
                      //Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: '').Deletenotification();
                    }
                  },
                  icon: liking.liked
                      ? const Icon(
                    Icons.thumb_up_off_alt_rounded,
                    color: Colors.blue,
                    size: 20,
                  )
                      : const Icon(
                    Icons.thumb_up_off_alt,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
                LikesCountWidget(totalLikes:liking.likes.length,)

              ],
            ),
          );});
  }
}



class LCLikingProvider extends ChangeNotifier{
  List<Map<String,dynamic>>likes=[];
  bool liked=false;
  Future<void> getAllikes(String collection,String postId,String year,String commentId)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection) // Change to your collection name
        .doc(postId)
        .collection('year')
        .doc(year)
        .collection('commentlikes');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> likeDocuments = querySnapshot.docs;
    final List<Map<String, dynamic>> alllikes=[];
    for (final likeDocument in likeDocuments) {
      final List<Map<String, dynamic>> likesArray = List<Map<String, dynamic>>.from(likeDocument['commentlikes']);
      final List<Map<String, dynamic>> filteredLikes = likesArray.where((element) {
        return element['commentId'] == commentId;
      }).toList();
      alllikes.addAll(filteredLikes);
    }
    likes=alllikes;
    liked = await checkIfUserLikedPost(commentId);
    notifyListeners();
  }
  void addlike(String collection,String postId,bool isnonet,String year,String commentId)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection) // Change to your collection name
        .doc(postId)
        .collection('year')
        .doc(year)
        .collection('commentlikes');

    final bool userLiked = await checkIfUserLikedPost(commentId);

    if (userLiked) {
    }else{
      final Timestamp timestamp = Timestamp.now();
      final like = {'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp,"commentId":commentId};
      likes.add(like);
      liked=true;
      notifyListeners();
      if(isnonet){
        try {
          // Query the Chat subcollection to retrieve existing documents
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

          if (documents.isNotEmpty) {
            // There are existing documents, get the latest one
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['commentlikes'];

            // Check if adding the message to the latest document exceeds the limit
            if (chatsArray.length < 16000) {
              // Add the message to the latest document
              chatsArray.add(like);
              latestDoc.reference.update({'commentlikes': chatsArray});
              notifyListeners();
            } else {
              // The latest document has reached the limit, create a new document for messages
              likesCollection.add({'commentlikes': [like]});
              notifyListeners();
            }
          } else {
            // No previous documents, create a new one with the initial message
            likesCollection.add({'commentlikes': [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          print('Error sending message: $e');
          // Handle the error (e.g., show an error message to the user)
        }
        notifyListeners();
      }else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          // Query the Likes subcollection to retrieve existing documents
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

          if (documents.isNotEmpty) {
            // There are existing documents, get the latest one
            final DocumentSnapshot latestDoc = documents.first;

            final List<Map<String, dynamic>>? chats = (latestDoc['commentlikes'] as List?)
                ?.cast<Map<String, dynamic>>();

            // Check if 'chats' is not null
            if (chats != null) {
              // Check if adding the message to the latest document exceeds the limit
              if (chats.length < 16000) {
                // Add the message to the latest document
                chats.add(like);
                transaction.update(latestDoc.reference, {'commentlikes': chats});
              } else {
                // The latest document has reached the limit, create a new document for messages
                likesCollection.add({'commentlikes': [like]});
              }
            }
          } else {
            // No previous documents, create a new one with the initial message
            likesCollection.add({'commentlikes': [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
    }
    notifyListeners();
  }
  void removelike(String collection,String postId,bool isnonet,String year,String commentId)async{
    final index1 = likes.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like["commentId"]==commentId);
    if(index1 != -1) {
      likes.removeAt(index1);
      liked=false;
      notifyListeners();
    }
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection) // Change to your collection name
        .doc(postId)
        .collection('year')
        .doc(year)
        .collection('commentlikes');

    // Query the Likes subcollection to find the document
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (final document in documents) {
      final List<dynamic> likesArray = document['commentlikes'];
      // Find the index of the like object with the specified userId
      final index = likesArray.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like['commentId']==commentId);
      if (index != -1) {
        // Remove the like object from the array
        likesArray.removeAt(index);
        // Update the document with the modified likes array
        await document.reference.update({'commentlikes': likesArray});
        notifyListeners();
        return; // Exit the loop once the like is deleted
      }
    }
    notifyListeners();
  }
  Future<bool> checkIfUserLikedPost(String commentId) async {
    if (likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like['commentId']==commentId)) {
      // If userId is found in any document, return true
      return true;
    }else{
      return false;
    }
  }

}