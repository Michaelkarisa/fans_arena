import 'package:fans_arena/fans/components/followerstabbar.dart';
import 'package:fans_arena/fans/screens/messages.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:uuid/uuid.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:flutter/foundation.dart';
import '../../appid.dart';
import '../../fans/components/bottomnavigationbar.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String apiKey =
String.fromEnvironment('316131999212869', defaultValue: '316131999212869');
const String apiSecret =
String.fromEnvironment('lMUJoL0R7-45y_iRbY-QI3ShFK4', defaultValue: 'lMUJoL0R7-45y_iRbY-QI3ShFK4');
const String cloudName =
String.fromEnvironment('dtwfhkkhm', defaultValue: 'dtwfhkkhm');
const String folder =
String.fromEnvironment('videos', defaultValue: 'videos');
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

class ClubsvideoPostpage extends StatefulWidget {
  final String videoPath;
  const ClubsvideoPostpage({super.key, required this.videoPath});

  @override
  State<ClubsvideoPostpage> createState() => _ClubsvideoPostpageState();
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

class _ClubsvideoPostpageState extends State<ClubsvideoPostpage> {
  static const int loadImage = 1;
  static const int doSignedUpload = 2;
  static const int doUnsignedUpload = 3;
  DataTransmitNotifier dataImages = DataTransmitNotifier();
  CloudinaryResponse cloudinaryResponses = CloudinaryResponse();
  bool loading = false;
  String? errorMessage;
  FileSource fileSource = FileSource.path;

  late VideoPlayerController _videoController;
  late Future<void> _initializeVideoPlayerFuture;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    _videoController = VideoPlayerController.file(File(widget.videoPath));
    _initializeVideoPlayerFuture = _videoController.initialize().then((_) {
      setState(() {
        dataImages = DataTransmitNotifier(path: widget.videoPath);
        _isPlaying = true;
            changed=true;
        _videoController.play();
      });
      _videoController.addListener((){
        setState(() {
          if(_videoController.value.isCompleted){
            _isPlaying = false;
            changed=false;
          }
        });
      });
    });
  }

  Future<Map<String, dynamic>> fetchCurrentAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final String geocodeApiUrl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapsApi';
      final response = await http.get(Uri.parse(geocodeApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final addressComponents = data['results'][0]['address_components'] as List;
          List<String> addressDetails = addressComponents.map((component) {
            return component['long_name'] as String;
          }).toList();
          String country = addressComponents.firstWhere(
                  (component) => (component['types'] as List).contains('country'),
              orElse: () => {'long_name': 'Unknown'}
          )['long_name'];
          final String placesApiUrl = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
          final responsePlaces = await http.get(
              Uri.parse('$placesApiUrl?location=${position.latitude},${position.longitude}&radius=2000&key=$mapsApi')
          );
          List<String> nearbyPlaces = [];
          if (responsePlaces.statusCode == 200) {
            final placesData = json.decode(responsePlaces.body);
            if (placesData['results'] != null && placesData['results'].isNotEmpty) {
              nearbyPlaces.addAll(placesData['results'].map<String>((place) {
                return '${place['name']}';
              }).toList());
            } else {
              nearbyPlaces.add('No nearby places found');
            }
          } else {
            nearbyPlaces.add('Error: ${responsePlaces.statusCode}');
          }
          return {
            'addressDetails': addressDetails,
            'country': country,
            'nearbyPlaces': nearbyPlaces
          };
        } else {
          return {
            'addressDetails': ['No address found'],
            'country': 'Unknown',
            'nearbyPlaces': ['No nearby places found']
          };
        }
      } else {
        throw Exception('Failed to fetch address');
      }
    } catch (e) {
      return {
        'addressDetails': ['Error: $e'],
        'country': 'Unknown',
        'nearbyPlaces': ['Error: $e']
      };
    }
  }



  @override
  void dispose() {
    _getCurrentUser();
    _videoController.dispose();
    super.dispose();
  }
  List<String> locations=[];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late User? currentUser;

  TextEditingController caption = TextEditingController();
  TextEditingController location = TextEditingController();


  void dialog2() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16.0),
              Text('Uploading Image...'),
            ],
          ),
        );
      },
    );
  }
