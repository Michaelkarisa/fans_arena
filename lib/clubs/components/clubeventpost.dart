import 'package:fans_arena/appid.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/joint/components/recently.dart';
import 'package:flutter/material.dart';
import '../../fans/data/newsfeedmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fans_arena/fans/screens/matchwatch.dart';
import '../../fans/screens/debate.dart';
import '../../reusablewidgets/carouselslider.dart';
import '../../reusablewidgets/cirularavatar.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_visibility_pro/keyboard_visibility_pro.dart';
import '../screens/eventsclubs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:uuid/uuid.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../fans/components/bottomnavigationbar.dart';
import '../../appid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';
const String apiKey =
String.fromEnvironment('316131999212869', defaultValue: '316131999212869');
const String apiSecret =
String.fromEnvironment('lMUJoL0R7-45y_iRbY-QI3ShFK4', defaultValue: 'lMUJoL0R7-45y_iRbY-QI3ShFK4');
const String cloudName =
String.fromEnvironment('dtwfhkkhm', defaultValue: 'dtwfhkkhm');
const String folder =
String.fromEnvironment('images', defaultValue: 'images');
const String uploadPreset =
String.fromEnvironment('aovvovqk', defaultValue: 'aovvovqk');

final cloudinary = Cloudinary.unsignedConfig(
  cloudName: cloudName,
);
final cloudinary1 = Cloudinary.signedConfig(
  cloudName: cloudName,
  apiKey: apiKey,
  apiSecret: apiSecret,
);
class HighlightCard extends StatefulWidget {
  final Map<String, dynamic> data;
  void Function(Map<String, dynamic> data) fun;
  void Function(Map<String, dynamic> data) funedit;
  HighlightCard({Key? key,
    required this.data,
    required this.fun,
    required this.funedit}) : super(key: key);

  @override
  _HighlightCardState createState() => _HighlightCardState();
}
enum FileSource {
  path,
  bytes,
}

class DataTransmitNotifier {
  final String? path;
  late final ProgressCallback? progressCallback;
  final notifier = ValueNotifier<double>(0);

