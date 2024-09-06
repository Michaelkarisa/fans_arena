import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/components/bottomnavigationbar.dart';
import 'package:fans_arena/fans/screens/viewyourstory.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../fans/screens/newsfeed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:io';

class Mystory extends StatefulWidget {
   Story story;
  Mystory({Key? key, required this.story}) : super(key: key);


  @override
  State<Mystory> createState() => _MystoryState();
}

class _MystoryState extends State<Mystory> {

  @override
  void initState() {
    super.initState();
    getIndex();

  }
  String userId='';
  void getIndex()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('index', 1);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Builder(builder: (BuildContext context){
        if (widget.story.story.isEmpty) {
            return Stack(
              children: [
                Column(
                  children: [
                    Container( decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                        height: MediaQuery.of(context).size.height*0.2,
                        width: MediaQuery.of(context).size.width*0.28,
                        child:Center(
                            child: InkWell(
                              onTap: (){
                                Bottomnavbar.setCamera(context);
                                getIndex();
                              },
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Add a story',
                                    style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                  Icon(Icons.add_circle_outline,size: 35,color: Colors.white,)
                                ],
                              ),
                            ))
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: InkWell(
                        onTap: (){
                          Bottomnavbar.setCamera(context);
                          getIndex();
                        },
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.add_circle_outline_rounded),
                            Text('Your story'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 5),
                  child: SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width * 0.248,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey[500],
                          child: CachedNetworkImage(
                            imageUrl:
                            widget.story.user.url,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 20,
                              backgroundImage: imageProvider,
                            ),

                          ),
                        ),],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return UserStory(
                story: widget.story,
                userId: FirebaseAuth.instance.currentUser!.uid);
          }
        },  ),

    );
  }
}


class UserStory extends StatefulWidget {
  String userId;
  Story story;
  UserStory({super.key,required this.story,required this.userId});

  @override
  State<UserStory> createState() => _UserStoryState();
}

class _UserStoryState extends State<UserStory> {
  @override
  void initState() {
    super.initState();
    if( widget.story.story.last['url'].toString().isNotEmpty) {
      initializeImage(widget.story.story.last['url'].toString());
    }}

  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
          video: videoUrl,
          imageFormat: ImageFormat.PNG,
          maxHeight: 240,
          maxWidth: 150,
          quality: 25,
          timeMs: 1500);
      return thumbnailData;
    } catch (e) {
      return null;
    }
  }
  final BaseCacheManager cacheManager = DefaultCacheManager();
  String thumbnailUrl = '';
  File? thumbnailFile;

  void initializeImage(String videoUrl) async {
    if (videoUrl.isEmpty) return;
    final cacheKey = '${widget.story.StoryId}_thumbnail';
    FileInfo? cachedFile = await cacheManager.getFileFromCache(cacheKey);
    if (cachedFile != null) {
      setState(() {
        thumbnailFile = cachedFile.file;
      });
    } else {
      Uint8List? thumbnailData = await generateThumbnail(videoUrl);
      if (thumbnailData != null) {
        File file = await cacheManager.putFile(
          cacheKey,
          thumbnailData,
          fileExtension: 'png',
        );
        setState(() {
          thumbnailFile = file;
        });
      }
    }
  }




  void getIndex()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('index', 1);
  }

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children:[
        Column(
          children: [
            InkWell(
              onTap: (){
                Navigator.push(context,
                  MaterialPageRoute(builder: (context)=>YourStoryViewScreen(s: widget.story,story:widget.story.story, userId:widget.userId,),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: MediaQuery.of(context).size.height*0.2,
                width: MediaQuery.of(context).size.width*0.28,
                child:thumbnailFile!=null?ClipRRect(borderRadius: BorderRadius.circular(10),child: Image.file(thumbnailFile!)):ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:CachedNetworkImage(
                    imageUrl: widget.story.story.last['url1'],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                      child: SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          value: downloadProgress.progress,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Center(child: Icon(Icons.error,color: Colors.white,size: 40,)),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: InkWell(
                onTap: (){
                  Bottomnavbar.setCamera(context);
                  getIndex();
                },
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(Icons.add_circle_outline_rounded),
                    Text('Your story'),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 5),
          child: SizedBox(
            width: MediaQuery
                .of(context)
                .size
                .width * 0.248,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[500],
                  child: CachedNetworkImage(
                    imageUrl:
                    profileimage,
                    imageBuilder: (context, imageProvider) => CircleAvatar(
                      radius: 20,
                      backgroundImage: imageProvider,
                    ),

                  ),
                ),

                Container(
                  width:13 ,
                  height: 13,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('${widget.story.story.length}',style: const TextStyle(color: Colors.white,fontSize: 10),)),),
              ],
            ),
          ),
        ),
      ],

    );
  }
}


