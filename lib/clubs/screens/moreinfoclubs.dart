import 'package:fans_arena/clubs/screens/editprofilec.dart';
import 'package:flutter/material.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:fans_arena/joint/data/screens/widgets/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/components/likebutton.dart';
import '../../fans/screens/newsfeed.dart';
class MoreInfoClubs extends StatefulWidget {
  Person user;
   MoreInfoClubs({super.key,required this.user});
  @override
  State<MoreInfoClubs> createState() => _MoreInfoClubsState();
}
class _MoreInfoClubsState extends State<MoreInfoClubs> {

  @override
  void initState(){
    super.initState();
    retrieveUsername();
  }
  bool isLoading=true;
  void retrieveUsername() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Clubs')
          .where('Clubid', isEqualTo: widget.user.userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          fieldname = data['field'];
          history = data['history'];
          isLoading=false;
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
  String fieldname='';
  String history='';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text('More info',style: TextStyle(color: Colors.black),),
        ),
        body:SizedBox(
          width: MediaQuery.of(context).size.width,
          child:isLoading? SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                     history.isNotEmpty? Column(
                        children: [
                          const Text("Club's History",style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(history),
                        ],
                      ):const SizedBox.shrink(),
                      const SizedBox(height: 10,),
                      fieldname.isNotEmpty?Column(
                        children: [
                          const Text('Field name',style: TextStyle(fontWeight: FontWeight.bold),),
                          Text(fieldname),
                        ],
                      ):const SizedBox.shrink(),
                      const SizedBox(height: 10,),
                      Column(
                        children: [
                          const Text('Current leagues participating in',style: TextStyle(fontWeight: FontWeight.bold),),
                          const SizedBox(height: 10,),
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(child:ClubsLeagues(clubId:widget.user.userId),)),
                        ],
                      ),
                      const SizedBox(height: 10,),
                    ],
                  ),
                ),
                const Text('Accomplishments and trophies',style: TextStyle(fontWeight: FontWeight.bold),),
                const SizedBox(height: 10,),
                Accomplishments(user: widget.user,),
                const SizedBox(height: 20,),
              ],
            ),
          ):SizedBox.shrink(),
        )
      ),
    );
  }
}

class Accomplishments extends StatefulWidget {
  Person user;
  Accomplishments({super.key,required this.user});

  @override
  State<Accomplishments> createState() => _AccomplishmentsState();
}

class _AccomplishmentsState extends State<Accomplishments> {
  String genre1 = '';
  String caption1 = '';
  String location1 = '';
  String url = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Posts> posts = [];
  Newsfeedservice news = Newsfeedservice();
  @override
  void initState() {
    super.initState();
    news = Newsfeedservice();
    getdata();
  }
  void getdata()async{
    await getBestmomments();
    await retrieveUserPosts();
  }
  List<String>postIds=[];
  List<Map<String, dynamic>> dataList2 = [];
  Future<void> getBestmomments()async{
    String Cname= await news.getAccount(widget.user.userId);
    if(Cname=='Professional'){
      QuerySnapshot documentSnapshot = await firestore.collection('Professional')
          .doc(widget.user.userId)
          .collection('moments')
          .get();
      List<QueryDocumentSnapshot> documents=documentSnapshot.docs;
      for(final data in documents) {
        List<dynamic>accomplishments = data['moments'];
        setState(() {
          dataList2.addAll(accomplishments.cast<Map<String ,dynamic>>());
        });
      }
    }else if(Cname=='Club'){
      QuerySnapshot documentSnapshot = await firestore.collection('Clubs')
          .doc(widget.user.userId)
          .collection('accomplishments')
          .get();
      List<QueryDocumentSnapshot> documents=documentSnapshot.docs;
      for(final data in documents) {
        List<dynamic>accomplishments = data['accomplishments'];
        setState(() {
          dataList2.addAll(accomplishments.cast<Map<String ,dynamic>>());
        });
      }
      for(final item in dataList2){
        String postId=item['postId'];
        setState(() {
          postIds.add(postId);
        });
      }
    }else if(Cname=='Fan'){
      QuerySnapshot documentSnapshot = await firestore.collection('Fans')
          .doc(widget.user.userId)
          .collection('moments')
          .get();
      List<QueryDocumentSnapshot> documents=documentSnapshot.docs;
      for(final data in documents) {
        List<dynamic>accomplishments = data['moments'];
        setState(() {
          dataList2.addAll(accomplishments.cast<Map<String ,dynamic>>());
        });
      }
    }
  }
  Future<void> retrieveUserPosts() async {
    List<PostModel>userPosts=await news.getfeed1(postIds: postIds);
    setState(() {
      for(final d in userPosts) {
        if(!postIds.contains(d.postid)) {
          posts.add(Posts(
              postid: d.postid,
              timestamp: d.timestamp,
              location: d.location,
              genre: d.genre,
              captionUrl: d.captionUrl,
              time: d.time,
              time1: d.time1,
              user: widget.user));
        }else{
          userPosts.remove(d);
        }
      }
    });
  }

