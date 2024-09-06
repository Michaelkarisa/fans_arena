import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/newsfeed.dart';
import 'likebutton.dart';
class LikeButton1 extends StatefulWidget {
  FansTv post;
  String authorId;
  LikeButton1({super.key, required this.post,required this.authorId});

  @override
  _LikeButton1State createState() => _LikeButton1State();
}

class _LikeButton1State extends State<LikeButton1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late LikingProvider liking=LikingProvider();
  @override
  void initState() {
    super.initState();
    checkIfUserLikedPost();
  }

  void checkIfUserLikedPost() async {
    await liking.getAllikes('FansTv', widget.post.postid);
    await liking.likedPost(widget.post.postid);
  }

  @override
  void dispose() {
    liking.likes.clear();
    super.dispose();
  }
  String message11='liked your FansTv video';

  @override
  Widget build(BuildContext context) {
    return  AnimatedBuilder(animation: liking,
    builder: (BuildContext context, Widget? child) {
    return  SizedBox(
      height: 55,
      child:Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 32,
            child: IconButton(
              padding: const EdgeInsets.all(0.0),
              onPressed: () {
                setState(() {
                  liking.liked=!liking.liked;
                  if (liking.liked) {
                    liking.addlike('FansTv', widget.post.postid);
                    NotifyFirebase().sendlikedNotifications(FirebaseAuth.instance.currentUser!.uid, widget.authorId, widget.post.postid, "FansTv video");
                    Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message11, content: widget.post.postid).sendnotification();
                  } else {
                    liking.removelike('FansTv', widget.post.postid);
                    Sendnotification(from: FirebaseAuth.instance.currentUser!.uid, to: widget.authorId, message: message11, content: '').Deletenotification();
                  }
                });
              },
              icon: liking.liked
                  ? const Icon(
                Icons.thumb_up_off_alt_rounded,
                color: Colors.blue,
                size: 30,
              )
                  : const Icon(
                Icons.thumb_up_off_alt,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          widget.post.likes?LikesCountWidget1(totalLikes: liking.likes.length,):Text("likes",style:TextStyle(color: Colors.white))
        ],
      ),
    );
  });
  }
}


class LikesCountWidget1 extends StatelessWidget {
  final int totalLikes;

  const LikesCountWidget1({super.key, required this.totalLikes});

  @override
  Widget build(BuildContext context) {

    if (totalLikes < 1) {
      return const SizedBox(height: 0, width: 0,);
    }else if(totalLikes>9999){
      return Text('${totalLikes/1000}K',style: const TextStyle(color: Colors.white),);
    }else if(totalLikes>999999){
      return Text('${totalLikes/1000000}M',style: const TextStyle(color: Colors.white),);
    }else if(totalLikes>999999999){
      return Text('${totalLikes/1000000000}B',style: const TextStyle(color: Colors.white),);
    } else {
      return Text(
        '$totalLikes',style: const TextStyle(color: Colors.white),
      );
    }
  }
}




