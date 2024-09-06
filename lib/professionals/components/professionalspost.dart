import 'package:fans_arena/joint/components/apostold.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/newsfeed.dart';
import 'package:shimmer/shimmer.dart';
class Professionalspost extends StatefulWidget {
  Person user;
  ScrollController controller;
  Professionalspost({super.key,
    required this.user,
    required this.controller});

  @override
  State<Professionalspost> createState() => _ProfessionalspostState();
}

class _ProfessionalspostState extends State<Professionalspost> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Posts> posts = [];
  Newsfeedservice news=Newsfeedservice();
  late PostModel lastPost;
  bool noPosts=false;
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.position.pixels >= widget.controller.position.maxScrollExtent*0.5) {
        loadMore1();
      }
    });
    news=Newsfeedservice();
    getPosts();
  }
  Set<String>postIds={};
  Future<void> getPosts()async{
    try {
      setState(() {
        m = 3;
      });
      List<PostModel> post = await news.getMyfeed(userId: widget.user.userId);
      setState(() {
        if (post.isEmpty) {
          noPosts = true;
        } else {
          lastPost = post.last;
        }
      });
      for (final d in post) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!postIds.any((uId) => uId == d.postid)) {
          postIds.add(d.postid);
          posts.add(Posts(
              postid: d.postid,
              timestamp: d.timestamp,
              location: d.location,
              genre: d.genre,
              captionUrl: d.captionUrl,
              time: d.time,
              time1: d.time1,
              user: widget.user));
        }
      }
      setState(() {
        m = 0;
      });
    }catch(e){
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        );
      });
    }
  }
  Future<void> loadMore1()async{
    setState(() {
      m=3;
    });
    List<PostModel> morePosts = await news.getMyfeed1(startpost: lastPost,userId: widget.user.userId);
    setState(() {
      if (morePosts.isNotEmpty) {
        lastPost =morePosts.last;
      }});
        for(final d in morePosts) {
          await Future.delayed(const Duration(milliseconds: 200));
          if(!postIds.any((uId)=>uId==d.postid)) {
            postIds.add(d.postid);
            posts.add(Posts(
                postid: d.postid,
                timestamp: d.timestamp,
                location: d.location,
                genre: d.genre,
                captionUrl: d.captionUrl,
                time: d.time,
                time1: d.time1,
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
      body:noPosts?const Center(child: Text('No Posts')):GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: posts.length+m,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.0,
          crossAxisCount: 3,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
        ),
        itemBuilder: (context, index) {
          if(index== posts.length||index> posts.length){
            return Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[500]!,
              period: const Duration(milliseconds: 800),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            );
          }else{
            List<Map<String, dynamic>> allLikes = [];
            final List<dynamic> likesArray = posts[index].captionUrl;
            allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
            final firstUrl = allLikes.isNotEmpty ? allLikes[0]['url'] : '';
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Apostold(user: widget.user, post: posts[index], posts: posts,)),
                );
              },
              child: Stack(
                children: [
                  Container(
                    width:MediaQuery.of(context).size.width*0.333,
                    height:MediaQuery.of(context).size.height*0.156323019,
                    color: Colors.black,
                    child: CachedNetworkImage(
                      imageUrl: firstUrl,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                        child: SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 30,)),
                    ),
                  ),
                  allLikes.length>1? const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.photo_library,color: Colors.white,size: 20,),
                    ),
                  ):const SizedBox.shrink()
                ],
              ),
            );
          }},
      ),
    );
  }
}