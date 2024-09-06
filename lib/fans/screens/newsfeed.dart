import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fans_arena/joint/components/stories.dart';
import 'package:fans_arena/joint/components/colors.dart';
import '../../joint/data/sportsapi/sportsmodel.dart';
import '../../joint/recommendationengine/recommendationscreen.dart';
import '../../joint/recommendationengine/recommendationscreen1.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../data/notificationsmodel.dart';
import '../data/videocontroller.dart';
import 'homescreen.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class NewsFeed extends StatefulWidget {
  const NewsFeed({super.key});

  @override
  State<NewsFeed> createState() => _NewsFeedState();
}

class _NewsFeedState extends State<NewsFeed> {
  List<Widget>widgets=[];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Posts> posts = [];
  List<Person> users = [];
 List<PostModel1> ptv = [];
  Set<String> postIds = {};
  late Posts lastPost;
  late DateTime _startTime;
  Set<String> userIds = {};
  String userId = '';
  String collectionName = '';
  late NetworkProvider connectivityProvider;
  @override
  void initState() {
    super.initState();
    connectivityProvider = Provider.of<NetworkProvider>(context, listen: false);
    connectivityProvider.addListener(_connectivityChanged);
    connectivityProvider.connectivity();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
    }
    widgets=[NewsStory(
      controller: controller1,
      stories: stories,
      isLoadingStories: isLoadingStories,
      captionUrl: myStory,
      noMoreStories:noMoreStories,
      function: ()=>getStories1(),
    ),PostLShimer()];
    setState(() {
      myStory = Story(
        timestamp: Timestamp.now(),
        story: story,
        time: '',
        StoryId: '',
        user: Person(
          name: '',
          url: '',
          collectionName: collectionName,
          userId: userId,
        ),
      );
    });
    _startTime = DateTime.now();
    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent * 0.5) {
        loadMore1();
      }
    });
    controller1.addListener(() {
      if (controller1.position.pixels >= controller1.position.maxScrollExtent * 0.5) {
        getStories1();
      }
    });
  }
  bool get=true;
  bool noMorePosts = false;
  bool isLoading = true;
  bool oldPosts=false;
  bool isLoadingStories = true;
  bool noMoreStories=false;

  Future<void> _connectivityChanged() async {
    if(get){
    if (connectivityProvider.isConnected) {
      await getData();
    } else {
      await getData();
    }}
  }
  Future<void> getData() async {
    setState(() {
      isLoading = true;
      posts.clear();
      users.clear();
      ptv.clear();
      postIds.clear();
      userIds.clear();
      oldPosts=false;
      isLoadingStories=true;
      noMorePosts=false;
      noMoreStories=false;
      widgets=[NewsStory(
        controller: controller1,
        stories: stories,
        isLoadingStories: isLoadingStories,
        captionUrl: myStory,
        noMoreStories:noMoreStories,
        function: ()=>getStories1(),
      ),PostLShimer()];
    });
    await getStories();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collectionName = prefs.getString('cname') ?? '';
    });
    if (collectionName.isEmpty) {
      collectionName = await news.getAccount(userId);
    }
    if (collectionName == 'Fan') {
      retrieveUserData();
    }
    getPosts();
    if (collectionName == 'Fan') {
      getTv();
    }
  }

  Future<void> getTv() async {
    ptv = await news.getFansTv();
  }

  Future<void> retrieveUserData() async {
    try {
       users = await fetchPosts.getsuggesteddata(userId);
    }catch(e){
    }
  }
  DataFetcher fetchPosts = DataFetcher();


  Future<void>removeLast()async{
    setState(() {
      widgets.removeLast();
    });
  }
  Future<void> getPosts() async {
    List<Posts> post = await fetchPosts.getPostsForFollowedUsers(userId);
    setState(() {
      if (post.isNotEmpty) {
        lastPost = post.last;
        get=false;
      }
    });
    for (final post1 in post) {
      if (!postIds.any((uId) => uId == post1.postid)) {
        postIds.add(post1.postid);
        await Future.delayed(const Duration(milliseconds: 300));
        if(post1.postid==post.first.postid) {
          await removeLast();
        }
        Timestamp time = post1.timestamp;
        DateTime date = time.toDate();
        final now = DateTime.now();
        int hours = now.difference(date).inHours;
        if (hours > 24) {
         posts.add(post1);
          if(!oldPosts) {
            widgets.add(collectionNamefor=="Fan"?RecommendationScreen1(users:users,):SizedBox.shrink());
            widgets.add(collectionNamefor=="Fan"?RecommendationScreen(posts: ptv,):SizedBox.shrink());
            widgets.add(Container(
              color: Colors.grey[200],
              height: 25,
              child: const Center(
                child: Text(
                  "Older Posts",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ));
            widgets.add(PostLayout(post: post1));
            oldPosts=true;
          }else{
            widgets.add(PostLayout(post: post1));
          }
        } else if (hours < 24) {
          posts.add(post1);
          widgets.add(PostLayout(post: post1));
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> loadMore1() async {
    if(!isLoading&&!get) {
    setState(() {
      if(!noMorePosts) {
        widgets.add(PostLShimer());
        isLoading = true;
      }
    });
    try {
      List<Posts> morePosts = await fetchPosts.getmorePostsForFollowedUsers(userId, lastPost.postid);
        if (morePosts.isNotEmpty) {
          setState(() {
            lastPost = morePosts.last;
          });
        } else{
          if(!noMorePosts) {
              await removeLast();
            setState(() {
            isLoading = false;
            noMorePosts = true;
          widgets.add(Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.003333,
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                  const Text(
                    'No more posts',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.003333,
                    child: Divider(
                      thickness: 2,
                      color: Colors.grey[300],
                    ),
                  ),
                ],
              ),
            ),
          ));});
        }}
      for (final post1 in morePosts) {
        if (!postIds.any((uId) => uId == post1.postid)) {
          postIds.add(post1.postid);
          await Future.delayed(const Duration(milliseconds: 300));
          if(post1.postid==morePosts.first.postid) {
            await removeLast();
          }
          Timestamp time = post1.timestamp;
          DateTime date = time.toDate();
          final now = DateTime.now();
          int hours = now.difference(date).inHours;
          if (hours > 24) {
            posts.add(post1);
            if(!oldPosts) {
              widgets.add(collectionNamefor=="Fan"?RecommendationScreen1(users:users):SizedBox.shrink());
              widgets.add(collectionNamefor=="Fan"?RecommendationScreen(posts: ptv):SizedBox.shrink());
              widgets.add(   Container(
                color: Colors.grey[200],
                height: 25,
                child: const Center(
                  child: Text(
                    "Older Posts",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ));
              widgets.add(PostLayout(post: post1));
              oldPosts=true;
            }else{
              widgets.add(PostLayout(post: post1));
            }
          } else if (hours < 24) {
            posts.add(post1);
            widgets.add(PostLayout(post: post1));
          }
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {

    }
    }
  }



  ScrollController controller = ScrollController();
  Newsfeedservice news = Newsfeedservice();
  @override
  void dispose(){
    Engagement().engagement('Newsfeed',_startTime,'');
    connectivityProvider.removeListener(_connectivityChanged);
    super.dispose();
  }
  late Story lastStory;
  List<Story> stories = [];
  late Story myStory;
  Set<String> storyIds = {};
  List<Map<String, dynamic>> story = [];
  Set<String> authorIds = {};
  ScrollController controller1 = ScrollController();

  Future<void> getStories() async {
    setState(() {
      stories.clear();
      storyIds.clear();
      authorIds.clear();
    });
    myStory = await getMyStory();
    List<Story> post = await fetchPosts.getStoryForFollowedUsers(userId);
    setState(() {
      if (post.isNotEmpty) {
        lastStory = post.last;
      }
    });
    post.sort((a, b) {
      Timestamp latestTimestampA = a.story.last['timestamp'];
      Timestamp latestTimestampB = b.story.last['timestamp'];
      return latestTimestampB.compareTo(latestTimestampA);
    });
    for (final p in post) {
      if (!storyIds.any((storyId)=>storyId==p.StoryId)) {
        storyIds.add(p.StoryId);
        Timestamp time = p.timestamp;
        DateTime date = time.toDate();
        final now = DateTime.now();
        int hours = now.difference(date).inHours;
        if (hours > 24) {
          // Handle old stories if needed
        } else if (hours < 24) {
          // Handle new stories if needed
        }
        //await Future.delayed(const Duration(milliseconds: 300));
        if (authorIds.any((userId)=>userId==p.user.userId)) {
          final d = stories.firstWhere((element) => element.user.userId == p.user.userId);
          d.story.addAll(p.story);
          d.story.sort((a, b) {
            Timestamp latestTimestampA = b['timestamp'];
            Timestamp latestTimestampB = a['timestamp'];
            return latestTimestampB.compareTo(latestTimestampA);
          });
        } else {
          authorIds.add(p.user.userId);
          stories.add(p);
          stories.sort((a, b) {
            Timestamp latestTimestampA = a.timestamp;
            Timestamp latestTimestampB = b.timestamp;
            return latestTimestampB.compareTo(latestTimestampA);
          });
        }
      }
    }
    setState(() {
      isLoadingStories = false;
      widgets=[NewsStory(
        controller: controller1,
        stories: stories,
        isLoadingStories: isLoadingStories,
        captionUrl: myStory,
        noMoreStories:noMoreStories,
        function: ()=>getStories1(),
      ),PostLShimer()];
    });
  }

  Future<void> getStories1() async {
    setState(() {
      isLoadingStories = true;
    });
    List<Story> post = await fetchPosts.getmoreStoryForFollowedUsers(userId, lastStory.StoryId);
    setState(() {
      if (post.isNotEmpty) {
        lastStory = post.last;
      }else{
        noMoreStories=true;
      }
    });
    for (final p in post) {
      if (!storyIds.any((storyId)=>storyId==p.StoryId)) {
        storyIds.add(p.StoryId);
        Timestamp time = p.timestamp;
        DateTime date = time.toDate();
        final now = DateTime.now();
        int hours = now.difference(date).inHours;
        if (hours > 24) {
          // Handle old stories if needed
        } else if (hours < 24) {
          // Handle new stories if needed
        }
        await Future.delayed(const Duration(milliseconds: 300));
        if (authorIds.any((userId)=>userId==p.user.userId)) {
          final d = stories.firstWhere((element) => element.user.userId == p.user.userId);
          d.story.addAll(p.story);
          d.story.sort((a, b) {
            Timestamp latestTimestampA = b['timestamp'];
            Timestamp latestTimestampB = a['timestamp'];
            return latestTimestampB.compareTo(latestTimestampA);
          });
        } else {
          authorIds.add(p.user.userId);
          stories.add(p);
          stories.sort((a, b) {
            Timestamp latestTimestampA = a.timestamp;
            Timestamp latestTimestampB = b.timestamp;
            return latestTimestampB.compareTo(latestTimestampA);
          });
        }
      }
    }
    setState(() {
      isLoadingStories = false;
    });
  }

  Future<Story>getMyStory()async{
    List<Map<String,dynamic>>captionUrl=[];
    QuerySnapshot querySnapshot=await FirebaseFirestore.instance.collection('Story').where('authorId',isEqualTo: userId).get();
    final List<QueryDocumentSnapshot> likeDocuments = querySnapshot.docs;
    Timestamp timestamp=Timestamp.now();
    for (final document in likeDocuments) {
      timestamp = document['createdAt'];
      final List<dynamic> likesArray = document['story'];
      captionUrl.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    captionUrl.sort((a, b){
      Timestamp latestTimestampA = b['timestamp'];
      Timestamp latestTimestampB = a['timestamp'];
      return latestTimestampB.compareTo(latestTimestampA);
    });
    DateTime createdDateTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdDateTime);
    String formattedTime = '';
    String hours = DateFormat('HH').format(createdDateTime);
    String minutes = DateFormat('mm').format(createdDateTime);
    String t = DateFormat('a').format(createdDateTime); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdDateTime);
    }
    String url=profileimage;
    String name=username;
    if(username.isEmpty||profileimage.isEmpty){
      DocumentSnapshot documentSnapshot1= await FirebaseFirestore.instance.collection('${collectionNamefor}s').doc(userId).get();
      if(documentSnapshot1.exists){
        var data=documentSnapshot1.data() as Map<String,dynamic>;
        setState(() {
          name=data['Clubname']??'';
          url=data['profileimage']??'';
          if(name.isEmpty){
            name=data['Stagename']??'';
            if(name.isEmpty){
              name=data['username']??'';
            }
          }
        });
      }}
    return Story(
      user: Person(name:name,
        url: url,
        collectionName:collectionName,
        userId: userId,),
      StoryId: '',
      timestamp: timestamp,
      time:formattedTime,
      story: captionUrl,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          elevation: 1,
          automaticallyImplyLeading: false,
          title: Text('Fans Arena', style: TextStyle(color: Textn),),
          backgroundColor: Appbare,
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                get = true;
              });
              await _connectivityChanged();
            },
            child: ListView.builder(
                controller: controller,
                itemCount: widgets.length,
                itemBuilder: (context,index){
                  return widgets[index];
                }
            )));
  }
}

