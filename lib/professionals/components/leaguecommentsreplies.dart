import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/bloc/accountchecker6.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
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
import 'package:uuid/uuid.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../screens/accountprofilepviewer.dart';
import 'leaguecomments.dart';
class LeagueCommentsReplies extends StatefulWidget {
  String year;
  LeagueC league;
  Comment comment;
  LeagueCommentsReplies({super.key,
    required this.league,
    required this.comment,
  required this.year});

  @override
  State<LeagueCommentsReplies> createState() => _LeagueCommentsRepliesState();
}

class _LeagueCommentsRepliesState extends State<LeagueCommentsReplies> {
  TextEditingController reply =TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<List<Reply>>data;
  @override
  void initState() {
    super.initState();
    data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);

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
  String message14='has replied to your comment on this post';
  Future<void> _commentPost() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Leagues') // Change to your collection name
        .doc(widget.league.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('replies');

    // Check if the user has already liked the post

    String replyId = generateUniqueNotificationId();
    if (reply.text.isEmpty) {
      // User has already liked the post, handle this case accordingly

      return;
    }

    final Timestamp timestamp = Timestamp.now();
    final like = {
      'replyId': replyId,
      'commentId': widget.comment.commentId,
      'createdAt': timestamp,
      'reply': reply.text,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    };
    if(isnonet){
      try {
        // Query the Chat subcollection to retrieve existing documents
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

        if (documents.isNotEmpty) {
          // There are existing documents, get the latest one
          final DocumentSnapshot latestDoc = documents.first;
          List<dynamic> likesArray = latestDoc['replies'];

          // Check if adding the like to the latest document exceeds the limit
          if (likesArray.length < 1000) {
            // Add the like to the latest document
            likesArray.add(like);
            setState(() {
              reply.clear();
            });
            await latestDoc.reference.update({'replies': likesArray});
            setState(() {
              data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
            });
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: widget.comment.user.userId,
                message: message14,
                content: '').sendnotification();
          } else {
            setState(() {
              reply.clear();
            });
            // The latest document has reached the limit, create a new document for likes
            await likesCollection.add({'replies': [like]});
            setState(() {
              data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
            });
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: widget.comment.user.userId,
                message: message14,
                content: '').sendnotification();
          }
        } else {
          setState(() {
            reply.clear();
          });
          // No previous documents, create a new one with the initial like
          await likesCollection.add({'replies': [like]});
          setState(() {
            data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
          });
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: widget.comment.user.userId,
              message: message14,
              content: '').sendnotification();
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

          final List<Map<String, dynamic>>? chats = (latestDoc['replies'] as List?)
              ?.cast<Map<String, dynamic>>();

          // Check if 'chats' is not null
          if (chats != null) {
            // Check if adding the message to the latest document exceeds the limit
            if (chats.length < 1000) {
              // Add the message to the latest document
              chats.add(like);
              setState(() {
                reply.clear();
              });
              transaction.update(latestDoc.reference, {'replies': chats});
              setState(() {
                data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
              });
              await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                  to: widget.comment.user.userId,
                  message: message14,
                  content: '').sendnotification();
            } else {
              setState(() {
                reply.clear();
              });
              // The latest document has reached the limit, create a new document for messages
              transaction.set(likesCollection.doc(), {'replies': [like]});
              setState(() {
                data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
              });
              await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                  to: widget.comment.user.userId,
                  message: message14,
                  content: '').sendnotification();
            }
          }
        } else {
          setState(() {
            reply.clear();
          });
          // No previous documents, create a new one with the initial message
          transaction.set(likesCollection.doc(), {'replies': [like]});
          setState(() {
            data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
          });
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: widget.comment.user.userId,
              message: message14,
              content: '').sendnotification();
        }
      });
    }
  }
  double radius=19;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('Replies',style: TextStyle(color: Colors.black),),
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
                      data=DataFetcher().getLeaguereplydata(docId: widget.league.leagueId, year:widget.year,commentId: widget.comment.commentId);
                    });
                  }, icon: const Icon(Icons.refresh,size: 30,color: Colors.black,)),
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
                                                  imageUrl:widget.comment.user.url,
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
                                                      widget.comment.user.name,
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
                                                  child:  SizedBox(
                                                    height: 20,
                                                    width: 20,
                                                    child:Accountchecker6(user: widget.comment.user,)
                                                  ),
                                                ),),
                                              widget.comment.user.userId==widget.league.author.userId?const Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 5,right: 2),
                                                    child: Icon(Icons.star,color: Colors.grey,size: 15,),
                                                  ),
                                                  Text('Manager',style: TextStyle(fontWeight: FontWeight.bold),),
                                                ],
                                              ):const Text(''),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right:5 ,left: 40),
                                          child: Text(widget.comment.comment),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20,left: 5),
                                          child: CommentLikeButtonL(leagueId:widget.league.leagueId ,commentId:widget.comment.commentId, year: widget.year,)
                                        )

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
                child: FutureBuilder<List<Reply>>(
                    future: data,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return const CommentShimmer();
                      }else if(snapshot.hasError){
                        return Text('${snapshot.error}');
                      }else if(!snapshot.hasData||snapshot.data!.isEmpty){
                        return const Center(child: Text("No Replies"),);
                      }else if(snapshot.hasData){
                        List<Reply>matches=snapshot.data!;

                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: matches.length,
                          itemBuilder: (BuildContext context, int index) {
                            final comments=matches[index]; // Get the Timestamp object
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
                            return  Padding(
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
                                          child: Text(comments.reply),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                            child: ReplyLikeButtonL(postId: widget.league.leagueId, replyId: comments.replyId, commentId: widget.comment.commentId,year:widget.year)
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
                              controller: reply,
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
                                hintText: 'write a reply',
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


class ReplyLikeButtonL extends StatefulWidget {
  String commentId;
  String postId;
  String replyId;
  String year;
  ReplyLikeButtonL({super.key, 
    required this.commentId,
    required this.postId,
    required this.replyId,
    required this.year,
  });

  @override
  _ReplyLikeButtonLState createState() => _ReplyLikeButtonLState();
}

class _ReplyLikeButtonLState extends State<ReplyLikeButtonL> {
  late LRLikingProvider liking=LRLikingProvider();
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }


  String message='liked your reply';

  void checkIfUserLikedPost() async {
    await liking.getAllikes("Leagues",widget.year, widget.postId,widget.replyId);
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
                      liking.addlike("Leagues",widget.year, widget.postId,isnonet,widget.replyId);
                     // Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: widget.postId).sendnotification();
                    } else {
                      liking.removelike("Leagues",widget.year, widget.postId,isnonet,widget.replyId);
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
                LikesCountWidget(totalLikes: liking.likes.length,)
              ],
            ),
          );
        });
  }
}


