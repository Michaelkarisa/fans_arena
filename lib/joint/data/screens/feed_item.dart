import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fans_arena/fans/bloc/accountchecker11.dart';
import 'package:fans_arena/fans/bloc/accountchecker14.dart';
import 'package:fans_arena/fans/components/likebuttonfanstv.dart';
import 'package:fans_arena/fans/screens/commentsdatafanstv.dart';
import 'package:fans_arena/joint/data/screens/comments.dart';
import 'package:fans_arena/main.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import '../../../../reusablewidgets/cirularavatar.dart';
import '../../../appid.dart';
import '../../../clubs/screens/accountclubviewer.dart';
import '../../../fans/data/videocontroller.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../fans/screens/accountfanviewer.dart';
import '../../../professionals/screens/accountprofilepviewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_gallery_saver2/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver2/image_gallery_saver.dart';
import 'package:dio/dio.dart';
class FeedItem extends StatefulWidget {
  final FansTv ftv;
  final List<FansTv> posts;
  final bool opt1;
  final int index;
  final Function() completed;
  const FeedItem({super.key,
    required this.ftv,
    required this.opt1,
    required this.completed,
    required this.index,
    required this.posts,
  });

  @override
  State<FeedItem> createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> with SingleTickerProviderStateMixin {

 final VideoControllerProvider _controller=VideoControllerProvider();
  bool _isPlaying = false;
ViewsProvider v=ViewsProvider();
late DateTime _startTime;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    initializePlayer(widget.ftv.url);
    v.getViews("FansTv", widget.ftv.postid);
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
      });}else {
        String url1 = widget.posts[widget.index+1].url;
        final fileInfo1 = await checkCacheFor(url1);
        if(fileInfo1==null){
        cachedForUrl(url1);
        }
        if(widget.index!=0) {
          String url2 = widget.posts[widget.index - 1].url;
          final fileInfo2 = await checkCacheFor(url2);
          if(fileInfo2==null){
            cachedForUrl(url2);
          }
        }
      final file = fileInfo.file;
      _controller.controller = VideoPlayerController.file(file);
      _controller.controller.initialize().then((value) {
        setState(() {
          _controller.controller.setLooping(true);
          _controller.controller.play();
          _controller.controller.setVolume(100.0);
        changed = true;
        _isPlaying = true;
        isLoading = false;
        });
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

 void cachedForUrl(String url) async {
    String url1=widget.posts[widget.index+1].url;
   await DefaultCacheManager().getSingleFile(url).then((value) {
     if(url1!=url){
      DefaultCacheManager().getSingleFile(url1).then((value) {
     });}
   });
 }
 void deleteCache()async{
   if(widget.index>5){
 String url =widget.posts[widget.index-6].url;
   await DefaultCacheManager().removeFile(url).then((value){

   });}
 }
bool isLoading =true;

  @override
void dispose() {
    if(!isnonet) {
      v.addView("FansTv", widget.ftv.postid, isnonet, _startTime);
      v.updateWatchhours("FansTv", widget.ftv.postid, isnonet, _startTime);
      Engagement().engagement('Fans_Tv', _startTime, widget.ftv.postid);
    }
    _controller.controller.pause();
    _controller.dispose();
    _controller.controller.dispose();
    deleteCache();
  super.dispose();
}
bool changed =false;

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
 double radius=23;
 String cname(){
   if(widget.ftv.user.collectionName=="Professional"){
     return 'P';
   }else if(widget.ftv.user.collectionName=="Club"){
     return 'C';
   }else {
     return '';
   }
 }
 List<String>hashes=["mine","Fans Arena","Sports","Ganze","Football","Basketball","NBAkenya","FiFA","UEFA","FKF","VolleyballKenya"];

 @override
  Widget build(BuildContext context) {
    String c=cname();
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
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
                        alignment:  Alignment.center,
                        child: IconButton(
                          icon: Icon(_isPlaying ?Icons.pause:Icons.play_arrow, size: 50,color: Colors.white,),
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
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: MediaQuery.of(context).size.height*0.35,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomAvatar( radius: radius, imageurl:widget.ftv.user.url),
                        const SizedBox(width: 6),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.6,
                          child: Padding(
                            padding: const EdgeInsets
                                .only(left: 5),
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 10.0,
                                maxWidth: 320.0,
                              ),
                              color: Colors.transparent,
                              height: 38.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        if(_isPlaying){
                                          _onPlayButtonPressed();
                                        }
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context){
                                                if(widget.ftv.user.collectionName=='Club'){
                                                  return AccountclubViewer(user: widget.ftv.user, index: 0);
                                                }else if(widget.ftv.user.collectionName=='Professional'){
                                                  return AccountprofilePviewer(user: widget.ftv.user, index: 0);
                                                }else{
                                                  return Accountfanviewer(user: widget.ftv.user, index: 0);
                                                }
                                              }
                                          ),
                                        );
                                      },
                                      child: CustomName(
                                        username: widget.ftv.user.name,
                                        maxsize:140,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                  ),
                                  c.isNotEmpty?Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Align(
                                      alignment: AlignmentDirectional.centerStart,
                                      child:  Container(
                                        width:20 ,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child:  Center(child: Text(c,style: const TextStyle(color: Colors.white),)),),
                                    ),
                                  ):const SizedBox.shrink(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Accountchecker11(user:widget.ftv.user,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Readmore(
                      text: widget.ftv.caption,
                      color: Colors.white,
                      hashes: hashes,
                    ),
                    AnimatedBuilder(
                        animation: v,
                        builder: (BuildContext context, Widget? child) {
                          return
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5,vertical: 2),
                              child: ViewsCount(totalLikes: v.views.length,),
                            );}),
                    Padding(
                        padding: const EdgeInsets.only(top: 20,left: 60),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.white70,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10),topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(
                                    width: 30,
                                    child: Icon(Icons.location_on_outlined,color: Colors.white,)),
                                FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 10.0,
                                        maxWidth: 160.0,
                                      ),
                                      color: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 10,left: 2),
                                        child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          widget.ftv.location,style: const TextStyle(color: Colors.white,fontSize: 15),),
                                      ),
                                    ))
                              ],
                            ),
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 2 ,bottom: 8),
            child: SizedBox(
              width: MediaQuery.of(context).size.width*0.12,
              height: MediaQuery.of(context).size.height*0.36,
              child: Column(
                mainAxisAlignment:MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LikeButton1(post: widget.ftv, authorId:widget.ftv.user.userId,),
                  const SizedBox(height: 20),
                  SizedBox(height:55,
                    child: InkWell(
                        onTap: (){
                          if(_isPlaying){
                            _onPlayButtonPressed();
                          }
                          showModalBottomSheet(
                            isScrollControlled: true,
                            isDismissible: false,
                            backgroundColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                            context: context,
                            builder: (BuildContext context) {
                              return BottomSheetWidget(post: widget.ftv,play:_onPlayButtonPressed, isplaying: _isPlaying,);
                            },
                          );
                        },
                        child: Column(
                          children: [
                            const Icon(Icons.mode_comment_outlined,color: Colors.white,size: 30,),
                            const SizedBox(height: 4,),
                            CommentsdatafansTv(postId: widget.ftv.postid,)
                          ],
                        )),
                  ),
                  const SizedBox(height: 10),
                  Accountchecker14(user: widget.ftv.user,),
                  SizedBox(
                    height: 35,
                    child: IconButton(onPressed: (){
                      showModalBottomSheet(
                        isScrollControlled: true,
                        isDismissible: true,
                        backgroundColor: Colors.transparent,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                        context: context,
                        builder: (BuildContext context) {
                          return widget.ftv.user.userId!=FirebaseAuth.instance.currentUser!.uid?OptionPosts1(postId: widget.ftv.postid, collection: 'FansTv', authorId: widget.ftv.user.userId, url: widget.ftv.url,):Optionposts(ftv:widget.ftv, collection: 'FansTv',);
                        },
                      );
                    },icon: const Icon(Icons.more_vert_outlined,color: Colors.white,size: 30,),),
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class Optionposts extends StatefulWidget {
  Posts? post;
  FansTv? ftv;
  String collection;
  Optionposts({super.key,this.post,this.ftv,required this.collection});

  @override
  State<Optionposts> createState() => _OptionpostsState();
}

class _OptionpostsState extends State<Optionposts> {
bool commenting =false;
bool likes=false;

@override
void initState(){
  super.initState();
  setState(() {
    if(widget.collection=="posts"){
      likes=widget.post!.likes;
    }else{
     likes=widget.ftv!.likes;
    }
    if(widget.collection=="posts"){
    commenting= widget.post!.commenting;
    }else{
    commenting=widget.ftv!.commenting;
    }
  });

}
  void deletePost(){
    FirebaseFirestore.instance
        .collection('FansTv')
        .where('postId', isEqualTo:widget.ftv?.postid )
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }

  void deletePost1()async{
    for(final item in widget.post!.captionUrl){
      await deleteStorageItemByUrl(item['url']);
    }
    FirebaseFirestore.instance
        .collection('posts')
        .where('postId', isEqualTo:widget.post?.postid )
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
  }
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
  Future<void> addpost(String postId) async {
    showToastMessage('Saving ${widget.collection}..');
    final DocumentReference fanDocRef = FirebaseFirestore.instance.collection('${collectionNamefor}s').doc(FirebaseAuth.instance.currentUser!.uid);
    final Timestamp createdAt = Timestamp.now();
    final like = {
      'postId': postId,
      'timestamp': createdAt,
    };
    Future<void> updateOrAddDocument(DocumentReference docRef) async {
      final DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        final QuerySnapshot locationQuery = await docRef.collection('saved${widget.collection}').get();
        if (locationQuery.docs.isNotEmpty) {
          final DocumentSnapshot locationDoc = locationQuery.docs.first;
          List<dynamic> likesArray = locationDoc[widget.collection] ?? [];
          if (likesArray.length < 12000) {
            likesArray.add(like);
            await locationDoc.reference.update({widget.collection: likesArray});
          } else {
            await docRef.collection('saved${widget.collection}').add({widget.collection: [like]});
          }
        } else {
          await docRef.collection('saved${widget.collection}').add({widget.collection: [like]});
        }
      }else{

      }
    }
    await updateOrAddDocument(fanDocRef);
    showToastMessage('Post saved..');
  }


  Future<void> deleteStorageItemByUrl(String url) async {
    Uri uri = Uri.parse(url);
    String storagePath = uri.path;
    try {
      Reference storageRef = FirebaseStorage.instance.ref().child(storagePath);
      await storageRef.delete();
    } catch (e) {
      print('Error deleting item: $e');
    }
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void>toggleOff(bool commenting1,bool likes1)async{
    try{
    DocumentSnapshot documentSnapshot = await firestore
        .collection(widget.collection)
        .doc(widget.collection=="posts"?widget.post!.postid:widget.ftv!.postid)
        .get();
    if (documentSnapshot.exists) {
      var oldData = documentSnapshot.data() as Map<String, dynamic>;
      Map<String, dynamic> newData = {};
      setState(() {
      if (likes1 != oldData['likes']) {
        newData['likes'] = likes1;
        likes=likes1;
        if(widget.collection=="posts"){
          widget.post!.likes=likes;
        }else{
          widget.ftv!.likes=likes;
        }
      }
      if (commenting1!= oldData['commenting']) {
        newData['commenting'] = commenting1;
        commenting=commenting1;
        if(widget.collection=="posts"){
          widget.post!.commenting=commenting1;
        }else{
          widget.ftv!.commenting=commenting1;
        }
      }
      });
    if (newData.isNotEmpty) {
      await documentSnapshot.reference.update(newData);
    }
  }}catch(e){
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
        );
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.31,
      minChildSize: 0.31,
      maxChildSize: 0.315,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),child: Padding(
              padding: const EdgeInsets.only(left: 8,right:8,top:8,bottom:16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      addpost(widget.collection=="posts"?widget.post!.postid:widget.ftv!.postid);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.save_alt),
                          SizedBox(width: 10,),
                          Text('Save post')
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PostInsights(postId:widget.collection=="FansTv"?widget.ftv!.postid:widget.post!.postid,collection:widget.collection)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.insights),
                          SizedBox(width: 10,),
                          Text('View Post Insights')
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        commenting=!commenting;
                      });
                      toggleOff(commenting, likes);
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPost(ftv:widget.ftv,post: widget.post,)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child:  Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          commenting?Icon(Icons.comments_disabled):Icon(Icons.mode_comment_outlined),
                          SizedBox(width: 10,),
                          commenting?Text('Turn off commenting'):Text("Turn on commenting")
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      setState(() {
                        likes=!likes;
                      });
                      toggleOff(commenting, likes);
                      //Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPost(ftv:widget.ftv,post: widget.post,)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                         likes?Icon(Icons.visibility_off):Icon(Icons.visibility),
                          SizedBox(width: 5,),
                          Icon(Icons.thumb_up),
                          SizedBox(width: 10,),
                          likes?Text('Hide Likes'):Text("Show Likes")
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPost(ftv:widget.ftv,post: widget.post,)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.mode_edit_sharp),
                          SizedBox(width: 10,),
                          Text('Edit post')
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                alignment: Alignment.center,
                                title: const Text('Delete post?'),
                                actions: [
                                  Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        child: const Text('No'),
                                        onPressed: () {
                                          Navigator.pop(context); // Dismiss the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('yes'),
                                        onPressed: () {
                                          widget.collection=="FansTv"?deletePost():deletePost1();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  )
                                ]);
                          }
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.delete_forever),
                          SizedBox(width: 10,),
                          Text('Delete post')
                        ],
                      ),
                    ),),

                ],),
            ),),
        ),
      ),
    );
  }
}