  DataTransmitNotifier({this.path, ProgressCallback? progressCallback}) {
    this.progressCallback = progressCallback ??
            (count, total) {
          notifier.value = count.toDouble() / total.toDouble();
        };
  }
}
class _HighlightCardState extends State<HighlightCard> {
  static const int loadImage = 1;
  static const int doSignedUpload = 2;
  static const int doUnsignedUpload = 3;
  List<DataTransmitNotifier> dataImages = [];
  List<CloudinaryResponse> cloudinaryResponses = [];
  bool loading = false;
  String? errorMessage;
  FileSource fileSource = FileSource.path;
  List<String> medias = [];
  List<VideoPlayerController> _videoControllers = [];
  List<Future<void>> _initializeVideoPlayerFutures = [];
  bool isLoading = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    medias = List<String>.from(widget.data['urls']);
    _videoControllers = medias.map((url) => VideoPlayerController.network(url)).toList();
    _initializeVideoPlayerFutures = _videoControllers.map((controller) => controller.initialize()).toList();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    medias.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        color: Color(widget.data['bcolor']),
        child: Stack(
          children: [
            SizedBox(
              height: 250,
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.data['heading'].toString().isNotEmpty)
                    Text(widget.data['heading'],
                      style: TextStyle(
                        color: Color(widget.data['hcolor']),
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (medias.isEmpty||medias[0]==""||medias[0]==null)
                    buildTextOnly()
                  else _videoControllers.length < 2
                      ? buildSingleMediaRow()
                      : buildMultipleMediaColumn()
                ],
              ),
            ),
            collectionNamefor=="Club"?Align(alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20,vertical:1),
                  child: SizedBox(
                    width:90,
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(padding: EdgeInsets.zero,onPressed: ()=>widget.fun(widget.data), icon: Icon(Icons.delete_forever,size: 25,color: Color(widget.data['tcolor']),)),
                        IconButton(padding: EdgeInsets.zero,onPressed: ()=>widget.funedit(widget.data), icon: Icon(Icons.edit,size: 25,color: Color(widget.data['tcolor']),)),
                      ],
                    ),
                  ),
                )):SizedBox.shrink()
          ],
        ),
      ),
    );
  }
  Widget buildSingleMediaRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          width: 150,
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: buildMediaWidget(context, 0),
            ),
          ),
        ),
        buildTextWidget(),
      ],
    );
  }

  Widget buildMultipleMediaColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 2,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox(
                  height: 150,
                  width: MediaQuery.of(context).size.width * 0.48,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: buildMediaWidget(context, index),
                    ),
                  ),
                );
              } else {
                return buildGridMedia();
              }
            },
          ),
        ),
        buildTextWidget(),
      ],
    );
  }

  Widget buildGridMedia() {
    List<String> data = List<String>.from(medias)..removeAt(0);
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width * 0.48,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.0,
              crossAxisCount: medias.length == 2 ? 1 : 2,
              mainAxisSpacing: 2.0,
              crossAxisSpacing: 2.0,
            ),
            itemBuilder: (context, index) {
              if(data.length>4&&index==3){
                return ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Stack(
                        children: [SizedBox(
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: buildMediaWidget(context, index+1)),
                          Center(child: Padding(
                            padding: const EdgeInsets.only(bottom: 50),
                            child: Text("+${medias.length-5}",
                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                          ),),
                        ],
                      ),
                    ));
              }else{
                return   ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: buildMediaWidget(context, index+1));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildMediaWidget(BuildContext context, int index) {
    final url = medias[index];
    return url.isNotEmpty
        ? CachedNetworkImage(
      fit: BoxFit.cover,
      imageUrl: url,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: SizedBox(
          width: 25,
          height: 25,
          child: CircularProgressIndicator(
            value: downloadProgress.progress,
          ),
        ),
      ),
      errorWidget: (context, url, error) {
        final controller = _videoControllers[index];
        return FutureBuilder<void>(
          future: _initializeVideoPlayerFutures[index],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else {
              return Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: const CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
    ) : const SizedBox.shrink();
  }

  Widget buildTextWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        height: medias.length > 1 ? 70 : 220,
        width: medias.length > 1 ? MediaQuery.of(context).size.width: MediaQuery.of(context).size.width * 0.49,
        child: Text(
          widget.data['text'],
          style: TextStyle(
            color: Color(widget.data['tcolor']),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget buildTextOnly() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        height: 220,
        child: Text(
          widget.data['text'],
          style: TextStyle(
            color: Color(widget.data['tcolor']),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}


class CreateHighlight extends StatefulWidget {
  const CreateHighlight({super.key});

  @override
  State<CreateHighlight> createState() => _CreateHighlightState();
}

class _CreateHighlightState extends State<CreateHighlight> {
  static const int loadImage = 1;
  static const int doSignedUpload = 2;
  static const int doUnsignedUpload = 3;
  List<DataTransmitNotifier> dataImages = [];
  List<CloudinaryResponse> cloudinaryResponses = [];
  bool loading = false;
  String? errorMessage;
  FileSource fileSource = FileSource.path;
  Color tcolor = Colors.black;
  Color hcolor = Colors.black;
  Color bcolor = Colors.white;
  List<Color> colors = [
    Colors.black,
    Colors.blue,
    Colors.purple,
    Colors.brown,
    Colors.red,
    Colors.white,
    Colors.green,
    Colors.indigo,
    Colors.orange,
    Colors.blueGrey,
    Colors.grey,
    Colors.amber,
    Colors.cyan,
    Colors.deepOrange,
    Colors.indigo,
    Colors.pink,
    Colors.teal,
    Colors.yellow,
    Colors.lime
  ];

  final TextEditingController headingController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  List<String> medias=[];
  List<VideoPlayerController> _videoControllers=[];
  List<Future<void>> _initializeVideoPlayerFutures=[];
  @override
  void dispose() {
    for(var videoc in _videoControllers){
      videoc.dispose();
    }
    super.dispose();
    headingController.dispose();
    textController.dispose();
    super.dispose();
  }
  @override
  void initState(){
    super.initState();
    _videoControllers = List.generate(
      medias.length,
          (index) => VideoPlayerController.file(File(medias[index])),
    );
    _initializeVideoPlayerFutures = _videoControllers
        .map((controller) => controller.initialize())
        .toList();
  }
  void pickMedia(bool video) async {
    if(video) {
      final ImagePicker picker = ImagePicker();
      final XFile? media = await picker.pickVideo(source: ImageSource.gallery);

      if (media != null) {
        setState(() {
          medias.add(media.path);
        });
      }
    }else{
      final ImagePicker picker = ImagePicker();
      final XFile? media = await picker.pickImage(source: ImageSource.gallery);
      if (media != null) {
        setState(() {
          medias.add(media.path);
        });
      }
    }
    setState(() {
      _videoControllers = List.generate(
        medias.length,
            (index) => VideoPlayerController.file(File(medias[index])),
      );
      _initializeVideoPlayerFutures = _videoControllers
          .map((controller) => controller.initialize())
          .toList();
    });
  }
  Future<Uint8List?> generateThumbnail(String videoUrl) async {
    try {
      final Uint8List? thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 25,
      );
      return thumbnailData;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }
  String thumbnailUrl = '';
  File? thumbnailFile;
  final BaseCacheManager cacheManager = DefaultCacheManager();
  void initializeImage() async {
    String videoUrl =   '';//await retrieveUrl();
    if (videoUrl.isEmpty) return;
    final cacheKey = '${''}_thumbnail';
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

  void postHighlight(Map<String,dynamic>data)async{
    try{
      List<Map<String,dynamic>>alldata=[];
      CollectionReference collectionReference=FirebaseFirestore.instance.collection('Highlights');
      DocumentSnapshot documentSnapshot=await collectionReference.doc(FirebaseAuth.instance.currentUser!.uid).get();
      if(documentSnapshot.exists){
        setState(() {
          alldata=List.from(documentSnapshot['highlights']);
          alldata.add(data);
        });
        await documentSnapshot.reference.update({
          'highlights':alldata,
          'docId':FirebaseAuth.instance.currentUser!.uid,
        });
        await Future.delayed(Duration(seconds: 1));
        dialogc();
      }else{
        collectionReference.doc(FirebaseAuth.instance.currentUser!.uid).set({
          'createdAt':Timestamp.now(),
          'highlights':[data],
          'docId':FirebaseAuth.instance.currentUser!.uid,
        });
        await Future.delayed(Duration(seconds: 1));
        dialogc();
      }}catch (e){
      dialog1(e.toString());
    }
  }
  void dialogc(){
    showDialog(context: context, builder: (context){
      return const AlertDialog(content: Text('highlight posted'),);
    });
  }

  Future<List<int>> getFileBytes(String path) async {
    return await File(path).readAsBytes();
  }

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }
  Future<List<String>> doMultipleUpload(List<DataTransmitNotifier> images) async {
    List<String> urls = [];
    List<String> publicIds = [];
    try {
      for (int i = 0; i < images.length; i++) {
        final data = images[i];
        String url = '';
        String publicId = generateUniqueNotificationId();
        List<int>? fileBytes;
        if (fileSource == FileSource.bytes) {
          fileBytes = await getFileBytes(data.path!);
        }
        dialog(data, i); // Show progress dialog for the specific image
        setState(() {});
        CloudinaryResponse response = await cloudinary1.upload(
          file: data.path,
          fileBytes: fileBytes,
          resourceType: CloudinaryResourceType.image, // Assuming you're uploading images
          folder: folder,
          progressCallback: (progress, progress1) {
            setState(() {
              data.notifier.value = progress.toDouble();
            });
            data.progressCallback!(progress, progress1);
          },
          publicId: publicId,
        );

        if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
          setState(() {
            cloudinaryResponses.add(response);
            url = response.secureUrl!;
            publicIds.add(response.publicId!);
          });
          urls.add(url);
          back();
        } else {
          setState(() {
            errorMessage = response.error;
          });
          // Continue to the next image in case of error
        }
      }
      return urls;
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      if (kDebugMode) {
        print(e);
      }
      return urls;
    }
  }

  void dialog(DataTransmitNotifier dataImage, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ValueListenableBuilder<double>(
              key: ValueKey(dataImage.path),
              valueListenable: dataImage.notifier,
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 8.0,
                    ),
                    const SizedBox(height: 4.0),
                    cloudinaryResponses.length > index && cloudinaryResponses[index].isSuccessful
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Text('${(value * 100).toInt()} %'),
                    Visibility(
                      visible: errorMessage?.isNotEmpty ?? false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$errorMessage",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red.shade900,
                            ),
                          ),
                          const SizedBox(
                            height: 128,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }


  void onNewImages(List<String> filePaths) {
    if (filePaths.isNotEmpty) {
      for (final path in filePaths) {
        if (path.isNotEmpty) {
          setState(() {
            dataImages.add(DataTransmitNotifier(path: path));
          });
        }
      }
      setState(() {});
    }
  }

  String insertStringBetween(String original) {
    String insert = 'f_auto,q_auto/v1'; // Remove 'video' from the insert string
    String modifiedURL = original.replaceFirst(RegExp(r'/upload/v\d+/'), '/upload/$insert/');
    return modifiedURL;
  }
  void back(){
    Navigator.of(context, rootNavigator: true).pop();
  }
  void dialog1(String e){
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: Text(e),
      );
    });
  }
  void dialog2(){
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Failed to upload media'),
          );
        });
  }

  int hl=0;
  int tl=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Highlight'),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 250,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(color: bcolor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      headingController.text.isNotEmpty? Text(
                        headingController.text,
                        style: TextStyle(
                          color: hcolor,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ):SizedBox.shrink(),
                      medias.isNotEmpty? _videoControllers.length<2? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                              height:225,
                              width:MediaQuery.of(context).size.width*0.49,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: buildMediaWidget(context, 0)),
                              )),
                          buildTextWidget(),
                        ],
                      ):Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height:150,
                            width:MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: 2,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                if(index==0) {
                                  return   SizedBox(
                                      height:150,
                                      width:MediaQuery.of(context).size.width*0.48,
                                      child: Padding(
                                        padding: const EdgeInsets.all(3.0),
                                        child: ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: buildMediaWidget(context, index)),
                                      ));
                                }else{
                                  List<String> data = [...medias];
                                  data.removeAt(0);
                                  return SizedBox(
                                    height:150,
                                    width:MediaQuery.of(context).size.width*0.48,
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: GridView.builder(
                                            physics: const NeverScrollableScrollPhysics(),
                                            itemCount: data.length>4?4:data.length,
                                            gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                                              childAspectRatio: 1.0,
                                              crossAxisCount: medias.length==2?1:2,
                                              mainAxisSpacing: 2.0,
                                              crossAxisSpacing: 2.0,
                                            ),
                                            itemBuilder: (context, index) {
                                              if(data.length>4&&index==3){
                                                return ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: SizedBox(
                                                      height: 100,
                                                      width: MediaQuery.of(context).size.width * 0.25,
                                                      child: Stack(
                                                        children: [
                                                          SizedBox(
                                                              height: 100,
                                                              width: MediaQuery.of(context).size.width * 0.25,
                                                              child: buildMediaWidget(context, index+1)),
                                                          Center(child: Padding(
                                                            padding: const EdgeInsets.only(bottom: 50),
                                                            child: Text("${medias.length-5}",
                                                              style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                                          ),),
                                                        ],),
                                                    ));
                                              }else{
                                                return ClipRRect(
                                                    borderRadius: BorderRadius.circular(4),
                                                    child: buildMediaWidget(context, index+1));
                                              }}),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          buildTextWidget(),
                        ],
                      ):Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          height:220,
                          width:MediaQuery.of(context).size.width,
                          child: Text(
                            textController.text,
                            style: TextStyle(
                              color: tcolor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('All media'),
            ),
            medias.isEmpty?SizedBox.shrink():SizedBox(
                height:100,
                width:MediaQuery.of(context).size.width,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: medias.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      return SizedBox(
                          height:100,
                          width:MediaQuery.of(context).size.width*0.25,
                          child: Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: Stack(
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: buildMediaWidget(context, index)),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(onPressed: ()=>setState(() {
                                    medias.removeAt(index);
                                  }), icon: Icon(Icons.delete_forever,size: 20,color: Colors.grey[200],)),
                                )
                              ],
                            ),
                          ));})),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Choose Background Color'),
            ),
            Wrap(
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      bcolor = color;
                    });
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: bcolor == color ? Colors.black : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Heading Input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: headingController,
                validator: (value) =>
                value != null && value.length>42 ? null : "Max character length exceeded",
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(bottom: 0,top: 0,left: 5),
                  labelText: 'Heading',
                  suffix: Text("$hl"),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    hl=value.length;
                  });
                },
              ),
            ),
            // Heading Color Picker
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Choose Heading Color'),),
            Wrap(
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      hcolor = color;
                    });},
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: hcolor == color ? Colors.black : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }).toList(),
            ),
            // Text Input
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: textController,
                scrollPhysics: const ScrollPhysics(),
                expands: false,
                maxLines: 6,
                minLines: 1,
                validator: (value) => value != null && value.length>100 ? null : "Max character length exceeded",
                decoration: InputDecoration(labelText: 'Text', suffix: Text("$tl"),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.only(bottom: 0,top: 0,left: 5),
                ),
                onChanged: (value) {
                  setState(() {
                    tl=value.length;
                  });
                },
              ),
            ),
            // Text Color Picker
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Choose Text Color'),
            ),
            Wrap(
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState((){
                      tcolor = color;
                    });},
                  child: Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: tcolor == color ? Colors.black : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed:()=> pickMedia(true),
                    child: const Text('Pick Video'),
                  ),
                  const SizedBox(width: 50,),
                  ElevatedButton(
                    onPressed:()=> pickMedia(false),
                    child: const Text('Pick Image'),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed:()async{
                setState(() {
                  dataImages=List.generate(medias.length,(index)=>DataTransmitNotifier(path: medias[index]));
                });
                String uid=generateUniqueNotificationId();
                if(medias.isNotEmpty) {
                  List<String>? urls = await doMultipleUpload(dataImages);
                  final  highlight={
                    "highlightId":uid,
                    'tcolor':tcolor.value,
                    'text':textController.text ,
                    'bcolor':bcolor.value,
                    'urls':urls ??[],
                    'hcolor':hcolor.value,
                    'heading':headingController.text,
                    'timestamp':Timestamp.now(),
                  };
                  postHighlight(highlight);
                }else{
                  final  highlight={
                    "highlightId":uid,
                    'tcolor':tcolor.value,
                    'text':textController.text ,
                    'bcolor':bcolor.value,
                    'urls':[],
                    'hcolor':hcolor.value,
                    'heading':headingController.text,
                    'timestamp':Timestamp.now(),
                  };
                  postHighlight(highlight);
                }
              },
              child: const Text('post highlight'),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildMediaWidget(BuildContext context, int index) {
    final url = medias[index];
    bool isVideo = url.toLowerCase().endsWith('.mp4');
    if (isVideo) {
      final controller = _videoControllers[index];
      return FutureBuilder<void>(
        future: _initializeVideoPlayerFutures[index],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio:controller.value.aspectRatio,
              child: VideoPlayer(controller),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      );
    } else {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
      );
    }
  }

  Widget buildTextWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SizedBox(
        height:medias.length>1?70: 220,
        width: medias.length>1?MediaQuery.of(context).size.width:MediaQuery.of(context).size.width*0.49,
        child: Text(
          textController.text,
          style: TextStyle(
            color: tcolor,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}


class CreateEvent extends StatefulWidget {
  const CreateEvent({super.key});

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> {
  int _currentIndex = 0;
  late Stream<DocumentSnapshot> data;
  @override
  void initState() {
    super.initState();
    setState(() {});
    data=FirebaseFirestore.instance.collection('Highlights').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
  }
  final TextEditingController headingController = TextEditingController();
  final TextEditingController textController = TextEditingController();
  void delete(List<Map<String, dynamic>> data,DocumentSnapshot doc)async{
    showDialog(context: context, builder: (context)=>AlertDialog(content: Text("Deleting"),));
    await doc.reference.update({ 'highlights':data,});
    Navigator.of(context,rootNavigator: true).pop();
    await Future.delayed(Duration(seconds: 1));
    showDialog(context: context, builder: (context)=>AlertDialog(content: Text("Deleted"),));
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context,rootNavigator: true).pop();
  }

  void update(List<Map<String, dynamic>> data,DocumentSnapshot doc)async{
    showDialog(context: context, builder: (context)=>AlertDialog(content: Text("updating"),));
    await doc.reference.update({ 'highlights':data,});
    Navigator.of(context,rootNavigator: true).pop();
    await Future.delayed(Duration(seconds: 1));
    showDialog(context: context, builder: (context)=>AlertDialog(content: Text("updated"),));
    await Future.delayed(Duration(seconds: 2));
    Navigator.of(context,rootNavigator: true).pop();
  }

  int hl=0;
  int tl=0;
  bool isExpanded=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:false,
      body: StreamBuilder<DocumentSnapshot>(
          stream:data,
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            }else if (snapshot.hasError) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("${snapshot.error}"),
                  const SizedBox(height: 10),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        data=FirebaseFirestore.instance.collection('Highlights').doc(FirebaseAuth.instance.currentUser!.uid).snapshots();
                      });
                    },
                    icon: const Icon(Icons.refresh, color: Colors.black),
                  ),
                  const Text('Refresh'),
                ],
              );
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No Data"));
            } else if (snapshot.hasData) {
              final doc = snapshot.data!;
              List<Map<String, dynamic>> data=[];
              if (doc.exists) {
                data = List<Map<String, dynamic>>.from(doc['highlights']);
              }
              final matchWidgets = data.map((match) => HighlightCard(
                data: match,
                fun: (Map<String, dynamic> d) {
                  showDialog(context: context,
                      builder: (context)=>AlertDialog(content: Text("Proceed in deleting highlight"),
                        actions: [Row(
                          mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                          children: [
                          TextButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text("No")),
                          TextButton(onPressed: (){
                            setState(() {
                              Navigator.pop(context);
                              data.remove(d);
                              delete(data, doc);
                            });
                          }, child: Text("Yes")),],)],));
                },
                funedit: (Map<String, dynamic> d) {
                  setState(() {
                    textController.text = d['text'];
                    headingController.text = d['heading'];
                  });
                  showModalBottomSheet(
                      isScrollControlled: true,
                      isDismissible: true,
                      backgroundColor: Colors.transparent,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                      ),
                      context: context,
                      builder: (BuildContext context) {
                        return DraggableScrollableSheet(
                          expand: true,
                          initialChildSize: isExpanded?0.8:0.5,
                          maxChildSize: 0.5,
                          minChildSize: 0.5,
                          builder: (context, pController) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.5),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                color: Colors.grey[200],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                        "Edit Highlight",
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: KeyboardVisibility(
                                        onChanged: (bool visible ) {
                                          setState(() {
                                            if(visible) {
                                              isExpanded =true;
                                            }else if(!visible){
                                              isExpanded =false;
                                            }
                                          });
                                        },
                                        child: TextFormField(
                                          controller: headingController,
                                          validator: (value) => value != null && value.length <= 42
                                              ? null
                                              : "Max character length exceeded",
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.only(bottom: 0, top: 0, left: 5),
                                            labelText: 'Heading',
                                            suffix: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text("${headingController.text.length}"),
                                            ),
                                            border: const OutlineInputBorder(),
                                          ),
                                          onChanged: (value) {
                                            setState(() {
                                              hl = value.length;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: TextFormField(
                                        controller: textController,
                                        scrollPhysics: const ScrollPhysics(),
                                        expands: false,
                                        maxLines: 6,
                                        minLines: 1,
                                        validator: (value) => value != null && value.length <= 100
                                            ? null
                                            : "Max character length exceeded",
                                        decoration: InputDecoration(
                                          labelText: 'Text',
                                          suffix: Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Text("${textController.text.length}"),
                                          ),
                                          border: const OutlineInputBorder(),
                                          contentPadding: const EdgeInsets.only(bottom: 0, top: 0, left: 5),
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            tl = value.length;
                                          });
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          for(var d1 in data) {
                                            if (d1['highlightId'] == d['highlightId']) {
                                              d1['heading'] = headingController.text;
                                              d1['text'] = textController.text;
                                            }
                                          }
                                        });
                                        update(data, doc);
                                      },
                                      child: const Text('Update Highlight'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  );
                },
              )).toList();
              return Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.3,
                      aspectRatio: 16 / 9,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                    ),
                    items: matchWidgets,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2, right: 2),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.96,
                        height: MediaQuery.of(context).size.height * 0.019,
                        child: Center(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: data.asMap().entries.map((entry) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _currentIndex = entry.key;
                                    });
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.015,
                                    height: MediaQuery.of(context).size.height * 0.015,
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );} else {
              return const SizedBox.shrink();
            }
          }),
    );
  }
}



