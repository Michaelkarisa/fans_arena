import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/screens/commentlikes.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/fans/screens/replylike.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../clubs/screens/eventsclubs.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'accountfanviewer.dart';

class FeedCommentsreplies extends StatefulWidget {
  Comment comment;
  Posts post;
  String authorId;
  FeedCommentsreplies({super.key,
    required this.comment,
    required this.post,
    required this.authorId
  });

  @override
  State<FeedCommentsreplies> createState() => _FeedCommentsrepliesState();
}

class _FeedCommentsrepliesState extends State<FeedCommentsreplies> {
  late Future<List<Reply>>data;
  @override
  void initState() {
    super.initState();
    data=DataFetcher().getreplydata(docId: widget.post.postid, collection: 'posts', subcollection: 'replies',commentId: widget.comment.commentId);
  }

  TextEditingController reply =TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String message='replied to your comment on this post';
  Future<void> _commentPost() async {
    await SendReplies().commentPost(docId:  widget.post.postid,
        authorId: widget.comment.user.userId,
        message: message,
        commentId: widget.comment.commentId,
        collection: 'posts', reply: reply);
    setState(() {
      reply.clear();
      data=DataFetcher().getreplydata(docId:  widget.post.postid, collection: 'posts', subcollection: 'replies',commentId: widget.comment.commentId);
    });
  }
  double radius=19;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: const Text('Replies',style: TextStyle(color:Colors.black),),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },//to next page},
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      data=DataFetcher().getreplydata(docId:  widget.post.postid, collection: 'posts', subcollection: 'replies',commentId: widget.comment.commentId);
                    });
                  }, icon: const Icon(Icons.refresh,size: 30,color: Colors.black,)),
                ],
              ),
            )
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverList(
                  delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 10,top: 8, bottom: 8),
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
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              CustomAvatar(radius: radius, imageurl: widget.comment.user.url),
                                              InkWell(
                                                onTap: () {
                                                  Navigator.push(context,
                                                    MaterialPageRoute(
                                                        builder: (context){
                                                          if(widget.comment.user.collectionName=='Club'){
                                                            return AccountclubViewer(user: widget.comment.user, index: 0);
                                                          }else if(widget.comment.user.collectionName=='Professional'){
                                                            return AccountprofilePviewer(user: widget.comment.user, index: 0);
                                                          }else{
                                                            return Accountfanviewer(user: widget.comment.user, index: 0);
                                                          }
                                                        }
                                                    ),
                                                  );
                                                },
                                                child: UsernameDO(
                                                  username: widget.comment.user.name,
                                                  collectionName: widget.comment.user.collectionName,
                                                  width: 160,
                                                  height: 38,
                                                  maxSize: 140,
                                                ),
                                              ),

                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 1,left: 45),
                                            child: Text(widget.comment.comment),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 20,left: 5),
                                            child: CommentLikeButton(postId: widget.post.postid,commentId: widget.comment.commentId, authorId: widget.comment.user.userId, collection: 'posts',),
                                          )
                                        ],
                                      ),
                                    )
                                ),
                                const Text('#',style:TextStyle(color: Colors.blue)),
                                const Text('#',style:TextStyle(color: Colors.blue)),
                                const Text('#',style:TextStyle(color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),

                      ])
              )
            ];
          },
          body: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<Reply>>(
                    future: data,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return const CommentShimmer();
                      }else if(snapshot.hasError){
                        return Text('${snapshot.error}');
                      }else if(!snapshot.hasData||snapshot.data!.isEmpty){
                        return const Center(child: Text("No Replies"),);
                      }else if(snapshot.hasData){
                        List<Reply>matches=snapshot.data!;

                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: matches.length,
                          itemBuilder: (BuildContext context, int index) {
                            final comments=matches[index]; // Get the Timestamp object
                            // Get the Timestamp object
                            DateTime createdDateTime = comments.timestamp.toDate();

                            // Get the current device time
                            DateTime now = DateTime.now();

                            // Calculate the difference between the two times
                            Duration difference = now.difference(createdDateTime);
                            // Convert the Timestamp to a formatted String
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
                              formattedTime = DateFormat('d MMM').format(createdDateTime); // Format the date as desired
                            }
                            String hours = DateFormat('HH').format(createdDateTime);
                            String minutes = DateFormat('mm').format(createdDateTime);
                            String t = DateFormat('a').format(createdDateTime); // AM/PM
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
                                            comments.user.userId==widget.authorId?const Row(
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
                                              child: Text('at $hours:$minutes $t',style: const TextStyle(fontSize: 14),),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40,right: 5),
                                          child: Text(comments.reply),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                          child: ReplyLikeButton(postId:  widget.post.postid, replyId: comments.replyId, commentId: widget.comment.commentId, collection: 'posts',authorId: comments.user.userId,),
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
                        return const SizedBox.shrink();
                      }
                    }),
              ),

              Container(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.black,
                        child: CachedNetworkImage(
                          imageUrl:
                          profileimage,
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
      ),
    );
  }
}