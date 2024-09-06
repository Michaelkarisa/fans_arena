import 'package:fans_arena/fans/screens/messages.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../joint/data/screens/loginscreen.dart';
import '../screens/groupchatting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AccountChecker13 extends StatefulWidget {

  const AccountChecker13({super.key});

  @override
  _AccountChecker13State createState() => _AccountChecker13State();
}
class _AccountChecker13State extends State<AccountChecker13> {
  String collectionName='';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  String groupId="";
  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    collectionName = prefs.getString('cname')?? '';
    collectionName = prefs.getString('cname')?? '';
    if(collectionName=="Professionals"){
      QuerySnapshot querySnapshot= await FirebaseFirestore.instance.collection('Professionals').doc(FirebaseAuth.instance.currentUser!.uid).collection('club').get();
      final List<QueryDocumentSnapshot> likeDocuments = querySnapshot.docs;
      setState(() {
        groupId= likeDocuments.first.id;
      });
    }
    setState(() {
      isLoading=false;
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
      return const AlertDialog(
        content: Text('Service currently not available for fans'),
        title: Text('Authorisation failed'),

      );;
    } else if (collectionName == 'Professional') {
      return Groupchatting(groupId: groupId, url: '', username: '',);
      } else if (collectionName == 'Club') {
        // Execute process for Clubs collection
      return ClubChat();
      } else {
        // Execute process if email is not found in any collection
      return const Loginscreen();
      }
    }
  }

