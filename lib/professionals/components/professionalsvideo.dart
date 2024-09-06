import 'package:fans_arena/fans/screens/fans_tvviewer2.dart';
import 'package:fans_arena/joint/data/screens/feeditem3.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/newsfeed.dart';
class Professionalsvideos extends StatefulWidget {
  Person user;
  ScrollController controller;
  Professionalsvideos({super.key,
    required this.user,
    required this.controller});

  @override
  State<Professionalsvideos> createState() => _ProfessionalsvideosState();
}

class _ProfessionalsvideosState extends State<Professionalsvideos> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<FansTv> post = [];
  late PostModel1 lastpost;
  bool noPosts=false;
  bool isLoadingMore = true;
  Set<String> postIds={};
  Newsfeedservice news=Newsfeedservice();
  @override
  void initState() {
    super.initState();
    news=Newsfeedservice();
    widget.controller.addListener(() {
      if (!isLoadingMore&&widget.controller.position.pixels >= widget.controller.position.maxScrollExtent*0.5) {
        loadMore();
      }
    });
    getPostsByAuthorId();
  }


  void getPostsByAuthorId() async {
    setState(() {
      m=3;
    });
    List<PostModel1> posts= await news.getFansTvv(userId: widget.user.userId);
    setState(() {
      if(posts.isEmpty){
        noPosts=true;
      }else{
        lastpost=posts.last;
      }
    });
    for(final d in posts){
      await Future.delayed(const Duration(milliseconds: 200));
      if(!postIds.any((uId)=>uId==d.postid)) {
        postIds.add(d.postid);
          post.add(FansTv(
              postid: d.postid,
              timestamp: d.timestamp,
              location: d.location,
              genre: d.genre,
              url: d.url,
              time: d.time,
              time1: d.time1,
              caption: d.caption,
              user: widget.user));
      }
    }
    setState(() {
        m=0;
    });
  }

  void loadMore() async {
    setState(() {
      m=3;
    });
    List<PostModel1> posts=await news.getFansTvv1(startat: lastpost, userId:widget.user.userId);
   setState(() {
     if (posts.isNotEmpty) {
       lastpost=posts.last;
     }});
   for(final d in posts){
     await Future.delayed(const Duration(milliseconds: 200));
     if(!postIds.any((uId)=>uId==d.postid)) {
       postIds.add(d.postid);
         postIds.add(d.postid);
         post.add(FansTv(
             postid: d.postid,
             timestamp: d.timestamp,
             location: d.location,
             genre: d.genre,
             url: d.url,
             time: d.time,
             time1: d.time1,
             caption: d.caption,
             user: widget.user));
     }
   }
   setState(() {
     m=0;
   });
  }

  int m=3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:noPosts?const Center(child: Text("No Videos ")):GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 1,
          mainAxisSpacing: 1,
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
        itemCount: post.length+m , // Adjust the item count
        itemBuilder: (BuildContext context, int index) {
          if(index==post.length||index>post.length){
            return Container(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[800]!,
                highlightColor: Colors.grey[500]!,
                period: const Duration(milliseconds: 800),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }else{
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Fans_tvviewer2(user: widget.user,post:post[index], posts: post,)),
              );
            },
            child: FeedItem3(url: post[index].url, postId: post[index].postid,),
          );
        }},
      ),
    );
  }
}
