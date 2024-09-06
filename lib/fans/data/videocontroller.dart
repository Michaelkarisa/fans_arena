import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoControllerProvider extends ChangeNotifier{
 late  VideoPlayerController controller;
 bool _isPlaying = false;
 Future<VideoPlayerController>initialize(String url)async{
   controller = VideoPlayerController.networkUrl(
     Uri.parse(url),
     videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
   );
   return controller;
 }
 bool isLoading=false;
 void initializePlayer1(String url) async {
   isLoading=true;
   final fileInfo = await checkCacheFor(url);
   if (fileInfo == null) {
     controller = VideoPlayerController.networkUrl(
       Uri.parse(url),
       videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
     );
     controller.initialize().then((value) {
       cachedForUrl(url);
         controller.setLooping(true);
         controller.play();
         isLoading=false;
         controller.setVolume(0.0);
         _isPlaying = true;
       notifyListeners();
     });
     notifyListeners();
   } else {
     final file = fileInfo.file;
     controller = VideoPlayerController.file(file);

     controller.initialize().then((value) {
         controller.setLooping(true);
         controller.play();
         controller.setVolume(0.0);
         _isPlaying = true;
         notifyListeners();
     });
     notifyListeners();
   }
   controller.addListener(() {
     if(controller.value.isInitialized){
         isLoading=false;
         notifyListeners();
     }else{
         isLoading=true;
         notifyListeners();
     }
     if (controller.value.isPlaying) {
         isLoading=false;
         notifyListeners();

     }else{
         isLoading=true;
         notifyListeners();
     }
   });
   notifyListeners();
   notifyListeners();
 }

 Future<FileInfo?> checkCacheFor(String url) async {
   final FileInfo? value = await DefaultCacheManager().getFileFromCache(url);
   return value;
 }

 void cachedForUrl(String url) async {
   await DefaultCacheManager().getSingleFile(url).then((value) {
     print('downloaded successfully done for $url');
     notifyListeners();

   });

 }
 void deletecache(String url)async{
   await DefaultCacheManager().removeFile(url).then((value){
     notifyListeners();
   });
 }


}