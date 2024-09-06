import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:uuid/uuid.dart';
import '../../fans/components/bottomnavigationbar.dart';
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
class Poststory1 extends StatefulWidget {
  final List<String> imagePath;
  const Poststory1({super.key, required this.imagePath});

  @override
  State<Poststory1> createState() => _Poststory1State();
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
class _Poststory1State extends State<Poststory1> {

  static const int loadImage = 1;
  static const int doSignedUpload = 2;
  static const int doUnsignedUpload = 3;
  List<DataTransmitNotifier> dataImages = [];
  List<CloudinaryResponse> cloudinaryResponses = [];
  bool loading = false;
  String? errorMessage;
  FileSource fileSource = FileSource.path;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late User? currentUser;
  List<TextEditingController> caption = [];
  late List<VideoPlayerController> _videoControllers;
  late List<Future<void>> _initializeVideoPlayerFutures;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _getCurrentUser();
    caption = List.generate(
      widget.imagePath.length,
          (index) => TextEditingController(),
    );
    _videoControllers = List.generate(
      widget.imagePath.length,
          (index) => VideoPlayerController.file(File(widget.imagePath[index])),
    );

    _initializeVideoPlayerFutures = _videoControllers
        .map((controller) => controller.initialize())
        .toList();
  }
  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });
    }
  }

