import 'package:fans_arena/clubs/screens/accountc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../fans/screens/accountf.dart';
import '../../joint/screens/revenueandstatistics.dart';


class Personalinfofans extends StatefulWidget {
  const Personalinfofans({super.key});

  @override
  State<Personalinfofans> createState() => _PersonalinfofansState();
}

class _PersonalinfofansState extends State<Personalinfofans> {
  TextEditingController email= TextEditingController();
  TextEditingController gender= TextEditingController();
  TextEditingController DoB= TextEditingController();
  TextEditingController Phonenumber= TextEditingController();
  String username1 = '';
  String favourite1 = '';
  String bio1 = '';
  String website1 = '';
  String imageurl = '';
  String email1 = '';
  String userId='';
  @override
  void initState(){
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      retrieveUsername();
    }
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Fans')
          .doc(userId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          gender.text = data['gender'];
          email.text = data['email'];
          DoB.text = data['birthday'];
          Phonenumber.text = data['phonenumber'];
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        },icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Personal Information',style: TextStyle(color: Colors.black,),),),
      body: Column(
        children: [
          const Text("This won't be part of your public profile unlses you deem so."),
          const SizedBox(height: 20,),
          const Text('Email address'),
          TextFormField(
            controller: email,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
                labelText: 'Email address'
            ),
          ),
          const SizedBox(height: 20,),
          const Text('Phone number'),
          TextFormField(
            controller: Phonenumber,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
                labelText:'Phone number'
            ),
          ),
          const SizedBox(height: 20,),
          const Text('Gender'),
          TextFormField(
            controller: gender,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
                labelText: 'Gender'
            ),
          ),
          const SizedBox(height: 20,),
          const Text('Date of Birth'),
          TextFormField(
            controller: DoB,
            decoration: const InputDecoration(
                suffixIcon: Icon(Icons.arrow_forward_ios,color: Colors.black,),
                labelText: 'Date of Birth'
            ),
          ),
        ],
      ),
    );
  }
}




class SecurityCheckup extends StatefulWidget {
  const SecurityCheckup({super.key});

  @override
  State<SecurityCheckup> createState() => _SecurityCheckupState();
}

class _SecurityCheckupState extends State<SecurityCheckup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Security Check Up',style: TextStyle(color: Colors.black),),),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}

class Passwordc extends StatefulWidget {
  const Passwordc({super.key});

  @override
  State<Passwordc> createState() => _PasswordcState();
}

class _PasswordcState extends State<Passwordc> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentPassword;
  String? _newPassword;
  void _changePassword() async {
    if(isStrongPassword5){
      if (_currentPassword == null || _newPassword == null) {
        print('Please enter both the current and new passwords.');
        return;
      }

      try {
        User? user = _auth.currentUser;

        if (user == null) {
          print('User not logged in.');
          return;
        }

        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPassword!,
        );
        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(_newPassword!);

        print('Password changed successfully.');
      } catch (e) {
        print('Failed to change password: $e');
      }}
  }
  bool _obscureText = true;
  bool _obscureText1 = true;
  bool isStrongPassword = false;
  bool isStrongPassword1 = false;
  bool isStrongPassword2 = false;
  bool isStrongPassword3 = false;
  bool isStrongPassword4 = false;
  bool isStrongPassword5 = false;
  TextEditingController password=TextEditingController();
  TextEditingController passwor1=TextEditingController();
  void checkPasswordStrength(String value) {
    setState(() {
      isStrongPassword = value.length >= 8;
      isStrongPassword1 = value.contains(RegExp(r'[a-z]'));
      isStrongPassword2 =value.contains(RegExp(r'[A-Z]'));
      isStrongPassword3 = value.contains(RegExp(r'[0-9]'));
      isStrongPassword4 = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      isStrongPassword5 =
          value.length >= 8 &&
              value.contains(RegExp(r'[a-z]')) &&
              value.contains(RegExp(r'[A-Z]')) &&
              value.contains(RegExp(r'[0-9]')) &&
              value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }
  int characternum=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Password',style: TextStyle(color: Colors.black),),),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top:5,bottom: 8),
                  child: Text('Change Password',style: TextStyle(fontSize: 19,color: Colors.black,fontWeight: FontWeight.bold),),
                ),
                TextFormField(
                  obscureText: _obscureText,
                  controller: passwor1,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText1 ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            _obscureText1 = !_obscureText1;
                          });
                        },
                      ),
                      labelText: 'Current Password'),

                  onChanged: (value) {
                    setState(() {
                      _currentPassword = value;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                if (_newPassword != null)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: 300,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Password Checker',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          Text(
                            isStrongPassword2
                                ? 'Password contains upper case letters'
                                : 'Password must contain upper case letters',
                            style: TextStyle(
                              color: isStrongPassword2 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword1
                                ? 'Password contains lower case letters'
                                : 'Password must contain lower case letters',
                            style: TextStyle(
                              color: isStrongPassword1 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword3
                                ? 'Password contains numeric values'
                                : 'Password must contain numeric values',
                            style: TextStyle(
                              color: isStrongPassword3 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword4
                                ? 'Password contains special characters'
                                : 'Password must contain special characters',
                            style: TextStyle(
                              color: isStrongPassword4 ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword
                                ? 'Password contains $characternum characters'
                                : 'Password must contain atleast 8 characters',
                            style: TextStyle(
                              color: isStrongPassword ? Colors.green : Colors.red,
                            ),
                          ),
                          Text(
                            isStrongPassword5
                                ? 'Password is strong'
                                : 'Password is not strong enough',
                            style: TextStyle(
                              color: isStrongPassword5 ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 5,),
                TextFormField(
                  controller: password,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      labelText: 'New Password'),
                  onChanged: (value) {
                    setState(() {
                      _newPassword = value;
                      checkPasswordStrength(value);
                      characternum=value.length;

                    });
                  },
                ),

                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _changePassword,
                  child: const Text('Change Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class Accountstatus extends StatefulWidget {
  const Accountstatus({super.key});

  @override
  State<Accountstatus> createState() => _AccountstatusState();
}

class _AccountstatusState extends State<Accountstatus> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);}, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Account Status',style: TextStyle(color: Colors.black),),
      ),
    );
  }
}

class Language extends StatefulWidget {
  const Language({super.key});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);}, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Language',style: TextStyle(color: Colors.black),),
      ),
      body: const Column(
        children: [
          Text('Only English is Available as for now.')
        ],
      ),
    );
  }
}

