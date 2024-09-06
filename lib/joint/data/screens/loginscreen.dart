import 'package:fans_arena/appid.dart';
import 'package:fans_arena/clubs/components/clubsaccountinfo.dart';
import 'package:fans_arena/clubs/screens/signupscreenc.dart';
import 'package:fans_arena/fans/bloc/accountchecker.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/fansaccountinfo.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/joint/screens/accountchoice.dart';
import 'package:fans_arena/professionals/screens/professinalsaccountinfo.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../fans/data/notificationsmodel.dart';
import '../../../fans/screens/signupscreenf.dart';
import '../../../professionals/screens/signupscreenp.dart';
import'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _setCname(String userId) async {
    Person p=await Newsfeedservice().getPerson(userId: userId);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      collectionNamefor=p.collectionName;
      username=p.name;
      profileimage=p.url;
      prefs.setString('cname', p.collectionName);
      prefs.setString('name',p.name);
      prefs.setString('profile', p.url);
      prefs.setBool('signin', true);
      prefs.setString('genre', p.genre);
    });
    showToastMessage("collectionName: $collectionNamefor");
  }
  final DateTime  _startTime=DateTime.now();
  late Position location;
  bool isLocationInitialized = false;

  @override
  void initState() {
    super.initState();

  }

  Future<void> initialize() async {
    await [Permission.microphone, Permission.camera,Permission.phone,Permission.location,Permission.storage].request();
    try {
      location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        isLocationInitialized = true;
      });
      await initPlatformState();
    } catch (e) {
      showDialog(context: context, builder: (context){
        return AlertDialog(content: Text(e.toString()),);
      });
      location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    }
  }
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }
  String _platformVersion = '',
      _imeiNo = "",
      _modelName = "",
      _manufacturerName = "",
      _deviceName = "",
      _productName = "",
      _cpuType = "",
      _hardware = "";
  var _apiLevel;
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
      await initialize();
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      showToastMessage("logged in");
      await _setCname(userCredential.user!.uid);
      showToastMessage("collectionName stored to device");
      //EventLogger().UserLogin('email', userCredential.user!.uid);
      Engagement().engagement('emailSignIn', _startTime, '');
      showToastMessage("engagement logged");
      await addData(userCredential.user!.uid);
      return const Accountchecker();
    } catch (error) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      dialog2(error.toString());
      return const Loginscreen();
    }
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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Timestamp createdAt = Timestamp.now();
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
      await initialize();
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
       await _setCname(userId!);
        showToastMessage("collectionName stored to device");
        final DocumentSnapshot doc = await FirebaseFirestore.instance.collection('${collectionNamefor}s').doc(userId).get();
        showToastMessage("check if user exists in database");
        if (doc.exists) {
          Engagement().engagement('googleSignIn', _startTime, '');
          showToastMessage("engagement logged");
         // EventLogger().UserLogin('Google', userCredential.user!.uid);
          await addData(userCredential.user!.uid);
        } else {
         await back();
         dialog(userCredential);
        }
      }
    } catch (e, exception) {
      await back();
       dialog1(exception.toString());
    }
  }

  Future<void> addData(String userId,)async{
    String? token= await NotifyFirebase().requestFCMToken();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('fcmToken',token!);
    });
    final String Id = generateUniqueNotificationId();
    final like = {
      'Id': Id,
      'devicename': _deviceName,
      'devicemodel': _modelName,
      'osversion': _platformVersion,
      'manufacturername': _manufacturerName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'state': 'login',
    };
    Map<String, dynamic> data = {
      'fcmToken':token,
      'onlinestatus':1,
      'collection':"${collectionNamefor}s",
      'userId':userId,
      'location':like,
    };
    await NotifyFirebase().saveSingIn(data,context);
    showToastMessage("Notification initialized");
  }


  void dialog1(String exception){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Error'),
        content: Text(exception),
      );
    });
  }
  void dialog(UserCredential userCredential){
    showDialog(
        barrierDismissible: false,
        context: context, builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('You do not have an account choose account option to continue'),
        content: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              Container(
                height: 50,
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      elevation: WidgetStateProperty.all<double>(4),
                    ),
                    child: Text(
                        "Fan".toUpperCase(),
                        style: const TextStyle(fontSize: 14,color: Colors.black)
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      createFan(userCredential);
                      //to next page
                    }
                ),
              ),
              SizedBox(height: 40,
                child: TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Fansaccountinfo(),
                    ),
                  );
                }, child: const Text('Learn more about Fans'),),
              ),
              Container(
                height: 50,
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child:
                ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      elevation: WidgetStateProperty.all<double>(4),
                    ),
                    child: Text(
                        "Club".toUpperCase(),
                        style: const TextStyle(fontSize: 14, color: Colors.black)
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      createClub(userCredential);

                      //to next page
                    }
                ),
              ),
              SizedBox(height: 40,
                child: TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Clubsaccountinfo(),
                    ),
                  );
                }, child: const Text('Learn more about Clubs'),),
              ),
              Container(
                height: 50,
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child:
                ElevatedButton(
                    style: ButtonStyle(
                      foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                      elevation: WidgetStateProperty.all<double>(4),
                    ),
                    child: Text(
                        "Professional".toUpperCase(),
                        style: const TextStyle(fontSize: 14, color: Colors.black)
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      createProfessional(userCredential);
                    }
                ),
              ),
              SizedBox(height: 40,
                child: TextButton(onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Profesaccountinfo(),
                    ),
                  );
                }, child: const Text('Learn more about Professionals'),),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              TextButton(onPressed: ()async{
                Navigator.pop(context);
                await _auth.signOut();
              }, child: const Text('dismiss')),
            ],
          )
        ],
      );
    });
  }
  Future<void>back()async{
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
  void createFan(UserCredential user)async{
    String Id = generateUniqueNotificationId();
    Timestamp createdAt = Timestamp.now();
    final like = {
      'Id':Id,
      'devicename':_deviceName,
      'devicemodel':_modelName,
      'osversion':_platformVersion,
      'manufacturername':_manufacturerName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'state':'createaccount',
      'timestamp': createdAt,};
    String? fCMToken = await NotifyFirebase().requestFCMToken();
    await _firestore.collection('Fans').doc(user.user!.uid).set({
      'username': user.user?.displayName,
      'searchname':user.user?.displayName?.toLowerCase(),
      'fcmToken':fCMToken,
      'fcmcreatedAt':FieldValue.serverTimestamp(),
      'devicemodel':_modelName,
      'email': user.user?.email,
      'Fanid': user.user!.uid,
      'createdAt': createdAt,
      'logintime': createdAt,
      'profileimage':'',
      'location':'',
      'website':'',
      'bio':'',
    });
    await FirebaseFirestore.instance.collection('Fans').doc(user.user!.uid).collection('locations').add({
      'location': [like]
    });
    //EventLogger().UserLogin('Google', user.user!.uid);
    collectionNamefor="Fan";
    _setCname(user.user!.uid);
    Engagement().engagement('GoogleSignUp', _startTime, '');
     naviContifP(user.user!.uid,user.user!.displayName!);
  }
  void naviContifP(String userId,String username){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContifP(userId:userId,username:username,)),
    );
  }
  void createClub(UserCredential user)async{
    String Id = generateUniqueNotificationId();
    Timestamp createdAt = Timestamp.now();
    final like = {
      'Id':Id,
      'devicename':_deviceName,
      'devicemodel':_modelName,
      'osversion':_platformVersion,
      'manufacturername':_manufacturerName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'state':'createaccount',
      'timestamp': createdAt,};
    String? fCMToken = await NotifyFirebase().requestFCMToken();
    await _firestore.collection('Clubs')
        .doc(user.user!.uid).set({
      'Clubname': user.user?.displayName,
      'searchname':user.user?.displayName?.toLowerCase(),
      'fcmToken':fCMToken,
      'fcmcreatedAt':FieldValue.serverTimestamp(),
      'devicemodel':_modelName,
      'email': user.user?.email,
      'Clubid': user.user!.uid,
      'createdAt': createdAt,
      'logintime': createdAt,
      'Location':'',
      'website':'',
      'Motto':'',
      'profileimage':'',
    });
    await FirebaseFirestore.instance.collection('Clubs').doc(user.user!.uid).collection('locations').add({
      'location': [like]
    });
    //EventLogger().UserLogin('Google', user.user!.uid);
    Engagement().engagement('GoogleSignUp', _startTime, '');
    collectionNamefor="Club";
    _setCname(user.user!.uid);
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ContiFP1(userId: user.user!.uid, username:user.user!.displayName!,)),
      );
  }
  void createProfessional(UserCredential user)async{
    String Id = generateUniqueNotificationId();
    Timestamp createdAt = Timestamp.now();
    final like = {
      'Id':Id,
      'devicename':_deviceName,
      'devicemodel':_modelName,
      'osversion':_platformVersion,
      'manufacturername':_manufacturerName,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'state':'createaccount',
      'timestamp': createdAt,};
    String? fCMToken = await NotifyFirebase().requestFCMToken();
    await _firestore.collection('Professionals')
        .doc(user.user!.uid).set({
      'email': user.user?.email,
      'Stagename': user.user?.displayName,
      'searchname':user.user?.displayName?.toLowerCase(),
      'fcmToken':fCMToken,
      'fcmcreatedAt':FieldValue.serverTimestamp(),
      'devicemodel':_modelName,
      'linkedaccount': '',
      'clubId': '',
      'profeid': user.user!.uid,
      'createdAt': createdAt,
      'logintime': createdAt,
      'quote':'',
      'profileimage':'',
      'website':'',
      'Location':'',
    });
    await FirebaseFirestore.instance.collection('Professionals').doc(user.user!.uid).collection('locations').add({
      'location': [like]
    });
    //EventLogger().UserLogin('Google', user.user!.uid);
    Engagement().engagement('GoogleSignUp', _startTime, '');
    collectionNamefor="Professional";
    _setCname(user.user!.uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ContiP(username:user.user!.displayName!,)),
      );

  }

  Future<void> _resetPassword() async {
      showDialog(
        context: context,
        builder: (context) {
          return const ResetPassword();
        },
      );
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
                    SizedBox(height: MediaQuery.of(context).size.height*0.033,),
                    SizedBox(height: MediaQuery.of(context).size.height*0.0111111,),
                    const Text('Sign In',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),),
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
                      child: loginfactions(context),),
                    TextButton(onPressed: _resetPassword
                    , child: const Text('forgot password')),
                    Padding(
                      padding: const EdgeInsets.only(left: 100.0, right: 100,),
                      child: Row(
                        children: [
                          const Text('No account? '),
                          TextButton(onPressed: (){
                            Navigator.push(context,
                              MaterialPageRoute(builder: (context)=> const Accountchoice(),
                              ),
                            );
                          }, child: const Text('Sign up'))
                        ],
                      ),
                    ),
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
  Widget loginfactions(BuildContext context) {
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

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool issent=false;
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
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Password Reset'),
      content: TextFormField(
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
          labelText: 'Email',
          suffixIcon: const Icon(Icons.email_rounded),
          hintText: 'Enter your email address',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('dismis'),
            ),
            TextButton(
              onPressed: ()async {
                if(!issent) {
                  await _auth.sendPasswordResetEmail(
                      email: _emailController.text.trim()).then((value) {
                    setState(() {
                      issent = true;
                    });
                  });
                  showToastMessage('email sent');
                }else{
                  String url ="https://mail.google.com/";
                  await launch(url);
                }
              },
              child:Text(issent?"open gmail":'send reset email'),
            ),
          ],
        ),

      ],
    );
  }
}





