import 'package:fans_arena/appid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:firebase_auth/firebase_auth.dart';
import '../../main.dart';
import '../components/bottomnavigationbar.dart';
import '../screens/notifications.dart';
import 'newsfeedmodel.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class LocalNotificationManager {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<bool?> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    bool? initialized = await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationClick,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationClick,
    );

    return initialized;
  }

  Future<void> showNotification({
    int id = 0,
    String title = '',
    String body = '',
    String payload = '',
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }
  int generateRandomUid() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }
  Future<void> scheduledNotification({
    int id = 0,
    String title = '',
    String body = '',
    String payload = '',
    required DateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id',
      'Your Channel Name',
      channelDescription: 'Your Channel Description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    id = generateRandomUid();
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      payload: payload,
      androidAllowWhileIdle: true,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

void onNotificationClick(NotificationResponse response) async {
  navigatorKey.currentState?.push(MaterialPageRoute(
    builder: (context) =>  const NotificationsScreen(allnotifications: [], hroute: false,),
  ));
}

void onBackgroundNotificationClick(NotificationResponse response) async {
  navigatorKey.currentState?.push(MaterialPageRoute(
    builder: (context) =>  const NotificationsScreen(allnotifications: [],hroute: false,),
  ));
}
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  _firebaseMessaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // Handle the background message, e.g., show a notification
}
class NotifyFirebase {
  Newsfeedservice news = Newsfeedservice();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final local =flutterLocalNotificationsPlugin;
final adroidchannel= const AndroidNotificationChannel(
  'high_importance_channel',
    'High Importance Notification',
    description: 'this channel is used for important notifications',
    importance: Importance.defaultImportance
    );
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
  Future<void> initNotifications() async {
    showToastMessage('Initializing notifications');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
       collectionNamefor = prefs.getString('cname')?? '';
     String fcmToken = prefs.getString('fcmToken')?? '';
      if (collectionNamefor.isEmpty) {
        collectionNamefor = await news.getAccount(FirebaseAuth.instance.currentUser!.uid);
        showToastMessage('fetching collection name');
      }
      DocumentSnapshot documentSnapshot= await FirebaseFirestore.instance.collection("${collectionNamefor}s").doc(FirebaseAuth.instance.currentUser!.uid).get();
     await  _setCurrentLocation(documentSnapshot.reference);
    } catch (error) {
      showToastMessage('Error initializing notifications: $error');
      // Handle error as needed
    }
  }

Future<void>signOut(BuildContext context)async{
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      showToastMessage('saving data');
      final String url ='$baseUrl/addSignOutData';
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  if (collectionNamefor.isEmpty) {
    collectionNamefor = await news.getAccount(userId!);
    showToastMessage('collection is empty');
  }
    Map<String, dynamic> data = {
      'collection':"${collectionNamefor}s",
      'userId':userId,
    };
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode(data),
  );
  if (response.statusCode == 200) {
    print('Data added successfully.');
    showToastMessage(response.statusCode.toString());
    showToastMessage('success updating doc');
    prefs.clear();
    showToastMessage('success in clearing preference');
    await FirebaseMessaging.instance.deleteToken();
    showToastMessage('success in deleting token');
    await FirebaseAuth.instance.signOut();
    showToastMessage('success in signing out');
    navigateBottomBar(context);
  } else {
    print('Failed to add data: ${response.body}');
    showToastMessage(response.statusCode.toString());
  }
  }catch(e){
    showToastMessage('error:$e');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("An error occured during logging out"),
          content: Text("$e")
        );
      },
    );
    }
}


