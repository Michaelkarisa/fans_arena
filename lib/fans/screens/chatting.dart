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


class Chatting extends StatefulWidget {
  Person user;
  String chatId;
  String userId;
  Chatting({super.key,required this.user,required this.chatId,this.userId=''});

  @override
  State<Chatting> createState() => _ChattingState();
}

class _ChattingState extends State<Chatting> {
  int index = 0;
  final TextEditingController message = TextEditingController();
  String userIde = '';
  String url = '';
  String state = '';
  String chatId = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _stream;
VideoControllerProvider v=VideoControllerProvider();
  late Person user;
  void getData()async{
    if(widget.userId.isNotEmpty){
    UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(widget.userId);
    if (appUsage != null) {
      setState(() {
        user=Person(
          url: appUsage.user.url,
          name:appUsage.user.name,
          collectionName: appUsage.user.collectionName,
          location: appUsage.user.location,
          userId:appUsage.user.userId,
        );
      });
    }}else{
      setState(() {
        user=widget.user;
      });
    }
  }
  MessageProvider m=MessageProvider();

  @override
  void initState() {
    super.initState();
    setState(() {
      chatId = widget.chatId;
    });
    v=VideoControllerProvider();
    m.retrieveChats(collection: 'Chats', docId: chatId);
    getData();
    setState(() {
      user=Person(
        url: '',
        name:'',
        collectionName: '',
        location: '',
        userId:'',
      );
    });
    retrieveAllChats();
    retrieveAllChats1();
  }


  @override
  void dispose() {

    super.dispose();
  }

  void createOrSendMessage() async {
    if (chatId.isEmpty) {
      createchat();
    } else {
      final chat=Chat(timestamp: Timestamp.now(), message: message.text, reply:{
        "messageId":replyId,
        "message":message1,
      }, urls: images,
          messageId:'',
          senderId: FirebaseAuth.instance.currentUser!.uid);
      m.sendMessage(collection: 'Chats', docId: chatId, message: chat,);
      setState(() {
        replying=false;
        _showCloseIcon=false;
        message.clear();
        images.clear();
      });

    }
  }

