import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Matchesstreamedno extends StatefulWidget {
  String userId;

  Matchesstreamedno({super.key,
    required this.userId,});

  @override
  State<Matchesstreamedno> createState() => _MatchesstreamednoState();
}

class _MatchesstreamednoState extends State<Matchesstreamedno> {
  int _followerscount = 0;
  @override
  void initState() {
    super.initState();
    _getcommentCount();
  }


  void _getcommentCount() {
    FirebaseFirestore.instance
        .collection('Clubs')
        .doc(widget.userId)
        .collection('matchestreamed')
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