class OptionPosts1 extends StatefulWidget {
  String postId;
  String collection;
  String authorId;
  String url;
  OptionPosts1({super.key,
    required this.postId,
    required this.collection,
    required this.authorId,
    required this.url});

  @override
  State<OptionPosts1> createState() => _OptionPosts1State();
}

class _OptionPosts1State extends State<OptionPosts1> {
  TextEditingController report = TextEditingController();

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
  Future<void> addPost(String postId) async {
    showToastMessage('Saving ${widget.collection}..');
    final DocumentReference fanDocRef = FirebaseFirestore.instance.collection('${collectionNamefor}s').doc(FirebaseAuth.instance.currentUser!.uid);
    final Timestamp createdAt = Timestamp.now();
    final like = {
      'postId': postId,
      'timestamp': createdAt,
    };
    Future<void> updateOrAddDocument(DocumentReference docRef) async {
      final DocumentSnapshot snapshot = await docRef.get();
      if (snapshot.exists) {
        final QuerySnapshot locationQuery = await docRef.collection('saved${widget.collection}').get();
        if (locationQuery.docs.isNotEmpty) {
          final DocumentSnapshot locationDoc = locationQuery.docs.first;
          List<dynamic> likesArray = locationDoc[widget.collection] ?? [];
          if (likesArray.length < 12000) {
            likesArray.add(like);
            await locationDoc.reference.update({widget.collection: likesArray});
          } else {
            await docRef.collection('saved${widget.collection}').add({widget.collection: [like]});
          }
        } else {
          await docRef.collection('saved${widget.collection}').add({widget.collection: [like]});
        }
      }else{

      }
    }
    await updateOrAddDocument(fanDocRef);
    showToastMessage('Post saved..');
  }

