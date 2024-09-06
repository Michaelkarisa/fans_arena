import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/chatting.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Accountchecker1 extends StatefulWidget {
  Person user;
  Accountchecker1({super.key,required this.user });

  @override
  _Accountchecker1State createState() => _Accountchecker1State();
}
class _Accountchecker1State extends State<Accountchecker1> {
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
      return
        const Center(
          child: SizedBox.shrink(),
        );
    }else if(widget.user.userId==FirebaseAuth.instance.currentUser!.uid){
      return SizedBox.shrink();
    } else if (widget.user.collectionName == 'Fan'||widget.user.collectionName == 'Professional') {
      // Execute process for Fans collection
      return SizedBox.shrink();
      //Padding(
      //  padding: const EdgeInsets.only(
      //     bottom: 10),
      // child: SizedBox(
      //   width: 38,
      //  height: 34,
      //  child: Transform.rotate(
      //    angle: -0.5,
      //   child: IconButton(
      //    padding: EdgeInsets.zero,
      //      onPressed: () {
      //      Navigator.push(context,
      //       MaterialPageRoute(
      //         builder: (
      //             context) => Chatting(user: widget.user, chatId: '',),
      //        ),
      //      );
      //     }, icon: const Icon(Icons.send)),
      // ),
      // ),
      // );
      } else {
        // Execute process if email is not found in any collection
        return const SizedBox.shrink();
      }
    }
  }

