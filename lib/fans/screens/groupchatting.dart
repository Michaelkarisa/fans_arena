import 'package:fans_arena/clubs/screens/eventsclubs.dart';
import 'package:fans_arena/fans/data/videocontroller.dart';
import 'package:fans_arena/fans/screens/groupdetails.dart';
import 'package:fans_arena/main.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:grouped_list/grouped_list.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../../appid.dart';
import '../../clubs/screens/lineupcreation.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'chatting.dart';
import 'messages.dart';

class Groupchatting extends StatefulWidget {
  final String groupId;
  final String url;
  final String username;
  const Groupchatting({super.key,required this.groupId,required this.url,required this.username});

  @override
  State<Groupchatting> createState() => _GroupchattingState();
}

class _GroupchattingState extends State<Groupchatting> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController message = TextEditingController();
  MessageProvider m=MessageProvider();
  String groupname='';
  String url='';
  VideoControllerProvider v=VideoControllerProvider();
  @override
  void initState() {
    super.initState();
    v=VideoControllerProvider();
    m.retrieveChats(collection: 'Groups', docId: widget.groupId);
  }

  List<Map<String, dynamic>> allLikes = [];
  bool isdelete=false;

  @override
  void dispose() {
    super.dispose();
  }


  String replyto = '';
  final ScrollController _scrollController = ScrollController();
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();

    return uniqueId;
  }
