import 'package:fans_arena/joint/data/screens/feed_item.dart';
import 'package:flutter/material.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/reusablewidgets/adstrial.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../fans/screens/newsfeed.dart';
class OptionsScreen3 extends StatefulWidget {
  Person user;
  FansTv post;
 List<FansTv> posts;
  OptionsScreen3( {super.key,
    required this.user,
    required this.post,
    required this.posts});
  @override
  _OptionsScreen3State createState() => _OptionsScreen3State();
}

class _OptionsScreen3State extends State<OptionsScreen3> with SingleTickerProviderStateMixin {
  late PostModel1 lastPost;
  final double lazyLoadThreshold = 0.7;
  //AdProvider ad=AdProvider();
  bool isLoading=true;
  Set<String> postIds={};
  @override
  void initState() {
    super.initState();
    //ad=AdProvider();
    //ad.createInterstitialAd();
    //ad.createRewardedAd();
    //ad.createRewardedInterstitialAd();
    _startTime=DateTime.now();
    final initialpage=widget.posts.indexOf(widget.post);
    controller=PageController(initialPage: initialpage);
    setState(() {
      if (widget.posts.isNotEmpty) {
        isLoading=false;
        final p=widget.posts.last;
        lastPost =PostModel1(postid: p.postid,
            location: p.location,
            time: p.time,
            genre: p.genre,
            caption: p.caption,
            url: p.url,
            timestamp: p.timestamp,
            time1: p.time1,
            user: widget.user);
      }
    });
  }
  late DateTime _startTime;
  void deleteCache()async{
    for(final post in widget.posts){
      final file=await checkCacheFor(post.url);
      if(file!=null){
        await DefaultCacheManager().removeFile(post.url);}
    }
  } Future<FileInfo?> checkCacheFor(String url) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
    return value;
  }
  @override
  void dispose(){
    deleteCache();
    Engagement().engagement('Fans_Tv',_startTime,'');
    //ad.dispose();
    super.dispose();
  }

  PageController controller = PageController();
  Newsfeedservice news = Newsfeedservice();

  int count=0;
  Future<void> loadMore(index) async {
    setState(() {
      count=count+1;
      currentIndex = index;
    });
    List<PostModel1> morePosts = await news.getFansTvv1(startat:lastPost,userId:widget.user.userId);
    setState(() {
      for(final d in morePosts) {
        if(!postIds.contains(d.postid)) {
          widget.posts.add(FansTv(
              postid: d.postid,
              timestamp: d.timestamp,
              location: d.location,
              genre: d.genre,
              url: d.url,
              time: d.time,
              time1: d.time1,
              caption: d.caption,
              user: widget.user));
        }else{
          morePosts.remove(d);
        }
      }
      if(morePosts.isNotEmpty){
        lastPost=morePosts.last;
      }
    });
  }
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.black,
          child:isLoading?const Center(child: CircularProgressIndicator(color: Colors.white,)): PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget.posts.length,
              controller: controller,
              onPageChanged: loadMore,
              itemBuilder: (ctx, index) {
                  return Container(
                      color: Colors.transparent,
                      height: MediaQuery.of(context).size.height,
                      child: FeedItem(ftv: widget.posts[index],opt1: true, completed: () {
                        if(index<widget.posts.length){
                          controller.nextPage(duration: const Duration(milliseconds:300 ), curve: Curves.easeIn);}
                      },index:index ,posts: widget.posts,));
                }
          ),
        ),
      ),
    );
  }}

