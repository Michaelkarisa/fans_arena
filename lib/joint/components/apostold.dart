import 'dart:async';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/components/likebutton.dart';
import 'package:fans_arena/joint/data/screens/widgets/readmore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/accountfanviewer.dart';
import '../../fans/screens/newsfeed.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../data/screens/feed_item.dart';

class Apostold extends StatefulWidget {
  Person user;
  Posts post;
  List<Posts> posts;
  Apostold({super.key, required this.user,required this.post,required this.posts});

  @override
  State<Apostold> createState() => _ApostoldState();
}
class _ApostoldState extends State<Apostold> with AutomaticKeepAliveClientMixin{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Newsfeedservice news=Newsfeedservice();
  ScrollController controller = ScrollController();
 late PostModel lastPost;
 int index=0;
 Set<String>postIds={};
  @override
  void initState() {
    super.initState();
    news = Newsfeedservice();
    getPosts();
    index = widget.posts.indexOf(widget.post);
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;
      final lastPosition = positions.isNotEmpty ? positions.last.index : -1;
      if (lastPosition == widget.posts.length - 1) {
        loadMore1();
      }
    });
  }

  Future<void> getPosts()async{
    setState(() {
      isloading=true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController.jumpTo(index: index, alignment: 0.05);
    });
    setState((){
      isloading=false;
      if (widget.posts.isNotEmpty) {
        final p=widget.posts.last;
        lastPost =PostModel(postid: p.postid,
            location: p.location,
            time: p.time,
            genre: p.genre,
            captionUrl: p.captionUrl,
            timestamp: p.timestamp,
            time1: p.time1,
            user: p.user);
        for(final p in widget.posts){
          postIds.add(p.postid);
        }
      }
    });
  }
 bool isloading=false;
  bool nomoreposts=false;
  Future<void> loadMore1()async{
    setState(() {
      isloading=true;
    });
    List<PostModel> morePosts = await news.getMyfeed1(startpost: lastPost,userId: widget.user.userId);
    setState(() {
      isloading=false;
      if (morePosts.isNotEmpty) {
        lastPost =morePosts.last;
        for(final d in morePosts) {
          if(!postIds.contains(d.postid)) {
            postIds.add(d.postid);
            widget.posts.add(Posts(
                postid: d.postid,
                timestamp: d.timestamp,
                location: d.location,
                genre: d.genre,
                captionUrl: d.captionUrl,
                time: d.time,
                time1: d.time1,
                user: widget.user));
          }else{
            morePosts.remove(d);
          }
        }
      }else if(morePosts.isEmpty){
        nomoreposts=true;
      }});
  }
  final itemkey=GlobalKey();
  final itemkey1=GlobalKey();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ScrollOffsetController scrollOffsetController =
  ScrollOffsetController();
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();
  late List<double> itemHeights;
  late List<Color> itemColors;
  bool reversed = false;
  double alignment = 0;
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return
      Scaffold(
        appBar: AppBar(
          title: const Text("Posts",style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        resizeToAvoidBottomInset: false,

        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ScrollablePositionedList.builder(
                  scrollDirection: Axis.vertical,
                  physics: const ScrollPhysics(),
                itemScrollController: itemScrollController,
                itemPositionsListener: itemPositionsListener,
                scrollOffsetController: scrollOffsetController,
                  itemCount: widget.posts.length+1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index==widget.posts.length) {
                      if(isloading){
                        return const PostLShimer();
                      }else if(nomoreposts){
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: SizedBox(
                            height: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                const Text('No more posts',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                SizedBox(
                                    height: MediaQuery
                                        .of(context)
                                        .size
                                        .height * 0.003333,
                                    child:  Divider(
                                      thickness: 2,
                                      color: Colors.grey[300],
                                    )),
                              ],
                            ),
                          ),
                        );
                      }else {
                        return const SizedBox.shrink();
                      }
                    }else{
                      return PostLayout1(post: widget.posts[index]);
                    }},
              ),
        ),
      );
  }
}


class PostLayout1 extends StatefulWidget {
  Posts post;
  PostLayout1({super.key, required this.post});

  @override
  State<PostLayout1> createState() => _PostLayout1State();
}

