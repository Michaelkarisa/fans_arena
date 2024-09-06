import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/screens/stream2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../fans/screens/newsfeed.dart';
class FilmBtn1 extends StatefulWidget {
  EventM event;
  FilmBtn1({super.key,required this.event});

  @override
  State<FilmBtn1> createState() => _FilmBtn1State();
}

class _FilmBtn1State extends State<FilmBtn1> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _isLiked = false;
  String userIde='';
  @override
  void initState() {
    super.initState();
    _getCurrentUser1();
    _checkUserLikedPost();
  }
  Future<void> _getCurrentUser1() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userIde = user.uid; // Assign the user ID to the userId variable
      });
    }
  }
  void _checkUserLikedPost() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Clubs')
          .doc(userIde)
          .collection('eventstreamed')
          .where('eventId', isEqualTo: widget.event.eventId)
          .limit(1)
          .get();

      setState(() {
        _isLiked = querySnapshot.docs.isNotEmpty; // Update _isLiked based on query result
      });
    } catch (e) {
      dialog('Error checking if user liked post: $e');
    }
  }
 void dialog(String e){
    showDialog(context: context, builder: (context){
      return  AlertDialog(
        content: Text(e),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return _isLiked?  TextButton(onPressed: (){
    } , child: const Text('Stats'),)
        :TextButton(onPressed: (){
      Navigator.push(context,
        MaterialPageRoute(builder: (context)=> Stream2(event: widget.event,),
        ),
      );
    } , child: const Text('Film'),);
  }
}
