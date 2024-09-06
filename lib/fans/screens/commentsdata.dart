import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Commentsdata extends StatefulWidget {
  String postId;
   Commentsdata({super.key, required this.postId});

  @override
  State<Commentsdata> createState() => _CommentsdataState();
}

class _CommentsdataState extends State<Commentsdata> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 0, width: 0,);
              } else {
                final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                    .docs;
                int totalLikes = 0;
                for (final likeDocument in likeDocuments) {
                  final likesArray = likeDocument['comments'] as List<dynamic>;
                  totalLikes += likesArray.length;
                }
                if (totalLikes < 1) {
                  return const SizedBox(height: 0, width: 0,);
                } else {
                  return Text(
                    '$totalLikes',
                  );
                }
              }
            }),
      ),
    );
  }
}