String genre="";
  Future<void> retrieveUsername() async {
    try {
      DocumentSnapshot doc=await firestore.collection('${collectionNamefor}s').doc(currentUser!.uid).get();
        if (doc.exists) {
          var data = doc.data() as Map<String, dynamic>;
            setState(() {
              genre= data['genre'];
            });
        } else {
          dialog1('No matching document found.');
        }
    } catch (e) {
      dialog1('Error retrieving data: $e');
    }
  }

  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });
      retrieveUsername();
    }
  }

  Future<String> uploadImageToStorage(BuildContext context, String url) async {
    File imageFile = File(url);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('FansTv')
          .child('thumbnail')
          .child('$fileName.jpg');

      final uploadTask = ref.putFile(imageFile);
      dialog2();
      uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        Navigator.of(context, rootNavigator: true).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                  ),
                  Text('Uploading image... ${(progress * 100).toStringAsFixed(2)}%'),
                ],
              ),
            );
          },
        );
      });
      final snapshot = await uploadTask.whenComplete(() {});
      back();
      if (snapshot.state == firebase_storage.TaskState.success) {
        String imageURL = await ref.getDownloadURL();
        return imageURL;
      } else {
        dialog1('Image upload task failed');
        return '';
      }
    } catch (e) {
      dialog1('Error uploading image to storage: $e');
      return '';
    }
  }

  void onNewImages(List<String> filePaths) {
    if (filePaths.isNotEmpty) {
      for (final path in filePaths) {
        if (path.isNotEmpty) {
          setState(() {
            dataImages = DataTransmitNotifier(path: path);
          });

        }
      }
      setState(() {});
    }
  }

  Future<List<int>> getFileBytes(String path) async {
    return await File(path).readAsBytes();
  }
  String generateUniqueNotificationId() {
    final String uniqueId = const Uuid().v4();

    return uniqueId;
  }
  String publicId='';
  void dialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ValueListenableBuilder<double>(
              key: ValueKey(dataImages.path),
              valueListenable: dataImages.notifier,
              builder: (context, value, child) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LinearProgressIndicator(
                      value: value,
                      minHeight: 8.0,
                    ),
                    const SizedBox(height: 4.0),
                  cloudinaryResponses.isSuccessful?Icon(Icons.check_circle, color: Colors.green,):Text('${(value * 100).toInt()} %'),
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

  void dialog1(String value) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(value),
        );
      },
    );
  }

  Future<void> uploadToCloudinary({required String path, required String uploadPreset}) async {
    try {
      dialog();
      final response = await cloudinary.unsignedUpload(
        file: path,
        uploadPreset: uploadPreset,
        resourceType: CloudinaryResourceType.video,
        progressCallback: dataImages.progressCallback,
      );
      Navigator.of(context, rootNavigator: true).pop();
      if (response.isSuccessful) {
        setState(() {
          cloudinaryResponses = response;
          publicId = cloudinaryResponses.publicId!;
        });
      } else {
        dialog1('Video upload failed: ${response.error}');
      }
    } catch (e) {
      dialog1('Error uploading video: $e');
    }
  }
  Future<String> doSingleUpload() async {
    String url = '';
    publicId = generateUniqueNotificationId();
    try {
      final data = dataImages;
      List<int>? fileBytes;
      if (fileSource == FileSource.bytes) {
        fileBytes = await getFileBytes(data.path!);
      }
      dialog();
      setState(() {});
      CloudinaryResponse response = await cloudinary1.upload(
        file: data.path,
        fileBytes: fileBytes,
        resourceType: CloudinaryResourceType.video,
        folder: folder,
        progressCallback: (progress, progress1) {
          setState(() {
            dataImages.notifier.value = progress.toDouble();
          });
          data.progressCallback!(progress, progress1);
        },
        publicId: publicId,
      );
      if (response.isSuccessful && response.secureUrl!.isNotEmpty) {
        setState(() {
          cloudinaryResponses = response;
          url = response.secureUrl!;
          publicId = response.publicId!;

        });
        back();
      } else {
        setState(() {
          errorMessage = response.error;
        });
      }
      return url;
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
      if (kDebugMode) {
        print(e);
      }
      return url;
    }
  }
  void back(){
    Navigator.of(context, rootNavigator: true).pop();
  }

  String insertStringBetween(String original,) {
    String insert = 'f_auto:video,q_auto/v1';
    String w1 = original.replaceFirst(RegExp(r'/upload/v1\d+/'), '/upload/$insert/');
    return w1;
  }
  Future<void> addPostToFirestore() async {
    if (currentUser == null) {
      return;
    }
    final postsCollection = FirebaseFirestore.instance.collection('FansTv');
    try {
      String originalImageURL = await doSingleUpload();
      if (originalImageURL.isNotEmpty) {
        String modifiedImageURL = insertStringBetween(originalImageURL);
        String postId = postsCollection.doc().id;
        Timestamp createdAt = Timestamp.now();
        postsCollection
            .doc(postId)
            .set({
          'postId': postId,
          'genre': genre,
          'location': location.text,
          'caption': caption.text,
          'url': modifiedImageURL,
          'thumbnail':'',
          'authorId': currentUser!.uid,
          'createdAt': createdAt,
          "hashes":hashes,
          'publicId': publicId,
        }).then((_) async {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text('Post added'),
                );
              });
          await Future.delayed(const Duration(seconds: 1));
          Navigator.of(context,rootNavigator: true).pop();
        }).catchError((error) {
          showDialog(
              context: context,
              builder: (context) {
                return  AlertDialog(
                  content: Text('Post upload failed:$error'),
                );
              });
        });
      } else {
        dialog1('Post upload failed');
      }
    } catch (e) {
      dialog1('Error retrieving user data: $e');
    }
  }

