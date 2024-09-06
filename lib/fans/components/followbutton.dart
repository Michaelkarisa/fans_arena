import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../appid.dart';

class Followbtn extends StatefulWidget {
  String userId;
  Followbtn({super.key,required this.userId});

  @override
  State<Followbtn> createState() => _FollowbtnState();
}

class _FollowbtnState extends State<Followbtn> {
  FollowProvider f=FollowProvider();
  @override
  void initState() {
    super.initState();
    getUserfollow();
  }

  void getUserfollow(){
    f.getFollowing("Fans", "following", FirebaseAuth.instance.currentUser!.uid,widget.userId);
    f.getFollowers("Fans", "followers", FirebaseAuth.instance.currentUser!.uid, widget.userId);
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: f, builder: (BuildContext context, Widget? child) {
      if(f.following){
        return  InkWell(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                        title: const Text('Confirmation'),
                        content: const Text('Do you want to Unfollow this account'),
                        actions: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  child: const Text('No'),
                                  onPressed: () {
                                    Navigator.pop(context); // Dismiss the dialog
                                  },
                                ),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () {
                                    f.togglefollow("Fans", "following","followers", FirebaseAuth.instance.currentUser!.uid,widget.userId);
                                    Navigator.pop(context); // Dismiss the dialog
                                  },
                                ),
                              ]
                          )
                        ]);
                  }
              );
            },
            child: const Text('Following', style: TextStyle(
                color: Colors.blue, fontSize: 17, fontWeight: FontWeight.bold),)

        );
      }else if(!f.following&&!f.follower){
        return InkWell(
            onTap:()=> f.togglefollow("Fans", "following","followers", FirebaseAuth.instance.currentUser!.uid,widget.userId),
            child: const Text('Follow',style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),));
      }else if(f.follower&&!f.following){
        return InkWell(
            onTap:()=> f.togglefollow("Fans", "following","followers", FirebaseAuth.instance.currentUser!.uid,widget.userId),
            child: const Text('Follow Back',style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),));
      }else {
        return const Text('Follow',style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),);
      }
    });
  }
}




class FollowProvider extends ChangeNotifier{
  List<Map<String,dynamic>>followings=[];
  List<Map<String,dynamic>>followers=[];
  bool following=false;
  bool follower=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> stream;
  late Stream<QuerySnapshot> stream1;
  Future<void> getFollowing(String collection,String subcollection,String userId,String userId1)async{
    try {
      stream = _firestore
          .collection(collection)
          .doc(userId)
          .collection(subcollection)
          .snapshots();
      stream.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> allfollowings = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc[subcollection]);
            allfollowings.addAll(chats);
          }
          followings=allfollowings;
          following=followings.any((like) => like['userId'] == userId1);
          notifyListeners();
        } else {
        }
        notifyListeners();
      });
    } catch (e) {
      notifyListeners();
    }
  }
  Future<void> getFollowers(String collection,String subcollection,String userId,String userId1)async{
    try {
      stream1 = _firestore
          .collection(collection)
          .doc(userId)
          .collection(subcollection)
          .snapshots();
      stream1.listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final List<QueryDocumentSnapshot> docs = snapshot.docs;
          List<Map<String, dynamic>> allfollowers = [];
          for (final doc in docs) {
            final List<Map<String,dynamic>> chats = List<Map<String,dynamic>>.from(doc[subcollection]);
            allfollowers.addAll(chats);
          }
          followers=allfollowers;
          follower=followers.any((like) => like['userId'] == userId1);
          notifyListeners();
        } else {
        }
        notifyListeners();
      });
    } catch (e) {
      notifyListeners();
    }
  }
  String colle(String subcollection,String collection){
    String n= subcollection.substring(1);
    if(subcollection=="professionals"){
      return"P$n";
    }else if(subcollection=="clubs"){
      return"C$n";
    }else{
     return collection;
    }
  }
  void togglefollow(String collection,String subcollection,String subcollection1,String userId,String userId1){
    String collection1= colle(subcollection, collection);
    notifyListeners();
    if(!following){
      following=true;
      final Timestamp timestamp = Timestamp.now();
      final like = {'userId': userId1, 'timestamp': timestamp};
      followings.add(like);
      final like1 = {'userId': userId, 'timestamp': timestamp};
      follow(collection1,subcollection1,userId1,userId,isnonet,like1);
      follow(collection,subcollection,userId,userId1,isnonet,like);
      notifyListeners();
      notifyListeners();
      if(subcollection=="following"||subcollection1=="followers"){
        NotifyFirebase().sendfollowingNotifications(userId, userId1);
        Sendnotification(from:userId, to: userId1, message:"is now following you", content: '').sendnotification();
      }else if(collection1=="Professionals"||subcollection1=='professionals'){
        NotifyFirebase().sendnewfanPNotifications(userId, userId1);
        Sendnotification(from:userId, to: userId1, message:"is now your fan", content: '').sendnotification();
      }else{
        NotifyFirebase().sendnewfanNotifications(userId, userId1);
        Sendnotification(from:userId, to: userId1, message:"is now your fan", content: '').sendnotification();
      }
      notifyListeners();
      notifyListeners();
    }else{
      final index1 = followings.indexWhere((like) => like['userId'] == userId1);
      if(index1 != -1) {
        final d=followings.removeWhere((like) => like['userId'] == userId1);
        following=false;
        notifyListeners();
      }
      notifyListeners();
      notifyListeners();
      unfollow(collection1,subcollection1,userId1,userId,isnonet);
      unfollow(collection,subcollection,userId,userId1,isnonet);
      notifyListeners();
      notifyListeners();
      // Sendnotification(from:FirebaseAuth.instance.currentUser!.uid, to: widget.userIde, message: message6, content: '').Deletenotification();
    }
  }
  void follow(String collection,String subcollection,String userId,String userId1,bool isnonet,Map<String,dynamic>like)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .collection(subcollection);
      if(isnonet){
        try {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            List<dynamic> chatsArray = latestDoc[subcollection];
            if (chatsArray.length < 16000) {
              chatsArray.add(like);
              latestDoc.reference.update({subcollection: chatsArray});
              notifyListeners();
            } else {
              likesCollection.add({subcollection: [like]});
              notifyListeners();
            }
          } else {
            likesCollection.add({subcollection: [like]});
            notifyListeners();
          }
          notifyListeners();
        } catch (e) {
          notifyListeners();
        }
        notifyListeners();
      }else {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final QuerySnapshot querySnapshot = await likesCollection.get();
          final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
          if (documents.isNotEmpty) {
            final DocumentSnapshot latestDoc = documents.first;
            final List<Map<String, dynamic>>? chats = (latestDoc[subcollection] as List?)
                ?.cast<Map<String, dynamic>>();
            if (chats != null) {
              if (chats.length < 16000) {
                chats.add(like);
                transaction.update(latestDoc.reference, {subcollection: chats});
              } else {
                likesCollection.add({subcollection: [like]});
              }
            }
          } else {
            likesCollection.add({subcollection: [like]});
          }
          notifyListeners();
        });
        notifyListeners();
      }
      notifyListeners();
  }

  void unfollow(String collection,String subcollection,String userId,String userId1,bool isnonet)async{
    final CollectionReference likesCollection = FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .collection(subcollection);
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    for (final document in documents) {
      final List<dynamic> likesArray = document[subcollection];
      final index = likesArray.indexWhere((like) => like['userId'] == userId1);
      if (index != -1) {
        likesArray.removeAt(index);
        await document.reference.update({subcollection: likesArray});
        notifyListeners();
        return;
      }
    }
    notifyListeners();
  }
}