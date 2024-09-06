import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/joint/data/screens/loginscreen.dart';
import 'package:fans_arena/joint/screens/filming.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Accountchecker3 extends StatefulWidget {
  const Accountchecker3({super.key});
  @override
  _Accountchecker3State createState() => _Accountchecker3State();
}
class _Accountchecker3State extends State<Accountchecker3> {
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
    setState(() {
      collectionName = prefs.getString('cname')??'';
    });
    if(collectionName.isEmpty) {
      collectionName = await news.getAccount(FirebaseAuth.instance.currentUser!.uid);
      setState(() {
        isLoading = false;
      });
    }
    setState(() {
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return  const Scaffold(
        body: Center(
          child: SizedBox(
              width: 35,
              height: 35,
              child: CircularProgressIndicator(color: Colors.black)),
        ),
      );
    } else if (collectionName == 'Fan') {
        // Execute process for Fans collection
        return const AlertDialog(
          content: Text('You are logged in as a Fan, account not authorised to access this service'),
          title: Text('Authorisation failed'),

        );
      } else if (collectionName == 'Professional') {
        // Execute process for Professional collection
        return  const EventsFilming();
      } else if (collectionName == 'Club') {
        // Execute process for Clubs collection
        return const EventsFilming();
      } else {
        // Execute process if email is not found in any collection
        return const Loginscreen();
      }
    }
  }





