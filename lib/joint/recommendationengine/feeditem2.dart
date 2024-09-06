import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../joint/data/screens/feed_item.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../fans/screens/newsfeed.dart';

class Feeditem2 extends StatefulWidget {
  final String videoUrl;
  String postId;
   Feeditem2({super.key, required this.videoUrl,required this.postId});

  @override
  State<Feeditem2> createState() => _Feeditem2State();
}

class _Feeditem2State extends State<Feeditem2> with SingleTickerProviderStateMixin{
  ViewsProvider v=ViewsProvider();
  @override
  void initState() {
    super.initState();
    v.getViews("FansTv", widget.postId);
    initializeImage();
  }

  final BaseCacheManager cacheManager = DefaultCacheManager();
  String thumbnailUrl = '';
  File? thumbnailFile;

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
         maxHeight: 240,
          maxWidth: 150,
        quality: 5,
        timeMs: 1500);
      return thumbnailData;
    } catch (e) {
      return null;
    }
  }

  void initializeImage() async {
    if (widget.videoUrl.isEmpty) return;
    final cacheKey = '${widget.postId}_thumbnail';
    FileInfo? cachedFile = await cacheManager.getFileFromCache(cacheKey);
    if (cachedFile != null) {
      setState(() {
        thumbnailFile = cachedFile.file;
      });
    } else {
      Uint8List? thumbnailData = await generateThumbnail(widget.videoUrl);
      if (thumbnailData != null) {
        File file = await cacheManager.putFile(
          cacheKey,
          thumbnailData,
          fileExtension: 'png',);
        setState(() {
          thumbnailFile = file;
        });
      }
    }
  }

  // Dispose
  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        height: 220,
        width: 140,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius:BorderRadius.circular(10) ,
            border: Border.all(
                width: 1,
                color: Colors.grey
            )
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: thumbnailFile!=null?Image.file(
                  thumbnailFile!,height: 220,
                width: 140,fit: BoxFit.fitWidth,) : TvItem(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10,bottom: 2),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: AnimatedBuilder(
                animation: v,
                builder: (BuildContext context, Widget? child) {
                   return ViewsCount(totalLikes: v.views.length,);
                  }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
