import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/professionals/screens/genrescreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../appid.dart';
import '../../fans/data/notificationsmodel.dart';
import '../../fans/screens/homescreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class SignupscreenC extends StatefulWidget {
  const SignupscreenC({super.key});

  @override
  State<SignupscreenC> createState() => _SignupscreenCState();
}


class _SignupscreenCState extends State<SignupscreenC> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController genrecontroller = TextEditingController();


  Future<void> sendVerificationEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null || !user.emailVerified) {
        // User is not verified
      } else {
        // User is verified
      }
    });
  }

  String _generateOtp([int length = 6]) {
    final random = Random();
    return List.generate(length, (_) => random.nextInt(10)).join();
  }

  Future<void> _sendOtpEmail(String email, String otpCode,String username) async {
    final url = Uri.parse('https://api.mailersend.com/v1/email');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': emailApi,
    };
    final body = json.encode({
      "from": {
        "email": "fansarenakenya@gmail.com",
        "name": "Fans Arena"
      },
      "to": [
        {
          "email": email,
          "name": username
        }
      ],
      "subject": "Your OTP Code for Fans Arena",
      "text": "Your OTP code is: $otpCode",
      "html": "<b>Your OTP code is: $otpCode</b>",
      "personalization": [
        {
          "email": email,
          "data": {
            "otp_code": otpCode
          }
        }
      ]
    });
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 202) {
      print('OTP email sent successfully');
    } else {
      print('Failed to send OTP email: ${response.body}');
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

  bool isEmailVerified() {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null && user.emailVerified;
  }
  late Position location;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    initialize();
  }
  late DateTime  _startTime;
  void initialize()async{
    await initPlatformState();
    location= await getCurrentLocation();
  }
  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
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

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }

  Future<void> _register(BuildContext context) async {
    final email = _emailController.text;
    final birthday = _selectedDate?.copyWith();
    final password = _passwordController.text;
    final username = _usernameController.text;
      final genre=genrecontroller.text;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02222),
                const Text('Signing up...'),
              ],
            ),
          ),
        );
      },
    );

    try {
      final fansSnapshot = await FirebaseFirestore.instance
          .collection('Clubs')
          .where('Clubname', isEqualTo: username)
          .limit(1)
          .get();
      final fansSnapshot1 = await FirebaseFirestore.instance
          .collection('Clubs')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (fansSnapshot.docs.isNotEmpty||fansSnapshot1.docs.isNotEmpty) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title:fansSnapshot.docs.isNotEmpty? const Text('Username Already Exists'):const Text('email already exists'),
              content:fansSnapshot.docs.isNotEmpty? const Text(
                  'The username entered already exists. Please enter a different username.'):const Text(
                  'The email entered already exists. Please enter a different email.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign in Failed'),
              content: const Text('Failed to sign in after registration. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      final int? year = birthday?.year;
      final int? month = birthday?.month;
      final int? day = birthday?.day;
      if(location==null) {
        location = await getCurrentLocation();
      }
      String Id = generateUniqueNotificationId();
      if (year != null && month != null && day != null) {
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
        final wholeDate = DateTime(year, month, day);
        String? fCMToken = await NotifyFirebase().requestFCMToken();
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          prefs.setString('fcmToken',fCMToken!);
        });
        await FirebaseFirestore.instance.collection('Clubs').doc(user.uid).set({
          'Clubname': username,
          'searchname':username.toLowerCase(),
          'fcmToken':fCMToken,
          'fcmcreatedAt':FieldValue.serverTimestamp(),
          'devicemodel':_modelName,
          'email': email,
          'genre': genre,
          'Clubid': user.uid,
          'createdAt': createdAt,
          'foundedday': wholeDate,
          'logintime':createdAt,
          'Location':'',
          'website':'',
          'Motto':'',
          'profileimage':'',
        });
        collectionNamefor="Club";
        _setCname(username);
        await FirebaseFirestore.instance.collection('Clubs').doc(user.uid).collection('locations').add({
          'location': [like]
        });
        final notifyFirebase=NotifyFirebase();
        await  notifyFirebase.notify();
        //EventLogger().UserSignUp('email', userCredential.user!.uid);
        Engagement().engagement('emailSignUp', _startTime, '');
      }
     navigateBottomBar();
      print('User registered: ${userCredential.user}');
    } catch (e) {
      String errorMessage = '';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'The email address is already in use.';
            break;
          default:
            errorMessage = 'Failed to register user: ${e.message}';
            break;
        }
      } else {
        errorMessage = 'Failed to register user: $e';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Sign Up Failed'),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        ).then((_) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        });
      });

      print(errorMessage);
    }
  }

  void navigateBottomBar(){
    showToastMessage("success");
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottomnavbar()),
          (Route<dynamic> route) => false,
    );
  }
  DateTime? _selectedDate;
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.utc(2050),
    );
    if (picked != null && picked != _selectedDate) {
      final pickedDateWithoutTime = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _selectedDate = pickedDateWithoutTime;
      });
    }
  }
  Future<void> _setCname(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('cname', collectionNamefor);
      prefs.setString('name',name);
      prefs.setBool('signup', true);
    });
  }
  bool _obscureText = true;
  bool isStrongPassword = false;
  bool isStrongPassword1 = false;
  bool isStrongPassword2 = false;
  bool isStrongPassword3 = false;
  bool isStrongPassword4 = false;
  bool isStrongPassword5 = false;
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
  String? _newPassword;
  int characternum=0;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential?> handleSignIn() async {

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
                Text('Signing up...'),
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
        final String userId = (await _auth.signInWithCredential(credential)).user!.uid ?? '';
        final DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Clubs').doc(userId).get();
        if (doc.exists) {
          await back();
          showDialog(context: context, builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Account Already Exists'),
              content: Text(
                  'You already have an account with this email. Please log in.'),
            );
          });

          return null;
        } else {
          if(location==null) {
            location = await getCurrentLocation();
          }
          Timestamp createdAt = Timestamp.now();
          final String email = (await _auth.signInWithCredential(credential)).user!.email ?? '';
          String Id = generateUniqueNotificationId();
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
          final String username = userCredential.user!.displayName ?? '';
          String? fCMToken = await NotifyFirebase().requestFCMToken();
          String url =userCredential.user!.photoURL ?? '';
          await _firestore.collection('Clubs').doc(userCredential.user!.uid).set({
            'Clubname': username,
            'searchname':username.toLowerCase(),
            'fcmToken':fCMToken,
            'fcmcreatedAt':FieldValue.serverTimestamp(),
            'devicemodel':_modelName,
            'email': email,
            'Clubid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'Location':'',
            'website':'',
            'Motto':'',
            'profileimage':url,
          });
          collectionNamefor="Club";
          _setCname(username);
          await FirebaseFirestore.instance.collection('Clubs').doc(userCredential.user!.uid).collection('locations').add({
            'location': [like]
          }).then((value) =>Navigator.of(context, rootNavigator: true).pop());
          //EventLogger().UserSignUp('Google', userCredential.user!.uid);
          Engagement().engagement('GoogleSignUp', _startTime, '');

          return userCredential;
        }
      }
    } catch (e, exception) {
      await back();
      showDialog(context: context, builder: (BuildContext context){
        return AlertDialog(
          title: const Text('Error'),
          content: Text('$exception'),
        );
      });
      print('Error: $exception');
    }
    return null;
  }
  Future<void>back()async{
    Navigator.of(context, rootNavigator: true).pop();
  }
  final formKey = GlobalKey<FormState>();
  bool value=false;
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
                  const SizedBox(height: 20,),
                  const Text('Club Account',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),),
                  SizedBox(height: MediaQuery.of(context).size.height*0.01111,),
                  const Text('Sign Up',style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold,),),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width*0.25,
                  ),
                  Column(
                    children: [
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
                          contentPadding: const EdgeInsets.only(left: 10),
                          labelText: 'Email',
                          suffixIcon: const Icon(Icons.email_rounded),
                          hintText: 'Enter your email address',
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color:Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'required';
                          }
                          return null;},
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          labelText: 'Clubname',
                          suffixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color:Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      TextFormField(
                        controller: genrecontroller,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'required';
                          }
                          return null;},
                        readOnly: true,
                        onTap: (){
                          showModalBottomSheet(
                            isScrollControlled: true,
                            isDismissible: true,
                            backgroundColor: Colors.transparent,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                            context: context,
                            builder: (BuildContext context) {
                              return Genrescreen( onNextPage: (genr) {
                                setState(() {
                                  genrecontroller.text = genr;
                                });});
                            },
                          );
                        },
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.only(left: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color:Colors.grey,
                              ),
                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.black),
                            ),
                            filled: true,
                            hintStyle: const TextStyle(color: Colors.black,
                              fontSize: 20, fontWeight: FontWeight.normal,),
                            fillColor: Colors.white70,

                            labelText: 'Genre'
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'required';
                          }
                          return null;},
                        onTap: () {
                          _selectDate(context);
                        },
                        readOnly: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color:Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: 'Date the club was founded',
                        ),
                        controller: TextEditingController(
                          text: _selectedDate != null
                              ? "${_selectedDate!.toLocal()}".split(' ')[0]
                              : '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
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
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'required';
                          }
                          return null;},
                        controller: _passwordController,
                        obscureText: _obscureText,
                        onChanged: (value){
                          checkPasswordStrength(value);
                          characternum=value.length;
                          _newPassword = value;
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.black,),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color:Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height:20
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.325,
                    child: signUpActions(context),),
                  const SizedBox(
                    height:20
                  ),
                  const Text('or Sign up with'),
                  const SizedBox(
                    height:20
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height*0.08,
                    width: MediaQuery.of(context).size.width*0.3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: ()async{   UserCredential? userCredential = await handleSignIn();
                        if (userCredential != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ContiFP1(userId: userCredential.user!.uid, username: userCredential.user!.displayName!,)),
                          );
                        }},
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
  Widget signUpActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 30),
                side: const BorderSide(
                  color: Colors.grey,
                )),
            onPressed: ()async {
              if(formKey.currentState!.validate()){
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    context: context,
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        expand: true,
                        initialChildSize: 0.8,
                        maxChildSize: 0.5,
                        minChildSize: 0.5,
                        builder: (context, pController) => SignUpPage()
                      );
                    },
                  );
                }else{
                  setState(() {
                    value=false;
                  });
                }
              },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text("Sign Up", style: TextStyle(color: Colors.black)),
            )
          ),
        ),
      ],
    );
  }

  Widget SignUpPage(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          color: Colors.grey[200],
        ),
        child: Column(
          children: [
            SizedBox(
                height: 600,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Terms and Condition',
                          style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
                        ),
                    Text(
                      'Introduction',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Welcome to Fans Arena, a platform that allows users to stream and view online content, including but not limited to video, audio, and live broadcasts. By accessing or using the App, you agree to comply with and be bound by these Terms of Use (“Terms”). If you do not agree to these Terms, please do not use the App.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '1. Acceptance of Terms',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'By creating an account, accessing, or using the App, you agree to these Terms and any additional terms, policies, and guidelines that the App may provide from time to time. You also acknowledge that you are of legal age to enter into these Terms or have obtained permission from a legal guardian.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '2. Changes to the Terms',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We reserve the right to modify or revise these Terms at any time. Any changes will be effective immediately upon posting the revised Terms. Your continued use of the App after any such changes constitutes your acceptance of the new Terms.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '3. User Accounts',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- Account Creation: To access certain features of the App, you may be required to create an account. You are responsible for maintaining the confidentiality of your account and password and for all activities that occur under your account.\n\n'
                          '- Account Information: You agree to provide accurate and complete information when creating your account and to update your information to keep it accurate and complete.\n\n'
                          '- Account Termination: We reserve the right to suspend or terminate your account at our discretion if you violate any part of these Terms or for any other reason.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '4. Use of the App',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- License: We grant you a limited, non-exclusive, non-transferable, and revocable license to access and use the App for personal and non-commercial purposes, subject to these Terms.\n\n'
                          '- Prohibited Conduct: You agree not to use the App to:\n'
                          '  - Violate any laws or regulations.\n'
                          '  - Post or transmit any content that is unlawful, defamatory, obscene, or otherwise objectionable.\n'
                          '  - Engage in any activity that could interfere with or disrupt the App or the servers and networks connected to the App.\n'
                          '  - Impersonate any person or entity or misrepresent your affiliation with any person or entity.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '5. Content Ownership and Rights',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- User-Generated Content: By uploading, posting, or otherwise making available any content on the App, you grant us a worldwide, non-exclusive, royalty-free, sublicensable, and transferable license to use, reproduce, distribute, prepare derivative works of, display, and perform the content in connection with the App and our business.\n\n'
                          '- App Content: All content provided by the App, including but not limited to text, graphics, logos, and software, is the property of [Application Name] or its content suppliers and is protected by copyright and other intellectual property laws. You may not reproduce, distribute, or create derivative works from the content without our express written permission.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '6. Privacy Policy',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your use of the App is also governed by our Privacy Policy, which explains how we collect, use, and disclose information about you. By using the App, you agree to our Privacy Policy.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '7. Termination',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We may terminate or suspend your access to the App, with or without notice, for any reason, including if you violate these Terms. Upon termination, your right to use the App will immediately cease, and we may delete your account and any content you have provided.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '8. Limitation of Liability',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'To the fullest extent permitted by law, Fans Arena and its affiliates, officers, directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, or any loss of data, use, goodwill, or other intangible losses, resulting from:\n'
                          '  - Your access to or use of or inability to access or use the App.\n'
                          '  - Any unauthorized access to or use of our servers and/or any personal information stored therein.\n'
                          '  - Any interruption or cessation of transmission to or from the App.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '9. Indemnification',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You agree to indemnify and hold Fans Arena and its affiliates, officers, directors, employees, and agents harmless from and against any claims, liabilities, damages, losses, and expenses, including without limitation reasonable legal and accounting fees, arising out of or in any way connected with your access to or use of the App, your violation of these Terms, or your infringement of any third-party rights.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '10. Governing Law',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'These Terms shall be governed by and construed in accordance with the laws of Kenya, without regard to its conflict of law principles. You agree to submit to the exclusive jurisdiction of the courts located within Kenya to resolve any legal matter arising from these Terms or your use of the App.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '11. Contact Information',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'If you have any questions about these Terms, please email us at fansarenakenya@gmail.com, or visit us on www.fansarenakenya.site.',
                    ),
                    SizedBox(height: 16),
                    Text(
                      '12. Miscellaneous',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '- Entire Agreement: These Terms, along with our Privacy Policy, constitute the entire agreement between you and Fans Arena regarding your use of the App.\n\n'
                          '- Waiver and Severability: The failure of Fans Arena to enforce any right or provision of these Terms shall not constitute a waiver of such right or provision. If any provision of these Terms is held to be invalid or unenforceable, the remaining provisions of these Terms will remain in full force and effect.',
                    ),
                  ],
                ),
              ),
            )),
            Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: Checkbox(
                    value: value,
                    onChanged: (bool? valu) {
                      setState(() {
                        value=!value;
                      });
                    },
                  ),),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'A verification email has been sent to your email address. Please check your inbox and verify your email to complete the registration process.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.325,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 30),
                  side: const BorderSide(
                    color: Colors.grey,),),
                onPressed: () {

                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Continue",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContiFP1 extends StatefulWidget {
  final String userId;
  final String username;
  const ContiFP1({super.key, required this.userId,required this.username});

  @override
  State<ContiFP1> createState() => _ContiFP1State();
}

