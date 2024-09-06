import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import '../bloc/usernamedisplay.dart';
import 'accountfanviewer.dart';
class LikesListView extends StatefulWidget {
  String postId;
  LikesListView({super.key, required this.postId});
  @override
  State<LikesListView> createState() => _LikesListViewState();
}


class _LikesListViewState extends State<LikesListView> {
  double radius=19;
  int totalLikes=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 33,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Appbare,
          title: LikesCount(postId: widget.postId,),
        ),
        body: FutureBuilder<List<Universalitem>>(
            future: DataFetcher().getlikesdata(docId: widget.postId,collection: 'posts',subcollection: 'likes'),
            builder: (context, snapshot){
              if(snapshot.hasError){
                return Text('${snapshot.error}');
              }else if(snapshot.hasData){
                List<Universalitem>data=snapshot.data!;
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    // Customize how you display each like object here
                    // For example, you might display userId and timestamp
                    final like = data[index].item;
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: ListTile(
                          leading: CustomAvatar( radius: radius, imageurl:like.url),
                          title:  InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context){
                                    if(like.collectionName=='Club'){
                                      return AccountclubViewer(user: like, index: 0);
                                    }else if(like.collectionName=='Professional'){
                                      return AccountprofilePviewer(user: like, index: 0);
                                    }else{
                                       return Accountfanviewer(user:like, index: 0);
                                    }
                                  }
                              ),);
                            },
                            child: UsernameDO(
                              username:like.name,
                              collectionName:like.collectionName,
                              width: 160,
                              height: 38,
                              maxSize: 140,
                            ),
                          ),
                          trailing: SizedBox(
                              width: 100,
                              child: Accountchecker11(user: like,))
                      ),
                    );
                  },
                );}else{
                return const LFShimmer();
              }
            })
    );
  }
}
class LikesCount extends StatelessWidget {
  final String postId;

  const LikesCount({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .doc(postId)
              .collection('likes')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox(height: 0, width: 0,);
            } else {
              final List<QueryDocumentSnapshot> likeDocuments = snapshot.data!
                  .docs;
              int totalLikes = 0;
              for (final likeDocument in likeDocuments) {
                final likesArray = likeDocument['likes'] as List<dynamic>;
                totalLikes += likesArray.length;
              }
              if(totalLikes==1){
                return Text(
                  '$totalLikes Like',
                  style:  TextStyle(color: Textn),
                );}else if(totalLikes>1){
                return Text(
                  '$totalLikes Likes',
                  style:  TextStyle(color: Textn),
                );
              }else{
                return const Text('');
              }

            }
          }),
    );
  }
}