class EditPost extends StatefulWidget {
   Posts? post;
  FansTv? ftv;
  EditPost({super.key,this.post,this.ftv});

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();
  bool isNotExpanded = false;
  int maxTextLength = 100;
  String location = '';
  List<TextEditingController> list = [];
  double radius = 23;
  int ind = 0;
  final VideoControllerProvider _controller=VideoControllerProvider();
  bool _isPlaying = false;
  @override
  void initState() {
    super.initState();
    _pageController1.addListener(_onPageChanged);
    if(widget.ftv==null) {
      location = _truncateText(widget.post!.location);
      list = List.generate(widget.post!.captionUrl.length, (index) {
        return TextEditingController(
            text: widget.post?.captionUrl[index]['caption']);
      });
    }else{
      location = _truncateText(widget.ftv!.location);
      list = List.generate(1, (index) {
        return TextEditingController(
            text: widget.ftv?.caption);
      });
      initializePlayer(widget.ftv!.url);
    }
  }

  String _truncateText(String text) {
    if (text.length <= maxTextLength) {
      return text;
    } else if (text.length > maxTextLength && !isNotExpanded) {
      return "${text.substring(0, maxTextLength - 5)}...";
    } else {
      return "$text ";
    }
  }

  void _onPageChanged() {
    if (_pageController1.page != _pageController2.page) {
      _pageController2.jumpToPage(_pageController1.page!.toInt());
    }
  }

  @override
  void dispose() {
    _pageController1.removeListener(_onPageChanged);
    _pageController1.dispose();
    _pageController2.dispose();
    for (var controller in list) {
      controller.dispose();
    }
    _controller.controller.dispose();
    super.dispose();
  }

