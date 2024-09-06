import 'package:fans_arena/professionals/screens/genrescreen.dart';
import 'package:flutter/cupertino.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_image_compress/flutter_image_compress.dart';// Add this import
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../clubs/data/lineup.dart';
import '../../clubs/screens/checklist.dart';
import '../../clubs/screens/clubteamtable.dart';
import '../../fans/screens/homescreen.dart';
import 'package:printing/printing.dart';


class EditprofileL extends StatefulWidget {
  String leagueId;
 EditprofileL({super.key, required this.leagueId});

  @override
  State<EditprofileL> createState() => _EditprofileLState();
}

class _EditprofileLState extends State<EditprofileL> {
  TextEditingController leaguename = TextEditingController();
  TextEditingController genre = TextEditingController();
  TextEditingController location = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageurl = '';
  String username = '';
String scorename1='goals';
String scorename2='points';


  @override
  void initState() {
    super.initState();
    _startTime=DateTime.now();
    retrieveUsername();
    _checkleague();
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

bool isloading=true;
  void retrieveUsername() async {
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Leagues')
          .doc(widget.leagueId)
          .get();

      if (documentSnapshot.exists) {
        var data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          imageurl = data['profileimage'];
         leaguename.text = data['leaguename'];
          genre.text = data['genre'];
          location.text=data['location'];
          _selectedGender=data['accountType'];
          isloading=false;
        });
      } else {
        print('No matching document found.');
      }
    } catch (e) {
      print('Error retrieving username: $e');
    }
  }

  void createLeague() async {
    final leaguesCollection = FirebaseFirestore.instance.collection(
        'Leagues');
    try {
      String leagueId = leaguesCollection
          .doc()
          .id;
      Timestamp createdAt = Timestamp.now();
      leaguesCollection
          .doc(leagueId)
          .set({
        'location': location.text,
        'authorId': FirebaseAuth.instance.currentUser!.uid,
        'createdAt': createdAt,
        'leagueId': leagueId,
        'genre':genre.text,
        'accountType':_selectedGender,
        'profileimage': imageurl,
        'leaguename':leaguename.text,
        'searchname':leaguename.text.toLowerCase()
      })
          .then((_) {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                content: Text('League Created'),
              );
            });
        print('Match data added to Firestore.');
      })
          .catchError((error) {
        print('Error adding post data to Firestore: $error');
      });
    } catch (e) {
      print('Error retrieving user data: $e');
    }
  }
  Future<String> uploadImageToStorage(BuildContext context) async {
    String image=await pickAndCompressImage(imageurl);
    File imageFile = File(image);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('League')
          .child('images')
          .child('$fileName.jpg');

      final uploadTask = ref.putFile(imageFile);

     dialog();
      final snapshot = await uploadTask.whenComplete(() {});
      // Close the progress dialog
   back();
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
  void back(){
    Navigator.of(context, rootNavigator: true).pop();
  }
  void uploadAndSaveImage() async {
    if (imageurl.isNotEmpty) {
      File imageFile = File(imageurl);

      if (imageFile.existsSync()) {
        String? imageUrl = await uploadImageToStorage(context);

        setState(() {
          imageurl = imageUrl;
        });
        createLeague();
            }
    }else{
      createLeague();
    }
  }
  void uploadAndSaveImage1() async {
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
    }else{
      saveDataToFirestore();
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
          .collection('Leagues')
          .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var documentSnapshot = querySnapshot.docs[0];
        var oldData = documentSnapshot.data() as Map<String, dynamic>;

        Map<String, dynamic> newData = {};

        if (leaguename.text.isNotEmpty && leaguename.text != oldData['leaguename']) {
          newData['leaguename'] = leaguename.text;
        }
        if (leaguename.text.isNotEmpty && leaguename.text != oldData['searchname']) {
          newData['searchname'] = leaguename.text.toLowerCase();
        }
        if (_selectedDate.toString().isNotEmpty && _selectedDate != oldData['fromDate']) {
          newData['fromDate'] = _selectedDate;
        }
        if (_selectedDate1.toString().isNotEmpty && _selectedDate1 != oldData['toDate']) {
          newData['toDate'] = _selectedDate1;
        }
        if (location.text.isNotEmpty && location.text != oldData['location']) {
          newData['location'] = location.text;
        }
        if (imageurl != oldData['profileimage']) {
          newData['profileimage'] = imageurl;
        }
        if (_selectedGender != oldData['accountType']) {
          newData['accountType'] = _selectedGender;
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
                  content: Text('League updated successfully'),
                );
              });
        } else {
          await Future.delayed(const Duration(milliseconds: 2500));
          Navigator.of(context,rootNavigator: true).pop();
          await Future.delayed(const Duration(milliseconds: 1000));
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text('Failed to update League'),
                  content: Text('No changes to update'),
                );
              });
        }
      } else {

      }
    } catch (e) {
      print('Error saving data: $e');
    }
  }
  bool update=false;
  void _checkleague() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Leagues')
          .where('authorId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      setState(() {
        update = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking if user liked post: $e');
    }
  }

  setString(genree){
    setState(() {
      print(genre.text);
      genre.text=genree;
    });
  }
  bool _showCloseIcon = false;
  bool _showCloseIcon1 = false;
  late DateTime _startTime;
  String? _selectedGender;
  @override
  void dispose(){
    Engagement().engagement('EditProfileLeagues',_startTime,widget.leagueId);
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
          title: const Text('League Profile', style: TextStyle(color: Colors.black),),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

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
                        controller: leaguename,
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
                                  leaguename.clear();
                                  _showCloseIcon = false;
                                });
                              },
                            ) : null,
                            hintText: 'League name',
                        )),
                    const SizedBox(height: 20,),
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
                                  genre.text = genr; // Store the commentId
                                });});
                            },
                          );
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
                            hintText: 'Genre',
                        )),
                    const SizedBox(height: 20,),
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'Account',
                        hintText: 'Select account',
                      ),
                      readOnly: true,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              title: const Text('Select account'),
                              children: <Widget>[
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      _selectedGender = 'Clubs';
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Clubs'),
                                ),
                                SimpleDialogOption(
                                  onPressed: () {
                                    setState(() {
                                      _selectedGender = 'Professionals';
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Professionals'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      validator: (value) =>
                      value != null && value.isNotEmpty ? null : "required",
                      controller: TextEditingController(text: _selectedGender ?? ''),
                    ),
                    const SizedBox(height: 20,),
                    TextFormField(
                        controller: location,
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
                            suffixIcon: _showCloseIcon ? const CircularProgressIndicator(): IconButton(
                              icon: const Icon(Icons.search,color: Colors.black,),
                              onPressed: () {
                                setState(() {
                                  location.clear();
                                  _showCloseIcon1 = true;
                                });
                              },
                            ),
                            hintText: 'Location',

                        )),
                    const SizedBox(height: 20,),
                    SizedBox(
                      height: 30,
                      child:update?OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 30),
                          side: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        onPressed: uploadAndSaveImage1
                        ,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            "Update",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      )  : OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 30),
                          side: const BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        onPressed: uploadAndSaveImage
                        ,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 1),
                          child: Text(
                            "create",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
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

}

