import 'package:fans_arena/appid.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../appid.dart';
import '../../fans/data/notificationsmodel.dart';
import '../../fans/screens/homescreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../fans/components/bottomnavigationbar.dart';
import '../../fans/screens/accountf.dart';
import '../../joint/data/screens/loginscreen.dart';
import '../../joint/screens/revenueandstatistics.dart';
import '../../professionals/screens/account.dart';
import 'package:fans_arena/fans/bloc/accountchecker.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountClub extends StatefulWidget {
  const AccountClub({super.key});

  @override
  State<AccountClub> createState() => _AccountClubState();
}

class _AccountClubState extends State<AccountClub> {
  @override
  void initState(){
    super.initState();
    checkAuthenticationMethod();
  }
  bool isgoogle=false;
  Future<void> checkAuthenticationMethod() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        bool isGoogleSignIn = user.providerData.any((userInfo) =>
        userInfo.providerId == GoogleAuthProvider.PROVIDER_ID);
        if (isGoogleSignIn) {
          setState(() {
            isgoogle=true;
          });
          print('User is authenticated via Google');
        } else {
          print('User is authenticated via email/password');
        }
      } else {
        print('User is not authenticated');
      }
    } catch (e) {
      print('Error checking authentication method: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account', style: TextStyle(color: Colors.black),),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3,bottom: 3),
                child: Text('Your account insights',style: TextStyle(fontSize: 19,color: Colors.black,fontWeight: FontWeight.bold),),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const AccountInsights()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Account Insights',),
                            ))),
                  )),
              const Padding(
                padding: EdgeInsets.only(top: 3,bottom: 3),
                child: Text('Your activity',style: TextStyle(fontSize: 19,color: Colors.black,fontWeight: FontWeight.bold),),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const TimeSpent()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Time spent'),
                            ))),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const InteractionsClubs()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Interactions'),
                        ))),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const Archived()));},
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Saved Posts & FansTv'),
                        ))),
                  )),
              if(FirebaseAuth.instance.currentUser!=null)
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const DeleteAccount()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Delete Account'),
                        ))),
                  )),
              const Padding(
                padding: EdgeInsets.only(top: 3,bottom: 3),
                child: Text('Security',style: TextStyle(fontSize: 19,color: Colors.black,fontWeight: FontWeight.bold),),
              ),
              isgoogle?const SizedBox.shrink():Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const Password()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Password'),
                        ))),
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 5,),
                child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginActivity()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Login Activity',),
                            )))),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const SavedLoginInfo()));
                    },
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Saved login information '),
                        ))),
                  )),
              Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const SecurityCheckup()));},
                    child: Container(
                        height: 60,
                        color: Colors.grey[200],
                        width: MediaQuery.of(context).size.width,
                        child: const Align(
                            alignment: Alignment.centerLeft,child:  Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('Security checkup'),
                        ))),
                  )),

            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAccount extends StatefulWidget {
  const DeleteAccount({super.key});
  @override
  State<DeleteAccount> createState() => _DeleteAccountState();
}
class _DeleteAccountState extends State<DeleteAccount> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  Future<Widget> _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text('Signing in...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      showToastMessage("logged in");
      //EventLogger().UserLogin('email', userCredential.user!.uid);
      Engagement().engagement('emailSignIn', _startTime, '');
      Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteAccountPage(user: userCredential,)));
      return const Accountchecker();
    } catch (error) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      dialog2(error.toString());
      return const Loginscreen();
    }
  }

  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }
  
  void dialog2(String error){
    String e1="[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.";
    String e2="[firebase_auth/user-not-found] There is no user record corresponding to this identifier. The user may have been deleted.";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign in Failed'),
          content:Builder(
            builder: (context){
              if(error==e1){
                return const Text("Sign in failed due to poor internet connection.");
              }else if(error==e2){
                return const Text("You do not have an account please Sign Up");
              }else{
                return Text('Signing in error: $error');
              }
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Builder(
                  builder: (context){
                    if(error==e1){
                      return  TextButton(
                          onPressed: () {
                            _login();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Retry'));
                    }else if(error==e2){
                      return TextButton(onPressed: () {
                        Navigator.pop(context);
                        showDialog(context: context, builder: (context)=>AlertDialog(
                          title: const Text("Sign Up with?"),
                          actions: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(onPressed: (){
                                  Navigator.pop(context);
                                }, icon: const Icon(Icons.email_outlined,color: Colors.black,size: 35,)),
                                const Text("or"),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height*0.035,
                                  width: MediaQuery.of(context).size.width*0.15,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: InkWell(
                                      onTap: ()async{
                                        Navigator.pop(context);
                                      },
                                      child: Image.asset("assets/images/google.png",fit: BoxFit.fitHeight,),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ));
                      }, child: const Text("Sign Up"));
                    }else{
                      return TextButton(
                          onPressed: ()async{
                            Navigator.of(context).pop();
                            await Future.delayed(Duration(seconds: 1));
                            _login();
                          },

                          child: const Text('Retry'));
                    }
                  },
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  final DateTime  _startTime=DateTime.now();
  Future<void>back()async{
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> handleSignIn() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text('Signing in...'),
              ],
            ),
          ),
        );
      },
    );
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        String? userId = userCredential.user?.uid;

        showToastMessage("logged in");
          Engagement().engagement('googleSignIn', _startTime, '');
          showToastMessage("engagement logged");
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DeleteAccountPage(user: userCredential,)));
          // EventLogger().UserLogin('Google', userCredential.user!.uid);
      }
    } catch (e, exception) {
      await back();
      dialog1(exception.toString());
    }
  }
  void dialog1(String exception){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Error'),
        content: Text(exception),
      );
    });
  }

  final formKey=GlobalKey<FormState>();
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height*0.03,),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01,),
                  const Text('To perform this action, sign in first',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.25,
                    height: MediaQuery.of(context).size.height*0.089,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.25,
                    height: MediaQuery.of(context).size.height*0.111,
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'required';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 2,left: 10,bottom: 2,right: 2),
                      labelText: 'Email',
                      suffixIcon: const Icon(Icons.email_rounded),
                      hintText: 'Enter your email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.033,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    textInputAction: TextInputAction.next,
                    validator: (value) =>
                    value != null && value.isNotEmpty ? null : "required",
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(top: 2,left: 10,bottom: 2,right: 2),
                      labelText: "password",
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height*0.0178),
                  SizedBox(
                    width:MediaQuery.of(context).size.width*0.325,
                    child: loginActions(context),),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.015,
                  ),
                  const Text('or Sign in with'),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.01667,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.08,
                    width: MediaQuery.of(context).size.width*0.3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: ()async{
                          await handleSignIn();
                        },
                        child: Image.asset("assets/images/google.png",fit: BoxFit.fitHeight,),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }
  Widget loginActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 30),
              side: const BorderSide(
                color: Colors.grey,
              ),
            ),
            onPressed: () {
              if(formKey.currentState!.validate()){
                _login();
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("Sign In", style: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ],
    );
  }

}

