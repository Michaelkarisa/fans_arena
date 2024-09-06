import 'package:fans_arena/joint/data/screens/feed_item.dart';
import 'package:flutter/material.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/reusablewidgets/adstrial.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../fans/screens/newsfeed.dart';

class OptionsScreen2 extends StatefulWidget {
String postId;
   OptionsScreen2( {super.key,required this.postId});
  @override
  _OptionsScreen2State createState() => _OptionsScreen2State();
}

class _OptionsScreen2State extends State<OptionsScreen2> with SingleTickerProviderStateMixin {
  List<FansTv> posts = [];
  late FansTv lastPost;
  final double lazyLoadThreshold = 0.7;
 // AdProvider ad=AdProvider();
  @override
  void initState() {
    super.initState();
    //ad.createInterstitialAd();
    //ad.createRewardedAd();
    //ad.createRewardedInterstitialAd();
    _startTime=DateTime.now();
    getPosts();
  }
  late DateTime _startTime;
bool isLoading=false;
  void deleteCache()async{
    for(final post in posts){
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
   // ad.dispose();
    super.dispose();
  }

  PageController controller = PageController();
  Newsfeedservice news = Newsfeedservice();
  void getPosts() async {
    setState(() {
      isLoading=true;
    });
    List<FansTv> post = await DataFetcher().getFansTv(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      posts.addAll(post);
      if (post.isNotEmpty) {
        isLoading=false;
        lastPost = post.last;
      }
    });
    List<FansTv> morePosts = await DataFetcher().getFansTv(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      posts.addAll(morePosts);
      if (morePosts.isNotEmpty) {
        lastPost = morePosts.last;
      }
    });
  }
  int count=0;
  Future<void> loadMore(index) async {
    setState(() {
      count=count+1;
      currentIndex = index;
    });
    List<FansTv> morePosts = await DataFetcher().getmoreFansTv(FirebaseAuth.instance.currentUser!.uid,lastPost.postid);
    setState(() {
      posts.addAll(morePosts);
      if (morePosts.isNotEmpty) {
        lastPost = morePosts.last;
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
              itemCount: posts.length,
              onPageChanged: loadMore,
              itemBuilder: (ctx, index) {
                  return Container(
                      color: Colors.transparent,
                      height: MediaQuery.of(context).size.height,
                      child: FeedItem(ftv: posts[index],opt1: true,completed: () {
                        if(index<posts.length){
                          controller.nextPage(duration: const Duration(milliseconds:300 ), curve: Curves.easeIn);}
                      },index:index ,posts: posts,));

              }
          ),
        ),
      ),
    );
  }}
