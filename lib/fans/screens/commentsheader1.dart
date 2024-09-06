import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CommentHeader1 extends StatefulWidget {
  String postId;
  CommentHeader1({super.key, required this.postId});

  @override
  State<CommentHeader1> createState() => _CommentHeader1State();
}

class _CommentHeader1State extends State<CommentHeader1> {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
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
              if(totalLikes<1) {
                return const Text('No Comments',style: TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes==1) {
                return Text('$totalLikes Comment',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes>999){
                return Text('${totalLikes/1000}K Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else{
                return Text('$totalLikes Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }
            }
          }),
    );

  }
}
