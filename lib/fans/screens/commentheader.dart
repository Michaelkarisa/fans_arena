import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class FeedcommentsH extends StatelessWidget {
  final String postId;

  const FeedcommentsH({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
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
                return const Text('No Post Comments',style: TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes==1) {
                return Text('$totalLikes Post Comment',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes>999){
                return Text('${totalLikes/1000}K Post Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes>999999){
                return Text('${totalLikes/1000000}M Post Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else if(totalLikes>999999999){
                return Text('${totalLikes/1000000000}B Post Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }else{
                return Text('$totalLikes Post Comments',style: const TextStyle(color: Colors.black,fontSize: 18,));
              }
            }
          }),
    );
  }
}