class CheckEvents extends StatefulWidget {
  const CheckEvents({super.key});

  @override
  State<CheckEvents> createState() => _CheckEventsState();
}

class _CheckEventsState extends State<CheckEvents> {
  late Future<List<MatchM>> _highlightsFuture;
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    _highlightsFuture = DataFetcher().getweeksmatches1(FirebaseAuth.instance.currentUser!.uid);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MatchM>>(
      future:_highlightsFuture,
      builder: (context, snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              )); } else if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${snapshot.error}"),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () {
                  setState(() {
                    _highlightsFuture = DataFetcher().getweeksmatches1(FirebaseAuth.instance.currentUser!.uid);
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.black),
              ),
              const Text('Refresh'),
            ],
          );
        } else if (!snapshot.hasData||snapshot.data!.isEmpty) {
          return const Center(child: Text("No Matches This week"));
        } else if (snapshot.hasData) {
          final matches = snapshot.data!;
          final matchWidgets = matches.map((match) => Padding(
            padding: const EdgeInsets.only(left: 5,right: 5,top: 8),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  match.league.userId.isNotEmpty? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomAvatar(imageurl:match.league.url, radius: 18),
                      const SizedBox(width: 5,),
                      CustomName(
                        username: match.league.name,
                        maxsize: 180,
                        style:const TextStyle(color: Colors.black,fontSize: 16),),
                    ],
                  ):const SizedBox.shrink(),
                  Padding(
                    padding: const EdgeInsets.only(left: 10,right: 10),
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.85,
                      decoration: BoxDecoration(color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CustomAvatar( radius:26, imageurl:match.club1.url),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 10,right: 1),
                                      child: Center(child: Text('${match.score1}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top: 5),
                                  child: CustomName(
                                    username:match.club1.name,
                                    maxsize: 140,
                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width*0.3,
                              height: 60,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(left: 3,right: 3),
                                    child: Center(child: Text('VS',style: TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 16.5),)),
                                  ),
                                  match
                                      .status != '0'||match.duration!=0 ?Time(matchId: match.matchId, club1Id: match.club1.userId, ): Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceEvenly,
                                    children: [
                                      Text(match.createdat),
                                      Text(match.starttime),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 1,right: 10),
                                      child: Center(child: Text('${match.score2}',style: const TextStyle(color: Colors.blueGrey,fontWeight: FontWeight.bold,fontSize: 26),)),
                                    ),
                                    CustomAvatar( radius: 26, imageurl:match.club2.url),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5,top:5),
                                  child: CustomName(
                                    username: match.club2.name,
                                    maxsize: 140,
                                    style:const TextStyle(color: Colors.black,fontSize: 16),),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 35,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Watch(match:match),
                        Container(
                          height: 28,
                          width: MediaQuery.of(context).size.width*0.35,
                          decoration: BoxDecoration(
                            color: Colors.white70,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 3, right: 2),
                                child: Icon(Icons.location_on_outlined,color: Colors.black,),),
                              SizedBox(
                                  width: 120,
                                  height: 20,
                                  child: OverflowBox(
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        maxLines:1,
                                        match.location,
                                        style: const TextStyle(color: Colors.black,fontSize: 15),))),],
                          ),
                        ),
                        Watch1( matches: match,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )).toList();
          return SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    clipBehavior: Clip.none,
                    height:180,
                    aspectRatio: 16 / 9,
                    autoPlay: true,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.99,
                    padEnds: false,
                    viewportFraction: 1.5,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items:matchWidgets,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: matches
                          .asMap()
                          .entries
                          .map((entry) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _currentIndex = entry.key;
                            });
                          },
                          child: Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.015,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.015,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == entry.key
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        }else{
          return const SizedBox.shrink();
        }
      },
    );

  }
}