  void reportPost(String postId,String report)async{
    showToastMessage('Reporting post...');
    final CollectionReference coll = FirebaseFirestore.instance.collection('Reportposts');
    final Timestamp createdAt = Timestamp.now();
    final like = {
      'postId': postId,
      'authorId':widget.authorId,
      'report':report,
      'timestamp': createdAt,
    };
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final QuerySnapshot querySnapshot = await coll.get();
        final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
        if (documents.isNotEmpty) {
          final DocumentSnapshot latestDoc = documents.first;
          final List<Map<String, dynamic>>? chats = (latestDoc['reports'] as List?)
              ?.cast<Map<String, dynamic>>();
          if (chats != null) {
            if (chats.length < 12000) {
              chats.add(like);
              transaction.update(latestDoc.reference, {'reports': chats});
              showToastMessage('Report sent...');
            } else {
              coll.add({'reports': [like]});
              showToastMessage('Report sent...');
            }
          }
          showToastMessage('Report sent...');
        } else {
          coll.add({'reports': [like]});
          showToastMessage('Report sent...');
        }
      });
    }


  Future<void> _saveNetworkImage(String url) async {
    try {
      var response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/temp_image.png';
      final File tempFile = File(tempPath);
      await tempFile.writeAsBytes(response.data);
      final result = await ImageGallerySaver.saveFile(tempPath);
      print(result);
    } catch (e) {
      print('Error saving network image: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.31,
      minChildSize: 0.31,
      maxChildSize: 0.315,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
            ),child: Padding(
            padding: const EdgeInsets.only(left: 8,right:8,top:8,bottom:16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: (){
                      addPost(widget.postId);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.archive),
                          SizedBox(width: 10,),
                          Text('Save post')
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      _saveNetworkImage(widget.url);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.save_alt),
                          SizedBox(width: 10,),
                          Text('Download media')
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                                alignment: Alignment.center,
                                title: const Text('Report post'),
                                content:SizedBox(
                                  height: 40,
                                  child: TextFormField(
                                    textAlignVertical: TextAlignVertical.bottom,
                                    controller: report,
                                    decoration: InputDecoration(
                                        hintText: 'Statement',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        hintStyle: const TextStyle(color: Colors.black)
                                    ),
                                  ),
                                ) ,
                                actions: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      TextButton(
                                        child: const Text('dismiss'),
                                        onPressed: () {
                                          Navigator.pop(context); // Dismiss the dialog
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('report'),
                                        onPressed: () {
                                          reportPost(widget.postId, report.text);
                                          Navigator.pop(context); // Dismiss the dialog
                                        },
                                      ),
                                    ],
                                  )
                                ]);}
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.report,color: Colors.red,),
                          SizedBox(width: 10,),
                          Text('report post')
                        ],
                      ),
                    ),)],),
            ),),
        ),
      ),
    );
  }
}
class PostInsights extends StatefulWidget {
  String postId;
  String collection;
   PostInsights({super.key,
    required this.postId,required this.collection});

