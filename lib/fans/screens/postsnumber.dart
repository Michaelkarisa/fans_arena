import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Postno extends StatefulWidget {
  String userId;
  Postno({super.key,required this.userId});

  @override
  State<Postno> createState() => _PostnoState();
}

class _PostnoState extends State<Postno> {
  int _postsCount = 0;
  int _fansTvCount=0;
  @override
  void initState() {
    super.initState();
    _getcommentCount();
    _getcommentCount1();
  }


  void _getcommentCount() {
    FirebaseFirestore.instance
        .collection('posts')
        .where('authorId', isEqualTo: widget.userId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _postsCount = snapshot.docs.length;
      });
    });
  }

  void _getcommentCount1() {
    FirebaseFirestore.instance
        .collection('FansTv')
        .where('authorId', isEqualTo: widget.userId)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _fansTvCount = snapshot.docs.length;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
     if(_fansTvCount+_postsCount>999){
      return Text('${_fansTvCount+_postsCount/1000}K');
    }else if(_fansTvCount+_postsCount>999999){
      return Text('${_fansTvCount+_postsCount/1000000}M');
    }else if(_fansTvCount+_postsCount>999999999){
      return Text('${_fansTvCount+_postsCount/1000000000}B');
    } else {
      return Text(
        '${_fansTvCount+_postsCount}',
      );
    }
  }
}