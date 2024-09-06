import 'package:fans_arena/fans/components/eventsbottombar.dart';
import 'package:fans_arena/fans/components/eventsclubsbottombar.dart';
import 'package:fans_arena/fans/components/eventsprofessionalsbottombar.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/joint/data/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fans_arena/clubs/screens/createeventpage.dart';
import 'package:fans_arena/professionals/screens/createeventspageprofe.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Accountchecker4 extends StatefulWidget {

  const Accountchecker4({super.key});

  @override
  _Accountchecker4State createState() => _Accountchecker4State();
}
class _Accountchecker4State extends State<Accountchecker4> {
   String collectionName='';
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }
  Future<void> _getCurrentUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if(prefs!=null) {
        collectionName = prefs.getString('cname') ?? '';
        collectionName = prefs.getString('cname') ?? '';
      }
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
        // Execute process for Fans collection
        return const Bottomeventsbar();
      } else if (collectionName == 'Professional') {
        // Execute process for Professional collection
        return  const EventsProfessionalsbottombar();
      } else if (collectionName == 'Club') {
        // Execute process for Clubs collection
        return const EventsClubsbottombar();
      } else {
        // Execute process if email is not found in any collection
        return const Loginscreen();
      }
    }
  }

  class AccountChecker7 extends StatefulWidget {
    const AccountChecker7({super.key});

    @override
    State<AccountChecker7> createState() => _AccountChecker7State();
  }

  class _AccountChecker7State extends State<AccountChecker7> {
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
      collectionName = prefs.getString('cname')!;
      collectionName = prefs.getString('cname')!;
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
      } else if (collectionName == 'Professional') {
        // Execute process for Professional collection
        return  const CreateeventPageProfe();
      } else if (collectionName == 'Club') {
        // Execute process for Clubs collection
        return const CreateEventPage();
      } else {
        // Execute process if email is not found in any collection
          return  const Scaffold(
          body: Center(
            child: SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(color: Colors.black)),
          ),
        );
      }
    }
  }


























