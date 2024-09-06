import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'followbutton.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class Followbtnprofe extends StatefulWidget {
  String userId;
  Followbtnprofe({super.key,required this.userId});

  @override
  State<Followbtnprofe> createState() => _FollowbtnprofeState();
}

class _FollowbtnprofeState extends State<Followbtnprofe> {
  FollowProvider f=FollowProvider();
bool isnonet=false;
  @override
  void initState() {
    super.initState();
    getUserfollow();
  }

  void getUserfollow(){
    f.getFollowing("Fans", "professionals", FirebaseAuth.instance.currentUser!.uid,widget.userId);
    f.getFollowers("Professionals", "fans",widget.userId, FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: f,
        builder: (BuildContext context, Widget? child) {
      if(f.following&&f.follower){
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
                                    f.togglefollow("Fans", "professionals","fans", FirebaseAuth.instance.currentUser!.uid,widget.userId);
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
      }else {
        return InkWell(
            onTap:()=> f.togglefollow("Fans", "professionals","fans", FirebaseAuth.instance.currentUser!.uid,widget.userId),
            child: const Text('Follow',style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),));
      }
    });
  }
}


