import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/commentsheader1.dart';
import 'package:fans_arena/fans/screens/repliesdatafanstv.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../clubs/screens/accountclubviewer.dart';
import '../../../clubs/screens/eventsclubs.dart';
import '../../../fans/screens/accountfanviewer.dart';
import '../../../fans/screens/commentlikes.dart';
import '../../../fans/screens/newsfeed.dart';
import '../../../fans/screens/replylike.dart';
import '../../../professionals/screens/accountprofilepviewer.dart';
import '../../../reusablewidgets/cirularavatar.dart';

class BottomSheetWidget extends StatefulWidget {
  FansTv post;
  void Function() play;
  bool isplaying;
  BottomSheetWidget({super.key,
    required this.post,
    required this.play,
    required this.isplaying});

  @override
  _BottomSheetWidgetState createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  final PageController pageController = PageController(initialPage: 0);
  final ScrollController pController= ScrollController();
  int _pageIndex = 0;

  @override
  void initState(){
    super.initState();
    setState(() {
      comment=Comment(user:Person(
          name: '', url: '',
          collectionName: '',
          userId: ''),
          comment: '',
          timestamp: Timestamp.now(),
          commentId: '');

    });
  }
  void initialize(Comment comment,){
    Page2(
      onPrevPage: () {
        pageController.previousPage(
          duration: const Duration(milliseconds: 20),
          curve: Curves.bounceInOut,
        );
      },
      pageController: pageController,
      pController: pController,
      post: widget.post,
      comment:comment,
    );
  }
  void page (index) async{
    setState(() {
      _pageIndex = index;
    });

  }
  late Comment comment;
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        expand: true,
        initialChildSize: 0.6,
        maxChildSize: 0.8,
        minChildSize: 0.4,
        builder: (context, pController) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(topLeft:Radius.circular(20),topRight: Radius.circular(20)),
                color: Colors.grey[200],
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.125,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(300),
                        child: const Divider(thickness: 4,color: Colors.black,)),
                  ),
                  Expanded(
                    child: PageView(
                        reverse: false,
                        physics: const NeverScrollableScrollPhysics(),
                        allowImplicitScrolling: true,
                        scrollBehavior: const ScrollBehavior(),
                        scrollDirection: Axis.horizontal,
                        controller: pageController,
                        onPageChanged: page,
                        children: [ CommentsTv(
                          onNextPage: (comments) {
                            initialize(comments);
                            setState(() {
                              comment = comments;
                            });
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 20),
                              curve: Curves.bounceInOut,
                            );
                          },
                          pageController: pageController,
                          pController: pController,
                          post: widget.post,
                          play: widget.play,
                          playing: widget.isplaying,
                        ),
                          Page2(
                            onPrevPage: () {
                              pageController.previousPage(
                                duration: const Duration(milliseconds: 20),
                                curve: Curves.bounceInOut,
                              );
                            },
                            pageController: pageController,
                            pController: pController,
                            post: widget.post,
                            comment: comment,
                          )]
                    ),

                  ),

                ],
              ),
            )));
  }
}
class CommentsTv extends StatefulWidget {
  FansTv post;
  final void Function(Comment comment) onNextPage;
  final void Function() play;
  final PageController pageController;
  final ScrollController pController;
  bool playing;
  CommentsTv({super.key,
    required this.onNextPage,
    required this.pageController,
    required this.pController,
    required this.play,
    required this.post,
    required this.playing});
  @override
  _CommentsTvState createState() => _CommentsTvState();
}

class _CommentsTvState extends State<CommentsTv> {
  TextEditingController comment =TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late Future<List<Comment>>data;
  @override
  void initState() {
    super.initState();
    data=DataFetcher().getcommentdata(docId: widget.post.postid, collection: 'FansTv', subcollection: 'comments');
  }

