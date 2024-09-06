import 'package:fans_arena/fans/bloc/accountchecker.dart';
import 'package:fans_arena/joint/data/screens/loginscreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Loginchecker extends StatefulWidget {
  const Loginchecker({super.key});

  @override
  State<Loginchecker> createState() => _LogincheckerState();
}

class _LogincheckerState extends State<Loginchecker> {
  bool isLoggedIn = true;
  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Widget checkLoginStatus() {
    if (currentUser != null && isLoggedIn) {
      return  const Accountchecker();
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