Future<void>saveSingIn(Map<String,dynamic>data,BuildContext context)async{
  final String url ='$baseUrl/addSignInData';
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      print('Data added successfully.');
      showToastMessage(response.statusCode.toString());
      NotifyFirebase().notify();
      NotifyFirebase().loginNotification(data['userId']);
      navigateBottomBar(context);
      showToastMessage("success");
    } else {
      print('Failed to add data: ${response.body}');
      showToastMessage(response.statusCode.toString());
    }
  } catch (e) {
    print('Error: $e');
    showToastMessage(e.toString());
  }
}
  void navigateBottomBar(BuildContext context)async{
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottomnavbar()),
          (Route<dynamic> route) => false,
    );
  }
  Future<String?> requestFCMToken() async {
    try {
      await firebaseMessaging.requestPermission();
      return await firebaseMessaging.getToken();
    } catch (error) {
      showToastMessage('Error requesting FCM token: $error');
      return null;
    }
  }
  Future<void> sendChatToCloudFunction(Map<String, dynamic> chatData) async {
    const String cloudFunctionUrl = 'YOUR_CLOUD_FUNCTION_URL';
    final String jsonData = jsonEncode(chatData);
    try {
      final response = await http.post(
        Uri.parse(cloudFunctionUrl),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        print('Chat sent successfully');
        showToastMessage(response.statusCode.toString());
      } else {
        print('Failed to send chat. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error sending chat: $error');
    }
  }




  Future<void> _setCurrentLocation(DocumentReference collectionRef) async {
    try {
      final Timestamp createdAt = Timestamp.now();
      Position location = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      double clongitude=location.longitude;
      double clatitude=location.latitude;
      final doc= await collectionRef.get();
      if(doc.exists){
        var oldData=doc.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (createdAt != oldData['ctimestamp']) {
          newData['ctimestamp'] = createdAt;
        }
        if(clongitude!=oldData['clogitude']){
          newData['clongitude']=clongitude;
        }
        if(clatitude!=oldData['clatitude']){
          newData['clatitude']=clatitude;
        }
        if (newData.isNotEmpty) {
          await doc.reference.update(newData);
        }
      }
      showToastMessage('current location added');
    } catch (error) {
      showToastMessage('Error setting current location: $error');
    }
  }

  int generateRandomUid() {
    Random random = Random();
    return 100000 + random.nextInt(900000);
  }
  Future<void>notify()async{
    try {
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        sound: true,
        badge: true,
      );
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        try {
          final notif = message.ttl;
          int id = generateRandomUid();
          if (notif == null) return;
          AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
              adroidchannel.id,
              adroidchannel.name,
              channelDescription: adroidchannel.description,
              importance: adroidchannel.importance,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher'
          );

          NotificationDetails platformChannelSpecifics = NotificationDetails(
              android: androidPlatformChannelSpecifics);
              local.show(
              id,
              message.notification?.title,
              message.notification?.body,
              platformChannelSpecifics,
              payload: jsonEncode(message.toMap())
          );
          showToastMessage("notification recieved");
        }catch(e){
          showToastMessage("error:$e");
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        try{
        final notif = message.ttl;
        int id = generateRandomUid();
        if (notif == null) return;
        AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
          adroidchannel.id,
          adroidchannel.name,
          channelDescription: adroidchannel.description,
          importance: adroidchannel.importance,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        );

        NotificationDetails platformChannelSpecifics = NotificationDetails(
            android: androidPlatformChannelSpecifics);
            local.show(
            id,
            message.notification?.title,
            message.notification?.body,
            platformChannelSpecifics,
            payload: jsonEncode(message.toMap())
        );
        showToastMessage("notification recieved");
        }catch(e){
          showToastMessage("error:$e");
        }
      });
      FirebaseMessaging.instance.getInitialMessage().then((value) =>
          handleMessage(value!));
      showToastMessage('notifications  initialized');
    }catch(e){
      showToastMessage('notifications not initialized, error:$e');
    }
  }
 void handleMessage(RemoteMessage message){
    navigatorKey.currentState?.pushNamed(
      NotificationsScreen.route,
      arguments: message,
    );
 }


Future initLocalNotification()async{
    const android=AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings=InitializationSettings(android: android,);
  local.initialize(
    settings,
  );

}
  String baseUrl='https://us-central1-fans-arena.cloudfunctions.net';
void sendfollowingNotifications(String currentuserId,otherId)async{
try{
  final response = await http.get(Uri.parse('$baseUrl/sendfollowingNotifications?uid1=$currentuserId&uid2=$otherId'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    showToastMessage('${response.statusCode}');
  } else {
    throw Exception('Failed to sendfollowingnotification1');
  } }catch(e){
  showToastMessage(e.toString());
  }
}

  void sendcommentNotifications(String from,String to,String postId,String commentId,String comment,String event)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/sendcommentNotifications?commentId=$commentId&comment=$comment&postId=$postId&from=$from&to=$to&event=$event'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to sendcommentNotifications');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }
  void sendInvitationNotification(String from,String to,String message)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/sendInvitationNotification?from=$from&to=$to&$message'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to sendInvitationNotification');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }

  void sendlikedNotifications(String from,String to,String postId,String event)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/sendlikedNotifications?postId=$postId&from=$from&to=$to&event=$event'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to sendlikedNotifications');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }
  void sendreplyNotifications(String from,String to,String postId,String commentId,String comment,String event)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/sendreplyNotifications?replyId=$commentId&reply=$comment&postId=$postId&from=$from&to=$to&event=$event'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to sendreplyNotifications');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }

  void loginNotification (String userId)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/loginNotification?uid=$userId'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to loginNotification ');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }

