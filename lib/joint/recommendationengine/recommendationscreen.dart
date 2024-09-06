import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/recommendationengine/feeditem2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendationScreen extends StatefulWidget {
  List<PostModel1>posts;
   RecommendationScreen({super.key,
     required this.posts,
    });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen>  {
  List<String> postIds=[];
  Future<void> _setPostIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('posts', postIds);
  }

  @override
  Widget build(BuildContext context) {
                  return SizedBox(
                height: 270,
                child: Column(
                  children: [
                    Container(
                      color: Colors.grey[200],
                      width:MediaQuery.of(context).size.width,height: 35,child: Padding(
                      padding: const EdgeInsets.only(left: 15,right: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('FansTv videos',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                          SizedBox(
                              height: 35,
                              child: TextButton(onPressed: (){
                                Bottomnavbar.setCamera2(context,widget.posts[0]);
                                for(final post in widget.posts){
                                  postIds.add(post.postid);
                                }
                                _setPostIds();
                              }, child: const Text('Explore',style: TextStyle(color: Colors.blue,),)))
                        ],
                      ),
                    ),),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.posts.length,
                        itemBuilder: (ctx, index) {
                          final post = widget.posts[index];
                          return InkWell(
                              onTap: (){
                                Bottomnavbar.setCamera2(context,post);
                              },
                              child: Feeditem2(videoUrl: post.url, postId: post.postid,));
                        },
                      ),
                    ),
                  ],
                ),
              );
  }
}


