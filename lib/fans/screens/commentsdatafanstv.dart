import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CommentsdatafansTv extends StatefulWidget {
  String postId;
  CommentsdatafansTv({super.key, required this.postId});

  @override
  State<CommentsdatafansTv> createState() => _CommentsdatafansTvState();
}

class _CommentsdatafansTvState extends State<CommentsdatafansTv> {

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('FansTv')
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
            }),
      ),
    );
  }
}