String url1='';


  Future<void> exitGroup() async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Groups');
    final QuerySnapshot querySnapshot = await likesCollection.where('groupId',isEqualTo: widget.groupId).get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['members'];
      final index = likesArray.indexWhere((like) => like['userId'] == FirebaseAuth.instance.currentUser!.uid);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'members': likesArray});
        return;
      }
    }
  }

  Future<void> deleteChat(String postId, String messageId) async {
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection('Groups')
        .doc(postId)
        .collection('chat');
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document['chats'];
      final index = likesArray.indexWhere((like) => like['messageId'] == messageId);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({'chats': likesArray});
        return;
      }
    }
  }

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
  bool _showCloseIcon = false;
  double radius=15;
  bool replying=false;
  String  replyId='';
  String message1='';
  Map<String, dynamic>reply={};
  String urlR='';
  String userId="";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[400],
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,color: Colors.white,size: 33,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          actions: [
            SizedBox(
              width: MediaQuery.of(context).size.width*0.875,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: (){
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context)=>  Groupdetails(groupId: widget.groupId, username: widget.username,),
                        ),
                      );
                    },
                    child: widget.username.isEmpty? CustomNameAvatarL(userId: widget.groupId,radius: radius, style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.normal,
                    ), maxsize: 160,):Row(
                      children: [
                        CustomAvatar(imageurl: widget.url, radius: radius),
                        CustomName(username: widget.username, maxsize: 160, style: const TextStyle(color: Colors.white,fontSize: 18))
                      ],
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.3625,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        PopupMenuButton<String>(
                          position:PopupMenuPosition.under,
                          onSelected: (value) {
                            if(value=='1'){
                              Navigator.push(context,
                                MaterialPageRoute(builder: (context)=>  Groupdetails(groupId: widget.groupId, username: widget.username,),
                                ),
                              );
                            }else if(value=='2'){
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  content:Text('Do you want to Exit ${'"${widget.username}"'} group?') ,
                                  actions: [
                                    Row(
                                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton(onPressed: (){
                                          Navigator.of(context,rootNavigator: true).pop();
                                        }, child: const Text('Cancel')),
                                        TextButton(onPressed: ()async{
                                         await exitGroup();
                                         Navigator.of(context,rootNavigator: true).pop();
                                        }, child: const Text('Exit')),
                                      ],
                                    )
                                  ],
                                );
                              });
                            }else if(value=='3'){

                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: '1',
                                child: Text('Group details'),
                              ),
                              const PopupMenuItem<String>(
                                value: '2',
                                child: Text('Exit Group'),
                              ),
                              const PopupMenuItem<String>(
                                value: '3',
                                child: Text('Mute notifications'),
                              ),
                            ];
                          },
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            )
          ],

        ),
        body:Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AnimatedBuilder(
                    animation: m,
                    builder: (BuildContext context, Widget? child) {
                      return Align(
                        alignment: Alignment.topCenter,
                        child:GroupedListView<Chat, String>(
                          controller: m.scrollController,
                          reverse: false,
                          elements:m.messages,
                          groupBy: (element) {
                            DateTime date = element.timestamp.toDate();
                            return DateTime(date.year, date.month, date.day,).toString();
                          },
                          groupHeaderBuilder: (Chat message) {
                            DateTime date = message.timestamp.toDate();
                            final now = DateTime.now();
                            if (date.year < now.year) {
                              final m=month(date);
                              return Center(child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            width: 1,
                                            color: Colors.grey
                                        )
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                      child: Text('${date.day} $m ${date.year}'),
                                    )),
                              ));
                            } else if (date.year == now.year && date.month < now.month || date.month == now.month&& date.day < now.day - 7) {
                              final m=month(date);
                              return Center(
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                              )
                                          ),
                                          child: Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                              child: Text('${date.day} $m ${date.year}')))));
                            } else if (date.year == now.year && date.month == now.month && date.day < now.day - 1) {
                              final weekday=weekDay(date);
                              return Center(  child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.grey
                                          )
                                      ),
                                      child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                          child:Text(weekday)))));
                            } else if (date.year == now.year && date.month == now.month && date.day < now.day) {
                              return Center(
                                  child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                              )
                                          ),
                                          child: const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                              child: Text('yesterday')))));
                            } else
                            if (date.year == now.year && date.month==now.month && date.day == now.day) {
                              return Center(  child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                              width: 1,
                                              color: Colors.grey
                                          )
                                      ),
                                      child: const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 4,horizontal: 6),
                                          child: Text('today')))));
                            } else {
                              return const Center(  child: Text(''));
                            }
                          },
                          groupSeparatorBuilder: (String value) {
                            return Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                          itemBuilder: (context, Chat chat) {
                            Chat chat1=Chat(
                              timestamp: Timestamp.now(),
                              message: '',
                              reply:{},
                              urls: [],
                              messageId:'',
                              senderId:'',
                            );
                            if(chat.reply["messageId"].toString().isNotEmpty){
                              chat1=m.messages.firstWhere((element) => element.messageId==chat.reply['messageId']);
                            }
                            if (chat.senderId == FirebaseAuth.instance.currentUser!.uid) {
                              return InkWell(
                                onLongPress: (){
                                  showDialog(context: context, builder:(context){
                                    return AlertDialog(content: const SizedBox(
                                      height: 50,
                                      child: Column(
                                        children: [
                                          Text('Do you wish to delete this message?'),
                                          Text('By deleting this message, the message will no longer be available to you or the other user.')
                                        ],
                                      ),
                                    ),actions: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(onPressed: (){
                                            Navigator.pop(context);
                                          }, child: const Text('cancel')),
                                          TextButton(onPressed: (){
                                            m.deleteChat(collection:'Groups', docId: widget.groupId, message: chat,);
                                            Navigator.pop(context);}, child: const Text('delete'))
                                        ],
                                      )
                                    ],);
                                  });},
                                child: MessageWidget(message:chat,
                                  docId: widget.groupId,
                                  group: true, color:Colors.teal,
                                  reply: (String userId1) {
                                    setState(() {
                                      userId=userId1;
                                      replying = true;
                                      replyId = chat.messageId;
                                      message1 = chat.message;
                                      for (final item in m.messages) {
                                        if (item.messageId == chat.messageId) {
                                          List<Map<String,dynamic>> urlss = List<Map<String,dynamic>>.from(item.urls);
                                          if(urlss.isNotEmpty){
                                            urlR=urlss.first['url1'];
                                          }else{
                                            urlR='';
                                          }
                                        }
                                      }
                                    });
                                  },
                                  message1: chat1,
                                  color1: Colors.blueGrey, set: () {
                                    int  index=m.messages.indexWhere((element) => element.messageId==chat1.messageId);
                                    m.scrollController.animateTo(
                                      m.scrollController.position.maxScrollExtent*((index/m.messages.length)+0.09),
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOut,
                                    );
                                  },),
                              );
                            } else if (chat.senderId!=FirebaseAuth.instance.currentUser!.uid) {
                              return MessageWidget(message:chat,
                                docId:widget.groupId,
                                group: true, color:Colors.blueGrey,
                                reply: (String userId1) {
                                  setState(() {
                                    userId=userId1;
                                    replying = true;
                                    replyId = chat.messageId;
                                    for (final item in m.messages) {
                                      if (item.messageId == chat.messageId) {
                                        message1 = chat.message;
                                        List<Map<String,dynamic>> urlss = List<Map<String,dynamic>>.from(item.urls);
                                        if(urlss.isNotEmpty){
                                          urlR=urlss.first['url1'];
                                        }else{
                                          urlR='';
                                        }
                                      }
                                    }
                                  });
                                }, message1: chat1, color1: Colors.teal, set: () {
                                  int  index=m.messages.indexWhere((element) => element.messageId==chat1.messageId);
                                  m.scrollController.animateTo(
                                    m.scrollController.position.maxScrollExtent*((index/m.messages.length)+0.09),
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                  );
                                },);}
                            return Container();
                          },
                          order: GroupedListOrder.ASC,
                        ),
                      );}
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Container(
                  color: Colors.transparent,
                  margin:const EdgeInsets.only(bottom: 8,right: 8,left: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      images.isNotEmpty?ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          height: 100,
                          decoration: const BoxDecoration(
                              color: Colors.teal,
                          ),
                          width:images.length<4?106*images.length.toDouble(): MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: images.map<Widget>((url) => Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: Stack(
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                bool urlExists = images.any((element) => element['url'] == url['url']);
                                                if (urlExists) {
                                                  message.text = images.firstWhere((element) => element['url'] == url['url'])['message'];
                                                } else {
                                                  images.add({
                                                    'url1':"",
                                                    'url': url['url'],
                                                    'message': message.text,
                                                  });
                                                  message.clear();
                                                }
                                              });
                                            },
                                            child: Image.file(
                                              File(url['url']),
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: InkWell(
                                            onTap: (){
                                              setState((){
                                                images.removeWhere((element) =>
                                              element['url'] == url['url']);
                                              });
                                            },
                                            child:const SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Icon(Icons.clear),
                                            ),
                                          ),
                                        ),

                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: images.any((element) => element['url']==url['url'])? InkWell(
                                            onTap: (){
                                              setState((){
                                                images.removeWhere((element) =>
                                                element['url'] == url['url']);
                                              });
                                            },
                                            child: const SizedBox(
                                              height: 30,
                                              width: 30,
                                              child: Icon(Icons.check,color: Colors.blue,),
                                            ),
                                          ):const SizedBox.shrink(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              ).toList(),
                            ),
                          ),
                        ),
                      ):const SizedBox.shrink(),
                      replying?SizedBox(
                        width: MediaQuery.of(context).size.width*0.92,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width*0.88,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blueGrey[300]!,
                                  border: Border.all(
                                    width: 10,
                                    color: Colors.blueGrey[700]!,
                                  )
                              ),
                              child: InkWell(
                                  onTap: (){
                                    // int index=m.messages.indexOf(chat);
                                    //m._scrollController.jumpTo(1/index);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(left: 10, right: 5),
                                              child:userId==FirebaseAuth.instance.currentUser!.uid?const Text(' You',
                                                style: TextStyle(color: Colors.blue,fontSize: 15,fontWeight: FontWeight.bold),): CustomNameM(
                                                userId: userId,
                                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                                maxsize: 160,
                                              ),
                                            ),
                                            SizedBox(
                                                width: MediaQuery.of(context).size.width*0.65,
                                                child: ReplyW(text: message1,color: Colors.white,)),

                                          ],
                                        ),
                                        SizedBox(
                                          width: 55,
                                          height: 55,
                                          child: urlR.isNotEmpty? Padding(
                                            padding: const EdgeInsets.only(right: 0.5),
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                              child: ImageVideo(url: urlR,),
                                            ),
                                          ):const SizedBox.shrink(),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                  onTap: (){
                                    setState(() {
                                      replying=false;
                                      message1="";
                                      replyId="";
                                      urlR="";
                                    });
                                  },
                                  child: Container(
                                      height: 23,
                                      width: 23,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: Colors.blueGrey[700]!,
                                      ),
                                      child: const Icon(Icons.close,color: Colors.white,))),
                            ),
                          ],
                        ),
                      ):const SizedBox.shrink(),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8,right: 3),
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.7375,
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
                                controller: message,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(bottom: 0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                                  ),
                                  focusedBorder:  OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(width: 1, color: Colors.grey),
                                  ),
                                  filled: true,
                                  hintStyle: const TextStyle(color: Colors.black,
                                    fontSize: 16, fontWeight: FontWeight.normal,),
                                  fillColor: Colors.white70,
                                  prefixIcon: IconButton(onPressed: (){
                                    _loadVideos();
                                  },icon: const Icon(Icons.image)),
                                  suffixIcon: const Icon(Icons.emoji_emotions),
                                  hintText: 'Type your message',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _showCloseIcon = value.isNotEmpty;
                                  });
                                },
                                onSubmitted: (String text) {

                                },
                              ),
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: _showCloseIcon||images.isNotEmpty  ? FloatingActionButton(
                                    backgroundColor: Colors.blueGrey,
                                    onPressed: () {
                                      final chat=Chat(timestamp: Timestamp.now(), message: message.text, reply:{
                                        "messageId":replyId,
                                        "message":message1,
                                      }, urls: images,
                                          messageId:'',
                                          senderId: FirebaseAuth.instance.currentUser!.uid);
                                      m.sendMessage(collection: 'Groups', docId: widget.groupId, message: chat,);
                                      setState(() {
                                        replying=false;
                                        _showCloseIcon=false;
                                        message.clear();
                                        images.clear();
                                      });
                                    },
                                    child: const Icon(Icons.send),
                                  ) : FloatingActionButton(
                                    backgroundColor: Colors.blueGrey,
                                    onPressed: () {
                                     setState(() {
                                       replying=false;
                                     });
                                    },
                                    child: const Icon(Icons.mic),
                                  ),
                                ),
                              )
                          ),

                        ],
                      ),
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
  String month(DateTime date){
    if(date.month==DateTime.january){
      return 'january';
    }else if(date.month==DateTime.february){
      return 'February';
    }else if(date.month==DateTime.march){
      return 'March';
    }else if(date.month==DateTime.april){
      return 'April';
    }else if(date.month==DateTime.may){
      return 'May';
    }else if(date.month==DateTime.june){
      return 'June';
    }else if(date.month==DateTime.july){
      return 'July';
    }else if(date.month==DateTime.august){
      return 'August';
    }else if(date.month==DateTime.september){
      return 'September';
    }else if(date.month==DateTime.october){
      return 'October';
    }else if(date.month==DateTime.november){
      return 'November';
    }else if(date.month==DateTime.december){
      return 'December';
    }else{
      return'';
    }}
  String weekDay(DateTime date){
    if(date.weekday==DateTime.monday){
      return 'Monday';
    }else if(date.weekday==DateTime.tuesday){
      return 'Tuesday';
    }else if(date.weekday==DateTime.wednesday){
      return 'Wednesday';
    }else if(date.weekday==DateTime.thursday){
      return 'Thursday';
    }else if(date.weekday==DateTime.friday){
      return 'Friday';
    }else if(date.weekday==DateTime.saturday){
      return 'Saturday';
    }else if(date.weekday==DateTime.sunday){
      return 'Sunday';
    }else{
      return'';
    }
  }

}
class ImageVideoUp extends StatefulWidget {
  List<Map<String,dynamic>> urls;
  String messageId;
  String chatId;
  bool group;
  String senderId;
  ImageVideoUp({Key? key,
    required this.urls,
    required this.senderId,
    required this.chatId,
    required this.messageId,
    required this.group,
  })
      : super(key: key);