class EditL extends StatefulWidget {
  const EditL({super.key});

  @override
  State<EditL> createState() => _EditLState();
}

class _EditLState extends State<EditL> {
  List<TextEditingController>dcolumns=[];
 int items=1;
 TextEditingController itemL=TextEditingController();
  @override
  void initState() {
    super.initState();
    generateList();
  }
  void generateList(){
    setState(() {
    dcolumns = List.generate(
      items, (index) => TextEditingController(),
    );

    });
  }
  List<String>itemss=['Rank'];
  String item='';
  TextEditingController leaguename = TextEditingController();
  TextEditingController genre = TextEditingController();
  TextEditingController location = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _selectedDate1;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String imageurl = '';
  String username = '';
  String scorename1='goals';
  String scorename2='points';

  setString(genree){
    setState(() {
      print(genre.text);
      genre.text=genree;
    });
  }
  bool isnetworkPath(String input) {
    return input.startsWith('https');
  }
  bool _showCloseIcon = false;
  bool _showCloseIcon1 = false;
  late DateTime _startTime;
  String? accountType;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leagues",style:TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20,),
              SizedBox(
                height: 140,
                width: 120,
                child: Stack(
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
                    Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
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
                            }, icon: const Icon(Icons.edit)))
                  ],
                ),
              ),
              SizedBox(
                width: 250,
                child: TextFormField(
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Account selection',
                    hintText: 'Select Account',
                  ),
                  readOnly: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return SimpleDialog(
                          title: const Text('Select Account'),
                          children: <Widget>[
                            SimpleDialogOption(
                              onPressed: () {
                                setState(() {
                                  accountType = 'Clubs';
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Clubs'),
                            ),
                            SimpleDialogOption(
                              onPressed: () {
                                setState(() {
                                  accountType = 'Professionals';
                                });
                                Navigator.pop(context);
                              },
                              child: const Text('Professionals'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  validator: (value) =>
                  value != null && value.isNotEmpty ? null : "required",
                  controller: TextEditingController(text: accountType ?? ''),
                ),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 250,
                child: TextFormField(
                    controller: leaguename,
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
                            leaguename.clear();
                            _showCloseIcon = false;
                          });
                        },
                      ) : null,
                      hintText: 'League name',
                    )),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 250,
                child: TextFormField(
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
                      hintText: 'Genre',
                    )),
              ),
              const SizedBox(height: 20,),
              SizedBox(
                width: 250,
                child: TextFormField(
                    controller: location,
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
                      suffixIcon: _showCloseIcon ? const CircularProgressIndicator(): IconButton(
                        icon: const Icon(Icons.search,color: Colors.black,),
                        onPressed: () {
                          setState(() {
                            location.clear();
                            _showCloseIcon1 = true;
                          });
                        },
                      ),
                      hintText: 'Location',

                    )),
              ),
              const SizedBox(height: 20),
              const Text("data table columns"),
              Text(item),
              SizedBox(
                width: 250,
                child: TextFormField(
                  controller:itemL,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(left: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'Number of columns',
                  ),),
              ),
              const SizedBox(height: 10),
              Container(
                height: 35,
                width: MediaQuery.of(context).size.width*0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  shape: BoxShape.rectangle,
                ),
                child: FloatingActionButton(
                  foregroundColor:Colors.blue,
                  backgroundColor:Colors.blue,
                  onPressed: () {
                    setState(() {
                      items=int.tryParse(itemL.text)??0;
                      generateList();
                    });
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'set length',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Wrap(children: dcolumns.map((d){
                int index=dcolumns.indexOf(d);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 175,
                    child: TextFormField(
                      controller:d,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(left: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'Column name',
                        suffix: Text("   ${index+1}   ")
                      )),
                  ),
                );}).toList(),),
              const SizedBox(height: 20),
              Container(
                height: 35,
                width: MediaQuery.of(context).size.width*0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  shape: BoxShape.rectangle,
                ),
                child: FloatingActionButton(
                  foregroundColor:Colors.blue,
                  backgroundColor:Colors.blue,
                  onPressed: () {
                    if(accountType=="Professionals"){
                      itemss=['Rank','Professionals'];
                      for(var t in dcolumns){
                        itemss.add(t.text);
                      }
                    }else{
                      itemss=['Rank','Clubs'];
                      for(var t in dcolumns){
                        itemss.add(t.text);
                      }
                    }
                  setState(() {
                    item =itemss.join(',');
                  });
                  },
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0), // Adjust the value to control the button's oval shape
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'set',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}


