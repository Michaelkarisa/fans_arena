import 'package:flutter/material.dart';

import '../data/newsfeedmodel.dart';

class Accountchecker6 extends StatefulWidget {
  Person user;
  int? iden;
  Accountchecker6({super.key, required this.user, this.iden});

  @override
  _Accountchecker6State createState() => _Accountchecker6State();
}

class _Accountchecker6State extends State<Accountchecker6> {
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
      return const SizedBox(
          width:20 ,
          height: 20,
          child: CircularProgressIndicator(color: Colors.white,));
    } else if (widget.user.collectionName == 'Fan') {
        // Execute process for Fans collection
        return const SizedBox(width: 0,height: 0,);
      } else if (widget.user.collectionName == 'Professional') {
        // Execute process for Professional collection
        return Container(
          width:20 ,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('P',style: TextStyle(color: Colors.white),)),);
      } else if (widget.user.collectionName == 'Club') {
        // Execute process for Clubs collection
        return Container(
          width:20,
          height:20,
          decoration: BoxDecoration(
            color: Colors.blueGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(child: Text('C',style: TextStyle(color: Colors.white),)),);
    } else if (widget.user.collectionName == 'Leagues') {
      // Execute process for Clubs collection
      return Container(
        width:20,
        height:20,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(child: Text('L',style: TextStyle(color: Colors.white),)),);
      } else {
        // Execute process if email is not found in any collection
        return const SizedBox.shrink();
      }
    }
  }