  @override
  State<ImageVideoUp> createState() => _ImageVideoUpState();
}

class _ImageVideoUpState extends State<ImageVideoUp> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            color: Colors.grey,
            child: Stack(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width*0.68,
                    child: widget.senderId==FirebaseAuth.instance.currentUser!.uid ? Column(
                      children: widget.urls.map<Widget>((url) =>url['url'].toString().isNotEmpty? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewFile(urls: widget.urls,url: url['url'],),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom:widget.urls.last['url']==url['url']? 0:4),
                          child:url['url1'].toString().isNotEmpty?ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SizedBox(
                              height: 270,
                              width: MediaQuery.of(context).size.width*0.68,
                              child: CachedNetworkImage(
                                imageUrl: url['url1'],
                                fit: BoxFit.fill,
                                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white, size: 40)),
                              ),
                            ),
                          ):ImageVW(url: url['url'], url1: url['url1'], chatId: widget.chatId, messageId: widget.messageId, group: widget.group, senderId: widget.senderId,)
                        ),
                      ):const SizedBox.shrink(),
                      ).toList(),
                    )
                        : Column(
                      children: widget.urls.map<Widget>((url) =>url['url1'].toString().isNotEmpty||url['url1']!=null? InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ViewFile(urls: widget.urls,url: url['url1'],),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom:widget.urls.last['url1']==url['url1']? 0:4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: SizedBox(
                              height: 270,
                              width: MediaQuery.of(context).size.width*0.68,
                              child: CachedNetworkImage(
                                imageUrl: url['url1'],
                                fit: BoxFit.fill,
                                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                  child: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white, size: 40)),
                              ),
                            ),
                          ),
                        ),
                      ):const SizedBox.shrink(),
                      ).toList(),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