  int ind=0;
  double radius=23;
  TextEditingController controller=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  Column(
        children: posts.map<Widget>((post){
          return PostLayout(post: post, dataList2: dataList2);
        }).toList(),
      );
  }
}


class PostLayout extends StatefulWidget {
  Posts post;
  List<Map<String,dynamic>>dataList2;
  PostLayout({super.key,required this.post,required this.dataList2});

  @override
  State<PostLayout> createState() => _PostLayoutState();
}

class _PostLayoutState extends State<PostLayout> {
  @override
  void initState() {
    super.initState();
    _pageController1.addListener(_onPageChanged);
  }
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();



  void _onPageChanged() {
    if (_pageController1.page != _pageController2.page) {
      // Set the page of the second PageView to match the first one.
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
  int ind=0;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: widget.dataList2.map<Widget>((item){
            if(item['postId']==widget.post.postid){
              return Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(item['accomplishment']),
              );
            }else{
              return const SizedBox.shrink();
            }
          }).toList(),
        ),
        const SizedBox(height: 5,),
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.003333,
            child: const Divider(
              thickness: 2,
              color: Colors.white60,
            )),
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height:55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomAvatar( radius: 18, imageurl: widget.post.user.url),
              //
              SizedBox(
                height:55,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UsernameDO(
                              username:widget.post.user.url,
                              collectionName:widget.post.user.collectionName,
                              maxSize: 140,
                              width: 160,
                              height: 38,),

                            const SizedBox(
                                height: 40,
                                width: 35,
                                child: Icon(Icons.more_vert)

                            ),]
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.87,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.post.location,
                            style: const TextStyle(fontSize: 14,),),
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

        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.00333,
            child: const Divider(
              thickness: 2,
              color: Colors.white60,
            )),
        SizedBox(
          height: 500,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.post.captionUrl.length,
                controller: _pageController1,
                itemBuilder: (context, index1) {
                  final captionUrl = widget.post.captionUrl[index1];
                  return InkWell(
                    onTap: () {},
                    child: Stack(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Container(
                            color: Colors.black,
                            margin: const EdgeInsets.all(0.5),
                            constraints: BoxConstraints(
                              minHeight: 200.0,
                              maxHeight: 500.0,
                              minWidth: MediaQuery.of(context).size.width,
                            ),
                            child: AspectRatio(
                              aspectRatio: 3 / 4, // Set the desired aspect ratio
                              child: Image.network(
                                captionUrl['url'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle image loading errors

                                  return SizedBox(
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                    child: const Center(
                                      child: SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: CircularProgressIndicator(color: Colors.white),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onPageChanged: (int index) {
                  setState(() {
                    ind = index;
                  });
                },
              ),
              widget.post.captionUrl.length>1? Align(
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
              ):const SizedBox(height: 0,width: 0,)
            ],
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
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child:  SizedBox(
                    height: 20,
                    child: PageView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:widget.post.captionUrl.length,
                        controller: _pageController2,
                        itemBuilder: (context, index) {
                          final captionUrl = widget.post.captionUrl[index];
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Padding(
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
                                ):const SizedBox.shrink()
                            ),
                          );}),
                  ),
                ),
              ),
            )),
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.01111,
            child: const Divider(
              thickness: 2,
              color: Colors.white60,
            )),
      ],
    );
  }
}
