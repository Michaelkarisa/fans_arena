import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../fans/data/videocontroller.dart';
import 'feed_item.dart';

class FeedItem0 extends StatefulWidget {
  final String url;
  final String storyId;
  final String authorId;
  final void Function(int) setduration;
  const FeedItem0({super.key, required this.url,required this.authorId,required this.storyId,required this.setduration});

  @override
  State<FeedItem0> createState() => _FeedItem0State();
}

class _FeedItem0State extends State<FeedItem0> with SingleTickerProviderStateMixin {
  //player controller
  late VideoControllerProvider _controller;
  late AnimationController _animationController;
  late Animation<double> _animation;

  ViewsProvider v=ViewsProvider();
  late DateTime _startTime;
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    initializePlayer(widget.url);
    v.getViews("Story", widget.storyId);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool isvideo= false;
  int duration=0;
  void initializePlayer(String url) async {
    _controller.initialize(url);
    try {
      await _controller.controller.initialize();
      setState(() {
        duration=_controller.controller.value.duration.inSeconds;
        isvideo=true;
      });
    } catch (e) {
      setState(() {
        isvideo=false;
        duration=30;
      });
    }
    setState(() {
      _controller.controller.setLooping(true);
      _controller.controller.play();
      _controller.controller.setVolume(100.0); // Unmute the video
    });
    widget.setduration(duration);
  }


  // Check for cache
  Future<FileInfo?> checkCacheFor(String url) async {
    final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
    return value;
  }

  // Cache Url Data
  void cachedForUrl(String url) async {
    await DefaultCacheManager().getSingleFile(url).then((value) {
      print('downloaded successfully done for $url');
    });
  }


  // Dispose
  @override
  void dispose() {
    if(widget.authorId!=FirebaseAuth.instance.currentUser!.uid){
      v.addView("Story",widget.storyId,false,_startTime);
      v.updateWatchhours("Story",widget.storyId,false,_startTime);
    }
    _controller.dispose();
    _controller.controller.dispose();
    _animationController.dispose();

    super.dispose();
  }
  bool changed =false;


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder: (BuildContext context, Widget? child){
      return Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height,
        child:isvideo? (_controller.controller == null)
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : ((_controller.controller.value.isInitialized)
            ? AspectRatio(
          aspectRatio: _controller.controller.value.aspectRatio,
          child: VideoPlayer(_controller.controller),
        )
            : const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )):Center(
          child: Image.network(
            widget.url,
            fit: BoxFit.cover,
          ),
        ),
      );
    });
  }
}
