import 'package:fans_arena/fans/bloc/accountchecker3.dart';
import 'package:fans_arena/joint/data/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loginchecker1 extends StatefulWidget {
  const Loginchecker1({super.key});

  @override
  State<Loginchecker1> createState() => _Loginchecker1State();
}

class _Loginchecker1State extends State<Loginchecker1> {
  bool isLoggedIn = true;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Widget checkLoginStatus() {
    if (currentUser != null && isLoggedIn) {
      return  const Accountchecker3();
    } else {
      return const Loginscreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: checkLoginStatus(),
    );
  }
}


