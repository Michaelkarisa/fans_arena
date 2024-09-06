import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fans_arena/fans/data/notificationsmodel.dart';
import 'package:fans_arena/joint/filming/data/wozaapi.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:crypto/crypto.dart';
import '../../../appid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class FilmingProvider extends ChangeNotifier{
  final StreamController<String> _eventStreamController = StreamController<String>.broadcast();
  Stream<String> get eventStream => _eventStreamController.stream;
  Mux  mux = Mux();
  App app = App();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String state1='1';
  String state2='1';
  double z=0.0;
  int activeuid=0;
  int uid1=0;
  RtcEngine? _engine;
  RtcEngine? get engine => _engine;
  int uid=0;
 List<int> uids=[];
  double value=0.6;
  int index=1;
  bool localUserJoined=false;
  int remote=0;
  String remoteuser='';
  double v=0.0;
  Map<int, String> uidToPeerIdMap = {};
  void addUser(int uid, String peerId) {
    uidToPeerIdMap[uid] = peerId;
    notifyListeners();
  }
  void setZoom({required double zoom}){
    engine?.setCameraZoomFactor(z+zoom);
    notifyListeners();
  }
  String exception='';
  void setActive({required int active}){
    activeuid=active;
    notifyListeners();
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
bool s=false;
String message='';
bool change=false;
int userMuteVideo=0;
int minBitrate=500;
int bitrate=-1;
int frameRate=20;
String converterId="";
  String token='';
  String token1='';
  bool check=false;
  int seconds1=0;
  Future<void> initAgora({
    required String userId,
    required String matchId,
    required String collection,
  }) async {
    v = 0.1;
    notifyListeners();
    Map<String, dynamic> data = await getData(matchId, collection);
    token = data['token'];
    token1 = data['token1'];
    seconds1 = data['seconds'];
    check = data['check'];
    authorId = data['authorId'];
    converterId = data['converterId'];
    streamkey = data['streamkey'];
    v = 0.2;
    notifyListeners();
    if(_engine==null) {
      _engine = createAgoraRtcEngine();
      await [Permission.microphone, Permission.camera].request();
      uids.clear();
      v = 0.3;
      notifyListeners();

      await _engine?.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ));
    }
    v = 0.4;
    notifyListeners();
    _engine?.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed)async {
            uids.clear();
            addUser(connection.localUid!, userId);
            activeuid = connection.localUid!;
            uid1 = connection.localUid!;
            uids.add(connection.localUid!);
            localUserJoined = true;
            notifyListeners();
            await updateUser(connection.localUid!, matchId, collection);
            _eventStreamController.add('Joined channel');
            notifyListeners();
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            remote = remoteUid;
            _eventStreamController.add('User $remoteUid joined');
            uids.add(remoteUid);
            addUser(remoteUid, userId);
            notifyListeners();
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            uidToPeerIdMap.remove(remoteUid);
            _eventStreamController.add('User $remoteUid left');
            uids.remove(remoteUid);
            notifyListeners();
          },
          onTokenPrivilegeWillExpire: (RtcConnection connection, String t) async {
            _eventStreamController.add('Token renewed');
            message = 'Session Expired';
            Map<String, dynamic> data = await app.fetchToken(matchId);
            t = data['token'];
            token = data['token'];
            token1 = data['token1'];
            await updateToken(token, token1, matchId, collection);
            message = '';
            notifyListeners();
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType type, ConnectionChangedReasonType reason) {
            message = reason.name;
            _eventStreamController.add('Connection state changed: $message');
            notifyListeners();
          },
          onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
            _eventStreamController.add('User $uid ${muted ? 'muted' : 'unmuted'} video');
            userMuteVideo = muted ? uid : 0;
            notifyListeners();
          }
      ),
    );

    v = 0.5;
    notifyListeners();
    await _engine?.enableVideo();
    v = 0.6;
    notifyListeners();
    await _engine?.startPreview(sourceType: change ? VideoSourceType.videoSourceCustom : VideoSourceType.videoSourceCamera);
    v = 0.7;
    notifyListeners();
    if (!s) {
      await _engine?.switchCamera();
      s = true;
    }
    v = 0.8;
    notifyListeners();
    await _engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    v = 0.85;
    notifyListeners();
    await _engine?.setVideoEncoderConfiguration(VideoEncoderConfiguration(
      degradationPreference: DegradationPreference.maintainQuality,
      bitrate: bitrate,
      frameRate: frameRate,
      minBitrate: 200,
      orientationMode: OrientationMode.orientationModeFixedLandscape,
    ));
    v = 0.9;
    notifyListeners();
    if(!localUserJoined) {
      try {
        await _engine?.joinChannel(
          token: token,
          channelId: matchId,
          uid: 0,
          options: const ChannelMediaOptions(
              channelProfile: ChannelProfileType
                  .channelProfileLiveBroadcasting),
        );
        _eventStreamController.add('Joined channel');
        showToastMessage('Joined channel');
        v = 1.0;
        notifyListeners();
      } catch (e) {
        _eventStreamController.add('Error joining channel: $e');
        showToastMessage('error joining channel: $e');
        notifyListeners();
      }
    }
    notifyListeners();
  }
  @override
  void dispose() {
    _eventStreamController.close();
    _engine?.leaveChannel();
    super.dispose();
  }
  Future<Map<String, dynamic>> getData(String matchId, String collection) async {
    v = 0.1;
    Map<String, dynamic> data1 = {};
    notifyListeners();
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(matchId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        Timestamp timestamp = data.containsKey('tokentimestamp') ? data['tokentimestamp'] : Timestamp.now();
        String converter = data.containsKey('converterId') ? data['converterId'] : '';
        String authorrId = data['authorId'];
        String tokenn = data.containsKey('token') ? data['token'] : '';
        String tokenn1 = data.containsKey('token1') ? data['token1'] : '';
        String streamk = data.containsKey('streamkey') ? data['streamkey'] : "";

        int secondss = DateTime.now().difference(timestamp.toDate()).inSeconds;

        if (tokenn1.isEmpty || tokenn.isEmpty || secondss > 7200) {
          Map<String, dynamic> data0 = await app.fetchToken(matchId);
          tokenn = data0['token'];
          tokenn1 = data0['token1'];

          Map<String, dynamic> newData = {};

          if (tokenn.isNotEmpty && tokenn != data['token']) {
            newData['token'] = tokenn;
          }
          if (tokenn1.isNotEmpty && tokenn1 != data['token1']) {
            newData['token1'] = tokenn1;
          }
          if (tokenn.isNotEmpty && tokenn != data['token']) {
            newData['tokentimestamp'] = Timestamp.now();
          }
          //showToastMessage("$tokenn");
          //showToastMessage("$tokenn1");
          notifyListeners();
          if (newData.isNotEmpty) {
            await documentSnapshot.reference.update(newData);
            showToastMessage('Data saved successfully');
          } else {
            showToastMessage('No changes to update');
          }
        }
        data1 = {
          'seconds': secondss,
          'token': tokenn,
          'converterId': converter,
          'authorId': authorrId,
          'check': streamk.isNotEmpty,
          'streamkey': streamk,
          'token1': tokenn1,
        };
        notifyListeners();
        return data1;
      } else {
        print('No matching document found.');
        return data1;
      }
    } catch (e) {
      return data1;
    }
  }

  String url='';
  Future<void> updateUrls({required String matchId,
    required String collection}) async {
    LiveStream live = await mux.createStream();
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(matchId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        for ( var playbackId in live.playbackIds){
         url="https://stream.mux.com/${playbackId.id}";
        Map<String, dynamic> newData = {};
        if(collection=="Matches") {
          if (url.isNotEmpty && url != oldData['matchUrl']) {
            newData['matchUrl'] = url;
          }
        }else{
          if (url.isNotEmpty && url != oldData['eventUrl']) {
            newData['eventUrl'] = url;
          }
        }
        if (live.streamKey.isNotEmpty && live.streamKey != oldData['streamkey']) {
          newData['streamkey'] = live.streamKey;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          check=true;
          print('Data saved successfully');
          notifyListeners();
        } else {
          print('No changes to update');
        }}
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
    notifyListeners();
  }

  Future<void>upDate(
      String rtcChannel,
      int rtcUid)async{
      String url =
          'https://api.agora.io/eu/v1/projects/$appId/rtmp-converters/$converterId';
      var requestBody = {
        "converter": {
          "transcodeOptions": {
            "rtcChannel": rtcChannel,
            "videoOptions": {
              "canvas": {"width": 1280, "height": 720},
              "layout": [
                {
                  "rtcStreamUid": rtcUid,
                  "region": {"xPos": 0, "yPos": 0, "zIndex": 1, "width": 1280, "height": 720},
                  "fillMode": "fill",
                  "placeholderImageUrl": "http://example.agora.io/host_placeholder.jpg"
                },
                {
                  "imageUrl": "http://example.agora.io/host_placeholder.jpg",
                  "region": {"xPos": 0, "yPos": 0, "zIndex": 1, "width": 1280, "height": 720},
                  "fillMode": "fill"
                }
              ]
            }
          }
        },
        "fields": "transcodeOptions.videoOptions.canvas,transcodeOptions.videoOptions.layout"
      };

      try {
        String plainCredentials = agorakey + ":" + agorasecret;
        String base64Credentials = base64.encode(utf8.encode(plainCredentials));
        String authorizationHeader = "Basic " + base64Credentials;
        var response = await http.patch(
          Uri.parse(url),
          headers: {
            'Authorization': authorizationHeader,
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
        if (response.statusCode == 200) {
          showToastMessage('Transcoding settings updated successfully');
        } else {
          showToastMessage('Failed to update transcoding settings. Status code: ${response.statusCode}');
        }
      } catch (error) {
        showToastMessage('Error: $error');
      }
   notifyListeners();
  }
  Future<void> deleteRtmpConverter() async {
    String url = "https://api.agora.io/eu/v1/projects/$appId/rtmp-converters/$converterId";
    try {
      var response = await http.delete(
        Uri.parse(url),
      );
      if (response.statusCode == 200) {
        showToastMessage('RTMP Converter deleted successfully');
      } else {
        showToastMessage('Failed to delete RTMP Converter. Status code: ${response.statusCode}');
      }
    } catch (error) {
      showToastMessage('Error: $error');
    }
  }
  Future<void> streamToSocialMedia(String channelId,String collection,String authorId) async {
    String url = "https://api.agora.io/eu/v1/projects/$appId/rtmp-converters";
    String rtmp="rtmp://global-live.mux.com:5222/app/$streamkey";
    String rtmp1="rtmp://a.rtmp.youtube.com/live2/qf22-zaja-32tt-44sb-8c5u";
    var postBody = {
      "converter": {
        "name": "${channelId}_vertical",
        "transcodeOptions": {
          "rtcChannel": channelId,
          "token": token,
          "audioOptions": {
            "codecProfile": "LC-AAC",
            "sampleRate": 48000,
            "bitrate": 30,
            "audioChannels": 1,
          },
          "videoOptions": {
            "canvas": {"width": 1280, "height": 720},
            "fillMode": "fit",
            "layout": [
              {
                "rtcStreamUid": uid1,
                "region": {
                  "xPos": 0,
                  "yPos": 0,
                  "zIndex": 1,
                  "width": 1280,
                  "height": 720
                },
                "fillMode": "fit",
                "placeholderImageUrl": "http://example.agora.io/user_placeholder.jpg",
                "seiOptions": {
                  "source": {
                    "metadata": true,
                    "datastream": true,
                    "customized": {"payload": "example"}
                  },
                  "sink": {"type": 100}
                }
              },
              {
                "rtcStreamUid": uid1,
                "region": {
                  "xPos": 0,
                  "yPos": 0,
                  "zIndex": 1,
                  "width":1280,
                  "height": 720
                },
                "fillMode": "fit",
              }
            ],
            "codecProfile": "baseline",
            "frameRate": 15,
            "gop": 30,
            "bitrate": 400,
            "seiOptions": {
              "source": {
                "metadata": true,
                "datastream": true,
                "customized": {"payload": "example"}
              },
            }
          }
        },
        "rtmpUrl": rtmp,
        "idleTimeOut": 60
      }
    };
    String plainCredentials = agorakey + ":" + agorasecret;
    String base64Credentials = base64.encode(utf8.encode(plainCredentials));
    String authorizationHeader = "Basic " + base64Credentials;
    var response = await http.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.authorizationHeader: authorizationHeader,
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode(postBody),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      Map<String, dynamic> converterData = responseData['converter'];
       converterId = converterData['id'];
      int createTs = converterData['createTs'];
      int updateTs = converterData['updateTs'];
      String state = converterData['state'];
      String r= await mux.enableLiveStream(streamkey);
      if(r=="200"||r=="201"){
        showToastMessage('mux stream enabled');
      }else{
        showToastMessage('mux stream error:$r');
      }
      updateConverterId(converterId,channelId,collection);
      NotifyFirebase().sendOnliveNotifications(authorId, channelId,collection=="Matches"?"Match":"Event");
      showToastMessage('started rtmp streaming');
    } else {
      showToastMessage('Failed to create RTMP Converter. Status code: ${response.statusCode}');
    }
  }

  Future<void> updateUser(int users,String matchId,String collection) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(matchId)
          .collection('streamers')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if ( users != oldData['uid']) {
          newData['uid'] = users;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          print('Data saved successfully');
          showToastMessage("streamer updated");
        } else {
          showToastMessage("no changes to update");
          print('No changes to update');
        }
      } else {
        showToastMessage("no matching document found.");
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
      showToastMessage("failed:$e");
    }
  }
  String streamkey='';
  String authorId='';

  Future<void> updateToken(String token,String token1,String matchId,String collection) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(matchId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if ( token != oldData['token']) {
          newData['token'] = token;
        }
        if ( token1 != oldData['token1']) {
          newData['token1'] = token1;
        }
        if ( Timestamp.now()!= oldData['tokentimestamp']) {
          newData['tokentimestamp'] = Timestamp.now();
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          notifyListeners();
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
        notifyListeners();
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  Future<void> updateConverterId(String converterId,String matchId,String collection) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(matchId)
          .get();
      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if ( converterId != oldData['converterId']) {
          newData['converterId'] = converterId;
        }
        if ( Timestamp.now()!= oldData['convertertimestamp']) {
          newData['convertertimestamp'] = Timestamp.now();
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          notifyListeners();
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
        notifyListeners();
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }




  Future<void> updateUser1(int user,String matchId,String collection) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(matchId)
          .get();

      if (documentSnapshot.exists) {
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if ( user != oldData['activeuser']) {
          newData['activeuser'] = user;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
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
  Stopwatch stopwatch = Stopwatch();
  late Timer timer;
  int seconds = 0;

  void startTimerFromTimestamp(int timestampDifference) {
    stopwatch.start();
    timer = Timer.periodic(const Duration(microseconds: 1), (_) {
      seconds = stopwatch.elapsed.inSeconds + timestampDifference;
      notifyListeners();
    });

  }

  Future<void> fetchTimestampAndStartTimer({required String matchId,required String collection}) async {
    DocumentSnapshot timestampSnapshot = await FirebaseFirestore.instance
        .collection(collection)
        .doc(matchId)
        .get();

    if (timestampSnapshot.exists&&pausetime.isEmpty) {
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime currentTime = DateTime.now();
      Duration difference = currentTime.difference(startTime);
      int timestampDifference = difference.inSeconds;
      seconds = timestampDifference;
      startTimerFromTimestamp(timestampDifference);
      print('$timestampDifference');
      notifyListeners();

    }else if(timestampSnapshot.exists&&pausetime.isNotEmpty){
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      Duration difference = startTime1.difference(startTime);
      int timestampDifference = difference.inSeconds;
      DateTime currentTime = DateTime.now();
      Duration difference1 = currentTime.difference(startTime2);
      int timestampDifference1 = difference1.inSeconds;
      int t = timestampDifference + timestampDifference1;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    }else if(timestampSnapshot.exists&&pausetime1.isNotEmpty){
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      DateTime currentTime = DateTime.now();
      Duration difference2 = currentTime.difference(startTime4);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int t = timestampDifference + timestampDifference1 + timestampDifference2;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    }else if(timestampSnapshot.exists&&pausetime2.isNotEmpty){
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      Timestamp timestampFromFirebase5 = timestampSnapshot['pausetime2'] as Timestamp;
      Timestamp timestampFromFirebase6 = timestampSnapshot['resumetime2'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      DateTime startTime5 = timestampFromFirebase5.toDate();
      DateTime startTime6 = timestampFromFirebase6.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      Duration difference2 = startTime5.difference(startTime4);
      DateTime currentTime = DateTime.now();
      Duration difference3 = currentTime.difference(startTime6);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int timestampDifference3 = difference3.inSeconds;
      int t = timestampDifference + timestampDifference1 + timestampDifference2 + timestampDifference3;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    }else if(timestampSnapshot.exists&&pausetime3.isNotEmpty){
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      Timestamp timestampFromFirebase5 = timestampSnapshot['pausetime2'] as Timestamp;
      Timestamp timestampFromFirebase6 = timestampSnapshot['resumetime2'] as Timestamp;
      Timestamp timestampFromFirebase7 = timestampSnapshot['pausetime3'] as Timestamp;
      Timestamp timestampFromFirebase8 = timestampSnapshot['resumetime3'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      DateTime startTime5 = timestampFromFirebase5.toDate();
      DateTime startTime6 = timestampFromFirebase6.toDate();
      DateTime startTime7 = timestampFromFirebase7.toDate();
      DateTime startTime8 = timestampFromFirebase8.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      Duration difference2 = startTime5.difference(startTime4);
      Duration difference3 = startTime7.difference(startTime6);
      DateTime currentTime = DateTime.now();
      Duration difference4 = currentTime.difference(startTime8);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int timestampDifference3 = difference3.inSeconds;
      int timestampDifference4 = difference4.inSeconds;
      int t = timestampDifference + timestampDifference1 + timestampDifference2 + timestampDifference3 + timestampDifference4;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    }else if(timestampSnapshot.exists&&pausetime4.isNotEmpty){
      Timestamp timestampFromFirebase = timestampSnapshot['starttime'] as Timestamp;
      Timestamp timestampFromFirebase1 = timestampSnapshot['pausetime'] as Timestamp;
      Timestamp timestampFromFirebase2 = timestampSnapshot['resumetime'] as Timestamp;
      Timestamp timestampFromFirebase3 = timestampSnapshot['pausetime1'] as Timestamp;
      Timestamp timestampFromFirebase4 = timestampSnapshot['resumetime1'] as Timestamp;
      Timestamp timestampFromFirebase5 = timestampSnapshot['pausetime2'] as Timestamp;
      Timestamp timestampFromFirebase6 = timestampSnapshot['resumetime2'] as Timestamp;
      Timestamp timestampFromFirebase7 = timestampSnapshot['pausetime3'] as Timestamp;
      Timestamp timestampFromFirebase8 = timestampSnapshot['resumetime3'] as Timestamp;
      Timestamp timestampFromFirebase9 = timestampSnapshot['pausetime4'] as Timestamp;
      Timestamp timestampFromFirebase10 = timestampSnapshot['resumetime4'] as Timestamp;
      DateTime startTime = timestampFromFirebase.toDate();
      DateTime startTime1 = timestampFromFirebase1.toDate();
      DateTime startTime2 = timestampFromFirebase2.toDate();
      DateTime startTime3 = timestampFromFirebase3.toDate();
      DateTime startTime4 = timestampFromFirebase4.toDate();
      DateTime startTime5 = timestampFromFirebase5.toDate();
      DateTime startTime6 = timestampFromFirebase6.toDate();
      DateTime startTime7 = timestampFromFirebase7.toDate();
      DateTime startTime8 = timestampFromFirebase8.toDate();
      DateTime startTime9 = timestampFromFirebase9.toDate();
      DateTime startTime10 = timestampFromFirebase10.toDate();
      Duration difference = startTime1.difference(startTime);
      Duration difference1 = startTime3.difference(startTime2);
      Duration difference2 = startTime5.difference(startTime4);
      Duration difference3 = startTime7.difference(startTime6);
      Duration difference4 = startTime9.difference(startTime8);
      DateTime currentTime = DateTime.now();
      Duration difference5 = currentTime.difference(startTime10);
      int timestampDifference = difference.inSeconds;
      int timestampDifference1 = difference1.inSeconds;
      int timestampDifference2 = difference2.inSeconds;
      int timestampDifference3 = difference3.inSeconds;
      int timestampDifference4 = difference4.inSeconds;
      int timestampDifference5 = difference5.inSeconds;
      int t = timestampDifference + timestampDifference1 + timestampDifference2 + timestampDifference3 + timestampDifference4 + timestampDifference5;
      seconds = t;
      startTimerFromTimestamp(t);
      print('$timestampDifference');
      notifyListeners();
    }

  }
  String pausetime='';
  String pausetime1='';
  String pausetime2='';
  String pausetime3='';
  String pausetime4='';
  String stoptime='';
  int duration=0;
  bool isstart=false;
  bool ispaused=false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<DocumentSnapshot> _stream;
  late Stream<DocumentSnapshot> _stream1;
  void onPause0({required String matchId,required String collection}) {
    _stream1 = _firestore.collection(collection).doc(matchId).snapshots();
    _stream1.listen((snapshot) {
      Timestamp newValue = (snapshot.data() as Map<String, dynamic>)['pausetime']as Timestamp;
      Timestamp newValue0 = (snapshot.data() as Map<String, dynamic>)['pausetime1']as Timestamp;
      Timestamp newValue2 = (snapshot.data() as Map<String, dynamic>)['pausetime2']as Timestamp;
      Timestamp newValue3 = (snapshot.data() as Map<String, dynamic>)['pausetime3']as Timestamp;
      Timestamp newValue4 = (snapshot.data() as Map<String, dynamic>)['pausetime4']as Timestamp;
      Timestamp newValue5 = (snapshot.data() as Map<String, dynamic>)['stoptime']as Timestamp;
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['duration'];
      DateTime createdDateTime = newValue.toDate();
      pausetime = DateFormat('d MMM').format(createdDateTime);
      DateTime createdDateTime1 = newValue0.toDate();
      pausetime1 = DateFormat('d MMM').format(createdDateTime1);
      DateTime createdDateTime2 = newValue2.toDate();
      pausetime2 = DateFormat('d MMM').format(createdDateTime2);
      DateTime createdDateTime3 = newValue3.toDate();
      pausetime3 = DateFormat('d MMM').format(createdDateTime3);
      DateTime createdDateTime4 = newValue4.toDate();
      pausetime4 = DateFormat('d MMM').format(createdDateTime4);
      DateTime createdDateTime5 = newValue5.toDate();
      stoptime = DateFormat('d MMM').format(createdDateTime5);
      duration=newValue1 ?? 0;
      notifyListeners();
    });
  }
  bool isenabled=false;
  void onPause2({required String matchId,required String collection}){
    _stream = _firestore.collection(collection).doc(matchId).snapshots();
    _stream.listen((snapshot) {
      final newValue = (snapshot.data() as Map<String, dynamic>)['state1'];
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['state2'];
      if ( newValue == state1 && newValue1 == state2) {
        isstart = true;
        ispaused = true;
        isenabled=true;
        fetchTimestampAndStartTimer(matchId: matchId, collection: collection, );
        notifyListeners();
      }else if(newValue == state1 &&newValue1 != state2){
        isstart = true;
        ispaused = false;
        isenabled=true;
        fetchTimestampAndStartTimer(matchId: matchId, collection: collection, ).then((value) =>stopwatch.stop());
        notifyListeners();
      }else {
        isstart=false;
        ispaused=false;
        isenabled=false;
        stopwatch.stop();
        notifyListeners();
      }
    });
  }
int score=0;
  int scor=0;
  void goals({required String matchId}) {
    _stream = _firestore.collection('Matches').doc(matchId).snapshots();
    _stream.listen((snapshot) async {
      final newValue = (snapshot.data() as Map<String, dynamic>)['score1'];
      final newValue1 = (snapshot.data() as Map<String, dynamic>)['score2'];
      if (score != newValue) {
        score = newValue ?? 0;
        notifyListeners();
      }
      if (scor != newValue1) {
        scor = newValue1 ?? 0;
        notifyListeners();
      }
    });
  }


  bool isrecording=false;
  String recordingPath='';
}

class App {
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
  static String appCertificate = "83dd7a1e12f24a159fb927b5316edf44";
  static int uid = 0;
  static int expirationTimeInSeconds = 7200;
  static String token = "007eJxTYNhU9DLp+qm4IIvVUptWqfRL6J60V7q3jmf1Te8lOpwWBtoKDCnGlgbmJsYpZpaGFiYmlolJhoYpBslGhkZJSWapRolpie8KUxsCGRkq9l1iYmSAQBCfnSE3MzkjMTWHgQEARt8fhA==";
  static  String channel = "michael";
  static String generateToken() {
    int timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + expirationTimeInSeconds;
    String result = buildTokenWithUid(appId, appCertificate, channel, uid, timestamp);
    print(result);
    return result;
  }

  static String buildTokenWithUid(String appId, String appCertificate, String channelName, int uid, int timestamp) {
    List<int> version = [0, 1, 0];
    List<int> unixTs = Uint32List.fromList([timestamp >> 24, timestamp >> 16, timestamp >> 8, timestamp]);
    List<int> randomInt = Uint32List(2);
    randomInt[0] = Random.secure().nextInt(0xFFFFFFFF);
    randomInt[1] = Random.secure().nextInt(0xFFFFFFFF);
    List<int> uidInt = Uint32List.fromList([uid >> 24, uid >> 16, uid >> 8, uid]);
    List<int> message = version + unixTs + randomInt + uidInt;

    Uint8List buffer = Uint8List.fromList(message);
    Hmac hmac = Hmac(sha256, utf8.encode(appCertificate));
    Digest result = hmac.convert(buffer);

    Uint8List signature = Uint8List.fromList(result.bytes);
    Uint8List token = Uint8List.fromList(message + signature);

    return base64Url.encode(token);
  }

  int tokenRole = 1;
  int tokenRole1 = 2;
  int tokenExpireTime = 7200;
  bool isTokenExpiring = false;

  Future<Map<String,dynamic>> fetchToken(String matchId) async {
    try {
      String url = '$tokenserver/rtc/$matchId/${tokenRole.toString()}/uid/${uid
          .toString()}?expiry=${tokenExpireTime.toString()}';
      String url1 = '$tokenserver/rtc/$matchId/${tokenRole1
          .toString()}/uid/${uid.toString()}?expiry=${tokenExpireTime
          .toString()}';
      final response = await http.get(Uri.parse(url));
      final response1 = await http.get(Uri.parse(url1));
      if (response.statusCode == 200 && response1.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);
        Map<String, dynamic> json1 = jsonDecode(response1.body);
        String newToken = json['rtcToken'];
        String newToken1 = json1['rtcToken'];
        showToastMessage("$newToken1");
        showToastMessage("$newToken");
        return {
          "token": newToken,
          "token1": newToken1,
        };;
      } else {
        return {
          "token": "",
          "token1": "",
        };
      }
    }catch(e){
      showToastMessage("$e");
      return {
        "token": "$e",
        "token1": "$e",
      };
    }
  }
 }