  Future<void> retrieveAllChats() async {
    _stream = _firestore
        .collection('Chats')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .where('senderId', isEqualTo: widget.user.userId)
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
        .where('receiverId', isEqualTo: widget.user.userId)
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

  Future<String> fetchDocuments() async {
    String chatId = '';
    if (widget.chatId.isEmpty) {
      await FirebaseFirestore.instance.collection('Chats')
          .where('senderId', isEqualTo: widget.user.userId)
          .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var document in querySnapshot.docs) {
          if (document.exists) {
            setState(() {
              chatId = document.id;
              chatId = document['chatId'];
            });
          }
        }
      }).catchError((error) {
        print("Error fetching documents: $error");
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            content: Text(error),
          );
        });
      });
      await FirebaseFirestore.instance.collection('Chats').where(
          'senderId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('receiverId', isEqualTo: widget.user.userId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var document in querySnapshot.docs) {
          if (document.exists) {
            setState(() {
              chatId = document.id;
              chatId = document['chatId'];
            });
          }
        }
      }).catchError((error) {
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            content: Text(error),
          );
        });
      });
      return chatId;
    } else {
      return '';
    }
  }

  bool isdelete=false;

  bool _showCloseIcon = false;

  void createchat() async {
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
        'receiverId': widget.user.userId,
        'createdAt': createdAt,
      });
      setState(() {
        chatId = messageId;
      });
      final chat=Chat(timestamp: Timestamp.now(), message: message.text, reply:{
        "messageId":replyId,
        "message":message1,
      }, urls: images,
          messageId:'',
          senderId: FirebaseAuth.instance.currentUser!.uid);
      m.sendMessage(collection: 'Chats', docId: chatId, message: chat,);
      setState(() {
        replying=false;
        _showCloseIcon=false;
        message.clear();
        images.clear();
      });
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  String replyto = '';

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();

    return uniqueId;
  }




  double radius = 23;

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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26,),
            onPressed: () {
              Navigator.of(context).pop();
            }, //to next page},
          ),
          actions: [

            SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.875,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.userId.isEmpty?Row(
                    children: [
                      CustomAvatar(
                           radius: radius, imageurl: widget.user.url),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context){
                                      if(widget.user.collectionName=='Club'){
                                        return AccountclubViewer(user: widget.user, index: 0);
                                      }else if(widget.user.collectionName=='Professional'){
                                        return AccountprofilePviewer(user: widget.user, index: 0);
                                      }else{
                                        return Accountfanviewer(user:widget.user, index: 0);
                                      }
                                    }
                                ),
                              ); //
                            },
                            child: UsernameDO(
                              username: widget.user.name,
                              collectionName: widget.user.collectionName,
                              maxSize:140,
                              width: 160,
                              height: 38,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      )
                    ],
                  ):CustomUsernameD0Avatar(userId: widget.userId, style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ), radius: radius, maxsize:140, height: 38, width: 160),

                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.3625,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        PopupMenuButton<String>(
                          position: PopupMenuPosition.under,
                          onSelected: (value) {
                            if (value == '1') {
                              Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context){
                                      if(user.collectionName=='Club'){
                                        return AccountclubViewer(user: user, index: 0);
                                      }else if(user.collectionName=='Professional'){
                                        return AccountprofilePviewer(user: user, index: 0);
                                      }else{
                                        return Accountfanviewer(user: user, index: 0);
                                      }
                                    }
                                ),
                              );
                            } else if (value == '2') {

                            } else if (value == '3') {

                            }
                          },
                          itemBuilder: (BuildContext context) {
                            return [
                              const PopupMenuItem<String>(
                                value: '1',
                                child: Text('View profile'),
                              ),
                              const PopupMenuItem<String>(
                                value: '2',
                                child: Text('Report'),
                              ),
                              const PopupMenuItem<String>(
                                value: '3',
                                child: Text('block'),
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
        body: Padding(
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
                                                m.deleteChat(collection:'Chats', docId:chatId, message: chat,);
                                                Navigator.pop(context);}, child: const Text('delete'))
                                            ],
                                          )
                                        ],);
                                      });},
                                    child: MessageWidget(message:chat,
                                      docId:chatId,
                                      group: false, color:Colors.teal,
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
                                      set: (){
                                        int index=m.messages.indexWhere((element) => element.messageId==chat1.messageId);
                                        m.scrollController.animateTo(
                                          m.scrollController.position.maxScrollExtent*((index/m.messages.length)+0.09),
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeOut,
                                        );
                                      },
                                      color1: Colors.blueGrey,
                                    ),
                                  );
                            } else if (chat.senderId!=FirebaseAuth.instance.currentUser!.uid) {
                              return MessageWidget(message:chat,
                                docId: chatId,
                                group: false, color:Colors.blueGrey,
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
                                }, message1: chat1,
                                set: (){
                                  int  index=m.messages.indexWhere((element) => element.messageId==chat1.messageId);
                                  m.scrollController.animateTo(
                                    m.scrollController.position.maxScrollExtent*((index/m.messages.length)+0.09),
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                  );
                                },
                                color1: Colors.teal,
                              );}
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
                                            child: const SizedBox(
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
                            padding: const EdgeInsets.only(left: 8, right: 3),
                            child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.7375,
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
                                    borderSide: const BorderSide(width: 1,
                                        color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(width: 1,
                                        color: Colors.grey),
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
                              child:  ClipRRect(
                                borderRadius: BorderRadius.circular(40),
                                child: SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: _showCloseIcon||images.isNotEmpty  ? FloatingActionButton(
                                    backgroundColor: Colors.blueGrey,
                                    onPressed: () {
                                      createOrSendMessage();
                                      setState(() {
                                        replying=false;
                                      });
                                    },
                                    child: const Icon(Icons.send),
                                  ) : FloatingActionButton(
                                    backgroundColor: Colors.blueGrey,
                                    onPressed: () {

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


class ViewFile extends StatefulWidget {
  List<Map<String,dynamic>>urls;
  String url;
   ViewFile({super.key,required this.urls,this.url=""});

  @override
  State<ViewFile> createState() => _ViewFileState();
}

class _ViewFileState extends State<ViewFile> {
  PageController c=PageController();
  @override
  void initState() {
    super.initState();
    if(widget.url.isNotEmpty){
      int page=widget.urls.indexWhere((u)=>u["url1"]==widget.url||u["url"]==widget.url);
      c=PageController(initialPage: page);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.white,size: 30,),
          onPressed: () {
            Navigator.of(context).pop();
          },//to next page},
        ),
        title: const Text('View Image',style: TextStyle(color: Colors.white),),
      ),
      body: PageView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: widget.urls.length,
          controller: c,
          itemBuilder: (context,index){
        return Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height:MediaQuery.of(context).size.height,
          child: Image.file(
                File(widget.urls[index]['url']),
            errorBuilder: (context, Object error, StackTrace? stackTrace)=> CachedNetworkImage(
              imageUrl: widget.urls[index]['url1'],
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
              errorWidget: (context, url, error) => const Center(child: Icon(Icons.error, color: Colors.white, size: 40)),
            ),
            fit: BoxFit.contain,
            ),
        );
      }),
    );
  }
}