  Future<void> saveDataToFirestore() async {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('Editing post...'),
        );
      },
    );
    try {
      for (var existingItem in list) {
        int i = list.indexOf(existingItem);
        if (existingItem.text.isNotEmpty) {
          widget.post?.captionUrl[i]['caption'] = existingItem.text;
        }
      }
      await FirebaseFirestore.instance.collection('posts').doc(widget.post?.postid).update({
        'captionUrl': widget.post?.captionUrl,
      });
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1));
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Post edited'),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  Future<void> saveDataToFirestore1() async {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          content: Text('Editing video...'),
        );
      },
    );
    try {
      for (var existingItem in list) {
        if (existingItem.text.isNotEmpty) {
          await FirebaseFirestore.instance.collection('FansTv').doc(widget.ftv?.postid).update({
            'caption': existingItem.text,
          });

        }
         existingItem.text.isEmpty;
      }
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Video edited'),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  void initializePlayer(String url) async {
    _controller.initialize(url);
    final fileInfo= await checkCacheFor(url);
    if(fileInfo==null){
      _controller.controller.initialize().then((value) {
        cachedForUrl(url);
        setState(() {
          _controller.controller.play();
          _controller.controller.setVolume(100.0);
          changed = true;
          _isPlaying = true;
          isLoading = false;
        });
      });}else{
      final file = fileInfo.file;
      _controller.controller = VideoPlayerController.file(file);
      _controller.controller.initialize().then((value) {
        _controller.controller.setLooping(true);
        _controller.controller.play();
        _controller.controller.setVolume(100.0);
        changed = true;
        _isPlaying = true;
        isLoading = false;
      });
    }
    _controller.controller.addListener(() {
      if(_controller.controller.value.isInitialized){
        setState(() {
          if (_controller.controller.value.isBuffering) {
            isLoading=true;
          }else{
            isLoading = false;
          }
        });
        List<DurationRange> buffered=_controller.controller.value.buffered;
      }else{
        setState(() {
          isLoading=true;
        });
      }
      if(_controller.controller.value.isCompleted){
        initializePlayer(url);
      }
    });
  }
  bool isfile=false;
  Future<FileInfo?> checkCacheFor(String url) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
    return value;
  }
  bool changed =false;
  void cachedForUrl(String url) async {
    await DefaultCacheManager().getSingleFile(url).then((value) {
    });
  }
  void deleteCache(url)async{
      await DefaultCacheManager().removeFile(url).then((value){
      });
  }
  bool isLoading =true;
  void _onPlayButtonPressed()async {
    if (_controller.controller.value.isPlaying) {
      setState(() {
        changed =false;
        _controller.controller.pause();
      });
      await  Future.delayed(const Duration(milliseconds: 400));
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _controller.controller.play();
        _isPlaying = true;
        changed =true;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.ftv==null?const Text('Edit Post'):const Text('Edit FansTv'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Container(
                  color: Colors.black,
                  width: MediaQuery.of(context).size.width,
                  constraints: const BoxConstraints(
                    minHeight: 0,
                    maxHeight: 500,
                  ),
                  child:widget.post==null?ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child:  AnimatedBuilder(
                      animation: _controller,
                      builder: (BuildContext context, Widget? child) {
                        return  Container(
                          color: Colors.transparent,
                          height: MediaQuery.of(context).size.height,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ((_controller.controller==null)
                                  ? const SizedBox.shrink(): AspectRatio(
                                aspectRatio: _controller.controller.value.aspectRatio,
                                child: GestureDetector(

                                  onTap: _onPlayButtonPressed,
                                  child: VideoPlayer(_controller.controller),
                                ),
                              )

                              ),
                              isLoading? const Center(
                                  child: CircularProgressIndicator(color: Colors.white)):const SizedBox.shrink(),
                              Positioned.fill(
                                child: AnimatedOpacity(
                                  opacity: changed ? 0.0 : 1.0,
                                  duration: const Duration(milliseconds: 500),
                                  child: Align(
                                    alignment: const Alignment(0.0,0.0),
                                    child: IconButton(
                                      icon:_isPlaying ? const Icon(Icons.pause, size: 50,color: Colors.white,): const Icon(Icons.play_arrow, size: 50,color: Colors.white,),
                                      onPressed: _onPlayButtonPressed,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ):Stack(
                    fit: StackFit.passthrough,
                    children: [
                      PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:widget.post?.captionUrl.length,
                        controller: _pageController1,
                        itemBuilder: (context, index) {
                          final captionUrl = widget.post?.captionUrl[index];
                          return CachedNetworkImage(
                            imageUrl: captionUrl?['url'],
                            fit: BoxFit.contain,
                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                              child: SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  value: downloadProgress.progress,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.error, color: Colors.white, size: 40),
                            ),
                          );
                        },
                        onPageChanged: (int index) {
                          setState(() {
                            ind = index;
                          });
                        },
                      ),
                      if (widget.post!.captionUrl.length > 1)
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 20,
                                    maxWidth: 50,
                                    minHeight: 0,
                                    minWidth: 0,
                                  ),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.black,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${ind + 1}/${widget.post?.captionUrl.length}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5, top: 15),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 80,
                    color: Colors.transparent,
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.post==null?1:list.length,
                      onPageChanged: (int index) {
                        setState(() {
                          ind = index;
                        });
                      },
                      controller: _pageController2,
                      itemBuilder: (context, index) {
                        return Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.7375,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              scrollPadding: const EdgeInsets.only(bottom: 1),
                              scrollPhysics: const ScrollPhysics(),
                              expands: false,
                              maxLines: 6,
                              minLines: 1,
                              textInputAction: TextInputAction.newline,
                              cursorColor: Colors.black,
                              controller: list[index],
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(bottom: 0, left: 5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: const BorderSide(width: 1, color: Colors.grey),
                                ),
                                filled: true,
                                hintStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                                fillColor: Colors.white70,
                                suffixIcon: const Icon(Icons.emoji_emotions),
                                hintText: 'Type caption',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 35,
                width: 130,
                child: OutlinedButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  onPressed: () async {
                    if(widget.post==null){
                      await saveDataToFirestore1();
                    }else {
                      await saveDataToFirestore();
                    }
                  },
                  child: const Text(
                    'Update post',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class NewsStory extends StatefulWidget {
   List<Story> stories;
  ScrollController controller;
   bool isLoadingStories;
   Story captionUrl;
   bool noMoreStories;
   void Function()function;
  NewsStory({
    super.key,
    required this.controller,
    required this.stories,
    required this.isLoadingStories,
    required this.captionUrl,
    required this.noMoreStories,
    required this.function,
  });

  @override
  State<NewsStory> createState() => _NewsStoryState();
}

class _NewsStoryState extends State<NewsStory> {
  @override
  void didUpdateWidget(covariant NewsStory oldWidget) {
    if (oldWidget.controller.position.pixels != widget.controller.position.pixels) {
      setState((){});
    }
    if (oldWidget.noMoreStories != widget.noMoreStories) {
      setState((){});
    }
    if (oldWidget.isLoadingStories != widget.isLoadingStories) {
      setState((){});
    }
    super.didUpdateWidget(oldWidget);
  }
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.position.pixels >= widget.controller.position.maxScrollExtent * 0.5) {
        widget.function();
        setState(() {});
      }
    });
  }
  @override
  Widget build(BuildContext context) {
        final isSmallScreen = MediaQuery.of(context).size.height < 700;
        final storyHeight = isSmallScreen ? MediaQuery.of(context).size.height * 0.2 : MediaQuery.of(context).size.height * 0.235;
        final captionWidth = MediaQuery.of(context).size.width * 0.29;
        return Padding(
          padding: const EdgeInsets.only(top: 5),
          child: SizedBox(
            height: storyHeight,
            child: ListView.builder(
              controller: widget.controller,
              scrollDirection: Axis.horizontal,
              itemCount:  widget.stories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0&&widget.stories.isNotEmpty) {
                  return SizedBox(
                    width: captionWidth,
                    child: Mystory(story: widget.captionUrl),
                  );
                } else if (index == widget.stories.length) {
                  if(widget.stories.isEmpty){
                    return Row(children: [
                      SizedBox(
                        width: captionWidth,
                        child: Mystory(story: widget.captionUrl),
                      ),_buildLoadingOrEmptyState(),
                    ],);
                  }else {
                    return _buildLoadingOrEmptyState();
                  }
                } else {
                  return OtherUsers(stories: widget.stories, story: widget.stories[index]);
                }
              },
            ),
          ),
        );
  }

  Widget _buildLoadingOrEmptyState() {
    if (widget.isLoadingStories) {
      return Row(
        children: List.generate(4, (_) => StoryItems()),
      );
    } else if(widget.noMoreStories){
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.5,
          child: const Center(
            child: Text(
              'No Stories Available',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      );
    }else{
      return SizedBox.shrink();
    }
  }
}



class SVideo extends StatefulWidget {
  String story;
  SVideo({super.key,required this.story});

  @override
  State<SVideo> createState() => _SVideoState();
}

class _SVideoState extends State<SVideo> {
  @override
  void initState() {
    super.initState();
    initializePlayer(widget.story);

  }
  late VideoPlayerController _controller;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int duration=0;
  bool isvideo=false;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void initializePlayer(String videoUrl) async {
    final fileInfo = await checkCacheFor(videoUrl);
    try {
      if (fileInfo == null) {
        _controller = VideoPlayerController.network(videoUrl);
        await _controller.initialize();
      } else {
        final file = fileInfo.file;
        _controller = VideoPlayerController.file(file);
        await _controller.initialize();
      }
      setState(() {
        isvideo=true;
        duration=_controller.value.duration.inSeconds;
      });
    }catch(e){
      setState(() {
        isvideo=false;
      });
    }
    setState(() {
      _controller.setLooping(true);
      _controller.play();
      _controller.setVolume(0);
    });
  }

  Future<FileInfo?> checkCacheFor(vvideourl) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(
        vvideourl);
    return value;
  }

  // Cache Url Data
  void cachedForUrl(videourl) async {
    await DefaultCacheManager().getSingleFile(videourl).then((value) {
      print('downloaded successfully done for $videourl');
    });
  }
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: _controller != null
          ? VideoPlayer(_controller)
          :  const Center(child: SizedBox(width:25,
          height: 25,
          child: CircularProgressIndicator(color: Colors.black,))),
    );
  }
}
class SImage extends StatelessWidget {
  String story;
  SImage({super.key,required this.story});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:CachedNetworkImage(
        imageUrl:story,
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              value: downloadProgress.progress,
            ),
          ),
        ),
        errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
      ),
    );
  }
}




class StoryItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.28,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[800]!,
                    highlightColor: Colors.grey[500]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: SizedBox(height: 20,),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 5.0,  left: 5),
            child: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.248,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width:13 ,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      period: const Duration(milliseconds: 800),
                      child: Container(
                        width:13 ,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}



class TvItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 220,
          width: 140,
          decoration: BoxDecoration(
              borderRadius:BorderRadius.circular(10) ,
              border: Border.all(
                  width: 1,
                  color: Colors.grey
              )
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[500]!,
            period: const Duration(milliseconds: 800),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CommentShimmer extends StatefulWidget {
  const CommentShimmer({super.key});

  @override
  State<CommentShimmer> createState() => _CommentShimmerState();
}

class _CommentShimmerState extends State<CommentShimmer> {
  List<double> sizes=[300,320,240,360];
  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
        itemCount: sizes.length,
        itemBuilder: (context,index){
          double size=sizes[index];
          final t=size*index;
          final d=t/2;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[600]!,
                highlightColor: Colors.grey[500]!,
                period: Duration(milliseconds: 600+d.toInt()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5,left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 43,
                            width: 43,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              period: Duration(milliseconds: 600+d.toInt()),
                              child: Container(
                                height: 43,
                                width: 43,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(50)
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              height: 25,
                              width: size/2,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                period: Duration(milliseconds: 600+d.toInt()),
                                child: Container(
                                  height: 25,
                                  width: size/2,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(50)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );}
    );

  }
}
class LFShimmer extends StatefulWidget {
  const LFShimmer({super.key});

  @override
  State<LFShimmer> createState() => _LFShimmerState();
}

class _LFShimmerState extends State<LFShimmer> {
  List<double> sizes=[300,320,240,360];
  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
        itemCount: sizes.length,
        itemBuilder: (context,index){
          double size=sizes[index];
          final t=size*index;
          final d=t/2;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              width: size,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[600]!,
                highlightColor: Colors.grey[500]!,
                period: Duration(milliseconds: 600+d.toInt()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5,left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: 43,
                            width: 43,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              period: Duration(milliseconds: 600+d.toInt()),
                              child: Container(
                                height: 43,
                                width: 43,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(50)
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              height: 25,
                              width: size/2,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                period: Duration(milliseconds: 600+d.toInt()),
                                child: Container(
                                  height: 25,
                                  width: size/2,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(50)
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );}
    );

  }
}
class PostLShimer extends StatelessWidget {
  const PostLShimer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.003333,
            child:  Divider(
              thickness: 2,
              color: Colors.grey[300],
            )),
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.975,
            height:55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceEvenly,
              children: [
                Container(
                  height: 43,
                  width: 43,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    period: const Duration(milliseconds: 800),
                    child: Container(
                      height: 43,
                      width: 43,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(50)
                      ),
                    ),
                  ),
                ),
                //
                SizedBox(
                  height:55,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.85,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceEvenly,
                    children: [
                      SizedBox(
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.0333,
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.85,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween,
                          children: [
                            SizedBox(
                              width: 180,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text("Loading username",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                  AnimatedTextKit(
                                    totalRepeatCount: 100,
                                    pause: const Duration(milliseconds: 200),
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        '.....',
                                        curve: Curves.linear,
                                        textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                        speed: const Duration(milliseconds: 100),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                                width:20,
                                height:  32,
                                child: Icon(Icons.more_vert)
                            ), //
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width * 0.87,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween,
                          children: [
                            SizedBox(
                              width: 180,
                              child: Row(
                                children: [
                                  const Text("Loading location",style: TextStyle(fontSize: 14)),
                                  AnimatedTextKit(
                                    totalRepeatCount: 100,
                                    pause: const Duration(milliseconds: 200),
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        '.....',
                                        curve: Curves.linear,
                                        textStyle: const TextStyle(fontSize: 14),
                                        speed: const Duration(milliseconds: 100),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 110,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Text("Loading time",style: TextStyle(fontSize: 13)),
                                  AnimatedTextKit(
                                    totalRepeatCount: 100,
                                    pause: const Duration(milliseconds: 200),
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        '.....',
                                        curve: Curves.linear,
                                        textStyle: const TextStyle(fontSize: 13),
                                        speed: const Duration(milliseconds: 100),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 5,),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.003333,
            child:  Divider(
              thickness: 2,
              color: Colors.grey[300],
            )),
        SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child:Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[500]!,
              period: const Duration(milliseconds: 800),
              child:Container(
                color: Colors.white,
              ),
            )
        ),
        Row(
          children: [
            SizedBox(
              width: 80,
              child: IconButton(
                onPressed: () {
                },
                icon: const Icon(
                  Icons.thumb_up_off_alt,
                  size: 25,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: IconButton(onPressed: () {
              }, icon: const Icon(Icons.mode_comment_outlined,)),
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.only(left: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 25,
                      width:180 ,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Loading caption",style: TextStyle(fontSize: 15)),
                          AnimatedTextKit(
                            totalRepeatCount: 100,
                            pause: const Duration(milliseconds: 200),
                            animatedTexts: [
                              TyperAnimatedText(
                                '.....',
                                curve: Curves.linear,
                                textStyle: const TextStyle(fontSize: 15),
                                speed: const Duration(milliseconds: 100),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )),
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.003333,
            child:  Divider(
              thickness: 2,
              color: Colors.grey[300],
            )),
        const SizedBox(height: 60,)
      ],
    );
  }
}


class MatchM{
  Person club1;
  Person club2;
  Person league;
  String authorId;
  int score1;
  int score2;
  String location;
  String status;
  String starttime;
  String matchId;
  String createdat;
  String leaguematchId;
  Timestamp timestamp;
  String tittle;
  String match1Id;
  String status1;
  Timestamp? startime;
  Timestamp? stoptime;
  int duration;
  MatchM({
    required this.matchId,
    required this.timestamp,
    required this.score1,
    required this.score2,
    required this.location,
    required this.status,
    required this.starttime,
    required this.createdat,
    required this.tittle,
    required this.leaguematchId,
    required this.match1Id,
    required this.status1,
    required this.authorId,
    required this.club1,
    required this.club2,
    required this.league,
    this.startime,
    this.stoptime,
    this.duration=0,

  });
  factory MatchM.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    String  formattedTime = DateFormat('d MMM').format(convertToTimestamp(json['scheduledDate']).toDate());
    return MatchM(
      league: Person(
          name:json['league']['username'],
          url: json['league']['profileImage'],
          collectionName:'League',
          userId: json['leagueId'],
          timestamp: convertToTimestamp(json['league']['timestamp'])
      ),
      timestamp: convertToTimestamp(json['createdAt']),
      location:json['location'],
      authorId: json['authorId'],
      score1: json['score1'],
      score2: json['score2'],
      club1:Person(
          name: json['club1']['username'],
          url: json['club1']['profileImage'],
          collectionName: json['club1']["collectionName"],
          userId: json['club1Id'],location: json['club1']['location'],timestamp:convertToTimestamp(json['club1']['timestamp'])),
      club2:Person(
          name: json['club2']['username'],
          url: json['club2']['profileImage'],
          collectionName: json['club2']["collectionName"],
          userId: json['club2Id'],location: json['club2']['location'],timestamp: convertToTimestamp(json['club2']['timestamp'])),
      status: json['state1'],
      starttime: json['time'],
      matchId: json['matchId'],
      createdat: formattedTime,
      tittle: json['title'],
      leaguematchId: json['leaguematchId'],
      match1Id: json['match1Id']??"",
      status1: json['state2'],
      startime: convertToTimestamp(json["starttime"]),
      stoptime: convertToTimestamp(json["stoptime"]),
      duration: json["duration"]==0||json['duration']==null?0:json["duration"],
    );
  }
}
class EventM {
  Person user;
  String location;
  String status;
  String starttime;
  String eventId;
  String createdat;
  Timestamp timestamp;
  String title;
  String status1;
  Timestamp? startime;
  Timestamp? stoptime;
  int duration;

  EventM({
    required this.eventId,
    required this.timestamp,
    required this.location,
    required this.status,
    required this.starttime,
    required this.createdat,
    required this.title,
    required this.user,
    required this.status1,
    this.startime,
    this.stoptime,
    this.duration = 0,
  });

  factory EventM.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    Timestamp createdAt= convertToTimestamp(json['createdAt']);
    String formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    return EventM(
      eventId: json['eventId'],
      timestamp: convertToTimestamp(json['createdAt']),
      location: json['location'],
      status: json['state1'],
      starttime: json['time'],
      createdat: formattedTime,
      title: json['title'],
      user: Person(
        name: json['author']['username'],
        url: json['author']['profileImage'],
        collectionName: json['author']["collectionName"],
        userId: json['authorId'],
        location: json['author']['location'],
          timestamp: convertToTimestamp(json['author']['timestamp']),
      ),
      status1: json['state2'],
      startime: convertToTimestamp(json['starttime']),
      stoptime: convertToTimestamp(json['stoptime']),
      duration: json["duration"] == 0 || json['duration'] == null ? 0 : json["duration"],
    );
  }
}


class Posts {
  String location;
  String time;
  String genre;
  String postid;
  List<Map<String, dynamic>> captionUrl;
  Timestamp timestamp;
  String time1;
  Person user;
  bool commenting;
  bool likes;
  Posts({
    required this.postid,
    required this.timestamp,
    required this.location,
    required this.genre,
    required this.captionUrl,
    required this.time,
    required this.time1,
    required this.user,
     this.commenting=true,
     this.likes=true,
  });

  factory Posts.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    Timestamp createdAt=convertToTimestamp(json['createdAt']);
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdAt.toDate());
    String formattedTime = '';
    String hours = DateFormat('HH').format(createdAt.toDate());
    String minutes = DateFormat('mm').format(createdAt.toDate());
    String t = DateFormat('a').format(createdAt.toDate()); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    }
    return Posts(
      postid: json['postId'],
      user: Person(name:json['author']['username'],
        url: json['author']['profileImage'],
        collectionName: json['author']['collectionName'],
        timestamp: convertToTimestamp(json['author']['timestamp']),
        userId: json['authorId'],),
      timestamp: convertToTimestamp(json['createdAt']),
      location: json['location'],
      genre: json['genre'],
      time1:'at $hours:$minutes $t',
      time:formattedTime,
      commenting: json['commenting']??true,
      likes: json['likes']??true,
      captionUrl: List<Map<String, dynamic>>.from(json['captionUrl'].map((x) => {
        'caption': x['caption'],
        'url': x['url'],
        'width':x['width'],
         'height':x['height']
      })),
    );
  }
}
class Data {
  String collection;
  String docId;
  String subcollection;
  String subdocId;
  Map<String, dynamic> data;

  Data({
    required this.collection,
    required this.docId,
    required this.subcollection,
    required this.subdocId,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'collection': collection,
      'docId': docId,
      'subcollection': subcollection,
      'subdocId': subdocId,
      'data': data,
    };
  }
}

class MatchData {
  String date;
  Timestamp starttime;
  Timestamp stoptime;
  Timestamp scheduledDate;
  String matchId;
  int day;
  int totalLikes;
  int duration;
  double totalWatchhours;
  int totalViews;
  int donations;
  double amount;
  MatchData({
    required this.date,
    required this.starttime,
    required this.stoptime,
    required this.scheduledDate,
    required this.matchId,
    required this.day,
    required this.totalLikes,
    required this.duration,
    required this.totalWatchhours,
    required this.totalViews,
    required this.donations,
    required this.amount,
  });

  factory MatchData.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    return MatchData(
      date: json['date'],
      starttime: json['starttime'] != null
          ? convertToTimestamp(json['starttime'])
          : Timestamp.now(),
      stoptime: json['stoptime'] != null
          ? convertToTimestamp(json['stoptime'])
          : Timestamp.now(),
      scheduledDate: json['scheduledDate'] != null
          ? convertToTimestamp(json['scheduledDate'])
          : Timestamp.now(),
      matchId: json['matchId'],
      day: json['day'],
      totalLikes: json['totalLikes'],
      duration: json['duration'],
      totalWatchhours:(json['totalWatchhours'] as num).toDouble(),
      totalViews: json['totalViews'], donations: json['donations'], amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'starttime': starttime,
      'stoptime': stoptime,
      'scheduledDate': scheduledDate,
      'matchId': matchId,
      'day': day,
      'totalLikes': totalLikes,
      'duration': duration,
      'totalWatchhours': totalWatchhours,
      'totalViews': totalViews,
    };
  }
}
class UserData {
 String date;
  int users;
UserData({required this.date, required this.users});
 factory UserData.fromJson(Map<String, dynamic> json) {
   return UserData(
     date: json['date'],
     users: json['users'],
   );
 }
 Map<String, dynamic> toJson() {
   return {
     'date': date,
     'users': users,
   };
 }
}

class SendDatatoFunction {
  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
  String baseUrl = 'https://us-central1-fans-arena.cloudfunctions.net';
  Future<void> addData({required Data data}) async {
    if(connection){
      final String url = '$baseUrl/addData';
      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data.toJson()),
        );
        if (response.statusCode == 200) {
          print('Data added successfully.');
          showToastMessage('Data added successfully.');
        } else {
          print('Failed to add data: ${response.body}');
          showToastMessage('Failed to add data: ${response.body}');
        }
      } catch (e) {
        showToastMessage('Error: $e');
      }
    }
  }
}

class SendComments{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  Future<void> commentPost({required String docId,required String authorId,required String message,required TextEditingController comment,required String collection}) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .collection('comments');
    String commentId = generateUniqueNotificationId();
    if (comment.text.isEmpty) {
      return;
    }
    final Timestamp timestamp = Timestamp.now();
    final like = {
      'commentId': commentId,
      'createdAt': timestamp,
      'comment':comment.text,
      'userId':FirebaseAuth.instance.currentUser!.uid,
    };
    if(isnonet){
      try {
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          final DocumentSnapshot latestDoc = documents.first;
          List<dynamic> likesArray = latestDoc['comments'];
          if (likesArray.length < 1000) {
            likesArray.add(like);
              comment.clear();
            await latestDoc.reference.update({'comments': likesArray});
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: authorId,
                message: message,
                content: docId).sendnotification();
          } else {
              comment.clear();
            await likesCollection.add({'comments': [like]});
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: authorId,
                message: message,
                content: docId).sendnotification();
          }
        } else {
            comment.clear();
          await likesCollection.add({'comments': [like]});
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: authorId,
              message: message,
              content: docId).sendnotification();
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }else {
      final data = {
        'commentId': commentId,
        'comment':comment.text,
        'userId':FirebaseAuth.instance.currentUser!.uid,
      };
      await SendDatatoFunction().addData(data: Data(
          collection:collection,
          docId: docId,
          subcollection: "comments",
          data: data, subdocId: ''));
          await Sendnotification(
              from: FirebaseAuth.instance.currentUser!.uid,
              to: authorId,
              message: message,
              content: docId).sendnotification();
          comment.clear();
        }
  }
}