void sendnewfanNotifications(String currentuserId,String otherId)async{
try{
  final response = await http.get(Uri.parse('$baseUrl/sendnewfanNotifications?uid1=$currentuserId&uid2=$otherId'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    showToastMessage('${response.statusCode}');
  } else {
    throw Exception('Failed to sendnewfanNotifications');
  }
}catch(e){
  showToastMessage(e.toString());
  }
}
void sendnewfanPNotifications(String currentuserId,String otherId)async{
try{
  final response = await http.get(Uri.parse('$baseUrl/sendnewfanPNotifications?uid1=$currentuserId&uid2=$otherId'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    showToastMessage('${response.statusCode}');
  } else {
    throw Exception('Failed to sendnewfanPNotifications');
  } }catch(e){
  showToastMessage(e.toString());
  }
}
void sendOnliveNotifications(String authorId,String matchId,String event)async{
try{
  final response = await http.get(Uri.parse('$baseUrl/sendOnliveNotifications?uid=$authorId&eventId=$matchId&event=$event'));
  if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
    showToastMessage('${response.statusCode}');
  } else {
    throw Exception('Failed to sendmatchstartednotification');
  } }catch(e){
  showToastMessage(e.toString());
  }
}

  void sendmatchlineupNotifications(String authorId,String matchId)async{
    try{
      final response = await http.get(Uri.parse('$baseUrl/sendmatchlineupNotifications?uid=$authorId&matchId=$matchId'));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        showToastMessage('${response.statusCode}');
      } else {
        throw Exception('Failed to sendmatchlineupNotifications');
      } }catch(e){
      showToastMessage(e.toString());
    }
  }

  Future<void> sendleaguesmatchcreated(String leagueId,String matchId,String club1Id,String club2Id)async{
  try {
    final response = await http.get(Uri.parse(
        '$baseUrl/sendleaguematchcreatedNotifications?leagueId=$leagueId&matchId=$matchId&club1=$club1Id&club2=$club2Id'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      showToastMessage('${response.statusCode}');
    } else {
      showToastMessage('Failed to sendleaguesmatchcreated');
    }
  }catch (e){
    showToastMessage('Failed to sendleaguesmatchcreated:$e');
  }
}
  Future<void> sendStreamingInvite(List<String> userIds,String userId,String event,String matchId)async{
    String userIdsString = userIds.join(',');
    try {
    final response = await http.get(Uri.parse(
        '$baseUrl/sendinviteNotifications?uids=$userIdsString&userId=$userId&event=$event&matchId=$matchId'));
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      showToastMessage('${response.statusCode}');
    } else {
      showToastMessage('Failed to send streaming invite');
    }
    }catch (e){
      showToastMessage('Failed to send streaming invite:$e');
    }
  }
  Future<void> sendMessageToUser(String toToken, String title, String body) async {

    final Map<String, dynamic> data = {
      'notification': {
        'title': title,
        'body': body,
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'priority': 'high',
      'to': toToken,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$fcmserverkey',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Message sent successfully
    } else {
      // Handle error
      print('Error sending FCM message: ${response.statusCode}');
    }
  }

  Future<void> sendFollowNotification(String toUserID, String fromUserID) async {
    DocumentSnapshot recipientDoc = await FirebaseFirestore.instance.collection('Fans').doc(toUserID).get();
    if (!recipientDoc.exists) {
      return;
    }
    String? recipientToken = recipientDoc['fcmToken'];
    final Map<String, dynamic> data = {
      'notification': {
        'title': 'New Follower',
        'body': 'You have a new follower!',
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'priority': 'high',
      'to': recipientToken,
    };

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$fcmserverkey',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Message sent successfully
    } else {
      // Handle error
      print('Error sending FCM message: ${response.statusCode}');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');


      }
    });
  }
}

class Sendnotification {
  String from;
  String to;
  String message;
  String content;
  String notifiId;
  String collection;
  Sendnotification({
    required this.from,
    required this.to,
    required this.message,
    required this.content,
    this.notifiId='',
    this.collection='',
  });
  Newsfeedservice news = Newsfeedservice();

  String generateUniqueNotificationId() {
    // You can use a library like uuid or generate IDs based on a timestamp
    // Here, I'm using the uuid package to generate a unique ID
    final String uniqueId = const Uuid().v4(); // You need to import the uuid package

    return uniqueId;
  }
  Future<void> sendnotification() async {
    if(collection.isEmpty) {
      collection = await news.getAccount(to);
    }
    final matchesCollection = FirebaseFirestore.instance.collection("${collection}s").doc(to).collection('notifications');
    try {
      notifiId = generateUniqueNotificationId();
      final QuerySnapshot querySnapshot = await matchesCollection.get();
      final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      final DocumentSnapshot latestDoc = documents.first;
      final List<Map<String, dynamic>>? chats = (latestDoc['notifications'] as List?)
          ?.cast<Map<String, dynamic>>();
      Timestamp createdAt = Timestamp.now();
      if (from.isNotEmpty && to.isNotEmpty && from != to) {
        final notifi={
          'NotifiId': notifiId,
          'from': from,
          'to': to,
          'message': message,
          'content': content,
          'createdAt': createdAt,
        };
        if(chats!=null) {
          chats.add(notifi);
          if(chats.length>5000){
            matchesCollection.add({
              "notifications":[notifi],
            });
          }else{
            latestDoc.reference.update({
              "notifications":chats,
            });
          }
        }
      }
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }

  void Deletenotification() {
   // FirebaseFirestore.instance.collection('Notification').where('notifiId', isEqualTo: notifiId).get().then((querySnapshot) {
   //   for (var doc in querySnapshot.docs) {
    //    doc.reference.delete();
     // }
   // });
  }
}