class _ContiFP1State extends State<ContiFP1> {
  String? _selectedGender;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final TextEditingController genrecontroller = TextEditingController();
  DateTime? _selectedDate;
  @override
  void initState(){
    super.initState();
    widget.userId;

  }
  final formKey = GlobalKey<FormState>();
  Future<void> saveDataToFirestore() async {
    if(formKey.currentState!.validate()){
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
                  Text('Saving data...'),
                ],
              ),
            ),
          );
        },
      );
      final birthday = _selectedDate?.copyWith();
      final gender = _selectedGender ?? '';
      try {
        QuerySnapshot querySnapshot = await firestore
            .collection('Clubs')
            .where('Clubid', isEqualTo: widget.userId)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var documentSnapshot = querySnapshot.docs[0];
          var oldData = documentSnapshot.data() as Map<String, dynamic>;

          Map<String, dynamic> newData = {};
          final genre = genrecontroller.text;
          final int? year = birthday?.year;
          final int? month = birthday?.month;
          final int? day = birthday?.day;
          Timestamp createdAt = Timestamp.now();
          if (year != null && month != null && day != null) {
            final wholeDate = DateTime(year, month, day);

            if (wholeDate
                .toIso8601String()
                .isNotEmpty && wholeDate != oldData['foundedday']) {
              newData['foundedday'] = wholeDate;
            }
          }
          if (genre.isNotEmpty && genre != oldData['genre']) {
            newData['genre'] = genre;
          }
          if (createdAt != oldData['logintime']) {
            newData['logintime'] = createdAt;
          }
          if (createdAt != oldData['createdAt']) {
            newData['createdAt'] = createdAt;
          }
          if (newData.isNotEmpty) {
            await documentSnapshot.reference.update(newData);
            await back();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Bottomnavbar()),
                  (Route<dynamic> route) => false,
            );
            print('Data saved successfully');
          } else {
            print('No changes to update');
          }
        } else {
          print('No matching document found.');
        }
      } catch (e) {
        print('Error saving data: $e');
      }
    }
  }
  Future<void>back()async{
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.utc(2050),
    );
    if (picked != null && picked != _selectedDate) {
      final pickedDateWithoutTime = DateTime(picked.year, picked.month, picked.day);
      setState(() {
        _selectedDate = pickedDateWithoutTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: const Text(
          'Additional Account Information',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black,size: 33,),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'required';
                  }
                  return null;},
                onTap: () {
                  _selectDate(context);
                },
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  labelText: 'Date the club was founded',
                ),
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? "${_selectedDate!.toLocal()}".split(' ')[0]
                      : '',
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'required';
                  }
                  return null;},
                controller: genrecontroller,
                readOnly: true,
                onTap: (){
                  showModalBottomSheet(
                    isScrollControlled: true,
                    isDismissible: true,
                    backgroundColor: Colors.transparent,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                    context: context,
                    builder: (BuildContext context) {
                      return Genrescreen( onNextPage: (genr) {
                        setState(() {
                          genrecontroller.text = genr;
                        });});
                    },
                  );
                },

                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(width: 1, color: Colors.black),
                    ),
                    focusedBorder:  OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(width: 1, color: Colors.black),
                    ),
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.black,
                      fontSize: 20, fontWeight: FontWeight.normal,),
                    fillColor: Colors.white70,

                    labelText: 'Genre'
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 35,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(

                      minimumSize: const Size(0, 30),
                      side: const BorderSide(
                        color: Colors.grey,
                      )),
                  onPressed:() => saveDataToFirestore(),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Continue", style: TextStyle(color: Colors.black)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}