class ImageVideo extends StatefulWidget {
  String url;
  ImageVideo({Key? key,
    required this.url,
  })
      : super(key: key);

  @override
  State<ImageVideo> createState() => _ImageVideoState();
}

class _ImageVideoState extends State<ImageVideo> {



  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Container(
        color: Colors.grey,
        child: SizedBox(
          height: 55,
          width: 55,
          child: CachedNetworkImage(
            imageUrl: widget.url,
            fit: BoxFit.fill,
            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white, size: 40)),
          ),
        ),
          ));
  }
}
class ImageVW extends StatefulWidget {
  String url;
  String url1;
  String chatId;
  String messageId;
  bool group;
  String senderId;
   ImageVW({super.key,
     required this.url,
     required this.url1,
     required this.chatId,
     required this.messageId,
     required this.group,
     required this.senderId,
   });

  @override
  State<ImageVW> createState() => _ImageVWState();
}

class _ImageVWState extends State<ImageVW> {
  MessageProvider v = MessageProvider();
  @override
  void initState() {
    super.initState();
    if(widget.senderId==FirebaseAuth.instance.currentUser!.uid&&!isnonet) {
      upLoad();
    }
  }

  void upLoad()async{
    final file =File(widget.url);
    bool fileExists = await file.exists();
    try {
      if (widget.url.isNotEmpty && widget.url1.isEmpty&&fileExists&&!isnonet) {
        v.showToastMessage('auto upload');
       await v.addUrl(messageId: widget.messageId,
           url: widget.url,
            chatId: widget.chatId,
           collection: widget.group ? 'Groups' : 'Chats');
      }
    }catch(e){
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
          );
        },
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        height: 270,
        width: MediaQuery.of(context).size.width*0.68,
        child: Stack(
          children: [
            SizedBox(
              height: 270,
              width: MediaQuery.of(context).size.width*0.68,
              child: Image.file(
                File(widget.url),
                fit: BoxFit.fill,
                errorBuilder: (context, Object error, StackTrace? stackTrace) => const Center(child: Icon(Icons.error, color: Colors.white, size: 40)),
              ),
            ),
            widget.url1.isEmpty ? AnimatedBuilder(
              animation: v,
              builder: (BuildContext context, Widget? child) {
                return Align(
                  alignment: Alignment.bottomRight,
                  child: InkWell(
                    onTap: () async {
                      await v.addUrl(messageId: widget.messageId,
                          url:widget.url,
                          chatId: widget.chatId, collection:widget.group? 'Groups':'Chats');
                      v.showToastMessage('button clicked');
                    },
                    child: Container(
                      height: 45,
                      width: 45,
                      margin: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          const Center(child: Icon(Icons.upload_sharp, color: Colors.white, size: 26)),
                          Center(
                            child: SizedBox(
                              height: 42,
                              width: 42,
                              child: CircularProgressIndicator(
                                value:v.progress,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
                : const SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