class EditableTable extends StatefulWidget {
  const EditableTable({super.key});

  @override
  State<EditableTable> createState() => _EditableTableState();
}

class _EditableTableState extends State<EditableTable> {
  List<Map<String, dynamic>> tableColumns = [
    {'fn': 'Rank'},
    {'fn': 'Club'},
  ];

  List<Map<String, dynamic>> dRows = [];

  TextEditingController tc = TextEditingController();
  TextEditingController vc = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController club = TextEditingController();
  String selectedColumn = '';
  String Id = '';

  void _addNewColumn() {
    setState(() {
      String newColumnName = tc.text;
      if (newColumnName.isNotEmpty) {
        tableColumns.add({'fn': newColumnName});
        for (var d in dRows) {
          d[newColumnName] = '0';
        }
      }
    });
  }

  void _editColumnH() {
    setState(() {
      String newColumnName = ec.text;
      if (newColumnName.isNotEmpty && selectedColumn.isNotEmpty) {
        if (tableColumns.any((element) => element['fn'] != newColumnName)) {
          for (var column in tableColumns) {
            if (column['fn'] == selectedColumn) {
              column['fn'] = newColumnName;
            }
          }
          for (var row in dRows) {
            row[newColumnName] = row.remove(selectedColumn);
          }
          selectedColumn = newColumnName;
        }
      }
    });
  }

  void _editColumnV() {
    setState(() {
      String newValue = vc.text;
      if (newValue.isNotEmpty && selectedColumn.isNotEmpty) {
        var row = dRows.firstWhere((element) => element[tableColumns[1]['fn']] == Id);
        row[selectedColumn] = newValue;
      }
    });
  }

  void _addRow() {
    setState(() {
      if (club.text.isNotEmpty) {
        Map<String, dynamic> data = {};
        for (var d in tableColumns) {
          int i = tableColumns.indexOf(d);
          if (i == 1) {
            data[d['fn']] = club.text;
          } else if (i > 1) {
            data[d['fn']] = '0';
          } else {
            data[d['fn']] = '';
          }
        }
        dRows.add(data);
      }
    });
  }
  bool ascending=true;

