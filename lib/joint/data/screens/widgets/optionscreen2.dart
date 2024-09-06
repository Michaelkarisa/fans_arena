import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/joint/data/screens/feed_item.dart';
import 'package:fans_arena/reusablewidgets/adstrial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../fans/screens/newsfeed.dart';
import 'package:firebase_auth/firebase_auth.dart';
class OptionsScreen1 extends StatefulWidget {
  const OptionsScreen1( {super.key,});
  @override
  _OptionsScreen1State createState() => _OptionsScreen1State();
}
class _OptionsScreen1State extends State<OptionsScreen1> with SingleTickerProviderStateMixin {
  List<FansTv> posts = [];
late FansTv lastPost;
  final double lazyLoadThreshold = 0.7;
 //AdProvider ad=AdProvider();
  bool isLoading=false;
  @override
  void initState() {
    super.initState();
    _getPostIds();
  //  ad.createInterstitialAd();
  // ad.createRewardedAd();
   //ad.createRewardedInterstitialAd();
    _startTime=DateTime.now();
    getPosts();
  }
  List<String> postIds=[];
  Future<void> _getPostIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    postIds=prefs.getStringList('posts')??[];
  }
  Set<String>postids={};
  late DateTime _startTime;
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
    //ad.dispose();
    super.dispose();
  }

  PageController controller = PageController();
  Newsfeedservice news = Newsfeedservice();
  void getPosts() async {
    setState(() {
      isLoading=true;
    });
    if(postIds.isEmpty) {
      List<FansTv> post = await DataFetcher().getFansTv(FirebaseAuth.instance.currentUser!.uid);
      if (post.isNotEmpty) {
        setState(() {
          isLoading=false;
          lastPost = post.last; // Track the last post from getfeed

        });
      }
      for(final p in post){
        if(!postids.contains(p.postid)){
      setState(() {
        posts.add(p);
        postids.add(p.postid);
      });
      }}
    }else{
        List<FansTv> post = await DataFetcher().getmoreFansTv(FirebaseAuth.instance.currentUser!.uid,postIds.first);
        if (post.isNotEmpty) {
          setState(() {
            isLoading=false;
            lastPost = post.last; // Track the last post from getfeed

          });
        }
        for(final p in post){
          if(!postids.contains(p.postid)){
            setState(() {
              posts.add(p);
              postids.add(p.postid);
            });
          }}
      }

  }
int count=0;
  Future<void> loadMore(index) async {
    setState(() {
      count=count+1;
      currentIndex = index;

    });
    List<FansTv> post = await DataFetcher().getmoreFansTv(FirebaseAuth.instance.currentUser!.uid,lastPost.postid);
    if (post.isNotEmpty) {
      setState(() {
        isLoading=false;
        lastPost = post.last;

      });
    }
    for(final p in post){
      if(!postids.contains(p.postid)){
        setState(() {
          posts.add(p);
          postids.add(p.postid);
        });
      }}
  }

  int currentIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: RefreshIndicator(
            onRefresh: ()async{
              posts = await DataFetcher().getFansTv(FirebaseAuth.instance.currentUser!.uid);
              if (posts.isNotEmpty) {
                lastPost = posts.last;
              }
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: isLoading? const Center(child: CircularProgressIndicator(color: Colors.white,))
                  : PageView.builder(
                controller: controller,
                  scrollDirection: Axis.vertical,
                  itemCount: posts.length,
                  onPageChanged:loadMore,
                  itemBuilder: (ctx, index) {
                  if(count==3){
                    //ad.showInterstitialAd();
                  }
                    return Container(
                        color: Colors.transparent,
                        height: MediaQuery.of(context).size.height,
                        child: FeedItem(ftv: posts[index],opt1: true,completed: () {
                          if(index<posts.length){
                            controller.nextPage(duration: const Duration(milliseconds:300 ), curve: Curves.easeIn);
                            }
                        },index:index ,posts: posts,));
                  }
              ),
            ),
          ),
        ),
      );
  }
}