  @override
  State<PostInsights> createState() => _PostInsightsState();
}

class _PostInsightsState extends State<PostInsights> {
  late DataPoints dataPoints;
  bool isLoading = true;
  FirebaseFirestore firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
    getData();
  }
  void getData() async {
    try {
      dataPoints = await DataFetcher().postData(widget.collection, widget.postId);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("$e"),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:  Text(
          "${widget.collection} Insights",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading||dataPoints==null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(2.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Likes against Duration(days)",style:TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 600,
                child: buildGraph(dataPoints, 'Likes', 'Duration (days)'),
              ),
              widget.collection=="posts"?SizedBox.shrink():Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Views against Duration(days)",style:TextStyle(fontWeight: FontWeight.bold)),
              ),
             widget.collection=="posts"?SizedBox.shrink(): SizedBox(
                height: 600,
                child: buildGraph1(dataPoints, 'Views', 'Duration (days)'),
              ),
              widget.collection=="posts"?SizedBox.shrink():Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Watch Hours against Duration(days)",style:TextStyle(fontWeight: FontWeight.bold)),
              ),
              widget.collection=="posts"?SizedBox.shrink():SizedBox(
                height: 600,
                child: buildGraph2(dataPoints, 'Watch Hours', 'Duration (days)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget buildGraph(DataPoints dataMap, String y, String x,) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.likesData.map((usage) => FlSpot(usage.minute.toDouble(), usage.likes.toDouble()*100000)).toList();
    double i=1.0;
    if(highestValue1>20&&highestValue1<50){
      i=5.0;
    }else if(highestValue1>50&&highestValue1<100){
      i=10.0;
    }else if(highestValue1>100&&highestValue1<500){
      i=20.0;
    }else if(highestValue1>500&&highestValue1<1000){
      i=30.0;
    }else if(highestValue1>1000&&highestValue1<10000){
      i=40.0;
    }
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      isCurved: true,
      barWidth: 4,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withOpacity(0.3),
      ),
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: LineChart(
                LineChartData(
                  maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
                  minY: 0,
                  maxX: highestValue1 <= 10
                      ? highestValue1.toDouble()
                      : (((highestValue1 + 9) ~/ 10) * 10).toDouble(),
                  minX: 1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize: 16,
                      axisNameWidget: Text(
                        y,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      axisNameSize: 16,
                      axisNameWidget: Text(
                        x,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 10,
                        interval: i,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: dataPoints,
                  clipData: FlClipData.all(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextGraphLikesData(dataMap, y, x),
      ],
    );
  }

  Widget TextGraphLikesData(DataPoints dataMap,String y,String x ){
    int likes = dataMap.likesData.fold(0, (sum, element) => sum + element.likes);
    int  duration = dataMap.likesData.last.minute;
    double average= likes/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$likes"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per day",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }

  Widget TextGraphViewsData(DataPoints dataMap,String y,String x ){
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    int  duration = dataMap.viewsData.last.minute;
    double average= views/duration;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$views"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                  VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text("Avg $y per day",style:TextStyle(fontWeight: FontWeight.bold)),
                        Text("$average"),
                        SizedBox(height: 1,),
                      ],
                    ),
                  ),
                ],),
            ),
          ),
        ],
      ),
    );
  }
  Widget TextGraphWatchHoursData(DataPoints dataMap,String y,String x ){
    double watchhours = dataMap.viewsData.fold(0, (sum, element) => sum + element.watchhours);
    int views = dataMap.viewsData.fold(0, (sum, element) => sum + element.views);
    int  duration = dataMap.viewsData.last.minute;
    double average= watchhours/duration;
    double averagewatchhours= watchhours/views;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text("Graph Insights",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          SizedBox(height: 5,),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                border: Border.all(width: 1,color: Colors.grey)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicHeight(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(y,style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("$watchhours"),
                              SizedBox(height: 1,),
                            ],
                          ),
                        ),
                        VerticalDivider(color: Colors.black,width: 40,thickness: 1,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text("Avg $y per day",style:TextStyle(fontWeight: FontWeight.bold)),
                              Text("$average"),
                              SizedBox(height: 1,),
                            ],
                          ),
                        ),
                      ]),
                ),
                Divider(color: Colors.black,height:3,thickness: 1,),
                Text("Avg $y per view",style:TextStyle(fontWeight: FontWeight.bold)),
                Text("$averagewatchhours"),
                SizedBox(height: 5,),
              ],),
          ),
        ],
      ),
    );
  }
  Widget buildGraph1(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.viewsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.views.toDouble())).toList();
    double i=1.0;
    if(highestValue1>20&&highestValue1<50){
      i=5.0;
    }else if(highestValue1>50&&highestValue1<100){
      i=10.0;
    }else if(highestValue1>100&&highestValue1<500){
      i=20.0;
    }else if(highestValue1>500&&highestValue1<1000){
      i=30.0;
    }else if(highestValue1>100&&highestValue1<500){
      i=40.0;
    }
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      isCurved: true,
      barWidth: 4,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withOpacity(0.3),
      ),
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: LineChart(
                LineChartData(
                  maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
                  minY: 0,
                  maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
                  minX: 1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize: 16,
                      axisNameWidget: Text(
                        y,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      axisNameSize: 16,
                      axisNameWidget: Text(
                        x,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 10,
                        interval: i,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: dataPoints,
                  clipData: FlClipData.all(),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphViewsData(dataMap,y,x )
      ],
    );
  }

  Widget buildGraph2(DataPoints dataMap, String y, String x) {
    final dataPoints = <LineChartBarData>[];
    int highestValue1 = dataMap.likesData.reduce((a, b) => a.minute > b.minute ? a : b).minute;
    List<FlSpot> spots = dataMap.viewsData.map((usage) => FlSpot(usage.minute.toDouble(), usage.watchhours.toDouble())).toList();
    double i=1.0;
    if(highestValue1>20&&highestValue1<50){
      i=5.0;
    }else if(highestValue1>50&&highestValue1<100){
      i=10.0;
    }else if(highestValue1>100&&highestValue1<500){
      i=20.0;
    }else if(highestValue1>500&&highestValue1<1000){
      i=30.0;
    }else if(highestValue1>100&&highestValue1<500){
      i=40.0;
    }
    final barChartGroupData = LineChartBarData(
      color: Colors.blueAccent,
      isStrokeJoinRound: true,
      spots: spots,
      isCurved: true,
      barWidth: 4,
      isStrokeCapRound: true,
      belowBarData: BarAreaData(
        show: true,
        color: Colors.blue.withOpacity(0.3),
      ),
      dotData: const FlDotData(
        show: true,
      ),
    );
    dataPoints.add(barChartGroupData);
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: SizedBox(
              height: 400,
              width: MediaQuery.of(context).size.width,
              child: LineChart(
                LineChartData(
                  maxY: spots.isNotEmpty ? spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) : 0,
                  minY: 0,
                  maxX: highestValue1<=10?highestValue1.toDouble():(((highestValue1 + 9) ~/ 10) * 10).toDouble(),
                  minX: 1,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      axisNameSize: 16,
                      axisNameWidget: Text(
                        y,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      axisNameSize: 16,
                      axisNameWidget: Text(
                        x,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 10,
                        interval: i,
                        getTitlesWidget: (value, titleMeta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: dataPoints,
                  clipData: FlClipData.all(),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20,),
        TextGraphWatchHoursData(dataMap,y,x )
      ],
    );
  }
}

class ViewsCount extends StatelessWidget {
  final int totalLikes;
  final Color color;
  const ViewsCount({super.key,required this.totalLikes,this.color=Colors.white});
  @override
  Widget build(BuildContext context) {

    if (totalLikes < 1) {
      return const SizedBox.shrink();
    }else if(totalLikes>999999){
      return Text('${totalLikes/1000000}M views',style:  TextStyle(color: color),);
    }else if(totalLikes>999999999){
      return Text('${totalLikes/1000000000}B views',style:  TextStyle(color: color),);
    } else if(totalLikes ==1) {
      return Text(
        '$totalLikes view',style:  TextStyle(color: color),
      );
    } else {
      return Text(
        '$totalLikes views',style:  TextStyle(color: color),
      );
    }

  }
}

class ViewsProvider extends ChangeNotifier{
  List<Map<String,dynamic>>views=[];
  bool viewed=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
   List<QueryDocumentSnapshot> alldocs =[];
  Future<void> getViews(String collection,String postId)async{
    try {
      stream = _firestore
          .collection(collection)
          .doc(postId)
          .collection('views')
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> allViews = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc['views']);
            allViews.addAll(chats);
          }
          alldocs=docs;
          views= allViews;
          viewed=views.any((element) => element['userId']==FirebaseAuth.instance.currentUser!.uid);
          notifyListeners();
        } else {
          notifyListeners();
        }
      });
    } catch (e) {
      notifyListeners();
    }
  }
  void addView(String collection,String postId,bool isnonet,DateTime startime)async{
    final timeSpentInSeconds = DateTime.now().difference(startime).inSeconds;
    final newHoursSpent = timeSpentInSeconds / 3600.0;
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(postId)
        .collection('views');

    final bool userLiked =views.any((element) => element['userId']==FirebaseAuth.instance.currentUser!.uid);

    if (userLiked) {
    }else{
      final Timestamp timestamp = Timestamp.now();
      var like = {'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp,'watchhours':newHoursSpent};
      if(collection=="Story"){
        like={'userId': FirebaseAuth.instance.currentUser!.uid, 'timestamp': timestamp,'watchhours':newHoursSpent,'storyId':postId};
      }
      viewed=true;
      notifyListeners();
      if(isnonet){
        try {
          final List<QueryDocumentSnapshot> documents = alldocs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc['views'];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({'views': chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({'views': [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({'views': [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          print('Error sending message: $e');
        }
        notifyListeners();
      }else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            final List<Map<String, dynamic>>? chats = (latestDoc['views'] as List?)
                ?.cast<Map<String, dynamic>>();
            if (chats != null) {
              if (chats.length < 16000) {
                chats.add(like);
                transaction.update(latestDoc.reference, {'views': chats});
              } else {
                likesCollection.add({'views': [like]});
              }
            }
          } else {
            likesCollection.add({'views': [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
    }
    notifyListeners();
  }
  Future<void> updateWatchhours(String collection,String postId,bool isnonet,DateTime startime) async {
    final timeSpentInSeconds = DateTime.now().difference(startime).inSeconds;
    final newHoursSpent = timeSpentInSeconds / 3600.0;
    try {
      final CollectionReference viewsCollection = FirebaseFirestore.instance
          .collection(collection)
          .doc(postId)
          .collection('views');
      final bool userLiked = viewed=views.any((element) => element['userId']==FirebaseAuth.instance.currentUser!.uid);
      if(!userLiked){
        return ;
      }
      QuerySnapshot querySnapshot = await viewsCollection.get();
      for (QueryDocumentSnapshot document in querySnapshot.docs) {
        List<Map<String, dynamic>>viewsArray= List.from(document['views']);
        final data=viewsArray.firstWhere((element) => element["userId"]==FirebaseAuth.instance.currentUser!.uid);
        viewsArray.remove(data);
        final newdata={
          'userId':data['userId'],
          'timestamp':data['timestamp'],
          'watchhours':data['watchhours']+newHoursSpent,
        };
         viewsArray.add(newdata);
        if(isnonet) {
          await document.reference.update({'views': viewsArray});
        }else{
          await FirebaseFirestore.instance.runTransaction((transaction) async{
            transaction.update(document.reference, {'views': viewsArray});
          });
        }
      }
    } catch (e) {
      print('Error updating watchhours: $e');
    }
  }
}