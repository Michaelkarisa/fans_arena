import 'package:http/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../appid.dart';
class LiveStream {
  String streamKey;
  String status;
  int reconnectWindow;
  List<PlaybackId> playbackIds;
  NewAssetSettings newAssetSettings;
  String id;
  String createdAt;
  String latencyMode;
  int maxContinuousDuration;

  LiveStream({
    required this.streamKey,
    required this.status,
    required this.reconnectWindow,
    required this.playbackIds,
    required this.newAssetSettings,
    required this.id,
    required this.createdAt,
    required this.latencyMode,
    required this.maxContinuousDuration,
  });

  factory LiveStream.fromJson(Map<String, dynamic> json) {
    return LiveStream(
      streamKey: json['stream_key'],
      status: json['status'],
      reconnectWindow: json['reconnect_window'],
      playbackIds: List<PlaybackId>.from(
        json['playback_ids'].map((id) => PlaybackId.fromJson(id)),
      ),
      newAssetSettings: NewAssetSettings.fromJson(json['new_asset_settings']),
      id: json['id'],
      createdAt: json['created_at'],
      latencyMode: json['latency_mode'],
      maxContinuousDuration: json['max_continuous_duration'],
    );
  }
}

class PlaybackId {
  String policy;
  String id;

  PlaybackId({required this.policy, required this.id});

  factory PlaybackId.fromJson(Map<String, dynamic> json) {
    return PlaybackId(
      policy: json['policy'],
      id: json['id'],
    );
  }
}

class NewAssetSettings {
  List<String> playbackPolicies;

  NewAssetSettings({required this.playbackPolicies});

  factory NewAssetSettings.fromJson(Map<String, dynamic> json) {
    return NewAssetSettings(
      playbackPolicies: List<String>.from(json['playback_policies']),
    );
  }
}

class Mux extends ChangeNotifier {
  final String create = "https://api.mux.com/video/v1/live-streams"; // Path, don't include the host
  late LiveStream livestream;
  Future<LiveStream> createStream() async {

    final Map<String, dynamic> request = {
      'playback_policy': 'public',
      'new_asset_settings': {'playback_policy': 'public'}
    };
    String requestBody = jsonEncode(request); // Convert the request to a JSON string
    String auth = base64Encode(utf8.encode('$muxTokenId:$muxTokenSecret'));

    Response res = await post(
      Uri.parse(create),
      body: requestBody,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Basic $auth", // Add the Authorization header with the base64-encoded credentials
      },
    );

    var body;
    if (res.statusCode == 201) {
      body = jsonDecode(res.body);
      final fixture = body['data'];
       livestream = LiveStream.fromJson(fixture);
      return livestream;
    } else {
      if (res.statusCode != 201) {
        print('error: ${res.statusCode}');
      }
      // Handle the case when the HTTP response status code is not 201
      // You can either return an empty list or throw an exception, depending on your app's requirements.
      return livestream;
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

  Future<String> enableLiveStream(String streamId) async {
    final String enableEndpoint = "https://api.mux.com/video/v1/live-streams/$streamId/enable";
    String auth = base64Encode(utf8.encode('$muxTokenId:$muxTokenSecret'));

    try {
      final http.Response response = await http.put(
        Uri.parse(enableEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Basic $auth",
        },
      );

      if (response.statusCode == 200) {
        return "Live stream enabled successfully.";
      } else {
        // Print response body for more detailed error information
        print('Error response body: ${response.body}');
        return "Error: ${response.statusCode} ${response.reasonPhrase}";
      }
    } catch (error) {
      return "Exception: $error";
    }
  }

}