class LRLikingProvider extends ChangeNotifier{
  List<Map<String,dynamic>>likes=[];
  bool liked=false;
  Future<void> getAllikes(String collection,String year, String postId, String replyId) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection) // Change to your collection name
        .doc(postId)
        .collection('year')
        .doc(year)// The document ID containing Likes subcollection
        .collection('replylikes');

    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> likeDocuments = querySnapshot.docs;
    final List<Map<String, dynamic>> alllikes=[];
    for (final likeDocument in likeDocuments) {
      final List<Map<String, dynamic>> likesArray = List<Map<String, dynamic>>.from(likeDocument['replylikes']);
      final List<Map<String, dynamic>> filteredLikes = likesArray.where((element) {
        return element['replyId'] == replyId;
      }).toList();
      alllikes.addAll(filteredLikes);
    }
    likes=alllikes;
    liked = await checkIfUserLikedPost(replyId);
    notifyListeners();
  }

  void addlike(String collection,String year,String postId,bool isnonet,replyId)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection) // Change to your collection name
        .doc(postId)
        .collection('year')
        .doc(year)
        .collection('replylikes');

    final bool userLiked = await checkIfUserLikedPost(replyId);

    if (userLiked) {
    }else{
      final Timestamp timestamp = Timestamp.now();
      final like = {'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp,'replyId':replyId};
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
            List<dynamic> chatsArray = latestDoc['replylikes'];

            // Check if adding the message to the latest document exceeds the limit
            if (chatsArray.length < 16000) {
              // Add the message to the latest document
              chatsArray.add(like);
              latestDoc.reference.update({'replylikes': chatsArray});
              notifyListeners();
            } else {
              // The latest document has reached the limit, create a new document for messages
              likesCollection.add({'replylikes': [like]});
              notifyListeners();
            }
          } else {
            // No previous documents, create a new one with the initial message
            likesCollection.add({'replylikes': [like]});
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

            final List<Map<String, dynamic>>? chats = (latestDoc['replylikes'] as List?)
                ?.cast<Map<String, dynamic>>();

            // Check if 'chats' is not null
            if (chats != null) {
              // Check if adding the message to the latest document exceeds the limit
              if (chats.length < 16000) {
                // Add the message to the latest document
                chats.add(like);
                transaction.update(latestDoc.reference, {'replylikes': chats});
              } else {
                // The latest document has reached the limit, create a new document for messages
                likesCollection.add({'replylikes': [like]});
              }
            }
          } else {
            // No previous documents, create a new one with the initial message
            likesCollection.add({'replylikes': [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
    }
    notifyListeners();
  }
  void removelike(String collection,String postId,String year,bool isnonet,String replyId)async{
    final index1 = likes.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like["replyId"]==replyId);
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
        .collection('replylikes');

    // Query the Likes subcollection to find the document
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    for (final document in documents) {
      final List<dynamic> likesArray = document['replylikes'];
      // Find the index of the like object with the specified userId
      final index = likesArray.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like['replyId']==replyId);
      if (index != -1) {
        // Remove the like object from the array
        likesArray.removeAt(index);
        // Update the document with the modified likes array
        await document.reference.update({'replylikes': likesArray});
        notifyListeners();
        return; // Exit the loop once the like is deleted
      }
    }
    notifyListeners();
  }
  Future<bool> checkIfUserLikedPost(String replyId) async {
    if (likes.any((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like["replyId"]==replyId)) {
      // If userId is found in any document, return true
      return true;
    }else{
      return false;
    }
  }

}