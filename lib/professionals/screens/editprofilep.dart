import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Add this import
import 'package:path_provider/path_provider.dart';
import 'genrescreen.dart';

class EditprofileP extends StatefulWidget {
  const EditprofileP({super.key});

  @override
  State<EditprofileP> createState() => _EditprofilePState();
}

class _EditprofilePState extends State<EditprofileP> {
  final TextEditingController username = TextEditingController();
  final TextEditingController profession = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController quote = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController genre = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageurl = '';
  String userId='';

  File? originalImage;
  String? compressedImageString;
  String? compressedImageSize;
  double compressionProgress = 0.0;
  int targetWidth = 512; // Default target width
  int targetHeight = 512; // Default target height
  String? originalImageSize;

  Future<String> pickAndCompressImage(String file) async {
    String image='';
    final originalFile = File(file);
// Get the size of the original file and store it as a string
    final originalFileSize = (originalFile.lengthSync() / 1024).toStringAsFixed(2);
    setState(() {
      originalImage = originalFile;
      originalImageSize = originalFileSize; // Store the size as a string
      compressedImageString = null;
      compressedImageSize = null;
      compressionProgress = 0.0; // Reset the progress
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
        image=tempFile.path;
      });
      //await GallerySaver.saveImage(tempFile.path); // Pass the file path
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
  Future<String> uploadImageToStorage(BuildContext context) async {
    String image=await pickAndCompressImage(imageurl);
    File imageFile = File(image);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('Profileprofessionals')
          .child('images')
          .child('$fileName.jpg');

      final uploadTask = ref.putFile(imageFile);
      dialog();
      final snapshot = await uploadTask.whenComplete(() {});
      Navigator.of(context, rootNavigator: true).pop();// Close the progress dialog

      if (snapshot.state == firebase_storage.TaskState.success) {
        String imageURL = await ref.getDownloadURL();
        return imageURL;
      } else {
        print('Image upload task failed');
        return '';
      }
    } catch (e) {
      print('Error uploading image to storage: $e');
      return '';
    }
  }
  Future<void> _getCurrentUser1() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid; // Assign the user ID to the userId variable
      });
      retrieveUsername();
    }
  }
  bool isloading=true;
  void retrieveUsername() async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username.text = data['Stagename']??'';
          location.text = data['Location']??'';
          imageurl = data['profileimage']??'';
          website.text = data['website']??'';
          profession.text = data['profession']??'';
          quote.text = data['quote']??'';
          genre.text =data['genre']??'';
          isloading=false;
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
void dialog(){
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
  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    _getCurrentUser1();
  }
  bool _showCloseIcon = false;
  bool _showCloseIcon1 = false;
  bool _showCloseIcon2 = false;
  bool _showCloseIcon3 = false;
  bool _showCloseIcon4 = false;
  bool _showCloseIcon5 = false;
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('EditProfileProfessionals',_startTime,'');
    super.dispose();
  }
  bool isnetworkPath(String input) {
    return input.startsWith('https');
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          title: const Text(
            'Edit Profile',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 140,
                      width: 150,
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isnetworkPath(imageurl)? CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.black,
                            child: CachedNetworkImage(
                              alignment: Alignment.topCenter,
                              imageUrl: imageurl,
                              imageBuilder: (context, imageProvider) => CircleAvatar(
                                radius: 50,
                                backgroundImage: imageProvider,
                              ),
                            ),
                          ): Container(
                              height: 100,
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                image:DecorationImage(image: FileImage(
                                  File(imageurl),
                                ),fit: BoxFit.cover,),
                              )),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: ()async{
                                    FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(type: FileType.image);
                                    if (result != null && result.files.isNotEmpty) {
                                      File imageFile = File(result.files.single.path!);
                                      setState(() {
                                        imageurl = imageFile.path;
                                      });
                                    }
                                  }, icon: const Icon(Icons.edit)),
                              IconButton(onPressed: (){
                                saveDataToFirestore();
                              }, icon: Icon(Icons.delete))
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      controller: username,
                      onChanged: (value) {
                        setState(() {
                          _showCloseIcon = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        filled: true,
                        hintStyle: const TextStyle(color: Colors.black,
                          fontSize: 20, fontWeight: FontWeight.normal,),
                        fillColor: Colors.white70,
                        suffixIcon: _showCloseIcon ? IconButton(
                          icon: const Icon(Icons.close,color: Colors.black,),
                          onPressed: () {
                            setState(() {
                              username.clear();
                              _showCloseIcon = false;
                            });
                          },
                        ) : null,
                        labelText: 'Stagename'
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      controller: profession,
                      onChanged: (value) {
                        setState(() {
                          _showCloseIcon1 = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        filled: true,
                        hintStyle: const TextStyle(color: Colors.black,
                          fontSize: 20, fontWeight: FontWeight.normal,),
                        fillColor: Colors.white70,
                        suffixIcon: _showCloseIcon1 ? IconButton(
                          icon: const Icon(Icons.close,color: Colors.black,),
                          onPressed: () {
                            setState(() {
                              profession.clear();
                              _showCloseIcon1 = false;
                            });
                          },
                        ) : null,
                        labelText: 'Profession'
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      controller: genre,
                      onTap: (){
                        showModalBottomSheet(
                          isScrollControlled: true,
                          isDismissible: true,
                          backgroundColor: Colors.transparent,
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10),topRight:  Radius.circular(10))),
                          context: context,
                          builder: (BuildContext context) {
                            return Genrescreen( onNextPage: (genr) {
                              setState(() {
                                genre.text = genr; // Store the commentId
                              });});
                          },
                        );
                      },
                      onChanged: (value) {
                        setState(() {
                          _showCloseIcon2 = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(width: 1, color: Colors.black),
                          ),
                          focusedBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(width: 1, color: Colors.black),
                          ),
                          filled: true,
                          hintStyle: const TextStyle(color: Colors.black,
                            fontSize: 20, fontWeight: FontWeight.normal,),
                          fillColor: Colors.white70,
                          suffixIcon: _showCloseIcon2 ? IconButton(
                            icon: const Icon(Icons.close,color: Colors.black,),
                            onPressed: () {
                              setState(() {
                                genre.clear();
                                _showCloseIcon2 = false;
                              });
                            },
                          ) : null,
                          labelText: 'Genre'
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                      controller: location,
                      onChanged: (value) {
                        setState(() {
                          _showCloseIcon3 = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(left: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(width: 1, color: Colors.black),
                        ),
                        filled: true,
                        hintStyle: const TextStyle(color: Colors.black,
                          fontSize: 20, fontWeight: FontWeight.normal,),
                        fillColor: Colors.white70,
                        suffixIcon: _showCloseIcon3 ? IconButton(
                          icon: const Icon(Icons.close,color: Colors.black,),
                          onPressed: () {
                            setState(() {
                              location.clear();
                              _showCloseIcon3 = false;
                            });
                          },
                        ) : null,
                          labelText: 'Location'
                      ),
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        TextFormField(
                          controller: quote,
                          onChanged: (value) {
                            setState(() {
                              _showCloseIcon4 = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.black),
                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.black),
                            ),
                            filled: true,
                            hintStyle: const TextStyle(color: Colors.black,
                              fontSize: 20, fontWeight: FontWeight.normal,),
                            fillColor: Colors.white70,
                            suffixIcon: _showCloseIcon4 ? IconButton(
                              icon: const Icon(Icons.close,color: Colors.black,),
                              onPressed: () {
                                setState(() {
                                  quote.clear();
                                  _showCloseIcon4 = false;
                                });
                              },
                            ) : null,
                              labelText: 'Quote'
                          ),
                        ),
                        IconButton(onPressed: (){
                          saveDataToFirestore();
                        }, icon: Icon(Icons.delete))
                      ],
                    ),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        TextFormField(
                          controller: website,
                          onChanged: (value) {
                            setState(() {
                              _showCloseIcon5 = value.isNotEmpty;
                            });
                          },
                          decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(left: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.black),
                            ),
                            focusedBorder:  OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(width: 1, color: Colors.black),
                            ),
                            filled: true,
                            hintStyle: const TextStyle(color: Colors.black,
                              fontSize: 20, fontWeight: FontWeight.normal,),
                            fillColor: Colors.white70,
                            suffixIcon: _showCloseIcon5 ? IconButton(
                              icon: const Icon(Icons.close,color: Colors.black,),
                              onPressed: () {
                                setState(() {
                                  website.clear();
                                  _showCloseIcon5 = false;
                                });
                              },
                            ) : null,
                            labelText: 'Website'
                          ),
                        ),
                        IconButton(onPressed: (){
                          saveDataToFirestore();
                        }, icon: Icon(Icons.delete))
                      ],
                    ),
                    const SizedBox(height: 20,),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.27,
                      child: actions1(context),
                    ),
                  ],
                ),
                isloading?const Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator()):const SizedBox.shrink()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget actions1(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 30),
              side: const BorderSide(
                color: Colors.grey,
              ),
            ),
            onPressed: () {
              if(imageurl.isNotEmpty){
                uploadAndSaveImage();
              }else{
                saveDataToFirestore();
              }

            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void uploadAndSaveImage() async {
    if (imageurl.isNotEmpty) {
      File imageFile = File(imageurl);

      if (imageFile.existsSync()) {
        String? imageUrl = await uploadImageToStorage(context);

        setState(() {
          imageurl = imageUrl;
        });
        saveDataToFirestore();
            }else{
        saveDataToFirestore();
      }
    }
  }





  Future<void> saveDataToFirestore() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: MediaQuery.of(context).size.height*0.02222),
                const Text('Updating profile...'),
              ],
            ),
          ),
        );
      },
    );
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Professionals')
          .where('profeid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};

        if (username.text.isNotEmpty && username.text != oldData['Stagename']) {
          newData['Stagename'] = username.text;
        }
        if (username.text.isNotEmpty && username.text != oldData['searchname']) {
          newData['searchname'] = username.text.toLowerCase();
        }
        if (profession.text.isNotEmpty && profession.text != oldData['Genre']) {
          newData['profession'] = profession.text;
        }
        if (quote.text.isNotEmpty && quote.text != oldData['Motto']) {
          newData['quote'] = quote.text;
        }
        if (website.text.isNotEmpty && website.text != oldData['website']) {
          newData['website'] = website.text;
        }
        if (location.text.isNotEmpty && location.text != oldData['Location']) {
          newData['Location'] = location.text;
        }
        if (imageurl.isNotEmpty&&imageurl != oldData['profileimage']) {
          newData['profileimage'] = imageurl;
        }
        if (genre.text.isNotEmpty&&genre.text != oldData['genre']) {
          newData['genre'] = genre.text;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          await Future.delayed(const Duration(milliseconds: 2500));
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(const Duration(milliseconds: 1000));
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text('Profile updated successfully'),
                );
              });
          await Future.delayed(const Duration(seconds: 4),(){});
          Navigator.of(context, rootNavigator: true).pop();
          print('Data saved successfully');
        } else {
          print('No changes to update');
        }
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.of(context,rootNavigator: true).pop();
      await Future.delayed(const Duration(milliseconds: 1000));
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Failed to update Profile'),
            );
          });
      await Future.delayed(const Duration(seconds: 4),(){});
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

}

