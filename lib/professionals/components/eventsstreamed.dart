import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Eventstreamedno extends StatefulWidget {
  String userId;

  Eventstreamedno({super.key,
    required this.userId,});

  @override
  State<Eventstreamedno> createState() => _EventstreamednoState();
}

class _EventstreamednoState extends State<Eventstreamedno> {
  int _followerscount = 0;
  @override
  void initState() {
    super.initState();
    _getcommentCount();
  }


  void _getcommentCount() {
    FirebaseFirestore.instance
        .collection('Professionals')
        .doc(widget.userId)
        .collection('eventstreamed')
        .snapshots()
        .listen((snapshot) {
      setState(() {
        _followerscount = snapshot.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_followerscount');
  }
}