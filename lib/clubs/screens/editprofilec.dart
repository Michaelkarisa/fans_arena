import 'package:fans_arena/fans/bloc/usernamedisplay.dart';
import 'package:fans_arena/fans/data/newsfeedmodel.dart';
import 'package:fans_arena/fans/screens/homescreen.dart';
import 'package:fans_arena/fans/screens/leagueviewer.dart';
import 'package:fans_arena/fans/screens/newsfeed.dart';
import 'package:fans_arena/professionals/screens/genrescreen.dart';
import 'package:fans_arena/reusablewidgets/cirularavatar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:fans_arena/joint/data/screens/widgets/readmore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import '../../fans/components/likebutton.dart';
import '../../main.dart';

class EditprofileC extends StatefulWidget {
  Person user;
  EditprofileC({super.key,required this.user});

  @override
  State<EditprofileC> createState() => _EditprofileCState();
}

class _EditprofileCState extends State<EditprofileC> {
  final TextEditingController username = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController genre = TextEditingController();
  final TextEditingController motto = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController history = TextEditingController();
  final TextEditingController fieldname = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageurl = '';
  String userId='';

  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    _getCurrentUser1();
  }
  late DateTime _startTime;

  @override
  void dispose(){
    Engagement().engagement('EditProfileClubs',_startTime,'');
    super.dispose();
  }
  File? originalImage;
  String? compressedImageString;
  String? compressedImageSize;
  double compressionProgress = 0.0;
  int targetWidth = 512;
  int targetHeight = 512;
  String? originalImageSize;

  Future<String> pickAndCompressImage(String file) async {
    String image='';
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
        image=tempFile.path;
      });
      //await GallerySaver.saveImage(tempFile.path);
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
          .child('Profileclubs')
          .child('images')
          .child('$fileName.jpg');
      final uploadTask = ref.putFile(imageFile);
      dialog();
      final snapshot = await uploadTask.whenComplete(() {});
        back();
      if (snapshot.state == firebase_storage.TaskState.success) {
        String imageURL = await ref.getDownloadURL();
        return imageURL;
      } else {
        return '';
      }
    } catch (e) {
      return e.toString();
    }
  }
  void back(){
    Navigator.of(context, rootNavigator: true).pop();
  }
  Future<void> _getCurrentUser1() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
      });
      retrieveUsername();
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
  bool isloading=true;
  void retrieveUsername() async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          username.text = data['Clubname']??'';
          location.text = data['Location']??'';
          genre.text = data['genre']??'';
          motto.text = data['Motto']??'';
          imageurl = data['profileimage']??'';
          website.text = data['website']??'';
          history.text=data['history']??'';
          fieldname.text=data['field']??'';
          isloading=false;
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }
  bool isNetworkPath(String input) {
    return input.startsWith('https');
  }
  bool _showCloseIcon = false;
  bool _showCloseIcon1 = false;
  bool _showCloseIcon2 = false;
  bool _showCloseIcon3 = false;
  bool _showCloseIcon4 = false;
  bool _showCloseIcon5 = false;
  bool _showCloseIcon6 = false;
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
        body:  isloading?const Center(
            child: CircularProgressIndicator()):SizedBox(
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Profile Photo',style:TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 5,),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: SizedBox(
                              height: 140,
                              width: 150,
                              child:Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  isNetworkPath(imageurl)? CircleAvatar(
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
                          ),
                          const SizedBox(
                            height: 20,
                          ),
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
                                labelText: 'Clubname'
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: genre,
                            readOnly: true,
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
                                      genre.text = genr;
                                    });});
                                },
                              );
                            },
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
                                      genre.clear();
                                      _showCloseIcon1 = false;
                                    });
                                  },
                                ) : null,
                                labelText: 'Genre'
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: location,
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
                                      location.clear();
                                      _showCloseIcon2 = false;
                                    });
                                  },
                                ) : null,
                                labelText: 'Location'
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: motto,
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
                                      motto.clear();
                                      _showCloseIcon3 = false;
                                    });
                                  },
                                ) : null,
                                labelText: 'Motto'
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width*0.8,
                                child: TextFormField(
                                  controller: website,
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
                                            website.clear();
                                            _showCloseIcon4 = false;
                                          });
                                        },
                                      ) : null,
                                      labelText: 'Website'
                                  ),
                                ),
                              ),
                              IconButton(onPressed: (){
                                saveDataToFirestore();
                              }, icon: Icon(Icons.delete))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.27,
                            child: actions1(context),
                          ),
                          const SizedBox(height: 20,),
                          const Text('more Info (optional)',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          const SizedBox(
                            height: 10,
                          ),
                          //clubs history
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width*0.8,
                                child: TextFormField(
                                    maxLines: 10,
                                    minLines: 6,
                                    controller: history,
                                    textInputAction: TextInputAction.newline,
                                    decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(left: 10,top: 3),
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
                                        labelText: "club's history"
                                    )),
                              ),
                              IconButton(onPressed: (){
                                saveDataToFirestore();
                              }, icon: Icon(Icons.delete))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width*0.8,
                                child:TextFormField(
                                  controller: fieldname,
                                  textInputAction: TextInputAction.done,
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
                                      labelText: "field name"
                                  )
                              )),
                              IconButton(onPressed: (){
                                saveDataToFirestore();
                              }, icon: Icon(Icons.delete))
                            ],
                          ),

                          const SizedBox(
                            height: 20,
                          ),
                          //Leagues
                          const Text('Current leagues participating',style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(
                            height: 10,
                          ),
                          FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(child:ClubsLeagues(clubId:FirebaseAuth.instance.currentUser!.uid),)),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: actions(context),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('Add accomplishment posts',style: TextStyle(fontWeight: FontWeight.bold),),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    AddAccompPosts(user:widget.user,),
                    const SizedBox(
                      height: 20,
                    ),
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
  Widget actions(BuildContext context) {
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
              saveDataToFirestore1();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                "save more info data",
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
          .collection('Clubs')
          .where('Clubid', isEqualTo:FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (username.text.isNotEmpty && username.text != oldData['Clubname']) {
          newData['Clubname'] = username.text;
        }
        if (username.text.isNotEmpty && username.text != oldData['searchname']) {
          newData['searchname'] = username.text.toLowerCase();
        }
        if (genre.text.isNotEmpty && genre.text != oldData['genre']) {
          newData['genre'] = genre.text;
        }
        if (motto.text.isNotEmpty && motto.text != oldData['Motto']) {
          newData['Motto'] = motto.text;
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
  Future<void> saveDataToFirestore1() async {

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Clubs')
          .where('Clubid', isEqualTo:FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;
        Map<String, dynamic> newData = {};
        if (history.text.isNotEmpty && history.text != oldData['history']) {
          newData['history'] = history.text;
        }
        if (fieldname.text.isNotEmpty && fieldname.text != oldData['field']) {
          newData['field'] = fieldname.text;
        }
        if (newData.isNotEmpty) {
          await documentSnapshot.reference.update(newData);
          await Future.delayed(const Duration(milliseconds: 1500));
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(const Duration(milliseconds: 1000));
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text('History and field added successfully'),
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
      print('Error saving data: $e');
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
class ClubsLeagues extends StatefulWidget {
  String clubId;
   ClubsLeagues({super.key,required this.clubId});

  @override
  State<ClubsLeagues> createState() => _ClubsLeaguesState();
}

class _ClubsLeaguesState extends State<ClubsLeagues> {
  Newsfeedservice news = Newsfeedservice();
  late DateTime _startTime;
  Set<LeagueC> leagues = {};

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    news = Newsfeedservice();
    getData();
  }

  void getData() async {
    List<LeagueC> leagues1 = await DataFetcher().getLeaguesForUser(widget.clubId);
    setState(() {
      leagues.addAll(leagues1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (leagues.isNotEmpty) {
      return Column(
          children: leagues.map<Widget>((post) {
            return Leagueprofile(leagues: post);
          },
          ).toList()
      );
    } else {
      return const Center(child: Text('No Leagues'));
    }
  }
}
class Leagueprofile extends StatefulWidget {
  LeagueC leagues;
 Leagueprofile({super.key,required this.leagues});
  @override
  State<Leagueprofile > createState() => _LeagueprofileState();
}

class _LeagueprofileState extends State<Leagueprofile > {

  @override
  void initState(){
    super.initState();
    retrieveUsername1();
    retrieveUsername2();
  }

  String name(String name) {
    if (name.length > 13) {
      return "${name.substring(0, 13)}...";
    }else{
      return name;
    }
  }
String year='';
  void retrieveUsername1() async {
    QuerySnapshot querysnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagues.leagueId)
        .collection('year')
        .orderBy('timestamp',descending: true)
        .get();

    if (querysnapshot.docs.isNotEmpty) {
      setState(() {
        year=querysnapshot.docs.first.id;
      });
    }
  }
  List<String>years=[];
  Future<void> retrieveUsername2() async {
    QuerySnapshot querysnapshot = await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagues.leagueId)
        .collection('year')
        .orderBy('timestamp',descending: true)
        .get();

    if (querysnapshot.docs.isNotEmpty) {
      List<QueryDocumentSnapshot>documents=querysnapshot.docs;
      for(final document in documents){
        years.add(document.id);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    String name1=name(widget.leagues.leaguename);
    return SizedBox(
      child: InkWell(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>LeagueLayout(league:widget.leagues,year: year, )));
        },
        child: Row(
          children: [
            CustomAvatar(imageurl:widget.leagues.imageurl, radius: 18),
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Text(name1,style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: SizedBox(
                  height:25,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Year: $year'),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        position: PopupMenuPosition.under,
                        icon: const Icon(Icons.arrow_drop_down),
                        onSelected: (value) {
                          setState(() {
                            year = value;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return years.map<PopupMenuEntry<String>>((item) {
                            return PopupMenuItem<String>(
                              value: item.toString(),
                              child: Text(item.toString()),
                            );
                          }).toList();
                        },
                      ),

                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
class Post {
  final String genre;
  final String location;
  final List<Map<String, dynamic>> captionUrl;
  final String time;
  String postid;
  Post({
    required this.genre,
    required this.captionUrl,
    required this.location,
    required this.time,
    required this.postid,
  });
}

class AddAccompPosts extends StatefulWidget {
  Person user;
   AddAccompPosts({super.key,required this.user});

  @override
  State<AddAccompPosts> createState() => _AddAccompPostsState();
}

class _AddAccompPostsState extends State<AddAccompPosts> {
  String genre1 = '';
  String caption1 = '';
  String location1 = '';
  String url = '';
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Posts> posts = [];
  Newsfeedservice news = Newsfeedservice();
  Set<String>postIds={};
  @override
  void initState() {
    super.initState();
    retrieveUserPosts();
    getBestmoments();
  }
  List<Map<String, dynamic>> dataList2 = [];
  void getBestmoments()async{
    String Cname= await news.getAccount(widget.user.userId);
    if(Cname=='Professional'){
      QuerySnapshot documentSnapshot = await firestore.collection('Professional')
          .doc(widget.user.userId)
          .collection('moments')
          .get();
      List<QueryDocumentSnapshot> documents=documentSnapshot.docs;
      for(final data in documents) {
        List<dynamic>accomplishments = data['moments'];
        setState(() {
          dataList2.addAll(accomplishments.cast<Map<String ,dynamic>>());
        });
      }
    }else if(Cname=='Club'){
      QuerySnapshot documentSnapshot = await firestore.collection('Clubs')
          .doc(widget.user.userId)
          .collection('accomplishments')
          .get();
      List<QueryDocumentSnapshot> documents=documentSnapshot.docs;
      for(final data in documents) {
        List<dynamic>accomplishments = data['accomplishments'];
        setState(() {
          dataList2.addAll(accomplishments.cast<Map<String ,dynamic>>());
        });
      }
    }else if(Cname=='Fan'){
      QuerySnapshot documentSnapshot = await firestore.collection('Fans')
          .doc(widget.user.userId)
          .collection('moments')
          .get();
      List<QueryDocumentSnapshot> documents=documentSnapshot.docs;
      for(final data in documents) {
        List<dynamic>accomplishments = data['moments'];
        setState(() {
          dataList2.addAll(accomplishments.cast<Map<String ,dynamic>>());
        });
      }
    }
  }

  void retrieveUserPosts() async {
    List<PostModel>userPosts=await news.getfeed(userId: widget.user.userId);
   setState(() {
     for(final d in userPosts) {
       if(!postIds.contains(d.postid)) {
         posts.add(Posts(
             postid: d.postid,
             timestamp: d.timestamp,
             location: d.location,
             genre: d.genre,
             captionUrl: d.captionUrl,
             time: d.time,
             time1: d.time1,
             user: widget.user));
       }else{
         userPosts.remove(d);
       }
     }
   });
  }

  Future<void> saveDataToFirestore1() async {
String Cname= await news.getAccount(widget.user.userId);
if(Cname=='Club') {
  final CollectionReference likesCollection = FirebaseFirestore.instance
      .collection('Clubs')
      .doc(widget.user.userId)
      .collection('accomplishments');
  List<Map<String, dynamic>> allLikes = [];
  for (final item in selectedStreamerIds) {
    allLikes.add({
      'postId': item['postId'],
      'accomplishment':item['accomplishment'],
      'timestamp': item['timestamp'],
    });
  }
  try {
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> chatsArray = latestDoc['accomplishments'];
      if (chatsArray.length < 16000) {
        chatsArray.addAll(allLikes);
        latestDoc.reference.update({'accomplishments': chatsArray});
      } else {
        likesCollection.add({'accomplishments': allLikes});
      }
    } else {
      likesCollection.add({'accomplishments': allLikes});
    }
  } catch (e) {
  }
}else if(Cname=='Professional'){
  final CollectionReference likesCollection = FirebaseFirestore.instance
      .collection('Professionals')
      .doc(widget.user.userId)
      .collection('moments');
  List<Map<String, dynamic>> allLikes = [];
  for (final item in selectedStreamerIds) {
    allLikes.add({
      'postId': item['postId'],
      'moment':item['accomplishment'],
      'timestamp': item['timestamp'],
    });
  }
  try {
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> chatsArray = latestDoc['moments'];
      if (chatsArray.length < 16000) {
        chatsArray.addAll(allLikes);
        latestDoc.reference.update({'moments': chatsArray});
      } else {
        likesCollection.add({'moments': allLikes});
      }
    } else {
      likesCollection.add({'moments': allLikes});
    }
  } catch (e) {
    print('Error sending message: $e');
  }

}else if(Cname=='Fan'){
  final CollectionReference likesCollection = FirebaseFirestore.instance
      .collection('Fans')
      .doc(widget.user.userId)
      .collection('moments');
  final Timestamp timestamp = Timestamp.now();
  List<Map<String, dynamic>> allLikes = [];
  for (final item in selectedStreamerIds) {
    allLikes.add({
      'postId': item['postId'],
      'moment':item['accomplishment'],
      'timestamp': item['timestamp'],
    });
  }
  try {
    final QuerySnapshot querySnapshot = await likesCollection.get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    if (documents.isNotEmpty) {
      final DocumentSnapshot latestDoc = documents.first;
      List<dynamic> chatsArray = latestDoc['moments'];
      if (chatsArray.length < 16000) {
        chatsArray.addAll(allLikes);
        latestDoc.reference.update({'moments': chatsArray});
      } else {
        likesCollection.add({'moments': allLikes});
      }
    } else {
      likesCollection.add({'moments': allLikes});
    }
  } catch (e) {
    print('Error sending message: $e');
  }
}
  }
  Set<Map<String,dynamic>> selectedStreamerIds={};
  @override
  Widget build(BuildContext context) {
    if(posts.isNotEmpty){
    return Column(
      children: [
        Align(
          alignment: Alignment.bottomRight,
          child: TextButton(onPressed: (){
            saveDataToFirestore1();
          }, child: Text(selectedStreamerIds.length>1?'Add posts':'Add post')),
        ),
        Column(
          children: posts.map<Widget>((post){
            return PostLayout2(post: post, dataList2: dataList2,data:(postId,accomplishment,remove){
              setState(() {
                if(remove){
              selectedStreamerIds.removeWhere((element) => element['postId']==postId);
                }else{
                selectedStreamerIds.add({
                  'postId':postId,
                  'accomplishments':accomplishment,
                  'timestamp':Timestamp.now(),
              });
                }
            });});
          }).toList(),
        ),
      ],
    );
  }else{
      return  const Center(child: Text('No posts'),);
    }}
}

class PostLayout2 extends StatefulWidget {
  Posts post;
  List<Map<String,dynamic>>dataList2;
  final void Function(String,String,bool) data ;
   PostLayout2({super.key,required this.post,required this.dataList2,required this.data,});

  @override
  State<PostLayout2> createState() => _PostLayout2State();
}

class _PostLayout2State extends State<PostLayout2> {
  @override
  void initState() {
    super.initState();
    _pageController1.addListener(_onPageChanged);
   data();
  }
void data()async{
  var size=await _getImageDimensions(widget.post.captionUrl.first['url']);
  setState(() {
    aspectRatio=size.width/size.height;
  });
}
  final PageController _pageController1 = PageController();
  final PageController _pageController2 = PageController();



  void _onPageChanged()async{
    if (_pageController1.page != _pageController2.page) {
     var size=await _getImageDimensions(widget.post.captionUrl[ind]['url']);
     setState(() {
       aspectRatio=size.width/size.height;
     });
      _pageController2.jumpToPage(_pageController1.page!.toInt());
    }
  }
  TextEditingController accomplishments = TextEditingController();
  @override
  void dispose() {
    _pageController1.removeListener(_onPageChanged);
    _pageController1.dispose();
    _pageController2.dispose();
    super.dispose();
  }
  int ind=0;
  double radius=23;
  String selectedTeamId='';
 double aspectRatio=1.0;
  List<String>hashes=["mine","Fans Arena","Sports","Ganze","Football","Basketball","NBAkenya","FiFA","UEFA","FKF","VolleyballKenya"];

  @override
  Widget build(BuildContext context) {
    return  Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: widget.dataList2.map<Widget>((item){
            if(item['postId']==widget.post.postid){
              accomplishments.text=item['accomplishment'];
              return  Padding(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child: TextFormField(
                    maxLines: 6,
                    minLines: 1,
                    controller: accomplishments,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10,top: 3),
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
                        labelText: "accomplishments"
                    )),
              );
            }else{
              return Padding(
                padding: const EdgeInsets.only(left: 10,right: 10),
                child: TextFormField(
                    maxLines: 6,
                    minLines: 1,
                    controller: accomplishments,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10,top: 3),
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
                        labelText: "accomplishments"
                    )),
              );
            }
          }).toList(),
        ),

        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.003333,
            child: const Divider(
              thickness: 2,
              color: Colors.white60,
            )),
        SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width*0.988,
          height:55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomAvatar(radius: radius, imageurl: widget.post.user.url),
              SizedBox(
                height:55,
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.85,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height * 0.0333,
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.85,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UsernameDO(
                              username:widget.post.user.name,
                              collectionName:widget.post.user.collectionName,
                              width: 160,
                              height: 38,
                              maxSize: 140,
                            ),
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Checkbox(
                                value: selectedTeamId==widget.post.postid||widget.dataList2.any((element) => element['postId']==widget.post.postid),
                                onChanged: (bool? value) {
                                    if (value == true) {
                                      widget.data(widget.post.postid,accomplishments.text,false);
                                      setState(() {
                                        selectedTeamId=widget.post.postid;
                                      });
                                    } else {
                                      widget.data(widget.post.postid,accomplishments.text,true);
                                      setState(() {
                                        selectedTeamId='';
                                      });
                                    }
                                },
                              ),//
                            ),]
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width * 0.87,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(widget.post.location,
                            style: const TextStyle(fontSize: 14,),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(widget.post.time,
                                style: const TextStyle(
                                  fontSize: 13,),),
                              SizedBox(width: 5,),
                              Text(widget.post.time1,
                                style: const TextStyle(
                                  fontSize: 13,),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.00333,
            child: const Divider(
              thickness: 2,
              color: Colors.white60,
            )),
        AspectRatio(
          aspectRatio:aspectRatio,
          child: Container(
            color: Colors.black,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.post.captionUrl.length,
                  controller: _pageController1,
                  itemBuilder: (context, index1) {
                    final captionUrl = widget.post.captionUrl[index1];
                    return CachedNetworkImage(
                      imageUrl: captionUrl['url']!,
                      fit: BoxFit.cover,
                      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(Icons.error, color: Colors.white, size: 40),
                      ),
                    );
                  },
                  onPageChanged: (int index) {
                    setState(() {
                      ind = index;
                    });
                  },
                ),
                widget.post.captionUrl.length>1? Align(
                  alignment: Alignment.topRight,
                  child:Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Container(
                          constraints: const BoxConstraints(
                            maxHeight: 20,
                            maxWidth: 50,
                            minHeight: 0,
                            minWidth: 0,
                          ),
                          decoration: const BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.black,
                          ),
                          child: Center(
                            child: Text(
                              '${ind + 1}/${widget.post.captionUrl.length}',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ):const SizedBox(height: 0,width: 0,)
              ],
            ),
          ),
        ),
        LikeArea(post: widget.post,),
        Padding(
          padding: const EdgeInsets.only(left: 5,top:5),
          child: widget.post.captionUrl.isNotEmpty
              ?   SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Wrap(
              children: [
                Wrap(
                  children: hashes.map((h)=> Text('#$h', style: const TextStyle(color: Colors.blue)),
                  ).toList(),
                ),
                Readmore1(text:"${widget.post.captionUrl[ind]['caption']}")
              ],
            ),
          )
              : const SizedBox.shrink(),
        ),
        SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height * 0.01111,
            child: const Divider(
              thickness: 2,
              color: Colors.white60,
            )),
      ],
    );
  }
  Future<Size> _getImageDimensions(String imageUrl) async {
    final Completer<Size> completer = Completer();
    final Image image = Image.network(imageUrl);

    image.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );

    return completer.future;
  }
}
