import 'package:fans_arena/fans/bloc/accountchecker10.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Accountchecker11 extends StatefulWidget {
Person user;
  Accountchecker11({super.key, required this.user});

  @override
  _Accountchecker11State createState() => _Accountchecker11State();
}
class _Accountchecker11State extends State<Accountchecker11> {
  late String collectionName;
  bool isLoading = true;

  Newsfeedservice news = Newsfeedservice();
  @override
  void initState() {
    super.initState();
    news = Newsfeedservice();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collectionName = prefs.getString('cname')??'';
    collectionName = prefs.getString('cname')??'';
    setState(() {
      isLoading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: SizedBox.shrink(),
      );
    } else if (FirebaseAuth.instance.currentUser!.uid==widget.user.userId) {
      // Execute process for Fans collection
      return const Text('You',style: TextStyle(color: Colors.blue,fontSize: 16,fontWeight: FontWeight.bold),);
    } else if (collectionName == 'Fan') {
        // Execute process for Fans collection
        return Accountchecker10(user: widget.user);
      } else {
        // Execute process if email is not found in any collection
        return const SizedBox.shrink();
      }
    }
  }