  void _removeColumn() {
    setState(() {
      if (selectedColumn.isNotEmpty && selectedColumn != tableColumns[0]['fn'] && selectedColumn != tableColumns[1]['fn']) {
        tableColumns.removeWhere((element) => element['fn'] == selectedColumn);
        for (var row in dRows) {
          row.remove(selectedColumn);
        }
        selectedColumn = '';
      }
    });
  }
void _sort(){
  if(ascending){
    dRows.sort((a,b){
      int adate = int.tryParse(a[selectedColumn])??0;
      int bdate = int.tryParse(b[selectedColumn])??0;
      return adate.compareTo(bdate);
    });}else{
    dRows.sort((a,b){
      int adate = int.tryParse(a[selectedColumn])??0;
      int bdate = int.tryParse(b[selectedColumn])??0;
      return bdate.compareTo(adate);
    });
  }
}

void _removeRow(){
setState(() {
  dRows.removeWhere((element) => element[selectedColumn]==Id);
});
}
  List<List<String>> data = [];

  Future<void> _add()async{
    List<List<String>> data1 = [];
    List<String> Cheadings = [];
    List<List<String>> rows = [];
    for (var cH in tableColumns) {
      String ch = cH['fn'];
      Cheadings.add(ch);
    }
    for (var rw in dRows) {
      List<String> row = [];
      int rnk=dRows.indexOf(rw);
      for (var cH in tableColumns) {
        int i=tableColumns.indexOf(cH);
        if(i==0){
          String ch = "${rnk+1}";
          row.add(ch);
        }else{
          String ch = rw[cH['fn']];
          row.add(ch);
        }
      }
      rows.add(row);
    }
    data1.add(Cheadings);
    data1.addAll(rows);
    setState(() {
      data=data1;
    });
  }

String leaguename='CHAPUNGU LEAGUE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("League"),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: ()async{
              await _add();
              generateAndPrintPDF();
            },
          ),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text(
              'Edit Table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 200,
              margin: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 1.5, color: Colors.grey[400]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                scrollPadding: EdgeInsets.zero,
                                controller: tc,
                                validator: (value){
                                  if(value!.length>10){
                                    return "Max length exceeded";
                                  }else{
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                  const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelText: 'Column name',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                ),
                                child: FloatingActionButton(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.blue,
                                  elevation: 1,
                                  onPressed: _addNewColumn,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Add cname',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                scrollPadding: EdgeInsets.zero,
                                controller: ec,
                                validator: (value){
                                  if(value!.length>10){
                                    return "Max length exceeded";
                                  }else{
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                  const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelText: 'Column name',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                ),
                                child: FloatingActionButton(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.blue,
                                  elevation: 1,
                                  onPressed: _editColumnH,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Edit cname',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        selectedColumn.isEmpty||tableColumns[0]['fn']==selectedColumn||tableColumns[1]['fn']==selectedColumn?const SizedBox.shrink():Column(
                          children: [
                         IconButton(onPressed: (){
                              setState(() {
                                ascending=!ascending;
                              });
                              _sort();
                            }, icon:ascending?const Icon(Icons.arrow_downward_outlined,color: Colors.black,size: 25,):const Icon(Icons.arrow_upward_outlined,color: Colors.black,size: 25,)),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: IconButton(onPressed: _removeColumn, icon: const Icon(Icons.delete_forever)),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                scrollPadding: EdgeInsets.zero,
                                controller: vc,
                                validator: (value){
                                  if(value!.length>10){
                                    return "Max length exceeded";
                                  }else{
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  contentPadding:
                                  const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  labelText: 'Cell value',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.25,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                ),
                                child: FloatingActionButton(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.blue,
                                  elevation: 1,
                                  onPressed: _editColumnV,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Edit rvalue',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                     Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        "${tableColumns[1]['fn']} Actions",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            scrollPadding: EdgeInsets.zero,
                            controller: club,
                            validator: (value){
                              if(value!.length>10){
                                return "Max length exceeded";
                              }else{
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding:
                              const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              labelText: '${tableColumns[1]['fn']} name',
                            ),
                          ),
                        ),
                        Container(
                          height: 35,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            shape: BoxShape.rectangle,
                          ),
                          child: FloatingActionButton(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.blue,
                            elevation: 1,
                            onPressed: _addRow,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Add ${tableColumns[1]['fn']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 35,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            shape: BoxShape.rectangle,
                          ),
                          child: FloatingActionButton(
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.blue,
                            elevation: 1,
                            onPressed: _removeRow,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            child:  Center(
                              child: Text(
                                'remove ${tableColumns[1]['fn']}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  const Text(
                    "Table",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                        columnSpacing: MediaQuery.of(context).size.width*0.08,
                      columns: tableColumns
                          .map((d) => DataColumn(
                          label: InkWell(
                            onTap: () {
                              setState(() {
                                ec.text = d['fn'];
                                selectedColumn = d['fn'];
                                vc.text="";
                              });
                            },
                            child: SizedBox(
                              height: 30,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(d['fn']),
                              ),
                            ),
                          )))
                          .toList(),
                      rows: dRows.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> d = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('${index + 1}')),
                          ...tableColumns
                              .where(
                                  (col) => col['fn'] != tableColumns[0]['fn'])
                              .map((col) {
                            String columnName = col['fn'];
                            int i = tableColumns.indexOf(col);
                            return DataCell(
                              i == 1
                                  ? InkWell(
                                onTap: () {
                                  setState(() {
                                    vc.text = d[columnName];
                                    ec.text = columnName;
                                    club.text=d[columnName];
                                    selectedColumn = columnName;
                                    Id = d[tableColumns[1]['fn']];
                                  });
                                },
                                    child: SizedBox(
                                      height: 30,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(d[columnName] ?? ''),
                                      ),
                                    ),
                                  )
                                  : InkWell(
                                onTap: () {
                                  setState(() {
                                    vc.text = d[columnName];
                                    ec.text = columnName;
                                    selectedColumn = columnName;
                                    Id = d[tableColumns[1]['fn']];
                                  });
                                },
                                child: SizedBox(
                                    height: 30,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Text(d[columnName] ?? ''),
                                    )),
                              ),
                            );
                          }),
                        ]);
                      }).toList()
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<Uint8List> generatePDF() async {
    final ByteData imageData = await rootBundle.load('assets/images/applogo.jpg');
    final Uint8List imageBytes = imageData.buffer.asUint8List();
    final image = pw.MemoryImage(imageBytes);
    final pdf = pw.Document();
    final tableHeaders = data.first;
    final tableData = data.sublist(1);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Image(
                image,
                height: 45,
                width: 45,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                leaguename,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableData,
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }


  Future<Uint8List> generatePDF2(List<List<String>> data) async {
    final pdf = pw.Document();
    final tableHeaders = data.first;
    final tableData = data.sublist(1);

    List<pw.TableRow> tableRows = [];

    // Add headers
    tableRows.add(
      pw.TableRow(
        children: tableHeaders.map((header) {
          return pw.Text(
            header,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          );
        }).toList(),
      ),
    );

    for (var row in tableData) {
      // Assuming the image URL is in the second column
      final imageUrl = row[1];
      final response = await http.get(Uri.parse(imageUrl));
      final imageBytes = response.bodyBytes;
      final image = pw.MemoryImage(imageBytes);

      // Create a row with the combined image and text
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Text(row[0]), // First column
            pw.Row(
              children: [
                pw.Image(image, height: 45, width: 45),
                pw.SizedBox(width: 10),
                pw.Text(row[2]), // Assuming the name is in the third column
              ],
            ),
            ...row.skip(3).map((cell) => pw.Text(cell)).toList(), // Other columns
          ],
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                leaguename,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: tableRows,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generatePDF1(List<List<String>> data) async {
    final pdf = pw.Document();
    final tableHeaders = data.first;
    final tableData = data.sublist(1);

    List<List<dynamic>> tableWithImages = [];

    for (var row in tableData) {
      // Assuming the image URL is in the second column
      final imageUrl = row[1];
      final response = await http.get(Uri.parse(imageUrl));
      final imageBytes = response.bodyBytes;
      final image = pw.MemoryImage(imageBytes);

      // Replace the URL with a Row containing the image and text
      final combinedWidget = pw.Row(
        children: [
          pw.Image(image, height: 45, width: 45),
          pw.SizedBox(width: 10),
          pw.Text(row[2]), // Assuming the name is in the third column
        ],
      );

      // Create a new row with combinedWidget
      List<dynamic> newRow = List<dynamic>.from(row);
      newRow[1] = combinedWidget; // Replace the image URL with combinedWidget

      tableWithImages.add(newRow);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    leaguename,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableWithImages,
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
  void generateAndPrintPDF() async {
    final pdfBytes = await generatePDF();
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
    );
  }
}


class EditableTable1 extends StatefulWidget {
  String leagueId;
  String year;
  String leaguename;
  String image;
  EditableTable1({super.key,
    required this.leagueId,
    required this.year,
    required this.leaguename,
    required this.image});

  @override
  State<EditableTable1> createState() => _EditableTable1State();
}

class _EditableTable1State extends State<EditableTable1> {

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() {
          mdown=false;
        });
      }else{
        setState(() {
          mdown=true;
        });
      }
    });
    getFnData();
    getClubData();
  }
  void getFnData()async{
    DocumentSnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .get();
   var document= snapshot.data() as Map<String,dynamic>;
    List<Map<String, dynamic>> allLikes = [];
      final List<dynamic> likesArray = document['leagueTable'];
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    setState(() {
      tableColumns=allLikes;
    });
  }
  Set<String>docIds={};
  void getClubData()async{
    QuerySnapshot snapshot= await FirebaseFirestore.instance
        .collection('Leagues')
        .doc(widget.leagueId)
        .collection('year')
        .doc(widget.year)
        .collection('clubs')
        .get();
    final List<QueryDocumentSnapshot> likeDocuments = snapshot.docs;
    List<Map<String, dynamic>> allLikes = [];
    for (final document in likeDocuments) {
      docIds.add(document.id);
      final List<dynamic> likesArray = document['clubs'];
      allLikes.addAll(likesArray.cast<Map<String, dynamic>>());
    }
    setState(() {
      dRows=allLikes;
      isLoading=false;
    });
  }

  List<Map<String, dynamic>> tableColumns = [
    {'fn':'Rank'},
    {'fn':'Club'},
  ];
  List<Map<String, dynamic>> dRows = [];

  TextEditingController tc = TextEditingController();
  TextEditingController vc = TextEditingController();
  TextEditingController ec = TextEditingController();
  TextEditingController club = TextEditingController();
  String selectedColumn = '';
  String id = '';

  void _addNewColumn() {
    setState(() {
      String newColumnName = tc.text;
      if (newColumnName.isNotEmpty) {
        tableColumns.add({'fn': newColumnName});
        for (var d in dRows) {
          d[newColumnName] = '0';
        }
      }
    });
  }
bool isLoading=true;
  void _editColumnH() {
    setState(() {
      String newColumnName = ec.text;
      if (newColumnName.isNotEmpty && selectedColumn.isNotEmpty) {
        if (tableColumns.any((element) => element['fn'] != newColumnName)) {
          for (var column in tableColumns) {
            if (column['fn'] == selectedColumn) {
              column['fn'] = newColumnName;
            }
          }
          for (var row in dRows) {
            row[newColumnName] = row.remove(selectedColumn);
          }
          selectedColumn = newColumnName;
        }
      }
    });
  }

  void _editColumnV() {
    setState(() {
      String newValue = vc.text;
      if (newValue.isNotEmpty && selectedColumn.isNotEmpty) {
        var row = dRows.firstWhere((element) => element[tableColumns[1]['fn']] == id);
        if(selectedColumn!=tableColumns[1]['fn']) {
          row[selectedColumn] = newValue;
        }
      }
    });
  }

  void _addRow() {
    setState(() {
      if (club.text.isNotEmpty) {
        Map<String, dynamic> data = {};
        for (var d in tableColumns) {
          int i = tableColumns.indexOf(d);
          if (i == 1) {
            data[d['fn']] = club.text;
          } else if (i > 1) {
            data[d['fn']] = '0';
          } else {
            data[d['fn']] = '';
          }
        }
        dRows.add(data);
      }
    });
  }
  bool ascending=true;

  void _removeColumn() {
    setState(() {
      if (selectedColumn.isNotEmpty && selectedColumn != tableColumns[0]['fn'] && selectedColumn != tableColumns[1]['fn']) {
        tableColumns.removeWhere((element) => element['fn'] == selectedColumn);
        for (var row in dRows) {
          row.remove(selectedColumn);
        }
        selectedColumn = '';
      }
    });
  }

  Future<void>  updateTable() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 80,
          child: Column(
            children: [
              CircularProgressIndicator(),
              Text('Updating table...')
            ],
          ),
        ),
      ),
    );
    FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('Leagues').doc(widget.leagueId).collection(
          'year').doc(widget.year).update({
        'leagueTable': tableColumns,
      });
      for(var docid in docIds){
    await firestore.collection('Leagues').doc(widget.leagueId).collection(
        'year').doc(widget.year).collection("clubs").doc(docid).update({
      'clubs': dRows,
    });
      }
    Navigator.of(context,rootNavigator: true).pop();
    await Future.delayed(Duration(seconds: 1));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 80,
          child: Text('Table Updated'),
        ),
      ),
    );
  }
  void _sort(){
    if(ascending){
      dRows.sort((a,b){
        int adate = int.tryParse(a[selectedColumn])??0;
        int bdate = int.tryParse(b[selectedColumn])??0;
        return adate.compareTo(bdate);
      });}else{
      dRows.sort((a,b){
        int adate = int.tryParse(a[selectedColumn])??0;
        int bdate = int.tryParse(b[selectedColumn])??0;
        return bdate.compareTo(adate);
      });
    }
  }

  void _removeRow(){
    setState(() {
      dRows.removeWhere((element) => element[selectedColumn]==id);
    });
  }
  final formKey=GlobalKey<FormState>();
  ScrollController controller=ScrollController();
  bool mdown=true;
  List<List<String>> data = [];

  Future<void> _add()async{
    showDialog(
      barrierDismissible: false,
        context: context, builder: (context)=>AlertDialog(
      content: SizedBox(
        height: 80,
        child: Column(
          children: [
            CircularProgressIndicator(),
            Text('Generating PDF..')
          ],
        ),
      ),
    ));
    try {
      List<List<String>> data1 = [];
      List<String> Cheadings = [];
      List<List<String>> rows = [];
      for (var cH in tableColumns) {
        String ch = cH['fn'];
        Cheadings.add(ch);
      }
      for (var rw in dRows) {
        List<String> row = [];
        int rnk = dRows.indexOf(rw);
        for (var cH in tableColumns) {
          int i = tableColumns.indexOf(cH);
          if (i == 0) {
            String ch = "${rnk + 1}";
            row.add(ch);
          } else if (i == 1) {
            UsersData? appUsage = await DatabaseHelper2Users.instance.getUser(
                rw[cH['fn']]);
            if (appUsage != null) {
              //row.add(appUsage.user.url);
              row.add(appUsage.user.name);
            }
          } else {
            String ch = rw[cH['fn']];
            row.add(ch);
          }
        }
        rows.add(row);
      }
      data1.add(Cheadings);
      data1.addAll(rows);
      setState(() {
        data = data1;
      });
    }catch(e){
      showDialog(context: context, builder: (context)=>AlertDialog(
        content: Text(e.toString()),
      ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("League"),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 80,
                child: IconButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>CheckList(tableColumns: tableColumns, dRow:dRows, navf: 'League',)));
                }, icon: const Icon(Icons.format_list_bulleted,color: Colors.black,),
                ),
              ),
            ),
              IconButton(
                icon: Icon(Icons.print),
                onPressed: ()async{
                  await _add();
                  generateAndPrintPDF();
                },
              ),
          ],
        ),
        body: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: NestedScrollView(
              controller: controller,
              headerSliverBuilder: (context, _) {
                return [
            SliverToBoxAdapter(
              child: Column(
              children: [
                const Text(
                  'Edit Table',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1.5, color: Colors.grey[400]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      controller: tc,
                                      validator: (value){
                                        if(value!.length>10){
                                          return "Max length exceeded";
                                        }else{
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        labelText: 'Column name',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: 35,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: FloatingActionButton(
                                        foregroundColor: Colors.blue,
                                        backgroundColor: Colors.blue,
                                        elevation: 1,
                                        onPressed: _addNewColumn,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Add column',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      controller: ec,
                                      validator: (value){
                                        if(value!.length>10){
                                          return "Max length exceeded";
                                        }else{
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        labelText: 'Column name',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: 35,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: FloatingActionButton(
                                        foregroundColor: Colors.blue,
                                        backgroundColor: Colors.blue,
                                        elevation: 1,
                                        onPressed: _editColumnH,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Edit column',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              selectedColumn.isEmpty||tableColumns[0]['fn']==selectedColumn||tableColumns[1]['fn']==selectedColumn?const SizedBox.shrink():Column(
                                children: [
                                  IconButton(onPressed: (){
                                    setState(() {
                                      ascending=!ascending;
                                    });
                                    _sort();
                                  }, icon:ascending?const Icon(Icons.arrow_downward_outlined,color: Colors.black,size: 25,):const Icon(Icons.arrow_upward_outlined,color: Colors.black,size: 25,)),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 5),
                                    child: IconButton(onPressed: _removeColumn, icon: const Icon(Icons.delete_forever)),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      controller: vc,
                                      validator: (value){
                                        if(value!.length>10){
                                          return "Max length exceeded";
                                        }else{
                                          return null;
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.only(left: 5, bottom: 1, top: 1),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        labelText: 'Cell value',
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      height: 35,
                                      width: MediaQuery.of(context).size.width * 0.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        shape: BoxShape.rectangle,
                                      ),
                                      child: FloatingActionButton(
                                        foregroundColor: Colors.blue,
                                        backgroundColor: Colors.blue,
                                        elevation: 1,
                                        onPressed: _editColumnV,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(10.0),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Edit cell',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Text(
                              "${tableColumns[1]['fn']} Actions",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                ),
                                child: FloatingActionButton(
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.blue,
                                  elevation: 1,
                                  onPressed:(){
                                    if(formKey.currentState!.validate()){
                                      updateTable();
                                    }},
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child:  const Center(
                                    child: Text(
                                      'Update Table',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              CustomNameAvatar(userId:id,radius: 16, style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ), maxsize: 70,cloadingname: '${tableColumns[1]['fn']}',),
                              Container(
                                height: 35,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  shape: BoxShape.rectangle,
                                ),
                                child: FloatingActionButton(
                                  elevation: 1,
                                  foregroundColor: Colors.blue,
                                  backgroundColor: Colors.blue,
                                  onPressed: _removeRow,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  child:  Center(
                                    child: Text(
                                      'remove ${tableColumns[1]['fn']}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),];},
                body: Column(
                  children: [
                    const Text(
                      "Table",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  isLoading||dRows.isEmpty? const Center(child: CircularProgressIndicator()):SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          columnSpacing: MediaQuery.of(context).size.width*0.03,
                          columns: tableColumns
                              .map((d) => DataColumn(
                              label: InkWell(
                                onTap: () {
                                  setState(() {
                                    ec.text = d['fn'];
                                    selectedColumn = d['fn'];
                                    vc.text="";
                                  });
                                },
                                child: SizedBox(
                                  height: 30,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(d['fn']),
                                  ),
                                ),
                              )))
                              .toList(),
                          rows: dRows.asMap().entries.map((entry) {
                            int index = entry.key;
                            Map<String, dynamic> d = entry.value;
                            return DataRow(cells: [
                              DataCell(Text('${index + 1}')),
                              ...tableColumns
                                  .where(
                                      (col) => col['fn'] != tableColumns[0]['fn'])
                                  .map((col) {
                                String columnName = col['fn'];
                                int i = tableColumns.indexOf(col);
                                return DataCell(
                                  i == 1
                                      ? InkWell(
                                    onTap: () {
                                      setState(() {
                                        ec.text = columnName;
                                        club.text=d[columnName];
                                        selectedColumn = columnName;
                                        id = d[tableColumns[1]['fn']];
                                      });
                                    },
                                    child: CustomNameAvatar(userId:d[columnName] ?? '',radius: 16, style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.normal,
                                    ), maxsize: 70,),
                                  )
                                      : InkWell(
                                    onTap: () {
                                      setState(() {
                                        vc.text = d[columnName];
                                        ec.text = columnName;
                                        selectedColumn = columnName;
                                        id = d[tableColumns[1]['fn']];
                                      });
                                    },
                                    child: SizedBox(
                                        height: 30,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: Text(d[columnName] ?? ''),
                                        )),
                                  ),
                                );
                              }),
                            ]);
                          }).toList()
                      ),
                    ),
                    const SizedBox(height: 120,)
                  ],
                ),
              ),
            ),
            Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                  child: IconButton(onPressed: (){
                    if(mdown){
                      controller.jumpTo(controller.position.maxScrollExtent);
                      setState(() {
                        mdown=false;
                      });
                    }else{
                      controller.jumpTo(0.0);
                      setState(() {
                        mdown=true;
                      });
                    }
                  },icon:Icon(mdown? Icons.arrow_downward_outlined:Icons.arrow_upward_outlined,color: Colors.black,),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Future<Uint8List> generatePDF() async {
    final pdf = pw.Document();
    final tableHeaders = data.first;
    final tableData = data.sublist(1);
    pw.MemoryImage? limage;
    if (widget.image.isNotEmpty) {
      final response = await http.get(Uri.parse(widget.image));
      final imageBytes = response.bodyBytes;
      limage = pw.MemoryImage(imageBytes);
    }
    List<pw.TableRow> tableRows = [];
    tableRows.add(
      pw.TableRow(
        children: tableHeaders.map((header) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text(
              header,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
    for (var row in tableData) {
      // final imageUrl = row[1];
      //  pw.MemoryImage? image;
      //  if (imageUrl.isNotEmpty) {
      //    final response = await http.get(Uri.parse(imageUrl));
      //   final imageBytes = response.bodyBytes;
      //  image = pw.MemoryImage(imageBytes);
      //}
      tableRows.add(
        pw.TableRow(children: row.map((cell) {
          return pw.Text(cell);
        }).toList(),
        ),
      );
    }
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text("LEAGUE TABLE", style: pw.TextStyle(
                fontSize: 30,
                fontWeight: pw.FontWeight.bold,
              ),),
              pw.SizedBox(height: 20),
              limage != null?
                pw.ClipRRect(
                  horizontalRadius: 35,
                  verticalRadius: 35,
                  child: pw.Image(
                      fit:pw.BoxFit.fill,
                      height: 70,
                      width: 70,
                      limage),
                ):pw.SizedBox.shrink(),
              pw.SizedBox(height: 10),
              pw.Text(
                widget.leaguename,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(),
                children: tableRows,
              ),
            ],
          );
        },
      ),
    );
    return pdf.save();
  }
  void generateAndPrintPDF() async {
    try {
      final pdfBytes = await generatePDF();
      Navigator.of(context,rootNavigator: true).pop();
      await Future.delayed(Duration(seconds: 1));
      showDialog(barrierDismissible: false,context: context, builder: (context)=>AlertDialog(
        content: Text('PDF Generated'),
      ));
      await Future.delayed(Duration(seconds: 1));
      Navigator.of(context,rootNavigator: true).pop();
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
      );
    }catch(e){
      showDialog(context: context, builder: (context)=>AlertDialog(
        content: Text(e.toString()),
      ));
    }
  }
}




