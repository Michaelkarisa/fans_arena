import 'package:fans_arena/clubs/screens/accountclubviewer.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/accountfanviewer.dart';
import 'package:fans_arena/professionals/screens/accountprofilepviewer.dart';
import 'package:flutter/material.dart';
import '../../joint/data/screens/loginscreen.dart';


class Accountchecker9 extends StatefulWidget {
  final String userId;
  final int index;
  final int? iden;
  const Accountchecker9({super.key, required this.userId,required this.index,this.iden});

  @override
  _Accountchecker9State createState() => _Accountchecker9State();
}

class _Accountchecker9State extends State<Accountchecker9> {
  late String collectionName;
  bool isLoading = true;

  Newsfeedservice news = Newsfeedservice();
  @override
  void initState() {
    super.initState();
    news = Newsfeedservice();
    _getCurrentUser();
  }
late Person user;
  Future<void> _getCurrentUser() async {
      collectionName = await news.getAccount(widget.userId);
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
        return Accountfanviewer(user:user,index:widget.index ,);
      } else if (collectionName == 'Professional') {
        // Execute process for Professional collection
        return AccountprofilePviewer(user:user,index:widget.index ,);
      } else if (collectionName == 'Club') {
        // Execute process for Clubs collection
        return AccountclubViewer(user:user,index:widget.index ,);
      } else {
        // Execute process if email is not found in any collection
        return const Loginscreen();
      }
    }
  }
