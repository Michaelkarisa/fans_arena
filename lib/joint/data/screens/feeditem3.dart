import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';
import 'package:shimmer/shimmer.dart';

class FeedItem3 extends StatefulWidget {
  final String url;
  final String postId;
  const FeedItem3({super.key,
    required this.url,required this.postId});
  @override
  State<FeedItem3> createState() => _FeedItem3State();
}
class _FeedItem3State extends State<FeedItem3> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
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
    if (widget.url.isEmpty) return;
    final cacheKey = '${widget.postId}_thumbnail';
    FileInfo? cachedFile = await cacheManager.getFileFromCache(cacheKey);
    if (cachedFile != null) {
      setState(() {
        thumbnailFile = cachedFile.file;
      });
    } else {
      Uint8List? thumbnailData = await generateThumbnail(widget.url);
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
    return Container(
      color: Colors.black,
      child: thumbnailFile!=null?Image.file(
        thumbnailFile!,
        fit: BoxFit.fill,
        ) : Container(
        child: Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[500]!,
          period: const Duration(milliseconds: 800),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
