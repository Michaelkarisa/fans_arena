import 'dart:async';
import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/screens/viewyourstory.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:story_view/story_view.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import 'accountfanviewer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:grouped_list/grouped_list.dart';
import '../../clubs/data/lineup.dart';
import '../../clubs/screens/accountclubviewer.dart';
import '../../main.dart';
import '../../professionals/screens/accountprofilepviewer.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../bloc/usernamedisplay.dart';
import '../data/newsfeedmodel.dart';
import '../data/videocontroller.dart';
import 'accountfanviewer.dart';
import 'groupchatting.dart';
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'messages.dart';

class StoryPage extends StatefulWidget {
  Story story;
  List<Story>stories;
  StoryPage({super.key,
    required this.story,
    required this.stories});
  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  PageController controller=PageController();

  @override
  void initState() {
    super.initState();
    final initialpage=widget.stories.indexOf(widget.story);
    controller = PageController(initialPage: initialpage);

  }
  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }
  bool keyboard=false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PageView.builder(
        controller: controller,
        itemCount: widget.stories.length,
        itemBuilder: (BuildContext context, int index) {
          final story=widget.stories[index];
          return StoryViewScreen(
            userId: story.user.userId,
            story: story.story,
            contoller: controller,
            stories: widget.stories,
            story1: story, keyb: keyboard, setkeyb: (bool k ) {
            setState(() {
              keyboard=k;
            });
          },);
        },

      ),
    );
  }
}


class StoryViewScreen extends StatefulWidget {
  bool keyb;
  Story story1;
  List<Story>stories;
  PageController contoller;
  String userId;
  List<Map<String, dynamic>> story;
  void Function(bool) setkeyb;
  StoryViewScreen({super.key,
    required this.userId,
    required this.story,
    required this.contoller,
    required this.stories,
    required this.story1,
    required this.keyb,
    required this.setkeyb,
  });

