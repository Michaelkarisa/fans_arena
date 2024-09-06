import 'package:fans_arena/appid.dart';
import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/screens/commentheader.dart';
import 'package:fans_arena/fans/screens/commentlikes.dart';
import 'package:fans_arena/fans/screens/newsfeedcommentreplies.dart';
import 'package:fans_arena/fans/screens/repliesdata.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'accountfanviewer.dart';
import 'newsfeed.dart';

class FeedComments extends StatefulWidget {
  Posts post;
  FeedComments({super.key,required this.post});

  @override
  State<FeedComments> createState() => _FeedCommentsState();
}

class _FeedCommentsState extends State<FeedComments> {
 late Future<List<Comment>>data;
  @override
  void initState() {
    super.initState();
    data=DataFetcher().getcommentdata(docId: widget.post.postid, collection: 'posts', subcollection: 'comments');
  }
  TextEditingController comment =TextEditingController();
  String message8='commented on your post';
  Future<void> _commentPost() async {
    await SendComments().commentPost(docId: widget.post.postid,
        authorId: widget.post.user.userId,
        message: message8,
        comment: comment,
        collection: 'posts');
    setState(() {
      comment.clear();
      data=DataFetcher().getcommentdata(docId: widget.post.postid, collection: 'posts', subcollection: 'comments');
    });
  }
 List<String>hashes=["mine","Fans Arena","Sports","Ganze","Football","Basketball","NBAkenya","FiFA","UEFA","FKF","VolleyballKenya"];

  double radius=19;
  bool ascending=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: FeedcommentsH(postId: widget.post.postid,),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(onPressed: (){
                    setState(() {
                      data= DataFetcher().getcommentdata(docId: widget.post.postid, collection: 'posts', subcollection: 'comments');
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
                                              CustomAvatar(radius: radius, imageurl: widget.post.user.url),
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
                                                child: UsernameDO(
                                                  username: widget.post.user.name,
                                                  collectionName: widget.post.user.collectionName,
                                                  width: 160,
                                                  height: 38,
                                                  maxSize: 140,
                                                ),
                                              ),

                                            ],
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context).size.width*0.6,
                                            child: ListView.builder(
                                                itemCount: widget.post.captionUrl.length,
                                                shrinkWrap: true,
                                                itemBuilder: (context,index){
                                                  final caption=widget.post.captionUrl[index];
                                                  return Text(caption['caption'],style: const TextStyle(color: Colors.black),);
                                                }),
                                          ),

                                        ],
                                      ),
                                    )
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
                        ),

                      ])
              )
            ];
          },
          body: Column(
            children: [
              Expanded(
                child:FutureBuilder<List<Comment>>(
                    future: data,
                    builder: (context, snapshot){
                      if(snapshot.connectionState==ConnectionState.waiting){
                        return const CommentShimmer();
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
                            String t = DateFormat('a').format(createdDateTime); // AM/PM
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
                                              child: Text('at $hours:$minutes $t',style: const TextStyle(fontSize: 14),),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40,right: 5),
                                          child: InkWell(
                                              onTap: (){
                                                Navigator.push(context,
                                                  MaterialPageRoute(builder: (context)=>
                                                      FeedCommentsreplies(comment:comments,post: widget.post,authorId: widget.post.user.userId,),
                                                  ),
                                                );
                                              },
                                              child: Text(comments.comment)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 5,right: 20,bottom: 10),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              TextButton(onPressed: (){
                                                Navigator.push(context,
                                                  MaterialPageRoute(builder: (context)=>
                                                      FeedCommentsreplies(comment:comments,post: widget.post,authorId: widget.post.user.userId,),
                                                  ),
                                                );
                                              }, child: Repliesdata(commentId: comments.commentId, postId: widget.post.postid)),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: CommentLikeButton(postId:widget.post.postid ,commentId: comments.commentId, authorId: comments.user.userId, collection: 'posts',),
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
                        return const SizedBox.shrink();
                      }}),
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
        ),
      ),
    );
  }
}
