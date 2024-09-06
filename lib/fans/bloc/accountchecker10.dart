import 'package:fans_arena/fans/components/followbtn1.dart';
import 'package:fans_arena/fans/components/followbtn2.dart';
import 'package:fans_arena/fans/components/followbutton.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:flutter/material.dart';
class Accountchecker10 extends StatefulWidget {
  Person user;
   Accountchecker10({super.key,required this.user});

  @override
  _Accountchecker10State createState() => _Accountchecker10State();
}
class _Accountchecker10State extends State<Accountchecker10> {
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
    if(isLoading) {
      return const SizedBox(height: 30,);
    } else if (widget.user.collectionName == 'Fan') {
        return Followbtn(userId: widget.user.userId);
      } else if (widget.user.collectionName == 'Professional') {
        return  Followbtnprofe(userId: widget.user.userId,);
      } else if (widget.user.collectionName == 'Club') {
        return Followbtnclubs(userId: widget.user.userId);
      } else {
        return const SizedBox(height: 30,);
      }
    }
  }

