import 'package:fans_arena/joint/components/apostold.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/data/newsfeedmodel.dart';
import '../../fans/screens/newsfeed.dart';
class Apostnew extends StatefulWidget {
  Person user;
  int index;
  List<Posts> posts;
  Apostnew({super.key, required this.user,required this.index,required this.posts});

  @override
  State<Apostnew> createState() => _ApostnewState();
}
class _ApostnewState extends State<Apostnew> with AutomaticKeepAliveClientMixin{
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Newsfeedservice news=Newsfeedservice();
  ScrollController controller = ScrollController();
  late PostModel lastPost;
  Set<String>postIds={};
  @override
  void initState() {
    super.initState();
    news=Newsfeedservice();
    getPosts();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        loadMore1();
      }
    });
  }

  Future<void> getPosts()async{
    setState(() async {
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
   await scrolltoitem();
  }
  bool isloading=true;
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
  Future<void> scrolltoitem() async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
  final context = itemkey.currentContext;

  if (context != null) {
  await Scrollable.ensureVisible(
  context,
  alignment: widget.index.toDouble() / widget.posts.length.toDouble(),
  );
  }
  });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Posts",style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(top: 10),
          child:  ListView.builder(
            scrollDirection: Axis.vertical,
            physics: const ScrollPhysics(),
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
class Optionposts extends StatefulWidget {
Posts post;
  Optionposts({super.key,required this.post});

  @override
  State<Optionposts> createState() => _OptionpostsState();
}

class _OptionpostsState extends State<Optionposts> {
TextEditingController caption = TextEditingController();
  void deletepost()async{
    for(final item in widget.post.captionUrl){
      await deleteStorageItemByUrl(item['url']);
    }
    FirebaseFirestore.instance
        .collection('posts')
        .where('postId', isEqualTo:widget.post.postid )
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        doc.reference.delete();
      }
    });
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





  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.31,
      minChildSize: 0.31,
      maxChildSize: 0.315,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

Padding(
  padding: const EdgeInsets.only(bottom: 15),
  child:   ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: Container(
    height: 80,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
        borderRadius: BorderRadius.circular(10)
      ),child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          InkWell(
            onTap: (){
           Navigator.push(context, MaterialPageRoute(builder: (context)=>EditPost(post: widget.post)));
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mode_edit_sharp),
                Text('Edit post')
              ],
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
                                  Navigator.pop(context);
                                },
                              ),
                              TextButton(
                                child: const Text('yes'),
                                onPressed: () {
                                  deletepost();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          )
                        ]);
                  }
              );
            },
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_forever),
                Text('Delete post')
              ],
            ),)],),
      ),),
  ),
),

        ],),
      ),
    );
  }
}
