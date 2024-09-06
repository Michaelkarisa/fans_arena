import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Repliesdatatv extends StatefulWidget {
  String postId;
  String commentId;

  Repliesdatatv({super.key,
    required this.commentId,
    required this.postId,});

  @override
  State<Repliesdatatv> createState() => _RepliesdatatvState();
}

class _RepliesdatatvState extends State<Repliesdatatv> {

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:FirebaseFirestore.instance
            .collection('FansTv')
            .doc(widget.postId).
        collection('replies')
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