import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
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
class ClubPhotoPostPage extends StatefulWidget {
  final List<String> imagePath;

  const ClubPhotoPostPage({super.key, required this.imagePath});

  @override
  State<ClubPhotoPostPage> createState() => _ClubPhotoPostPageState();
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

class _ClubPhotoPostPageState extends State<ClubPhotoPostPage> {

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
  List<String> membertoadd = [];

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
    caption = List.generate(
      widget.imagePath.length,
          (index) => TextEditingController(),
    );
  }

  List<TextEditingController> caption = [];
  TextEditingController location = TextEditingController();
  TextEditingController genre = TextEditingController();

  Future<void> retrieveUsername() async {
    try {
     DocumentSnapshot documentSnapshot= await firestore.collection("${collectionNamefor}s").doc(currentUser!.uid).get();
        if (documentSnapshot.exists) {
          var data = documentSnapshot.data() as Map<String, dynamic>;
          genre.text = data['genre'];
        } else {
          dialog1('No matching document found.');
        }
    } catch (e) {
      dialog1('Error retrieving data: $e');
    }
  }

  File? originalImage;
  String? compressedImageString;
  String? compressedImageSize;
  double compressionProgress = 0.0;
  int targetWidth = 720;
  int targetHeight = 1280;
  String? originalImageSize;

  void _getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUser = user;
      });
      retrieveUsername();
    }
  }

  Future<String> pickAndCompressImage(String file) async {
    String image = '';
    final originalFile = File(file);
    final originalFileSize = (originalFile.lengthSync() / 1024).toStringAsFixed(2);
    setState(() {
      originalImage = originalFile;
      originalImageSize = originalFileSize;
      compressedImageString = null;
      compressedImageSize = null;
      compressionProgress = 0.0;
    });
    await Future.delayed(Duration.zero);
    final compressedBytes = await compressImage(originalFile);
    if (compressedBytes != null) {
      final compressedBase64 = base64Encode(compressedBytes);
      final compressedSizeKB = (compressedBytes.lengthInBytes / 1024).toStringAsFixed(2);
      setState(() {
        compressedImageString = compressedBase64;
        compressedImageSize = compressedSizeKB;
      });
      final tempDir = await getTemporaryDirectory();
      final tempFile = await File('${tempDir.path}/compressed_image.jpg').writeAsBytes(compressedBytes);
      setState(() {
        image = tempFile.path;
      });
    }
    return image;
  }

  Future<Uint8List?> compressImage(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: 85,
      minHeight: targetHeight,
      minWidth: targetWidth,
    );
    return result;
  }



  void back() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void dialog1(String e) {
    showDialog(context: context, builder: (context) {
      return AlertDialog(
        content: Text(e),
      );
    });
  }

  void dialog2() {
    showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('Failed to upload image'),
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


  Future<void> addPostToFirestore() async {
    if (currentUser == null) {
      return;
    }
    final postsCollection = FirebaseFirestore.instance.collection('posts');
    try {
      if (selectedImages.isNotEmpty) {
        // Upload all selected images to Cloudinary
        List<String?> imageURLs = await doMultipleUpload(dataImages);
        imageURLs.removeWhere((url) => url == null);
        List<String> modifiedImageURLs = [];
        for (String? imageURL in imageURLs) {
          if (imageURL != null) {
            String modifiedImageURL = insertStringBetween(imageURL);
            modifiedImageURLs.add(modifiedImageURL);
          }
        }

        // Get the list of maps containing the URLs and their corresponding captions
        final List<Map<String, dynamic>> membersWithTimestamps = [];
        String postId = postsCollection.doc().id;
        Timestamp createdAt = Timestamp.now();
        for (int i = 0; i < modifiedImageURLs.length; i++) {
          membersWithTimestamps.add({
            'url': modifiedImageURLs[i],
            'caption': selectedImages[i]['caption'],
          });
        }

        // Save the post to Firestore
        await postsCollection.doc(postId).set({
          'postId': postId,
          'genre': genre.text,
          'location': location.text,
          'captionUrl': membersWithTimestamps,
          'authorId': currentUser!.uid,
          'createdAt': createdAt,
        }).then((_) async {
          // Show success dialog
          showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('Post added'),
              );
            },
          );
          // Clear the selected images
          selectedImages.clear();
          // Wait for a moment before closing the dialog and navigating
          await Future.delayed(const Duration(seconds: 1));
          Navigator.of(context, rootNavigator: true).pop();
          await Future.delayed(const Duration(seconds: 1));
          navigateBottomBar();
        }).catchError((error) {
          // Handle Firestore errors
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text('$error'),
              );
            },
          );
        });
      } else {
        dialog1('No images were selected for posting.');
      }
    } catch (e) {
      dialog1('Error retrieving user data: $e');
    }
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
  void navigateBottomBar() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Bottomnavbar()),
          (Route<dynamic> route) => false,
    );
  }

  Set<int> selectedIndexes = <int>{};
  List<Map<String, String>> selectedImages = [];
  List<String> locations=[];
  bool isEnabled=false;
  String country='';
  String Country="Add Country";
  int ind=0;
  bool isLoading=false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text(
            'New Post',
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
                    child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.imagePath.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final url = widget.imagePath[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: SizedBox(
                          height: 200,
                          width: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: SizedBox(
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
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                height: 40,
                                                width: 40,
                                                child: Checkbox(
                                                  overlayColor:MaterialStateProperty.all<Color>(Colors.white),
                                                  value: selectedIndexes.contains(index),
                                                  onChanged: (bool? value) {
                                                    setState(() {
                                                      if (value == true) {
                                                        selectedIndexes.add(index);
                                                        selectedImages.add({
                                                          'url': url,
                                                          'caption': caption[index].text,
                                                        });
                                                      } else {
                                                        selectedIndexes.remove(index);
                                                        selectedImages.removeWhere((element) =>
                                                        element['url'] == url);
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
                                    ],
                                  ),
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
                                  decoration:InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                    fillColor: Colors.grey[200],
                                    filled: true,
                                    border: InputBorder.none,
                                    labelText: 'Caption',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                ),
                  ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width*0.935,
                      child: Column(
                        children: [
                          Container(
                              height: 30,
                              width: MediaQuery.of(context).size.width*0.315,
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
                                width: MediaQuery.of(context).size.width*0.65,
                                child: TextFormField(
                                  scrollPhysics: const ScrollPhysics(),
                                  expands: false,
                                  maxLines: 4,
                                  minLines: 1,
                                  controller: location,
                                  decoration:  InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 5,vertical: 1),
                                      fillColor: Colors.grey[200],
                                    filled: true,
                                    border: InputBorder.none,
                                      labelText: 'Location',

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

                                }
                              }, icon: Icon(Icons.refresh))
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30,),
                    SizedBox(
                      height: 35,
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
                        onPressed: () async{
                          setState(() {
                          dataImages=List.generate(selectedImages.length,(index)=>DataTransmitNotifier(path: selectedImages[index]['url']));
                          });
                          await addPostToFirestore();
                        },
                        child: const Text(
                          'Upload post',
                          style: TextStyle(color: Colors.black),
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
        ),
      ),
    );
  }

  Future<List<bool>> checkImageFilesExist(List<String> imagePaths) async {
    final List<Future<bool>> fileExistenceFutures = imagePaths.map((imagePath) => File(imagePath).exists()).toList();
    final List<bool> fileExistenceResults = await Future.wait(fileExistenceFutures);
    return fileExistenceResults;
  }



}
