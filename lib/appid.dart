import "dart:async";
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';

import "fans/screens/notifications.dart";
class ApiData {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _stream;
  late final StreamController<Map<String, dynamic>> _controller =
  StreamController<Map<String, dynamic>>();
   String agoraapi='';
  String appIkey='';
   String mConsumerKey='';
   String mConsumerSecret='';
   String newsapikey='';
   String tokenserver='';
   String footballapi='';
   String muxTokenId='';
   String muxTokenSecret='';
   String agorasecret='';
   String agorakey='';
   String fcmTokenServerkey='';
   String mapsApi="";
   String emailApi="";
  ApiData._privateConstructor() {
    _stream = FirebaseFirestore.instance
        .collection('APIS')
        .doc('api')
        .snapshots()
        .asBroadcastStream();
    _stream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        agoraapi = data['agoraapi'];
        appIkey = data['apikey'];
        mConsumerKey = data['mConsumerKey'];
        mConsumerSecret = data['mConsumerSecret'];
        newsapikey = data['newsapikey'];
        tokenserver = data['tokenserver'];
        footballapi = data['footballapi'];
        muxTokenId = data['muxTokenId'];
        muxTokenSecret = data['muxTokenSecret'];
        agorakey=data['agorakey'];
        agorasecret=data['agorasecret'];
        fcmTokenServerkey=data['fcmserverkey'];
        mapsApi=data['mapsApi'];
        emailApi= data['emailApi'];
        _controller.add(data);
      }
    });
  }
  static final ApiData _instance = ApiData._privateConstructor();
  static ApiData get instance => _instance;
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}

class AppData {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _stream;
  late final StreamController<Map<String, dynamic>> _controller =
  StreamController<Map<String, dynamic>>();
   String username='';
   String profileimage='';
   String bio='';//motto,profession
   String website='';
   String email='';
   String collectionName='';
  AppData._privateConstructor() {
    _stream = FirebaseFirestore.instance
        .collection("${collectionNamefor}s")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .asBroadcastStream();
    _stream.listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        username = data['username']??data['Clubname']??data['Stagename']??'';
        profileimage=data['profileimage'];
        _controller.add(data);
      }
    });
  }
  static final AppData _instance = AppData._privateConstructor();
  static AppData get instance => _instance;
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
String collectionNamefor="";
String appId = '';
String appIkey = '';
String mConsumerKey = '';
String mConsumerSecret = '';
String newsapikey = '';
String tokenserver = '';
String footballapi = '';
String muxTokenId = '';
String muxTokenSecret = '';
String agorakey='';
String agorasecret='';
String fcmserverkey='';
String username='';
String profileimage='';
String bio='';//motto,profession
String website='';
String email='';
bool isnonet=false;
String mapsApi='';
String emailApi='';
bool connection=false;