class DeleteAccountPage extends StatefulWidget {
  UserCredential user;
  DeleteAccountPage({super.key,required this.user});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<void>deleteAccount()async{
    Map<String, dynamic> collection = {
      "Fan":'username',
      "Professional":"Stagename",
      "Club":"Clubname",
    };
    DocumentSnapshot documentSnapshot = await firestore
        .collection("${collectionNamefor}s")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (documentSnapshot.exists) {
      Map<String, dynamic> newData = {
        collection[collectionNamefor]:'user',
        "deleteDate":Timestamp.now()
      };
      if (newData.isNotEmpty) {
        await documentSnapshot.reference.set(newData);
          widget.user.user!.delete();

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(elevation: 1,title: Text("Delete Account"),),
        body: Column(
          children: [
            Text("Warning!",style:TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 18)),
            Text("By deleting this account you will no longer be able to access this account again, your personal data will be erased from this platform that's include images and videos"),
            SizedBox(
              width:MediaQuery.of(context).size.width*0.325,
              child: loginActions(context),),
          ],
        ),
      ),
    );
  }
  Widget loginActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 30),
              side: const BorderSide(
                color: Colors.grey,
              ),
            ),
            onPressed: () {

            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text("Delete account", style: TextStyle(color: Colors.black)),
            ),
          ),
        ),
      ],
    );
  }
}


class InteractionsClubs extends StatefulWidget {
  const InteractionsClubs({super.key});

  @override
  State<InteractionsClubs> createState() => _InteractionsClubsState();
}

