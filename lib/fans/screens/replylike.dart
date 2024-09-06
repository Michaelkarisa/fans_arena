import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../appid.dart';
import '../data/notificationsmodel.dart';

class ReplyLikeButton extends StatefulWidget {
  String commentId;
  String postId;
  String replyId;
  String authorId;
  String collection;
  ReplyLikeButton({super.key,
    required this.commentId,
    required this.postId,
    required this.replyId,
    required this.collection,
    required this.authorId
  });

  @override
  _ReplyLikeButtonState createState() => _ReplyLikeButtonState();
}

class _ReplyLikeButtonState extends State<ReplyLikeButton> {
  late RLikingProvider liking=RLikingProvider();
  @override
  void initState() {
    super.initState();
    liking=RLikingProvider();
    checkIfUserLikedPost();
  }

  String message='liked your reply';

  void checkIfUserLikedPost() async {
    await liking.getAllikes(widget.collection, widget.postId,widget.replyId);
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
                  liking.addlike(widget.collection, widget.postId, isnonet,widget.replyId);
                  NotifyFirebase().sendlikedNotifications(FirebaseAuth.instance.currentUser!.uid, widget.authorId, widget.postId, "Reply");
                  Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: widget.postId).sendnotification();
                } else {
                  liking.removelike(widget.collection, widget.postId, isnonet,widget.replyId);
                  Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: '').Deletenotification();
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
class LikesCountWidget extends StatelessWidget {
  final int totalLikes;
  const LikesCountWidget({super.key, required this.totalLikes});

  @override
  Widget build(BuildContext context) {
    if (totalLikes < 1) {
      return const SizedBox(height: 0, width: 0,);
    }else if(totalLikes>999){
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
}


class RLikingProvider extends ChangeNotifier{
  List<Map<String,dynamic>>likes=[];
  bool liked=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  Future<void> getAllikes(String collection, String postId, String replyId)async{
    try {
      stream = _firestore
          .collection(collection)
          .doc(postId)
          .collection('replylikes')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          final List<Map<String, dynamic>> alllikes=[];
          for (final likeDocument in docs) {
            final List<Map<String, dynamic>> likesArray = List<Map<String, dynamic>>.from(likeDocument['replylikes']);
            final List<Map<String, dynamic>> filteredLikes = likesArray.where((element) {
              return element['replyId'] == replyId;
            }).toList();
            alllikes.addAll(filteredLikes);
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

  void addlike(String collection,String postId,bool isnonet,replyId)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
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
  void removelike(String collection,String postId,bool isnonet,String replyId)async{
    final index1 = likes.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid&&like["replyId"]==replyId);
    if(index1 != -1) {
      likes.removeAt(index1);
      liked=false;
      notifyListeners();
    }
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
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


