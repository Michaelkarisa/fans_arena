import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/bloc/accountchecker2.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Accountchecker0 extends StatefulWidget {
Person user;
  Accountchecker0({super.key,required this.user});

  @override
  _Accountchecker0State createState() => _Accountchecker0State();
}
class _Accountchecker0State extends State<Accountchecker0> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    } else if(collectionNamefor=='Club'||widget.user.userId==FirebaseAuth.instance.currentUser!.uid||widget.user.collectionName == 'Club'){
      return const SizedBox.shrink();
    }else if (widget.user.collectionName == 'Fan'||widget.user.collectionName == 'Professional') {
      return Accountchecker2(user:widget.user);
      }else{
      return const SizedBox.shrink();
    }
  }
}
