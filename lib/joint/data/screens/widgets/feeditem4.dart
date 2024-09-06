import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../fans/data/videocontroller.dart';

class FeedItem4 extends StatefulWidget {
  //Url to play video
  final String url;
  const FeedItem4({super.key, required this.url});

  @override
  State<FeedItem4> createState() => _FeedItem4State();
}

class _FeedItem4State extends State<FeedItem4> with SingleTickerProviderStateMixin {
  //player controller
  late VideoControllerProvider _controller;
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _animation;


  @override
  void initState() {
    super.initState();
    _controller=VideoControllerProvider();
    //initialize player
    initializePlayer(widget.url);

    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }



  //Initialize Video Player
  void initializePlayer(String url) async {
    _controller.initialize(url);
    _controller.controller.initialize().then((value) {
      setState(() {
        _controller.controller.setLooping(true);
        _controller.controller.play();
        _controller.controller.setVolume(100.0); // Unmute the video
        _isPlaying = true;
      });
    });
  }

  // Dispose
  @override
  void dispose() {
    _controller.dispose();
    _controller.controller.dispose();
    _animationController.dispose();
    super.dispose();
  }


  void _onPlayButtonPressed() {
    setState(() {
      if (_controller.controller.value.isPlaying) {
        _controller.controller.pause();
        _isPlaying = false;
        _animationController.reverse();
      } else {
        _controller.controller.play();
        _isPlaying = true;
        _animationController.forward();
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _controller, builder:(BuildContext context, Widget? child){
      return ClipRRect(
      borderRadius: BorderRadius.circular(5),
    child: _controller.controller != null
    ? VideoPlayer(_controller.controller)
        : const Center(child: SizedBox(width:25,
    height: 25,
    child: CircularProgressIndicator( color: Colors.black,))),
    );
    });
  }
}