class Watch extends StatefulWidget {
  MatchM match;
  Watch({super.key,
    required this.match,
  });

  @override
  State<Watch> createState() => _WatchState();
}

class _WatchState extends State<Watch> {
  String statusName='';
  String state='1';
  String state1='0';
  String state2='0';
  @override
  void initState(){
    super.initState();
    DateTime scheduledDate = widget.match.timestamp.toDate();
    if (widget.match.status == state && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Ongoing';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month > DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    } else if (widget.match.status == state1 && scheduledDate.year < DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.match.status == state1 && scheduledDate.year > DateTime.now().year && scheduledDate.month > DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    } else if (widget.match.status == state1 && scheduledDate.year < DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if ( scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.match.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if(statusName=='Ongoing'){
      return TextButton(onPressed: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context)=> Matchwatch(match:widget.match),
          ),
        );
      } , child: const Text('Watch'),);
    }else{
      return const Text('');
    }
  }
}
class Watch1 extends StatefulWidget {
  MatchM matches;
  Watch1({super.key,required this.matches});

  @override
  State<Watch1> createState() => _Watch1State();
}

class _Watch1State extends State<Watch1> {
  String statusName='';
  String state='1';
  String state1='0';
  String state2='0';
  @override
  void initState(){
    super.initState();
    DateTime scheduledDate = widget.matches.timestamp.toDate();
    if (widget.matches.status == state && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Ongoing';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month > DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year < DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day < DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year > DateTime.now().year && scheduledDate.month > DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year < DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day > DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month < DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Recently';
      });
    } else if (widget.matches.status == state1 && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      setState(() {
        statusName = 'Upcoming1';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if(statusName=='Ongoing'){
      return TextButton(onPressed: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>Debate(matches: widget.matches,)));
      } , child: const Text('Debate'),);
    }else if(statusName=='Upcoming1'){
      return TextButton(onPressed: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>Debate(matches: widget.matches,)));
      } , child: const Text('Debate'),);
    }else if(statusName=='Upcoming'){
      return const Text('');
    }else if(statusName=='Recently'){
      return   TextButton(onPressed: (){
        Navigator.push(context,
          MaterialPageRoute(builder: (context)=> Stats(matches: widget.matches,),
          ),
        );
      } , child: const Text('Stats'),);
    }else{
      return const Text('Unknown');
    }
  }
}


