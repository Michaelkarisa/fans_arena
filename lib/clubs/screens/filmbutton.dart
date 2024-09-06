import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/screens/stream1.dart';
import 'package:fans_arena/joint/components/recently.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fans/screens/newsfeed.dart';
class FilmBtn extends StatefulWidget {
  MatchM matches;
  FilmBtn({super.key,required this.matches});

  @override
  State<FilmBtn> createState() => _FilmBtnState();
}

class _FilmBtnState extends State<FilmBtn> {
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
          .collection('matchestreamed')
          .where('matchId', isEqualTo: widget.matches.matchId)
          .limit(1)
          .get();

      setState(() {
        _isLiked = querySnapshot.docs.isNotEmpty; // Update _isLiked based on query result
      });
    } catch (e) {
      print('Error checking if user liked post: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return _isLiked?  TextButton(onPressed: (){
      Navigator.push(context,
        MaterialPageRoute(builder: (context)=> Stats(matches:widget.matches,),
        ),
      );
    } , child: const Text('Stats'),)
    :TextButton(onPressed: (){
      Navigator.push(context,
        MaterialPageRoute(builder: (context)=> Stream1(match:widget.matches,),
        ),
      );
    } , child: const Text('Film'),);
  }
}
