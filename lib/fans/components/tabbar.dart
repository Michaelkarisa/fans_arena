import 'package:fans_arena/fans/screens/groups.dart';
import 'package:fans_arena/fans/screens/messages.dart';
import 'package:fans_arena/joint/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class Tabbar extends StatefulWidget {
  int index;
  Tabbar({super.key,required this.index});

  @override
  State<Tabbar> createState() => _TabbarState();
}

class _TabbarState extends State<Tabbar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    retrieveAllChats();
    retrieveAllChats1();
    retrieveAllGroups();
    _tabController = TabController(length: 2, vsync: this,initialIndex: widget.index);
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _stream;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  void retrieveAllChats() {
    _stream = _firestore
        .collection('Chats')
        .where('receiverId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();

    _stream.listen((snapshot) {
      final chatDocuments = snapshot.docs;
      for (var document in chatDocuments) {
        final documentData = document.data() as Map<String, dynamic>;
        final userId = documentData['senderId'];
        final chatId = documentData['chatId'];
        uniqueUserIds.add(userId);
        uniquechatIds.add(chatId);
      }
      setState(() {}); // Trigger rebuild after data changes
    });
  }

  Set<String> uniqueUserIds = <String>{};
  Set<String> uniquechatIds = <String>{};
  void retrieveAllChats1(){
    _stream = _firestore
        .collection('Chats')
        .where('senderId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .snapshots();

    _stream.listen((snapshot) {
      final chatDocuments = snapshot.docs;
      for (var document in chatDocuments) {
        final documentData = document.data() as Map<String, dynamic>;
        final userId = documentData['receiverId'];
        final chatId = documentData['chatId'];
        uniqueUserIds.add(userId);
        uniquechatIds.add(chatId);
      }
      setState(() {}); // Trigger rebuild after data changes
    });
  }

  Set<String> userGroupIds = {};
  Set<String> groupnames = {};
  Set<String> profileimage = {};
  void retrieveAllGroups() {
    userGroupIds.clear();
    groupnames.clear();
    profileimage.clear();
    _stream = FirebaseFirestore.instance.collection('Groups').snapshots();
    _stream.listen((snapshot) {
      final groupDocuments = snapshot.docs;
      for (final document in groupDocuments) {
        final List<dynamic> membersArray = document['members'] ?? [];
        String groupId = document['groupId'] ?? '';
        String name = document['groupname'] ?? '';
        String url = document['profileimage'] ?? '';
        List<String> userIds = membersArray.whereType<Map<String, dynamic>>().map((member) {
          return member['userId'] as String? ?? '';
        }).where((userId) => userId.isNotEmpty).toList();
        if (userIds.contains(FirebaseAuth.instance.currentUser?.uid)) {
          userGroupIds.add(groupId);
          groupnames.add(name);
          profileimage.add(url);
        }
      }
      setState(() {});
    });
  }

  String y='';
  int chats=0;
  int groups=0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
          appBar: AppBar(
            elevation: 1,
            automaticallyImplyLeading: false,
            title: Text('Message', style: TextStyle(color: Textn),),
            backgroundColor: Appbare,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.03333),
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.03333,
                child: TabBar(

                  controller: _tabController,
                  tabs: <Tab>[
                    Tab(child:Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chats', style: TextStyle(fontSize: 16,color: Colors.black),),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.05,
                            height: MediaQuery.of(context).size.height*0.0222,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:  Center(child: Text("${uniquechatIds.length}",style: const TextStyle(color: Colors.white),)),),
                        ),
                      ],
                    )
                        ),
                    Tab(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Groups', style: TextStyle(fontSize: 16,color: Colors.black),),
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Container(
                            width: MediaQuery.of(context).size.width*0.05,
                            height: MediaQuery.of(context).size.height*0.0222,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child:  Center(child: Text("${userGroupIds.length}",style: const TextStyle(color: Colors.white),)),),
                        ),
                      ],
                    ),

                    ),

                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              Messages(chatIdList: uniquechatIds.toList(), userIdList: uniqueUserIds.toList(),),
               Groups(userGroupIds: userGroupIds.toList(), groupnames: groupnames.toList(), profileimage: profileimage.toList(),),
            ],
          ),
    );
  }
}