void back(){
  Navigator.of(context, rootNavigator: true).pop();
}
void dialogE1(String e){
  showDialog(context: context, builder: (context){
    return  AlertDialog(
      content: Text('failed to upload File:$e'),
    );
  });
}
  Future<List<int>> getFileBytes(String path) async {
    return await File(path).readAsBytes();
  }

  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();
    return uniqueId;
  }
  Future<List<Map<String?,dynamic>>> doMultipleUpload(List<Map<String?,dynamic>> storys) async {
    List<String> urls = [];
    List<Map<String?,dynamic>> storys1=[];
    List<String> publicIds = [];
    try {
      for (int i = 0; i < storys.length; i++) {
        final item = storys[i];
        final image = item['url1'];
        final video = item['url'];
        final caption = item['caption'];
        final duration = item['duration'];
        if (image.toString().isNotEmpty) {
          final data = DataTransmitNotifier(path: image);
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
            resourceType: CloudinaryResourceType.image,
            // Assuming you're uploading images
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
            storys1.add({
              'url':'',
              'url1':url,
              'caption': caption,
              'duration':duration,
            });
            back();
          } else {
            setState(() {
              errorMessage = response.error;
            });
            // Continue to the next image in case of error
          }
        } else {
          final data = DataTransmitNotifier(path: video);
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
            resourceType: CloudinaryResourceType.video,
            // Assuming you're uploading images
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
            storys1.add({
              'url':url,
              'url1':'',
              'caption': caption,
              'duration':duration,
            });
            back();
          } else {
            setState(() {
              errorMessage = response.error;
            });
            // Continue to the next image in case of error
          }
        }
      }
      return storys1;
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      if (kDebugMode) {
        print(e);
      }
      return storys1;
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

  Future<void> addPostToFirestore() async {
    if (currentUser == null) {
      return;
    }
    final postsCollection = FirebaseFirestore.instance.collection('Story');
    String  id=postsCollection.doc().id;
   QuerySnapshot? documentSnapshot;
    try {
      documentSnapshot = await postsCollection.where('authorId',isEqualTo: currentUser!.uid).orderBy('createdAt',descending: true).get();
    } catch (e) {
      dialoge('Error getting document: $e');
    }
    try {
      if (selectedImages.isNotEmpty) {
        List<Map<String?,dynamic>> stories = await doMultipleUpload(selectedImages,);
        final List<Map<String, dynamic>> membersWithTimestamps = [];
        String storyId = generateUniqueNotificationId();
        Timestamp createdAt = Timestamp.now();
        for (final item in stories) {
          String image=item['url1'];
          String video= item['url'];
          String caption = item['caption'];
          int duration= item['duration'];
            if(video.isNotEmpty){
            membersWithTimestamps.add({
              'url': video,
              'url1':'',
              'duration':duration,
              'caption':caption,
              'storyId': storyId,
              'timestamp': createdAt,
            });}else{
        membersWithTimestamps.add({
          'url1': image,
          'url':'',
          'caption': caption,
          'storyId': storyId,
          'timestamp': createdAt,
        });
        }}
        if (documentSnapshot != null && documentSnapshot.docs.isNotEmpty) {
          final data= documentSnapshot.docs.first.data()as Map<String, dynamic>;
          List<Map<String, dynamic>>  existingStory = List<Map<String, dynamic>>.from(data['story']);
          existingStory.addAll(membersWithTimestamps);
          var fcmCreatedAt = data['createdAt'] as Timestamp?;
          DateTime? time=fcmCreatedAt?.toDate();
          DateTime time1=DateTime(time!.year,time.month,time.day);
          DateTime now=DateTime.now();
          DateTime time2=DateTime(now.year,now.month,now.day);
          if(time1.isAtSameMomentAs(time2)){
          postsCollection.doc(documentSnapshot.docs.first.id).update({
            'story': existingStory,
          }).then((_) async {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    content: Text('Story added'),
                  );
                });
            selectedImages.clear();
            await Future.delayed(const Duration(seconds: 1));
            Navigator.of(context,rootNavigator: true).pop();
            await Future.delayed(const Duration(seconds: 1));
            navigateBottomBar();
          }).catchError((error) {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                content: Text('$error'),
              );
            });
          });}else{
            postsCollection.doc(id).set({
              'StoryId':id,
              'authorId': currentUser!.uid,
              'createdAt': createdAt,
              'story': membersWithTimestamps,
            }).then((_)async{
              showDialog(
                  context: context,
                  builder: (context) {
                    return const AlertDialog(
                      content: Text('Story added'),
                    );
                  });
              await Future.delayed(const Duration(seconds: 1));
              Navigator.of(context,rootNavigator: true).pop();
              await Future.delayed(const Duration(seconds: 1));
              navigateBottomBar();
            }).catchError((error) {
              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  content: Text('$error'),
                );
              });
            });
          }
        } else {
          postsCollection.doc(id).set({
            'StoryId':postsCollection.id,
            'authorId': currentUser!.uid,
            'createdAt': createdAt,
            'story': membersWithTimestamps,
          }).then((_)async {
            showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    content: Text('Story added'),
                  );
                });
            await Future.delayed(const Duration(seconds: 1));
            Navigator.of(context,rootNavigator: true).pop();
            await Future.delayed(const Duration(seconds: 1));
            navigateBottomBar();
          }).catchError((error) {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                content: Text('$error'),
              );
            });
          });
        }
      } else {
      }
    } catch (e) {
     dialoge(e.toString());
    }
  }