  String message='commented on your video';
  Future<void> _commentPost() async {
    await SendComments().commentPost(docId: widget.post.postid,
        authorId: widget.post.user.userId,
        message: message,
        comment: comment,
        collection: 'FansTv');
    setState(() {
      comment.clear();
      data=DataFetcher().getcommentdata(docId: widget.post.postid, collection: 'FansTv', subcollection: 'comments');
    });
  }
List<String>hashes=["mine","Fans Arena","Sports","Ganze","Football","Basketball","NBAkenya","FiFA","UEFA","FKF","VolleyballKenya"];

  double radius=19;
  bool ascending=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        automaticallyImplyLeading: false,
        toolbarHeight: 40,
        elevation: 0,
        title:   Padding(
          padding: const EdgeInsets.only(left: 20,right: 15),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.88,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommentHeader1(postId: widget.post.postid,),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(onPressed: (){
                        setState(() {
                          data=DataFetcher().getcommentdata(docId: widget.post.postid, collection: 'FansTv', subcollection: 'comments');
                        });
                      }, icon: const Icon(Icons.refresh,size: 30,color: Colors.black,)),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.sort,color: Colors.black,),
                        onSelected: (value) {
                          if(value=='1'){

                          }else if (value=='2'){
                            setState(() {
                              ascending=!ascending;
                            });
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            const PopupMenuItem<String>(
                              value: '1',
                              child: Text('Top most comment'),
                            ),
                            PopupMenuItem<String>(
                              value: '2',
                              child: Text(ascending?'Latest comment':'Oldest comment'),
                            ),
                          ];
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,color: Colors.black,size: 30,),
                        onPressed: () {
                          if(!widget.playing) {
                            widget.play();
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 2,
                controller: widget.pController,
                shrinkWrap: true,
                itemBuilder: (context,index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          CustomAvatar(
                                              radius: 25, imageurl: widget.post.user.url),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 5),
                                            child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
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
                                                  ); //
                                                },
                                                child: UsernameDO(
                                                  username: widget.post.user.name,
                                                  collectionName: widget.post.user.collectionName,
                                                  maxSize:140,
                                                  width: 160,
                                                  height: 38,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )),
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 40,right: 5),
                                        child: Text(widget.post.caption),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Wrap(
                                children: hashes.map((h)=> Text('#$h', style: const TextStyle(color: Colors.blue)),
                                  ).toList(),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return data==null?SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height*0.45,
                        child: const CommentShimmer()):FutureBuilder<List<Comment>>(
                        future: data,
                        builder: (context, snapshot){
                          if(snapshot.connectionState==ConnectionState.waiting){
                            return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height*0.45,
                                child: const CommentShimmer());
                          }else if(snapshot.hasError){
                            return Text('${snapshot.error}');
                          }else if(!snapshot.hasData||snapshot.data!.isEmpty){
                            return const Center(child: Text("No Comments"),);
                          }else if(snapshot.hasData){
                            List<Comment>matches=snapshot.data!;
                            if(ascending){
                              matches .sort((a, b) {
                                Timestamp adate = a.timestamp;
                                Timestamp bdate = b.timestamp;
                                return adate.compareTo(bdate);
                              });
                            }else{
                              matches .sort((a, b) {
                                Timestamp adate = a.timestamp;
                                Timestamp bdate = b.timestamp;
                                return bdate.compareTo(adate);
                              });}
                            return ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: matches.length,
                              itemBuilder: (BuildContext context, int index) {
                                final comments=matches[index];
                                DateTime createdDateTime = comments.timestamp.toDate();
                                DateTime now = DateTime.now();
                                Duration difference = now.difference(createdDateTime);
                                String formattedTime = '';
                                if (difference.inSeconds == 1) {
                                  formattedTime = 'now';
                                } else if (difference.inSeconds < 60) {
                                  formattedTime = 'now';
                                } else if (difference.inMinutes ==1) {
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
                                } else if (difference.inDays == 7) {
                                  formattedTime = '${difference.inDays ~/ 7} week ago';
                                } else {
                                  formattedTime = DateFormat('d MMM').format(createdDateTime);
                                }
                                String hours = DateFormat('HH').format(createdDateTime);
                                String minutes = DateFormat('mm').format(createdDateTime);
                                String t = DateFormat('a').format(createdDateTime); // AM/PM/ AM/PM
                                return  Padding(
                                  padding: const EdgeInsets.only(top:3 ,bottom: 3),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          color: Colors.white70,
                                          border: Border.symmetric(horizontal: BorderSide(
                                            width: 1,
                                            color: Colors.white24,
                                          ))
                                      ),
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.only(top:4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 5),
                                                  child: CustomAvatar(radius: 16, imageurl: comments.user.url),
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.push(context,
                                                        MaterialPageRoute(
                                                            builder: (context){
                                                              if(comments.user.collectionName=='Club'){
                                                                return AccountclubViewer(user: comments.user, index: 0);
                                                              }else if(comments.user.collectionName=='Professional'){
                                                                return AccountprofilePviewer(user: comments.user, index: 0);
                                                              }else{
                                                                return Accountfanviewer(user: comments.user, index: 0);
                                                              }
                                                            }
                                                        ),
                                                      );
                                                    },
                                                    child: CustomName(username:comments.user.name,style: const TextStyle(color: Colors.black,
                                                      fontSize: 16.0,
                                                      fontWeight: FontWeight.bold,), maxsize: 140,)
                                                ),
                                                comments.user.userId==widget.post.user.userId?const Row(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 5,right: 2),
                                                      child: Icon(Icons.star,color: Colors.grey,size: 15,),
                                                    ),
                                                    Text('Author',style: TextStyle(fontWeight: FontWeight.bold),),
                                                  ],
                                                ):const Text(''),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4),
                                                  child: Text(formattedTime,style: const TextStyle(fontSize: 14),),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 4),
                                                  child: Text('at ${hours}:${minutes} $t',style: const TextStyle(fontSize: 14),),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 40,right: 5),
                                              child: InkWell(
                                                  onTap: (){
                                                    widget.onNextPage(comments);
                                                  },
                                                  child: Text(comments.comment)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                              child:  Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  TextButton(onPressed: (){
                                                    widget.onNextPage(comments);
                                                  }, child: Repliesdatatv(postId: widget.post.postid, commentId: comments.commentId,)),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    child: CommentLikeButton(postId:widget.post.postid ,commentId: comments.commentId,authorId: comments.user.userId,collection:"FansTv"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }else{
                            return SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height*0.45,
                                child: const CommentShimmer());
                          }});}}),),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.black,
                    child: CachedNetworkImage(
                      imageUrl: profileimage,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 18,
                        backgroundImage: imageProvider,
                      ),

                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width:MediaQuery.of(context).size.width*0.65,
                        child: TextFormField(
                          controller: comment,
                          scrollPhysics: const ScrollPhysics(),
                          expands: false,
                          maxLines: 4,
                          minLines: 1,
                          textInputAction: TextInputAction.newline,
                          cursorColor: Colors.black,
                          decoration:  InputDecoration(
                            filled: true,
                            focusColor: Colors.grey,
                            hoverColor: Colors.grey,
                            fillColor: Colors.white,
                            hintText:widget.post.commenting?'write a comment':"commenting disabled",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.15,
                      child:widget.post.commenting? TextButton(onPressed: _commentPost,
                          child: const Text('Post',style: TextStyle(color: Colors.blue),)):SizedBox.shrink())
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Page2 extends StatefulWidget {
  FansTv post;
  final VoidCallback onPrevPage;
  final ScrollController pController;
  final PageController pageController;
  Comment comment;
  Page2({super.key,
    required this.onPrevPage,
    required this.pController,
    required this.pageController,
    required this.post,
    required this.comment,
  });

  @override
  _Page2State createState() => _Page2State();

}

class _Page2State extends State<Page2> {

  TextEditingController reply =TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
 late Future<List<Reply>>data;
  @override
  void didUpdateWidget(covariant Page2 oldWidget) {
    if (oldWidget.comment.commentId != widget.comment.commentId) {
      _getCurrentUser1();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }
  Future<void> _getCurrentUser1() async {
    setState(() {
      data=DataFetcher().getreplydata(docId: widget.post.postid, collection: 'FansTv', subcollection: 'replies', commentId:widget.comment.commentId );
    });
  }


  String message='replied to your comment on this video';
  Future<void> _commentPost() async {
    await SendReplies().commentPost(docId: widget.post.postid,
        authorId: widget.comment.user.userId,
        message: message,
        commentId: widget.comment.commentId,
        collection: 'FansTv', reply: reply);
    setState(() {
      reply.clear();
      data=DataFetcher().getreplydata(docId: widget.post.postid, collection: 'FansTv', subcollection: 'replies',commentId: widget.comment.commentId);
    });
  }
  bool isLoading = true;


  double radius=19;
  List<Reply> matches=[];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        widget.onPrevPage;
        return true;
      },
      child: Scaffold(
        backgroundColor:Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          automaticallyImplyLeading: false,
          toolbarHeight:40,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              onPressed: (){
                widget.onPrevPage();
                setState(() {
                  matches.clear();
                });
              },
              icon: const Icon(Icons.arrow_back,color: Colors.black,size: 30,),
            ),
          ),
          titleSpacing: 1.0,
          centerTitle: true,
          title:   const Padding(
            padding: EdgeInsets.only(left: 20,right: 45),
            child: Text('Replies',style: TextStyle(color: Colors.blue,fontSize: 18),),
          ),
          actions: [
            SizedBox(
              width:MediaQuery.of(context).size.width * 0.35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      data=DataFetcher().getreplydata(docId: widget.post.postid, collection: 'FansTv', subcollection: 'replies', commentId:widget.comment.commentId );
                    });
                  }, icon: const Icon(Icons.refresh,size: 30,color: Colors.black,)),
                  IconButton(
                    icon: const Icon(Icons.close,color: Colors.black,size: 30,),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        body:  Column(
          children: [
            Expanded(
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: 2,
                  controller: widget.pController,
                  shrinkWrap: true,
                  itemBuilder: (context,index) {
                    if (index == 0) {
                      return   Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        CustomAvatar(
                                            radius: 25, imageurl: widget.post.user.url),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
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
                                                ); //
                                              },
                                              child: UsernameDO(
                                                username: widget.post.user.name,
                                                collectionName: widget.post.user.collectionName,
                                                maxSize:140,
                                                width: 160,
                                                height: 38,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )),
                                        ),
                                        widget.comment.user.userId==widget.post.user.userId?const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 5,right: 2),
                                              child: Icon(Icons.star,color: Colors.grey,size: 15,),
                                            ),
                                            Text('Author',style: TextStyle(fontWeight: FontWeight.bold),),
                                          ],
                                        ):const Text(''),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 40,right: 5),
                                      child: Text(widget.comment.comment),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20,left: 5),
                                      child: CommentLikeButton(postId: widget.post.postid, commentId: widget.comment.commentId,authorId: widget.comment.user.userId,collection:"FansTv"),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return data==null? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height*0.45,
                          child: const CommentShimmer()): FutureBuilder<List<Reply>>(
                          future: data,
                          builder: (context, snapshot){
                            if(snapshot.connectionState==ConnectionState.waiting){
                              return SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height*0.45,
                                  child: const CommentShimmer());
                            }else if(snapshot.hasError){
                              return Text('${snapshot.error}');
                            }else if(!snapshot.hasData||snapshot.data!.isEmpty){
                              return const Center(child: Text("No Replies"),);
                            }else if(snapshot.hasData){
                              matches=snapshot.data!;
                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: matches.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final comments=matches[index];
                                  DateTime createdDateTime = comments.timestamp.toDate();
                                  DateTime now = DateTime.now();
                                  Duration difference = now.difference(createdDateTime);
                                  String formattedTime = '';
                                  if (difference.inSeconds == 1) {
                                    formattedTime = 'now';
                                  } else if (difference.inSeconds < 60) {
                                    formattedTime = 'now';
                                  } else if (difference.inMinutes ==1) {
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
                                  } else if (difference.inDays == 7) {
                                    formattedTime = '${difference.inDays ~/ 7} week ago';
                                  } else {
                                    formattedTime = DateFormat('d MMM').format(createdDateTime);
                                  }
                                  String hours = DateFormat('HH').format(createdDateTime);
                                  String minutes = DateFormat('mm').format(createdDateTime);
                                  String t = DateFormat('a').format(createdDateTime); // AM/P
                                  return Padding(
                                    padding: const EdgeInsets.only(top:3 ,bottom: 3),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.white70,
                                            border: Border.symmetric(horizontal: BorderSide(
                                              width: 1,
                                              color: Colors.white24,
                                            ))
                                        ),
                                        width: MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.only(top:4),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 5),
                                                    child: CustomAvatar(radius: 16, imageurl: comments.user.url),
                                                  ),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder: (context){
                                                                if(comments.user.collectionName=='Club'){
                                                                  return AccountclubViewer(user: comments.user, index: 0);
                                                                }else if(comments.user.collectionName=='Professional'){
                                                                  return AccountprofilePviewer(user: comments.user, index: 0);
                                                                }else{
                                                                  return Accountfanviewer(user: comments.user, index: 0);
                                                                }
                                                              }
                                                          ),
                                                        );
                                                      },
                                                      child: CustomName(username:comments.user.name,style: const TextStyle(color: Colors.black,
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.bold,), maxsize: 140,)
                                                  ),
                                                  comments.user.userId==widget.post.user.userId?const Row(
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets.only(left: 5,right: 2),
                                                        child: Icon(Icons.star,color: Colors.grey,size: 15,),
                                                      ),
                                                      Text('Author',style: TextStyle(fontWeight: FontWeight.bold),),
                                                    ],
                                                  ):const Text(''),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 4),
                                                    child: Text(formattedTime,style: const TextStyle(fontSize: 14),),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 4),
                                                    child: Text('at ${hours}:${minutes} $t',style: const TextStyle(fontSize: 14),),
                                                  ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 40,right: 5),
                                                child: Text(comments.reply),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                                child: ReplyLikeButton(postId: widget.post.postid, replyId: comments.replyId, commentId: widget.comment.commentId, collection: 'FansTv',authorId: comments.user.userId,),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }else{
                              return SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height*0.45,
                                  child: const CommentShimmer());
                            }
                          });}}),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black,
                      child: CachedNetworkImage(
                        imageUrl: profileimage,
                        imageBuilder: (context, imageProvider) => CircleAvatar(
                          radius: 18,
                          backgroundImage: imageProvider,
                        ),

                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width:MediaQuery.of(context).size.width*0.65,
                          child: TextFormField(
                            controller: reply,
                            scrollPhysics: const ScrollPhysics(),
                            expands: false,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.newline,
                            cursorColor: Colors.black,
                            decoration:  InputDecoration(
                              filled: true,
                              focusColor: Colors.grey,
                              hoverColor: Colors.grey,
                              fillColor: Colors.white,
                              hintText: widget.post.commenting?'write a reply':"replying disabled",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                        width: MediaQuery.of(context).size.width*0.15,
                        child: widget.post.commenting? TextButton(onPressed: _commentPost,
                            child: const Text('Post',style: TextStyle(color: Colors.blue),)):SizedBox.shrink())
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