class _InteractionsClubsState extends State<InteractionsClubs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: (){Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back,color: Colors.black,size: 33,)),
        title: const Text('Interactions',style: TextStyle(color: Colors.black),),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: InkWell(
              onTap: (){ Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Interactions(),
                ),
              );},
              child: Container(
                height: 50,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Posts you interacted with'),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: InkWell(
              onTap: (){ Navigator.push(context,
                MaterialPageRoute(builder: (context) =>  const InteractionsFansTv(),
                ),
              );},
              child: Container(
                height: 50,
                color: Colors.grey[200],
                width: MediaQuery.of(context).size.width,
                child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('FansTvs you interacted with'),
                    )),
              ),
            ),
          ),

        ],
      ),
    );
  }
}





class LinksVisited extends StatefulWidget {
  const LinksVisited({super.key});

  @override
  State<LinksVisited> createState() => _LinksVisitedState();
}

class _LinksVisitedState extends State<LinksVisited> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Links Visited',style: TextStyle(color: Colors.black),),),
      body: const Column(
        children: [

        ],
      ),
    );
  }
}


class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  String _platformVersion = 'Unknown',
      _imeiNo = "",
      _modelName = "",
      _manufacturerName = "",
      _deviceName = "",
      _productName = "",
      _cpuType = "",
      _hardware = "";
  var _apiLevel;

  @override
  void initState() {
    super.initState();
    initialize();
  }
  void initialize()async{
    await [Permission.phone].request();
    await initPlatformState();
  }

  Future<void> initPlatformState() async {
    late String platformVersion,
        imeiNo = '',
        modelName = '',
        manufacturer = '',
        deviceName = '',
        productName = '',
        cpuType = '',
        hardware = '';
    var apiLevel;

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (kIsWeb) {
        // Handle web-specific logic if necessary
        platformVersion = 'Web';
      } else {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            var androidInfo = await deviceInfoPlugin.androidInfo;
            platformVersion = androidInfo.version.release;
            modelName = androidInfo.model;
            manufacturer = androidInfo.manufacturer;
            deviceName = androidInfo.device;
            productName = androidInfo.product;
            cpuType = androidInfo.supportedAbis.join(', ');
            hardware = androidInfo.hardware;
            apiLevel = androidInfo.version.sdkInt;
            break;
          case TargetPlatform.iOS:
            var iosInfo = await deviceInfoPlugin.iosInfo;
            platformVersion = iosInfo.systemVersion;
            modelName = iosInfo.model;
            manufacturer = 'Apple';
            deviceName = iosInfo.name;
            productName = iosInfo.localizedModel;
            cpuType = iosInfo.utsname.machine;
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.linux:
            var linuxInfo = await deviceInfoPlugin.linuxInfo;
            platformVersion = linuxInfo.version!;
            modelName = linuxInfo.name;
            manufacturer = linuxInfo.id;
            deviceName = linuxInfo.prettyName;
            productName = linuxInfo.variant!;
            cpuType = 'Not available';
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.windows:
            var windowsInfo = await deviceInfoPlugin.windowsInfo;
            platformVersion = windowsInfo.releaseId;
            modelName = windowsInfo.productName;
            manufacturer = 'Microsoft';
            deviceName = windowsInfo.computerName;
            productName = windowsInfo.editionId;
            cpuType = windowsInfo.computerName;
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.macOS:
            var macOsInfo = await deviceInfoPlugin.macOsInfo;
            platformVersion = macOsInfo.osRelease;
            modelName = macOsInfo.model;
            manufacturer = 'Apple';
            deviceName = macOsInfo.computerName;
            productName = macOsInfo.model;
            cpuType = macOsInfo.arch;
            hardware = 'Not available';
            apiLevel = 'Not available';
            break;
          case TargetPlatform.fuchsia:
            platformVersion = 'Fuchsia platform isn\'t supported';
            modelName = 'Fuchsia platform isn\'t supported';
            manufacturer = 'Fuchsia platform isn\'t supported';
            deviceName = 'Fuchsia platform isn\'t supported';
            productName = 'Fuchsia platform isn\'t supported';
            cpuType = 'Fuchsia platform isn\'t supported';
            hardware = 'Fuchsia platform isn\'t supported';
            apiLevel = 'Fuchsia platform isn\'t supported';
            break;
        }
      }
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
      _imeiNo = imeiNo;
      _modelName = modelName;
      _manufacturerName = manufacturer;
      _apiLevel = apiLevel;
      _deviceName = deviceName;
      _productName = productName;
      _cpuType = cpuType;
      _hardware = hardware;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text('Login Activity',style: TextStyle(color: Colors.black),),),
      body: Column(
        children: [
          const Text('Where you are logged in Nairobi, Kenya, Active now, M2101K7AG'),
          const SizedBox(
            height: 40,
          ),
          Text('$_platformVersion\n'),
          const SizedBox(
            height: 10,
          ),
          Text('IMEI Number: $_imeiNo\n'),
          const SizedBox(
            height: 10,
          ),
          Text('Device Model: $_modelName\n'),
          const SizedBox(
            height: 10,
          ),
          Text('API Level: $_apiLevel\n'),
          const SizedBox(
            height: 10,
          ),
          Text('Manufacture Name: $_manufacturerName\n'),
          const SizedBox(
            height: 10,
          ),
          Text('Device Name: $_deviceName\n'),
          const SizedBox(
            height: 10,
          ),
          Text('Product Name: $_productName\n'),
          const SizedBox(
            height: 10,
          ),
          Text('CPU Type: $_cpuType\n'),
          const SizedBox(
            height: 10,
          ),
          Text('Hardware Name: $_hardware\n'),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}


class Password extends StatefulWidget {
  const Password({super.key});

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentPassword;
  String? _newPassword;
  void _changePassword() async {
    if(isStrongPassword5&& _currentPassword!=_newPassword){
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
      // Define your password strength criteria here
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

class TimeSpent extends StatefulWidget {
  const TimeSpent({super.key});

  @override
  _TimeSpentState createState() => _TimeSpentState();
}

class _TimeSpentState extends State<TimeSpent> {


  @override
  void initState() {
    super.initState();
  }

  bool val =false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.arrow_back,color: Colors.black,)),
        backgroundColor: Colors.white,
        title: const Text('Time spent',style: TextStyle(color: Colors.black),),
        actions: const [

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Time spent on the app in hours for the last 7 days.'),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width * 0.99,
              height: 400,
              child: FutureBuilder<List<AppUsage>>(
                future: DatabaseHelper.instance.getAppUsages(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final appUsages = snapshot.data;

                    // Create a list of data points for the bar chart
                    final dataPoints = appUsages?.map((usage) {
                      return BarChartGroupData(
                        x: _getDayOfWeek(usage.date),
                        // Pass the day of the week directly
                        barRods: [BarChartRodData(toY: usage.hoursSpent,width: 40,borderRadius: BorderRadius.circular(0),gradient: const LinearGradient(
                          colors: [
                            Colors.blueAccent,
                            Colors.lightBlueAccent,
                            Colors.blueGrey,
                          ],
                          stops: [0.0, 0.5, 1.0], // Adjust the stops for smooth transition
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),)],
                      );
                    }).toList();

                    return BarChart(
                      BarChartData(
                        maxY:appUsages!.reduce((value, element) => value.hoursSpent > element.hoursSpent ? value : element).hoursSpent.toDouble()*1.5,
                        minY: 0,
                        alignment: BarChartAlignment.spaceAround,
                        groupsSpace: 12,
                        gridData: const FlGridData(show:false),
                        borderData:FlBorderData(show:false),
                        titlesData: FlTitlesData(
                          leftTitles:  const AxisTitles(axisNameSize: 16, axisNameWidget: Text('hours',style: TextStyle(fontWeight: FontWeight.bold),),
                              sideTitles:SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                              )
                          ),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(axisNameSize: 16, axisNameWidget: const Text('Days',style: TextStyle(fontWeight: FontWeight.bold),),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value,tittlemeta) {
                                // Map your numeric value to custom labels here
                                switch (value.toInt()) {
                                  case 1:
                                    return const Text('Mon');
                                  case 2:
                                    return const Text('Tue');
                                  case 3:
                                    return const Text('Wed');
                                  case 4:
                                    return const Text('Thu');
                                  case 5:
                                    return const Text('Fri');
                                  case 6:
                                    return const Text('Sat');
                                  case 7:
                                    return const Text('Sun');
                                  default:
                                    return const Text('');
                                }
                              },
                            ),

                          ),
                        ),
                        barGroups: dataPoints,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getDayOfWeek(DateTime date) {
    return date.weekday;
  }
}