List<String>hashes=[];
  void navigateBottomBar() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottomnavbar()),
          (Route<dynamic> route) => false,
    );
  }
  bool changed =false;
bool isLoading=false;
  bool isEnabled=false;
  String country='';
  String Country="Add Country";
  int ind=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New FansTv',
        ),
      ),
      body: SizedBox(
          width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                    color: Colors.white,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 10.0,
                            maxWidth: 280.0,
                            maxHeight: 280,
                            minHeight: 10,
                          ),
                          child: Container(
                            color: Colors.black,
                            child:_videoController!=null? FutureBuilder<void>(
                              future: _initializeVideoPlayerFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return AspectRatio(
                                    aspectRatio: _videoController.value.aspectRatio,
                                    child: Stack(
                                      children: [
                                        VideoPlayer(_videoController),
                                        Positioned.fill(
                                          child: AnimatedOpacity(
                                            opacity: changed ? 0.0 : 1.0,
                                            duration: const Duration(milliseconds: 500),
                                            child: Align(
                                              alignment:  Alignment.center,
                                              child: IconButton(
                                                icon:_isPlaying ? const Icon(Icons.pause, size: 50,color: Colors.white,): const Icon(Icons.play_arrow, size: 50,color: Colors.white,),
                                                onPressed: ()async{
                                                  if (_videoController.value.isPlaying) {
                                                    setState(() {
                                                      changed =false;
                                                      _videoController.pause();
                                                    });
                                                    await  Future.delayed(const Duration(milliseconds: 400));
                                                    setState(() {
                                                      _isPlaying = false;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _videoController.play();
                                                      _isPlaying = true;
                                                      changed =true;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            ):const Center(child: CircularProgressIndicator()),
                          ),
                        )
                    )
                ),
              ),

              const SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.835,
                child: TextFormField(
                  controller: caption,
                  expands: false,
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                    labelText: 'Caption',
                    filled: true,
                    fillColor: Colors.grey[200],
                      border: InputBorder.none
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.935,
                child: Column(
                  children: [
                    Container(
                      height: 30,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.blue[300]!
                          )
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                          Text(Country,style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),),
                          IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: (){
                                setState(() {
                                  isEnabled=!isEnabled;
                                  if(isEnabled){
                                    location.text =
                                    "${locations[ind]}, ${country}";
                                  }else{
                                    location.text=locations[ind];
                                  }
                                });
                              },icon:Icon(
                            isEnabled ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color:isEnabled? Colors.purple:Colors.black54,
                          )),
                                                ],
                                              ),
                        )),
                    const SizedBox(height: 10.0),
                    locations.isEmpty?Text("Refresh to add locations"):SizedBox(
                      height: 40,
                      child: ListView.builder(
                          itemCount: locations.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context,index){
                            return  InkWell(
                              onTap:(){
                                setState(() {
                                  ind=index;
                                  if(isEnabled) {
                                    location.text =
                                    "${locations[index]}, ${country}";
                                  }else{
                                    location.text=locations[index];
                                  }
                                });
                              },
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal:20),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Container(
                                      height: 28,
                                      decoration:  BoxDecoration(
                                        color: Colors.grey[500],
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(10),bottomLeft: Radius.circular(10),topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                         SizedBox(
                                              width: 30,
                                              child: Icon(Icons.location_on_outlined,color: Colors.black54,)),
                                          Padding(
                                            padding: const EdgeInsets.only(right: 10,left: 2),
                                            child: Text(
                                              locations[index],style: const TextStyle(color: Colors.black,fontSize: 15),),
                                          )
                                        ],
                                      ),
                                    ),
                                  )),
                            );
                          }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined),
                        SizedBox(width: 15,),
                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.635,
                          child: TextFormField(
                            scrollPhysics: const ScrollPhysics(),
                            expands: false,
                            maxLines: 4,
                            minLines: 1,
                            controller: location,
                            decoration:  InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                fillColor: Colors.grey[200],
                                labelText: 'Location',
                              filled: true,
                              border: InputBorder.none
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        isLoading?CircularProgressIndicator():IconButton(onPressed: ()async{
                          setState(() {
                            isLoading=true;
                          });
                          try {
                            final addressData = await fetchCurrentAddress();
                            final List<String> addressDetails = List<String>.from(addressData['addressDetails']);
                            final List<String> nearbyPlaces = List<String>.from(addressData['nearbyPlaces']);
                            String c = addressData['country'];
                            if (addressDetails.isNotEmpty) {
                              addressDetails.remove(c);
                              if (addressDetails.isNotEmpty) {
                                addressDetails.removeAt(0);
                              }
                            }
                            locations = [...addressDetails, ...nearbyPlaces];
                            setState(() {
                              country = c;
                              isLoading = false;
                              isEnabled=false;
                            });
                          } catch (e) {
                            dialog1(e.toString());
                          }
                        }, icon: Icon(Icons.refresh))
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20.0),
              InkWell(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Followerstab(userId: FirebaseAuth.instance.currentUser!.uid, index: 0)));
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 35,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Tag Accounts",style: TextStyle(fontSize: 16,),),
                          Icon(Icons.arrow_forward_ios_sharp,)
                        ],
                      ),
                    )),
              ),
              Column(children: hashes.map((userId)=>Container(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomUsernameD0Avatar(userId: userId,
                            style: TextStyle(), radius: 18, maxsize: 200, height: 25, width: 200),
                        Checkbox(value: hashes.any((uid)=>uid==userId),
                            onChanged: (value){
                          setState(() {
                            if(value!){
                              hashes.remove(userId);
                            }
                          });
                        })
                      ],
                    ),
                  ))).toList(),),
              const SizedBox(height: 20.0),
              SizedBox(
                height: 30,
                width: 130,
                child: OutlinedButton(
                  style: ButtonStyle(
                    foregroundColor:
                    WidgetStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                    WidgetStateProperty.all<Color>(Colors.white),
                    shape:
                    WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                        side: const BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                  onPressed: () => addPostToFirestore().then((_) => navigateBottomBar()),
                  child: const Text(
                    'Upload post',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
