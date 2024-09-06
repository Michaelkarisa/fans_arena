import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../appid.dart';
import '../bloc/accountchecker0.dart';
import '../screens/commentsdata.dart';
import '../screens/likes.dart';
import '../screens/newsfeed.dart';
import '../screens/newsfeedcomments.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LikeArea extends StatefulWidget {
  Posts post;
  LikeArea({super.key,
    required this.post,});

  @override
  _LikeAreaState createState() => _LikeAreaState();
}

class _LikeAreaState extends State<LikeArea> {
  LikingProvider liking=LikingProvider();
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }

  void checkIfUserLikedPost() async {
    await liking.getAllikes('posts', widget.post.postid);
  }

  @override
  void dispose() {
    liking.likes.clear();
    super.dispose();
  }
  String message='liked your post';
  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(animation: liking,
      builder: (BuildContext context, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
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
                              liking.addlike('posts', widget.post.postid,);
                              NotifyFirebase().sendlikedNotifications(FirebaseAuth.instance.currentUser!.uid, widget.post.user.userId, widget.post.postid, "Post");
                              Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.post.user.userId, message: message, content: widget.post.postid).sendnotification();
                            } else {
                              liking.removelike('posts', widget.post.postid,);
                              Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.post.user.userId, message: message, content: '').Deletenotification();
                            }
                        },
                        icon: liking.liked
                            ? const Icon(
                          Icons.thumb_up_off_alt_rounded,
                          color: Colors.blue,
                          size: 25,
                        )
                            : const Icon(
                          Icons.thumb_up_off_alt,
                          size: 25,
                          color: Colors.black,
                        ),
                      ),
                      widget.post.likes?LikesCountWidget(totalLikes: liking.likes.length,):Text("likes")
                    ],
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(onPressed: () {
                        Navigator.push(context,
                          MaterialPageRoute(
                            builder: (
                                context) =>  FeedComments(post:widget.post,),
                          ),
                        );
                      },
                          icon: const Icon(
                            Icons.mode_comment_outlined,)),
                      Commentsdata(postId:widget.post.postid)
                    ],
                  ),
                ),

                SizedBox(
                    width: 38,
                    height: 30,
                    child: Accountchecker0(user: widget.post.user,)),
              ],
            ),
            Padding(
                padding: const EdgeInsets.only(left: 5),
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        color: Colors.transparent,
                        child: InkWell(
                            onTap:() {
                              if(widget.post.likes) {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        LikesListView(
                                          postId: widget.post.postid,),
                                  ),
                                );
                              }
                            },child: LikesTextWidget( liked: liking.liked,liking: widget.post.likes, totalLikes: liking.likes.length,
                        )))))
          ],
        );
      },

    );
  }
}


class LikesCountWidget extends StatelessWidget {
  int totalLikes;

  LikesCountWidget({super.key, required this.totalLikes});

  @override
  Widget build(BuildContext context) {
    if (totalLikes < 1) {
      return const SizedBox.shrink();
    } else if (totalLikes > 999) {
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

class LikingProvider extends ChangeNotifier{
  List<Map<String,dynamic>>likes=[];
  bool liked=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  List<QueryDocumentSnapshot> alldocs =[];

  Future<void> getAllikes(String collection,String postId)async{
    try {
      stream = _firestore
          .collection(collection)
          .doc(postId)
          .collection('likes')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> alllikes = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['likes']);
            alllikes.addAll(chats);
          }
          alldocs=docs;
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
  void addlike(String collection,String postId,)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('likes');

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
          final List<QueryDocumentSnapshot> documents = alldocs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['likes'];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({'likes': chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({'likes': [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({'likes': [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          print('Error sending message: $e');
        }
        notifyListeners();
      }else {
        final data = {
          'userId':FirebaseAuth.instance.currentUser!.uid,
        };
        await SendDatatoFunction().addData(data: Data(
            collection:collection,
            docId: postId,
            subcollection: "likes",
            data: data, subdocId: ''));
        _saveLikedPost(postId);
        notifyListeners();
      }
      notifyListeners();
    }
    notifyListeners();
  }
  Future<void> _saveLikedPost(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedPosts = prefs.getStringList('likedPosts') ?? [];
    if (!likedPosts.contains(postId)&&!liked) {
      likedPosts.add(postId);
      await prefs.setStringList('likedPosts', likedPosts);
      liked=true;
      notifyListeners();
    }
  }
  Future<void> likedPost(String postId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? likedPosts = prefs.getStringList('likedPosts') ?? [];
    if (likedPosts.contains(postId)&&!liked) {
      likedPosts.add(postId);
      await prefs.setStringList('likedPosts', likedPosts);
      liked=true;
      notifyListeners();
    }
  }
  void removelike(String collection,String postId,)async{
    final index1 = likes.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
    if(index1 != -1) {
      likes.removeAt(index1);
      liked=false;
      notifyListeners();
    }
    final List<QueryDocumentSnapshot> documents = alldocs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['likes'];
      final index = likesArray.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'likes': likesArray});
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }

}



class LikesTextWidget extends StatelessWidget {
  bool liked;
  int totalLikes;
  bool liking;
  LikesTextWidget({super.key, required this.liked,required this.totalLikes,required this.liking});

  @override
  Widget build(BuildContext context) {
    if (liking) {
      if (totalLikes < 1) {
        return const SizedBox.shrink();
      } else if (totalLikes > 2 && liked) {
        return Text(
          'you and ${totalLikes - 1} other accounts liked this post',
        );
      } else if (totalLikes == 1 && liked) {
        return const Text(
          'you liked this post',
        );
      } else if (totalLikes == 2 && liked) {
        return Text(
          'you and ${totalLikes - 1} other account liked this post',
        );
      } else if (totalLikes > 999 && liked) {
        return Text(
          'you and ${totalLikes / 1000 - 1}K other account liked this post',
        );
      } else if (totalLikes > 999999 && liked) {
        return Text(
          'you and ${totalLikes / 1000000 - 1}M other account liked this post',
        );
      } else if (totalLikes > 999999999 && liked) {
        return Text(
          'you and ${totalLikes / 1000000000 -
              1}B other account liked this post',
        );
      } else if (totalLikes == 1 && !liked) {
        return Text(
          '$totalLikes  account liked this post',
        );
      } else if (totalLikes > 1 && !liked) {
        return Text(
          '$totalLikes  accounts liked this post',
        );
      } else if (totalLikes > 999 && !liked) {
        return Text(
          '${totalLikes / 1000}K  accounts liked this post',
        );
      } else if (totalLikes > 999999 && !liked) {
        return Text(
          '${totalLikes / 1000000}M  accounts liked this post',
        );
      } else if (totalLikes > 999999999 && !liked) {
        return Text(
          '${totalLikes / 1000000000}B  accounts liked this post',
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      if (totalLikes < 1) {
        return const SizedBox.shrink();
      } else if (totalLikes >= 2 && liked) {
        return Text(
          'you and other accounts liked this post',
        );
      } else if (totalLikes == 1 && liked) {
        return const Text(
          'you liked this post',
        );
      } else if (totalLikes == 1 && !liked) {
        return const Text(
          'post liked',
        );
      } else if (totalLikes > 1 && !liked) {
        return const Text(
          'several accounts liked this post',
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }
}
