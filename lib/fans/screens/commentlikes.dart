import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../appid.dart';
import '../data/notificationsmodel.dart';

class CommentLikeButton extends StatefulWidget {
  String commentId;
  String postId;
  String authorId;
  String collection;
  CommentLikeButton({super.key,
    required this.commentId,
    required this.postId,
    required this.authorId,required this.collection});

  @override
  _CommentLikeButtonState createState() => _CommentLikeButtonState();
}

class _CommentLikeButtonState extends State<CommentLikeButton> {
  CLikingProvider liking=CLikingProvider();
  @override
  void didUpdateWidget(covariant CommentLikeButton oldWidget) {
    if (oldWidget.commentId != widget.commentId) {
      checkIfUserLikedPost();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }


  String message='liked your comment';

  void checkIfUserLikedPost() async {
    await liking.getAllikes(widget.collection, widget.postId,widget.commentId);
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
                      liking.addlike(widget.collection, widget.postId, isnonet,widget.commentId);
                      NotifyFirebase().sendlikedNotifications(FirebaseAuth.instance.currentUser!.uid, widget.authorId, widget.postId, "Comment");
                      Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message, content: widget.postId).sendnotification();
                    } else {
                      liking.removelike(widget.collection, widget.postId, isnonet,widget.commentId);
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
                LikesCountWidget(totalLikes:liking.likes.length ,)
              ],
            ),
          );});
  }
}


class LikesCountWidget extends StatelessWidget {
  final int totalLikes;
  const LikesCountWidget({super.key,
    required this.totalLikes,});

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


class CLikingProvider extends ChangeNotifier {
  List<Map<String, dynamic>>likes = [];
  bool liked = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  List<QueryDocumentSnapshot> alldocs = [];

  Future<void> getAllikes(String collection, String postId,
      String commentId) async {
    try {
      stream = _firestore
          .collection(collection)
          .doc(postId)
          .collection('commentlikes')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
          final List<Map<String, dynamic>> alllikes = [];
          for (final likeDocument in likeDocuments) {
            final List<Map<String, dynamic>> likesArray = List<
                Map<String, dynamic>>.from(likeDocument['commentlikes']);
            final List<Map<String, dynamic>> filteredLikes = likesArray.where((
                element) {
              return element['commentId'] == commentId;
            }).toList();
            alllikes.addAll(filteredLikes);
          }
          alldocs = likeDocuments;
          likes = alllikes;
          liked = likes.any((like) => like['userId'] ==
              FirebaseAuth.instance.currentUser!.uid &&
              like['commentId'] == commentId);
          notifyListeners();
        } else {}
        notifyListeners();
      });
    } catch (e) {
      notifyListeners();
    }
  }

  void addlike(String collection, String postId, bool isnonet,
      String commentId) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('commentlikes');
    final bool userLiked = likes.any((like) =>
    like['userId'] == FirebaseAuth.instance.currentUser!.uid &&
        like['commentId'] == commentId);
    if (userLiked) {} else {
      final Timestamp timestamp = Timestamp.now();
      final like = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': timestamp,
        "commentId": commentId
      };
      likes.add(like);
      liked = true;
      notifyListeners();
      if (isnonet) {
        try {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['commentlikes'];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({'commentlikes': chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({'commentlikes': [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({'commentlikes': [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          print('Error sending message: $e');
        }
        notifyListeners();
      } else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            final List<Map<String,
                dynamic>>? chats = (latestDoc['commentlikes'] as List?)
                ?.cast<Map<String, dynamic>>();
            if (chats != null) {
              if (chats.length < 16000) {
                chats.add(like);
                transaction.update(
                    latestDoc.reference, {'commentlikes': chats});
              } else {
                likesCollection.add({'commentlikes': [like]});
              }
            }
          } else {
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

  void removelike(String collection, String postId, bool isnonet,
      String commentId) async {
    final index1 = likes.indexWhere((like) =>
    like['userId'] == FirebaseAuth.instance.currentUser!.uid &&
        like["commentId"] == commentId);
    if (index1 != -1) {
      likes.removeAt(index1);
      liked = false;
      notifyListeners();
    }
    final List<QueryDocumentSnapshot> documents = alldocs;

    for (final document in documents) {
      final List<dynamic> likesArray = document['commentlikes'];
      final index = likesArray.indexWhere((like) =>
      like['userId'] == FirebaseAuth.instance.currentUser!.uid &&
          like['commentId'] == commentId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'commentlikes': likesArray});
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }


}