class SendReplies{

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  Future<void> commentPost({required String docId,required String authorId,required String message,required TextEditingController reply,required String collection,required String commentId}) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(docId)
        .collection('replies');
    String replyId = generateUniqueNotificationId();
    if (reply.text.isEmpty) {
      return;
    }
    final Timestamp timestamp = Timestamp.now();
    final like = {
      'replyId': replyId,
      'commentId': commentId,
      'createdAt': timestamp,
      'reply': reply.text,
      'userId': FirebaseAuth.instance.currentUser!.uid,
    };
    if(isnonet){
      try {
        final QuerySnapshot querySnapshot = await likesCollection.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          final DocumentSnapshot latestDoc = documents.first;
          List<dynamic> likesArray = latestDoc['replies'];
          if (likesArray.length < 1000) {
            likesArray.add(like);
            reply.clear();
            await latestDoc.reference.update({'replies': likesArray});
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: authorId,
                message: message,
                content: docId).sendnotification();
          } else {
            reply.clear();
            await likesCollection.add({'replies': [like]});
            await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
                to: authorId,
                message: message,
                content: docId).sendnotification();
          }
        } else {
          reply.clear();
          await likesCollection.add({'replies': [like]});
          await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
              to: authorId,
              message: message,
              content: docId).sendnotification();
        }
      } catch (e) {
        print('Error sending message: $e');
      }
    }else {
      final data = {
        'replyId': replyId,
        'commentId':commentId,
        'reply': reply.text,
        'userId': FirebaseAuth.instance.currentUser!.uid,
      };
      await SendDatatoFunction().addData(data: Data(collection:collection,docId: docId,subcollection: "replies",data: data, subdocId: ''));
      await Sendnotification(from: FirebaseAuth.instance.currentUser!.uid,
          to: authorId,
          message: message,
          content: docId).sendnotification();
      reply.clear();
    }
  }
}

class FansTv{
  String location;
  String time;
  String caption;
  String genre;
  String url;
  String postid;
  Timestamp timestamp;
  String time1;
  Person user;
  bool commenting;
  bool likes;
  FansTv({
    required this.postid,
    required this.caption,
    required this.location,
    required this.time,
    required this.genre,
    required this.url,
    required this.timestamp,
    required this.time1,
    required this.user,
    this.commenting=true,
    this.likes=true,
  });

  factory FansTv.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    Timestamp createdAt = convertToTimestamp(json['createdAt']);
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdAt.toDate());

    String formattedTime = '';
    String hours = DateFormat('HH').format(createdAt.toDate());
    String minutes = DateFormat('mm').format(createdAt.toDate());
    String t = DateFormat('a').format(createdAt.toDate()); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    }
    return FansTv(
      postid: json['postId'],
      user: Person(name:json['author']['username'],
        url: json['author']['profileImage'],
        collectionName: json['author']['collectionName'],
        userId: json['authorId'],timestamp: convertToTimestamp(json['author']['timestamp'])),
      timestamp: createdAt,
      location: json['location'],
      genre: json['genre'],
      time1:'at $hours:$minutes $t',
      time: formattedTime,
      caption:json['caption'],
      url: json['url'],
      commenting: json['commenting']??true,
      likes: json['likes']??true,
    );
  }

}
class Story {
  Person user;
  List<Map<String, dynamic>> story;
  String time;
  Timestamp timestamp;
  String StoryId;
  Story({
    required this.timestamp,
    required this.story,
    required this.time,
    required this.StoryId,
    required this.user,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }

    Timestamp createdAt = convertToTimestamp(json['createdAt']);
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdAt.toDate());
    String formattedTime = '';
    String hours = DateFormat('HH').format(createdAt.toDate());
    String minutes = DateFormat('mm').format(createdAt.toDate());
    String t = DateFormat('a').format(createdAt.toDate()); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    }
    return Story(
      user: Person(name:json['author']['username'],
        url: json['author']['profileImage'],
        collectionName: json['author']['collectionName'],
        userId: json['authorId'],timestamp: convertToTimestamp(json['author']['timestamp'])),
      StoryId: json['StoryId'],
      timestamp: createdAt,
      time:formattedTime,
      story: List<Map<String, dynamic>>.from(json['story'].map((x) {
        if (x['duration'] == null) {
          return {
            'caption': x['caption'],
            'url': x['url'],
            'url1': x['url1'],
            'timestamp': convertToTimestamp(x['timestamp']),
            'storyId': x['storyId']
          };
        } else {
          return {
            'caption': x['caption'],
            'url': x['url'],
            'url1': x['url1'],
            'timestamp': convertToTimestamp(x['timestamp']),
            'duration': x['duration'],
            'storyId': x['storyId']
          };
        }
      })),
    );
  }
}
class Comment{
  String commentId;
  Person user;
  String comment;
  Timestamp timestamp;
  Comment({
    required this.user,
    required this.comment,
    required this.timestamp,
    required this.commentId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    DateTime now=DateTime.now();
    Timestamp createdAt = convertToTimestamp(json['createdAt']);
    Duration difference = now.difference(createdAt.toDate());
    String formattedTime = '';
    String hours = DateFormat('HH').format(createdAt.toDate());
    String minutes = DateFormat('mm').format(createdAt.toDate());
    String t = DateFormat('a').format(createdAt.toDate()); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    }
    return Comment(
        user: Person(name:json['author']['username'],
          url: json['author']['profileImage'],
          collectionName: json['author']['collectionName'],
          userId: json['userId'],timestamp: convertToTimestamp(json['author']['timestamp'])),
        comment: json['comment'],
        timestamp: createdAt,
        commentId: json['commentId']);
  }
}
class Reply{
  String commentId;
  String replyId;
  Person user;
  String reply;
  Timestamp timestamp;
  Reply({
    required this.user,
    required this.reply,
    required this.timestamp,
    required this.commentId,
    required this.replyId
  });
  factory Reply.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    DateTime now=DateTime.now();
    Timestamp createdAt = convertToTimestamp(json['createdAt']);
    Duration difference = now.difference(createdAt.toDate());
    String formattedTime = '';
    String hours = DateFormat('HH').format(createdAt.toDate());
    String minutes = DateFormat('mm').format(createdAt.toDate());
    String t = DateFormat('a').format(createdAt.toDate()); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    }
    return Reply(
        user: Person(name:json['author']['username'],
          url: json['author']['profileImage'],
          collectionName: json['author']['collectionName'],
          userId: json['userId'],timestamp: convertToTimestamp(json['author']['timestamp'])),
        replyId: json['replyId'],
        reply: json['reply'],
        timestamp: createdAt,
        commentId: json['commentId']);
  }
}
class Universalitem{
  Person item;
  Timestamp timestamp;
  Universalitem({
    required this.item,
    required this.timestamp
  });
  factory Universalitem.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    Timestamp createdAt = convertToTimestamp(json['timestamp']);
    return Universalitem(
        item: Person(name:json['author']['username']??'',
          url: json['author']['profileImage']??'',
          collectionName: json['author']['collectionName']??'',
          userId: json['userId']??'',
          motto: json['author']['motto']??'',
          location: json['author']['location']??'',
          timestamp: convertToTimestamp(json['author']['timestamp']),
        ), timestamp: createdAt);

  }
}