void dialoge(String e){
  showDialog(context: context, builder: (context) {
    return AlertDialog(
      content: Text(e),
    );
  });
}
  void navigateBottomBar() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottomnavbar()),
          (Route<dynamic> route) => false,
    );
  }

  Set<int> selectedIndexes = <int>{};
  List<Map<String, dynamic>> selectedImages = [];
  @override
  void dispose() {
    for (var controller in _videoControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 33),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.white,
          title: const Text(
            'New Story',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: FutureBuilder<List<bool>>(
          future: checkImageFilesExist(widget.imagePath),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return  SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 400,
                      child:ListView.builder(
                        shrinkWrap: true,
                        itemCount: widget.imagePath.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final url = widget.imagePath[index];
                          bool isVideo = url.toLowerCase().endsWith('.mp4');
                          if (isVideo) {
                              final controller = _videoControllers[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                                child: SizedBox(
                                  width: 150,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      FutureBuilder<void>(
                                        future: _initializeVideoPlayerFutures[index],
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done) {
                                            return  SizedBox(
                                              height: 200,
                                              width: 150,
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                    height: 200,
                                                    width: 150,
                                                    child: AspectRatio(
                                                      aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
                                                      child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(10),
                                                          child: VideoPlayer(controller)),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topRight,
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 5),
                                                      child: SizedBox(
                                                        height: 40,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            SizedBox(
                                                              height: 40,
                                                              width: 40,
                                                              child: Checkbox(
                                                                value: selectedIndexes.contains(index),
                                                                onChanged: (bool? value) {
                                                                  setState(() {
                                                                    if (value == true) {
                                                                      selectedIndexes.add(index);
                                                                      selectedImages.add({
                                                                        'url': url,
                                                                        'url1':'',
                                                                        'caption': caption[index].text,
                                                                        'duration':controller.value.duration.inSeconds,
                                                                      });
                                                                    } else {
                                                                      selectedIndexes.remove(index);
                                                                      selectedImages.removeWhere(
                                                                              (element) => element['url'] == url);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: (){
                                                                setState(() {
                                                                  widget.imagePath.remove(url);
                                                                  selectedIndexes.remove(index);
                                                                  selectedImages.removeWhere(
                                                                          (element) => element['url'] == url);
                                                                });
                                                              },
                                                              child: const SizedBox(
                                                                  height: 40,
                                                                  width: 40,
                                                                  child: Icon(Icons.close,color: Colors.white,)
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text('${snapshot.error}');
                                          } else {
                                            return const CircularProgressIndicator();
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width*0.375,
                                        child: TextFormField(
                                          scrollPhysics: const ScrollPhysics(),
                                          expands: false,
                                          maxLines: 4,
                                          minLines: 1,
                                          controller: caption[index],
                                          decoration: const InputDecoration(
                                            contentPadding: EdgeInsets.all(1),
                                            labelText: 'caption',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: SizedBox(
                                width: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 200,
                                      width: 150,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: SizedBox(
                                              height: 200,
                                              width: 150,
                                              child: Image.file(
                                                File(url),
                                                fit: BoxFit.fill,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 6,vertical: 5),
                                              child: SizedBox(
                                                height: 40,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      height: 40,
                                                      width: 40,
                                                      child: Checkbox(
                                                        overlayColor:WidgetStateProperty.all<Color>(Colors.white),
                                                        value: selectedIndexes.contains(index),
                                                        onChanged: (bool? value) {
                                                          setState(() {
                                                            if (value == true) {
                                                              selectedIndexes.add(index);
                                                              selectedImages.add({
                                                                'url':'',
                                                                'url1': url,
                                                                'duration':0,
                                                                'caption': caption[index].text, // Initialize caption
                                                              });
                                                            } else {
                                                              selectedIndexes.remove(index);
                                                              selectedImages.removeWhere(
                                                                      (element) => element['url1'] == url);
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    InkWell(
                                                      onTap: (){
                                                        setState(() {
                                                          widget.imagePath.remove(url);
                                                          selectedIndexes.remove(index);
                                                          selectedImages.removeWhere(
                                                                  (element) => element['url'] == url);
                                                        });
                                                      },
                                                      child: const SizedBox(
                                                          height: 40,
                                                          width: 40,
                                                          child: Icon(Icons.close,color: Colors.white,)
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.375,
                                      child: TextFormField(
                                        scrollPhysics: const ScrollPhysics(),
                                        expands: false,
                                        maxLines: 4,
                                        minLines: 1,
                                        controller: caption[index],
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.all(1),
                                          labelText: 'caption',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      )

                    ),
                    SizedBox(
                      height: 30,
                      width: 130,
                      child: OutlinedButton(
                        style: ButtonStyle(
                          foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                        onPressed: () async{
                          await addPostToFirestore();
                        },
                        child: const Text(
                          'Upload story',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }else if(snapshot.hasError){
              return Text('${snapshot.error}');
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        )),
    );
  }

  Future<List<bool>> checkImageFilesExist(List<String> imagePaths) async {
    final List<Future<bool>> fileExistenceFutures = imagePaths.map((imagePath) => File(imagePath).exists()).toList();
    final List<bool> fileExistenceResults = await Future.wait(fileExistenceFutures);
    return fileExistenceResults;
  }



}