class _PostLayout1State extends State<PostLayout1> {
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();
  bool isNotExpanded = false;
  int maxTextLength = 100;
  String location = '';
  int ind = 0;
  double radius = 23;
  late Future<Size> data;
  @override
  void initState() {
    super.initState();
    getaspect();
    _pageController1.addListener(_onPageChanged);
    setState(() {
      location = _truncateText(widget.post.location);
    });
  }
  void getaspect()async{
    final imagesize=await _getImageDimensions(widget.post.captionUrl[ind]['url']);
    setState(() {
      aspectRatio=imagesize.width / imagesize.height;
    });
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

  void _onPageChanged()async{
    getaspect();
    if (_pageController1.page != _pageController2.page) {
      _pageController2.jumpToPage(_pageController1.page!.toInt());
    }
  }

  @override
  void dispose() {
    _pageController1.removeListener(_onPageChanged);
    _pageController1.dispose();
    _pageController2.dispose();
    super.dispose();
  }
  double aspectRatio=1.0;
  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.003333,
            child: Divider(
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
                CustomAvatar( radius: radius, imageurl:widget.post.user.url),
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
                            InkWell(
                              onTap: () {
                                Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (context){
                                        if(widget.post.user.collectionName=='Club'){
                                          return AccountclubViewer(user: widget.post.user, index: 0);
                                        }else if(widget.post.user.collectionName=='Professional'){
                                          return AccountprofilePviewer(user: widget.post.user, index: 0);
                                        }else{
                                          return Accountfanviewer(user: widget.post.user, index: 0);
                                        }
                                      }
                                  ),
                                );
                              },
                              child: UsernameDO(username: widget.post.user.name,
                                width: 160,maxSize: 140,
                                collectionName: widget.post.user.collectionName,
                                height: 38,),
                            ),

                            SizedBox(
                                width:20,
                                height:  32,
                                child: InkWell(
                                  onTap: (){
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      isDismissible: true,
                                      backgroundColor: Colors.transparent,
                                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return widget.post.user.userId==FirebaseAuth.instance.currentUser!.uid?Optionposts(post: widget.post, collection: 'posts',):OptionPosts1(postId: widget.post.postid, collection: 'posts', authorId: widget.post.user.userId, url: widget.post.captionUrl[ind]['url'],);
                                      },
                                    );
                                  },
                                  child: const Icon(Icons.more_vert),)
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
                            Text(location,
                              style: const TextStyle(
                                fontSize: 14,),),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(widget.post.time,
                                  style: const TextStyle(
                                    fontSize: 13,),),
                                const SizedBox(width: 5,),
                                Text(widget.post.time1,
                                  style: const TextStyle(
                                    fontSize: 13,),),
                              ],
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
                .height * 0.00333,
            child:  Divider(
              thickness: 2,
              color: Colors.grey[300],
            )),

        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.post.captionUrl.length,
                  controller: _pageController1,
                  itemBuilder: (context, index) {
                    final captionUrl = widget.post.captionUrl[index];
                    return CachedNetworkImage(
                      imageUrl: captionUrl['url']!,
                      fit: BoxFit.cover,
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
                  onPageChanged: (int index){
                    //final imagesize=await _getImageDimensions(widget.post.captionUrl[index]['url']);
                    setState(() {
                    //  aspectRatio=imagesize.width / imagesize.height;
                      ind = index;
                    });
                  },
                ),
                if (widget.post.captionUrl.length > 1)
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
                                '${ind + 1}/${widget.post.captionUrl.length}',
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

        LikeArea(post: widget.post,),
                Padding(
            padding: const EdgeInsets.only(left: 5),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: SizedBox(
                  height: 25,
                  child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.post.captionUrl.length,
                      controller: _pageController2,
                      itemBuilder: (context, index) {
                        final captionUrl = widget.post.captionUrl[index];
                        return Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child:  widget.post.captionUrl.isNotEmpty?
                            ReadMoreWidget(
                              text: captionUrl['caption'],
                              hashtags: const ['#wandethe',
                                '#karisa', '#twende', '#Fans Arena',
                              ],
                              trimLines: 7,
                              delimiter: '...',
                              hashtagTextStyle: const TextStyle(color: Colors.blue),
                              delimiterStyle: const TextStyle(color: Colors.black),
                              postDataTextStyle: const TextStyle(
                                  color: Colors.black, fontSize: 15),
                              colorClickableText: Colors.blueGrey,
                              trimMode: TrimMode.Line,

                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                              moreStyle: const TextStyle(fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ):const SizedBox(height: 0,)
                        );}),
                ),
              ),
            )),
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.01111,
            child: Divider(
              thickness: 2,
              color: Colors.grey[300],
            )),
      ],
    );
  }
  Future<Size> _getImageDimensions(String imageUrl) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.network(imageUrl);

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );

    return completer.future;
  }
}