class MessageTime extends StatelessWidget {
  Timestamp time;
  MessageTime({super.key,required this.time});

  @override
  Widget build(BuildContext context) {
    String hours = DateFormat('HH').format(time.toDate());
    String minutes = DateFormat('mm').format(time.toDate());
    String t = DateFormat('a').format(time.toDate());
    return   Text('$hours:$minutes $t', style: const TextStyle(color: Colors.white, fontSize: 11));
  }
}
class LatestTime extends StatefulWidget {
  String chatId;
  String collection;
  LatestTime({super.key,
    required this.chatId,
    required this.collection});

  @override
  State<LatestTime> createState() => _LatestTimeState();
}

class _LatestTimeState extends State<LatestTime> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(widget.collection)
            .doc(widget.chatId)
            .collection('chat')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Text('');
          } else {
            final List<QueryDocumentSnapshot> likeDocuments = snapshot
                .data!.docs;
            List<Map<String, dynamic>> allLikes = [];
            for (final document in likeDocuments) {
              final List<dynamic> likesArray = document['chats'];
              allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
            }
            if(allLikes.isNotEmpty) {
              allLikes.sort((b, a) {
                Timestamp time1 = a['timestamp'];
                Timestamp time2 = b['timestamp'];
                DateTime date=time1.toDate();
                DateTime date1=time2.toDate();
                DateTime adate= DateTime(date.year, date.month, date.day,date.hour,date.minute,date.second,date.millisecond,date.microsecond);
                DateTime bdate= DateTime(date1.year, date1.month, date1.day,date1.hour,date1.minute,date1.second,date1.millisecond,date1.microsecond);
                return adate.compareTo(bdate);
              });

              Timestamp createdAt= allLikes[0]['timestamp'];
              DateTime createdDateTime = createdAt.toDate();
              DateTime now = DateTime.now();
              Duration difference = now.difference(createdDateTime);
              String formattedTime = '';
              String hours = DateFormat('HH').format(createdAt.toDate());
              String minutes = DateFormat('mm').format(createdAt.toDate());
              String t = DateFormat('a').format(createdAt.toDate());
              if (difference.inDays < 1) {
                formattedTime = '$hours:$minutes $t';
              } else if (difference.inDays > 1&&difference.inDays < 3) {
                formattedTime = 'yesterday';
              } else {
                formattedTime = DateFormat('d MMM').format(createdDateTime);
              }
              return Text(formattedTime,
                style: const TextStyle(color: Colors.black, fontSize: 12),);
            }else{
              return const Text('');
            }
          }});
  }
}