class DataPoints {
  final List<LikeData> likesData;
  final List<ViewData> viewsData;
  final List<DonationData> donationsData;
  DataPoints({required this.likesData,
    required this.viewsData,required this.donationsData});
  factory DataPoints.fromJson(Map<String, dynamic> json) {
    var likesList = json['likesDatapoints'] as List;
    var viewsList = json['viewsDatapoints'] as List;
    var donationsList = json.containsKey('donationsDatapoints')?json['donationsDatapoints'] as List:[];
    List<LikeData> likesDataPoints = likesList.map((i) => LikeData.fromJson(i)).toList();
    List<ViewData> viewsDataPoints = viewsList.map((i) => ViewData.fromJson(i)).toList();
    List<DonationData> donationsDataPoints = donationsList.map((i) => DonationData.fromJson(i)).toList();
    return DataPoints(likesData: likesDataPoints, viewsData: viewsDataPoints, donationsData: donationsDataPoints);
  }
  Map<String, dynamic> toJson() {
    return {
      'likesDatapoints': likesData.map((e) => e.toJson()).toList(),
      'viewsDatapoints': viewsData.map((e) => e.toJson()).toList(),
      'donationsDatapoints': donationsData.map((e) => e.toJson()).toList(),
    };
  }
}

class LikeData{
  final int minute;
  final int likes;
  LikeData({required this.minute, required this.likes});
  factory LikeData.fromJson(Map<String, dynamic> json) {
    return LikeData(
      minute: json['minute'],
      likes: json['likes'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'minute': minute,
      'likes': likes,
    };
  }
}
class DonationData{
  final int minute;
  final double amount;
  DonationData({required this.minute, required this.amount});
  factory DonationData.fromJson(Map<String, dynamic> json) {
    return DonationData(
      minute: json['minute'],
      amount: (json['amount'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'minute': minute,
      'amount': amount,
    };
  }
}

class ViewData {
  final int minute;
  final int views;
  final double watchhours;
  ViewData({required this.minute,
    required this.views, required this.watchhours});
  factory ViewData.fromJson(Map<String, dynamic> json) {
    return ViewData(
      minute: json['minute'],
      views: json['views'],
      watchhours: (json['watchhours'] as num).toDouble(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'minute': minute,
      'views': views,
      'watchhours': watchhours,
    };
  }
}


class LeagueC {
  String leagueId;
  Person author;
  String leaguename;
  String imageurl;
  String location;
  String genre;
  Timestamp timestamp;
  List<String>leagues;
  String accountType;
  LeagueC({
    required this.accountType,
    required this.author,
    required this.leagueId,
    required this.leaguename,
    required this.imageurl,
    required this.genre,
    required this.location,
    required this.timestamp,
    required this.leagues,
  });

  factory LeagueC.fromJson(Map<String, dynamic> json) {
    Timestamp convertToTimestamp(dynamic value) {
      if (value is Map<String, dynamic>) {
        int seconds = value['_seconds'] ?? 0;
        int nanoseconds = value['_nanoseconds'] ?? 0;
        return Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(
          seconds * 1000 + nanoseconds ~/ 1000000,
        ));
      }
      return Timestamp.now();
    }
    DateTime now=DateTime.now();
    Timestamp createdAt = convertToTimestamp(json['createdAt']);
    Duration difference = now.difference(createdAt.toDate());
    String formattedTime = '';
    String hours = DateFormat('HH').format(createdAt.toDate());
    String minutes = DateFormat('mm').format(createdAt.toDate());
    String t = DateFormat('a').format(createdAt.toDate()); // AM/PM
    if (difference.inSeconds == 1) {
      formattedTime = 'now';
    } else if (difference.inSeconds < 60) {
      formattedTime = 'now';
    } else if (difference.inMinutes == 1) {
      formattedTime = '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      formattedTime = '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      formattedTime = '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      formattedTime = '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      formattedTime = '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      formattedTime = '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      formattedTime = '${difference.inDays ~/ 7} weeks ago';
    } else {
      formattedTime = DateFormat('d MMM').format(createdAt.toDate());
    }
    List<String> leagues = (json['leagues'] as List<dynamic>).map((item) => item.toString()).toList();
    return LeagueC(
      leagues: leagues,
      leagueId: json['leagueId'],
      genre: json['genre'],
      imageurl: json['profileimage']??"",
      author: Person(
          name: json['author']['username'],
          url: json['author']['profileImage']??"",
          collectionName: 'Professional',
          userId:json['authorId'],
          timestamp: convertToTimestamp(json['author']['timestamp'])
      ),
      leaguename: json['leaguename']??"",
      location:json['location']??"",
      timestamp: createdAt,
      accountType: json['accountType']??"",
    );
  }
}

class Football {
  Fixture fixture;
  Team home;
  Team away;
  Goal goal;
  LeagueS league;
  ScoreS scoreS;

  Football({required this.fixture,
    required this.away,
    required this.goal,
    required this.scoreS,
    required this.home,
    required this.league});

  factory Football.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Football(
      fixture: Fixture.fromJson(data['match']['fixture'] ?? {}),
      league: LeagueS.fromJson(data['match']['league'] ?? {}),
      away: Team.fromJson(data['match']['teams']['away'] ?? {}),
      goal: Goal.fromJson(data['match']['goals'] ?? {}),
      scoreS: ScoreS.fromJson(data['match']['score'] ?? {}),
      home: Team.fromJson(data['match']['teams']['home'] ?? {}),
    );
  }

}

class Handball {
  String time;
  Teams home;
  Teams away;
  Goal goal;
  Statusb status;

  Handball({required this.away,
    required this.goal,
    required this.home,
    required this.status,
    required this.time});

  factory Handball.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Handball(
        time: data['match']['time']??'',
        status: Statusb.fromJson(data['match']['status']),
        away: Teams.fromJson(data['match']['teams']['away']),
        goal: Goal.fromJson(data['match']['scores']),
        home:Teams.fromJson(data['match']['teams']['home'])
    );
  }

}
class Baseball{
  String time;
  Teams home;
  Teams away;
  BaseballScores baseballScores;
  Statusb status;
  Baseball({
    required this.away,
    required this.baseballScores,
    required this.home,
    required this.status,
    required this.time});
  factory Baseball.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Baseball(
        time: data['match']['time']??'',
        status: Statusb.fromJson(data['match']['status']),
        away: Teams.fromJson(data['match']['teams']['away']),
        baseballScores:BaseballScores.fromJson(data['match']['scores']),
        home:Teams.fromJson(data['match']['teams']['home'])
    );
  }
}
class Basketball{
  Teams home;
  Teams away;
  Scores scores;
  Country country;
  Statusb status;
  League league;
  String time;
  Basketball({required this.status,
    required this.time,
    required this.league,
    required this.home,
    required this.away,
    required this.scores,
    required this.country});

