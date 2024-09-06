import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'followbutton.dart';

class Followbtnclubs extends StatefulWidget {
  String userId;
  Followbtnclubs({super.key,required this.userId});

  @override
  State<Followbtnclubs> createState() => _FollowbtnclubsState();
}

class _FollowbtnclubsState extends State<Followbtnclubs> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  FollowProvider f=FollowProvider();
  bool isnonet=false;
  @override
  void initState() {
    super.initState();
    getUserfollow();
  }

  void getUserfollow(){
    f.getFollowing("Fans", "clubs", FirebaseAuth.instance.currentUser!.uid,widget.userId);
    f.getFollowers("Clubs", "fans",widget.userId, FirebaseAuth.instance.currentUser!.uid);
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
                                        f.togglefollow("Fans", "clubs","fans", FirebaseAuth.instance.currentUser!.uid,widget.userId);
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
              onTap: ()=> f.togglefollow("Fans", "clubs","fans", FirebaseAuth.instance.currentUser!.uid,widget.userId),
                child: const Text('Follow',style: TextStyle(color: Colors.blue,fontSize: 17,fontWeight: FontWeight.bold),));
          }
        });
  }
}