  @override
  _StoryViewScreenState createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {

  final storyItems=<StoryItem>[];
  final StoryController _storyController = StoryController();
  void addStory() async {
    try {
      for (final story in widget.story) {
        String image=story['url1'];
        String video=story['url'];
        String cap = story['caption'];
        captions.add(cap);
        if(image.isEmpty) {
          int duration = story['duration']??30;
          storyItems.add(StoryItem.pageVideo(
            video,
            duration: Duration(seconds: duration),
            controller: _storyController,
          ));
        }else{
          storyItems.add(StoryItem.pageImage(
            duration: const Duration(seconds: 6),
            controller: _storyController,
            url: image,
          ));
        }
      }
      setState(() {
        isloading = false;
      });
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(e.toString()),
        );
      });
      print("Error adding story: $e");
    }finally{
      setState(() {
        isloading = false;
      });
    }
  }
  MessageProvider m=MessageProvider();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _stream;
  bool isloading=true;
  @override
  void initState() {
    super.initState();
    setState(() {
      isExpanded=widget.keyb;
    });
    Timestamp time=widget.story[0]['timestamp'];
    String hours = DateFormat('HH').format(time.toDate());
    String minutes = DateFormat('mm').format(time.toDate());
    String t = DateFormat('a').format(time.toDate());
    String d=date1(time);
    date="$d at $hours:$minutes $t";
    addStory();
    retrieveAllChats();
    retrieveAllChats1();
  }
  SViewsProvider v= SViewsProvider();

  @override
  void dispose(){
    _storyController.dispose();
    addview();
    super.dispose();
  }

  void createOrSendMessage() async {
    if (chatId.isEmpty) {
      createChat();
    } else {
      final chat=Chat(timestamp: Timestamp.now(), message: message.text, reply:{
        "messageId":widget.story1.story[currentIndex]['storyId'],
        "message":"",
      }, urls: images,
          messageId:'',
          senderId: FirebaseAuth.instance.currentUser!.uid);
      m.sendMessage(collection: 'Chats', docId: chatId, message: chat,);
      setState(() {
        _showCloseIcon=false;
        message.clear();
        images.clear();
      });

    }
  }
  String chatId = '';
  Future<void> retrieveAllChats() async {
    _stream = _firestore
        .collection('Chats')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('senderId', isEqualTo: widget.story1.user.userId)
        .snapshots();
    _stream.listen((snapshot) {
      final chatDocuments = snapshot.docs;
      for (var document in chatDocuments) {
        if (document.exists) {
          final documentData = document.data() as Map<String, dynamic>;
          chatId = documentData['chatId'];
        }
      }
      setState(() {});
    });
  }

  void retrieveAllChats1() {
    _stream = _firestore
        .collection('Chats')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('receiverId', isEqualTo: widget.story1.user.userId)
        .snapshots();
    _stream.listen((snapshot) {
      final chatDocuments = snapshot.docs;
      for (var document in chatDocuments) {
        if (document.exists) {
          final documentData = document.data() as Map<String, dynamic>;
          chatId = documentData['chatId'];
        }
      }
      setState(() {});
    });
  }



  bool isdelete=false;

  bool _showCloseIcon = false;

  void createChat() async {
    try {
      final messageCollection = FirebaseFirestore.instance.collection('Chats');
      String messageId = messageCollection
          .doc()
          .id;
      Timestamp createdAt = Timestamp.now();
      messageCollection
          .doc(messageId)
          .set({
        'chatId': messageId,
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'receiverId': widget.story1.user.userId,
        'createdAt': createdAt,
      });
      setState(() {
        chatId = messageId;
      });
      final chat=Chat(timestamp: Timestamp.now(), message: message.text, reply:{
        "messageId":widget.story1.story[currentIndex]['storyId'],
        "message":"",
      }, urls: images,
          messageId:'',
          senderId: FirebaseAuth.instance.currentUser!.uid);
      m.sendMessage(collection: 'Chats', docId: chatId, message: chat,);
      setState(() {
        _showCloseIcon=false;
        message.clear();
        images.clear();
      });
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  int currentIndex = 0;
  Future<void> _loadVideos() async {
    final List<XFile> videos = await ImagePicker().pickMultiImage(requestFullMetadata: true);
    if (videos != null) {
      for(final video in videos){
        final File loadedVideo = File(video.path);
        setState(() {
          images.add({
            'url': loadedVideo.path,
            'url1': '',
          });
        });
      }}
  }


  List<Map<String,dynamic>>images=[];
  void handleCompleted()async{
    await setK();
    widget.contoller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn);
    final currentIndex=widget.stories.indexOf(widget.story1);
    final isLastPage=widget.stories.length-1==currentIndex;
    if(isLastPage){
      Navigator.pop(context);
      v.addView(widget.userId, widget.story[currentIndex-1]['storyId'],date2,true);
    }
  }
  Future<void>setK()async{
    widget.setkeyb(isExpanded);
  }
  void handleCompleted1()async{
    await setK();
    widget.contoller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn);
    final currentIndex=widget.stories.indexOf(widget.story1);
    final isLastPage=widget.stories.length-1==currentIndex;
    if(isLastPage){
      v.addView(widget.userId, widget.story[currentIndex-1]['storyId'],date2,true);
      Navigator.pop(context);
    }
  }

  String date1(Timestamp createdAt){
    DateTime createdDateTime = createdAt.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(createdDateTime);
    if (difference.inSeconds == 1) {
      return 'now';
    } else if (difference.inSeconds < 60) {
      return  '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes == 1) {
      return  '${difference.inMinutes} minute ago';
    } else if (difference.inMinutes < 60) {
      return  '${difference.inMinutes} minutes ago';
    } else if (difference.inHours == 1) {
      return  '${difference.inHours} hour ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return  '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      return  '${difference.inDays} days ago';
    } else if (difference.inDays ==7) {
      return  '${difference.inDays ~/ 7} weeks ago';
    } else {
      return  DateFormat('d MMM').format(createdDateTime);
    }
  }
  bool isExpanded=false;
  final TextEditingController _textController=TextEditingController();
  final TextEditingController  message=TextEditingController();
  String date='';


  List<String> captions=[];
  String caption='';

  int count=0;
  List<int> track=[];
  DateTime date2=DateTime.now();
  void addview(){
  v.addView(widget.story1.StoryId, widget.story[currentIndex-1]['storyId'],date2,true);
  if(track.last==currentIndex){
     date2=DateTime.now();
      }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            isloading? const Center(child: SizedBox(
                width: 55,
                height: 55,
                child: CircularProgressIndicator(color: Colors.white,strokeWidth: 3,))):GestureDetector(
              onLongPressStart: (d){
                _storyController.pause();
              },onLongPressEnd: (d){
              _storyController.play();
            },
              child: StoryView(
                progressPosition: ProgressPosition.top,
                controller: _storyController,
                storyItems:storyItems,
                repeat: false,
                onVerticalSwipeComplete: (direction){
                  if(direction==Direction.right){
                    handleCompleted();
                  }else if(direction==Direction.down){
                    setState(() {
                      isExpanded=false;
                    });
                  }else if(direction==Direction.left){
                    handleCompleted1();
                  }else if(direction==Direction.up){
                    Navigator.pop(context);
                  }
                },
                onStoryShow: (s,index) {
                  currentIndex=index;
                  track.add(index);
                  if(index==0){
                    setState(() {
                      count=count+1;
                    });
                  }
                  if(count>1&&index==0){
                    handleCompleted1();
                  }
                  if(index>0){
                    addview();
                    setState(() {
                      count=0;
                      Timestamp time=widget.story[index]['timestamp'];
                      String hours = DateFormat('HH').format(time.toDate());
                      String minutes = DateFormat('mm').format(time.toDate());
                      String t = DateFormat('a').format(time.toDate());
                      String d=date1(time);
                      date="$d at $hours:$minutes $t";
                    });}
                  //addview();
                },
                onComplete: handleCompleted,
              ),
            ),
            Align(
              alignment: const Alignment(0.0,0.82),
              child: Text(captions[currentIndex],style: const TextStyle(color: Colors.white),),
            ),
            widget.story1.user.collectionName=="Club"||collectionNamefor=="Club"?SizedBox.shrink():Align(
                alignment: const Alignment(0.0,0.97),
                child:FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width:isExpanded? MediaQuery.of(context).size.width *0.9:MediaQuery.of(context).size.width *0.2,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AnimatedContainer(
                                width:isExpanded? MediaQuery.of(context).size.width *0.75:MediaQuery.of(context).size.width *0.2,
                                duration: const Duration(milliseconds: 500),
                                child:KeyboardVisibility(
                                  onChanged: (bool visible ) {
                                    setState(() {
                                      if(visible) {
                                        isExpanded =true;
                                        _storyController.pause();
                                      }else if(!visible){
                                        isExpanded =false;
                                        _storyController.play();
                                      }
                                    });
                                  },
                                  child:isExpanded? TextFormField(
                                      scrollPadding: const EdgeInsets.only(bottom: 1),
                                      scrollPhysics: const ScrollPhysics(),
                                      expands: false,
                                      maxLines: 4,
                                      controller:message,
                                      minLines: 1,
                                      textInputAction: TextInputAction.newline,
                                      cursorColor: Colors.black,
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration:InputDecoration(
                                        contentPadding: const EdgeInsets.only(left: 15,bottom: 1,top: 1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          borderSide: const BorderSide(width: 1, color: Colors.grey),
                                        ),
                                        focusedBorder:  OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          borderSide: const BorderSide(width: 1, color: Colors.grey),
                                        ),
                                        prefixIcon:IconButton(onPressed: (){},icon: const Icon(Icons.image)),
                                        suffixIcon:const Icon(Icons.emoji_emotions),
                                        filled: true,
                                        focusColor: Colors.grey,
                                        hoverColor: Colors.grey,
                                        fillColor: Colors.white,
                                        hintText: 'reply',
                                      )
                                  ):TextFormField(
                                      scrollPadding: const EdgeInsets.only(bottom: 1),
                                      scrollPhysics: const ScrollPhysics(),
                                      expands: false,
                                      onTap: (){
                                        setState(() {
                                          isExpanded=true;
                                        });
                                      },
                                      textInputAction: TextInputAction.newline,
                                      cursorColor: Colors.black,
                                      textAlignVertical: TextAlignVertical.center,
                                      decoration:InputDecoration(
                                        contentPadding: const EdgeInsets.only(left: 15,bottom: 1,top: 1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          borderSide: const BorderSide(width: 1, color: Colors.grey),
                                        ),
                                        focusedBorder:  OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                          borderSide: const BorderSide(width: 1, color: Colors.grey),
                                        ),
                                        filled: true,
                                        focusColor: Colors.grey,
                                        hoverColor: Colors.grey,
                                        fillColor: Colors.white,
                                        hintText: 'reply',
                                      )
                                  ),
                                )
                            ),
                          ),
                        ),
                        isExpanded? Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: SizedBox(
                              height: 50,
                              width: 50,
                              child: FloatingActionButton(
                                backgroundColor: Colors.blueGrey,
                                onPressed:(){} ,child: const Icon(Icons.send,color: Colors.white,),),),
                          ),
                        ):const SizedBox.shrink()
                      ],
                    ),
                  ),
                )
            ),
            Align(
              alignment: Alignment.topCenter,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16,vertical: 15),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close,color: Colors.white,size: 30,),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },//to next page},
                      ),
                      CustomAvatar(radius: 22, imageurl: widget.story1.user.url),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width*0.75,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  UsernameDO(
                                    username: widget.story1.user.name,
                                    collectionName: widget.story1.user.collectionName,
                                    maxSize:140,
                                    width: 160,
                                    height: 38,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(date,style: const TextStyle(fontSize: 13,color: Colors.white),)
                                ],
                              ),
                              SizedBox(
                                width: 30,
                                child: PopupMenuButton<String>(
                                  onOpened:()=>_storyController.pause(),
                                  onCanceled:()=>_storyController.play(),
                                  color: Colors.white,
                                  iconColor: Colors.white,
                                  position: PopupMenuPosition.under,
                                  onSelected: (value) {
                                    if(value=='3'){
                                      Navigator.push(context,  MaterialPageRoute(
                                          builder: (context){
                                            if(widget.story1.user.collectionName=='Club'){
                                              return AccountclubViewer(user: widget.story1.user, index: 0);
                                            }else if(widget.story1.user.collectionName=='Professional'){
                                              return AccountprofilePviewer(user:widget.story1.user, index: 0);
                                            }else{
                                              return Accountfanviewer(user:widget.story1.user, index: 0);
                                            }
                                          }
                                      ),);
                                      }else{

                                    }},
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem<String>(
                                        value: '1',
                                        child: Text('Report'),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: '3',
                                        child: Text('View Profile'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