  factory Basketball.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Basketball(
      time: data['match']['time']??"",
      home:Teams.fromJson(data['match']['teams']['home']),
      away:Teams.fromJson(data['match']['teams']['away']),
      scores: Scores.fromJson(data['match']['scores']),
      country:  Country.fromJson(data['match']['country']),
      status: Statusb.fromJson(data['match']['status']),
      league: League.fromJson(data['match']['league']),
    );
  }
}

class Nba{
  int id;
  String league;
  int season;
  Date date;
  int stage;
  Status1 status;
  Periods periods;
  Arena arena;
  Teams1 teams;
  Scores1 scores;
  List<dynamic> officials;
  dynamic timesTied;
  dynamic leadChanges;
  dynamic nugget;
  Nba({    required this.id,
    required this.league,
    required this.season,
    required this.date,
    required this.stage,
    required this.status,
    required this.periods,
    required this.arena,
    required this.teams,
    required this.scores,
    required this.officials,
    required this.timesTied,
    required this.leadChanges,
    required this.nugget,});
  factory Nba.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Nba(
      id: data['match']['id'] ?? 0,
      league: data['match']['league'] ?? '',
      season: data['match']['season'] ?? 0,
      date: Date.fromJson(data['match']['date'] ?? {}),
      stage: data['match']['stage'] ?? 0,
      status: Status1.fromJson(data['match']['status'] ?? {}),
      periods: Periods.fromJson(data['match']['periods'] ?? {}),
      arena: Arena.fromJson(data['match']['arena'] ?? {}),
      teams: Teams1.fromJson(data['match']['teams'] ?? {}),
      scores: Scores1.fromJson(data['match']['scores'] ?? {}),
      officials: data['match']['officials'] ?? [],
      timesTied: data['match']['timesTied'],
      leadChanges: data['match']['leadChanges'],
      nugget: data['match']['nugget'],
    );
  }
}
class Volleyball{
  String time;
  Teamsrby home;
  Teamsrby away;
  GameScoresrby scores;
  Countryvol country;
  Statusb status;
  Volleyball({ required this.home,
    required this.time,
    required this.status,
    required this.away,
    required this.scores,
    required this.country});
  factory Volleyball.fromFirestore(Map<String,dynamic>data){
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Volleyball(
        time: data['match']['time']??'',
        status: Statusb.fromJson(data['match']['status']),
        home:Teamsrby.fromJson(data['match']['teams']['home']),
        away:Teamsrby.fromJson(data['match']['teams']['away']),
        scores: GameScoresrby.fromJson(data['match']['scores']),
        country: Countryvol.fromJson(data['match']['country']));
  }
}

class Nfl{
  Game game;
  Teams home;
  Teams away;
  Scoresnfl scores;
  Leaguenfl leagues;
  Nfl({required this.away,
    required this.scores,
    required this.home,
    required this.game,
    required this.leagues});
  factory Nfl.fromFirestore(Map<String,dynamic> data){
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Nfl(
        leagues: Leaguenfl.fromJson(data['match']['league']),
        game: Game.fromJson(data['match']['game']),
        away: Teams.fromJson(data['match']['teams']['away']),
        scores: Scoresnfl.fromJson(data['match']['scores']),
        home:Teams.fromJson(data['match']['teams']['home'])
    );
  }
}

class Rugby{
  Teamsrby home;
  Teamsrby away;
  GameScoresrby scores;
  Statusb status;
  String time;
  Rugby({required this.home,
    required this.time,
    required this.away,
    required this.scores,
    required this.status});
  factory Rugby.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Rugby(
      time: data['match']['time']??"",
      status: Statusb.fromJson(data['match']['status']),
      home:Teamsrby.fromJson(data['match']['teams']['home']),
      away:Teamsrby.fromJson(data['match']['teams']['away']),
      scores: GameScoresrby.fromJson(data['match']['scores']),
    );
  }
}
class Formula1{
  int id;
  Competition competition;
  Circuit circuit;
  int season;
  String type;
  Laps laps;
  FastestLap fastestLap;
  String distance;
  String timezone;
  String date;
  dynamic weather;
  String status;
  Formula1({
    required this.id,
    required this.competition,
    required this.circuit,
    required this.season,
    required this.type,
    required this.laps,
    required this.fastestLap,
    required this.distance,
    required this.timezone,
    required this.date,
    required this.weather,
    required this.status,
  });
  factory Formula1.fromFirestore(Map<String, dynamic> data) {
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Formula1(
      id: data['match']['id'] ?? 0,
      competition: Competition.fromJson(data['match']['competition'] ?? {}),
      circuit: Circuit.fromJson(data['match']['circuit'] ?? {}),
      season: data['match']['season'] ?? 0,
      type: data['match']['type'] ?? '',
      laps: Laps.fromJson(data['match']['laps'] ?? {}),
      fastestLap: FastestLap.fromJson(data['match']['fastest_lap'] ?? {}),
      distance: data['match']['distance'] ?? '',
      timezone: data['match']['timezone'] ?? '',
      date: data['match']['date'] ?? '',
      weather: data['match']['weather'],
      status: data['match']['status'] ?? '',
    );
  }
}
class Hockey{
  String time;
  Teamsrby home;
  Teamsrby away;
  GameScoresrby scores;
  Countryvol country;
  Statusb status;
  Hockey({required this.home,
    required this.time,
    required this.status,
    required this.away,
    required this.scores,
    required this.country});
  factory Hockey.fromFirestore(Map<String,dynamic>data){
    if (data == null) {
      throw Exception('Document data is null');
    }
    return Hockey(
        time: data['match']['time']??'',
        status: Statusb.fromJson(data['match']['status']),
        home:Teamsrby.fromJson(data['match']['teams']['home']),
        away:Teamsrby.fromJson(data['match']['teams']['away']),
        scores: GameScoresrby.fromJson(data['match']['scores']),
        country: Countryvol.fromJson(data['match']['country'])
    );
  }
}


class News{
  String articleId;
  String title;
  String link;
  List<String>? keywords;
  List<String> creator;
  String videoUrl;
  String description;
  String content;
  String pubDate;
  String imageUrl;
  String sourceId;
  int sourcePriority;
  List<String> country;
  List<String> category;
  String language;
  News({    required this.articleId,
    required this.title,
    required this.link,
    this.keywords,
    required this.creator,
    required this.videoUrl,
    required this.description,
    required this.content,
    required this.pubDate,
    required this.imageUrl,
    required this.sourceId,
    required this.sourcePriority,
    required this.country,
    required this.category,
    required this.language,});
  factory News.fromFirestore(Map<String,dynamic>data){
    if (data == null) {
      throw Exception('Document data is null');
    }
    return News(
      articleId: data['article']['article_id'] ?? '',
      title: data['article']['title'] ?? '',
      link: data['article']['link'] ?? '',
      keywords: List<String>.from(data['article']['keywords'] ?? []),
      creator: List<String>.from(data['article']['creator'] ?? []),
      videoUrl: data['article']['video_url'] ?? '',
      description: data['article']['description'] ?? '',
      content: data['article']['content'] ?? '',
      pubDate: data['article']['pubDate'] ?? '',
      imageUrl: data['article']['image_url'] ?? '',
      sourceId: data['article']['source_id'] ?? '',
      sourcePriority: data['article']['source_priority'] ?? 0,
      country: List<String>.from(data['article']['country'] ?? []),
      category: List<String>.from(data['article']['category'] ?? []),
      language: data['article']['language'] ?? '',
    );
  }
}
class DataFetcher {
  String baseUrl="https://us-central1-fans-arena.cloudfunctions.net";

