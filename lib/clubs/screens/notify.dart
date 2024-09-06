import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../fans/data/notificationsmodel.dart';
import 'package:fans_arena/appid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
class Notify extends StatefulWidget {
  const Notify({super.key});

  @override
  State<Notify> createState() => _NotifyState();
}

class _NotifyState extends State<Notify> {
  @override
  void initState(){
    super.initState();
    getAds();
  }
  void getAds()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String token =prefs.getString('fcmToken')!;
      if(token==null||token.isEmpty){
        _notifyUpdates=false;
      }else{
        _notifyUpdates=true;
      }
    });
  }
  bool _notifyUpdates = false;

  void enable(bool change)async{
    DocumentSnapshot doc= await FirebaseFirestore.instance.collection("${collectionNamefor}s").doc(FirebaseAuth.instance.currentUser!.uid).get();
    String? token= await NotifyFirebase().requestFCMToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('fcmToken',change?token!:"");
      _notifyUpdates = change;
    });
    if(doc.exists) {
      Map<String, dynamic> newData = {};
      if (change) {
        newData['fcmToken'] = token;

      }else{
        newData['fcmToken'] = "";
        await FirebaseMessaging.instance.deleteToken();
      }
      if (change) {
        newData['fcmcreatedAt'] = Timestamp.now();
      }
      if (newData.isNotEmpty) {
        await doc.reference.update(newData);
      }else{
        setState((){
          _notifyUpdates = change;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(
              height: 60,
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child:   SwitchListTile(
                  title: const Text('Notifications'),
                  value: _notifyUpdates,
                  onChanged: enable,
                ),
              ),
            ),
          )
    );
  }
}