class UpDebate extends StatefulWidget {
  MatchM matches;
  UpDebate({super.key,
    required this.matches});

  @override
  State<UpDebate> createState() => _UpDebateState();
}

class _UpDebateState extends State<UpDebate> {
  late DateTime scheduledDate;
  @override
  void initState() {
    super.initState();
    scheduledDate = widget.matches.timestamp.toDate();
  }
  @override
  Widget build(BuildContext context) {
    if (widget.matches.status == '0' && scheduledDate.year == DateTime.now().year && scheduledDate.month == DateTime.now().month && scheduledDate.day == DateTime.now().day) {
      return TextButton(onPressed: (){
        Navigator.push(context,
            MaterialPageRoute(builder: (context)=>Debate(matches: widget.matches,)));
      } , child: const Text('Debate'),);
    }else{
      return TextButton(onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUp(matches: widget.matches,)));
      }, child: const Text('LineUp'));
    }
  }
}

class LineUp extends StatefulWidget {
  MatchM matches;
  LineUp({super.key,required this.matches});

  @override
  State<LineUp> createState() => _LineUpState();
}

class _LineUpState extends State<LineUp> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String winner='';
  late Matches match1;
  @override
  void initState(){
    super.initState();
    setState(() {
      match1= Matches(
        league: Person(
            name:'',
            url:'',
            collectionName:'',
            userId:''
        ),
        authorId:'' ,
        timestamp:Timestamp.now(),
        location:'',
        score1:0,
        score2:0,
        status:'',
        starttime:'',
        matchId:'',
        createdat:'',
        tittle:'',
        leaguematchId:'',
        match1Id:'',
        status1:'',
        club1:Person(
            name:'',
            url:'',
            collectionName:'',
            userId:''),
        club2:Person(
            name:'',
            url:'',
            collectionName:'',
            userId:''),

      );
    });
    setState(() {
      if(widget.matches.score2>widget.matches.score1){
        winner='club2';
      }else if(widget.matches.score1>widget.matches.score2){
        winner='club1';
      }else if(widget.matches.score1==widget.matches.score2){
        winner='draw';
      }
    });
    retrieveMatch2();
  }
  void retrieveMatch2() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Matches')
          .doc(widget.matches.match1Id)
          .get();

      if (documentSnapshot.exists) {
        var doc = documentSnapshot.data() as Map<String, dynamic>;
        Timestamp createdAt = doc['scheduledDate'] ?? Timestamp.now();
        DateTime createdDateTime = createdAt.toDate();
        String formattedTime = '';
        formattedTime = DateFormat('d MMM').format(createdDateTime);
        String club1name='';
        String collectionName1='';
        String imageurl1='';
        String club2name='';
        String collectionName2='';
        String imageurl2='';
        final data= await FirebaseFirestore.instance.collection('Clubs').doc(doc['club1Id']).get();
        if(data.exists){
          setState(() {
            club1name=data['Clubname']??'';
            collectionName1="Club";
            imageurl1=data['profileimage']??'';
          });
        }else{
          final data1= await FirebaseFirestore.instance.collection('Professionals').doc(doc['club1Id']).get();
          setState(() {
            club1name=data1['Stagename']??'';
            collectionName1="Professional";
            imageurl1=data1['profileimage']??'';
          });

        }

        final data2 =await FirebaseFirestore.instance.collection('Clubs').doc(doc['club2Id']).get();
        if(data2.exists){
          setState(() {
            club2name=data2['Clubname']??'';
            collectionName2="Club";
            imageurl2=data2['profileimage']??'';
          });
        }else{
          final data1=await FirebaseFirestore.instance.collection('Professionals').doc(doc['club2Id']).get();
          setState(() {
            club2name=data1['Stagename']??'';
            collectionName2="Professional";
            imageurl2=data1['profileimage']??'';
          });
        }

        String name='';
        String url='';
        final data3=await FirebaseFirestore.instance.collection('Leagues').doc(doc['leagueId']).get();
        if(data3.exists){
          setState(() {
            name=data3['leaguename']??'';
            url=data3['profileimage']??'';
          });
        }
        setState(() {
          match1= Matches(
            league: Person(
                name: name,
                url: url,
                collectionName:'League',
                userId: doc['leagueId']??''
            ),
            authorId:doc['authorId']??'' ,
            timestamp: doc['createdAt'],
            location: doc['location'] ?? '',
            score1: doc['score1'] ?? '',
            score2: doc['score2'] ?? '',
            status: doc['state1'] ?? '',
            starttime: doc['time'] ?? '',
            matchId: doc['matchId'] ?? '',
            createdat: formattedTime,
            tittle: doc['title'] ?? '',
            leaguematchId: doc['leaguematchId'] ?? '',
            match1Id: doc['match1Id']??'',
            status1: doc['state2'] ?? '',
            club1:Person(
                name: club1name,
                url: imageurl1,
                collectionName: collectionName1,
                userId: doc['club1Id'] ?? ''),
            club2:Person(
                name: club2name,
                url: imageurl2,
                collectionName: collectionName2,
                userId: doc['club2Id'] ?? ''),

          );
          isloading=false;
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
  bool isloading=true;
  double radius=15;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          title: const Text('Lineups',style:TextStyle(color: Colors.black),),
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          },icon: const Icon(Icons.arrow_back,color: Colors.black,),),
        ),
        body:   FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child:  CustomName(
                                    username: widget.matches.authorId==widget.matches.club1.userId?widget.matches.club1.name:widget.matches.club2.name,
                                    maxsize: 140,
                                    style:const TextStyle(color: Colors.black,fontSize: 14),),
                                ),
                                const Text('Match',style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5),
                            child:FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width*0.95,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      widget.matches.league.userId.isNotEmpty? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomAvatar(imageurl:widget.matches.league.url, radius: 18),
                                          const SizedBox(width: 5,),
                                          CustomName(
                                            username: widget.matches.league.name,
                                            maxsize: 180,
                                            style:const TextStyle(color: Colors.black,fontSize: 16),),
                                        ],
                                      ):const SizedBox.shrink(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.85,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CustomAvatar( radius: radius, imageurl:widget.matches.club1.url),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: CustomName(
                                                        username: widget.matches.club1.name,
                                                        maxsize: 140,
                                                        style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5,right: 2),
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blueGrey,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),
                                                        child: Center(child: Text('${widget.matches.score1}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 3,right: 3),
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blueGrey,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),
                                                        child: const Center(child: Text('VS',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 1,right: 5),
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blueGrey,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),
                                                        child: Center(child: Text('${widget.matches.score2}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),)),
                                                      ),
                                                    ),
                                                    CustomAvatar( radius: radius, imageurl:widget.matches.club2.url),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child:CustomName(
                                                        username: widget.matches.club2.name,
                                                        maxsize: 140,
                                                        style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width*0.5,
                                                height: 40,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Text(widget.matches.createdat),
                                                    Text(widget.matches.starttime),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: 35,
                                        child: Container(
                                            height: 28,
                                            width: MediaQuery.of(context).size.width*0.35,
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: TextButton(onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUpA(match: widget.matches,)));
                                            }, child: const Text('Lineup'))
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: CustomName(username: widget.matches.authorId==widget.matches.club1.userId?widget.matches.club2.userId:widget.matches.club1.userId,
                                    maxsize: 140,
                                    style:const TextStyle(color: Colors.black,fontSize: 14),),
                                ),
                                const Text('Match',style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          widget.matches.match1Id.isNotEmpty? Padding(
                            padding: const EdgeInsets.only(right: 10,left: 10,bottom: 5),
                            child:FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width*0.95,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 5,right: 5,top: 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      match1.league.userId.isNotEmpty? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomAvatar(imageurl:match1.league.url, radius: 18),
                                          const SizedBox(width: 5,),
                                          CustomName(
                                            username: match1.league.name,
                                            maxsize: 180,
                                            style:const TextStyle(color: Colors.black,fontSize: 16),),
                                        ],
                                      ):const SizedBox.shrink(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.85,
                                          decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius: BorderRadius.circular(10)
                                          ),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(top: 6,left: 6, right: 6 ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    CustomAvatar( radius: radius, imageurl:match1.club1.url),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5),
                                                      child: CustomName(
                                                        username: match1.club1.name,
                                                        maxsize: 140,
                                                        style:const TextStyle(color: Colors.black,fontSize: 16),),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 5,right: 2),
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blueGrey,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),
                                                        child: Center(child: Text('${match1.score1}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 3,right: 3),
                                                      child: Container(
                                                        height: 30,
                                                        width: 30,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blueGrey,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),
                                                        child: const Center(child: Text('VS',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),)),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 1,right: 5),
                                                      child: Container(
                                                        height: 20,
                                                        width: 20,
                                                        decoration: BoxDecoration(
                                                            color: Colors.blueGrey,
                                                            borderRadius: BorderRadius.circular(5)
                                                        ),
                                                        child: Center(child: Text('${match1.score2}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),)),
                                                      ),
                                                    ),
                                                    CustomAvatar( radius: radius, imageurl:match1.club2.url),
                                                    Padding(
                                                        padding: const EdgeInsets.only(left: 5),
                                                        child: CustomName(
                                                          username: match1.club2.name,
                                                          maxsize: 140,
                                                          style:const TextStyle(color: Colors.black,fontSize: 16),)
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width*0.5,
                                                height: 40,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Text(match1.createdat),
                                                    Text(match1.starttime),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        height: 35,
                                        child: Container(
                                            height: 28,
                                            width: MediaQuery.of(context).size.width*0.35,
                                            decoration: BoxDecoration(
                                              color: Colors.white70,
                                              borderRadius: BorderRadius.circular(10),
                                            ),

                                            child: TextButton(onPressed: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context)=>LineUpB(match: widget.matches,)));
                                            }, child: const Text('Lineup'))
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ):const Center(child: Text('Have not created a Match')),

                        ],
                      ),
                    ]
                )
            )
        )
    );
  }
}