  Future<DataPoints> matchData(String collection,String docId) async {
    final response = await http.get(Uri.parse('$baseUrl/matchData?docId=$docId&collection=$collection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final leagueData = jsonResponse['dataPoints'];
      if (leagueData != null) {
        return DataPoints.fromJson(leagueData);
      } else {
        throw Exception('No data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<DataPoints> postData(String collection,String docId) async {
    final response = await http.get(Uri.parse('$baseUrl/postData?docId=$docId&collection=$collection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final leagueData = jsonResponse['dataPoints'];
      if (leagueData != null) {
        return DataPoints.fromJson(leagueData);
      } else {
        throw Exception('No data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }
  //getsuggesteddata
  Future<List<MatchData>> allMatchData(String userId,String collection) async {
    final response = await http.get(Uri.parse('$baseUrl/allMatchData?docId=$userId&collection=$collection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> matchData = jsonResponse['matchDataPoints'];
      return matchData.map((postData) => MatchData.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matchData');
    }
  }
  Future<List<Person>> getsuggesteddata(String userId,) async {
    final response = await http.get(Uri.parse('$baseUrl/getsuggesteddata?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> matchData = jsonResponse['users'];
      return matchData.map((postData) => Person.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load userData');
    }
  }
  Future<List<UserData>> userData(String userId,String collection,String subcollection,String from,String to) async {
    final response = await http.get(Uri.parse('$baseUrl/userData?docId=$userId&collection=$collection&subcollection=$subcollection&from=$from&to=$to'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> matchData = jsonResponse['followersDatapoints'];
      return matchData.map((postData) => UserData.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load userData');
    }
  }
  Future<List<Posts>> getPostsForFollowedUsers(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getPostsForFollowedUsers?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['posts'];
      return postsData.map((postData) => Posts.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }


  Future<List<Posts>> getPostsInteractedwith(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getpostsinteractedwith?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['posts'];
      return postsData.map((postData) => Posts.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }
  Future<List<Posts>> getmorePostsForFollowedUsers(String userId,String docId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmorePostsForFollowedUsers?uid=$userId&lastdocId=$docId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['posts'];
      return postsData.map((postData) => Posts.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Story>> getStoryForFollowedUsers(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getStoryForFollowedUsers?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['story'];
      return postsData.map((postData) => Story.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load story');
    }
  }

  Future<List<FansTv>> getmoreFansTv(String userId,String docId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmoreFansTv?uid=$userId&lastdocId=$docId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['posts'];
      return postsData.map((postData) => FansTv.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<FansTv>> getFansTv(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getFansTv?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['posts'];
      return postsData.map((postData) => FansTv.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<FansTv>> getFansTvinteractedwith(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getFansTvinteractedwith?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['posts'];
      return postsData.map((postData) => FansTv.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<List<Story>> getmoreStoryForFollowedUsers(String userId,String docId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmoreStoryForFollowedUsers?uid=$userId&lastdocId=$docId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['story'];
      return postsData.map((postData) => Story.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load story');
    }
  }

  Future<List<LeagueC>> getLeaguesForUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getLeaguesForUser?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['leagues'];
      return postsData.map((postData) => LeagueC.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load leagues');
    }
  }

  Future<LeagueC> getLeague(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getLeague?leagueId=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final leagueData = jsonResponse['league'];
      if (leagueData != null) {
        return LeagueC.fromJson(leagueData);
      } else {
        throw Exception('No league found for the user');
      }
    } else {
      throw Exception('Failed to load league');
    }
  }

  Future<LeagueC> getmyLeague(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmyLeague?authorId=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final leagueData = jsonResponse['league'];
      if (leagueData != null) {
        return LeagueC.fromJson(leagueData);
      } else {
        throw Exception('No league found for the user');
      }
    } else {
      throw Exception('Failed to load league');
    }
  }

  Future<MatchM> getMatch(String matchId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmatch?docId=$matchId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final leagueData = jsonResponse['matches'];
      if (leagueData != null) {
        return MatchM.fromJson(leagueData);
      } else {
        throw Exception('No match found for the user');
      }
    } else {
      throw Exception('Failed to load match');
    }
  }

  Future<EventM> getEvent(String matchId) async {
    final response = await http.get(Uri.parse('$baseUrl/getevent?docId=$matchId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final leagueData = jsonResponse['events'];
      if (leagueData != null) {
        return EventM.fromJson(leagueData);
      } else {
        throw Exception('No event found for the user');
      }
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<List<MatchM>> getTmatches(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getTodaysmatches?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getTevents(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getTodaysevents?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getweeksmatches(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getweeksmatches?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getweeksevents(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getweeksevents?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getweeksmatches1(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getweeksmatches1?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getweeksevents1(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getweeksevents1?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getUmatches(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getUpcomingmatches?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getUevents(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getUpcomingevents?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getPmatches(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getPastmatches?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getPevents(String userId) async {
    DateTime today=DateTime.now();
    String t="${today.year}-${today.month}-${today.day}";
    final response = await http.get(Uri.parse('$baseUrl/getPastevents?uid=$userId&date=$t'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getmatcheswatched(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmatcheswatched?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> geteventswatched(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/geteventswatched?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getmymatches(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmymatches?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getmyevents(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmyevents?uid=$userId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getmoremymatches(String userId,String lastdocId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmoremymatches?uid=$userId&lastdocId=$lastdocId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getmoremyevents(String userId,String lastdocId) async {
    final response = await http.get(Uri.parse('$baseUrl/getmoremyevents?uid=$userId&lastdocId=$lastdocId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<MatchM>> getfiltermatches(String userId,DateTime from, DateTime to) async {
    String to1="${to.year}-${to.month}-${to.day}";
    String from1="${from.year}-${from.month}-${from.day}";
    final response = await http.get(Uri.parse('$baseUrl/getfiltermatches?uid=$userId&from=$from1&to=$to1'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['matches'];
      return postsData.map((postData) => MatchM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<EventM>> getfilterevents(String userId,DateTime from, DateTime to) async {
    String to1="${to.year}-${to.month}-${to.day}";
    String from1="${from.year}-${from.month}-${from.day}";
    final response = await http.get(Uri.parse('$baseUrl/getfilterevents?uid=$userId&from=$from1&to=$to1'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['events'];
      return postsData.map((postData) => EventM.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<Universalitem>> getanydata({required String docId,required String collection,required String subcollection}) async {
    final response = await http.get(Uri.parse('$baseUrl/getanydata?docId=$docId&collection=$collection&subcollection=$subcollection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['data'];
      return postsData.map((postData) => Universalitem.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<Universalitem>> getlikesdata({required String docId,required String collection,required String subcollection}) async {
    final response = await http.get(Uri.parse('$baseUrl/getlikesdata?docId=$docId&collection=$collection&subcollection=$subcollection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['likes'];
      return postsData.map((postData) => Universalitem.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load likes');
    }
  }

  Future<List<Comment>> getcommentdata({required String docId,required String collection,required String subcollection}) async {
    final response = await http.get(Uri.parse('$baseUrl/getcommentsdata?docId=$docId&collection=$collection&subcollection=$subcollection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['comments'];
      return postsData.map((postData) => Comment.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<Comment>> getLeaguecommentdata({required String docId,required String year}) async {
    final response = await http.get(Uri.parse('$baseUrl/getLeagueComments?docId=$docId&year=$year'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['comments'];
      return postsData.map((postData) => Comment.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<Reply>> getreplydata({required String docId,required String collection,required String subcollection,required String commentId}) async {
    final response = await http.get(Uri.parse('$baseUrl/getreplydata?docId=$docId&collection=$collection&subcollection=$subcollection&commentId=$commentId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['replies'];
      return postsData.map((postData) => Reply.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }

  Future<List<Reply>> getLeaguereplydata({required String docId,required String year, required String commentId}) async {
    final response = await http.get(Uri.parse('$baseUrl/getLeagueCommentsreplies?docId=$docId&year=$year&commentId=$commentId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['replies'];
      return postsData.map((postData) => Reply.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }


  Future<List<Football>> fetchfootball() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Football').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Football.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Nba>> fetchnba() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Nba').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Nba.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Basketball>> fetchbasketball() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Basketball').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Basketball.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Baseball>> fetchbaseball() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('BaseBall').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Baseball.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Rugby>> fetchrugby() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Rugby').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Rugby.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Nfl>> fetchnfl() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('American-football').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Nfl.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Volleyball>> fetchvolleyball() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Volleyball').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Volleyball.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Handball>> fetchhandball() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Handball').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Handball.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Hockey>> fetchhockey() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Hockey').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Hockey.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<Formula1>> fetchF1() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('Formula-1').orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['matches']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => Formula1.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<News>> fetchNews({required String genre}) async {
    String collectionName="${genre}-news";
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(collectionName).orderBy('createdAt',descending: true).limit(1).get();
    List<Map<String,dynamic>> data=[];
    List<QueryDocumentSnapshot> docs=querySnapshot.docs;
    for(final doc in docs ){
      List<Map<String,dynamic>> data1=List.from(doc['news']);
      data.addAll(data1);
    }
    if (data.isNotEmpty) {
      return data.map((d) => News.fromFirestore(d)).toList();
    } else {
      throw Exception('No matches found.');
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String collection = prefs.getString('cname')!;
    if (collection.isEmpty) {
      collection = await Newsfeedservice().getAccount(userId!);
    }
    String subcollection="notifications";
    String collectionName="${collection}s";
    final response = await http.get(Uri.parse('$baseUrl/getanydata?docId=$userId&collection=$collectionName&subcollection=$subcollection'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> postsData = jsonResponse['data'];
      return postsData.map((postData) => NotificationModel.fromJson(postData)).toList();
    } else {
      throw Exception('Failed to load matches');
    }
  }
}



class DisplayPosts extends StatefulWidget {
  const DisplayPosts({super.key});

  @override
  State<DisplayPosts> createState() => _DisplayPostsState();
}

class _DisplayPostsState extends State<DisplayPosts> {
  ScrollController scrollController=ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('posts trial'),
        ),
        body: FutureBuilder<List<Posts>>(
          future: DataFetcher().getmorePostsForFollowedUsers(FirebaseAuth.instance.currentUser!.uid,"6wvzycB7J75oUVYsPPCV"),
          builder: (BuildContext context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('no posts')); // Handle case where there are no likes
            } else {
              final List<Posts> posts = snapshot.data!;
              return ListView.builder(
                  itemCount: posts.length,
                  controller: scrollController,
                  itemBuilder: (context, index){
                    Posts post=posts[index];
                    return PostLayout(post: post);
                  });
            }
          },
        )

    );
  }
}
